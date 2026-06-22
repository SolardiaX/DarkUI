local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnCombatLog (CLEU + UNIT_COMBAT outgoing damage/heal/miss)
-- Based on MidnightBattleText's dual-source pattern
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combat.combatText

local GetTime = GetTime
local band = bit.band
local pcall = pcall
local select = select
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_Spell_GetSpellName = C_Spell.GetSpellName

local GetCombatLogInfo = C_CombatLog and C_CombatLog.GetCurrentEventInfo

local FLAG_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE or 0x00000001
local FLAG_PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER or 0x00000400

local DEDUP_WINDOW = 0.15
local UC_FALLBACK_WINDOW = 0.4
local CLEU_ACTIVE_WINDOW = 5
local SPELL_TRACK_WINDOW = 1.5

------------------------------------------------------------------------
-- State
------------------------------------------------------------------------

local recentMarks = {}
local lastCleanTime = 0
local lastCLEUTime = 0

local lastPlayerCastTime = 0
local lastPlayerSpellId = nil
local lastPlayerSpellName = nil

local lastPetCastTime = 0
local lastPetSpellId = nil
local lastPetSpellName = nil

------------------------------------------------------------------------
-- Mark / Consume (MBT pcall pattern for secret-safe key generation)
------------------------------------------------------------------------

local function markEvent(amount, category, spellId, isCrit)
    local now = GetTime()
    lastCLEUTime = now
    local ok, key = pcall(function() return tostring(amount) .. category end)
    if not ok then return end
    recentMarks[key] = { time = now, spellId = spellId, isCrit = isCrit }
end

local function consumeMark(amount, category)
    local ok, key = pcall(function() return tostring(amount) .. category end)
    if not ok then return false, nil, false end
    local mark = recentMarks[key]
    if mark and (GetTime() - mark.time) <= DEDUP_WINDOW then
        recentMarks[key] = nil
        return true, mark.spellId, mark.isCrit
    end
    return false, nil, false
end

local function cleanMarks(now)
    if now - lastCleanTime < DEDUP_WINDOW * 3 then return end
    lastCleanTime = now
    for k, v in pairs(recentMarks) do
        if now - v.time > DEDUP_WINDOW * 2 then
            recentMarks[k] = nil
        end
    end
end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function spellIcon(spellId)
    if not spellId then return nil end
    local ok, icon = pcall(C_Spell_GetSpellTexture, spellId)
    return ok and icon or nil
end

local function spellName(spellId)
    if not spellId then return nil end
    local ok, name = pcall(C_Spell_GetSpellName, spellId)
    return ok and name or nil
end

local function getLastPlayerSpellId()
    if lastPlayerSpellId and (GetTime() - lastPlayerCastTime) <= SPELL_TRACK_WINDOW then
        return lastPlayerSpellId, lastPlayerSpellName
    end
    return nil, nil
end

local function getLastPetSpellId()
    if lastPetSpellId and (GetTime() - lastPetCastTime) <= SPELL_TRACK_WINDOW then
        return lastPetSpellId, lastPetSpellName
    end
    return nil, nil
end

------------------------------------------------------------------------
-- Emit
------------------------------------------------------------------------

local function emitDamage(amount, schoolMask, spellId, sName, isAuto, isRangedAuto, isPet, isCrit)
    local dataEvent = {}
    dataEvent.eventType = isPet and "OUTBOUND_PET_DAMAGE" or "OUTBOUND_DAMAGE"
    dataEvent.amount = amount
    dataEvent.damageType = schoolMask or 1
    dataEvent.isAutoAttack = isAuto and not isPet
    dataEvent.isRangedAutoAttack = isRangedAuto and not isPet
    dataEvent.isCrit = isCrit
    dataEvent.skillID = spellId
    dataEvent.skillName = sName or spellName(spellId)
    dataEvent.spellCount = 1

    local icon = spellIcon(spellId)
    if icon then
        dataEvent.skillIcon = icon
        dataEvent.skillIcons = { icon }
    end

    module.Display.Format(dataEvent)
end

local function emitHeal(amount, spellId, sName, isPet, isCrit)
    local dataEvent = {}
    dataEvent.eventType = "OUTBOUND_HEAL"
    dataEvent.amount = amount
    dataEvent.isCrit = isCrit
    dataEvent.skillID = spellId
    dataEvent.skillName = sName or spellName(spellId)
    dataEvent.spellCount = 1

    local icon = spellIcon(spellId)
    if icon then
        dataEvent.skillIcon = icon
        dataEvent.skillIcons = { icon }
    end

    module.Display.Format(dataEvent)
end

local function emitMiss(missType, spellId)
    local dataEvent = {}
    dataEvent.eventType = "OUTBOUND_MISS"
    dataEvent.missType = missType or "MISS"
    dataEvent.skillID = spellId
    dataEvent.skillName = spellName(spellId)
    dataEvent.spellCount = 1

    local icon = spellIcon(spellId)
    if icon then
        dataEvent.skillIcon = icon
        dataEvent.skillIcons = { icon }
    end

    module.Display.Format(dataEvent)
end

------------------------------------------------------------------------
-- CLEU Sub-event Tables
------------------------------------------------------------------------

local CLEU_DAMAGE = {
    SWING_DAMAGE = true,
    RANGE_DAMAGE = true,
    SPELL_DAMAGE = true,
    SPELL_PERIODIC_DAMAGE = true,
    DAMAGE_SHIELD = true,
}

local CLEU_HEAL = {
    SPELL_HEAL = true,
    SPELL_PERIODIC_HEAL = true,
}

local CLEU_MISS = {
    SWING_MISSED = true,
    RANGE_MISSED = true,
    SPELL_MISSED = true,
}

------------------------------------------------------------------------
-- CLEU Handler (entire parser in outer pcall)
------------------------------------------------------------------------

local function parseCLEU()
    local timestamp, subevent, hideCaster,
        srcGUID, srcName, srcFlags, srcRaidFlags,
        destGUID, destName, destFlags, destRaidFlags = GetCombatLogInfo()

    local isMySource = band(srcFlags, FLAG_MINE) ~= 0
    if not isMySource then return end

    local isPlayerSource = band(srcFlags, FLAG_PLAYER) ~= 0
    local isPetSource = not isPlayerSource

    -- Outgoing damage
    if CLEU_DAMAGE[subevent] then
        local amount, schoolMask, spellId, sName, isAuto, isRangedAuto

        if subevent == "SWING_DAMAGE" then
            amount = select(12, GetCombatLogInfo())
            schoolMask = 1
            isAuto = true
            isRangedAuto = false
        elseif subevent == "RANGE_DAMAGE" then
            spellId = select(12, GetCombatLogInfo())
            sName = select(13, GetCombatLogInfo())
            schoolMask = select(14, GetCombatLogInfo())
            amount = select(15, GetCombatLogInfo())
            isAuto = false
            isRangedAuto = true
        else
            spellId = select(12, GetCombatLogInfo())
            sName = select(13, GetCombatLogInfo())
            schoolMask = select(14, GetCombatLogInfo())
            amount = select(15, GetCombatLogInfo())
            isAuto = false
            isRangedAuto = false
        end

        if not amount then return end

        -- Critical detection (offset 18 for SWING, 21 for spell-based)
        local isCrit = false
        local critical
        if subevent == "SWING_DAMAGE" then
            critical = select(18, GetCombatLogInfo())
        else
            critical = select(21, GetCombatLogInfo())
        end
        if critical ~= nil then
            local cOk, cVal = pcall(function() return critical == true end)
            isCrit = cOk and cVal or false
        end

        markEvent(amount, "damage", spellId, isCrit)
        cleanMarks(GetTime())

        if isPlayerSource and cfg.outgoing then
            emitDamage(amount, schoolMask, spellId, sName, isAuto, isRangedAuto, false, isCrit)
        elseif isPetSource and cfg.outgoing then
            emitDamage(amount, schoolMask, spellId, sName, isAuto, isRangedAuto, true, isCrit)
        end
        return
    end

    -- Outgoing heal (skip self-heal: destFlags MINE + PLAYER)
    if CLEU_HEAL[subevent] and isPlayerSource then
        local isPlayerDest = band(destFlags, FLAG_MINE) ~= 0 and band(destFlags, FLAG_PLAYER) ~= 0
        if isPlayerDest then return end

        if not cfg.outgoing_heal then return end

        local spellId = select(12, GetCombatLogInfo())
        local sName = select(13, GetCombatLogInfo())
        local amount = select(15, GetCombatLogInfo())
        local critical = select(18, GetCombatLogInfo())

        if not amount then return end

        local isCrit = false
        if critical ~= nil then
            local cOk, cVal = pcall(function() return critical == true end)
            isCrit = cOk and cVal or false
        end

        markEvent(amount, "heal", spellId, isCrit)
        emitHeal(amount, spellId, sName, false, isCrit)
        return
    end

    -- Outgoing miss
    if CLEU_MISS[subevent] and isPlayerSource then
        if not cfg.outgoing_miss then return end

        local missType, spellId
        if subevent == "SWING_MISSED" then
            missType = select(12, GetCombatLogInfo())
        else
            spellId = select(12, GetCombatLogInfo())
            missType = select(15, GetCombatLogInfo())
        end

        markEvent(missType or "MISS", "miss", spellId, false)
        emitMiss(missType, spellId)
        return
    end
end

------------------------------------------------------------------------
-- UNIT_COMBAT Handler
------------------------------------------------------------------------

local UC_MISS = {
    BLOCK = true, DODGE = true, PARRY = true, MISS = true,
    IMMUNE = true, DEFLECT = true, REFLECT = true,
    RESIST = true, ABSORB = true, EVADE = true,
}

local function handleUnitCombat(unit, action, flagText, amount, schoolMask)
    if unit == "target" then
        local isCrit = (flagText == "CRITICAL")

        if action == "WOUND" then
            if not cfg.outgoing then return end
            local marked = consumeMark(amount, "damage")
            if marked then return end
            if (GetTime() - lastCLEUTime) < CLEU_ACTIVE_WINDOW then return end

            local spellId, sName = getLastPlayerSpellId()
            if spellId then
                emitDamage(amount, schoolMask, spellId, sName, false, false, false, isCrit)
                return
            end
            spellId, sName = getLastPetSpellId()
            if spellId then
                emitDamage(amount, schoolMask, spellId, sName, false, false, true, isCrit)
            end

        elseif action == "HEAL" then
            if not cfg.outgoing_heal then return end
            local marked = consumeMark(amount, "heal")
            if marked then return end
            if (GetTime() - lastCLEUTime) < CLEU_ACTIVE_WINDOW then return end

            local spellId, sName = getLastPlayerSpellId()
            if spellId then
                emitHeal(amount, spellId, sName, false, isCrit)
            end

        elseif UC_MISS[action] then
            if not cfg.outgoing_miss then return end
            local marked = consumeMark(action, "miss")
            if marked then return end
            if (GetTime() - lastCLEUTime) < CLEU_ACTIVE_WINDOW then return end

            local spellId = getLastPlayerSpellId()
            emitMiss(action, spellId)
        end

    elseif unit == "pet" then
        if action == "WOUND" then
            consumeMark(amount, "damage")
        end
    end
end

------------------------------------------------------------------------
-- UNIT_SPELLCAST_SUCCEEDED Handler
------------------------------------------------------------------------

local function handleSpellcast(unit, _, spellId)
    local now = GetTime()
    if unit == "player" then
        lastPlayerCastTime = now
        lastPlayerSpellId = spellId
        lastPlayerSpellName = spellName(spellId)
    elseif unit == "pet" then
        lastPetCastTime = now
        lastPetSpellId = spellId
        lastPetSpellName = spellName(spellId)
    end
end

------------------------------------------------------------------------
-- Frame Registration
------------------------------------------------------------------------

local cleuFrame = CreateFrame("Frame")
local ucFrame = CreateFrame("Frame")
local spellFrame = CreateFrame("Frame")
local regenFrame = CreateFrame("Frame")

cleuFrame:SetScript("OnEvent", function()
    pcall(parseCLEU)
end)

ucFrame:SetScript("OnEvent", function(_, _, unit, action, flagText, amount, school)
    pcall(handleUnitCombat, unit, action, flagText, amount, school)
end)

spellFrame:SetScript("OnEvent", function(_, _, unit, _, spellId)
    pcall(handleSpellcast, unit, nil, spellId)
end)

------------------------------------------------------------------------
-- Enable / Disable (with InCombatLockdown protection)
------------------------------------------------------------------------

module.CombatLog = module.CombatLog or {}

local function registerEvents()
    if GetCombatLogInfo then
        cleuFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    if ucFrame.RegisterUnitEvent then
        ucFrame:RegisterUnitEvent("UNIT_COMBAT", "target", "pet")
    else
        ucFrame:RegisterEvent("UNIT_COMBAT")
    end
    if spellFrame.RegisterUnitEvent then
        spellFrame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player", "pet")
    else
        spellFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
    end
end

function module.CombatLog:Enable()
    if InCombatLockdown() then
        regenFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
        regenFrame:SetScript("OnEvent", function(self)
            self:UnregisterAllEvents()
            registerEvents()
        end)
        return
    end
    registerEvents()
end

function module.CombatLog:Disable()
    cleuFrame:UnregisterAllEvents()
    ucFrame:UnregisterAllEvents()
    spellFrame:UnregisterAllEvents()
    regenFrame:UnregisterAllEvents()
end
