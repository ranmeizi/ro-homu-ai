local Node = require 'AI_sakray.USER_AI.BehaviorTree.Core.Node'

local IsEnemyInRange = Node:new()

function IsEnemyInRange:execute()
    print("Checking if enemy is in range...")
    return true -- 假设条件成立
end

return IsEnemyInRange