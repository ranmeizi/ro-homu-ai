local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Retry = setmetatable({}, { __index = Node })
Retry.__index=Retry

function Retry:new(child, maxRetries)
    local node = Node.new(self)
    node.child = child
    node.maxRetries = maxRetries
    return node
end

function Retry:execute()
    for i = 1, self.maxRetries do
        if self.child:execute() then
            return true
        end
    end
    return false
end

return Retry