---@class MoveToTask
---@field name 'MoveTo'
---@field pos_x number|nil  要么给 xy 要么给 target_id
---@field pos_y number|nil
---@field target_id number|nil

---@class KillTask Kill任务
---@field name 'Kill'
---@field target_id number 要杀的目标
---@field mode nil | 'default' | 'fullpower' | 'skillonly' 默认default

---@class StopTask 保持在屏幕里
---@field name 'Stop'

---@class TryJumpTaskOptions
---@field removeUniqueTask boolean 默认nil 开启删除队列里这个name的task