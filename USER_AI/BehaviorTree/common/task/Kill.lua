--[[
    Kill 杀死目标 [跨tick]

    需要按照当前目标和场景，决定击杀策略

    场景：

    1.Farm (condition是否处于farm)
    farm 时要尽可能快速击杀，并保持可持续输出，节省hp/sp，减少逃跑回血的时间

    2.FullPower (condition是否要启用 fullpower)
    [注意!] 这个就是想让目标死，不会逃跑的。
    全力击杀，使出自己dps最强的输出手段，再最短时间杀死目标。

    3.SkillOnly
    只使用技能输出

    行为:

    1. 靠近敌人

    2. 攻击敌人

    前置判断:

    1. 目标已死亡 ?
        目标死亡    返回 SUCCESS
        目标未死亡  返回 RUNNING

]]

local NormalAttack = require 'AI_sakray/USER_AI/BehaviorTree/common/actions/NormalAttack'
local MoveTo = require 'AI_sakray/USER_AI/BehaviorTree/common/actions/MoveTo'
local UseSkill = require 'AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill'
local SkillInfo = require('AI_sakray/USER_AI/HOMU/skill')

--- @param task KillTask
local function ConditionIsDead(task)
    --- 没目标了 重新找
    if (task == nil) then
        return NodeStates.SUCCESS
    end

    local target_id = task.target_id
    TraceAI('ConditionIsDead' .. target_id)
    local target = Blackboard.objects.monsters[target_id]
    if target == nil then
        return NodeStates.SUCCESS
    end

    if target.motion == MOTION_DEAD then
        return NodeStates.SUCCESS
    end

    return NodeStates.FAILURE
end

--- @param task KillTask
local function ActionAttack(task)
    return NormalAttack(task.target_id)
end

--- @param task KillTask
local function ActionMoveTo(task)
    return MoveTo({ target_id = task.target_id })
end

--- 多少秒没走到放弃目标
local GIVEUP_TIME = 7 * 1000
--- 忽略该目标多久 - 2分钟
local IGNORE_TIME = 60 * 1000 * 2

--- 支持放弃的 moveto 计时器内返回 success 超出返回 failure
--- 然后把它放入黑名单呆一会
local giveupable_moveto = Selector:new({
    Timeout:new(
        'moveto_timer',
        -- 加入黑名单
        ActionNode:new(function()
            -- 添加到黑名单
            local task = Blackboard.task
            if task == nil then
                return NodeStates.FAILURE
            end
            Blackboard.black_list_cache:set(task.target_id, task.target_id, IGNORE_TIME)

            -- 放弃这个目标
            return NodeStates.SUCCESS
        end),
        GIVEUP_TIME
    ),
    -- 移动到目标
    ActionNode:new(Task.withTask(ActionMoveTo))
})

-- 默认策略
local default_strategy = Succeeder:new(
    Sequence:new({
        -- 尝试攻击
        Inverter:new(
            ActionNode:new(Task.withTask(ActionAttack))
        ),
        -- 移动到目标
        -- ActionNode:new(Task.withTask(ActionMoveTo))
        giveupable_moveto
    })
)

-- 技能攻击比较远距离的人
local filir_kill_skill_on_way_branch = Inverter:new(
    Selector:new({
        -- 技能攻击
        Sequence:new({
            ConditionNode:new(function()
                -- 在路上击杀他
                if Blackboard.task._skillOnWay == true then
                    return NodeStates.SUCCESS
                else
                    return NodeStates.FAILURE
                end
            end),
            ---@param task KillTask
            ActionNode:new(Task.withTask(function(task)
                UseSkill(5, HFLI_MOON, task.target_id)
                return NodeStates.SUCCESS
            end))
        }),
        -- 判断要不要技能攻击
        Sequence:new({
            -- 如果sp充足(10次5级月光sp + buff最低消费)且目标距离>9
            ConditionNode:new(function()
                -- 看看能否连续使用10次5级月光
                local moon_10_cost = SkillInfo.skillbook[HFLI_MOON]['5'].sp_cost * 10
                -- 最低保留sp 保证能用1次 加速+闪避
                local min_sp = SkillInfo.skillbook[HFLI_FLEET]['1'].sp_cost +
                    SkillInfo.skillbook[HFLI_SPEED]['1'].sp_cost

                local min_limit = moon_10_cost + min_sp

                -- 距离
                local distance = GetDistance2(Blackboard.task.target_id, Blackboard.id)

                TraceAI('判断sp呢')
                if distance > 9 and Blackboard.objects.homu.sp > min_limit then
                    return NodeStates.SUCCESS
                else
                    return NodeStates.FAILURE
                end
            end),
            ActionNode:new(function()
                Blackboard.task._skillOnWay = true
                return NodeStates.SUCCESS
            end)
        })
    })
)

-- 飞里乐专属 kill 策略
local filir_kill_subtree = Succeeder:new(
    Sequence:new({
        --- 因为这里 普攻接技能没有延迟，但是技能接普攻有3秒延迟
        --- 所以尽量全用普攻 或是全用技能，如果普攻接技能了就血赚，最好不要出现技能接普攻的现象，这样就是血赚
        ---
        ---1. 第一下一定要普通攻击，因为普通攻击接技能没有延迟
        ---2. 如果sp > 80%，就用技能打
        ---3. 如果sp < 最低消费 就开始不用技能攒蓝量
        ---
        ---1 是尽量嫖 普攻接技能的延迟
        ---2～3 是尽量避免出现 技能接普攻的现象
        ---
        ---然后使用 伤害/sp 性价比最高的技能等级，这样输出最大化
        Inverter:new(
            Selector:new({
                -- 处理 第一下普攻
                Sequence:new({
                    ---@param task KillTask
                    ConditionNode:new(Task.withTask(function(task)
                        if task._hasFirstAttack == true then
                            return NodeStates.FAILURE
                        else
                            return NodeStates.SUCCESS
                        end
                    end)),
                    ActionNode:new(Task.withTask(function(task)
                        local res = NormalAttack(task.target_id)

                        -- 攻击失败
                        if (res == NodeStates.FAILURE) then
                            return res
                        end

                        -- 打完第一下了
                        Blackboard.task._hasFirstAttack = true
                        return NodeStates.SUCCESS
                    end))
                }),
                -- 要不要技能攻击
                ---@param task KillTask
                ActionNode:new(Task.withTask(function(task)
                    TraceAI('攻击失败了，判断技能攻击')
                    if task.mode ~= 'skillonly' and Blackboard.objects.homu.sp > Blackboard.objects.homu.sp_max * 0.8 then
                        Blackboard.task.mode = 'skillonly'
                    end

                    if task.mode == 'skillonly' and Blackboard.objects.homu.sp < SkillInfo.skillbook[HFLI_FLEET]['1'].sp_cost +
                        SkillInfo.skillbook[HFLI_SPEED]['1'].sp_cost then
                        Blackboard.task.mode = 'default'
                    end

                    return NodeStates.FAILURE
                end)),
                ---@param task KillTask
                ActionNode:new(Task.withTask(function(task)
                    if task.mode == 'skillonly' then
                        return UseSkill(1, HFLI_MOON, task.target_id)
                    else
                        return NormalAttack(task.target_id)
                    end
                end))
            })
        ),
        -- 在这里考虑，如果sp充足(10次5级月光sp + buff最低消费)且目标距离>9 ,全程月光攻击 这样如果如果怪死在路上了就赚大了
        -- 人为判断，如果没有5级月光，就把这里注释了吧。。。
        filir_kill_skill_on_way_branch,
        giveupable_moveto
    })
)

local Kill = Task:new(
    RunningOrNot:new(
        Sequence:new({
            -- 条件 目标活着?
            Inverter:new(
                ConditionNode:new(
                    Task.withTask(ConditionIsDead)
                )
            ),
            Selector:new({
                -- 判断是飞里乐
                Sequence:new({
                    ConditionNode:new(function()
                        if Blackboard.type == FILIR then
                            return NodeStates.SUCCESS
                        else
                            return NodeStates.FAILURE
                        end
                    end),
                    filir_kill_subtree
                }),
                -- 默认策略
                default_strategy
            })
        })
    )
)

return Kill
