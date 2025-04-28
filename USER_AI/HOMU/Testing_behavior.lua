local CommandModule = require 'AI_sakray.USER_AI.BehaviorTree.common.subtrees.CommandModule'
local TaskModule = require 'AI_sakray.USER_AI.BehaviorTree.common.subtrees.TaskModule'
local Environment = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.Environment'

local TestBehaviorTree = {}

-- 定义行为树结构
TestBehaviorTree.root = Sequence:new({
    CommandModule,
    ActionNode:new(Environment),
    Inverter:new(TaskModule),

})

return TestBehaviorTree