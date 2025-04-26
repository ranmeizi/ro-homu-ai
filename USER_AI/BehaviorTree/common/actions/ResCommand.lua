local ActionNode = require "AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode"
local json = require('AI_sakray.USER_AI.libs.dkjson')

return ActionNode:new(function()
    -- 去找有没有客户端发来的指令，如果有，那么就存入，由 CommandModule 后续节点去消费 cmd列表中的命令
    local msg = GetMsg(Blackboard.id)
    GetResMsg(Blackboard.id)

    TraceAI('kanyixia msgs'.. List.size(Blackboard.cmds))

    if msg ~= nil and msg[1] ~= NOME_CMD then
        TraceAI('有消息'.. json.encode(msg))
        List.pushright(Blackboard.cmds, msg)
    end

    

    return NodeStates.SUCCESS
end)
