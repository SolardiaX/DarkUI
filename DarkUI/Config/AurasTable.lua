local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Aura Configuration
------------------------------------------------------------------------

local pairs = pairs

-- RaidDebuffs
C.aura.raidDebuffs = {}

-- RaidBuffs
C.aura.raidBuffs = {}

function C.aura:AddClassSpells(list)
    for class, value in pairs(list) do
        if class == "ALL" or class == E.myClass then
            C.aura.raidBuffs[class] = value
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
