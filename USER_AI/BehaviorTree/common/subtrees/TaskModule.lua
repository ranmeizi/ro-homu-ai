local Farm = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Farm'
local MoveTo = require 'AI_sakray.USER_AI.BehaviorTree.common.task.MoveTo'

local handlers = {
    MoveTo = MoveTo
}

local TaskModule = {

}
TaskModule.__index = TaskModule

function TaskModule.execute()
    TraceAI('TaskModule start')

    -- 检查任务
    if Blackboard.task == nil then
        TraceAI('TaskModule Failure')
        return NodeStates.FAILURE
    end

    -- 检查handler
    local handler = handlers[Blackboard.task.name]

    if handler == nil then
        TraceAI('TaskModule Failure')
        return NodeStates.FAILURE
    end

    TraceAI('TaskModule Success')

    return handler:execute()
end

return TaskModule
