local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Timeout = setmetatable({}, { __index = Node })
Timeout.__index = Timeout

function Timeout:new(child, duration)
    local node = Node.new(self)
    node.child = child
    node.duration = duration
    node.startTime = nil
    return node
end

function Timeout:execute()
    if not self.startTime then
        self.startTime = GetTick()
    end

    if GetTick() - self.startTime > self.duration then
        self.startTime = nil
        return NodeStates.FAILURE
    end

    return self.child:execute()
end

return Timeout
