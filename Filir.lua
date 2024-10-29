--- mainskill is the best value skill and level
--- when sp is not enough it must be only
--- the crazy skiller should always call skill_attack
local skill_main = {
    id = HFLI_FLEET,
    level = 1,
    lastTick = 0,
    duration = 1000 * 3,
    
}

function mainskill_reset() 
    skill_main.lastTick = GetTick()
end 

--- @param creep Creep
local function try_use_skill(creep)
    local tick = GetTick()
    if tick > (skill_main.lastTick + skill_main.duration) then
        if ERR_NOT_IN_RANGE == Apis.skill_attack(creep, creep.target, skill_main.id, skill_main.level) then
            Apis.moveTo(creep, creep.target)
        else 
            -- memo tick
            skill_main.lastTick = tick
        end
    end
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
        if creep.hyper_follow ~= nil and (GetTick() > (creep.status_start_tick + creep.hyper_follow.delay)) then
            creep.hyper_follow.id = creep.owner_id
        end

        -- do nothing
        if creep.hyper_follow ~= nil and creep.hyper_follow.id ~= nil then
            Hyper_follow(creep)
        end
    end,
    ---@param creep Creep
    [States.BATTLE] = function(self, creep)
        local target = creep.target

        if target == nil then
            -- turn to pre-battle
            Apis.changeState(creep, States.FOLLOW)
        end

        -- normal attack
        local res = Apis.attack(creep, target)

        if res == ERR_INVALID_TARGET then
            -- turn to pre-battle
            creep.target = nil
            Apis.changeState(creep, States.FOLLOW)
        elseif res == ERR_NOT_IN_RANGE then
            Apis.moveTo(creep, target)
        end

        try_use_skill(creep)
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
        -- mainskill_reset()?
    end

    if creep.target ~= nil then
        Apis.changeState(creep,States.BATTLE)
    end

    handler[state](handler, creep)
end
