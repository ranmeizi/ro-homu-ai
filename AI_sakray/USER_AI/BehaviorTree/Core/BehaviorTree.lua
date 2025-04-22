local BehaviorTree = {}
BehaviorTree.__index = BehaviorTree

function BehaviorTree:new(root)
    local obj = { root = root }
    setmetatable(obj, self)
    return obj
end

function BehaviorTree:run()
    if self.root then
        self.root:execute()
    end
end

return BehaviorTree