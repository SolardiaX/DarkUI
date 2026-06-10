local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Interrupt Announce
------------------------------------------------------------------------

local module = E:Module("Announcement"):Sub("Interrupt")

local cfg = C.announcement.interrupt

local CHANNELS = { "SAY", "YELL", "EMOTE", "PARTY", "RAID_ONLY", "RAID" }

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end

    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function()
        if not IsInGroup() then return end

        local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = C_CombatLog.GetCurrentEventInfo()
        if event ~= "SPELL_INTERRUPT" then return end
        if sourceGUID ~= UnitGUID("player") and sourceGUID ~= UnitGUID("pet") then return end

        local _, instanceType = GetInstanceInfo()
        local inPartyLFG = IsPartyLFG()
        local inRaid = IsInRaid()

        if instanceType == "arena" then
            local skirmish = IsArenaSkirmish()
            local _, isRegistered = IsActiveBattlefieldArena()
            if skirmish or not isRegistered then
                inPartyLFG = true
            end
            inRaid = false
        end

        local channel = CHANNELS[cfg.channel] or "PARTY"
        local spellLink = C_Spell.GetSpellLink(spellID) or spellName or tostring(spellID)
        local msg = format(L.CHAT_INTERRUPTED or "Interrupted %s: %s [%s]", destName or "?", spellLink, spellName or "")

        if channel == "PARTY" then
            SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
        elseif channel == "RAID" then
            SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY"))
        elseif channel == "RAID_ONLY" and inRaid then
            SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
        elseif channel == "SAY" and instanceType ~= "none" then
            SendChatMessage(msg, "SAY")
        elseif channel == "YELL" and instanceType ~= "none" then
            SendChatMessage(msg, "YELL")
        elseif channel == "EMOTE" then
            SendChatMessage(msg, "EMOTE")
        end
    end)
end
