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

---------------------porings-------------------------

local poring_map                  = {
    [1002] = { name = '波利', value = 2 },
    [1113] = { name = '土波利', value = 4 },
    [1031] = { name = '波波利', value = 8 },
    [1242] = { name = '冰波利', value = 16 },
    [1613] = { name = '金属波利', value = 32 },
    [1784] = { name = '石头波利', value = 64 },
    [1836] = { name = '熔岩波利', value = 128 },
    [1894] = { name = '雨水波利', value = 256 },
    [1904] = { name = '炸弹波利', value = 512 },
    [1582] = { name = '恶魔波利', value = 1024 },
    [1096] = { name = '天使波利', value = 2048 }
}

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

--
function IsKeyInTable(table, key)
    for k, v in pairs(table) do
        if k == key then
            return true
        end
    end

    return false
end

local function saveGridToCsv(grid)
    local csv = ""
    for _, row in ipairs(grid) do
        local rowCSV = ""
        for _, value in ipairs(row) do
            -- 将值转换为字符串，并确保数字被引号包围，以符合 CSV 格式
            rowCSV = rowCSV .. (rowCSV ~= "" and "," or "") .. tostring(value)
        end
        -- 将行 CSV 添加到总 CSV 中，并在每行后添加换行符
        csv = csv .. rowCSV .. "\n"
    end
    return csv
end

--找波利
local function poring_identify(type)
    if (IsKeyInTable(poring_map, type)) then
        TraceAI('Hi,I find a poring named' .. poring_identify[type].name)
        return poring_identify[type].value
    end

    return nil
end

--[[
    检查是否进入 2048 的站位
    你需要将人物和生命体像这样站位
      ☻   上
    ┏━━━━━━━━━━┓
    ┃          ┃
  左┃          ┃ 右
    ┃          ┃
    ┃          ┃
    ┗━━━━━━━━━━┛
      ☺   下

    ☻= 生命体
    ☺= 人物

    homu x = 231  homu y = 171
    ownerx = 231  ownery = 164
--]]
function CheckIfOn2048Seat(myid)
    MyDestX, MyDestY = GetV(V_POSITION, GetV(V_OWNER, myid))
    HDestX, HDestY = GetV(V_POSITION, myid)

    if MyDestX == 231 and MyDestY == 164 and HDestX == 231 and HDestY == 171 then
        return true
    end

    return false
end

-- 从游戏坐标系转换数组index
local function transPosToArrayIndex(x, y)
    -- 原点x坐标
    local o_x = 231
    -- 原点y坐标
    local o_y = 166

    local row = 4 - y + o_y
    local col = 4 - x + o_x

    return row, col
end

-- 检查波利,写入文件
local function identify(myid)
    local grid = {
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 },
        { 0, 0, 0, 0 }
    }

    for i, id in ipairs(GetActors()) do
        local type = GetV(V_HOMUNTYPE, id)
        local value = poring_identify(type)

        -- 是棋子种类
        if (value ~= nil) then
            -- 判断 x y 坐标
            local x, y = GetV(V_POSITION, id)

            local row, col = transPosToArrayIndex(x, y)

            -- 这个坐标落在 grid 中
            if row > 0 and row < 5 and col > 0 and col < 5 then
                grid[row][col] = value
            end
        end
    end

    return grid
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

    -- 判断是否要进入 2048 状态
    if CheckIfOn2048Seat(MyID) then
        MyState = PUZZLE_ST
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
--[[
      ☻   上
    ┏━━━━━━━━━━┓
    ┃          ┃
  左┃          ┃ 右
    ┃          ┃
    ┃          ┃
    ┗━━━━━━━━━━┛
      ☺   下

    ☻= 生命体
    ☺= 人物

    homu x = 231  homu y = 171
    ownerx = 231  ownery = 164
--]]
function OnPUZZLE_ST()
    if (GetTick() % 10 == 0) then
        -- 10 tick 一次哦
        local grid = identify(MyID)

        -- 写入文件
        local content = saveGridToCsv(grid)

        local file, err = io.open("grid.csv", "w") -- "w" 模式表示写入，会覆盖文件内容
        if not file then
            error("无法打开文件: " .. err)
        end

        -- 将内容写入文件
        file:write(content)

        -- 关闭文件
        file:close()
    end
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

local function testPoringFn()
    local actors = GetActors()

    for i, id in ipairs(actors) do
        local type = GetV(V_HOMUNTYPE, id)
        local value = poring_identify(type)

        if (value ~= nil) then
            TraceAI('see my poring value:' .. value)
        end
    end
end

------------

function AI(myid)
    MyID = myid
    local msg = GetMsg(myid)     -- command
    local rmsg = GetResMsg(myid) -- reserved command

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

    -- if (GetTick() % 10 == 0) then
    --     -- 10 tick 一次哦
    --     testPoringFn()
    -- end


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
        OnPUZZLE_ST()
    end
end
