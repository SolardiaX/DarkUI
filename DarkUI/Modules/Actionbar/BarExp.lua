local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Exp/Rep Bar
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("ExpRep")

local gsub, smatch = string.gsub, string.match
local floor = math.floor

local cfg = C.actionbar.bars.exp

local faction_standing_msg = {
    gsub(FACTION_STANDING_INCREASED, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_GENERIC, "%%s", "(.+)"),
    gsub(FACTION_STANDING_DECREASED, "%%s", "(.+)"),
    gsub(FACTION_STANDING_DECREASED_GENERIC, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_ACH_BONUS, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_BONUS, "%%s", "(.+)"),
    gsub(FACTION_STANDING_INCREASED_DOUBLE_BONUS, "%%s", "(.+)"),
}

local function switcherSetFactionByName(faction_name)
    if faction_name == "Guild" then
        faction_name = GetGuildInfo("player")
    end

    for i = 1, C_Reputation.GetNumFactions() do
        local factionInfo = C_Reputation.GetFactionDataByIndex(i)
        if factionInfo and factionInfo.name == faction_name then
            if C_Reputation.IsFactionActive(i) then
                C_Reputation.SetWatchedFactionByIndex(i)
            end
        end
    end
end

local function switcherOnEvent(_, event, ...)
    if cfg.autoswitch ~= true then
        return
    end

    local arg1 = ...
    if event == "CHAT_MSG_COMBAT_FACTION_CHANGE" then
        local faction_name
        local i = 1
        while (faction_name == nil) and (i < #faction_standing_msg) do
            faction_name = smatch(arg1, faction_standing_msg[i])
            i = i + 1
        end
        if faction_name ~= nil then
            switcherSetFactionByName(faction_name)
        end
    end
end

local function updateBar(statusbar, isrep)
    if not isrep then
        local barMin, barMax = UnitXP("player"), UnitXPMax("player")
        local exhaustion = GetXPExhaustion() or 0

        statusbar:SetMinMaxValues(0, barMax)
        statusbar:SetValue(barMin)
        statusbar.rest:SetMinMaxValues(0, barMax)
        statusbar.rest:SetValue(math.min(barMin + exhaustion, barMax))
    else
        local factionData = C_Reputation.GetWatchedFactionData()
        if not factionData then
            statusbar:Hide()
            return
        end

        local standing = factionData.reaction
        local barMin = factionData.currentReactionThreshold
        local barMax = factionData.nextReactionThreshold
        local value = factionData.currentStanding
        local factionID = factionData.factionID

        if factionID and C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
            value = majorFactionData.renownReputationEarned or 0
            barMin, barMax = 0, majorFactionData.renownLevelThreshold
        else
            local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            local friendID, friendRep, friendThreshold, nextFriendThreshold
            if repInfo then
                friendID, friendRep, friendThreshold, nextFriendThreshold =
                    repInfo.friendshipFactionID, repInfo.standing, repInfo.reactionThreshold, repInfo.nextThreshold
            end
            if C_Reputation.IsFactionParagon(factionID) then
                local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
                currentValue = mod(currentValue, threshold)
                barMin, barMax, value = 0, threshold, currentValue
            elseif friendID and friendID ~= 0 then
                if nextFriendThreshold then
                    barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
                else
                    barMin, barMax, value = 0, 1, 1
                end
                standing = 5
            else
                if standing == MAX_REPUTATION_REACTION then
                    barMin, barMax, value = 0, 1, 1
                end
            end
        end

        local color = FACTION_BAR_COLORS[standing or 5]
        statusbar:SetStatusBarColor(color.r, color.g, color.b)
        statusbar:SetMinMaxValues(0, barMax - barMin)
        statusbar:SetValue(value - barMin)
    end
end

local function barShowXP(statusbar)
    statusbar:Show()
    statusbar:SetStatusBarColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b, 0.85)
    statusbar.background:SetVertexColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b, 0.3)
    statusbar.rest:Show()
    updateBar(statusbar)
end

local function barShowRep(statusbar)
    statusbar:Show()
    statusbar.rest:Hide()
    updateBar(statusbar, true)
end

local function barOnEvent(self, event, arg1, arg2)
    if event == "PLAYER_ENTERING_WORLD" then
        if IsPlayerAtEffectiveMaxLevel() then
            barShowRep(self)
        else
            barShowXP(self)
        end
    elseif event == "PLAYER_XP_UPDATE" and arg1 == "player" then
        updateBar(self)
    elseif event == "PLAYER_LEVEL_UP" then
        if IsPlayerAtEffectiveMaxLevel() then
            barShowRep(self)
        else
            barShowXP(self)
        end
    elseif event == "MODIFIER_STATE_CHANGED" then
        if arg1 == "LCTRL" or arg1 == "RCTRL" then
            if arg2 == 1 then
                barShowRep(self)
            elseif not IsPlayerAtEffectiveMaxLevel() then
                barShowXP(self)
            end
        end
    elseif event == "UPDATE_FACTION" then
        if IsPlayerAtEffectiveMaxLevel() then
            barShowRep(self)
        end
    end
end

local function barOnEnter()
    local mxp = UnitXPMax("player")
    local xp = UnitXP("player")
    local rxp = GetXPExhaustion()
    local factionData = C_Reputation.GetWatchedFactionData()
    local withXp = false

    GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
    GameTooltip:AddLine(L.ACTIONBAR_EXP_REP or "XP / Rep")
    GameTooltip:AddLine(" ")

    if not IsPlayerAtEffectiveMaxLevel() then
        GameTooltip:AddLine(L.ACTIONBAR_EXP or "Experience")
        GameTooltip:AddLine(" ")

        GameTooltip:AddDoubleLine(
            COMBAT_XP_GAIN,
            xp .. "|cffffd100/|r" .. mxp .. " |cffffd100/|r " .. floor((xp / mxp) * 1000) / 10 .. "%",
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            1,
            1,
            1
        )
        if rxp then
            GameTooltip:AddDoubleLine(
                TUTORIAL_TITLE26,
                rxp .. " |cffffd100/|r " .. floor((rxp / mxp) * 1000) / 10 .. "%",
                NORMAL_FONT_COLOR.r,
                NORMAL_FONT_COLOR.g,
                NORMAL_FONT_COLOR.b,
                1,
                1,
                1
            )
        end

        if IsXPUserDisabled() then
            GameTooltip:AddLine("|cffff0000" .. XP .. LOCKED)
        end

        withXp = true
    end

    if factionData then
        local name = factionData.name
        local standing = factionData.reaction
        local barMin = factionData.currentReactionThreshold
        local barMax = factionData.nextReactionThreshold
        local value = factionData.currentStanding
        local factionID = factionData.factionID

        local standingtext
        if factionID and C_Reputation.IsMajorFaction(factionID) then
            local majorFactionData = C_MajorFactions.GetMajorFactionData(factionID)
            name = majorFactionData.name
            standingtext = format(RENOWN_LEVEL_LABEL, majorFactionData.renownLevel)

            local isMaxRenown = C_MajorFactions.HasMaximumRenown(factionID)
            if isMaxRenown then
                barMin, barMax, value = 0, 1, 1
            else
                value = majorFactionData.renownReputationEarned or 0
                barMin, barMax = 0, majorFactionData.renownLevelThreshold
            end
        else
            local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
            local friendID, friendRep, friendThreshold, nextFriendThreshold, friendTextLevel
            if repInfo then
                friendID = repInfo.friendshipFactionID
                friendRep = repInfo.standing
                friendThreshold = repInfo.reactionThreshold
                nextFriendThreshold = repInfo.nextThreshold
                friendTextLevel = repInfo.text
            end
            local repRankInfo = C_GossipInfo.GetFriendshipReputationRanks(factionID)
            local currentRank, maxRank = repRankInfo.currentLevel, repRankInfo.maxLevel
            if friendID and friendID ~= 0 then
                if maxRank > 0 then
                    name = name .. " (" .. currentRank .. " / " .. maxRank .. ")"
                end
                if nextFriendThreshold then
                    barMin, barMax, value = friendThreshold, nextFriendThreshold, friendRep
                else
                    barMax = barMin + 1e3
                    value = barMax - 1
                end
                standingtext = friendTextLevel
            else
                if standing == MAX_REPUTATION_REACTION then
                    barMax = barMin + 1e3
                    value = barMax - 1
                end
                standingtext = _G["FACTION_STANDING_LABEL" .. standing] or UNKNOWN
            end
        end

        if withXp then
            GameTooltip:AddLine(" ")
        end

        GameTooltip:AddLine(L.ACTIONBAR_REP or "Reputation")
        GameTooltip:AddLine(" ")

        GameTooltip:AddDoubleLine(FACTION, name, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
        GameTooltip:AddDoubleLine(
            STANDING,
            standingtext,
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            FACTION_BAR_COLORS[standing].r,
            FACTION_BAR_COLORS[standing].g,
            FACTION_BAR_COLORS[standing].b
        )
        GameTooltip:AddDoubleLine(
            REPUTATION,
            value - barMin .. "|cffffd100 /|r" .. barMax - barMin .. " |cffffd100/|r " .. floor((value - barMin) / (barMax - barMin) * 1000) / 10 .. "%",
            NORMAL_FONT_COLOR.r,
            NORMAL_FONT_COLOR.g,
            NORMAL_FONT_COLOR.b,
            1,
            1,
            1
        )

        if C_Reputation.IsFactionParagon(factionID) then
            local currentValue, threshold = C_Reputation.GetFactionParagonInfo(factionID)
            local paraCount = floor(currentValue / threshold)
            currentValue = mod(currentValue, threshold)
            GameTooltip:AddDoubleLine(
                (L.ACTIONBAR_PARAGON_EXP or "Paragon") .. " - Lv" .. paraCount,
                currentValue .. "/" .. threshold .. " (" .. floor(currentValue / threshold * 100) .. "%)",
                0.6,
                0.8,
                1,
                1,
                1,
                1
            )
        end
    end

    GameTooltip:Show()
end

local function barOnLeave()
    GameTooltip:Hide()
end

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    local statusbar = CreateFrame("StatusBar", "DarkUI_XPBar", UIParent)
    statusbar:SetFrameStrata(cfg.bfstrata)
    statusbar:SetFrameLevel(cfg.bflevel)
    statusbar:SetSize(cfg.width, cfg.height)
    statusbar:SetPoint(unpack(cfg.pos))
    statusbar:SetScale(cfg.scale)
    statusbar:SetStatusBarTexture(C.media.texture.status)
    statusbar:SetStatusBarColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b)

    statusbar.rest = CreateFrame("StatusBar", nil, statusbar)
    statusbar.rest:SetFrameStrata(cfg.bfstrata)
    statusbar.rest:SetFrameLevel(cfg.bflevel)
    statusbar.rest:SetAllPoints(statusbar)
    statusbar.rest:SetStatusBarTexture(C.media.texture.status)
    statusbar.rest:SetStatusBarColor(cfg.restcolor.r, cfg.restcolor.g, cfg.restcolor.b)

    statusbar.background = statusbar:CreateTexture(nil, "BACKGROUND", nil, -8)
    statusbar.background:SetAllPoints(statusbar)
    statusbar.background:SetTexture(C.media.texture.status)
    statusbar.background:SetVertexColor(cfg.xpcolor.r, cfg.xpcolor.g, cfg.xpcolor.b, 0.3)

    statusbar:SetScript("OnEvent", barOnEvent)
    statusbar:SetScript("OnEnter", barOnEnter)
    statusbar:SetScript("OnLeave", barOnLeave)

    statusbar:RegisterEvent("PLAYER_XP_UPDATE")
    statusbar:RegisterEvent("PLAYER_LEVEL_UP")
    statusbar:RegisterEvent("PLAYER_ENTERING_WORLD")
    statusbar:RegisterEvent("UPDATE_FACTION")
    statusbar:RegisterEvent("MODIFIER_STATE_CHANGED")

    self:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE", switcherOnEvent)
end
