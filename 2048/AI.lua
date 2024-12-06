--[[
    完全2048工具人，没有任何战斗代码
    你用完了记得切换回常规AI
]] --

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
--------------------------------
V_OWNER                           = 0  -- ������ ID			
V_POSITION                        = 1  -- ��ü�� ��ġ
V_TYPE                            = 2  -- �̱���
V_MOTION                          = 3  -- ����
V_ATTACKRANGE                     = 4  -- ���� ���� ����
V_TARGET                          = 5  -- ����, ��ų ��� ��ǥ�� ID
V_SKILLATTACKRANGE                = 6  -- ��ų ��� ����
V_HOMUNTYPE                       = 7  -- ȣ��Ŭ�罺 ����
V_HP                              = 8  -- HP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_SP                              = 9  -- SP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_MAXHP                           = 10 -- �ִ� HP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_MAXSP                           = 11 -- �ִ� SP (ȣ��Ŭ�罺�� ���ο��Ը� ����)
V_MERTYPE                         = 12 -- �뺴 ����	
V_POSITION_APPLY_SKILLATTACKRANGE = 13 -- SkillAttackange�� ������ ��ġ
V_SKILLATTACKRANGE_LEVEL          = 14 -- ���� �� SkillAttackange
---------------------------------	

IDLE_ST                           = 0
FOLLOW_ST                         = 1

MOVE_CMD_ST                       = 4
STOP_CMD_ST                       = 5

FOLLOW_CMD_ST                     = 12
PUZZLE_ST                         = 99 -- 兔美酱眼神开始犀利了起来，开始记录棋盘


------------------------------------------
-- global variable
------------------------------------------
MyState      = IDLE_ST    -- ������ ���´� �޽�
MyEnemy      = 0          -- �� id
MyDestX      = 0          -- ������ x
MyDestY      = 0          -- ������ y
MyPatrolX    = 0          -- ���� ������ x
MyPatrolY    = 0          -- ���� ������ y
ResCmdList   = List.new() -- ���� ���ɾ� ����Ʈ
MyID         = 0          -- ȣ��Ŭ�罺 id
MySkill      = 0          -- ȣ��Ŭ�罺�� ��ų
MySkillLevel = 0          -- ȣ��Ŭ�罺�� ��ų ����

Puzzle_x     = 0
Puzzle_y     = 0
------------------------------------------
-- util
function GetDistance(x1, y1, x2, y2)
    return math.floor(math.sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2))
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

------------------------------------------
---cmd

function OnMOVE_CMD(x, y)
    TraceAI("OnMOVE_CMD")

    if (x == MyDestX and y == MyDestY and MOTION_MOVE == GetV(V_MOTION, MyID)) then
        return -- ���� �̵����� �������� ���� ���̸� ó������ �ʴ´�.
    end

    local curX, curY = GetV(V_POSITION, MyID)
    if (math.abs(x - curX) + math.abs(y - curY) > 15) then -- �������� ���� �Ÿ� �̻��̸� (�������� �հŸ��� ó������ �ʱ� ������)
        List.pushleft(ResCmdList, { MOVE_CMD, x, y })      -- ���� ���������� �̵��� �����Ѵ�. 	
        x = math.floor((x + curX) / 2)                     -- �߰��������� ���� �̵��Ѵ�.
        y = math.floor((y + curY) / 2)                     --
    end

    Move(MyID, x, y)

    MyState = MOVE_CMD_ST
    MyDestX = x
    MyDestY = y
    MyEnemy = 0
    MySkill = 0
end

function OnSTOP_CMD()
    TraceAI("OnSTOP_CMD")

    if (GetV(V_MOTION, MyID) ~= MOTION_STAND) then
        Move(MyID, GetV(V_POSITION, MyID))
    end
    MyState = IDLE_ST
    MyDestX = 0
    MyDestY = 0
    MyEnemy = 0
    MySkill = 0
end

function OnFOLLOW_CMD()
    -- �������� �����¿� �޽Ļ��¸� ���� ��ȯ��Ų��.
    if (MyState ~= FOLLOW_CMD_ST) then
        MoveToOwner(MyID)
        MyState = FOLLOW_CMD_ST
        MyDestX, MyDestY = GetV(V_POSITION, GetV(V_OWNER, MyID))
        MyEnemy = 0
        MySkill = 0
        TraceAI("OnFOLLOW_CMD")
    else
        MyState = IDLE_ST
        MyEnemy = 0
        MySkill = 0
        TraceAI("FOLLOW_CMD_ST --> IDLE_ST")
    end
end

function ProcessCommand(msg)
    if (msg[1] == MOVE_CMD) then
        OnMOVE_CMD(msg[2], msg[3])
        TraceAI("MOVE_CMD")
    elseif (msg[1] == STOP_CMD) then
        OnSTOP_CMD()
        TraceAI("STOP_CMD")
    elseif (msg[1] == FOLLOW_CMD) then
        OnFOLLOW_CMD()
        TraceAI("FOLLOW_CMD")
    end
end

-------------------------------------------
---state

function OnIDLE_ST()
    TraceAI("OnIDLE_ST")

    local cmd = List.popleft(ResCmdList)
    if (cmd ~= nil) then
        ProcessCommand(cmd) -- ���� ���ɾ� ó��
        return
    end

    local distance = GetDistanceFromOwner(MyID)
    if (distance > 3 or distance == -1) then -- MYOWNER_OUTSIGNT_IN
        MyState = FOLLOW_ST
        TraceAI("IDLE_ST -> FOLLOW_ST")
        return;
    end
end

function OnFOLLOW_ST()
    TraceAI("OnFOLLOW_ST")

    if (GetDistanceFromOwner(MyID) <= 3) then --  DESTINATION_ARRIVED_IN
        MyState = IDLE_ST
        TraceAI("FOLLOW_ST -> IDLW_ST")
        return;
    elseif (GetV(V_MOTION, MyID) == MOTION_STAND) then
        MoveToOwner(MyID)
        TraceAI("FOLLOW_ST -> FOLLOW_ST")
        return;
    end
end

function OnMOVE_CMD_ST()
    TraceAI("OnMOVE_CMD_ST")

    local x, y = GetV(V_POSITION, MyID)
    if (x == MyDestX and y == MyDestY) then -- DESTINATION_ARRIVED_IN
        MyState = IDLE_ST
    end
end

function OnSTOP_CMD_ST()

end

function OnFOLLOW_CMD_ST()
    TraceAI("OnFOLLOW_CMD_ST")

    local ownerX, ownerY, myX, myY
    ownerX, ownerY = GetV(V_POSITION, GetV(V_OWNER, MyID)) -- ����
    myX, myY = GetV(V_POSITION, MyID)                      -- ��

    local d = GetDistance(ownerX, ownerY, myX, myY)

    if (d <= 3) then -- 3�� ���� �Ÿ���
        return
    end

    local motion = GetV(V_MOTION, MyID)
    if (motion == MOTION_MOVE) then -- �̵���
        d = GetDistance(ownerX, ownerY, MyDestX, MyDestY)
        if (d > 3) then             -- ������ ���� ?
            MoveToOwner(MyID)
            MyDestX = ownerX
            MyDestY = ownerY
            return
        end
    else -- �ٸ� ����
        MoveToOwner(MyID)
        MyDestX = ownerX
        MyDestY = ownerY
        return
    end
end

-- 一旦进入这个状态，没办法自己结束，需要移动一下
function OnPUZZLE_ST()

end

------------

local function testPosFn(myid)
    MyDestX, MyDestY = GetV(V_POSITION, GetV(V_OWNER, myid))
    HDestX, HDestY = GetV(V_POSITION, myid)

    --- 生命体探位吧
    TraceAI('homo x:' .. HDestX .. 'homo y:' .. HDestY)
    TraceAI('owner x:' .. MyDestX .. 'owner y:' .. MyDestY)
end

local function testFsFn()
    -- 写入文件
    -- 要写入的内容
    local content = "Hello, World!\nThis is a test."

    -- 打开文件用于写入，如果文件不存在则创建
    local file, err = io.open("example.txt", "w") -- "w" 模式表示写入，会覆盖文件内容
    if not file then
        error("无法打开文件: " .. err)
    end

    -- 将内容写入文件
    file:write(content)

    -- 关闭文件
    file:close()
end

------------

function AI(myid)
    MyID = myid
    local msg = GetMsg(myid)     -- command
    local rmsg = GetResMsg(myid) -- reserved command

    testPosFn(myid)
    testFsFn()
    if msg[1] == NONE_CMD then
        if rmsg[1] ~= NONE_CMD then
            if List.size(ResCmdList) < 10 then
                List.pushright(ResCmdList, rmsg) -- ���� ���� ����
            end
        end
    else
        List.clear(ResCmdList) -- ���ο� ������ �ԷµǸ� ���� ���ɵ��� �����Ѵ�.
        ProcessCommand(msg)    -- ���ɾ� ó��
    end

    -- ���� ó��
    if (MyState == IDLE_ST) then
        OnIDLE_ST()
    elseif (MyState == FOLLOW_ST) then
        OnFOLLOW_ST()
    elseif (MyState == MOVE_CMD_ST) then
        OnMOVE_CMD_ST()
    elseif (MyState == STOP_CMD_ST) then
        OnSTOP_CMD_ST()
    elseif (MyState == FOLLOW_CMD_ST) then
        OnFOLLOW_CMD_ST()
    elseif (MyState == PUZZLE_ST) then

    end
end
