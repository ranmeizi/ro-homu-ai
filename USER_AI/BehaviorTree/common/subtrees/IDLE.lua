--[[
    一直保持在主人身边，随便走走

    a - 静止模式
    b - 反击
    c - 拉怪保护主人
    d - 没事干 整活
        d1 - 随机绕一圈模式 (创建一个绕一圈task)
        d2 - 休闲模式 随便走走 (随便走 task 间隔 4000ms)
        d3 - 惊吓模式 快速乱走 (最边走 task 间隔 0ms)
        d4 - 画爱心
]]
local IDLE = Sequence:new({
    -- 有 target 就去攻击

    -- 离开

    -- 跟住主人
    -- Sequence:new({
    --     ConditionNode:new(function()
    --         if Blackboard.objects.owner.distance > IDLE_FOLLOW_DISTANCE then
    --             return NodeStates.SUCCESS
    --         end

    --         return NodeStates.FAILURE
    --     end),
    --     ActionNode:new(function()
    --         MoveToOwner(Blackboard.id)
    --     end)
    -- })

})

return IDLE
