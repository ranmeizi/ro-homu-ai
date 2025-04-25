require 'AI_sakray.USER_AI.Const'
require 'AI_sakray.USER_AI.Util'
require 'AI_sakray.USER_AI.Memory'
local json = require('AI_sakray.USER_AI.libs.dkjson')
local BehaviorTree = require 'AI_sakray.USER_AI.BehaviorTree.Core.BehaviorTree'

local TestingBT = require 'AI_sakray.USER_AI.HOMU.Testing_behavior'

-- 读取 memory
Memory.load()

-- 全局黑板
Blackboard = {
    memory = Memory, -- 需要持久化的数据

    target_id = nil, -- 目标(不一定是攻击对象，也有可能有些整活用这个)

    attack_id = nil, -- 攻击目标

    -- 任务记录
    task = nil,

    -- 任务队列
    task_queue = List:new(),

    -- 调用 Environment 记录 objects
    objects = {
        -- 生命值
        hp = nil,
        -- 最大生命值
        hp_max = nil,
        -- 魔法值
        sp = nil,
        -- 最大魔法值
        sp_max = nil,

        -- 怪物列表
        monsters = {},
        -- 永远到达不了的目标，MoveTo timeout 的目标加进去
        unreachable = {},
    }
}

-- 初始化行为树
local tree = BehaviorTree:new(TestingBT.root)

local function loop(id)
    local msg = GetMsg(id)   -- command
    local rmsg = GetResMsg(id) -- reserved command


    if msg then
        TraceAI('msg' .. json.encode(msg))
    end

    if rmsg then
        TraceAI('rmsg' .. json.encode(rmsg))
    end

    -- TraceAI("tick:" .. Memory.tick)
    Memory.tick = Memory.tick + 1

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
