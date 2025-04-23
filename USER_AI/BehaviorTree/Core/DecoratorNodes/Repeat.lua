local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local Repeat = setmetatable({}, { __index = Node })
Repeat.__index = Repeat

function Repeat:new(child, times)
    local node = Node.new(self)
    node.child = child
    node.times = times
    return node
end

function Repeat:execute()
    for i = 1, self.times do
        if not self.child:execute() then
            return false
        end
    end
    return true
end

return Repeat
