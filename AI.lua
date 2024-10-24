require "AI\\Const"
require "AI\\Util"
require "AI\\Filir"

FOLLOW_STICKY = 3000

States = {
    FOLLOW = 'follow',
    BATTLE = 'battle',
    BACK = 'back',
}

---@class Creep
---@field id number
---@field owner_id number|nil
---@field state string
---@field target number
---@field skills table|nil
local Creep = {
    id = 0,
    owner_id = nil,
    hp = 0,
    sp = 0,
    type = 0,
    state = States.PRE_BATTLE,
    -- motion target
    target = 0,
    -- skills
    skills = nil,
    -- frequency times attack use main attack skill
    frequency = 1
}

-- counter attack
SKILL_FREQ_LIST = List.new()

-- common command

local function cmd_get_skill()
    local type = GetV(V_HOMUNTYPE, Creep.id)

    if type == FILIR then
        Creep.skills = Filir_get_skills()
    end
end

--[[
    Boboan AI

    v0.0.0

    1. cut queue , command first  TODO
]] --
function AI(id)
    local type = GetV(V_HOMUNTYPE, id)

    Creep.id = id
    Creep.type = type
    Creep.hp = GetV(V_HP, id)
    Creep.sp = GetV(V_SP, id)

    -- if dont have skills , try call cmd_get_skill
    -- but when you change type , pleace use command
    if Creep.skills == nil then
        cmd_get_skill()
    end

    if Creep.owner_id == nil then
        Creep.owner_id = GetV(V_OWNER, id)
    end


    if type == FILIR then
        Filir_run(Creep)
    end
end
