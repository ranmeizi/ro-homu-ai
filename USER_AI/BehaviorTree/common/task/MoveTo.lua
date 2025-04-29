local MoveTo = require('AI_sakray/USER_AI/BehaviorTree/common/actions/MoveTo')
--[[
    MoveToPos

    移动到 target pos
]]

return Task:new(
    ActionNode:new(function()
        ---@type MoveToTask
        local task = Blackboard.task

        return MoveTo({
            pos_x = task.pos_x,
            pos_y = task.pos_y,
            target_id = task.target_id
        })
    end)
)
