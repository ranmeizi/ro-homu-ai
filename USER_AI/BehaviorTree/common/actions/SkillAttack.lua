--- SkillAttack 对敌人技能攻击
---@param target_id number
function SkillAttack(level, type, target_id)
    -- 判断攻击距离
    local attack_range = GetV(V_SKILLATTACKRANGE, Blackboard.id, type)

    local distance = Blackboard.objects.monsters[target_id].distance

    if distance > attack_range then
        return NodeStates.FAILURE
    end

    -- 这里有问题哦，需要自己实现技能CD的一套控制逻辑，也不难

    -- 放技能
    SkillObject(Blackboard.id, level, type, target_id)

    return NodeStates.SUCCESS
end

return SkillAttack