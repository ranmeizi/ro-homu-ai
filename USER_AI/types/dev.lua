---@alias NodeStates -1|1|0

---@class MoveToTask
---@field name 'MoveTo'
---@field pos_x number|nil  要么给 xy 要么给 target_id
---@field pos_y number|nil
---@field target_id number|nil

---@class KillTask Kill任务
---@field name 'Kill'
---@field target_id number 要杀的目标
---@field mode nil | 'default' | 'fullpower' | 'skillonly' 默认default
---@field _skillOnWay nil | true  在路上杀的标识
---@field _hasFirstAttack nil | true 是不是打了第一下

---@class StopTask 保持在屏幕里
---@field name 'Stop'

---@class FarmTask 练级
---@field name 'Farm'

---@class UseSkillTask 放技能
---@field name 'UseSkill'
---@field level number 技能等级
---@field type number 技能编号
---@field target_id number 目标ID

---@class TryJumpTaskOptions
---@field removeUniqueTask boolean 默认nil 开启删除队列里这个name的task

---@class AbstractTimer 计时器
---@field startTime number 开始时间
---@field timeout number   延迟时间
