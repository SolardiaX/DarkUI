local E, C, L = select(2, ...):unpack()
local module = C.aura

-- 角标的相关法术 [spellID] = {anchor, {r, g, b}}
module.cornerBuffs = {
    ["PRIEST"]      = {
        [194384] = { "TOPRIGHT", { 1, 1, .66 } }, -- 救赎
        [214206] = { "TOPRIGHT", { 1, 1, .66 } }, -- 救赎(PvP)
        [41635]  = { "BOTTOMRIGHT", { .2, .7, .2 } }, -- 愈合导言
        [193065] = { "BOTTOMRIGHT", { .54, .21, .78 } }, -- 忍辱负重
        [139]    = { "TOPLEFT", { .4, .7, .2 } }, -- 恢复
        [17]     = { "TOPLEFT", { .7, .7, .7 } }, -- 真言术盾
        [47788]  = { "LEFT", { .86, .45, 0 }, true }, -- 守护之魂
        [33206]  = { "LEFT", { .47, .35, .74 }, true }, -- 痛苦压制
        [6788]  = {"TOP", {.86, .11, .11}, true},		-- 虚弱灵魂
    },
    ["DRUID"]       = {
        [774]    = { "TOPRIGHT", { .8, .4, .8 } }, -- 回春
        [155777] = { "RIGHT", { .8, .4, .8 } }, -- 萌芽
        [8936]   = { "BOTTOMLEFT", { .2, .8, .2 } }, -- 愈合
        [33763]  = { "TOPLEFT", { .4, .8, .2 } }, -- 生命绽放
        [188550]  = {"TOPLEFT", {.4, .8, .2}},			-- 生命绽放，橙装
        [48438]  = { "BOTTOMRIGHT", { .8, .4, 0 } }, -- 野性成长
        [207386] = { "TOP", { .4, .2, .8 } }, -- 春暖花开
        [102351] = { "LEFT", { .2, .8, .8 } }, -- 结界
        [102352] = { "LEFT", { .2, .8, .8 } }, -- 结界(HoT)
        [200389] = { "BOTTOM", { 1, 1, .4 } }, -- 栽培
    },
    ["PALADIN"]     = {
        [287280]  = {"TOPLEFT", {1, .8, 0}},			-- 圣光闪烁
        [53563]  = { "TOPRIGHT", { .7, .3, .7 } }, -- 道标
        [156910] = { "TOPRIGHT", { .7, .3, .7 } }, -- 信仰道标
        [200025] = { "TOPRIGHT", { .7, .3, .7 } }, -- 美德道标
        [1022]   = { "BOTTOMRIGHT", { .2, .2, 1 }, true }, -- 保护
        [1044]   = { "BOTTOMRIGHT", { .89, .45, 0 }, true }, -- 自由
        [6940]   = { "BOTTOMRIGHT", { .89, .1, .1 }, true }, -- 牺牲
        [223306] = { "BOTTOMLEFT", { .7, .7, .3 } }, -- 赋予信仰
        [25771]  = {"TOP", {.86, .11, .11}, true},		-- 自律
    },
    ["SHAMAN"]      = {
        [61295]  = { "TOPRIGHT", { .2, .8, .8 } }, -- 激流
        [974]    = { "BOTTOMRIGHT", { 1, .8, 0 } }, -- 大地之盾
        [207400] = { "BOTTOMLEFT", { .6, .8, 1 } }, -- 先祖活力
    },
    ["MONK"]        = {
        [119611] = { "TOPLEFT", { .3, .8, .6 } }, -- 复苏之雾
        [116849] = { "TOPRIGHT", { .2, .8, .2 }, true }, -- 作茧缚命
        [124682] = { "BOTTOMLEFT", { .8, .8, .25 } }, -- 氤氲之雾
        [191840] = { "BOTTOMRIGHT", { .27, .62, .7 } }, -- 精华之泉
    },
    ["ROGUE"]       = {
        [57934] = { "BOTTOMRIGHT", { .9, .1, .1 } }, -- 嫁祸
    },
    ["WARRIOR"]     = {
        [114030] = { "TOPLEFT", { .2, .2, 1 } }, -- 警戒
    },
    ["HUNTER"]      = {
        [34477] = { "BOTTOMRIGHT", { .9, .1, .1 } }, -- 误导
        [90361] = { "TOPLEFT", { .4, .8, .2 } }, -- 灵魂治愈
    },
    ["WARLOCK"]     = {
        [20707]  = {"BOTTOMRIGHT", {.8, .4, .8}, true},	-- 灵魂石
    },
    ["DEMONHUNTER"] = {},
    ["MAGE"]        = {},
    ["DEATHKNIGHT"] = {},
}

-- 小队框体的技能监控CD [spellID] = duration in seconds
module.partySpells = {
    [57994]  = 12, -- 风剪
    [1766]   = 15, -- 脚踢
    [6552]   = 15, -- 拳击
    [47528]  = 15, -- 心灵冰冻
    [96231]  = 15, -- 责难
    [106839] = 15, -- 迎头痛击
    [116705] = 15, -- 切喉手
    [183752] = 15, -- 瓦解
    [187707] = 15, -- 压制
    [2139]   = 24, -- 法术反制
    [147362] = 24, -- 反制射击
    [15487]  = 45, -- 沉默
    [109248] = 45,	-- 束缚射击
    [78675]  = 60, -- 日光术

    [8143]   = 60, -- 战栗图腾
    [102793] = 60, -- 乌索尔旋风
    [119381] = 60, -- 扫堂腿
    [179057] = 60, -- 混乱新星
    [205636] = 60, -- 树人
    [102342] = 90,	-- 铁木树皮
    [31224]  = 120, -- 暗影斗篷
    [190319] = 120,	-- 燃烧
    [25046]  = 120, -- 奥术洪流
    [28730]  = 120,
    [50613]  = 120,
    [69179]  = 120,
    [80483]  = 120,
    [129597] = 120,
    [155145] = 120,
    [202719] = 120,
    [232633] = 120,
    [186265] = 180,	-- 灵龟守护
}

-- 天赋/特质影响下的冷却时间
module.talentCDFix = {
    [740]    = 120, -- 宁静
    [2094]   = 90, -- 致盲
    [15286]  = 75, -- 吸血鬼的拥抱
    [15487]  = 30, -- 沉默
    [22812]  = 40, -- 树皮术
    [30283]  = 30, -- 暗怒
    [48792]  = 165, -- 冰封之韧
    [79206]  = 60, -- 灵魂行者的恩赐
    [102342] = 45, -- 铁木树皮
    [108199] = 90, -- 血魔之握
    [109304] = 105, -- 意气风发
    [116849] = 100, -- 作茧缚命
    [119381] = 40, -- 扫堂腿
    [179057] = 40, -- 混乱新星
}

-- 团队框体职业相关Buffs
local list = {
    ["ALL"]         = {            -- 全职业
        [642]    = true, -- 圣盾术
        [871]    = true, -- 盾墙
        [1022]   = true, -- 保护祝福
        [27827]  = true, -- 救赎之魂
        [31224]  = true, -- 暗影斗篷
        [33206]  = true, -- 痛苦压制
        [45438]  = true, -- 冰箱
        [47585]  = true, -- 消散
        [47788]  = true, -- 守护之魂
        [48792]  = true, -- 冰封之韧
        [86659]  = true, -- 远古列王守卫
        [102342] = true, -- 铁木树皮
        [104773] = true, -- 不灭决心
        [108271] = true, -- 星界转移
        [115203] = true, -- 壮胆酒
        [116849] = true, -- 作茧缚命
        [118038] = true, -- 剑在人在
        [160029] = true, -- 正在复活
        [186265] = true, -- 灵龟守护
        [196555] = true, -- 虚空行走
        [204018] = true, -- 破咒祝福
        [204150] = true, -- 圣光护盾
        [264735] = true,	-- 优胜劣汰
    },
    ["WARNING"]     = {
        [87023]  = true, -- 灸灼
        [95809]  = true, -- 疯狂
        [123981] = true, -- 永劫不复
        [209261] = true, -- 未被污染的邪能
    },
}

module:AddClassSpells(list)