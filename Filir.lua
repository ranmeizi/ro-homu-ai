local skills = {
    {
        id = HFLI_FLEET,
        cooldown = 120000,
        lastSkillTime = 0,
    },
    {
        id = HFLI_SPEED,
        cooldown = 120000,
        lastSkillTime = 0,
    },
}

--- mainskill is the best value skill and level
--- when sp is not enough it must be only
--- the crazy skiller should always call skill_attack
local mainSkill = HFLI_FLEET
local mainSkillLvl = 1
local freq = 3

--- @param creep Creep
--- @param target_id number
local function hyperAttack(creep, target_id)
    local res = Apis.attack(creep, target_id)

    -- add
    if (res == OK) then
        List.pushright(SKILL_FREQ_LIST, 1)
    end

    -- check freq
    if List.size(SKILL_FREQ_LIST) >= freq then
        -- try use skill
        if ERR_NOT_IN_RANGE == Apis.skill_attack(creep, target_id, mainSkill, mainSkillLvl) then
            Apis.moveTo(creep, target_id)
        else
            List.clear(SKILL_FREQ_LIST)
        end
    end

    return res
end

local handler = {
    ---@param creep Creep
    [States.FOLLOW] = function(self, creep)
        -- get distance
        local distance = GetDistanceFromOwner(creep.id)

        -- keep distance from owner till state change
        if distance > 3 then
            MoveToOwner(creep.id)
        end

        -- do nothing
    end,
    ---@param creep Creep
    [States.PRE_BATTLE] = function(self, creep)
        local target = creep.target or Apis.getEnemy(creep)

        if target ~= 0 then
            -- turn to pre-battle
            creep.state = States.BATTLE
        end

        -- stay by owner
        self[States.FOLLOW](creep)
    end,
    ---@param creep Creep
    [States.BATTLE] = function(self, creep)
        local target = creep.target or Apis.getEnemy(creep)

        if target == 0 then
            -- turn to pre-battle
            creep.state = States.PRE_BATTLE
        end

        -- normal attack
        -- local res = Apis.attack(creep, target)
        -- use hyper attack
        local res = hyperAttack(creep, target)
        if res == ERR_INVALID_TARGET then
            -- turn to pre-battle
            creep.target = 0
            creep.state = States.PRE_BATTLE
        elseif res == ERR_NOT_IN_RANGE then
            Apis.moveTo(creep, target)
        end
    end,
    ---@param creep Creep
    [States.BACK] = function(self, creep)

    end
}

---@param creep Creep
function Filir_run(creep)
    local state = creep.state

    handler[state](handler, creep)
end

-- get filir`s skills
function Filir_get_skills()
    return skills
end
