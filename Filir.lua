--- mainskill is the best value skill and level
--- when sp is not enough it must be only
--- the crazy skiller should always call skill_attack
local mainSkill = HFLI_FLEET
local mainSkillLvl = 3
local freq = 3

--- @param creep Creep
--- @param target_id number|nil
local function hyperAttack(creep, target_id)
    return Apis.attack(creep, target_id)
end


local handler = {
    ---@param creep Creep
    [States.FOLLOW] = function(self, creep)
        -- get distance
        local distance = GetDistanceFromOwner(creep.id)

        -- keep distance from owner till state change
        if distance > 3 then
            MoveToOwner(creep.id)
            return
        end

        -- check need hyper_follow
        if creep.hyper_follow and GetTick() > creep.status_start_tick + creep.hyper_follow.delay then
            creep.hyper_follow.id = creep.owner_id
        end

        -- do nothing
    end,
    ---@param creep Creep
    [States.BATTLE] = function(self, creep)
        local target = creep.target

        if target == nil then
            -- turn to pre-battle
            Apis.changeState(creep, States.FOLLOW)
        end

        -- normal attack
        -- local res = Apis.attack(creep, target)
        -- use hyper attack
        local res = hyperAttack(creep, target)
        if res == ERR_INVALID_TARGET then
            -- turn to pre-battle
            creep.target = nil
            Apis.changeState(creep, States.FOLLOW)
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

    -- auto attack
    if creep.auto_attack == true and creep.target == nil then
        Apis.getEnemy(creep)
    end

    handler[state](handler, creep)
end
