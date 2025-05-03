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
                    -- 生命体坐标
                    local x1 = Blackboard.objects.homu.pos.x
                    local y1 = Blackboard.objects.homu.pos.y

                    -- 主人坐标
                    local x2 = Blackboard.objects.owner.pos.x
                    local y2 = Blackboard.objects.owner.pos.y

                    -- 向主人方向移动1格子
                    local dx = x1 - x2
                    local dy = y1 - y2

                    local movementX = dx > 0 and -1 or 1
                    local movementY = dy > 0 and -1 or 1

                    if dx == 0 then
                        movementX = 0
                    end

                    if dy == 0 then
                        movementY = 0
                    end

                    Move(Blackboard.id, x1 + movementX, y1 + movementY)
                    return NodeStates.FAILURE
                end)
            })
        )
    )
)
