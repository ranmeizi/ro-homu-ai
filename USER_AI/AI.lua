-- 挂全局
_G.json = require('AI_sakray/USER_AI/libs/dkjson')
_G.Array = require('AI_sakray/USER_AI/libs/ArrayLike')


require 'AI_sakray.USER_AI.Const'
require 'AI_sakray.USER_AI.Util'
require 'AI_sakray.USER_AI.Memory'
require('AI_sakray/USER_AI/BehaviorTree/Core/init')


local TestingBT = require 'AI_sakray.USER_AI.HOMU.Testing_behavior'



-- 读取 memory
Memory.load()

-- 全局黑板
Blackboard = {
    id = nil, -- 生命体id

    owner_id = nil,

    memory = Memory, -- 需要持久化的数据

    target_id = nil, -- 目标(不一定是攻击对象，也有可能有些整活用这个)

    attack_id = nil, -- 攻击目标

    -- 客户端发送命令列表
    cmds = Array:new({}),

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
            attack_range = 0
        },

        -- 怪物列表
        monsters = {},

        -- 记录 find taeget 的结果
        bestTarget = nil
    },

    -- IDLE 配置
    idle_state = {

    }
}

TraceAI('object')

-- 初始化行为树
local tree = BehaviorTree:new(TestingBT.root)

TraceAI('tree')

local function loop(id)
    -- TraceAI('AI loop start')
    -- 记录id
    Blackboard.id = id
    Blackboard.owner_id = GetV(V_OWNER, id)

    Memory.tick = GetTick()

    TraceAI('tick:'..Memory.tick)

    -- if Memory.tick % 10 == 0 then
    --     TraceAI('env' .. json.encode(Blackboard.objects))
    -- end

    -- 运行行为树
    tree:run()

end

function AI(id)
    xpcall(function()
        loop(id)
    end, function(err)
        TraceAI('出错天了噜' .. tostring(err))
        -- 保存 memory

        -- 打印堆栈信息
        TraceAI(debug.traceback(err))
        -- 抛出异常
        -- error(err)
    end)
end
