local Node = require 'AI_sakray.USER_AI.BehaviorTree.Core.Node'
local ActionNode = setmetatable({}, { __index = Node })

function ActionNode:new(action)
    local obj = Node:new()
    obj.action = action
    setmetatable(obj, self)
    return obj
end

function ActionNode:execute()
    return self.action()
end

return ActionNode