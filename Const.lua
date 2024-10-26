--  c function

--[[
function	TraceAI (string) end
function	MoveToOwner (id) end
function 	Move (id,x,y) end
function	Attack (id,id) end
function 	GetV (V_,id) end
function	GetActors () end
function	GetTick () end
function	GetMsg (id) end
function	GetResMsg (id) end
function	SkillObject (id,level,skill,target) end
function	SkillGround (id,level,skill,x,y) end
function	IsMonster (id) end								-- id�� �����ΰ�? yes -> 1 no -> 0

--]]





-------------------------------------------------
-- constants
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





--------------------------------------------
-- ȣ��Ŭ�罺 ����
--------------------------------------------

LIF           = 1
AMISTR        = 2
FILIR         = 3
VANILMIRTH    = 4
LIF2          = 5
AMISTR2       = 6
FILIR2        = 7
VANILMIRTH2   = 8
LIF_H         = 9
AMISTR_H      = 10
FILIR_H       = 11
VANILMIRTH_H  = 12
LIF_H2        = 13
AMISTR_H2     = 14
FILIR_H2      = 15
VANILMIRTH_H2 = 16

--------------------------------------------



--------------------------------------------
-- �뺴 ����
--------------------------------------------
ARCHER01 = 1
ARCHER02 = 2
ARCHER03 = 3
ARCHER04 = 4
ARCHER05 = 5
ARCHER06 = 6
ARCHER07 = 7
ARCHER08 = 8
ARCHER09 = 9
ARCHER10 = 10
LANCER01 = 11
LANCER02 = 12
LANCER03 = 13
LANCER04 = 14
LANCER05 = 15
LANCER06 = 16
LANCER07 = 17
LANCER08 = 18
LANCER09 = 19
LANCER10 = 20
SWORDMAN01 = 21
SWORDMAN02 = 22
SWORDMAN03 = 23
SWORDMAN04 = 24
SWORDMAN05 = 25
SWORDMAN06 = 26
SWORDMAN07 = 27
SWORDMAN08 = 28
SWORDMAN09 = 29
SWORDMAN10 = 30
--------------------------------------------



--------------------------
MOTION_STAND   = 0
MOTION_MOVE    = 1
MOTION_ATTACK  = 2
MOTION_DEAD    = 3
MOTION_ATTACK2 = 9
--------------------------




--------------------------
-- command
--------------------------
NONE_CMD          = 0
MOVE_CMD          = 1
STOP_CMD          = 2
ATTACK_OBJECT_CMD = 3
ATTACK_AREA_CMD   = 4
PATROL_CMD        = 5
HOLD_CMD          = 6
SKILL_OBJECT_CMD  = 7
SKILL_AREA_CMD    = 8
FOLLOW_CMD        = 9
--------------------------



--[[ ���ɾ� ����

MOVE_CMD
	{���ɹ�ȣ,X��ǥ,Y��ǥ}
	
STOP_CMD
	{���ɹ�ȣ}

ATTACK_OBJECT_CMD
	{���ɹ�ȣ,��ǥID}

ATTACK_AREA_CMD	
	{���ɹ�ȣ,X��ǥ,Y��ǥ}

PATROL_CMD	
	{���ɹ�ȣ,X��ǥ,Y��ǥ}
	
HOLD_CMD
	{���ɹ�ȣ}

SKILL_OBJECT_CMD
	{���ɹ�ȣ,���÷���,����,��ǥID}

SKILL_AREA_CMD
	{���ɹ�ȣ,���÷���,����,X��ǥ,Y��ǥ}

FOLLOW_CMD
	{���ɹ�ȣ}

--]]

--------------------------
-- SUPPORT SKILLS
--------------------------
HLIF_HEAL = 8001
HLIF_AVOID = 8002
HLIF_CHANGE = 8004
HAMI_CASTLE = 8005
HAMI_DEFENCE = 8006
HAMI_BLOODLUST = 8008
HFLI_FLEET = 8010
HFLI_SPEED = 8011
HVAN_CHAOTIC = 8014
MH_GOLDENE_FERSE = 8032
MH_STEINWAND = 8033
MH_ANGRIFFS_MODUS = 8035
MH_GRANITIC_ARMOR = 8040
MH_MAGMA_FLOW = 8039
MH_OVERED_BOOST = 8023
MH_LIGHT_OF_REGENE = 8022
MH_SILENT_BREEZE = 8026
MH_PAIN_KILLER = 8021
--------------------------


--------------------------
---res code
--------------------------
OK = 0
ERR_NOT_FOUND = -5
ERR_INVALID_TARGET = -7
ERR_NOT_IN_RANGE = -9
ERR_UNKNOWN = -99
--------------------------



--------------------------
--- runtime 
FOLLOW_STICKY = 3000

States = {
    FOLLOW = 'follow',
	PRE_BATTLE = 'pre-battle',
    BATTLE = 'battle',
    BACK = 'back',
}
--------------------------