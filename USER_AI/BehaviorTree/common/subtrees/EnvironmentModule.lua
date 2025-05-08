local Environment = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.Environment'

local EnvironmentSubTree = Sequence:new({
    ActionNode:new(Environment),
    -- 保持在屏幕内
    ActionNode:new(function()
        -- 如果超过，那么 插队一个下一tick回到视野内的Task
        if Blackboard.objects.homu.distance >= SCREEN_MAX_DISTANCE then
            -- 走两步得了，push 一个 Stop task
            MoveToOwner(Blackboard.id)

            local currTask = Blackboard.task

            if currTask ~= nil then
                Blackboard.task = nil
                Blackboard.task_queue:unshift(currTask)
            end

            local task = {
                name = 'Stop'
            }

            TryJumpTask(task, { removeUniqueTask = true })
        end
    end)
})

return EnvironmentSubTree
