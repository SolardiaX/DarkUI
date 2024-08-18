local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--    Configuration of CombatText AoeSpam
----------------------------------------------------------------------------------------

local pairs, tinsert, unpack = pairs, tinsert, unpack

-- Position Configure
local PlayerAuraPoint = { "LEFT", UIParent, "CENTER", -400, -175 }
local EnchantAuraPoint = { "RIGHT", UIParent, "CENTER", -200, 40 }
local TargetAuraPoint = { "LEFT", UIParent, "CENTER", 200, -10 }
local SpecialAuraPoint = { "RIGHT", UIParent, "CENTER", -200, -10 }
local FocusAuraPoint = { "LEFT", UIParent, "CENTER", -450, 260 }
local CDPoint = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 5, 240 }
local WarningAuraPoint = { "LEFT", UIParent, "CENTER", 200, 40 }
local RaidDebuffPoint = { "LEFT", UIParent, "CENTER", 200, 100 }
local InternalPoint = { "BOTTOM", UIParent, "BOTTOM", -300, 180 }

local groups = {
    -- groups name = direction, interval, mode, iconsize, position, barwidth
    ["Player Aura"]    = { "LEFT", 5, "ICON", 22, PlayerAuraPoint },
    ["Target Aura"]    = { "RIGHT", 5, "ICON", 36, TargetAuraPoint },
    ["Special Aura"]   = { "LEFT", 5, "ICON", 36, SpecialAuraPoint },
    ["Focus Aura"]     = { "RIGHT", 5, "ICON", 35, FocusAuraPoint },
    ["Spell Cooldown"] = { "UP", 5, "BAR", 18, CDPoint, 200 },
    ["Enchant Aura"]   = { "LEFT", 5, "ICON", 36, EnchantAuraPoint },
    ["Raid Buff"]      = { "LEFT", 5, "ICON", 45, RaidDebuffPoint },
    ["Raid Debuff"]    = { "RIGHT", 5, "ICON", 45, RaidDebuffPoint },
    ["Warning"]        = { "RIGHT", 5, "ICON", 42, WarningAuraPoint },
    ["InternalCD"]     = { "UP", 5, "BAR", 18, InternalPoint, 200 },
}

-- AuraWatch
C.aura.auraWatch = {
    enable       = true,
    clickThrough = false,
    iconScale    = 1,
    quakeRing    = false,
}

-- RaidDebuffs
C.aura.raidDebuffs = {}

-- RaidDebuffs
C.aura.raidBuffs = {}

local function newAuraFormat(value)
    local newTable = {}
    for _, v in pairs(value) do
        local id = v.AuraID or v.SpellID or v.ItemID or v.SlotID or v.TotemID or v.IntID
        if id and not v.Disabled then
            newTable[id] = v
        end
    end
    return newTable
end

function C.aura:AddClassSpells(list)
    for class, value in pairs(list) do
        if class == "ALL" or class == E.myClass then
            C.aura.raidBuffs[class] = value
        end
    end
end

function C.aura:AddNewAuraWatch(class, list)
    for _, k in pairs(list) do
        for _, v in pairs(k) do
            local spellID = v.AuraID or v.SpellID
            if spellID then
                local name = C_Spell.GetSpellName(spellID)
                if not name and not v.Disabled then
                    wipe(v)
                end
            end
        end
    end

    if class ~= "ALL" and class ~= E.myClass then return end
    if not C.aura.auraWatch[class] then C.aura.auraWatch[class] = {} end

    for name, v in pairs(list) do
        local direction, interval, mode, size, pos, width = unpack(groups[name])
        tinsert(C.aura.auraWatch[class], {
            Name      = name,
            Direction = direction,
            Interval  = interval,
            Mode      = mode,
            IconSize  = size,
            Pos       = pos,
            BarWidth  = width,
            List      = newAuraFormat(v)
        })
    end
end

function C.aura:AddDeprecatedGroup(list)
    for name, value in pairs(list) do
        for _, l in pairs(C.aura.auraWatch["ALL"]) do
            if l.Name == name then
                local newTable = newAuraFormat(value)
                for spellID, v in pairs(newTable) do
                    l.List[spellID] = v
                end
            end
        end
    end
end

function C.aura:RegisterDebuff(tierID, instID, bossID, spellID, level)
    local instName = EJ_GetInstanceInfo(instID)

    if not C.aura.raidDebuffs[instName] then C.aura.raidDebuffs[instName] = {} end
    if not level then level = 2 end
    if level > 6 then level = 6 end

    C.aura.raidDebuffs[instName][spellID] = level
end
