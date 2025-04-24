local Farm = require 'AI_sakray.USER_AI.BehaviorTree.common.task.Farm'

local TaskModule = {
    tasks={
        Farm = Farm
    }
}
TaskModule.__index = TaskModule

function TaskModule.execute()
    TraceAI('TaskModule start')

    -- 检查任务
    if Blackboard.task == nil then
        TraceAI('TaskModule Failure')
        return NodeStates.FAILURE
    end


    TraceAI('TaskModule Success')

    return NodeStates.SUCCESS
end

return TaskModule