local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable or not C.actionbar.bars.exp.enable then return end

----------------------------------------------------------------------------------------
--	Exp Bar
----------------------------------------------------------------------------------------

local _G = _G
local CollapseFactionHeader = CollapseFactionHeader
local CreateFrame = CreateFrame
local ExpandFactionHeader = ExpandFactionHeader
local GetCurrentCombatTextEventInfo = GetCurrentCombatTextEventInfo
local GetNumFactions = GetNumFactions
local GetFactionInfo = GetFactionInfo
local GetFactionInfoByID = GetFactionInfoByID
local C_GossipInfo_GetFriendshipReputation = C_GossipInfo.GetFriendshipReputation
local C_GossipInfo_GetFriendshipReputationRanks = C_GossipInfo.GetFriendshipReputationRanks
local GetGuildInfo = GetGuildInfo
local GetWatchedFactionInfo = GetWatchedFactionInfo
local IsFactionInactive = IsFactionInactive
local IsAddOnLoaded, LoadAddOn = IsAddOnLoaded, LoadAddOn
local SetWatchedFactionIndex = SetWatchedFactionIndex
local UnitXP, UnitXPMax, GetXPExhaustion = UnitXP, UnitXPMax, GetXPExhaustion
local IsXPUserDisabled, IsWatchingHonorAsXP = IsXPUserDisabled, IsWatchingHonorAsXP
local GetText, CanPrestige, GetPrestigeInfo = GetText, CanPrestige, GetPrestigeInfo
local UnitSex, UnitHonor, UnitHonorLevel, UnitHonorMax = UnitSex, UnitHonor, UnitHonorLevel, UnitHonorMax
local UnitPrestige = UnitPrestige
local GetMaxPlayerHonorLevel = GetMaxPlayerHonorLevel
local C_Reputation_IsFactionParagon = C_Reputation.IsFactionParagon
local C_Reputation_GetFactionParagonInfo = C_Reputation.GetFactionParagonInfo
local gsub, smatch, unpack, select = string.gsub, string.match, unpack, select
local math_min, floor = math.min, floor
local FACTION_STANDING_INCREASED = FACTION_STANDING_INCREASED
local FACTION_STANDING_INCREASED_GENERIC = FACTION_STANDING_INCREASED_GENERIC
local FACTION_STANDING_DECREASED = FACTION_STANDING_DECREASED
local FACTION_STANDING_DECREASED_GENERIC = FACTION_STANDING_DECREASED_GENERIC
local FACTION_STANDING_INCREASED_ACH_BONUS = FACTION_STANDING_INCREASED_ACH_BONUS
local FACTION_STANDING_INCREASED_BONUS = FACTION_STANDING_INCREASED_BONUS
local FACTION_STANDING_INCREASED_DOUBLE_BONUS = FACTION_STANDING_INCREASED_DOUBLE_BONUS
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local MAX_REPUTATION_REACTION = MAX_REPUTATION_REACTION
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local COMBAT_XP_GAIN = COMBAT_XP_GAIN
local NORMAL_FONT_COLOR = NORMAL_FONT_COLOR
local TUTORIAL_TITLE26 = TUTORIAL_TITLE26
local XP, LOCKED, FACTION, STANDING, REPUTATION = XP, LOCKED, FACTION, STANDING, REPUTATION
local PVP_PRESTIGE_RANK_UP_TITLE, LEVEL, HONOR_POINTS = PVP_PRESTIGE_RANK_UP_TITLE, LEVEL, HONOR_POINTS
local PVP_HONOR_PRESTIGE_AVAILABLE, MAX_HONOR_LEVEL = PVP_HONOR_PRESTIGE_AVAILABLE, MAX_HONOR_LEVEL
local UIParent = _G.UIParent
local GameTooltip = _G.GameTooltip

local cfg = C.actionbar.bars.exp

------------------------------------------------------
-- / Auto Rep Switch FUNCs / --
------------------------------------------------------
local collapsed_factions = {}

local faction_standing_msg = {
    gsub(FACTION_STANDING_INCREASED, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_GENERIC, "%%s", "(.+)"),
    gsub(FACTION_STANDING_DECREASED, "%%s", "(.+)"),
    gsub(FACTION_STANDING_DECREASED_GENERIC, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_ACH_BONUS, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_BONUS, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_DOUBLE_BONUS, "%%s", "(.+)")
}

local function switcher_ExpandAndRemember()
    local i = 1

    while i < GetNumFactions() do
        local faction_name, _, _, _, _, _, _, _, _, is_collapsed = GetFactionInfo(i)
        if is_collapsed then
            collapsed_factions[faction_name] = true
            ExpandFactionHeader(i)
        end
        i = i + 1
    end
end

local function switcher_CollapseAndForget()
    local i = 1

    while i < GetNumFactions() do
        local faction_name = GetFactionInfo(i)
        if collapsed_factions[faction_name] then
            CollapseFactionHeader(i)
        end
        i = i + 1
    end
    collapsed_factions = {}
end

local function switcher_SetFactionIndexByID(rep_id)
    local faction_name, _, _ = GetFactionInfoByID(rep_id)

    switcher_ExpandAndRemember()

    local current_name
    for i = 1, GetNumFactions() do
        current_name = GetFactionInfo(i)
        if faction_name == current_name then
            if not IsFactionInactive(i) then
                SetWatchedFactionIndex(i)
            end
            break
        end
    end

    switcher_CollapseAndForget()
    return
end

local function switcher_SetFactionIndexByName(faction_name)
    if faction_name == "Guild" then
        faction_name = GetGuildInfo("player")
    end

    switcher_ExpandAndRemember()

    for i = 1, GetNumFactions() do
        local current_name, _, _, _, _, _, _, _, _, _, _, _, _, rep_id = GetFactionInfo(i)
        if faction_name == current_name then
            switcher_CollapseAndForget()
            switcher_SetFactionIndexByID(rep_id)
            return
        end
    end

    switcher_CollapseAndForget()
    return
end

local function switcher_OnEvent(_, event, ...)
    local arg1 = ...

    if (event == "COMBAT_TEXT_UPDATE" and arg1 == "FACTION") then
        local faction, _ = GetCurrentCombatTextEventInfo()
        if faction ~= nil then
            switcher_SetFactionIndexByName(faction)
        end
    end

    if (event == "CHAT_MSG_COMBAT_FACTION_CHANGE") then
        local faction_name
        local i = 1

        while (faction_name == nil) and (i < #faction_standing_msg) do
            faction_name = smatch(arg1, faction_standing_msg[i])
            i = i + 1
        end

        if faction_name ~= nil then
            switcher_SetFactionIndexByName(faction_name)
        end
    end
end

local function updateBar(statusbar, isrep)
    if not isrep then
        local min, max = UnitXP("player"), UnitXPMax("player")
        local exhaustion = GetXPExhaustion() or 0

        statusbar:SetMinMaxValues(0, max)
        statusbar:SetValue(min)
        statusbar.rest:SetMinMaxValues(0, max)
        statusbar.rest:SetValue(math_min(min + exhaustion, max))
    else
        local name, standing, min, max, value, factionID = GetWatchedFactionInfo()

        if not name then return end

        local friendID, friendRep, _, _, _, _, _, friendThreshold, nextFriendThreshold = C_GossipInfo_GetFriendshipReputation(factionID)
        if friendID then
            if nextFriendThreshold then
                min, max, value = friendThreshold, nextFriendThreshold, friendRep
            else
                min, max, value = 0, 1, 1
            end
            standing = 5
        elseif C_Reputation_IsFactionParagon(factionID) then
            local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
            min, max, value = 0, threshold, currentValue
        else
            if standing == MAX_REPUTATION_REACTION then
                min, max, value = 0, 1, 1
            end
        end

        local color = FACTION_BAR_COLORS[standing]
        statusbar:SetStatusBarColor(color.r, color.g, color.b)
        statusbar:SetMinMaxValues(0, max - min)
        statusbar:SetValue(value - min)
    end
end

local function bar_showXP(statusbar)
    statusbar:SetStatusBarColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b, 0.85)
    statusbar.background:SetVertexColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b, 0.3)

    statusbar.rest:Show()

    updateBar(statusbar)
end

local function bar_showRep(statusbar)
    statusbar.rest:Hide()

    updateBar(statusbar, true)
end

local function bar_OnEvent(self, event, arg1, arg2, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        if E.level == MAX_PLAYER_LEVEL then
            bar_showRep(self)
        else
            bar_showXP(self)
        end
    elseif event == "PLAYER_XP_UPDATE" and arg1 == "player" then
        updateBar(self)
    elseif event == "PLAYER_LEVEL_UP" then
        if E.level == MAX_PLAYER_LEVEL then
            bar_showRep(self)
        else
            bar_showXP(self)
        end
    elseif event == "MODIFIER_STATE_CHANGED" then
        if arg1 == "LCTRL" or arg1 == "RCTRL" then
            if arg2 == 1 then
                bar_showRep(self)
            elseif arg2 == 0 and E.level ~= MAX_PLAYER_LEVEL then
                bar_showXP(self)
            end
        end
    elseif event == "UPDATE_FACTION" then
        if E.level == MAX_PLAYER_LEVEL then
            bar_showRep(self)
        end
    end
end

local function bar_OnEnter()
    local mxp = UnitXPMax("player")
    local xp = UnitXP("player")
    local rxp = GetXPExhaustion()
    local name, standing, minrep, maxrep, value, factionID = GetWatchedFactionInfo()

    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")

    GameTooltip:AddLine(L.ACTIONBAR_EXP_REP)
    GameTooltip:AddLine(" ")

    if E.level ~= MAX_PLAYER_LEVEL then
        GameTooltip:AddLine(L.ACTIONBAR_EXP)
        GameTooltip:AddLine(" ")
        
        GameTooltip:AddDoubleLine(
                COMBAT_XP_GAIN,
                xp .. "|cffffd100/|r" .. mxp .. " |cffffd100/|r " .. floor((xp / mxp) * 1000) / 10 .. "%",
                NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
                1, 1, 1)
        if rxp then
            GameTooltip:AddDoubleLine(
                    TUTORIAL_TITLE26,
                    rxp .. " |cffffd100/|r " .. floor((rxp / mxp) * 1000) / 10 .. "%",
                    NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
                    1, 1, 1
            )
        end

        if IsXPUserDisabled() then
            GameTooltip:AddLine("|cffff0000" .. XP .. LOCKED)
        end
    end

    if name then
        local repInfo = C_GossipInfo_GetFriendshipReputation(factionID)
        local friendID, friendThreshold, nextFriendThreshold, friendTextLevel = repInfo.friendshipFactionID, repInfo.reactionThreshold, repInfo.nextThreshold, repInfo.text
        local repRankInfo = C_GossipInfo_GetFriendshipReputationRanks(factionID)
        local currentRank, maxRank = repRankInfo.currentLevel, repRankInfo.maxLevel
        local standingtext

        if friendID then
            if maxRank > 0 then
                name = name .. " (" .. currentRank .. " / " .. maxRank .. ")"
            end
            if not nextFriendThreshold then
                value = maxrep - 1
            end
            standingtext = friendTextLevel
        else
            if standing == MAX_REPUTATION_REACTION then
                maxrep = minrep + 1e3
                value = maxrep - 1
            end
            standingtext = GetText("FACTION_STANDING_LABEL" .. standing, UnitSex("player"))
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.ACTIONBAR_REP)
        GameTooltip:AddLine(" ")

        GameTooltip:AddDoubleLine(FACTION, name, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
        GameTooltip:AddDoubleLine(
                STANDING,
                _G["FACTION_STANDING_LABEL" .. standing],
                NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
                FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b
        )
        GameTooltip:AddDoubleLine(
                REPUTATION,
                value - minrep .. "|cffffd100 /|r" .. maxrep - minrep .. " |cffffd100/|r " .. floor((value - minrep) / (maxrep - minrep) * 1000) / 10 .. "%",
                NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b,
                1, 1, 1
        )

        if C_Reputation_IsFactionParagon(factionID) then
            local currentValue, threshold = C_Reputation_GetFactionParagonInfo(factionID)
            local paraCount = floor(currentValue/threshold)
			currentValue = mod(currentValue, threshold)
            GameTooltip:AddDoubleLine(
                    L.ACTIONBAR_PARAGON_EXP.." - Lv"..paraCount,
                    currentValue .. "/" .. threshold .. " (" .. floor(currentValue / threshold * 100) .. "%)",
                    .6, .8, 1,
                    1, 1, 1
            )
        end

        if factionID == 2465 then -- 荒猎团
			local repInfo = C_GossipInfo_GetFriendshipReputation(2463) -- 玛拉斯缪斯
			local rep, name, reaction, threshold, nextThreshold = repInfo.standing, repInfo.name, repInfo.reaction, repInfo.reactionThreshold, repInfo.nextThreshold
			if nextThreshold and rep > 0 then
				local current = rep - threshold
				local currentMax = nextThreshold - threshold
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(name, 0,.6,1)
				GameTooltip:AddDoubleLine(reaction, current.." / "..currentMax.." ("..floor(current/currentMax*100).."%)", .6,.8,1, 1,1,1)
			end
		end
    end

    if IsWatchingHonorAsXP() then
        local current, max = UnitHonor("player"), UnitHonorMax("player")
        local level, levelmax = UnitHonorLevel("player"), GetMaxPlayerHonorLevel()
        local text
        if CanPrestige() then
            text = PVP_HONOR_PRESTIGE_AVAILABLE
        elseif level == levelmax then
            text = MAX_HONOR_LEVEL
        else
            text = current .. "/" .. max
        end
        GameTooltip:AddLine(" ")
        if UnitPrestige("player") > 0 then
            GameTooltip:AddLine(select(2, GetPrestigeInfo(UnitPrestige("player"))), .0, .6, 1)
        else
            GameTooltip:AddLine(PVP_PRESTIGE_RANK_UP_TITLE .. LEVEL .. "0", .0, .6, 1)
        end
        GameTooltip:AddDoubleLine(HONOR_POINTS .. LEVEL .. level, text, .6, .8, 1, 1, 1, 1)
    end

    GameTooltip:Show()
end

local function bar_OnLeave()
    GameTooltip:Hide()
end

if not IsAddOnLoaded("Blizzard_GuildUI") then LoadAddOn("Blizzard_GuildUI") end

if cfg.disable_at_max_lvl and E.level == MAX_PLAYER_LEVEL then
    local holder = CreateFrame("Frame", nil, UIParent)
    holder:SetFrameStrata(cfg.bfstrata)
    holder:SetFrameLevel(cfg.bflevel)
    holder:SetSize(cfg.width, cfg.height)
    holder:SetPoint(unpack(cfg.pos))
    holder:SetScale(cfg.scale)

    holder.texture = holder:CreateTexture(nil, "BACKGROUND")
    holder.texture:SetTexture(cfg.statusbar)
    holder.texture:SetAllPoints(holder)
    holder.texture:SetVertexColor(1 / 255, 1 / 255, 1 / 255)

    return
end

local statusbar = CreateFrame("StatusBar", "DarkUI_XPBar", UIParent)
statusbar:SetFrameStrata(cfg.bfstrata)
statusbar:SetFrameLevel(cfg.bflevel)
statusbar:SetSize(cfg.width, cfg.height)
statusbar:SetPoint(unpack(cfg.pos))
statusbar:SetScale(cfg.scale)
statusbar:SetStatusBarTexture(cfg.statusbar)
statusbar:SetStatusBarColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b)

statusbar.rest = CreateFrame("Statusbar", nil, statusbar)
statusbar.rest:SetAllPoints(statusbar)
statusbar.rest:SetStatusBarTexture(cfg.statusbar)
statusbar.rest:SetStatusBarColor(cfg.restcolor.r, cfg.restcolor.g, cfg.restcolor.b)

statusbar.background = statusbar:CreateTexture(nil, "BACKGROUND", nil, -8)
statusbar.background:SetAllPoints(statusbar)
statusbar.background:SetTexture(cfg.statusbar)
statusbar.background:SetVertexColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b, 0.3)

statusbar:SetScript("OnEvent", bar_OnEvent)
statusbar:SetScript("OnEnter", bar_OnEnter)
statusbar:SetScript("OnLeave", bar_OnLeave)

statusbar:RegisterEvent("PLAYER_XP_UPDATE")
statusbar:RegisterEvent("PLAYER_LEVEL_UP")
statusbar:RegisterEvent("PLAYER_ENTERING_WORLD")
statusbar:RegisterEvent("UPDATE_FACTION")
statusbar:RegisterEvent("MODIFIER_STATE_CHANGED")

-- create frame as event listener
local switcher = CreateFrame("Frame")

-- register events
switcher:RegisterEvent("COMBAT_TEXT_UPDATE")
switcher:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")

-- set script
switcher:SetScript("OnEvent", switcher_OnEvent)
