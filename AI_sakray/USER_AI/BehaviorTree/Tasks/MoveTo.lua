local ActionNode = require 'AI_sakray.USER_AI.BehaviorTree.Core.ActionNode'

local MoveTo = ActionNode:new(function()
    print("Moving to target...")
    return true -- 假设任务成功
end)

return MoveTo