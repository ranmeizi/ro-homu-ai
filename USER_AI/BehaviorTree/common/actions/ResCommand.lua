local ActionNode = require "AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode"

return ActionNode:new(function ()
    -- 去找有没有客户端发来的指令，如果有，那么就存入
    TraceAI('Action ResCommand')
    return NodeStates.SUCCESS
end)