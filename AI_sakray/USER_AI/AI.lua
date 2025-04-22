require 'AI_sakray.USER_AI.Const'
require 'AI_sakray.USER_AI.Util'
require 'AI_sakray.USER_AI.Memory'
local BehaviorTree = require 'AI_sakray.USER_AI.BehaviorTree.Core.BehaviorTree'
local BehaviorTreeConfig = require 'AI_sakray.USER_AI.Config.BehaviorTreeConfig'

-- 读取 memory
Memory.load()

-- 初始化行为树
local tree = BehaviorTree:new(BehaviorTreeConfig.root)

local function loop(id)
    -- 运行行为树
    tree:run()
    -- 保存 memory
    Memory.store()
end

function AI(id)
    xpcall(function()
        loop(id)
    end, function(err)
        -- 保存 memory
        Memory.store()
        -- 抛出异常
        error(err)
    end)
end
