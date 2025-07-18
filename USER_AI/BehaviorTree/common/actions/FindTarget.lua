--- @param id number
local function checkBlackList(id)
    local val = Blackboard.black_list_cache:get(id)
    TraceAI('DINF LOG' .. json.encode(val))
    return val ~= nil
end

local function clearBlackListInterval()
    if PerXSecond(60 * 10) then
        Blackboard.black_list_cache:clearExpired()
    end
end

--[[
    应该是探测不到客户端的 hp sp
    选最近的把
    或是自己记录一个权重

    找到   SUCCESS
    未找到 FAILURE

    我觉得应该记录一个战斗日志
    对于未知敌人，失败无所谓，最重要是需要在失败中吸取教训。

    1. 主人的目标，是第一优先级，因为主人目标是人工选的
    2.
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

-- 从 monster 里找最优的怪 (由于信息太少，先找最近的)
local function findBestTargetInMonsters()
    local target = nil
    for id, monster in pairs(Blackboard.objects.monsters) do
        -- 先要考虑，是否是屏幕内的 即与主人相距<=15
        if monster.distance_owner <= 15 then
            -- 忽略黑名单里的怪
            if checkBlackList(monster) == false then
                if target == nil then
                    target = monster
                else
                    if monster.distance < target.distance then
                        target = monster
                    end
                end
            end
        end
    end



    return target and target.id or nil
end


-- 从 仇恨列表中找最近的怪
local function findNearestInAggroList(list)
    local item = nil

    for index, value in ipairs(list) do
        if item == nil then
            item = value
        else
            if value.distance == 1 then
                return value.id
            elseif value.distance < item.distance then
                item = value
            end
        end
    end

    return item and item.id or nil
end

--[[
    疯狗型
    1. 主人的目标，是第一优先级，因为主人目标是人工选的
    2. 去找自己周围最指的打的
]]
local function madDogFindTarget()
    -- 1. 第一目标是主人打的
    if Blackboard.objects.owner.target ~= nil then
        return Blackboard.objects.owner.target
    end

    -- 2. monster 里找
    return findBestTargetInMonsters()
end

--[[
    忠犬型
    1. 主人的目标
    2. 攻击自己的目标
    3. 攻击主人的目标
]]
local function loyalDogFindTarget()
    -- 1. 第一目标是主人打的
    -- if Blackboard.objects.owner.target ~= nil then
    --     return Blackboard.objects.owner.target
    -- end

    -- 2. 攻击自己的怪
    local res = findNearestInAggroList(Blackboard.objects.aggroListHomu)

    if res ~= nil then
        return res
    end

    -- 3. 攻击主人的目标
    res = findNearestInAggroList(Blackboard.objects.hateListOwner)

    if res ~= nil then
        return res
    end
end

--[[
    死狗型
    完全不打人
]]
local function deadDogFindTarget()

end

return {
    madDogFindTarget = madDogFindTarget,
    loyalDogFindTarget = loyalDogFindTarget,
    clearBlackListInterval = clearBlackListInterval
}
