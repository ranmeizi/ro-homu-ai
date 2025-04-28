local MoveTo = require('AI_sakray/USER_AI/BehaviorTree/common/actions/MoveTo')
--[[
    MoveToPos

    移动到 target pos
]]

return Task:new(
    ActionNode:new(function()
        ---@class MoveToTask
        ---@field name 'MoveTo'
        ---@field pos_x number|nil  要么给 xy 要么给 target_id
        ---@field pos_y number|nil
        ---@field target_id number|nil
        local task = Blackboard.task

        return MoveTo({
            pos_x = task.pos_x,
            pos_y = task.pos_y,
            target_id = task.target_id
        })
    end)
)
