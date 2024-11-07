local E, C, L = select(2, ...):unpack()
local module = C.aura

-- 大米词缀及赛季相关
local SEASON_SPELLS = {
	--[209858] = 2, -- 死疽
	--[240443] = 2, -- 爆裂
	--[240559] = 1, -- 重伤
	--[408556] = 2, -- 缠绕
	--[342494] = 2, -- 狂妄吹嘘，S1
	--[355732] = 2, -- 融化灵魂，S2
	--[356666] = 2, -- 刺骨之寒，S2
	--[356667] = 2, -- 刺骨之寒，S2
	--[356925] = 2, -- 屠戮，S2
	--[358777] = 2, -- 痛苦之链，S2
	--[366288] = 2, -- 猛力砸击，S3
	--[366297] = 2, -- 解构，S3
	--[396364] = 2, -- 狂风标记，DF S1
	--[396369] = 2, -- 闪电标记，DF S1
	[440313] = 2, -- 虚空裂隙，TWW S1
}

function module:RegisterSeasonSpells(tier, instance)
	for spellID, priority in pairs(SEASON_SPELLS) do
		module:RegisterDebuff(tier, instance, 0, spellID, priority)
	end
end

-- 团队框体职业相关Buffs
local list = {
    ["ALL"]      = {                -- 全职业
        [642]    = true, -- 圣盾术
        [871]    = true, -- 盾墙
        [1022]   = true, -- 保护祝福
        [1044]   = true, -- 自由祝福
        [6940]   = true, -- 牺牲祝福
        [10060]  = true, -- 能量灌注
        [22812]  = true, -- 树皮术
        [61336]  = true, -- 生存本能
        [27827]  = true, -- 救赎之魂
        [31224]  = true, -- 暗影斗篷
        [33206]  = true, -- 痛苦压制
        [45438]  = true, -- 冰箱
        [47585]  = true, -- 消散
        [47788]  = true, -- 守护之魂
        [48792]  = true, -- 冰封之韧
        [86659]  = true, -- 远古列王守卫
        [102342] = true, -- 铁木树皮
        [102558] = true, -- 熊化身
        [104773] = true, -- 不灭决心
        [108271] = true, -- 星界转移
        [110909] = true, -- 操控时间
        [115203] = true, -- 壮胆酒
        [116849] = true, -- 作茧缚命
        [118038] = true, -- 剑在人在
        [160029] = true, -- 正在复活
        [186265] = true, -- 灵龟守护
        [196555] = true, -- 虚空行走
        [204018] = true, -- 破咒祝福
        [204150] = true, -- 圣光护盾
        [264735] = true, -- 优胜劣汰
        [281195] = true, -- 优胜劣汰
        [374348] = true, -- 新生光焰
        [363916] = true, -- 黑曜鳞片
    },
    ["WARNING"]  = {
        [87023]  = true, -- 灸灼
        [95809]  = true, -- 疯狂
        [123981] = true, -- 永劫不复
        [209261] = true, -- 未被污染的邪能
    },
}

module:AddClassSpells(list)

