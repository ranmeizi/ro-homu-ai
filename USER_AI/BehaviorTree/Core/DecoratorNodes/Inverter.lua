local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Inverter = setmetatable({}, { __index = Node })
Inverter.__index = Inverter

function Inverter:new(child)
    local node = Node.new(self)
    node.child = child
    return node
end

function Inverter:execute()
    return not self.child:execute()
end

return Inverter
