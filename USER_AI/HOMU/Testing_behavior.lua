local Sequence = require("AI_sakray.USER_AI.BehaviorTree.Core.ControlNodes.Sequence")
local ActionNode = require("AI_sakray.USER_AI.BehaviorTree.Core.ExecutionNodes.ActionNode")
local ResCommand = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.ResCommand'
local TaskModule = require 'AI_sakray.USER_AI.BehaviorTree.Core.TaskModule'
local Inverter = require 'AI_sakray.USER_AI.BehaviorTree.Core.DecoratorNodes.Inverter'
local Environment = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.Enviroment'

local TestBehaviorTree = {}

-- 定义行为树结构
TestBehaviorTree.root = Sequence:new({
    ResCommand,
    Inverter:new(TaskModule),
    Environment
})

return TestBehaviorTree