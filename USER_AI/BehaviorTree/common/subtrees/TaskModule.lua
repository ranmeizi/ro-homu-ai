local Farm = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Farm'

local handlers = {
    Farm = Farm
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

    if handler.execute() ~= NodeStates.SUCCESS then
        -- 结束任务?
    end

    return NodeStates.SUCCESS
end

return TaskModule
