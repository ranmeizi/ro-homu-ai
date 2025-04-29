local ResCommand = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.ResCommand'

--- 创建 MoveTo Task
--- [MoveTo.lua](${workspaceFolder}/USER_AI/BehaviorTree/common/task/MoveTo.lua)
local function createMoveToTask()
    -- 消费 cmds
    local cmd = Blackboard.cmds:shift()


    -- 创建一个 MoveTo Task
    Blackboard.task = {
        name = 'MoveTo',
        pos_x = cmd[2],
        pos_y = cmd[3]
    }
end

--- 创建 Kill Task
--- [Kill.lua](${workspaceFolder}/USER_AI/BehaviorTree/common/task/Kill.lua)
local function createKillTask()
    TraceAI('createKillTask')
    -- 消费 cmds
    local cmd = Blackboard.cmds:shift()

    -- 创建一个 MoveTo Task
    Blackboard.task = {
        name = 'Kill',
        target_id = cmd[2]
    }
end

-- 插队
local function tryJumpTask(createTaskFn)
    return function()
        -- 把当前 task leftpush 到 task_queue
        local currTask = Blackboard.task

        if currTask ~= nil then
            Blackboard.task = nil
            List.pushleft(Blackboard.task_queue, currTask)
        end

        TraceAI('tryJumpTask: SSBSBSBSBSBSB ')
        -- 创建任务
        createTaskFn()

        return NodeStates.SUCCESS
    end
end

---@params index number
---@params type 1|3|7|9
local function createCmdCondition(index, type)
    return function()
        local cmd = index == 1
            and Blackboard.cmds:get(1)
            or Blackboard.cmds:get(2)

        TraceAI('createCmdCondition: '.. json.encode(Blackboard.cmds:get(1)))
        if cmd ~= nil and cmd[1] == type then
            return NodeStates.SUCCESS
        else
            return NodeStates.FAILURE
        end
    end
end

local CommandModule = Sequence:new({
    -- 获取消息
    ActionNode:new(ResCommand),
    -- 判断
    Succeeder:new(
        Selector:new({
            Sequence:new({
                -- 判断第一位是不是 FOLLOW_CMD,如果是，进入后续 x tick 的第二 cmd 的判断
                ConditionNode:new(createCmdCondition(1, FOLLOW_CMD)),
                -- Timeout节点
            }),
            Sequence:new({
                -- 判断第一位是不是 MOVE_CMD
                ConditionNode:new(createCmdCondition(1, MOVE_CMD)),
                -- 插队一个 MoveTo Task
                ActionNode:new(tryJumpTask(createMoveToTask))
            }),
            Sequence:new({
                -- 判断第一位是不是 MOVE_CMD
                ConditionNode:new(createCmdCondition(1, ATTACT_OBJET_CMD)),
                -- 插队一个 Kill Task
                ActionNode:new(createKillTask)
            }),
        })
    )
})

return CommandModule
