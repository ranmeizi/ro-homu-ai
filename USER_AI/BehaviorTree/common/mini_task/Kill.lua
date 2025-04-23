--[[
    Kill 杀死目标 [跨tick]

    需要按照当前目标和场景，决定击杀策略

    场景：
    
    1.Farm (condition是否处于farm)
    farm 时要尽可能快速击杀，并保持可持续输出，节省hp/sp，减少逃跑回血的时间

    2.FullPower (condition是否要启用 fullpower)
    [注意!] 这个就是想让目标死，不会逃跑的。
    全力击杀，使出自己dps最强的输出手段，再最短时间杀死目标。

    3.SkillOnly
    只使用技能输出

    行为:

    1. 靠近敌人

    2. 攻击敌人

    前置判断:

    1. 目标已死亡 ?
        目标死亡    返回 SUCCESS
        目标未死亡  返回 RUNNING

]]