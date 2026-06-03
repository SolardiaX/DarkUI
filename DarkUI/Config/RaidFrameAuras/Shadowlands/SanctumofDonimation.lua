local E, C, L = select(2, ...):unpack()

local TIER = 9
local INSTANCE = 1193 -- 统御圣所
local BOSS

BOSS = 2435 -- 塔拉格鲁
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347283) -- 捕食者之嚎
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347286) -- 不散之惧
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 346986) -- 粉碎护甲
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347269, 6) -- 永恒锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 346985) -- 压制
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347274) -- 毁灭猛击

BOSS = 2442 -- 典狱长之眼
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350606) -- 绝望倦怠
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355240) -- 轻蔑
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355245) -- 忿怒
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 349979) -- 牵引锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348074) -- 痛击长枪
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351827) -- 蔓延痛苦
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350763) -- 毁灭凝视

BOSS = 2439 -- 九武神
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350287) -- 终约之歌
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350542) -- 命运残片
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350202) -- 无尽之击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350475) -- 灵魂穿透
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350555) -- 命运碎片
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350109) -- 布琳佳的悲恸挽歌
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350483) -- 联结精华
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350039) -- 阿尔苏拉的粉碎凝视
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350184) -- 达丝琪拉的威猛冲击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350374) -- 愤怒之翼

BOSS = 2444 -- 耐奥祖的残迹
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350073) -- 折磨
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 349890) -- 苦难
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350469) -- 怨毒
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 354634) -- 怨恨
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 354479) -- 怨恨
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 354534) -- 怨恨

BOSS = 2445 -- 裂魂者多尔玛赞
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 353429) -- 饱受磨难
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 353023) -- 折磨
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351787) -- 刑罚新星
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350647) -- 折磨烙印
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350422) -- 毁灭之刃
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350851) -- 聚魂之河
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 354231) -- 灵魂镣铐
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348987) -- 好战者枷锁
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350927) -- 好战者枷锁

BOSS = 2443 -- 痛楚工匠莱兹纳尔
--E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 356472) -- 萦绕烈焰
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355505) -- 影铸锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355506) -- 影铸锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348456) -- 烈焰套索陷阱
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 356870) -- 烈焰套索爆炸
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355568) -- 十字刃斧
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355786) -- 黑化护甲

BOSS = 2446 -- 初诞者的卫士
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 352394) -- 光辉能量
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350496) -- 净除威胁
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347359) -- 压制力场
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355357) -- 湮灭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350732) -- 破甲
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 352833) -- 分解

BOSS = 2447 -- 命运撰写师罗-卡洛
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 354365) -- 恐怖征兆
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350568) -- 永恒之唤
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 353435) -- 不堪重负
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351680) -- 祈求宿命
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 353432) -- 命运重担
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 353693) -- 不稳增幅
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 350355) -- 宿命联结
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 353931) -- 扭曲命运

BOSS = 2440 -- 克尔苏加德
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 346530) -- 冰封毁灭
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 354289) -- 险恶瘴气
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347454) -- 湮灭回响
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347518) -- 湮灭回响
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347292) -- 湮灭回响
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348978) -- 灵魂疲惫
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355389) -- 无情追击
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 357298) -- 冻结之缚
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 355137) -- 暗影之池
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348638) -- 亡者归来
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348760) -- 冰霜冲击

BOSS = 2441 -- 希尔瓦娜斯·风行者
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 349458) -- 统御锁链
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347704) -- 黑暗帷幕
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347607) -- 女妖的印记
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 347670) -- 暗影匕首
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351117) -- 恐惧压迫
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351870) -- 索命妖魂
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351253) -- 女妖哀嚎
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351451) -- 嗜睡诅咒
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351092) -- 动荡能量
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 351091) -- 动荡能量
E:RegisterRaidDebuff(TIER, INSTANCE, BOSS, 348064) -- 哀恸箭
