local skills={
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

local handler = {
    ---@param creep Creep
    [States.FOLLOW] = function(creep)
        -- get distance
        local distance = GetDistanceFromOwner(creep.id)

        -- keep distance from owner till state change
        if distance > 3 then 
            MoveToOwner(creep.id)
        end

        -- do nothing

    end,
    ---@param creep Creep
    [States.PRE_BATTLE] = function(creep)
        if creep.target==nil then
           
        else 
           -- turn to battle
           creep.state=States.BATTLE
        end
    end,
    ---@param creep Creep
    [States.BATTLE] = function(creep)

    end,
    ---@param creep Creep
    [States.BACK] = function(creep)
        
    end
}

---@param creep Creep
function Filir_run(creep)

    local state = creep.state

    handler[state](creep)

end

-- get filir`s skills
function Filir_get_skills()
    return skills
end
