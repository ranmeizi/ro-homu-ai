require "AI_sakray\\USER_AI\\Const"
require "AI_sakray\\USER_AI\\Util"
require "AI_sakray\\USER_AI\\Filir"

---@class Creep
---@field id number
---@field owner_id number|nil
---@field state string
---@field target number|nil
---@field skills table|nil
local Creep = {
    id = 0,
    owner_id = nil,
    hp = 0,
    sp = 0,
    type = 0,
    state = States.PRE_BATTLE,
    -- motion target
    target = nil,
}

-- counter attack
SKILL_FREQ_LIST = List.new()

-- common command

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


    if Creep.owner_id == nil then
        Creep.owner_id = GetV(V_OWNER, id)
    end

    if type == FILIR then
        Filir_run(Creep)
    end
end
