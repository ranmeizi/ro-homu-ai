local Farm = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Farm'
local MoveTo = require 'AI_sakray.USER_AI.BehaviorTree.common.task.MoveTo'
local Kill = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Kill'
local BackToScreen = require('AI_sakray.USER_AI.BehaviorTree.common.task.BackToScreen')
local Stop = require('AI_sakray/USER_AI/BehaviorTree/common/task/Stop')

local handlers = {
    MoveTo = MoveTo,
    Kill = Kill,
    BackToScreen = BackToScreen,
    Stop = Stop
}

local TaskModule = {

}
TaskModule.__index = TaskModule

function TaskModule.execute()
    -- TraceAI('TaskModule start')

    -- 检查任务
    if Blackboard.task == nil then
        -- TraceAI('TaskModule Failure,reason no task')
        return NodeStates.FAILURE
    end

    -- TraceAI('seeeeeee' .. Blackboard.task.name)
    -- 检查handler
    local handler = handlers[Blackboard.task.name]

    if handler == nil then
        -- TraceAI('TaskModule Failure,reason no handler')
        return NodeStates.FAILURE
    end

    -- TraceAI('TaskModule Success')

    return handler:execute()
end

return TaskModule
