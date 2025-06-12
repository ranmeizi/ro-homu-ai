local HpSpRecorder = {}
HpSpRecorder.__index = HpSpRecorder

--- 构造函数
--- @param max_samples number 最大样本容量（可选，默认120）
--- @param threshold number 接近HP/MAX的阈值（可选，默认200s）
function HpSpRecorder.new(max_samples, threshold)
    return setmetatable({
        samples = {},
        max_samples = max_samples or 120,
        threshold = threshold or 200,
    }, HpSpRecorder)
end

--- 记录当前状态（由外部控制调用间隔）
--- @param hp number 当前HP
--- @param hp_max number HP最大值
--- @param sp number 当前SP
--- @param sp_max number SP最大值
function HpSpRecorder:record(hp, hp_max, sp, sp_max)
    -- 如果HP或SP接近上限，跳过记录
    if hp >= hp_max - self.threshold or sp >= sp_max - self.threshold then
        return
    end

    -- 记录样本（时间戳由外部传入或使用系统时间）
    table.insert(self.samples, {
        timestamp = os.time(),  -- 或用 GetTick() 如果需更高精度
        hp = hp,
        sp = sp,
        -- 可选：记录最大值用于后续分析
        hp_max = hp_max,
        sp_max = sp_max,
    })

    -- 移除旧样本，保持固定长度
    while #self.samples > self.max_samples do
        table.remove(self.samples, 1)
    end
end

-- 计算两个样本间的真实时间差(毫秒)
local function get_time_diff(samples, i, j)
    return samples[j].timestamp - samples[i].timestamp
end

-- 改进后的分析方法
function HpSpRecorder:analyze()
    -- 临时存储有效样本
    local valid_samples = {}
    
    -- 过滤掉接近上限的样本
    for _, sample in ipairs(self.samples) do
        local hp_threshold = sample.hp_max - 200
        local sp_threshold = sample.sp_max - 200
        
        if sample.hp < hp_threshold and sample.sp < sp_threshold then
            table.insert(valid_samples, sample)
        end
    end
    
    -- 如果有效样本不足，直接返回 nil
    if #valid_samples < 2 then return nil end

    local results = {
        hp = {
            regen = { total = 0, count = 0 },  -- 自然恢复
            potion = { total = 0, count = 0 }, -- 药水/技能恢复
            damage = { total = 0, count = 0 }, -- 受到伤害
        },
        sp = {
            regen = { total = 0, count = 0 },   -- 自然恢复
            potion = { total = 0, count = 0 },  -- 药水/技能恢复
            consume = { total = 0, count = 0 }, -- 消耗（技能、buff等）
        },
        intervals = {}                          -- 记录实际时间间隔（秒）
    }

    -- 计算所有有效间隔
    for i = 2, #self.samples do
        local interval = get_time_diff(self.samples, i - 1, i) / 1000 -- 转为秒
        table.insert(results.intervals, interval)
    end

    -- 计算 HP 和 SP 的变化
    for i = 2, #self.samples do
        local prev = self.samples[i - 1]
        local curr = self.samples[i]
        local time_diff = get_time_diff(self.samples, i - 1, i) / 1000 -- 秒

        -- HP 变化分析
        local hp_diff = curr.hp - prev.hp
        if hp_diff > 0 then
            if hp_diff / time_diff < 50 then -- 自然恢复（速率 < 50 HP/秒）
                results.hp.regen.total = results.hp.regen.total + hp_diff
                results.hp.regen.count = results.hp.regen.count + 1
            else -- 药水或技能恢复（单次恢复 ≥ 50 HP）
                results.hp.potion.total = results.hp.potion.total + hp_diff
                results.hp.potion.count = results.hp.potion.count + 1
            end
        elseif hp_diff < 0 then -- 受到伤害
            results.hp.damage.total = results.hp.damage.total - hp_diff
            results.hp.damage.count = results.hp.damage.count + 1
        end

        -- SP 变化分析（逻辑类似 HP）
        local sp_diff = curr.sp - prev.sp
        if sp_diff > 0 then
            if sp_diff / time_diff < 30 then -- 自然恢复（速率 < 30 SP/秒）
                results.sp.regen.total = results.sp.regen.total + sp_diff
                results.sp.regen.count = results.sp.regen.count + 1
            else -- 药水或技能恢复（单次恢复 ≥ 30 SP）
                results.sp.potion.total = results.sp.potion.total + sp_diff
                results.sp.potion.count = results.sp.potion.count + 1
            end
        elseif sp_diff < 0 then -- SP 消耗（技能、buff 等）
            results.sp.consume.total = results.sp.consume.total - sp_diff
            results.sp.consume.count = results.sp.consume.count + 1
        end
    end

    -- 计算平均恢复/消耗速率（每秒）
    local total_seconds = get_time_diff(self.samples, 1, #self.samples) / 1000 -- 总秒数

    -- 安全计算平均值（防止除零或样本不足）
    results.hp.avg_regen = (total_seconds > 0 and #self.samples >= 2)
        and (results.hp.regen.total / total_seconds)
        or 0 -- 默认值

    results.sp.avg_regen = (total_seconds > 0 and #self.samples >= 2)
        and (results.sp.regen.total / total_seconds)
        or 0

    return results
end

return HpSpRecorder
