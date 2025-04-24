local FindBestTarget = require 'AI_sakray.USER_AI.BehaviorTree.common.actions.FindBestTarget'
local Sequence = require 'AI_sakray.USER_AI.BehaviorTree.Core.ControlNodes.Sequence'

local Farm = Sequence:new({
    FindBestTarget
})

return Farm