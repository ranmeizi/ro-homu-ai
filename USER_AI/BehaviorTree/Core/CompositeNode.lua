local Node = require 'AI_sakray.USER_AI.BehaviorTree.Core.Node'
local CompositeNode = setmetatable({}, { __index = Node })

function CompositeNode:new(children)
    local obj = Node:new()
    obj.children = children or {}
    setmetatable(obj, self)
    return obj
end

function CompositeNode:execute()
    for _, child in ipairs(self.children) do
        if child:execute() then
            return true
        end
    end
    return false
end

return CompositeNode