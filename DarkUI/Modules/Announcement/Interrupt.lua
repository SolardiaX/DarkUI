local E, C, L = select(2, ...):unpack()

if not C.announcement.interrupt.enable then return end

----------------------------------------------------------------------------------------
--    Announce your interrupts (modified from Elv)
----------------------------------------------------------------------------------------
local module = E:Module("Announcement"):Sub("Interrupt")

local IsInGroup, IsInRaid, IsPartyLFG = IsInGroup, IsInRaid, IsPartyLFG
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local UnitGUID = UnitGUID
local GetInstanceInfo = GetInstanceInfo
local IsArenaSkirmish, IsActiveBattlefieldArena = IsArenaSkirmish, IsActiveBattlefieldArena
local SendChatMessage = SendChatMessage
local format = format

local cfg = C.announcement.interrupt
local channels = { 'SAY', 'YELL', 'EMOTE', 'PARTY', 'RAID_ONLY', 'RAID' }

local function annouce_interrupt()
    local inGroup, inRaid, inPartyLFG = IsInGroup(), IsInRaid(), IsPartyLFG()
    if not inGroup then return end -- not in group, exit.

    local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID, spellName = CombatLogGetCurrentEventInfo()
    if not (event == "SPELL_INTERRUPT" and (sourceGUID == UnitGUID("player") or sourceGUID == UnitGUID("pet"))) then
        return
    end

    local _, instanceType = GetInstanceInfo()
    if instanceType == "arena" then
        local skirmish = IsArenaSkirmish()
        local _, isRegistered = IsActiveBattlefieldArena()
        if skirmish or not isRegistered then
            inPartyLFG = true
        end
        inRaid = false --IsInRaid() returns true for arenas and they should not be considered a raid
    end

    local interruptAnnounce, msg = channels[cfg.channel], format(L.CHAT_INTERRUPTED, destName, spellID, spellName)
    if interruptAnnounce == "PARTY" then
        SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "PARTY")
    elseif interruptAnnounce == "RAID" then
        SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or (inRaid and "RAID" or "PARTY"))
    elseif interruptAnnounce == "RAID_ONLY" and inRaid then
        SendChatMessage(msg, inPartyLFG and "INSTANCE_CHAT" or "RAID")
    elseif interruptAnnounce == "SAY" and instanceType ~= "none" then
        SendChatMessage(msg, "SAY")
    elseif interruptAnnounce == "YELL" and instanceType ~= "none" then
        SendChatMessage(msg, "YELL")
    elseif interruptAnnounce == "EMOTE" then
        SendChatMessage(msg, "EMOTE")
    end
end

module:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", annouce_interrupt)
