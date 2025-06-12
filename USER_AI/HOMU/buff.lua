-- 普通
local filir_normal = {
    default = {
        {
            -- 等级
            level = 1,
            -- 技能id
            skill_id = HFLI_FLEET,
            -- sp 消耗
            sp_cost = 30,
            -- 使用间隔
            duration = 60 * 1000,
        },
        {
            -- 等级
            level = 1,
            -- 技能id
            skill_id = HFLI_SPEED,
            -- sp 消耗
            sp_cost = 30,
            -- 使用间隔
            duration = 60 * 1000,
        }
    },
    power_max = {
        {
            -- 等级
            level = 5,
            -- 技能id
            skill_id = HFLI_FLEET,
            -- sp 消耗
            sp_cost = 70,
            -- 使用间隔
            duration = 120 * 1000,
        },
        {
            -- 等级
            level = 5,
            -- 技能id
            skill_id = HFLI_SPEED,
            -- sp 消耗
            sp_cost = 70,
            -- 使用间隔
            duration = 120 * 1000,
        }
    }
}

-- 保持增益buff
local function keepBuff()

end
