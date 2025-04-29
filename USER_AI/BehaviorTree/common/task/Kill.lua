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
    local target_id = task.target_id

    local target = Blackboard.objects.monsters[target_id]
    if target == nil then
        return NodeStates.SUCCESS
    end

    if target.motion == MOTION_DEAD then
        return NodeStates.SUCCESS
    end

    return NodeStates.RUNNING
end

--- @param task KillTask
local function ActionAttack(task)
    return NormalAttack(task.target_id)
end

--- @param task KillTask
local function ActionMoveTo(task)
    return MoveTo({ target_id = task.target_id })
end

local Kill = Task:new(
    Sequence:new({
        -- 条件 目标活着?
        RunningOrNot:new(
            Inverter:new(
                ConditionNode:new(
                    Task.withTask(ConditionIsDead)
                )
            )
        ),
        Succeeder:new(
            Sequence:new({
                -- 尝试攻击
                ActionNode:new(Task.withTask(ActionAttack)),
                -- 移动到目标
                ActionNode:new(Task.withTask(ActionMoveTo))
            })
        )
    })
)

return Kill
