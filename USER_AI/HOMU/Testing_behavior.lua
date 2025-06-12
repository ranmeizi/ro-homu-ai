local CommandModule = require 'AI_sakray.USER_AI.BehaviorTree.common.subtrees.CommandModule'
local TaskModule = require 'AI_sakray.USER_AI.BehaviorTree.common.subtrees.TaskModule'
local EnvironmentModule = require 'AI_sakray.USER_AI.BehaviorTree.common.subtrees.EnvironmentModule'
local IDLE = require('AI_sakray/USER_AI/BehaviorTree/common/subtrees/IDLE')
local TestBehaviorTree = {}

local MOVE_RIGHT = ActionNode:new(function()
    Move(Blackboard.id, Blackboard.objects.homu.pos.x + 1, Blackboard.objects.homu.pos.y)
end)

-- 定义行为树结构
TestBehaviorTree.root = Sequence:new({
    CommandModule,
    EnvironmentModule,
    Inverter:new(TaskModule), -- 取反，因为 Task 执行成功，意味着没事可做了
    IDLE
})



return TestBehaviorTree
