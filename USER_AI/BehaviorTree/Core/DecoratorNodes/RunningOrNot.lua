local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local RunningOrNot = setmetatable({}, { __index = Node })
RunningOrNot.__index = RunningOrNot

function RunningOrNot:new(child)
    local node = setmetatable(Node.new(self), self)
    node.child = child
    return node
end

function RunningOrNot:execute()
    -- 执行子节点
    local status = self.child:execute()

    -- 如果子节点返回 SUCCESS，将其转换为 RUNNING
    if status == NodeStates.SUCCESS then
        return NodeStates.RUNNING
    end

    -- 其他状态保持不变
    return status
end

return RunningOrNot