local skillbook = require('USER_AI.HOMU.skill').skillbook

--- UseSkill 对敌人技能攻击
---@param target_id number
local function UseSkill(level, type, target_id)
    -- 判断攻击距离
    local attack_range = GetV(V_SKILLATTACKRANGE, Blackboard.id, type)

    local distance = Blackboard.objects.monsters[target_id].distance

    if distance > attack_range then
        return NodeStates.FAILURE
    end

    -- 查看cd cd中的技能不予响应
    if Blackboard.cooldown:get(type) ~= nil then
        return NodeStates.FAILURE
    end

    -- 记录cd
    local skill_info = skillbook[type]
    if skill_info ~= nil and skill_info.cd > 0 then
        Blackboard.cooldown:set(type, skill_info.cd * 1000)
    end


    -- 放技能
    SkillObject(Blackboard.id, level, type, target_id)

    return NodeStates.SUCCESS
end

return UseSkill
