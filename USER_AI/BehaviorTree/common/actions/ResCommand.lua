local ActionNode = require "AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode"

return ActionNode:new(function()
    -- 去找有没有客户端发来的指令，如果有，那么就存入，由 CommandModule 后续节点去消费 cmd列表中的命令
    TraceAI('Action ResCommand')

    local msg = GetMsg(Blackboard.id)

    if msg ~= nil then
        List.pushright(Blackboard.cmds, msg)
    end

    return NodeStates.SUCCESS
end)
