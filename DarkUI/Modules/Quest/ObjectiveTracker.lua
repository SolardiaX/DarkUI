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
-- Skin State
------------------------------------------------------------------------

-- Never write custom keys onto Blizzard-owned frames: the tracker iterates
-- its own tables with pairs() (usedBlocks, pools) where stray keys become
-- fake entries, and any addon write taints the key. All idempotency flags
-- and created-widget references live in external weak-keyed tables instead.
local styled = setmetatable({}, { __mode = "k" }) -- frame -> true (one-time skin flag)
local rangeOverlays = setmetatable({}, { __mode = "k" }) -- ItemButton -> range overlay texture
local iconBackdrops = setmetatable({}, { __mode = "k" }) -- progress bar icon -> backdrop
local headerColors = setmetatable({}, { __mode = "k" }) -- block -> header text color
local questColors = {} -- questID -> difficulty color, rebuilt on quest log events

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

-- Difficulty colors are computed OUTSIDE the tracker Update chain: secure
-- quest-log reads inside Blizzard's Update charge the whole pass to us and
-- can leak taint into reward/money rendering on turn-in. Quest log events
-- rebuild the questID -> color cache (debounced); the deferred apply pass
-- only reads the cache.

local function applyQuestColors()
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if not questID then break end
        local col = questColors[questID]
        local block = col and QuestObjectiveTracker:GetExistingBlock(questID)
        if block and block.HeaderText then
            block.HeaderText:SetTextColor(col.r, col.g, col.b)
            headerColors[block] = col
        end
    end
end

local function computeQuestColor(questID) return GetDifficultyColor(C_PlayerInfo.GetContentDifficultyQuestForPlayer(questID)) end

local function rebuildQuestColors()
    wipe(questColors)
    for i = 1, C_QuestLog.GetNumQuestWatches() do
        local questID = C_QuestLog.GetQuestIDForQuestWatchIndex(i)
        if not questID then break end
        -- Difficulty may be a secret value in restricted content and
        -- GetDifficultyColor compares it: guard and skip on failure.
        local ok, col = pcall(computeQuestColor, questID)
        if ok and col then questColors[questID] = col end
    end
    applyQuestColors()
end

local colorRebuildPending = false
local function queueColorRebuild()
    if colorRebuildPending then return end
    colorRebuildPending = true
    C_Timer.After(0.25, function()
        colorRebuildPending = false
        rebuildQuestColors()
    end)
end

-- Dirty flag: hooksecurefunc charges Blizzard's entire Update() to us, so
-- the hook only marks and a single deferred pass does the work.
local colorApplyPending = false
local function onQuestTrackerUpdate()
    if colorApplyPending then return end
    colorApplyPending = true
    C_Timer.After(0, function()
        colorApplyPending = false
        applyQuestColors()
    end)
end

-- POI scale/alpha and world quest quality color. Deferred because Blizzard
-- assigns the pooled poiButton after AddBlock; the timer also moves the
-- C_QuestLog reads out of the tracker Update chain.
local function styleBlockPOI(block)
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
                    headerColors[block] = col
                end
            end
        end
    end)
end

------------------------------------------------------------------------
-- Quest Item Button Skin
------------------------------------------------------------------------

local function hotkeyShow(self)
    local overlay = rangeOverlays[self:GetParent()]
    if overlay then overlay:Show() end
end

local function hotkeyHide(self)
    local overlay = rangeOverlays[self:GetParent()]
    if overlay then overlay:Hide() end
end

local function hotkeyColor(self, r)
    local overlay = rangeOverlays[self:GetParent()]
    if overlay then overlay:SetShown(r == 1) end
end

local function skinQuestIcons(block)
    local item = block and block.ItemButton
    if item and not styled[item] then
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
        rangeOverlays[item] = rangeOverlay

        hooksecurefunc(item.HotKey, "Show", hotkeyShow)
        hooksecurefunc(item.HotKey, "Hide", hotkeyHide)
        hooksecurefunc(item.HotKey, "SetVertexColor", hotkeyColor)
        hotkeyColor(item.HotKey, item.HotKey:GetTextColor())
        item.HotKey:SetAlpha(0)

        styled[item] = true
    end

    local finder = block and block.rightEdgeFrame
    if finder and not styled[finder] then
        finder:SetSize(26, 26)
        finder:SetNormalTexture(0)
        finder:SetHighlightTexture(0)
        finder:SetPushedTexture(0)

        local bg = CreateFrame("Frame", nil, finder, "BackdropTemplate")
        bg:SetTemplate("Fill")
        bg:SetPoint("TOPLEFT", finder, 2, -2)
        bg:SetPoint("BOTTOMRIGHT", finder, -2, 2)
        bg:SetFrameLevel(1)

        finder:HookScript("OnEnter", function(self)
            if self:IsEnabled() then bg:SetBackdropBorderColor(E.myColor.r, E.myColor.g, E.myColor.b) end
        end)
        finder:HookScript("OnLeave", function() bg:SetBackdropBorderColor(unpack(C.media.border_color)) end)

        hooksecurefunc(finder, "Show", function() bg:SetFrameLevel(1) end)

        styled[finder] = true
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

    if not styled[progressBar] then
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
            icon:SetMask("")
            iconBackdrops[icon] = E:StyleIcon(icon, true)
            icon:ClearAllPoints()
            icon:SetPoint("TOPLEFT", bar, "TOPRIGHT", 8, 2)
            icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 30, -2)

            if bar.AnimIn and bar.AnimIn.Play then hooksecurefunc(bar.AnimIn, "Play", function() bar.AnimIn:Stop() end) end
        end

        styled[progressBar] = true
    end

    local iconBG = icon and iconBackdrops[icon]
    if iconBG then iconBG:SetShown(icon:IsShown() and icon:GetTexture() ~= nil) end
end

------------------------------------------------------------------------
-- Timer Bar Skin
------------------------------------------------------------------------

local function skinTimerBar(tracker, key)
    local timerBar = tracker.usedTimerBars[key]
    local bar = timerBar and timerBar.Bar

    if not styled[timerBar] then
        -- Hide via SetTexture("") only: SetTexture(nil) / SetAlpha(0) taint
        -- Blizzard-owned textures and pooled reuse then errors on secrets.
        if bar.BorderLeft then bar.BorderLeft:SetTexture("") end
        if bar.BorderRight then bar.BorderRight:SetTexture("") end
        if bar.BorderMid then bar.BorderMid:SetTexture("") end

        bar:SetStatusBarTexture(C.media.texture.status)
        bar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)
        bar:CreateBackdrop("transparent")
        bar:CreateBorder("thin")

        styled[timerBar] = true
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
-- Block Hook Handlers
------------------------------------------------------------------------

local function onAddBlock(_, block)
    skinQuestIcons(block)
    styleBlockPOI(block)
end

local function onBlockHeaderClick(_, block) onBlockClick(block.id) end

local function onBlockHeaderEnter(_, block)
    if isFramePositionedLeft(ObjectiveTrackerFrame) then
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint("TOPLEFT", block, "TOPRIGHT", 0, 0)
        GameTooltip:Show()
    end
end

local function onBlockHeaderLeave(_, block)
    local col = headerColors[block]
    if col and block.HeaderText then block.HeaderText:SetTextColor(col.r, col.g, col.b) end
end

------------------------------------------------------------------------
-- Dungeon Stage Block Skin
------------------------------------------------------------------------

-- Only the StageBlock singleton itself is touched. Never style its
-- WidgetContainer children or hook its tooltip: those frames share
-- Blizzard's UIWidget pool with tooltip/AreaPOI widgets, and any addon
-- method call on them taints the pool (secret-value comparison errors in
-- GameTooltip_ClearWidgetSet / UIWidgetTemplateTextWithState later).
local function skinStageBlock(block)
    if not styled[block] then
        styled[block] = true

        block:CreateBackdrop("transparent")
        block.backdrop:SetBackdropEdge("thin")

        -- Only faded in by AlphaAnim, never re-textured: one-time clear.
        block.GlowTexture:SetTexture("")
    end

    -- UpdateStageBlock re-applies SetAtlas to NormalBG/FinalBG and re-shows
    -- ThemeOverlay on every call (stage advance, textureKit change), so
    -- these must be cleared on every pass, not just once.
    block.NormalBG:SetTexture("")
    block.FinalBG:SetTexture("")
    if block.ThemeOverlay then block.ThemeOverlay:SetTexture("") end
end

------------------------------------------------------------------------
-- Mythic+ Block Skin
------------------------------------------------------------------------

local function skinChallengeBlock(block)
    if styled[block] then return end
    styled[block] = true

    block:CreateBackdrop("transparent")
    block.backdrop:SetBackdropEdge("thin")
    block.backdrop:SetPoint("TOPLEFT", block, 3, -3)
    block.backdrop:SetPoint("BOTTOMRIGHT", block, -6, 3)
    block.backdrop.overlay:SetVertexColor(0.12, 0.12, 0.12, 1)

    local bg = select(3, block:GetRegions())
    if bg then bg:SetTexture("") end

    block.TimerBGBack:SetTexture("")
    block.TimerBG:SetTexture("")

    block.StatusBar:SetStatusBarTexture(C.media.texture.status)
    block.StatusBar:SetStatusBarColor(0, 0.6, 1)
    block.StatusBar:CreateBackdrop("transparent")
    block.StatusBar.backdrop:SetBackdropEdge("thin")
    block.StatusBar.backdrop:SetFrameLevel(block.backdrop:GetFrameLevel() + 1)
    block.StatusBar:SetFrameLevel(block.StatusBar:GetFrameLevel() + 3)
end

local function skinAffixes(self)
    for frame in self.affixPool:EnumerateActive() do
        frame.Border:SetTexture("")
        if not styled[frame] then
            frame.Portrait:SetTexCoord(0.1, 0.9, 0.1, 0.9)
            frame.Portrait:CreateBackdrop()
            styled[frame] = true
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
-- SplashFrame Taint Fix
------------------------------------------------------------------------

-- Clone of SplashFrameMixin:OnHide() minus the ObjectiveTrackerFrame:Update()
-- call, which taints the quest item button / money frames downstream (same
-- fix as ElvUI). Intentional SetScript: the whole body is replaced.
local function splashFrameOnHide(frame)
    local fromGameMenu = frame.screenInfo and frame.screenInfo.gameMenuRequest
    frame.screenInfo = nil

    if C_TalkingHead and C_TalkingHead.SetConversationsDeferred then C_TalkingHead.SetConversationsDeferred(false) end
    if AlertFrame and AlertFrame.SetAlertsEnabled then AlertFrame:SetAlertsEnabled(true, "splashFrame") end

    if fromGameMenu and not frame.showingQuestDialog and not InCombatLockdown() then ShowUIPanel(GameMenuFrame) end

    frame.showingQuestDialog = nil
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end

    -- Position: anchor holder + re-anchor hook (NOT Edit Mode / LEMO).
    -- LEMO:ApplyChanges commits layouts by ShowUIPanel/HideUIPanel on
    -- EditModeManagerFrame; entering/exiting Edit Mode from addon context
    -- taints secureexecuterange over encounter events (secret number
    -- comparisons in RefreshEncounterEvents / HideSystemSelections).
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

    ObjectiveTrackerFrame.Header.Background:SetTexture("")

    -- Minimize button
    local button = ObjectiveTrackerFrame.Header.MinimizeButton
    button:SetSize(17, 17)
    button:StripTextures()
    E:StyleIconButton(button)

    local minus = button:CreateTexture(nil, "OVERLAY")
    minus:SetSize(7, 1)
    minus:SetPoint("CENTER")
    minus:SetTexture(C.media.texture.blank)

    local plus = button:CreateTexture(nil, "OVERLAY")
    plus:SetSize(1, 7)
    plus:SetPoint("CENTER")
    plus:SetTexture(C.media.texture.blank)
    plus:Hide()

    hooksecurefunc(ObjectiveTrackerFrame, "SetCollapsed", function(_, collapsed)
        plus:SetShown(collapsed)
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
    end)

    -- Difficulty coloring: event-driven cache + deferred apply
    self:RegisterEvent("QUEST_LOG_UPDATE", queueColorRebuild)
    self:RegisterEvent("QUEST_WATCH_LIST_CHANGED", queueColorRebuild)
    self:RegisterEvent("PLAYER_ENTERING_WORLD", queueColorRebuild)
    hooksecurefunc(QuestObjectiveTracker, "Update", onQuestTrackerUpdate)

    -- Ctrl+Click in quest map
    hooksecurefunc("QuestMapLogTitleButton_OnClick", function(self) onBlockClick(self.questID) end)

    -- Hook all tracker headers
    for i = 1, #headers do
        local tracker = headers[i]
        if tracker then
            local header = tracker.Header
            if header and header.Background then header.Background:SetTexture("") end

            hooksecurefunc(tracker, "AddBlock", onAddBlock)
            hooksecurefunc(tracker, "GetProgressBar", skinProgressBar)
            hooksecurefunc(tracker, "GetTimerBar", skinTimerBar)
            hooksecurefunc(tracker, "OnBlockHeaderClick", onBlockHeaderClick)
            hooksecurefunc(tracker, "OnBlockHeaderEnter", onBlockHeaderEnter)
            hooksecurefunc(tracker, "OnBlockHeaderLeave", onBlockHeaderLeave)
        end
    end

    -- Dungeon stage block
    hooksecurefunc(ScenarioObjectiveTracker.StageBlock, "UpdateStageBlock", skinStageBlock)

    -- Mythic+ block
    hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "Activate", skinChallengeBlock)
    hooksecurefunc(ScenarioObjectiveTracker.ChallengeModeBlock, "SetUpAffixes", skinAffixes)

    -- SplashFrame taint fix
    if SplashFrame then SplashFrame:SetScript("OnHide", splashFrameOnHide) end
end
