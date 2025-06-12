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

local Kill = Task:new(
    RunningOrNot:new(
        Sequence:new({
            -- 条件 目标活着?
            Inverter:new(
                ConditionNode:new(
                    Task.withTask(ConditionIsDead)
                )
            ),
            Succeeder:new(
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
        })
    )
)

return Kill
