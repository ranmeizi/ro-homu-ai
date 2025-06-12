-- 挂全局
_G.json = require('AI_sakray/USER_AI/libs/dkjson')
_G.Array = require('AI_sakray/USER_AI/libs/ArrayLike')
_G.CacheControl = require('AI_sakray/USER_AI/libs/CacheControl')


require('AI_sakray/USER_AI/Const')
require('AI_sakray/USER_AI/Util')
require('AI_sakray/USER_AI/BehaviorTree/Core/init')


local TestingBT = require 'AI_sakray.USER_AI.HOMU.Testing_behavior'
local clearBlackListInterval = require 'AI_sakray/USER_AI/BehaviorTree/common/actions/FindTarget'
local HpSpRecorder = require('AI_sakray/USER_AI/HOMU/calc')

local RecoveryRecorder = HpSpRecorder.new(120, 200)

-- 全局黑板
Blackboard = {
    id = nil, -- 生命体id

    owner_id = nil,

    target_id = nil, -- 目标(不一定是攻击对象，也有可能有些整活用这个)

    attack_id = nil, -- 攻击目标

    -- 客户端发送命令列表
    cmds = Array:new({}),

    -- 计时器 table
    timers = {},

    --[[
        任务记录
        {
            name: '任务名称',
            ... 按任务定义的动态参数类型
        }
    ]] --
    task = nil,

    -- 任务队列
    task_queue = Array.new({}),

    -- 寻敌黑名单
    black_list_cache = CacheControl:new(),

    -- 调用 Environment 记录 objects , 后面可以用外置应用读出来
    objects = {
        -- 生命体
        homu = {
            id = nil,
            -- 生命值
            hp = nil,
            -- 最大生命值
            hp_max = nil,
            -- 魔法值
            sp = nil,
            -- 最大魔法值
            sp_max = nil,
            -- 类型(编号)
            type = nil,
            -- 位置
            pos = { x = nil, y = nil },
            -- 攻击距离
            attack_range = 0
        },
        -- 主人
        owner = {
            id = nil,
            -- 生命值
            hp = nil,
            -- 最大生命值
            hp_max = nil,
            -- 魔法值
            sp = nil,
            -- 最大魔法值
            sp_max = nil,
            -- 类型(编号)
            type = nil,
            -- 位置
            pos = { x = nil, y = nil },
            -- 攻击距离
            attack_range = 0,
            -- 目标
            target = nil,
            distance = nil
        },

        -- 怪物列表
        monsters = {},

        -- 生命体 仇恨列表
        hateListHomu = Array:new({}),

        -- 主人 仇恨列表
        hateListOwner = Array:new({}),

        -- 记录 find taeget 的结果
        bestTarget = nil
    },

    -- 记录日志
    logs = {
        -- hp 回复速度
        hp_avg_regen = 0,
        -- sp 回复速度
        sp_avg_regen = 0,
    }
}

-- 初始化行为树
local tree = BehaviorTree:new(TestingBT.root)

function showTasks()
    if Blackboard.task == nil then
        TraceAI('current task: nil')
    else
        TraceAI('current task:' .. Blackboard.task.name)
    end


    local queue = 'task queue:'

    for index, value in Blackboard.task_queue:ipairs() do
        queue = queue .. value.name .. ','
    end

    TraceAI(queue)
end

local function loop(id)
    TraceAI('AI loop start')
    -- 记录id
    Blackboard.id = id
    Blackboard.owner_id = GetV(V_OWNER, id)

    showTasks()

    -- 运行行为树
    tree:run()
end

function AI(id)
    xpcall(function()
        loop(id)

        -- 清理黑名单
        clearBlackListInterval()

        -- 统计代码
        if PerXSecond(1) then
            RecoveryRecorder:record(
                Blackboard.objects.homu.hp,
                Blackboard.objects.homu.hp_max,
                Blackboard.objects.homu.sp,
                Blackboard.objects.homu.sp_max
            )
        end

        if PerXSecond(60) then
            RecoveryRecorder:analyze()
        end
    end, function(err)
        TraceAI('出错天了噜' .. tostring(err))
        -- 保存 memory

        -- 打印堆栈信息
        TraceAI(debug.traceback(err))
        -- 抛出异常
        -- error(err)
    end)
end
