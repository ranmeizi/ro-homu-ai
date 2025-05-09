local ResCommand = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.ResCommand'
local UseSkill = require('AI_sakray/USER_AI/BehaviorTree/common/actions/UseSkill')

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
    -- 消费 cmds
    local cmd = Blackboard.cmds:shift()

    -- 创建一个 MoveTo Task
    Blackboard.task = {
        name = 'Kill',
        target_id = cmd[2]
    }
end

---@params index number
---@params type 1|3|7|9
local function createCmdCondition(index, type)
    return function()
        local cmd = index == 1
            and Blackboard.cmds:get(1)
            or Blackboard.cmds:get(2)

        if cmd ~= nil and cmd[1] == type then
            return NodeStates.SUCCESS
        else
            return NodeStates.FAILURE
        end
    end
end

local timerName = 'cmd_timer'

local function clear()
    Blackboard.cmds:clear()
end

local function Todo()
    clear()
end

--[[
    这里规定，下命令，在主人周围 8 格 代表 8个 options
    1️⃣2️⃣3️⃣       -1,-1 | 0,-1 | 1,-1
    4️⃣👨🏻‍🦳5️⃣       -1,0  |      | 1,0
    6️⃣7️⃣8️⃣       -1,1  | 0,1  | 1,1
]]
local function getValidOptions(x, y)
    local ox = Blackboard.objects.owner.pos.x
    local oy = Blackboard.objects.owner.pos.y

    -- 定义相对坐标与选项编号的映射
    local optionsMap = {
        ["-1,-1"] = 1, -- 左上
        ["0,-1"]  = 2, -- 上
        ["1,-1"]  = 3, -- 右上
        ["-1,0"]  = 4, -- 左
        ["1,0"]   = 5, -- 右
        ["-1,1"]  = 6, -- 左下
        ["0,1"]   = 7, -- 下
        ["1,1"]   = 8  -- 右下
    }

    -- 计算相对坐标
    local dx = x - ox
    local dy = y - oy

    -- 查找选项编号
    local key = string.format("%d,%d", dx, dy)
    return optionsMap[key]
end

-- 选项
local OptionHandlers = {
    --option 1 开启 farm task
    function()
        ---@type FarmTask
        local task = {
            name = 'Farm'
        }

        TryJumpTask(task, { removeUniqueTask = true })

        clear()
    end,
    -- option2
    Todo,
    -- option3
    Todo,
    -- option4
    Todo,
    -- option5
    Todo,
    -- option6
    Todo,
    -- option7
    Todo,
    -- option8
    Todo
}

-- 好像有些太啰嗦，就当是测试节点，以后用一个function搞定

local CommandModule = Sequence:new({
    -- 获取消息
    ActionNode:new(ResCommand),
    -- 判断
    Succeeder:new(
        Selector:new({
            Sequence:new({
                -- 判断第一位是不是 FOLLOW_CMD,如果是，进入后续 x tick 的第二 cmd 的判断
                ConditionNode:new(createCmdCondition(1, FOLLOW_CMD)),
                -- 这里要进行第二次判断,如果通过 就结束
                Inverter:new(
                    Selector:new({
                        Sequence:new({
                            -- alt+t 连击 结束所有任务，进入 IDLE 状态
                            ConditionNode:new(createCmdCondition(2, FOLLOW_CMD)),
                            ActionNode:new(function()
                                clear()
                                Blackboard.task = nil
                                Blackboard.task_queue:clear()

                                return NodeStates.SUCCESS
                            end)
                        }),
                        Sequence:new({
                            -- 用 Move 命令选中 人物周边8个格子，代表8个选项
                            ConditionNode:new(createCmdCondition(2, MOVE_CMD)),
                            ActionNode:new(function()
                                local _, x, y = Blackboard.cmds:get(2)

                                local opt = getValidOptions(x, y)

                                if opt == nil then
                                    return NodeStates.FAILURE
                                else
                                    -- 执行对应选项 handler
                                    OptionHandlers[opt]()
                                    return NodeStates.SUCCESS
                                end
                            end)
                        }),
                    })
                ),
                -- 删除第二位
                ActionNode:new(function()
                    Blackboard.cmds:clear()
                    Blackboard.cmds:push({
                        FOLLOW_CMD
                    })
                end),
                -- Timeout节点  只有Timeout可以结束这个为期2秒的判断，所以 alt + t 慎点
                Timeout:new(
                    timerName,
                    -- 清空命令
                    ActionNode:new(clear),
                    2000
                )
            }),
            Sequence:new({
                -- 判断第一位是不是 MOVE_CMD
                ConditionNode:new(createCmdCondition(1, MOVE_CMD)),
                -- 插队一个 MoveTo Task
                ActionNode:new(createMoveToTask)
            }),
            Sequence:new({
                -- 判断第一位是不是 ATTACT_OBJET_CMD
                ConditionNode:new(createCmdCondition(1, ATTACT_OBJET_CMD)),
                -- 插队一个 Kill Task
                ActionNode:new(createKillTask)
            }),
            Sequence:new({
                -- 判断第一位是不是 MOVE_CMD
                ConditionNode:new(createCmdCondition(1, SKILL_OBJECT_CMD)),
                -- 放技能
                ActionNode:new(function()
                    -- 消费 cmds
                    local cmd = Blackboard.cmds:shift()

                    UseSkill(cmd[2], cmd[3], cmd[4])
                end)
            }),
        })
    )
})

return CommandModule
