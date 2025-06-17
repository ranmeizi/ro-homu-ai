-- 挂全局
_G.json = require('AI_sakray/USER_AI/libs/dkjson')
_G.Array = require('AI_sakray/USER_AI/libs/ArrayLike')
_G.CacheControl = require('AI_sakray/USER_AI/libs/CacheControl')


require('AI_sakray/USER_AI/Const')
require 'AI_sakray.USER_AI.Util'
require('AI_sakray/USER_AI/BehaviorTree/Core/init')

TraceAI('test vt start')
local TestingBT = require 'AI_sakray.USER_AI.HOMU.Testing_behavior'
TraceAI('test vt over')
local FilirBT = require 'AI_sakray.USER_AI.HOMU.Filir_behavior'
TraceAI('tree over')
local clearBlackListInterval = require 'AI_sakray/USER_AI/BehaviorTree/common/actions/FindTarget'.clearBlackListInterval
TraceAI('calc start')
local HpSpRecorder = require('AI_sakray/USER_AI/HOMU/calc')

local RecoveryRecorder = HpSpRecorder.new(120, 200)

-- 全局黑板
Blackboard = {
    id = nil, -- 生命体id

    owner_id = nil,

    type = nil,

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

    -- 技能冷却
    cooldown = CacheControl:new(),

    -- 保持增益buff的配置项 (由 Option2 开启/关闭，或是由task开启/关闭)
    buff_conf = nil,

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
        aggroListHomu = Array:new({}),

        -- 主人 仇恨列表
        aggroListOwner = Array:new({}),

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
local filir_tree = BehaviorTree:new(FilirBT.root)

local function showTasks()
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
    Blackboard.type = GetV(V_HOMUNTYPE, id)

    showTasks()

    -- 运行行为树
    filir_tree:run()
end

function AI(id)
    xpcall(function()
        loop(id)

        -- 清理过期黑名单
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

        if PerXSecond(10) then
            local options = {
                indent = true,    -- 美化输出，带缩进和换行
                level = 0,        -- 初始缩进级别
                noprotect = false -- 不保护循环引用
            }

            TraceAI(json.encode(Blackboard.black_list_cache, options))
            TraceAI(json.encode(Blackboard.cooldown, options))
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
