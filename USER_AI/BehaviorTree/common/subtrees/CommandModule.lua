local ActionNode = require 'AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode'
local ConditionNode = require 'AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ConditionNode'
local Selector = require 'AI_sakray.USER_AI.BehaviorTree.Core.ControlNodes.Selector'
local Sequence = require 'AI_sakray.USER_AI.BehaviorTree.Core.ControlNodes.Sequence'
local ResCommand = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.ResCommand'

--- 创建 MoveTo Task
--- [MoveTo.lua](${workspaceFolder}/USER_AI/BehaviorTree/common/task/MoveTo.lua)
local function createMoveToTask()
    -- 消费 cmds
    local _, x, y = List.popleft(Blackboard.cmds)
    -- 创建一个 MoveTo Task
    Blackboard.task = {
        name = 'MoveTo',
        pos_x = x,
        pos_y = y
    }
end

-- 插队
local function tryJumpTask(createTaskFn)
    return function()
        -- 把当前 task leftpush 到 task_queue
        local currTask = Blackboard.task

        if currTask ~ -nil then
            Blackboard.task = nil
            List.pushleft(Blackboard.task_queue, currTask)
        end

        -- 创建任务
        createTaskFn()

        return NodeStates.SUCCESS
    end
end

---@params index number
---@params type 1|3|7|9
local function createCmdCondition(index, type)
    return function()
        local cmd = Blackboard.cmds[index]
        if cmd[1] == type then
            return NodeStates.SUCCESS
        else
            return NodeStates.FAILURE
        end
    end
end

local CommandModule = Sequence:new({
    -- 获取消息
    ResCommand:new(),
    -- 判断
    Selector:new({
        Sequence:new({
            -- 判断第一位是不是 FOLLOW_CMD,如果是，进入后续 x tick 的第二 cmd 的判断
            ConditionNode(createCmdCondition(1, FOLLOW_CMD)),
            -- Timeout节点
        }),
        Sequence:new({
            -- 判断第一位是不是 MOVE_CMD
            ConditionNode:new(createCmdCondition(1, MOVE_CMD)),
            -- 插队一个 MoveTo Task
            ActionNode:new(tryJumpTask(createMoveToTask))
        }),
    })
})
