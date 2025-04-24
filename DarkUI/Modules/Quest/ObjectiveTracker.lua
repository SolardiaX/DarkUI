local E, C, L = select(2, ...):unpack()

if not C.quest.enable then return end

local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

local headers = {
    ScenarioObjectiveTracker,
    BonusObjectiveTracker,
    UIWidgetObjectiveTracker,
    CampaignQuestObjectiveTracker,
    QuestObjectiveTracker,
    AdventureObjectiveTracker,
    AchievementObjectiveTracker,
    MonthlyActivitiesObjectiveTracker,
    ProfessionsRecipeTracker,
    WorldQuestObjectiveTracker,
}

----------------------------------------------------------------------------------------
--    Move ObjectiveTrackerFrame and hide background
----------------------------------------------------------------------------------------
local anchor = CreateFrame("Frame", "DarkUI_ObjectiveTrackerAnchor", UIParent)
anchor:SetPoint(unpack(C.quest.quest_tracker_pos))
anchor:SetSize(224, 150)

ObjectiveTrackerFrame:SetClampedToScreen(true)
ObjectiveTrackerFrame:ClearAllPoints()
ObjectiveTrackerFrame:SetPoint("TOP", anchor, "TOP")
ObjectiveTrackerFrame.IsUserPlaced = function() return true end
ObjectiveTrackerFrame.ignoreFramePositionManager = true
ObjectiveTrackerFrame.ignoreFrameLayout = true

hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
    if parent ~= anchor then
        ObjectiveTrackerFrame:ClearAllPoints()
        ObjectiveTrackerFrame:SetPoint("TOP", anchor, "TOP")
    end
end)

ObjectiveTrackerFrame.Header.Background:SetTexture(nil)

----------------------------------------------------------------------------------------
--    Skin ObjectiveTrackerFrame.HeaderMenu.MinimizeButton
----------------------------------------------------------------------------------------
local button = ObjectiveTrackerFrame.Header.MinimizeButton
button:SetSize(17, 17)
button:StripTextures()

E:StyleButton(button)

button.minus = button:CreateTexture(nil, "OVERLAY")
button.minus:SetSize(7, 1)
button.minus:SetPoint("CENTER")
button.minus:SetTexture(C.media.texture.blank)

button.plus = button:CreateTexture(nil, "OVERLAY")
button.plus:SetSize(1, 7)
button.plus:SetPoint("CENTER")
button.plus:SetTexture(C.media.texture.blank)

button.plus:Hide()

hooksecurefunc(ObjectiveTrackerFrame, "SetCollapsed", function(self, collapsed)
    if collapsed then
        button.plus:Show()
    else
        button.plus:Hide()
    end
    
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
end)

----------------------------------------------------------------------------------------
--    Difficulty color for quest headers
----------------------------------------------------------------------------------------
hooksecurefunc(QuestObjectiveTracker, "Update", function()
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if not questID then
            break
        end
        local block = QuestObjectiveTracker:GetExistingBlock(questID)
        if block then
            local col = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID))
            block.HeaderText:SetTextColor(col.r, col.g, col.b)
            block.HeaderText.col = col
        end
    end
end)

local function colorQuest(_, block)
    C_Timer.After(0.01, function()
        local poi = block.poiButton
        if poi then
            poi:SetScale(0.85)
            poi:SetPoint("TOP")
            if poi.Glow and poi.Glow:IsShown() then -- quest is selected
                poi:SetAlpha(1)
            else
                poi:SetAlpha(0.7)
            end
            local style = poi:GetStyle()
            if style == POIButtonUtil.Style.WorldQuest then
                local questID = poi:GetQuestID()
                local info = C_QuestLog.GetQuestTagInfo(questID)
                if info then
                    local col = {r = 1, g = 1, b = 1}
                    if info.quality == Enum.WorldQuestQuality.Epic then
                        col = BAG_ITEM_QUALITY_COLORS[4]
                    elseif info.quality == Enum.WorldQuestQuality.Rare then
                        col = BAG_ITEM_QUALITY_COLORS[3]
                    end
                    block.HeaderText:SetTextColor(col.r, col.g, col.b)
                    block.HeaderText.col = col
                end
            end
        end
    end)
end

----------------------------------------------------------------------------------------
--    Skin quest item buttons
----------------------------------------------------------------------------------------
local function HotkeyShow(self)
    local item = self:GetParent()
    if item.rangeOverlay then item.rangeOverlay:Show() end
end

local function HotkeyHide(self)
    local item = self:GetParent()
    if item.rangeOverlay then item.rangeOverlay:Hide() end
end

local function HotkeyColor(self, r)
    local item = self:GetParent()
    if item.rangeOverlay then
        if r == 1 then
            item.rangeOverlay:Show()
        else
            item.rangeOverlay:Hide()
        end
    end
end

local function SkinQuestIcons(_, block)
    local item = block and block.ItemButton

    if item and not item.skinned then
        item:SetSize(25, 25)
        item:SetTemplate("Default")
        item:SetNormalTexture(0)

        E:StyleButton(item)

        item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        item.icon:SetPoint("TOPLEFT", item, 2, -2)
        item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)

        item.Cooldown:SetAllPoints(item.icon)

        item.Count:ClearAllPoints()
        item.Count:SetPoint("TOPLEFT", 1, -1)
        item.Count:SetFont(STANDARD_TEXT_FONT, 10, THINOUTLINE)
        item.Count:SetShadowOffset(1, -1)

        local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
        rangeOverlay:SetTexture(C.media.texture.blank)
        rangeOverlay:SetInside()
        rangeOverlay:SetVertexColor(1, 0.3, 0.1, 0.6)
        item.rangeOverlay = rangeOverlay

        hooksecurefunc(item.HotKey, "Show", HotkeyShow)
        hooksecurefunc(item.HotKey, "Hide", HotkeyHide)
        hooksecurefunc(item.HotKey, "SetVertexColor", HotkeyColor)
        HotkeyColor(item.HotKey, item.HotKey:GetTextColor())
        item.HotKey:SetAlpha(0)

        item.skinned = true
    end

    local finder = block and block.rightEdgeFrame
    if finder and not finder.skinned then
        finder:SetSize(26, 26)
        finder:SetNormalTexture(0)
        finder:SetHighlightTexture(0)
        finder:SetPushedTexture(0)
        
        E:ApplyOverlayBorder(finder)

        finder.bg = CreateFrame("Frame", nil, finder)
        finder.bg:SetTemplate("Overlay")
        finder.bg:SetPoint("TOPLEFT", finder, "TOPLEFT", 2, -2)
        finder.bg:SetPoint("BOTTOMRIGHT", finder, "BOTTOMRIGHT", -2, 2)
        finder.bg:SetFrameLevel(1)

        finder:HookScript("OnEnter", function(self)
            if self:IsEnabled() then
                self.bg:SetBackdropBorderColor(unpack(C.media.highlight_color))
                if self.bg.overlay then
                    self.bg.overlay:SetVertexColor(C.media.highlight_color[1] * 0.3, C.media.highlight_color[2] * 0.3, C.media.highlight_color[3] * 0.3, 1)
                end
            end
        end)

        finder:HookScript("OnLeave", function(self)
            self.bg:SetBackdropBorderColor(unpack(C.media.border_color))
            if self.bg.overlay then
                self.bg.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
            end
        end)

        hooksecurefunc(finder, "Show", function(self)
            self.bg:SetFrameLevel(1)
        end)

        finder.skinned = true
    end
end

-- WorldQuestsList button skin
-- local frame = CreateFrame("Frame")
-- frame:RegisterEvent("PLAYER_LOGIN")
-- frame:SetScript("OnEvent", function()
--     if not C_AddOns.IsAddOnLoaded("WorldQuestsList") then return end

--     local orig = _G.WorldQuestList.ObjectiveTracker_Update_hook
--     local function orig_hook(...)
--         orig(...)
--         for _, b in pairs(WorldQuestList.LFG_objectiveTrackerButtons) do
--             if b and not b.skinned then
--                 b:SetSize(20, 20)
--                 b.texture:SetAtlas("socialqueuing-icon-eye")
--                 b.texture:SetSize(12, 12)
--                 b:SetHighlightTexture(0)

--                 local point, anchor, point2, x, y = b:GetPoint()
--                 if x == -18 then
--                     b:SetPoint(point, anchor, point2, -13, y)
--                 end

--                 E:ApplyOverlayBorder(b)

--                 b.skinned = true
--             end
--         end
--     end
--     _G.WorldQuestList.ObjectiveTracker_Update_hook = orig_hook
-- end)

-- ----------------------------------------------------------------------------------------
-- --    Skin quest objective progress bar
-- ----------------------------------------------------------------------------------------
local function SkinProgressBar(tracker, key)
    local progressBar = tracker.usedProgressBars[key]
    local bar = progressBar and progressBar.Bar
    local label = bar and bar.Label
    local icon = bar and bar.Icon

    if not progressBar.styled then
        if bar.BarFrame then bar.BarFrame:Hide() end
        if bar.BarFrame2 then bar.BarFrame2:Hide() end
        if bar.BarFrame3 then bar.BarFrame3:Hide() end
        if bar.BarGlow then bar.BarGlow:Hide() end
        if bar.Sheen then bar.Sheen:Hide() end
        if bar.IconBG then bar.IconBG:SetAlpha(0) end
        if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
        if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
        if bar.BorderMid then bar.BorderMid:SetAlpha(0) end
        if progressBar.PlayFlareAnim then progressBar.PlayFlareAnim  = E.Dummy end -- hide animation

        bar:SetSize(200, 16)
        bar:SetStatusBarTexture(C.media.texture.status)
        bar:CreateBackdrop("Transparent")

        -- local border = bar:CreateTexture(nil, "BORDER")
        -- border:SetPoint("CENTER", bar, "CENTER", 0, 0)
        -- border:SetTexture(bar_border)
        -- border:SetSize(256 * bar:GetWidth() / 198, 64 * bar:GetHeight() / 12)

        -- bar.border = border
        bar:CreateBorder()

        label:ClearAllPoints()
        label:SetPoint("CENTER", 0, -1)
        label:SetFont(STANDARD_TEXT_FONT, 10, THINOUTLINE)
        label:SetDrawLayer("OVERLAY")

        if icon then
            icon:SetPoint("RIGHT", 26, 0)
            icon:SetSize(20, 20)
            icon:SetMask("")

            local border = CreateFrame("Frame", "$parentIconBorder", bar)
            border:SetAllPoints(icon)
            -- border:SetTemplate("Transparent")
            -- border:SetBackdropColor(0, 0, 0, 0)
            bar.newIconBg = border
            E:ApplyOverlayBorder(border)

            hooksecurefunc(bar.AnimIn, "Play", function()
                bar.AnimIn:Stop()
            end)
        end

        progressBar.styled = true
    end

    if bar.newIconBg then bar.newIconBg:SetShown(icon:IsShown()) end
end

-- ----------------------------------------------------------------------------------------
-- --    Skin Timer bar
-- ----------------------------------------------------------------------------------------
local function SkinTimer(tracker, key)
    local timerBar = tracker.usedTimerBars[key]
    local bar = timerBar and timerBar.Bar

    if not timerBar.styled then
        if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
        if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
        if bar.BorderMid then bar.BorderMid:SetAlpha(0) end

        bar:SetStatusBarTexture(C.media.texture.status)
        bar:CreateBackdrop("Transparent")
        
        local border = bar:CreateTexture(nil, "BORDER")
        border:SetPoint("CENTER")
        border:SetTexture(bar_border)
        border:SetSize(256 * bar:GetWidth() / 198, 64 * bar:GetHeight() / 12)

        bar.border = border
        
        timerBar.styled = true
    end
end

-- ----------------------------------------------------------------------------------------
-- --    Ctrl+Click to abandon a quest or Alt+Click to share a quest(by Suicidal Katt)
-- ----------------------------------------------------------------------------------------
local function onClick(questID)
    if IsControlKeyDown() then
        Menu.GetManager():HandleESC()
        QuestMapQuestOptions_AbandonQuest(questID)
    elseif IsAltKeyDown() and C_QuestLog.IsPushableQuest(questID) then
        Menu.GetManager():HandleESC()
        QuestMapQuestOptions_ShareQuest(questID)
    end
end

hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self) onClick(self.questID) end)

----------------------------------------------------------------------------------------
--    Skin and hook all trackers
----------------------------------------------------------------------------------------
local IsFramePositionedLeft = function(frame)
    local x = frame:GetCenter()
    local screenWidth = GetScreenWidth()
    local positionedLeft = false

    if x and x < (screenWidth / 2) then
        positionedLeft = true
    end

    return positionedLeft
end

for i = 1, #headers do
    local header = headers[i].Header
    if header then
        header.Background:SetTexture(nil)
    end

    local tracker = headers[i]
    if tracker then
        hooksecurefunc(tracker, "AddBlock", SkinQuestIcons)
        hooksecurefunc(tracker, "GetProgressBar", SkinProgressBar)
        hooksecurefunc(tracker, "GetTimerBar", SkinTimer)

        hooksecurefunc(tracker, "OnBlockHeaderClick", function(_, block) onClick(block.id) end)

        hooksecurefunc(tracker, "OnBlockHeaderEnter", function(_, block)
            if IsFramePositionedLeft(ObjectiveTrackerFrame) then
                GameTooltip:ClearAllPoints()
                GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 0, 0)
                GameTooltip:Show()
            end
        end)

        hooksecurefunc(tracker, "OnBlockHeaderLeave", function(_, block)
            if block.HeaderText and block.HeaderText.col then
                block.HeaderText:SetTextColor(block.HeaderText.col.r, block.HeaderText.col.g, block.HeaderText.col.b)
            end
        end)
        hooksecurefunc(tracker, "AddBlock", colorQuest)
    end
end

----------------------------------------------------------------------------------------
--    Skin Dungeon block
----------------------------------------------------------------------------------------
-- hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", function(block)
--     if not block.backdrop then
--         -- block:CreateBackdrop("Overlay")
--         -- block.backdrop:SetPoint("TOPLEFT", block.NormalBG, 6, -8)
--         -- block.backdrop:SetPoint("BOTTOMRIGHT", block.NormalBG, -6, 8)

--         block:CreateBorder()
--         block.border:SetPoint("TOPLEFT", block.NormalBG, 9, -6)
--         block.border:SetPoint("BOTTOMRIGHT", block.NormalBG, -9, 6)

--         -- block.NormalBG:SetAlpha(0)
--         -- block.FinalBG:SetAlpha(0)
--         -- block.GlowTexture:SetTexture("")
--     end
-- end)

hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateWidgetRegistration", function(self)
    local widgetContainer = self.WidgetContainer
    if widgetContainer.widgetFrames then
        for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
            -- if widgetFrame.Frame then widgetFrame.Frame:SetAlpha(0) end

            local bar = widgetFrame.TimerBar
            if bar and not bar.styled then
                local border = bar:CreateTexture(nil, "BORDER")
                border:SetPoint("CENTER")
                border:SetTexture(bar_border)
                border:SetSize(256 * bar:GetWidth() / 198, 64 * bar:GetHeight() / 12)

                bar.border = border

                bar:SetStatusBarTexture(C.media.texture.status)
                bar:CreateBackdrop("Overlay")
                bar:SetStatusBarColor(0, 0.6, 1)
                bar:SetFrameLevel(bar:GetFrameLevel() + 3)
                bar.styled = true
            end

            if widgetFrame.CurrencyContainer then
                for currencyFrame in widgetFrame.currencyPool:EnumerateActive() do
                    if not currencyFrame.styled then
                        E:SkinIcon(currencyFrame.Icon)
                        currencyFrame.styled = true
                    end
                end
            end
        end
    end
end)

-- ScenarioObjectiveTracker.StageBlock:HookScript("OnEnter", function(self)
--     if IsFramePositionedLeft(ObjectiveTrackerFrame) then
--         GameTooltip:ClearAllPoints()
--         GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 50, -3)
--     end
-- end)

-- ----------------------------------------------------------------------------------------
-- --    Skin Mythic+ block
-- ----------------------------------------------------------------------------------------
-- hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "Activate", function(block)
--     if not block.backdrop then
--         block:CreateBackdrop("Overlay")
--         block.backdrop:SetPoint("TOPLEFT", block, 3, -3)
--         block.backdrop:SetPoint("BOTTOMRIGHT", block, -6, 3)
--         block.backdrop.overlay:SetVertexColor(0.12, 0.12, 0.12, 1)

--         local bg = select(3, block:GetRegions())
--         bg:SetAlpha(0)

--         block.TimerBGBack:SetAlpha(0)
--         block.TimerBG:SetAlpha(0)

--         block.StatusBar:SetStatusBarTexture(C.media.texture.status)
--         block.StatusBar:CreateBackdrop("Overlay")
--         block.StatusBar.backdrop:SetFrameLevel(block.backdrop:GetFrameLevel() + 1)
--         block.StatusBar:SetStatusBarColor(0, 0.6, 1)
--         block.StatusBar:SetFrameLevel(block.StatusBar:GetFrameLevel() + 3)
--     end
-- end)

-- hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "SetUpAffixes", function(self)
--     for frame in self.affixPool:EnumerateActive() do
--         frame.Border:SetTexture(nil)
--         frame.Portrait:SetTexture(nil)
--         if not frame.styled then
--             E:ApplyOverlayBorder(frame)
--             frame.styled = true
--         end

--         if frame.info then
--             frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
--         elseif frame.affixID then
--             local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
--             frame.Portrait:SetTexture(filedataid)
--         end
--     end
-- end)

-- ----------------------------------------------------------------------------------------
-- --    Skin Torghast ablities
-- ----------------------------------------------------------------------------------------
-- local Maw = ScenarioObjectiveTracker.MawBuffsBlock.Container
-- Maw:SetPoint("TOPRIGHT", ScenarioObjectiveTracker.MawBuffsBlock, "TOPRIGHT", -23, 0)
-- Maw.List.button:SetSize(234, 30)
-- Maw.List:StripTextures()

-- E:StyleButton(Maw)

-- Maw.List:HookScript("OnShow", function(self)
--     self.button:SetPushedTexture(0)
--     self.button:SetHighlightTexture(0)
--     self.button:SetWidth(234)
--     self.button:SetButtonState("NORMAL")
--     self.button:SetPushedTextOffset(0, 0)
--     self.button:SetButtonState("PUSHED", true)
-- end)

-- Maw.List:HookScript("OnHide", function(self)
--     self.button:SetPushedTexture(0)
--     self.button:SetHighlightTexture(0)
--     self.button:SetWidth(234)
-- end)

-- Maw:HookScript("OnClick", function(container)
--     container.List:ClearAllPoints()
--     if IsFramePositionedLeft(ObjectiveTrackerFrame) then
--         container.List:SetPoint("TOPLEFT", container, "TOPRIGHT", 30, 1)
--     else
--         container.List:SetPoint("TOPRIGHT", container, "TOPLEFT", -15, 1)
--     end
-- end)