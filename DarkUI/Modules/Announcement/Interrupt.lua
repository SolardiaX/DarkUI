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

    self:RegisterEvent("UNIT_SPELLCAST_INTERRUPT", function(_, _, unit, _, spellID)
        if not IsInGroup() then return end
        if unit ~= "player" and unit ~= "pet" then return end

        local info = C_Spell.GetSpellInfo(spellID)
        local spellName = info and info.name or tostring(spellID)
        local spellLink = C_Spell.GetSpellLink(spellID) or spellName

        local _, instanceType = GetInstanceInfo()
        local inPartyLFG = IsPartyLFG()
        local inRaid = IsInRaid()

        if instanceType == "arena" then
            local skirmish = IsArenaSkirmish()
            local _, isRegistered = IsActiveBattlefieldArena()
            if skirmish or not isRegistered then inPartyLFG = true end
            inRaid = false
        end

        local channel = CHANNELS[cfg.channel] or "PARTY"
        local msg = format(L.CHAT_INTERRUPTED or "Interrupted: %s", spellLink)

        if C_ChatInfo.InChatMessagingLockdown() then return end
        if channel == "PARTY" then
            C_ChatInfo.SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
        elseif channel == "RAID" then
            C_ChatInfo.SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY"))
        elseif channel == "RAID_ONLY" and inRaid then
            C_ChatInfo.SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
        elseif channel == "SAY" and instanceType ~= "none" then
            C_ChatInfo.SendChatMessage(msg, "SAY")
        elseif channel == "YELL" and instanceType ~= "none" then
            C_ChatInfo.SendChatMessage(msg, "YELL")
        elseif channel == "EMOTE" then
            C_ChatInfo.SendChatMessage(msg, "EMOTE")
        end
    end)
end
