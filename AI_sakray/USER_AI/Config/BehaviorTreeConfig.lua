local CompositeNode = require 'AI_sakray.USER_AI.BehaviorTree.Core.CompositeNode'
local MoveTo = require 'AI_sakray.USER_AI.BehaviorTree.Tasks.MoveTo'
local IsEnemyInRange = require 'AI_sakray.USER_AI.BehaviorTree.Conditions.IsEnemyInRange'

local root = CompositeNode:new({
    IsEnemyInRange,
    MoveTo
})

return {
    root = root
}