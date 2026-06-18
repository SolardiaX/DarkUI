local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnDamageMeter
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combattext

local PLAYER_GUID = UnitGUID("player") or "0x0000000000000000"
local PLAYER_NAME = UnitName("player")

local BATCH_DELAY = 0.15
local lastResetTime = 0

local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_Spell_IsAutoAttackSpell = C_Spell.IsAutoAttackSpell
local C_Spell_IsRangedAutoAttackSpell = C_Spell.IsRangedAutoAttackSpell

local PET_CHECK_FRAME = CreateFrame("Frame")
local PET_CHECK_FS = PET_CHECK_FRAME:CreateFontString(nil, "OVERLAY")
PET_CHECK_FS:SetFont("Interface\\AddOns\\DarkUI\\Media\\calibri-bold.ttf", 12)
PET_CHECK_FS:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -10000, -10000)
PET_CHECK_FS:Show()

local function isPetAttackByCreatureName(creatureName)
    if not issecretvalue(creatureName) then
        return creatureName ~= ""
    end

    PET_CHECK_FS:SetWidth(10)
    PET_CHECK_FS:SetText(creatureName)

    local numLines = PET_CHECK_FS:GetNumLines()

    local success, _ = pcall(function()
        C_Spell.GetSpellName(numLines)
    end)

    return success
end

local isProcessing = false

local dataEvent = {}

local function onDamageMeterCombatSessionUpdate()
    if not C_DamageMeter or isProcessing then
        return
    end

    local now = GetTime()
    if (now - lastResetTime) < BATCH_DELAY then
        return
    end

    isProcessing = true

    local playerDamageSessionSource = C_DamageMeter.GetCombatSessionSourceFromType(0, Enum.DamageMeterType.DamageDone, PLAYER_GUID)

    local spellCount = #playerDamageSessionSource.combatSpells

    if spellCount == 0 then
        C_DamageMeter.ResetAllCombatSessions()
        lastResetTime = now
        isProcessing = false
        return
    end

    local groupUnlikeSpells = cfg.group_unlike_spells

    if groupUnlikeSpells then
        wipe(dataEvent)

        dataEvent.recipientUnit = "target"
        dataEvent.recipientGUID = UnitGUID("target")
        dataEvent.recipientName = UnitName("target")

        dataEvent.eventType = "OUTBOUND_DAMAGE"
        dataEvent.sourceGUID = PLAYER_GUID
        dataEvent.sourceName = PLAYER_NAME
        dataEvent.sourceUnit = "player"

        dataEvent.amount = playerDamageSessionSource.totalAmount
        dataEvent.damageType = 1
        dataEvent.spellCount = spellCount

        if spellCount == 1 then
            local damageSpell = playerDamageSessionSource.combatSpells[1]
            dataEvent.isAutoAttack = C_Spell_IsAutoAttackSpell(damageSpell.spellID)
            dataEvent.isRangedAutoAttack = C_Spell_IsRangedAutoAttackSpell(damageSpell.spellID)

            if isPetAttackByCreatureName(damageSpell.creatureName) then
                dataEvent.eventType = "OUTBOUND_PET_DAMAGE"
                dataEvent.sourceGUID = UnitGUID("pet")
                dataEvent.sourceName = UnitName("pet")
                dataEvent.sourceUnit = "pet"
            end
        end

        local icons = {}
        for _, damageSpell in ipairs(playerDamageSessionSource.combatSpells) do
            local icon = C_Spell_GetSpellTexture(damageSpell.spellID)
            if icon then
                table.insert(icons, icon)
            end
        end
        dataEvent.skillIcons = icons
        if #icons > 0 then
            dataEvent.skillIcon = icons[1]
        end

        module.Display.Format(dataEvent)
    else
        for _, damageSpell in ipairs(playerDamageSessionSource.combatSpells) do
            wipe(dataEvent)

            dataEvent.recipientUnit = "target"
            dataEvent.recipientGUID = UnitGUID("target")
            dataEvent.recipientName = UnitName("target")

            local damageSpellId = damageSpell.spellID
            local damageAmount = damageSpell.totalAmount

            if isPetAttackByCreatureName(damageSpell.creatureName) then
                dataEvent.eventType = "OUTBOUND_PET_DAMAGE"
                dataEvent.sourceGUID = UnitGUID("pet")
                dataEvent.sourceName = UnitName("pet")
                dataEvent.sourceUnit = "pet"
            else
                dataEvent.eventType = "OUTBOUND_DAMAGE"
                dataEvent.sourceGUID = PLAYER_GUID
                dataEvent.sourceName = PLAYER_NAME
                dataEvent.sourceUnit = "player"
            end

            dataEvent.isAutoAttack = C_Spell_IsAutoAttackSpell(damageSpellId)
            dataEvent.isRangedAutoAttack = C_Spell_IsRangedAutoAttackSpell(damageSpellId)

            dataEvent.skillID = damageSpellId
            dataEvent.skillName = C_Spell.GetSpellName(damageSpellId)
            dataEvent.skillIcon = C_Spell_GetSpellTexture(damageSpellId)
            if dataEvent.skillIcon then
                dataEvent.skillIcons = { dataEvent.skillIcon }
            end
            dataEvent.amount = damageAmount

            dataEvent.damageType = 1

            module.Display.Format(dataEvent)
        end
    end

    C_DamageMeter.ResetAllCombatSessions()

    lastResetTime = now
    isProcessing = false
end

module.handlers = module.handlers or {}
module.handlers["DAMAGE_METER_COMBAT_SESSION_UPDATED"] = onDamageMeterCombatSessionUpdate
