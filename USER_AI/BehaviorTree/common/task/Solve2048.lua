local Solve2048State = require('AI_sakray/USER_AI/BehaviorTree/common/actions/Solve2048State')

return Task:new(
    RunningOrNot:new(
        ActionNode:new(function()
            return Solve2048State()
        end)
    )
)