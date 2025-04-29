local function updateTargetInfoOnTable(table, id)
    table.hp = GetV(V_HP, id)
    table.hp_max = GetV(V_MAXHP, id)
    table.sp = GetV(V_SP, id)
    table.sp_max = GetV(V_MAXSP, id)
    table.pos = {}
    local x, y = GetV(V_POSITION, id)
    table.pos.x = x
    table.pos.y = y
    table.type = GetV(V_HOMUNTYPE, id)
    table.attack_range = GetV(V_ATTACKRANGE, id)
    table.motion = GetV(V_MOTION, id)
end

function Environment()
    TraceAI('Action Environment')

    -- 更新自身信息
    updateTargetInfoOnTable(Blackboard.objects.homu, Blackboard.id)
    -- 更新主人信息
    updateTargetInfoOnTable(Blackboard.objects.owner, Blackboard.owner_id)

    -- 获取所有敌人
    local actors = GetActors()

    Blackboard.objects.monsters = {} -- 刷新

    for index, value in ipairs(actors) do
        if IsMonster(value) == 1 then
            Blackboard.objects.monsters[value] = {}
            updateTargetInfoOnTable(Blackboard.objects.monsters[value], value)
            -- 是敌人的话多检测一下 target
            Blackboard.objects.monsters[value].target = GetV(V_TARGET, value)
        end
    end


    return NodeStates.SUCCESS
end

return Environment
