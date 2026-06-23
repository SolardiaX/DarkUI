local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Quest Notification
------------------------------------------------------------------------

local module = E:Module("Announcement"):Sub("QuestNotification")

local cfg = C.announcement

local strmatch, strfind, gsub, format, floor = strmatch, strfind, gsub, format, floor
local wipe, mod, tonumber, pairs = wipe, mod, tonumber, pairs
local GetQuestLink = GetQuestLink
local C_QuestLog_IsComplete = C_QuestLog.IsComplete
local C_QuestLog_IsWorldQuest = C_QuestLog.IsWorldQuest
local C_QuestLog_GetQuestTagInfo = C_QuestLog.GetQuestTagInfo
local C_QuestLog_GetTitleForQuestID = C_QuestLog.GetTitleForQuestID
local C_QuestLog_GetQuestIDForLogIndex = C_QuestLog.GetQuestIDForLogIndex
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_QuestLog_GetLogIndexForQuestID = C_QuestLog.GetLogIndexForQuestID
local C_QuestLog_GetInfo = C_QuestLog.GetInfo

local DAILY = DAILY
local QUEST_COMPLETE = QUEST_COMPLETE
local COLLECTED = COLLECTED
local LE_QUEST_TAG_TYPE_PROFESSION = Enum.QuestTagType.Profession
local LE_QUEST_FREQUENCY_DAILY = Enum.QuestFrequency.Daily

local completedQuest = {}
local initComplete

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function getQuestLinkOrName(questID) return GetQuestLink(questID) or C_QuestLog_GetTitleForQuestID(questID) or "" end

local function sendQuestMsg(msg)
    if IsPartyLFG() or C_PartyInfo.IsPartyWalkIn() then
        SendChatMessage(msg, "INSTANCE_CHAT")
    elseif IsInRaid() then
        SendChatMessage(msg, "RAID")
    elseif IsInGroup() then
        SendChatMessage(msg, "PARTY")
    end
end

local function getPattern(pattern)
    pattern = gsub(pattern, "%(", "%%%1")
    pattern = gsub(pattern, "%)", "%%%1")
    pattern = gsub(pattern, "%%%d?$?.", "(.+)")
    return format("^%s$", pattern)
end

local questMatches = {
    ["Found"] = getPattern(ERR_QUEST_ADD_FOUND_SII),
    ["Item"] = getPattern(ERR_QUEST_ADD_ITEM_SII),
    ["Kill"] = getPattern(ERR_QUEST_ADD_KILL_SII),
    ["PKill"] = getPattern(ERR_QUEST_ADD_PLAYER_KILL_SII),
    ["ObjectiveComplete"] = getPattern(ERR_QUEST_OBJECTIVE_COMPLETE_S),
    ["QuestComplete"] = getPattern(ERR_QUEST_COMPLETE_S),
    ["QuestFailed"] = getPattern(ERR_QUEST_FAILED_S),
}

------------------------------------------------------------------------
-- Handlers
------------------------------------------------------------------------

local function onQuestProgress(_, _, _, msg)
    for _, pattern in pairs(questMatches) do
        if strmatch(msg, pattern) then
            local _, _, _, cur, max = strfind(msg, "(.*)[:：]%s*([-%d]+)%s*/%s*([-%d]+)%s*$")
            cur, max = tonumber(cur), tonumber(max)
            if cur and max and max >= 10 then
                if mod(cur, floor(max / 5)) == 0 then sendQuestMsg(msg) end
            else
                sendQuestMsg(msg)
            end
            break
        end
    end
end

local function onQuestAccepted(_, _, questID)
    if not questID then return end
    if C_QuestLog_IsWorldQuest(questID) then return end

    local tagInfo = C_QuestLog_GetQuestTagInfo(questID)
    if tagInfo and tagInfo.worldQuestType == LE_QUEST_TAG_TYPE_PROFESSION then return end

    local questLogIndex = C_QuestLog_GetLogIndexForQuestID(questID)
    if questLogIndex then
        local info = C_QuestLog_GetInfo(questLogIndex)
        if info then
            local title = getQuestLinkOrName(questID)
            local daily = info.frequency == LE_QUEST_FREQUENCY_DAILY
            if daily then
                sendQuestMsg(format("%s [%s]%s", L.QUEST_ACCEPT or "Accept", DAILY, title))
            else
                sendQuestMsg(format("%s %s", L.QUEST_ACCEPT or "Accept", title))
            end
        end
    end
end

local function onQuestLogUpdate()
    for i = 1, C_QuestLog_GetNumQuestLogEntries() do
        local questID = C_QuestLog_GetQuestIDForLogIndex(i)
        local isComplete = questID and C_QuestLog_IsComplete(questID)
        if isComplete and not completedQuest[questID] and not C_QuestLog_IsWorldQuest(questID) then
            if initComplete then
                PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "Master")
                sendQuestMsg(format("%s %s", getQuestLinkOrName(questID), QUEST_COMPLETE))
            end
            completedQuest[questID] = true
        end
    end
    initComplete = true
end

local function onWorldQuestComplete(_, _, questID)
    if C_QuestLog_IsWorldQuest(questID) then
        if questID and not completedQuest[questID] then
            PlaySound(SOUNDKIT.ALARM_CLOCK_WARNING_3, "Master")
            sendQuestMsg(format("%s %s", getQuestLinkOrName(questID), QUEST_COMPLETE))
            completedQuest[questID] = true
        end
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.quest_notification then return end

    self:RegisterEvent("QUEST_ACCEPTED", onQuestAccepted)
    self:RegisterEvent("QUEST_LOG_UPDATE", onQuestLogUpdate)
    self:RegisterEvent("QUEST_TURNED_IN", onWorldQuestComplete)
    self:RegisterEvent("UI_INFO_MESSAGE", onQuestProgress)
end
