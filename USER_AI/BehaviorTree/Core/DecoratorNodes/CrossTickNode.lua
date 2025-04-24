local Node = require("AI_sakray.USER_AI.BehaviorTree.Core.Node")
local CrossTickNode = setmetatable({}, { __index = Node })
CrossTickNode.__index = CrossTickNode

function CrossTickNode:new(child, clear)
    local node = setmetatable(Node.new(self), self)
    node.child = child
    node.clear = clear -- 可选的清理函数
    return node
end

function CrossTickNode:execute()
    -- 如果当前运行的节点是自己，继续执行子节点
    if currentRunningNode == self then
        local status = self.child:execute()
        if status ~= Node.Status.RUNNING then
            -- 子节点完成，调用清理函数（如果有）
            if self.clear then
                self.clear()
            end
            currentRunningNode = nil -- 清除当前运行的节点
        end
        return status
    end

    -- 如果没有其他节点在运行，执行子节点
    if currentRunningNode == nil then
        local status = self.child:execute()
        if status == Node.Status.RUNNING then
            currentRunningNode = self -- 标记为当前运行的节点
        elseif status ~= Node.Status.RUNNING and self.clear then
            -- 如果子节点立即完成，调用清理函数
            self.clear()
        end
        return status
    end

    -- 有其他节点在运行，跳过执行
    return Node.Status.FAILURE
end

return CrossTickNode