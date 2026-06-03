local E, C, L = select(2, ...):unpack()

local TIER = 8
local INSTANCE = 1180 -- 尼奥罗萨，觉醒之城
local BOSS

BOSS = 2368 -- 黑龙帝王拉希奥
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306015) -- 灼烧护甲
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306163, 6) -- 万物尽焚
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313959) -- 灼热气泡
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 314347) -- 毒扼
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309733) -- 疯狂燃烧
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307053) -- 岩浆池
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313250) -- 蠕行疯狂

BOSS = 2365 -- 玛乌特
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307399) -- 暗影之伤
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307806) -- 吞噬魔法
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307586) -- 噬魔深渊
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306301) -- 禁忌法力
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 314993, 6) -- 吸取精华
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315025) -- 远古诅咒

BOSS = 2369 -- 先知斯基特拉
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307785) -- 扭曲心智
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307784) -- 困惑心智
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 308059) -- 暗影震击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309652) -- 虚幻之蚀
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307950) -- 心智剥离
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313215) -- 颤涌镜像

BOSS = 2377 -- 黑暗审判官夏奈什
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 311551) -- 深渊打击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 312406) -- 虚空觉醒
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 314298) -- 末日迫近
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306311) -- 灵魂鞭笞
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 305575) -- 仪式领域
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 316211) -- 恐惧浪潮

BOSS = 2372 -- 主脑
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313461) -- 腐蚀
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315311) -- 毁灭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313672) -- 酸液池
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 314593) -- 麻痹毒液
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313460) -- 虚化
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310402) -- 吞食狂热

BOSS = 2367 -- 无厌者夏德哈
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307471) -- 碾压
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307472) -- 融解
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307358) -- 衰弱唾液
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306928) -- 幽影吐息
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 308177) -- 熵能聚合
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306930) -- 熵能暗息
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 314736) -- 毒泡流溢
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306929) -- 翻滚毒息
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 318078, 6) -- 锁定
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309704) -- 腐蚀涂层

BOSS = 2373 -- 德雷阿佳丝
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310246) -- 虚空之握
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310277) -- 动荡之种
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310309) -- 动荡易伤
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310358) -- 狂乱低语
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310361) -- 不羁狂乱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310406) -- 虚空闪耀
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 308377) -- 虚化脓液
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 317001) -- 暗影排异
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310552) -- 精神鞭笞
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310563) -- 背叛低语
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310567) -- 背叛者

BOSS = 2374 -- 伊格诺斯，重生之蚀
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309961) -- 恩佐斯之眼
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 311367) -- 腐蚀者之触
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310322) -- 腐蚀沼泽
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 312486) -- 轮回噩梦
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 311159) -- 诅咒之血
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315094) -- 锁定
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313759) -- 诅咒之血

BOSS = 2370 -- 维克修娜
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307359) -- 绝望
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307020) -- 暮光之息
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307019) -- 虚空腐蚀
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306981) -- 虚空之赐
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310224, 6) -- 毁灭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307314) -- 渗透暗影
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307343) -- 暗影残渣
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307250) -- 暮光屠戮
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315769) -- 屠戮
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307284) -- 恐怖降临
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307645) -- 黑暗之心
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310323) -- 荒芜
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315932) -- 蛮力重击

BOSS = 2364 -- 虚无者莱登
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306819) -- 虚化重击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306279) -- 动荡暴露
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306273) -- 不稳定的生命
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306637) -- 不稳定的虚空爆发
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309777) -- 虚空污秽
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313227) -- 腐坏伤口
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310019, 6) -- 充能锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310022, 6) -- 充能锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315252) -- 恐怖炼狱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 316065) -- 腐化存续

BOSS = 2366 -- 恩佐斯的外壳
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307832) -- 恩佐斯的仆从
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313334) -- 恩佐斯之赐
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306973) -- 疯狂炸弹
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 306984) -- 狂乱炸弹
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313364) -- 精神腐烂
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315954) -- 漆黑伤疤
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307044) -- 梦魇抗原
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 307011) -- 疯狂繁衍

BOSS = 2375 -- 腐蚀者恩佐斯
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 314889) -- 探视心智
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315624) -- 心智受限
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309991) -- 痛楚
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313609) -- 恩佐斯之赐
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 308996) -- 恩佐斯的仆从
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 316711) -- 意志摧毁
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313400) -- 堕落心灵
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 316542, 6) -- 妄念
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 316541, 6) -- 妄念
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310042) -- 混乱爆发
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313793) -- 狂乱之火
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313610) -- 精神腐烂
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 309698) -- 虚空鞭笞
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 311392) -- 心灵之握
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310073) -- 心灵之握
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 313184) -- 突触震击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310331) -- 虚空凝视
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 312155) -- 碎裂自我
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315675) -- 碎裂自我
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315672) -- 碎裂自我
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 310134) -- 疯狂聚现
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 312866) -- 灾变烈焰
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 315772) -- 心灵之握
