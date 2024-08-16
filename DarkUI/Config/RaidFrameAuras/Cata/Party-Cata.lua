local E, C, L = select(2, ...):unpack()
local module = C.aura

local TIER = 4
local INSTANCE -- 5人本

INSTANCE = 68 -- 旋云之巅
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 65 -- 潮汐王座
module:RegisterSeasonSpells(TIER, INSTANCE)

INSTANCE = 71 -- 格瑞姆巴托
module:RegisterSeasonSpells(TIER, INSTANCE)