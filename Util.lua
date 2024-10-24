require "AI\\Const"

--------------------------------------------
-- List utility
--------------------------------------------
List = {}

function List.new()
	return { first = 0, last = -1 }
end

function List.pushleft(list, value)
	local first = list.first - 1
	list.first  = first
	list[first] = value
end

function List.pushright(list, value)
	local last = list.last + 1
	list.last = last
	list[last] = value
end

function List.popleft(list)
	local first = list.first
	if first > list.last then
		return nil
	end
	local value = list[first]
	list[first] = nil -- to allow garbage collection
	list.first = first + 1
	return value
end

function List.popright(list)
	local last = list.last
	if list.first > last then
		return nil
	end
	local value = list[last]
	list[last] = nil
	list.last = last - 1
	return value
end

function List.clear(list)
	for i, v in ipairs(list) do
		list[i] = nil
	end
	--[[
	if List.size(list) == 0 then
		return
	end
	local first = list.first
	local last  = list.last
	for i=first, last do
		list[i] = nil
	end
--]]
	list.first = 0
	list.last = -1
end

function List.size(list)
	local size = list.last - list.first + 1
	return size
end

-------------------------------------------------







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
--- @param target_id number
function CheckTarget(creep, target_id)
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

Apis = {
	--- find closest enemy
	--- @param creep Creep
	findClosestEnemy = function(creep)
		local result = 0
		local actors = GetActors()
		local enemys = {}
		local index  = 1

		for i, v in ipairs(actors) do
			if (v ~= creep.owner_id and v ~= creep.id) then
				if (1 == IsMonster(v)) then
					enemys[index] = v
					index = index + 1
				end
			end
		end

		local min_dis = 100
		local dis
		for i, v in ipairs(enemys) do
			dis = GetDistance2(creep.id, v)
			if (dis < min_dis) then
				result = v
				min_dis = dis
			end
		end

		return result
	end,
	--- @param creep Creep
	getEnemy = function(creep)
		creep.target = Apis.findClosestEnemy(creep)
		return creep.target
	end,
	--- normal attack
	--- @param creep Creep
	--- @param target_id number
	attack = function(creep, target_id)
		-- check target
		if CheckTarget(creep, target_id) ~= OK then
			return ERR_INVALID_TARGET
		end

		-- check distance
		local x1, y1 = GetV(V_POSITION, creep.id)
		local x2, y2 = GetV(V_POSITION, target_id)
		if (x1 == -1 or x2 == -1) then
			-- I think cant be there ,it should be return last step
			return ERR_INVALID_TARGET
		end
		local d = GetDistance(x1, y1, x2, y2)
		local a = GetV(V_ATTACKRANGE, creep.id)

		if a < d then
			return ERR_NOT_IN_RANGE
		end

		-- attack

		Attack(creep.id, target_id)

		return OK
	end,
	--- skill attack
	--- @param creep Creep
	--- @param target_id number
	--- @param skill number
	--- @param level number
	skill_attack = function(creep, target_id, skill, level)
		-- check target
		if CheckTarget(creep, target_id) ~= OK then
			return ERR_INVALID_TARGET
		end

		-- check distance
		local x1, y1 = GetV(V_POSITION, creep.id)
		local x2, y2 = GetV(V_POSITION, target_id)
		if (x1 == -1 or x2 == -1) then
			-- I think cant be there ,it should be return last step
			return ERR_INVALID_TARGET
		end
		local d = GetDistance(x1, y1, x2, y2)
		local a = GetV(V_SKILLATTACKRANGE_LEVEL, creep.id, skill, level)

		if a < d then
			return ERR_NOT_IN_RANGE
		end

		-- skill_attack
		if (1 ~= SkillObject(creep.id, level, skill, target_id)) then
			-- maybe no sp?
			return ERR_UNKNOWN
		end

		return OK
	end,
	--- @param creep Creep
	--- @param target_id number
	moveTo = function(creep, target_id)
		-- check target
		if CheckTarget(creep, target_id) ~= OK then
			return ERR_INVALID_TARGET
		end

		-- moveto
		local x, y = GetV(V_POSITION, target_id)

		Move(creep.id, x, y)

		return OK
	end
}
