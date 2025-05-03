--[[
    应该是探测不到客户端的 hp sp
    选最近的把
    或是自己记录一个权重

    找到   SUCCESS
    未找到 FAILURE

    我觉得应该记录一个战斗日志
    对于未知敌人，失败无所谓，最重要是需要在失败中吸取教训。
]]
local function findBestTarget()
    -- 寻找最优敌人
    -- print('Action FindBestTarget')

    Blackboard.objects.bestTarget = nil -- 重置

    for index, monster in ipairs(Blackboard.objects.monsters) do
        if Blackboard.objects.bestTarget == nil then
            Blackboard.objects.bestTarget = monster
        else
            if monster.distance < Blackboard.objects.bestTarget.distance then
                Blackboard.objects.bestTarget = monster
            end
        end
    end

    return Blackboard.objects.bestTarget
        and NodeStates.SUCCESS
        or NodeStates.FAILURE
end

return findBestTarget
