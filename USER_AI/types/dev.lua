---@class MoveToTask
---@field name 'MoveTo'
---@field pos_x number|nil  要么给 xy 要么给 target_id
---@field pos_y number|nil
---@field target_id number|nil

---@class KillTask Kill任务类型
---@field name 'Kill'
---@field target_id number 要杀的目标
---@field mode nil | 'default' | 'fullpower' | 'skillonly' 默认default
