local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b

------------------------------------------------------------------------
-- Quest Info (reward display shared across quest panels)
-- Ported from NDui QuestInfo.lua + ElvUI Quest.lua (2026-07)
------------------------------------------------------------------------

local _G = _G
local pairs, ipairs, next, select = pairs, ipairs, next, select
local strmatch = strmatch
local hooksecurefunc = hooksecurefunc
local GetQuestID = GetQuestID

local C_QuestLog_GetSelectedQuest = C_QuestLog.GetSelectedQuest
local C_QuestInfoSystem_GetQuestRewardSpells = C_QuestInfoSystem.GetQuestRewardSpells

local function clearHighlight()
    for _, button in pairs(_G.QuestInfoRewardsFrame.RewardButtons) do
        if button.textBg then
            button.textBg:SetBackdropColor(0, 0, 0, 0.25)
        end
    end
end

local function setHighlight(self)
    clearHighlight()

    local _, point = self:GetPoint()
    if point and point.textBg then
        point.textBg:SetBackdropColor(cr, cg, cb, 0.25)
    end
end

local defaultColor = GetMaterialTextColors("Default")
local completedColor = QUEST_OBJECTIVE_COMPLETED_FONT_COLOR:GetRGB()

local function replaceTextColor(object, r)
    if r == 0 or r == defaultColor[1] then
        object:SetTextColor(1, 1, 1)
    elseif r == completedColor then
        object:SetTextColor(0.7, 0.7, 0.7)
    end
end

local function restyleSpellButton(bu)
    if not bu then return end
    local name = bu:GetName()

    if name then
        local nameFrame = _G[name .. "NameFrame"]
        if nameFrame then nameFrame:Hide() end
        local spellBorder = _G[name .. "SpellBorder"]
        if spellBorder then spellBorder:Hide() end
    end

    local icon = bu.Icon
    if icon then
        icon:SetPoint("TOPLEFT", 3, -2)
        S:ReskinIcon(icon)
    end

    local bg = bu:CreateBackdrop()
    bg:SetBackdropColor(0, 0, 0, 0.25)
    bg:SetPoint("TOPLEFT", 2, -1)
    bg:SetPoint("BOTTOMRIGHT", 0, 14)
end

local function reskinRewardButton(bu)
    if not bu then return end

    bu.NameFrame:Hide()
    bu.bg = S:ReskinIcon(bu.Icon)

    bu.backdrop = nil
    local bg = bu:CreateBackdrop()
    bg:SetBackdropColor(0, 0, 0, 0.25)
    bg:SetPoint("TOPLEFT", bu.bg, "TOPRIGHT", 2, 0)
    bg:SetPoint("BOTTOMRIGHT", bu.bg, 100, 0)
    bu.textBg = bg
end

local function reskinRewardButtonWithSize(bu, isMapQuestInfo)
    reskinRewardButton(bu)
    if not bu then return end

    if isMapQuestInfo then
        bu.Icon:SetSize(29, 29)
    else
        bu.Icon:SetSize(34, 34)
    end
end

local function hookTextColorYellow(self, r, g, b)
    if r ~= 1 or g ~= 0.8 or b ~= 0 then
        self:SetTextColor(1, 0.8, 0)
    end
end

local function setTextColorYellow(font)
    if not font then return end
    font:SetShadowColor(0, 0, 0, 0)
    font:SetTextColor(1, 0.8, 0)
    hooksecurefunc(font, "SetTextColor", hookTextColorYellow)
end

local function hookTextColorWhite(self, r, g, b)
    if r ~= 1 or g ~= 1 or b ~= 1 then
        self:SetTextColor(1, 1, 1)
    end
end

local function setTextColorWhite(font)
    if not font then return end
    font:SetShadowColor(0, 0, 0)
    font:SetTextColor(1, 1, 1)
    hooksecurefunc(font, "SetTextColor", hookTextColorWhite)
end

function S:QuestInfo()
    if not C.general.skins then return end

    -- Item reward highlight
    _G.QuestInfoItemHighlight:GetRegions():Hide()
    hooksecurefunc(_G.QuestInfoItemHighlight, "SetPoint", setHighlight)
    _G.QuestInfoItemHighlight:HookScript("OnShow", setHighlight)
    _G.QuestInfoItemHighlight:HookScript("OnHide", clearHighlight)

    -- Spell objective frame
    restyleSpellButton(_G.QuestInfoSpellObjectiveFrame)

    -- Dynamic reward buttons
    hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
        local bu = rewardsFrame.RewardButtons[index]
        if bu and not bu.__styled then
            reskinRewardButtonWithSize(bu, rewardsFrame == _G.MapQuestInfoRewardsFrame)
            S:ReskinIconBorder(bu.IconBorder)

            bu.__styled = true
        end
    end)

    -- Map quest info named reward frames
    _G.MapQuestInfoRewardsFrame.XPFrame.Name:SetShadowOffset(0, 0)
    for _, name in next, { "HonorFrame", "MoneyFrame", "SkillPointFrame", "XPFrame", "ArtifactXPFrame", "TitleFrame", "WarModeBonusFrame" } do
        reskinRewardButtonWithSize(_G.MapQuestInfoRewardsFrame[name], true)
    end

    -- Quest info named reward frames
    for _, name in next, { "HonorFrame", "SkillPointFrame", "ArtifactXPFrame", "WarModeBonusFrame" } do
        reskinRewardButtonWithSize(_G.QuestInfoRewardsFrame[name])
    end

    -- Title Reward
    local titleFrame = _G.QuestInfoPlayerTitleFrame
    if titleFrame then
        local icon = titleFrame.Icon
        S:ReskinIcon(icon)
        for i = 2, 4 do
            local region = select(i, titleFrame:GetRegions())
            if region then region:Hide() end
        end
        local bg = titleFrame:CreateBackdrop()
        bg:SetBackdropColor(0, 0, 0, 0.25)
        bg:SetPoint("TOPLEFT", icon, "TOPRIGHT", 0, 2)
        bg:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 220, -1)
    end

    -- QuestInfo_Display hook: spell/follower/rep rewards
    hooksecurefunc("QuestInfo_Display", function()
        local objectivesTable = _G.QuestInfoObjectivesFrame.Objectives
        if objectivesTable then
            for i = #objectivesTable, 1, -1 do
                local object = objectivesTable[i]
                if object.hooked then break end
                object:SetTextColor(1, 1, 1)
                hooksecurefunc(object, "SetTextColor", replaceTextColor)
                object.hooked = true
            end
        end

        local rewardsFrame = _G.QuestInfoFrame.rewardsFrame
        local isQuestLog = _G.QuestInfoFrame.questLog ~= nil
        local questID = isQuestLog and C_QuestLog_GetSelectedQuest() or GetQuestID()
        local spellRewards = C_QuestInfoSystem_GetQuestRewardSpells(questID) or {}

        if #spellRewards > 0 then
            for spellHeader in rewardsFrame.spellHeaderPool:EnumerateActive() do
                spellHeader:SetVertexColor(1, 1, 1)
            end

            for reward in rewardsFrame.followerRewardPool:EnumerateActive() do
                if not reward.__styled then
                    reward.BG:Hide()
                    local bg = reward:CreateBackdrop()
                    bg:SetBackdropColor(0, 0, 0, 0.25)
                    reward.__styled = true
                end
            end

            for spellReward in rewardsFrame.spellRewardPool:EnumerateActive() do
                if not spellReward.__styled then
                    reskinRewardButton(spellReward)
                    spellReward.__styled = true
                end
            end
        end

        for repReward in rewardsFrame.reputationRewardPool:EnumerateActive() do
            if not repReward.__styled then
                reskinRewardButton(repReward)
                repReward.__styled = true
            end
        end
    end)

    -- QuestType text color
    hooksecurefunc(_G.QuestInfoQuestType, "SetTextColor", function(text, r, g, b)
        if not (r == 1 and g == 1 and b == 1) then
            text:SetTextColor(1, 1, 1)
        end
    end)

    -- Required money text color
    hooksecurefunc(_G.QuestInfoRequiredMoneyText, "SetTextColor", replaceTextColor)
    if _G.QuestInfoSpellObjectiveLearnLabel then
        hooksecurefunc(_G.QuestInfoSpellObjectiveLearnLabel, "SetTextColor", replaceTextColor)
    end

    -- Yellow headers
    local yellowish = {
        _G.QuestInfoTitleHeader,
        _G.QuestInfoDescriptionHeader,
        _G.QuestInfoObjectivesHeader,
        _G.QuestInfoRewardsFrame.Header,
        _G.QuestInfoAccountCompletedNotice,
    }
    for _, font in pairs(yellowish) do
        setTextColorYellow(font)
    end

    -- White body text
    local whitish = {
        _G.QuestInfoDescriptionText,
        _G.QuestInfoObjectivesText,
        _G.QuestInfoGroupSize,
        _G.QuestInfoRewardText,
        _G.QuestInfoTimerText,
        _G.QuestInfoRewardsFrame.ItemChooseText,
        _G.QuestInfoRewardsFrame.ItemReceiveText,
        _G.QuestInfoRewardsFrame.PlayerTitleText,
        _G.QuestInfoRewardsFrame.XPFrame.ReceiveText,
    }
    for _, font in pairs(whitish) do
        setTextColorWhite(font)
    end

    -- Seal frame text color replacement
    local replacedSealColor = {
        ["480404"] = "c20606",
        ["042c54"] = "1c86ee",
    }
    hooksecurefunc(_G.QuestInfoSealFrame.Text, "SetText", function(self, text)
        if text and text ~= "" then
            local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
            if colorStr and rawText then
                colorStr = replacedSealColor[colorStr] or "99ccff"
                self:SetFormattedText("|cff%s%s|r", colorStr, rawText)
            end
        end
    end)
end

S:AddCallback("QuestInfo")
