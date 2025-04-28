local FindBestTarget = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.FindBestTarget'

local Farm = Sequence:new({
    FindBestTarget
})

return Farm