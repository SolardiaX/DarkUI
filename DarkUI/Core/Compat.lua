local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- WoW 12.0 Compatibility Layer
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- Secret Values
----------------------------------------------------------------------------------------

function E:IsSecret(value)
    if issecretvalue then return issecretvalue(value) end
    return false
end

function E:SafeValue(value, fallback)
    if E:IsSecret(value) then return fallback end
    return value
end

----------------------------------------------------------------------------------------
-- Polyfills
----------------------------------------------------------------------------------------

-- GetVehicleBarIndex → C_ActionBar.GetVehicleBarIndex
if not GetVehicleBarIndex and C_ActionBar and C_ActionBar.GetVehicleBarIndex then GetVehicleBarIndex = C_ActionBar.GetVehicleBarIndex end

-- GetBonusBarIndex → C_ActionBar.GetBonusBarIndex
if not GetBonusBarIndex and C_ActionBar and C_ActionBar.GetBonusBarIndex then GetBonusBarIndex = C_ActionBar.GetBonusBarIndex end

-- GetOverrideBarIndex → C_ActionBar.GetOverrideBarIndex
if not GetOverrideBarIndex and C_ActionBar and C_ActionBar.GetOverrideBarIndex then GetOverrideBarIndex = C_ActionBar.GetOverrideBarIndex end

-- GetExtraBarIndex → C_ActionBar.GetExtraBarIndex
if not GetExtraBarIndex and C_ActionBar and C_ActionBar.GetExtraBarIndex then GetExtraBarIndex = C_ActionBar.GetExtraBarIndex end

-- GetTempShapeshiftBarIndex → C_ActionBar.GetTempShapeshiftBarIndex
if not GetTempShapeshiftBarIndex and C_ActionBar and C_ActionBar.GetTempShapeshiftBarIndex then
    GetTempShapeshiftBarIndex = C_ActionBar.GetTempShapeshiftBarIndex
end

-- HasVehicleActionBar → C_ActionBar.HasVehicleActionBar
if not HasVehicleActionBar and C_ActionBar and C_ActionBar.HasVehicleActionBar then HasVehicleActionBar = C_ActionBar.HasVehicleActionBar end

-- HasOverrideActionBar → C_ActionBar.HasOverrideActionBar
if not HasOverrideActionBar and C_ActionBar and C_ActionBar.HasOverrideActionBar then HasOverrideActionBar = C_ActionBar.HasOverrideActionBar end

-- HasBonusActionBar → C_ActionBar.HasBonusActionBar
if not HasBonusActionBar and C_ActionBar and C_ActionBar.HasBonusActionBar then HasBonusActionBar = C_ActionBar.HasBonusActionBar end

-- HasAction → C_ActionBar.HasAction
if not HasAction and C_ActionBar and C_ActionBar.HasAction then HasAction = C_ActionBar.HasAction end

-- GetActionInfo → C_ActionBar.GetActionInfo
if not GetActionInfo and C_ActionBar and C_ActionBar.GetActionInfo then GetActionInfo = C_ActionBar.GetActionInfo end

-- IsActionInRange → C_ActionBar.IsActionInRange
if not IsActionInRange and C_ActionBar and C_ActionBar.IsActionInRange then IsActionInRange = C_ActionBar.IsActionInRange end

-- IsUsableAction → C_ActionBar.IsUsableAction
if not IsUsableAction and C_ActionBar and C_ActionBar.IsUsableAction then IsUsableAction = C_ActionBar.IsUsableAction end

-- GetActionCooldown → C_ActionBar.GetActionCooldown
if not GetActionCooldown and C_ActionBar and C_ActionBar.GetActionCooldown then GetActionCooldown = C_ActionBar.GetActionCooldown end

-- GetSpellPowerCost → C_Spell.GetSpellPowerCost
if not GetSpellPowerCost and C_Spell and C_Spell.GetSpellPowerCost then GetSpellPowerCost = C_Spell.GetSpellPowerCost end

-- GetSpellInfo: 11.0+ returns table, provide old multi-return wrapper
if not GetSpellInfo then
    GetSpellInfo = function(spellID)
        local info = C_Spell.GetSpellInfo(spellID)
        if info then return info.name, nil, info.iconID, info.castTime, info.minRange, info.maxRange, info.spellID, info.originalIconID end
    end
end

-- GetSpellCooldown → C_Spell.GetSpellCooldown
if not GetSpellCooldown then
    GetSpellCooldown = function(spellID)
        local info = C_Spell.GetSpellCooldown(spellID)
        if info then return info.startTime, info.duration, info.isEnabled, info.modRate end
        return 0, 0, 0
    end
end

-- UnitAura → C_UnitAuras
if not UnitAura then
    UnitAura = function(unit, index, filter)
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
        if auraData then return AuraUtil.UnpackAuraData(auraData) end
    end
end

if not UnitBuff then UnitBuff = function(unit, index, filter) return UnitAura(unit, index, (filter and filter .. "|HELPFUL") or "HELPFUL") end end

if not UnitDebuff then UnitDebuff = function(unit, index, filter) return UnitAura(unit, index, (filter and filter .. "|HARMFUL") or "HARMFUL") end end

-- GetContainerItemInfo → C_Container
if not GetContainerItemInfo then
    GetContainerItemInfo = function(bagIndex, slotIndex)
        local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
        if info then
            return info.iconFileID,
                info.stackCount,
                info.isLocked,
                info.quality,
                info.isReadable,
                info.hasLoot,
                info.hyperlink,
                info.isFiltered,
                info.hasNoValue,
                info.itemID,
                info.isBound
        end
    end
end

-- IsEncounterInProgress → C_InstanceEncounter
if not IsEncounterInProgress and C_InstanceEncounter then IsEncounterInProgress = C_InstanceEncounter.IsEncounterInProgress end

-- CombatLogGetCurrentEventInfo: removed in 12.0, no direct replacement
-- Modules that relied on CLEU must be rewritten to use unit-based events

-- SpellIsPriorityAura → C_Spell.IsPriorityAura
if not SpellIsPriorityAura and C_Spell and C_Spell.IsPriorityAura then SpellIsPriorityAura = C_Spell.IsPriorityAura end

-- ATTACK_BUTTON_FLASH_TIME may be removed
if not ATTACK_BUTTON_FLASH_TIME then ATTACK_BUTTON_FLASH_TIME = 0.4 end

-- TutorialFrameAlertButton: guard against removal
-- Modules should check existence before using
