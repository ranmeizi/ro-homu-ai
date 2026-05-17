--[[
    1. 检查主人身边的敌人，如果在 13 范围内
    2. 并且周围的海葵(1579) 小于 1 个
    3. 调用 socket 发送种海葵指令
]]

local socket = require("AI_sakray/USER_AI/ahk_util/socket")

TraceAI("[ahk_util.detection] 模块已加载")

local M = {
    enemy_range = 13,
    anemone_range = 13,
    anemone_type = 1579,
    plant_cooldown_ms = 8000,
    debug_interval_ms = 3000,
}

local _last_plant_tick = 0
local _last_debug_tick = 0
local _diagnosed = false

function M.debug_status()
    local now = GetTick()
    if now - _last_debug_tick < M.debug_interval_ms then
        return
    end
    _last_debug_tick = now
    local enemies = M.count_enemies_near_owner(M.enemy_range)
    local anemones = M.count_anemones_near_owner(M.anemone_range)
    local should = enemies > 0 and anemones < 1
    local reason = "ready"
    if enemies <= 0 then
        reason = "skip:no_enemy"
    elseif anemones >= 1 then
        reason = "skip:has_anemone"
    end
    TraceAI(string.format(
        "[ahk_util.detection] enemies=%d anemones=%d should_plant=%s reason=%s owner_id=%s",
        enemies, anemones, tostring(should), reason, tostring(Blackboard and Blackboard.owner_id)
    ))
end

---联调：无视条件强制发指令 1（测 Lua→AHK 时临时调用）
---@return boolean ok
---@return string resp
function M.test_send()
    TraceAI("[ahk_util.detection] test_send 强制发送")
    return socket.plant_anemone()
end

---统计主人周围敌人数量
---@param range number|nil
---@return number
function M.count_enemies_near_owner(range)
    range = range or M.enemy_range
    local owner_id = Blackboard and Blackboard.owner_id
    if not owner_id then
        return 0
    end

    local count = 0

    if Blackboard.objects and Blackboard.objects.monsters then
        for _, monster in pairs(Blackboard.objects.monsters) do
            if monster.distance_owner and monster.distance_owner <= range then
                count = count + 1
            end
        end
        return count
    end

    for _, id in ipairs(GetActors()) do
        if IsMonster(id) == 1 and GetDistance2(owner_id, id) <= range then
            count = count + 1
        end
    end
    return count
end

---统计主人周围海葵(1579)数量
---@param range number|nil
---@return number
function M.count_anemones_near_owner(range)
    range = range or M.anemone_range
    local owner_id = Blackboard and Blackboard.owner_id
    if not owner_id then
        return 0
    end

    local count = 0
    for _, id in ipairs(GetActors()) do
        if GetV(V_HOMUNTYPE, id) == M.anemone_type then
            if GetDistance2(owner_id, id) <= range then
                count = count + 1
            end
        end
    end
    return count
end

---是否满足种海葵条件
---@return boolean
function M.should_plant_anemone()
    local enemies = M.count_enemies_near_owner(M.enemy_range)
    local anemones = M.count_anemones_near_owner(M.anemone_range)
    return enemies > 0 and anemones < 1
end

---检测并发送种海葵指令（带冷却）
---@return boolean triggered 是否已发送
---@return string|nil reason
function M.check_and_plant()
    M.debug_status()

    if not _diagnosed then
        _diagnosed = true
        socket.diagnose()
    end

    if not M.should_plant_anemone() then
        return false, "condition_not_met"
    end

    local now = GetTick()
    if now - _last_plant_tick < M.plant_cooldown_ms then
        TraceAI("[ahk_util.detection] 冷却中 skip")
        return false, "cooldown"
    end

    TraceAI("[ahk_util.detection] 条件满足，发送种海葵指令")
    local ok, resp = socket.plant_anemone()
    if ok then
        _last_plant_tick = now
        TraceAI("[ahk_util.detection] plant_anemone OK: " .. tostring(resp))
        return true, resp
    end

    TraceAI("[ahk_util.detection] plant_anemone FAIL: " .. tostring(resp))
    return false, resp
end

return M
