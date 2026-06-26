local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Objective Tracker
------------------------------------------------------------------------

local module = E:Module("Quest"):Sub("ObjectiveTracker")
E:Module("Quest"):SetConfigKey("quest")

local cfg = C.quest

local function getTrackerPos()
    local pos = { unpack(cfg.tracker_pos) }
    local bars = C.actionbar and C.actionbar.bars
    if bars then
        for i = 4, 6 do
            if bars["bar" .. i] and bars["bar" .. i].enable then pos[4] = pos[4] - 30 end
        end
    end
    return pos
end

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

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

local function isFramePositionedLeft(frame)
    local x = frame:GetCenter()
    local screenWidth = GetScreenWidth()
    return x and x < (screenWidth / 2)
end

------------------------------------------------------------------------
-- Difficulty Color
------------------------------------------------------------------------

local function colorQuestHeaders()
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if not questID then break end
        local block = QuestObjectiveTracker:GetExistingBlock(questID)
        if block then
            local col = GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID))
            block.HeaderText:SetTextColor(col.r, col.g, col.b)
            block.HeaderText.col = col
        end
    end
end

local function colorBlock(_, block)
    C_Timer.After(0.01, function()
        local poi = block.poiButton
        if poi then
            poi:SetScale(0.85)
            poi:SetPoint("TOP")
            if poi.Glow and poi.Glow:IsShown() then
                poi:SetAlpha(1)
            else
                poi:SetAlpha(0.7)
            end
            local style = poi:GetStyle()
            if style == POIButtonUtil.Style.WorldQuest then
                local questID = poi:GetQuestID()
                local info = C_QuestLog.GetQuestTagInfo(questID)
                if info then
                    local col = { r = 1, g = 1, b = 1 }
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

------------------------------------------------------------------------
-- Quest Item Button Skin
------------------------------------------------------------------------

local function hotkeyShow(self)
    local item = self:GetParent()
    if item.rangeOverlay then item.rangeOverlay:Show() end
end

local function hotkeyHide(self)
    local item = self:GetParent()
    if item.rangeOverlay then item.rangeOverlay:Hide() end
end

local function hotkeyColor(self, r)
    local item = self:GetParent()
    if item.rangeOverlay then
        if r == 1 then
            item.rangeOverlay:Show()
        else
            item.rangeOverlay:Hide()
        end
    end
end

local function skinQuestIcons(_, block)
    local item = block and block.ItemButton
    if item and not item.skinned then
        item:SetSize(25, 25)
        item:SetTemplate("Default")
        item:SetNormalTexture(0)
        E:StyleIconButton(item)

        item.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        item.icon:SetPoint("TOPLEFT", item, 2, -2)
        item.icon:SetPoint("BOTTOMRIGHT", item, -2, 2)

        item.Cooldown:SetAllPoints(item.icon)

        item.Count:ClearAllPoints()
        item.Count:SetPoint("TOPLEFT", 1, -1)
        item.Count:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        item.Count:SetShadowOffset(1, -1)

        local rangeOverlay = item:CreateTexture(nil, "OVERLAY")
        rangeOverlay:SetTexture(C.media.texture.blank)
        rangeOverlay:SetInside()
        rangeOverlay:SetVertexColor(1, 0.3, 0.1, 0.6)
        item.rangeOverlay = rangeOverlay

        hooksecurefunc(item.HotKey, "Show", hotkeyShow)
        hooksecurefunc(item.HotKey, "Hide", hotkeyHide)
        hooksecurefunc(item.HotKey, "SetVertexColor", hotkeyColor)
        hotkeyColor(item.HotKey, item.HotKey:GetTextColor())
        item.HotKey:SetAlpha(0)

        item.skinned = true
    end

    local finder = block and block.rightEdgeFrame
    if finder and not finder.skinned then
        finder:SetSize(26, 26)
        finder:SetNormalTexture(0)
        finder:SetHighlightTexture(0)
        finder:SetPushedTexture(0)

        finder.bg = CreateFrame("Frame", nil, finder, "BackdropTemplate")
        finder.bg:SetTemplate("Fill")
        finder.bg:SetPoint("TOPLEFT", finder, 2, -2)
        finder.bg:SetPoint("BOTTOMRIGHT", finder, -2, 2)
        finder.bg:SetFrameLevel(1)

        finder:HookScript("OnEnter", function(self)
            if self:IsEnabled() then self.bg:SetBackdropBorderColor(E.myColor.r, E.myColor.g, E.myColor.b) end
        end)
        finder:HookScript("OnLeave", function(self) self.bg:SetBackdropBorderColor(unpack(C.media.border_color)) end)

        hooksecurefunc(finder, "Show", function(self) self.bg:SetFrameLevel(1) end)

        finder.skinned = true
    end
end

------------------------------------------------------------------------
-- Progress Bar Skin
------------------------------------------------------------------------

local function skinProgressBar(tracker, key)
    local progressBar = tracker.usedProgressBars[key]
    local bar = progressBar and progressBar.Bar
    local label = bar and bar.Label
    local icon = bar and bar.Icon

    if not progressBar.styled then
        bar:StripTextures()
        bar:SetSize(200, 16)
        bar:SetStatusBarTexture(C.media.texture.status)
        bar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
        bar:CreateBackdrop("transparent")
        bar:CreateBorder("thin")

        label:ClearAllPoints()
        label:SetPoint("CENTER", 0, -1)
        label:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        label:SetDrawLayer("OVERLAY")

        if icon then
            icon:SetPoint("RIGHT", 26, 0)
            icon:SetSize(20, 20)
            icon:SetMask("")

            local border = CreateFrame("Frame", nil, bar, "BackdropTemplate")
            border:SetAllPoints(icon)
            border:SetTemplate("Default")
            bar.newIconBg = border

            if bar.AnimIn and bar.AnimIn.Play then hooksecurefunc(bar.AnimIn, "Play", function() bar.AnimIn:Stop() end) end
        end

        progressBar.styled = true
    end

    if bar.newIconBg then bar.newIconBg:SetShown(icon:IsShown()) end
end

------------------------------------------------------------------------
-- Timer Bar Skin
------------------------------------------------------------------------

local function skinTimerBar(tracker, key)
    local timerBar = tracker.usedTimerBars[key]
    local bar = timerBar and timerBar.Bar

    if not timerBar.styled then
        if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
        if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
        if bar.BorderMid then bar.BorderMid:SetAlpha(0) end

        bar:SetStatusBarTexture(C.media.texture.status)
        bar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
        bar:CreateBackdrop("transparent")
        bar:CreateBorder("thin")

        timerBar.styled = true
    end
end

------------------------------------------------------------------------
-- Ctrl+Click Abandon / Alt+Click Share
------------------------------------------------------------------------

local function onBlockClick(questID)
    if IsControlKeyDown() then
        Menu.GetManager():HandleESC()
        QuestMapQuestOptions_AbandonQuest(questID)
    elseif IsAltKeyDown() and C_QuestLog.IsPushableQuest(questID) then
        Menu.GetManager():HandleESC()
        QuestMapQuestOptions_ShareQuest(questID)
    end
end

------------------------------------------------------------------------
-- Dungeon Stage Block Skin
------------------------------------------------------------------------

local function skinStageBlock(block)
    if not block.backdrop then
        block:CreateBackdrop("transparent")
        block.__backdrop:SetBackdropEdge("thin")

        block.NormalBG:SetAlpha(0)
        block.FinalBG:SetAlpha(0)
        block.GlowTexture:SetTexture("")
    end
end

local function skinStageWidgets(self)
    local widgetContainer = self.WidgetContainer
    if widgetContainer.widgetFrames then
        for _, widgetFrame in pairs(widgetContainer.widgetFrames) do
            if widgetFrame.Frame then widgetFrame.Frame:SetAlpha(0) end

            local bar = widgetFrame.TimerBar
            if bar and not bar.styled then
                bar:SetStatusBarTexture(C.media.texture.status)
                bar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
                bar:CreateBackdrop("transparent")
                bar:CreateBorder("thin")
                bar:SetFrameLevel(bar:GetFrameLevel() + 3)
                bar.styled = true
            end

            if widgetFrame.CurrencyContainer then
                for currencyFrame in widgetFrame.currencyPool:EnumerateActive() do
                    if not currencyFrame.styled then
                        currencyFrame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                        currencyFrame.Icon:CreateBackdrop()
                        currencyFrame.styled = true
                    end
                end
            end
        end
    end
end

------------------------------------------------------------------------
-- Mythic+ Block Skin
------------------------------------------------------------------------

local function skinChallengeBlock(block)
    if not block.__styled then
        block:CreateBackdrop("transparent")
        block.__backdrop:SetBackdropEdge("thin")
        block.__backdrop:SetPoint("TOPLEFT", block, 3, -3)
        block.__backdrop:SetPoint("BOTTOMRIGHT", block, -6, 3)
        block.__backdrop.__overlay:SetVertexColor(0.12, 0.12, 0.12, 1)

        local bg = select(3, block:GetRegions())
        if bg then bg:SetAlpha(0) end

        block.TimerBGBack:SetAlpha(0)
        block.TimerBG:SetAlpha(0)

        block.StatusBar:SetStatusBarTexture(C.media.texture.status)
        block.StatusBar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
        block.StatusBar:CreateBackdrop("transparent")
        block.StatusBar.__backdrop:SetBackdropEdge("thin")
        block.StatusBar.__backdrop:SetFrameLevel(block.__backdrop:GetFrameLevel() + 1)
        block.StatusBar:SetStatusBarColor(0, 0.6, 1)
        block.StatusBar:SetFrameLevel(block.StatusBar:GetFrameLevel() + 3)

        block.__styled = true
    end
end

local function skinAffixes(self)
    for frame in self.affixPool:EnumerateActive() do
        frame.Border:SetTexture(nil)
        if not frame.styled then
            frame.Portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            frame.Portrait:CreateBackdrop()
            frame.styled = true
        end

        if frame.info then
            frame.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[frame.info.key].texture)
        elseif frame.affixID then
            local _, _, filedataid = C_ChallengeMode.GetAffixInfo(frame.affixID)
            frame.Portrait:SetTexture(filedataid)
        end
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end

    -- Anchor
    local anchor = CreateFrame("Frame", "DarkUI_ObjectiveTrackerAnchor", UIParent)
    anchor:SetPoint(unpack(getTrackerPos()))
    anchor:SetSize(1, 1)

    ObjectiveTrackerFrame:SetClampedToScreen(true)
    ObjectiveTrackerFrame:ClearAllPoints()
    ObjectiveTrackerFrame:SetPoint("TOPRIGHT", anchor, "TOPRIGHT")
    ObjectiveTrackerFrame.IsUserPlaced = function() return true end
    ObjectiveTrackerFrame.ignoreFramePositionManager = true
    ObjectiveTrackerFrame.ignoreFrameLayout = true

    hooksecurefunc(ObjectiveTrackerFrame, "SetPoint", function(_, _, parent)
        if parent ~= anchor then
            ObjectiveTrackerFrame:ClearAllPoints()
            ObjectiveTrackerFrame:SetPoint("TOPRIGHT", anchor, "TOPRIGHT")
        end
    end)

    hooksecurefunc(ObjectiveTrackerFrame, "SetHeight", function(_, height)
        if height ~= cfg.tracker_height then ObjectiveTrackerFrame:SetHeight(cfg.tracker_height) end
    end)

    ObjectiveTrackerFrame.Header.Background:SetTexture(nil)

    -- Minimize button
    local button = ObjectiveTrackerFrame.Header.MinimizeButton
    button:SetSize(17, 17)
    button:StripTextures()
    E:StyleIconButton(button)

    button.minus = button:CreateTexture(nil, "OVERLAY")
    button.minus:SetSize(7, 1)
    button.minus:SetPoint("CENTER")
    button.minus:SetTexture(C.media.texture.blank)

    button.plus = button:CreateTexture(nil, "OVERLAY")
    button.plus:SetSize(1, 7)
    button.plus:SetPoint("CENTER")
    button.plus:SetTexture(C.media.texture.blank)
    button.plus:Hide()

    hooksecurefunc(ObjectiveTrackerFrame, "SetCollapsed", function(_, collapsed)
        if collapsed then
            button.plus:Show()
        else
            button.plus:Hide()
        end
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
    end)

    -- Difficulty coloring
    hooksecurefunc(QuestObjectiveTracker, "Update", colorQuestHeaders)

    -- Ctrl+Click in quest map
    hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self) onBlockClick(self.questID) end)

    -- Hook all tracker headers
    for i = 1, #headers do
        local header = headers[i].Header
        if header then header.Background:SetTexture(nil) end

        local tracker = headers[i]
        if tracker then
            hooksecurefunc(tracker, "AddBlock", skinQuestIcons)
            hooksecurefunc(tracker, "GetProgressBar", skinProgressBar)
            hooksecurefunc(tracker, "GetTimerBar", skinTimerBar)
            hooksecurefunc(tracker, "OnBlockHeaderClick", function(_, block) onBlockClick(block.id) end)

            hooksecurefunc(tracker, "OnBlockHeaderEnter", function(_, block)
                if isFramePositionedLeft(ObjectiveTrackerFrame) then
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

            hooksecurefunc(tracker, "AddBlock", colorBlock)
        end
    end

    -- Dungeon stage block
    hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", skinStageBlock)
    hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateWidgetRegistration", skinStageWidgets)

    ScenarioObjectiveTracker.StageBlock:HookScript("OnEnter", function(self)
        if isFramePositionedLeft(ObjectiveTrackerFrame) then
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 50, -3)
        end
    end)

    -- Mythic+ block
    hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "Activate", skinChallengeBlock)
    hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "SetUpAffixes", skinAffixes)
end
