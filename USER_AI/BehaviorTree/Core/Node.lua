local Node = {}
Node.__index = Node

function Node:new()
    local obj = {}
    setmetatable(obj, self)
    return obj
end

function Node:execute()
    error("execute() must be implemented in derived classes")
end

return Node