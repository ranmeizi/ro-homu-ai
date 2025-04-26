--[[
    MoveToPos

    移动到 target pos
]]

local ActionNode = require('AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode')
local Task = require('AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Task')
local json = require('AI_sakray.USER_AI.libs.dkjson')

return Task:new(
    ActionNode:new(function()

        TraceAI('Action MoveTo')

        ---@class MoveToTask
        ---@field name 'MoveTo'
        ---@field pos_x number|nil  要么给 xy 要么给 target_id
        ---@field pos_y number|nil
        ---@field target_id number|nil
        local task = Blackboard.task

        TraceAI('看一下任务'..json.encode(task))

        -- 目标
        if task.target_id == nil and (task.pos_x == nil or task.pos_y == nil) then
            return NodeStates.FAILURE -- 拜拜 没法move task 结束
        end

        -- 结束条件
        local homu_x, homu_y = GetV(V_POSITION, Blackboard.id)

        local x = task.pos_x;
        local y = task.pos_y;

        if task.target_id ~= nil then
            -- 实时更新一下 target 的位置
            x, y = GetV(V_POSITION, task.target_id)
        end

        if homu_x == x and homu_y == y then
            -- target 的目标一般会因为攻击 提前结束
            return NodeStates.SUCCESS
        end

        -- 移动
        Move(Blackboard.id, x, y)

        return NodeStates.RUNNING
    end)
)
