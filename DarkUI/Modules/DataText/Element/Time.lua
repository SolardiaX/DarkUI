local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Time
------------------------------------------------------------------------

local module = E:Module("DataText")

local format, floor, mod, strfind = format, math.floor, mod, strfind
local date, time, tonumber, pairs = date, time, tonumber, pairs
local GetCVarBool, GetGameTime = GetCVarBool, GetGameTime
local GameTime_GetLocalTime = GameTime_GetLocalTime
local GameTime_GetGameTime = GameTime_GetGameTime
local RequestRaidInfo = RequestRaidInfo
local GetNumSavedInstances, GetSavedInstanceInfo = GetNumSavedInstances, GetSavedInstanceInfo
local GetNumSavedWorldBosses, GetSavedWorldBossInfo = GetNumSavedWorldBosses, GetSavedWorldBossInfo
local SecondsToTime = SecondsToTime
local InCombatLockdown = InCombatLockdown
local ToggleCalendar = ToggleCalendar
local ToggleTimeManager = ToggleTimeManager
local IsShiftKeyDown = IsShiftKeyDown
local C_DateAndTime_GetCurrentCalendarTime = C_DateAndTime.GetCurrentCalendarTime
local C_Calendar_GetNumPendingInvites = C_Calendar.GetNumPendingInvites
local C_Calendar_GetDayEvent = C_Calendar.GetDayEvent
local C_Calendar_SetAbsMonth = C_Calendar.SetAbsMonth
local C_Calendar_OpenCalendar = C_Calendar.OpenCalendar
local C_Calendar_GetNumDayEvents = C_Calendar.GetNumDayEvents
local C_AreaPoiInfo_GetAreaPOIInfo = C_AreaPoiInfo.GetAreaPOIInfo
local C_Map_GetMapInfo = C_Map.GetMapInfo
local IsQuestFlaggedCompleted = C_QuestLog.IsQuestFlaggedCompleted
local GetQuestResetTime = GetQuestResetTime
local TIMEMANAGER_TICKER_24HOUR = TIMEMANAGER_TICKER_24HOUR
local TIMEMANAGER_TICKER_12HOUR = TIMEMANAGER_TICKER_12HOUR
local FULLDATE = FULLDATE
local CALENDAR_WEEKDAY_NAMES = CALENDAR_WEEKDAY_NAMES
local CALENDAR_FULLDATE_MONTH_NAMES = CALENDAR_FULLDATE_MONTH_NAMES
local PLAYER_DIFFICULTY_TIMEWALKER = PLAYER_DIFFICULTY_TIMEWALKER
local RAID_INFO_WORLD_BOSS = RAID_INFO_WORLD_BOSS
local DUNGEON_DIFFICULTY3 = DUNGEON_DIFFICULTY3
local DUNGEONS, RAID_INFO, QUESTS_LABEL, QUEST_COMPLETE = DUNGEONS, RAID_INFO, QUESTS_LABEL, QUEST_COMPLETE
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local GameTooltip = GameTooltip

local cfg = module.config.Time

local PROGRESS_FORMAT = " |cff%s(%s/%s)|r"

------------------------------------------------------------------------
-- Time Format
------------------------------------------------------------------------

local function updateTimerFormat(hour, minute, colorPrefix)
    if GetCVarBool("timeMgrUseMilitaryTime") then
        return format(colorPrefix .. TIMEMANAGER_TICKER_24HOUR, hour, minute)
    else
        local suffix = hour < 12 and "AM" or "PM"
        if hour > 12 then
            hour = hour - 12
        elseif hour == 0 then
            hour = 12
        end
        return format(colorPrefix .. TIMEMANAGER_TICKER_12HOUR .. "|r" .. suffix, hour, minute)
    end
end

------------------------------------------------------------------------
-- Timewalker Detection
------------------------------------------------------------------------

local isTimeWalker, walkerTexture

local function checkTimeWalker()
    local today = C_DateAndTime_GetCurrentCalendarTime()
    C_Calendar_SetAbsMonth(today.month, today.year)
    C_Calendar_OpenCalendar()

    local numEvents = C_Calendar_GetNumDayEvents(0, today.monthDay)
    if numEvents <= 0 then
        return
    end

    for i = 1, numEvents do
        local info = C_Calendar_GetDayEvent(0, today.monthDay, i)
        if info and info.title and not issecretvalue(info.title) and strfind(info.title, PLAYER_DIFFICULTY_TIMEWALKER) and info.sequenceType ~= "END" then
            isTimeWalker = true
            walkerTexture = info.iconTexture
            break
        end
    end
end

local function checkTexture(texture)
    if not walkerTexture then
        return
    end
    if walkerTexture == texture or walkerTexture == texture - 1 then
        return true
    end
end

------------------------------------------------------------------------
-- Quest Tracking Data
------------------------------------------------------------------------

local questlist = {
    { name = "Blingtron", id = 34774 },
    { name = "Timewarped", id = 83285, texture = 6006158 }, -- Vanilla
    { name = "Timewarped", id = 40168, texture = 1129674 }, -- TBC
    { name = "Timewarped", id = 40173, texture = 1129686 }, -- WotLK
    { name = "Timewarped", id = 40786, texture = 1304688 }, -- Cata
    { name = "Timewarped", id = 45563, texture = 1530590 }, -- MoP
    { name = "Timewarped", id = 55499, texture = 1129683 }, -- WoD
    { name = "Timewarped", id = 64710, texture = 1467047 }, -- Legion
    { name = "", id = 76586, questName = true }, -- Spreading the Light
    { name = "", id = 82946, questName = true }, -- Wax On Wax Off
    { name = "", id = 83240, questName = true }, -- Theater Troupe
    { name = "", id = 83333, questName = true }, -- Awakening Machine
}

local delvesKeys = { 91175, 91176, 91177, 91178 }
local keyName

------------------------------------------------------------------------
-- Delves Data
------------------------------------------------------------------------

local delveList = {
    { uiMapID = 2393, delveID = 8426 },
    { uiMapID = 2424, delveID = 8428 },
    { uiMapID = 2405, delveID = 8430 },
    { uiMapID = 2405, delveID = 8432 },
    { uiMapID = 2413, delveID = 8434 },
    { uiMapID = 2413, delveID = 8436 },
    { uiMapID = 2395, delveID = 8438 },
    { uiMapID = 2393, delveID = 8440 },
    { uiMapID = 2437, delveID = 8442 },
    { uiMapID = 2437, delveID = 8444 },
}

------------------------------------------------------------------------
-- Tooltip Helpers
------------------------------------------------------------------------

local title

local function addTitle(text)
    if not title then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(text .. ":", 0.6, 0.8, 1)
        title = true
    end
end

------------------------------------------------------------------------
-- Module Injection
------------------------------------------------------------------------

module:Inject("Time", {
    OnLoad = function(self)
        module:RegEvents(self, "PLAYER_ENTERING_WORLD")
        if not keyName then
            local info = C_CurrencyInfo.GetCurrencyInfo(3028)
            keyName = info and info.name or "Restored Coffer Key"
        end
        if TimeManagerClockButton then
            TimeManagerClockButton:Hide()
        end
    end,
    OnEvent = function(self, event)
        if event == "PLAYER_ENTERING_WORLD" then
            checkTimeWalker()
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        end
    end,
    OnUpdate = function(self, elapsed)
        self.elapsed = (self.elapsed or 5) + elapsed
        if self.elapsed > 5 then
            local colorPrefix = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
            local hour, minute
            if GetCVarBool("timeMgrUseLocalTime") then
                hour, minute = tonumber(date("%H")), tonumber(date("%M"))
            else
                hour, minute = GetGameTime()
            end
            self.text:SetText(updateTimerFormat(hour, minute, colorPrefix))
            self.elapsed = 0
        end
    end,
    OnEnter = function(self)
        self.hovered = true
        RequestRaidInfo()

        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOP", self, "BOTTOM", 0, -8)
        GameTooltip:ClearLines()

        local today = C_DateAndTime_GetCurrentCalendarTime()
        local w, m, d, y = today.weekday, today.month, today.monthDay, today.year
        GameTooltip:AddLine(format(FULLDATE, CALENDAR_WEEKDAY_NAMES[w], CALENDAR_FULLDATE_MONTH_NAMES[m], d, y), 0, 0.6, 1)
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(L.DATATEXT_LOCAL_TIME, GameTime_GetLocalTime(true), 0.6, 0.8, 1, 1, 1, 1)
        GameTooltip:AddDoubleLine(L.DATATEXT_REALM_TIME, GameTime_GetGameTime(true), 0.6, 0.8, 1, 1, 1, 1)

        local r, g, b

        -- World Bosses
        title = false
        for i = 1, GetNumSavedWorldBosses() do
            local name, id, reset = GetSavedWorldBossInfo(i)
            if not (id == 11 or id == 12 or id == 13) then
                addTitle(RAID_INFO_WORLD_BOSS)
                GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 1, 1, 1)
            end
        end

        -- Mythic Dungeons
        title = false
        for i = 1, GetNumSavedInstances() do
            local name, _, reset, diff, locked, extended = GetSavedInstanceInfo(i)
            if diff == 23 and (locked or extended) then
                addTitle(DUNGEON_DIFFICULTY3 .. DUNGEONS)
                if extended then
                    r, g, b = 0.3, 1, 0.3
                else
                    r, g, b = 1, 1, 1
                end
                GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
            end
        end

        -- Raids
        title = false
        for i = 1, GetNumSavedInstances() do
            local name, _, reset, _, locked, extended, _, isRaid, _, diffName, numBosses, progress = GetSavedInstanceInfo(i)
            if isRaid and (locked or extended) then
                addTitle(RAID_INFO)
                if extended then
                    r, g, b = 0.3, 1, 0.3
                else
                    r, g, b = 1, 1, 1
                end
                local progressColor = (numBosses == progress) and "ff0000" or "00ff00"
                local progressStr = format(PROGRESS_FORMAT, progressColor, progress, numBosses)
                GameTooltip:AddDoubleLine(name .. " - " .. diffName .. progressStr, SecondsToTime(reset, true, nil, 3), 1, 1, 1, r, g, b)
            end
        end

        -- Quests
        title = false
        for _, v in pairs(questlist) do
            if IsQuestFlaggedCompleted(v.id) then
                local showEntry = true
                if v.name == "Timewarped" then
                    showEntry = isTimeWalker and checkTexture(v.texture)
                end
                if showEntry then
                    addTitle(QUESTS_LABEL)
                    local displayName = v.questName and QuestUtils_GetQuestName(v.id) or v.name
                    GameTooltip:AddDoubleLine(displayName, QUEST_COMPLETE, 1, 1, 1, 1, 0, 0)
                end
            end
        end

        -- Delves Keys
        local currentKeys, maxKeys = 0, #delvesKeys
        for _, questID in pairs(delvesKeys) do
            if IsQuestFlaggedCompleted(questID) then
                currentKeys = currentKeys + 1
            end
        end
        if currentKeys > 0 then
            addTitle(QUESTS_LABEL)
            if currentKeys == maxKeys then
                r, g, b = 1, 0, 0
            else
                r, g, b = 0, 1, 0
            end
            GameTooltip:AddDoubleLine(keyName, format("%d/%d", currentKeys, maxKeys), 1, 1, 1, r, g, b)
        end

        -- Bountiful Delves
        title = false
        for _, v in pairs(delveList) do
            local delveInfo = C_AreaPoiInfo_GetAreaPOIInfo(v.uiMapID, v.delveID)
            if delveInfo then
                addTitle(delveInfo.description)
                local mapInfo = C_Map_GetMapInfo(v.uiMapID)
                GameTooltip:AddDoubleLine(mapInfo.name .. " - " .. delveInfo.name, SecondsToTime(GetQuestResetTime(), true, nil, 3), 1, 1, 1, 1, 1, 1)
            end
        end

        -- Help
        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(
            L.DATATEXT_TOGGLE_CALENDAR,
            L.DATATEXT_WEEKLY_VAULT,
            module.ttsubh.r,
            module.ttsubh.g,
            module.ttsubh.b,
            module.ttsubh.r,
            module.ttsubh.g,
            module.ttsubh.b
        )

        GameTooltip:Show()
    end,
    OnClick = function(_, button)
        if button == "LeftButton" then
            if InCombatLockdown() then
                UIErrorsFrame:AddMessage("|cffffff00" .. ERR_NOT_IN_COMBAT .. "|r")
                return
            end
            ToggleCalendar()
        elseif button == "MiddleButton" then
            if not WeeklyRewardsFrame then
                C_AddOns.LoadAddOn("Blizzard_WeeklyRewards")
            end
            if WeeklyRewardsFrame then
                if InCombatLockdown() then
                    WeeklyRewardsFrame:SetShown(not WeeklyRewardsFrame:IsShown())
                else
                    ToggleFrame(WeeklyRewardsFrame)
                end
            end
        elseif button == "RightButton" then
            ToggleTimeManager()
        end
    end,
})
