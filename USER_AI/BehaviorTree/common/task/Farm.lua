TraceAI('FindTarget')
local FindTarget = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.FindTarget'

--[[
    Farm loop

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
    ActionNode:new(function()
        -- 重置
        Blackboard.objects.bestTarget = nil

        local res = FindTarget.madDogFindTarget()

        Blackboard.objects.bestTarget = res

        if res == nil then
            MoveToOwner(Blackboard.id)

            -- TODO 没有目标 这里往点击队列里 push 一个坐标
            ---
            --- 一定要往可移动的地方走，这很重要！
            --- 但脚本并不知道哪里能走
            --- 所以这个功能可以针对地图启用, 能到达的地方 给这个坐标加分，到达不了的地方分数为 0
            --- 久而久之，到达不了的地方点击频率就会明显下降
            --- 
            --- 这个map数据 需要持久化记录，不能让努力白费
            --- 这个map 要人手动走地图 where 去取坐标建立，或是用option拨号？
            --- 
            --- 在一个方向上的随机，将移动路线按坐标或是生命体移动方向，还是怎么地，做分类，
            --- 看他在那个象限，再再这个象限的一定距离外，随机选一个点
            --- 这可能与 "到达不了的点" 冲突， 此时应该往相反的象限移动，或是点击飞行翅膀
        end

        return NodeStates.SUCCESS
    end),
    -- 发布Kill任务
    ActionNode:new(function()
        if Blackboard.objects.bestTarget == nil then
            return NodeStates.FAILURE
        end

         -- 插队一个 Kill
         local task = {
            name = 'Kill',
            target_id = Blackboard.objects.bestTarget
        }

        TryJumpTask(task, {})

        return NodeStates.FAILURE
    end)
})

return Farm
