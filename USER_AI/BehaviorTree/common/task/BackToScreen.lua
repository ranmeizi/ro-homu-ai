return Task:new(
    RunningOrNot:new(
        Inverter:new(
            Sequence:new({
                --  判断是否是视野外
                ConditionNode:new(function()
                    return Blackboard.objects.homu.distance > 13
                        and NodeStates.SUCCESS
                        or NodeStates.FAILURE
                end),
                --  移动到主人身边
                ActionNode:new(function()
                    Move(Blackboard.id, Blackboard.objects.owner.pos.x, Blackboard.objects.owner.pos.y)
                end)
            })
        )
    )
)
