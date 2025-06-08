--[[
    Stop 走的有点快 到视野里停一下

    下面是考虑调用的情况
    1. MoveToOwner 了 停不下来了, Stop 一下
]]

return Task:new(
    RunningOrNot:new(
        Inverter:new(
            Sequence:new({
                -- 判断在屏幕内吗？
                ConditionNode:new(function()
                    TraceAI('Stop ConditionNode')
                    if Blackboard.objects.owner.distance < SCREEN_MAX_DISTANCE - 1 then
                        return NodeStates.SUCCESS
                    else
                        return NodeStates.FAILURE
                    end
                end),
                ActionNode:new(function()
                    TraceAI('ZAI FAN WEI NEI LE')
                    Move(Blackboard.id, Blackboard.objects.homu.pos.x, Blackboard.objects.homu.pos.y)
                    return NodeStates.SUCCESS
                end)
            })
        )
    )
)
