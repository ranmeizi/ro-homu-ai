local FindBestTarget = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.FindBestTarget'

--[[
    Farm

    从 Command 发送练级命令，进入练级任务

    这个节点主要是一个任务发布策略

    如果没有目标那么去插队一个【寻敌】任务

    如果有目标，去插队一个【Kill】任务

    就如此循环

    Command 可以发送 取消全部任务的命令，只有这样才能结束这个状态

    应该不需要Task 包裹，等task 有了新的功能再说把
]]
local Farm = Sequence:new({
    -- 寻敌
    ActionNode:new(FindBestTarget),
    -- 发布Kill任务
    ActionNode:new(function()
        -- 还是校验一下保险
        if Blackboard.objects.bestTarget ~= nil then
            Blackboard.task = {
                name = 'Kill',
                target_id = Blackboard.objects.bestTarget.id
            }

            Blackboard.objects.bestTarget = nil
        end

        return NodeStates.SUCCESS
    end)
})

return Farm
