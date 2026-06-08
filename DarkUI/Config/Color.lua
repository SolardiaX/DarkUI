local _, ns = ...
local E, C, L = ns:unpack()
local oUF = ns.oUF or oUF

----------------------------------------------------------------------------------------
-- oUF Colors
----------------------------------------------------------------------------------------

local health = oUF:CreateColor(0.15, 0.15, 0.15)
health:SetCurve({
    [0]   = CreateColor(255 / 255, 42 / 255, 12 / 255, 1),
    [0.5] = CreateColor(231 / 255, 48 / 255, 78 / 255, 1),
    [1]   = CreateColor(0.15, 0.15, 0.15, 1),
})

C.oUF_colors = setmetatable({
    health = health,
    tapped = oUF:CreateColor(0.6, 0.6, 0.6),
    disconnected = oUF:CreateColor(0.84, 0.75, 0.65),
    power = setmetatable({
        ["MANA"] = oUF:CreateColor(0.31, 0.45, 0.63),
        ["RAGE"] = oUF:CreateColor(0.69, 0.31, 0.31),
        ["FOCUS"] = oUF:CreateColor(0.71, 0.43, 0.27),
        ["ENERGY"] = oUF:CreateColor(0.65, 0.63, 0.35),
        ["COMBO_POINTS"] = oUF:CreateColor(0.90, 0.45, 0.15),
        ["RUNES"] = oUF:CreateColor(0.55, 0.57, 0.61),
        ["RUNIC_POWER"] = oUF:CreateColor(0, 0.82, 1),
        ["SOUL_SHARDS"] = oUF:CreateColor(0.58, 0.51, 0.79),
        ["LUNAR_POWER"] = oUF:CreateColor(0.30, 0.52, 0.90),
        ["HOLY_POWER"] = oUF:CreateColor(0.95, 0.90, 0.60),
        ["MAELSTROM"] = oUF:CreateColor(0, 0.50, 1),
        ["CHI"] = oUF:CreateColor(0.71, 1, 0.92),
        ["INSANITY"] = oUF:CreateColor(0.40, 0, 0.80),
        ["ARCANE_CHARGES"] = oUF:CreateColor(0.10, 0.10, 0.98),
        ["FURY"] = oUF:CreateColor(0.85, 0.36, 0.21),
        ["PAIN"] = oUF:CreateColor(1, 0.61, 0),
        ["ESSENCE"] = oUF:CreateColor(0.39, 0.68, 0.81),
        ["POWER_TYPE_FEL_ENERGY"] = oUF:CreateColor(0.65, 0.63, 0.35),
        ["AMMOSLOT"] = oUF:CreateColor(0.8, 0.6, 0),
        ["FUEL"] = oUF:CreateColor(0, 0.55, 0.5),
    }, { __index = oUF.colors.power }),
    runes = setmetatable({
        [1] = oUF:CreateColor(0.69, 0.31, 0.31),
        [2] = oUF:CreateColor(0.33, 0.59, 0.33),
        [3] = oUF:CreateColor(0.31, 0.45, 0.63),
        [4] = oUF:CreateColor(0.84, 0.75, 0.65),
    }, { __index = oUF.colors.runes }),
    reaction = setmetatable({
        [1] = oUF:CreateColor(0.85, 0.27, 0.27), -- Hated
        [2] = oUF:CreateColor(0.85, 0.27, 0.27), -- Hostile
        [3] = oUF:CreateColor(0.85, 0.27, 0.27), -- Unfriendly
        [4] = oUF:CreateColor(0.85, 0.77, 0.36), -- Neutral
        [5] = oUF:CreateColor(0.33, 0.59, 0.33), -- Friendly
        [6] = oUF:CreateColor(0.33, 0.59, 0.33), -- Honored
        [7] = oUF:CreateColor(0.33, 0.59, 0.33), -- Revered
        [8] = oUF:CreateColor(0.33, 0.59, 0.33), -- Exalted
    }, { __index = oUF.colors.reaction }),
}, { __index = oUF.colors })
