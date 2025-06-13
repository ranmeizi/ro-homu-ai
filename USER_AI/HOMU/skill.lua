local skillbook = {
    -- 月光
    [HFLI_MOON] = {
        ['1'] = { sp_cost = 4, cd = 0, stay_duration = nil },
        ['2'] = { sp_cost = 8, cd = 0, stay_duration = nil },
        ['3'] = { sp_cost = 12, cd = 0, stay_duration = nil },
        ['4'] = { sp_cost = 16, cd = 0, stay_duration = nil },
        ['5'] = { sp_cost = 20, cd = 0, stay_duration = nil },
    },
    -- 闪避
    [HFLI_FLEET] = {
        ['1'] = { sp_cost = 30, cd = 60, stay_duration = 60 },
        ['2'] = { sp_cost = 40, cd = 70, stay_duration = 55 },
        ['3'] = { sp_cost = 50, cd = 80, stay_duration = 50 },
        ['4'] = { sp_cost = 60, cd = 90, stay_duration = 45 },
        ['5'] = { sp_cost = 70, cd = 120, stay_duration = 40 },
    },
    -- 加速
    [HFLI_SPEED] = {
        ['1'] = { sp_cost = 30, cd = 60, stay_duration = 60 },
        ['2'] = { sp_cost = 40, cd = 70, stay_duration = 55 },
        ['3'] = { sp_cost = 50, cd = 80, stay_duration = 50 },
        ['4'] = { sp_cost = 60, cd = 90, stay_duration = 45 },
        ['5'] = { sp_cost = 70, cd = 120, stay_duration = 40 },
    }
}

local filir_buff = { { 1, HFLI_FLEET }, { 1, HFLI_SPEED } }

local buff_conf = {
    [FILIR] = filir_buff
}

return {
    skillbook = skillbook,
    buff_conf = buff_conf
}
