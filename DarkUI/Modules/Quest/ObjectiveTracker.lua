local E, C, L = select(2, ...):unpack()

if not C.quest.enable then return end

----------------------------------------------------------------------------------------
-- Style ObjectiveTrackerFrame
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local C_QuestLog_GetNumQuestWatches = C_QuestLog.GetNumQuestWatches
local C_QuestLog_GetQuestIDForQuestWatchIndex = C_QuestLog.GetQuestIDForQuestWatchIndex
local GetDifficultyColor = GetDifficultyColor
local C_PlayerInfo_GetContentDifficultyQuestForPlayer = C_PlayerInfo.GetContentDifficultyQuestForPlayer
local GetScreenWidth = GetScreenWidth
local unpack, pairs = unpack, pairs
local hooksecurefunc = hooksecurefunc
local BONUS_OBJECTIVE_TRACKER_MODULE = BONUS_OBJECTIVE_TRACKER_MODULE
local WORLD_QUEST_TRACKER_MODULE = WORLD_QUEST_TRACKER_MODULE
local DEFAULT_OBJECTIVE_TRACKER_MODULE = DEFAULT_OBJECTIVE_TRACKER_MODULE
local ACHIEVEMENT_TRACKER_MODULE = ACHIEVEMENT_TRACKER_MODULE
local QUEST_TRACKER_MODULE = QUEST_TRACKER_MODULE
local UIParent = UIParent
local GameTooltip = GameTooltip
local ObjectiveTrackerFrame = ObjectiveTrackerFrame
local ObjectiveTrackerScenarioRewardsFrame = ObjectiveTrackerScenarioRewardsFrame
local ObjectiveTrackerBonusRewardsFrame = ObjectiveTrackerBonusRewardsFrame
local ScenarioStageBlock = ScenarioStageBlock

----------------------------------------------------------------------------------------
--  Move ObjectiveTrackerFrame
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame", "ObjectiveTrackerAnchor", UIParent)
frame:SetPoint(unpack(C.quest.quest_tracker_pos))
frame:SetSize(224, 150)

ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint("TOPRIGHT", frame)
ObjectiveTrackerFrame:SetHeight(E.screenHeight * 4 / 5)

ObjectiveTrackerFrame.IsUserPlaced = function() return true end

local headers = {
    ObjectiveTrackerBlocksFrame.ScenarioHeader,
    ObjectiveTrackerBlocksFrame.CampaignQuestHeader,
    ObjectiveTrackerBlocksFrame.QuestHeader,
    ObjectiveTrackerBlocksFrame.AchievementHeader,
    BONUS_OBJECTIVE_TRACKER_MODULE.Header,
    WORLD_QUEST_TRACKER_MODULE.Header,
    ObjectiveTrackerFrame.BlocksFrame.UIWidgetsHeader
}
for i = 1, #headers do
    local header = headers[i]
    if header then
        header.Background:Hide()
    end
end

ObjectiveTrackerFrame.HeaderMenu.Title:SetAlpha(0)

----------------------------------------------------------------------------------------
--	Skin ObjectiveTrackerFrame item buttons
----------------------------------------------------------------------------------------
hooksecurefunc(QUEST_TRACKER_MODULE, "SetBlockHeader", function(_, block)
    local item = block.itemButton
    if item and not item.skinned then
        item:SetSize(26, 26)
        item:CreateTextureBorder()
        item:SetNormalTexture(nil)

        item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        item.icon:SetPoint("TOPLEFT", item, 2, -2)
        item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)

        item.Cooldown:SetAllPoints(item.icon)

        item.Count:ClearAllPoints()
        item.Count:SetPoint("TOPLEFT", 1, -1)
        item.Count:SetFont(STANDARD_TEXT_FONT, 10, THINOUTLINE)
        item.Count:SetShadowOffset(1, -1)

        item.HotKey:SetFontObject(NumberFont_OutlineThick_Mono_Small)
        
        item.skinned = true
    end
end)

hooksecurefunc(WORLD_QUEST_TRACKER_MODULE, "AddObjective", function(_, block)
    local item = block.itemButton
    if item and not item.skinned then
        item:SetSize(26, 26)
        item:CreateTextureBorder()

        item.skinned = true
    end
end)

hooksecurefunc("QuestObjectiveSetupBlockButton_AddRightButton", function(block, button)
    if button and button.GetPoint then
        local a, b, c, d, e = button:GetPoint()
        if block.groupFinderButton and b == block.groupFinderButton and block.itemButton and button == block.itemButton then
            button:SetPoint(a, b, c, d - 1, e)
        end
    end
end)

hooksecurefunc("QuestObjectiveSetupBlockButton_FindGroup", function(block)
    if block.hasGroupFinderButton and block.groupFinderButton and not block.groupFinderButton.styled then
        block.groupFinderButton:SetSize(21, 21)
        block.groupFinderButton:CreateTextureBorder()
        block.groupFinderButton.styled = true
    end
end)

----------------------------------------------------------------------------------------
--  Difficulty color for ObjectiveTrackerFrame lines
----------------------------------------------------------------------------------------
hooksecurefunc(QUEST_TRACKER_MODULE, "Update", function()
    for i = 1, C_QuestLog_GetNumQuestWatches() do
        local questID = C_QuestLog_GetQuestIDForQuestWatchIndex(i)
        if not questID then
            break
        end
    local col = GetDifficultyColor(C_PlayerInfo_GetContentDifficultyQuestForPlayer(questID))
        local block = QUEST_TRACKER_MODULE:GetExistingBlock(questID)
        if block then
            block.HeaderText:SetTextColor(col.r, col.g, col.b)
            block.HeaderText.col = col
        end
    end
end)

hooksecurefunc(DEFAULT_OBJECTIVE_TRACKER_MODULE, "AddObjective", function(_, block)
    if block.module == ACHIEVEMENT_TRACKER_MODULE then
        block.HeaderText:SetTextColor(0.75, 0.61, 0)
        block.HeaderText.col = nil
    end
end)

hooksecurefunc("ObjectiveTrackerBlockHeader_OnLeave", function(self)
    local block = self:GetParent()
    if block.HeaderText.col then
        block.HeaderText:SetTextColor(block.HeaderText.col.r, block.HeaderText.col.g, block.HeaderText.col.b)
    end
end)

----------------------------------------------------------------------------------------
--	Set tooltip depending on position
----------------------------------------------------------------------------------------
local function IsFramePositionedLeft(f)
    local x = f:GetCenter()
    local screenWidth = GetScreenWidth()
    local positionedLeft = false

    if x and x < (screenWidth / 2) then
        positionedLeft = true
    end

    return positionedLeft
end

hooksecurefunc("BonusObjectiveTracker_ShowRewardsTooltip", function(block)
    if IsFramePositionedLeft(ObjectiveTrackerFrame) then
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 0, 0)
    end
end)

ScenarioStageBlock:HookScript("OnEnter", function(self)
    if IsFramePositionedLeft(ObjectiveTrackerFrame) then
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 50, -3)
    end
end)

do
    if IsFramePositionedLeft(ObjectiveTrackerFrame) then
        local list = ScenarioBlocksFrame.MawBuffsBlock.Container.List
        if list then
            list:ClearAllPoints()
            list:SetPoint("TOPLEFT", ScenarioBlocksFrame.MawBuffsBlock.Container, "TOPRIGHT", 15, 0)
        end
    end
end
----------------------------------------------------------------------------------------
--	Kill reward animation when finished dungeon or bonus objectives
----------------------------------------------------------------------------------------
ObjectiveTrackerScenarioRewardsFrame.Show = E.dummy

hooksecurefunc("BonusObjectiveTracker_AnimateReward", function()
    ObjectiveTrackerBonusRewardsFrame:ClearAllPoints()
    ObjectiveTrackerBonusRewardsFrame:SetPoint("BOTTOM", UIParent, "TOP", 0, 90)
end)

----------------------------------------------------------------------------------------
--	Skin ScenarioStageBlock
----------------------------------------------------------------------------------------
-- local StageBlock = _G["ScenarioStageBlock"]
-- StageBlock:CreateBackdrop("Blur")
-- StageBlock.backdrop:SetPoint("TOPLEFT", ScenarioStageBlock.NormalBG, 3, -3)
-- StageBlock.backdrop:SetPoint("BOTTOMRIGHT", ScenarioStageBlock.NormalBG, -3, 3)

-- StageBlock.NormalBG:SetAlpha(0)
-- StageBlock.FinalBG:SetAlpha(0)
-- StageBlock.GlowTexture:SetTexture("")

----------------------------------------------------------------------------------------
--	Ctrl+Click to abandon a quest or Alt+Click to share a quest(by Suicidal Katt)
----------------------------------------------------------------------------------------
hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self)
    if IsControlKeyDown() then
        CloseDropDownMenus()
        QuestMapQuestOptions_AbandonQuest(self.questID)
    elseif IsAltKeyDown() and C_QuestLog.IsPushableQuest(self.questID) then
        CloseDropDownMenus()
        QuestMapQuestOptions_ShareQuest(self.questID)
    end
end)
hooksecurefunc(QUEST_TRACKER_MODULE, "OnBlockHeaderClick", function(_, block)
    if IsControlKeyDown() then
        CloseDropDownMenus()
        QuestMapQuestOptions_AbandonQuest(block.id)
    elseif IsAltKeyDown() and C_QuestLog.IsPushableQuest(block.id) then
        CloseDropDownMenus()
        QuestMapQuestOptions_ShareQuest(block.id)
    end
end)