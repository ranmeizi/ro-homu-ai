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
    -- 计算生命体与主人距离
    Blackboard.objects.homu.distance = GetDistance2(Blackboard.id, Blackboard.owner_id)

    -- 如果超过，那么 插队一个回到视野内的Task
    TraceAI('distance:'..Blackboard.objects.homu.distance)

    if Blackboard.objects.homu.distance > 13 then
        -- 把当前 task leftpush 到 task_queue
        local currTask = Blackboard.task

        if currTask ~= nil then
            Blackboard.task = nil
            List.pushleft(Blackboard.task_queue, currTask)
        end

        -- 创建一个 back to screen task
        Blackboard.task = {
            name = 'BackToScreen'
        }
    end

    -- 更新主人信息
    updateTargetInfoOnTable(Blackboard.objects.owner, Blackboard.owner_id)

    -- 获取所有敌人
    local actors = GetActors()

    Blackboard.objects.monsters = {} -- 刷新

    for index, value in ipairs(actors) do
        if IsMonster(value) == 1 then
            Blackboard.objects.monsters[value] = {}
            updateTargetInfoOnTable(Blackboard.objects.monsters[value], value)
            -- 是敌人的话多检测一下 target 计算一下 distance
            Blackboard.objects.monsters[value].target = GetV(V_TARGET, value)
            Blackboard.objects.monsters[value].distance = GetDistance2(Blackboard.id, value)
        end
    end


    return NodeStates.SUCCESS
end

return Environment
