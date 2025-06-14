-- local json = require('AI_sakray.USER_AI.libs.dkjson')


------------------------------------

-------------------------------------------------
---util

function GetDistance(x1, y1, x2, y2)
	return math.floor(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))
end

function GetDistance2(id1, id2)
	local x1, y1 = GetV(V_POSITION, id1)
	local x2, y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return -1
	end
	return GetDistance(x1, y1, x2, y2)
end

function GetOwnerPosition(id)
	return GetV(V_POSITION, GetV(V_OWNER, id))
end

function GetDistanceFromOwner(id)
	local x1, y1 = GetOwnerPosition(id)
	local x2, y2 = GetV(V_POSITION, id)
	if (x1 == -1 or x2 == -1) then
		return -1
	end
	return GetDistance(x1, y1, x2, y2)
end

function IsOutOfSight(id1, id2)
	local x1, y1 = GetV(V_POSITION, id1)
	local x2, y2 = GetV(V_POSITION, id2)
	if (x1 == -1 or x2 == -1) then
		return true
	end
	local d = GetDistance(x1, y1, x2, y2)
	if d > 20 then
		return true
	else
		return false
	end
end

--- check is INVALID_TARGET
--- @param creep Creep
--- @param target_id number|nil
function CheckTarget(creep, target_id)
	-- is nil
	if target_id == nil then
		return ERR_INVALID_TARGET
	end

	-- is dead
	if (MOTION_DEAD == GetV(V_MOTION, target_id)) then -- ENEMY_DEAD_IN
		return ERR_INVALID_TARGET
	end

	-- in sight
	if (true == IsOutOfSight(creep.id, target_id)) then
		return ERR_INVALID_TARGET
	end

	return OK
end

local function util_posstr(pos)
	return pos.x .. "," .. pos.y
end

--- 查询位置
--- @param creep Creep
local function move_to_next(creep)
	local distance = creep.hyper_follow.distance

	local x1, y1 = GetV(V_POSITION, creep.id)
	local x2, y2 = GetV(V_POSITION, creep.hyper_follow.id)

	-- 计算 move 点的位置
	local pos_table = {
		[HF_TOP_LEFT] = { x = x2 - distance, y = y2 - distance },
		[HF_TOP_RIGHT] = { x = x2 + distance, y = y2 - distance },
		[HF_BOTTOM_RIGHT] = { x = x2 + distance, y = y2 + distance },
		[HF_BOTTOM_LEFT] = { x = x2 - distance, y = y2 + distance }
	}

	local pos_creep = { x = x1, y = y1 }

	-- 判断到点了吗？
	if util_posstr(pos_creep) == util_posstr(pos_table[HF_TOP_LEFT]) then
		creep.hyper_follow.state = HF_TOP_LEFT
	elseif util_posstr(pos_creep) == util_posstr(pos_table[HF_TOP_RIGHT]) then
		creep.hyper_follow.state = HF_TOP_RIGHT
	elseif util_posstr(pos_creep) == util_posstr(pos_table[HF_BOTTOM_RIGHT]) then
		creep.hyper_follow.state = HF_BOTTOM_RIGHT
	elseif util_posstr(pos_creep) == util_posstr(pos_table[HF_BOTTOM_LEFT]) then
		creep.hyper_follow.state = HF_BOTTOM_LEFT
	end

	local state = creep.hyper_follow.state


	local next = hf_next_table[state]
	local target_pos = pos_table[next]

	-- move
	Move(creep.id, target_pos['x'], target_pos['y'])
end



--- 超级跟随
--- @param creep Creep
function Hyper_follow(creep)
	TraceAI('hey hf')
	if creep.hyper_follow == nil then
		return -1
	end

	-- no follow target
	if creep.hyper_follow.id == nil then
		return ERR_INVALID_TARGET
	end

	move_to_next(creep)

	return OK
end

-- 插队
---comment
---@param task MoveToTask | KillTask | StopTask | FarmTask | UseSkillTask
---@param options TryJumpTaskOptions | nil
function TryJumpTask(task, options)
	-- 保存当前任务
	local currTask = Blackboard.task
	if currTask ~= nil then
		Blackboard.task = nil
		Blackboard.task_queue:unshift(currTask)
	end

	local removeUniqueTask = options == nil and nil or options.removeUniqueTask

	if removeUniqueTask == true then
		-- 删除 queue 里 名为 task.name 的任务
		Blackboard.task_queue = Blackboard.task_queue:filter(function(item)
			return item.name ~= task.name
		end)
	end

	Blackboard.task = task

	return NodeStates.SUCCESS
end

-- 是否经历了 X 秒
---@param sec number
function PerXSecond(sec)
	return GetTick() // 1000 % sec == 0
end
