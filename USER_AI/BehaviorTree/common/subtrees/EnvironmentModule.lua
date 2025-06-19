local Environment = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.Environment'

local EnvironmentSubTree = Sequence:new({
    ActionNode:new(Environment),
    -- 需要保持 Buff 吗
    Succeeder:new(
        Sequence:new({
            -- 判断 续buff 开关
            ConditionNode:new(function()
                if Blackboard.buff_conf == nil then
                    return NodeStates.FAILURE
                else
                    return NodeStates.SUCCESS
                end
            end),
            -- 续buff
            ActionNode:new(function()
                local conf = Blackboard.buff_conf

                for index, value in ipairs(conf) do
                    local level = value[1]
                    local type = value[2]

                    if Blackboard.cooldown:get(type) == nil then
                        --使用技能
                        ---@type UseSkillTask
                        local task = {
                            name = 'UseSkill',
                            level = level,
                            type = type,
                            target_id = Blackboard.id
                        }

                        TryJumpTask(task, {})
                    end
                end
            end)
        })
    ),
    -- 保持在屏幕内
    ActionNode:new(function()
        -- 如果超过，那么 插队一个下一tick回到视野内的Task
        if Blackboard.objects.owner.distance >= SCREEN_MAX_DISTANCE then
            -- 走两步得了，push 一个 Stop task
            MoveToOwner(Blackboard.id)

            -- local currTask = Blackboard.task

            -- if currTask ~= nil then
            --     Blackboard.task = nil
            --     Blackboard.task_queue:unshift(currTask)
            -- end

            local task = {
                name = 'Stop'
            }

            TryJumpTask(task, { removeUniqueTask = true })
        end

        return NodeStates.SUCCESS
    end)
})

return EnvironmentSubTree
