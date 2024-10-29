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
    state = States.FOLLOW,
    auto_attack = true,
    -- motion target
    target = nil,
    status_start_tick = 0,
    -- hyper follow TOP_LEFT -> TOP_RIGHT -> BOTTOM_RIGHT -> BOTTOM_RIGHT -> TOP_LEFT
    hyper_follow = {
        id = nil,
        delay = 500, -- if stay in FOLLOW over {delay} ms , call hyper_follow
        state = nil,
        distance = 1,
    }
}

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
