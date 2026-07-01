local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b

------------------------------------------------------------------------
-- Achievement UI
-- Ported from AuroraClassic AddOns/Blizzard_AchievementUI.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
-- Note: B.CreateBDFrame(f, alpha) → f:CreateBackdrop() + SetBackdropColor.
-- Note: B.Dummy → E.Dummy (noop function from Core/API.lua).
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function setupButtonHighlight(button, bg)
    button:SetHighlightTexture(C.media.texture.blank)
    local hl = button:GetHighlightTexture()
    hl:SetVertexColor(cr, cg, cb, 0.25)
    hl:SetInside(bg, 2, 2)
end

local function setupStatusbar(bar)
    bar:StripTextures()
    bar:SetStatusBarTexture(C.media.texture.status)
    bar:GetStatusBarTexture():SetGradient("VERTICAL", CreateColor(0, 0.4, 0, 1), CreateColor(0, 0.6, 0, 1))
    local barBg = bar:CreateBackdrop()
    barBg:SetBackdropColor(0, 0, 0, 0.25)
end

function S:Achievement()
    if not (C.skins.enable and C.skins.achievement) then return end

    S:ReskinPortraitFrame(_G.AchievementFrame)
    _G.AchievementFrameWaterMark:SetAlpha(0)
    _G.AchievementFrame.Header:StripTextures()
    _G.AchievementFrame.Header.Title:Hide()
    _G.AchievementFrame.Header.Points:SetPoint("TOP", _G.AchievementFrame, 0, -3)

    for i = 1, 3 do
        local tab = _G["AchievementFrameTab" .. i]
        if tab then
            S:ReskinTab(tab)
            tab:ClearAllPoints()
            if i == 1 then
                tab:SetPoint("TOPLEFT", _G.AchievementFrame, "BOTTOMLEFT", -3, 0)
            else
                tab:SetPoint("TOPLEFT", _G["AchievementFrameTab" .. (i - 1)], "TOPRIGHT", -5, 0)
            end
        end
    end

    S:ReskinFilterButton(_G.AchievementFrameFilterDropdown)
    _G.AchievementFrameFilterDropdown:ClearAllPoints()
    _G.AchievementFrameFilterDropdown:SetPoint("TOPLEFT", 25, -5)
    S:ReskinClose(_G.AchievementFrameCloseButton)

    -- Search box
    S:ReskinEditBox(_G.AchievementFrame.SearchBox)
    _G.AchievementFrame.SearchBox:ClearAllPoints()
    _G.AchievementFrame.SearchBox:SetPoint("TOPRIGHT", _G.AchievementFrame, "TOPRIGHT", -40, -5)
    _G.AchievementFrame.SearchBox:SetPoint("BOTTOMLEFT", _G.AchievementFrame, "TOPRIGHT", -160, -25)

    local previewContainer = _G.AchievementFrame.SearchPreviewContainer
    local showAllSearchResults = previewContainer.ShowAllSearchResults
    previewContainer:StripTextures()
    previewContainer:ClearAllPoints()
    previewContainer:SetPoint("TOPLEFT", _G.AchievementFrame, "TOPRIGHT", 7, -2)
    local previewBg = S:CreateBackground(previewContainer)
    previewBg:SetPoint("TOPLEFT", -3, 3)
    previewBg:SetPoint("BOTTOMRIGHT", showAllSearchResults, 3, -3)

    for i = 1, 5 do
        S:StyleSearchButton(previewContainer["SearchPreview" .. i])
    end
    S:StyleSearchButton(showAllSearchResults)

    local result = _G.AchievementFrame.SearchResults
    result:SetPoint("BOTTOMLEFT", _G.AchievementFrame, "BOTTOMRIGHT", 15, -1)
    result:StripTextures()
    local resultBg = S:CreateBackground(result)
    resultBg:SetPoint("TOPLEFT", -10, 0)
    resultBg:SetPoint("BOTTOMRIGHT")

    S:ReskinClose(result.CloseButton)
    S:ReskinTrimScrollBar(result.ScrollBar)
    hooksecurefunc(result.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                child:StripTextures(2)
                S:ReskinIcon(child.Icon)
                local bg = child:CreateBackdrop()
                bg:SetBackdropEdge("round_white")
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetInside()
                setupButtonHighlight(child, bg)

                child.__styled = true
            end
        end
    end)

    -- AchievementFrameCategories
    _G.AchievementFrameCategories:StripTextures()
    S:ReskinTrimScrollBar(_G.AchievementFrameCategories.ScrollBar)
    hooksecurefunc(_G.AchievementFrameCategories.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            local button = child.Button
            if button and not button.__styled then
                button.Background:Hide()
                local bg = button:CreateBackdrop()
                bg:SetBackdropEdge("round_white")
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetPoint("TOPLEFT", 0, -1)
                bg:SetPoint("BOTTOMRIGHT")
                setupButtonHighlight(button, bg)

                button.__styled = true
            end
        end
    end)

    _G.AchievementFrameAchievements:StripTextures()
    S:ReskinTrimScrollBar(_G.AchievementFrameAchievements.ScrollBar)
    select(3, _G.AchievementFrameAchievements:GetChildren()):Hide()

    local function updateAccountString(button)
        if button.DateCompleted:IsShown() then
            if button.accountWide then
                button.Label:SetTextColor(0, 0.6, 1)
            else
                button.Label:SetTextColor(0.9, 0.9, 0.9)
            end
        else
            if button.accountWide then
                button.Label:SetTextColor(0, 0.3, 0.5)
            else
                button.Label:SetTextColor(0.65, 0.65, 0.65)
            end
        end
    end

    local function updateProgressBars(frame)
        local objectives = frame:GetObjectiveFrame()
        if objectives and objectives.progressBars then
            for _, bar in next, objectives.progressBars do
                if not bar.__styled then
                    setupStatusbar(bar)
                    bar.__styled = true
                end
            end
        end
    end

    hooksecurefunc(_G.AchievementFrameAchievements.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child and not child.__styled then
                child:StripTextures(true)
                child.Background:SetAlpha(0)
                child.Highlight:SetAlpha(0)
                child.Icon.frame:Hide()
                child.Description:SetTextColor(0.9, 0.9, 0.9)
                child.Description.SetTextColor = E.Dummy

                local bg = child:CreateBackdrop()
                bg:SetBackdropEdge("round_white")
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetPoint("TOPLEFT", 1, -1)
                bg:SetPoint("BOTTOMRIGHT", 0, 2)
                S:ReskinIcon(child.Icon.texture)

                S:ReskinCheck(child.Tracked)
                child.Tracked:SetSize(20, 20)
                child.Check:SetAlpha(0)

                hooksecurefunc(child, "UpdatePlusMinusTexture", updateAccountString)
                hooksecurefunc(child, "DisplayObjectives", updateProgressBars)

                child.__styled = true
            end
        end
    end)

    _G.AchievementFrameSummary:StripTextures()
    _G.AchievementFrameSummary:GetChildren():Hide()
    _G.AchievementFrameSummaryAchievementsHeaderHeader:SetVertexColor(1, 1, 1, 0.25)
    _G.AchievementFrameSummaryCategoriesHeaderTexture:SetVertexColor(1, 1, 1, 0.25)

    hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
        for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
            local bu = _G["AchievementFrameSummaryAchievement" .. i]
            if bu.accountWide then
                bu.Label:SetTextColor(0, 0.6, 1)
            else
                bu.Label:SetTextColor(0.9, 0.9, 0.9)
            end

            if not bu.__styled then
                bu:DisableDrawLayer("BORDER")
                bu:HideBackdrop()

                local bd = bu.Background
                bd:SetTexture(C.media.texture.blank)
                bd:SetVertexColor(0, 0, 0, 0.25)

                bu.TitleBar:Hide()
                bu.Glow:Hide()
                bu.Highlight:SetAlpha(0)
                bu.Icon.frame:Hide()
                S:ReskinIcon(bu.Icon.texture)

                -- backdrop slot freed so subsequent CreateBackdrop is independent
                bu.backdrop = nil
                local bg = bu:CreateBackdrop()
                bg:SetBackdropEdge("round_white")
                bg:SetBackdropColor(0, 0, 0, 0)
                bg:SetPoint("TOPLEFT", 2, -2)
                bg:SetPoint("BOTTOMRIGHT", -2, 2)

                bu.__styled = true
            end

            bu.Description:SetTextColor(0.9, 0.9, 0.9)
        end
    end)

    for i = 1, 12 do
        local bu = _G["AchievementFrameSummaryCategoriesCategory" .. i]
        setupStatusbar(bu)
        bu.Label:SetTextColor(1, 1, 1)
        bu.Label:SetPoint("LEFT", bu, "LEFT", 6, 0)
        bu.Text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)
        _G[bu:GetName() .. "ButtonHighlight"]:SetAlpha(0)
    end

    local bar = _G.AchievementFrameSummaryCategoriesStatusBar
    if bar then
        setupStatusbar(bar)
        _G[bar:GetName() .. "Title"]:SetPoint("LEFT", bar, "LEFT", 6, 0)
        _G[bar:GetName() .. "Text"]:SetPoint("RIGHT", bar, "RIGHT", -5, 0)
    end

    _G.AchievementFrameSummaryAchievementsEmptyText:SetText("")

    hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
        local numCriteria = GetAchievementNumCriteria(id)
        local textStrings, metas, criteria, object = 0, 0
        for i = 1, numCriteria do
            local _, criteriaType, completed, _, _, _, _, assetID = GetAchievementCriteriaInfo(id, i)
            if assetID and criteriaType == _G.CRITERIA_TYPE_ACHIEVEMENT then
                metas = metas + 1
                criteria, object = objectivesFrame:GetMeta(metas), "Label"
            elseif criteriaType ~= 1 then
                textStrings = textStrings + 1
                criteria, object = objectivesFrame:GetCriteria(textStrings), "Name"
            end

            local text = criteria and criteria[object]
            if text and completed and objectivesFrame.completed then text:SetTextColor(1, 1, 1) end
        end
    end)

    -- Stats
    _G.AchievementFrameStatsBG:Hide()
    select(4, _G.AchievementFrameStats:GetChildren()):Hide()
    S:ReskinTrimScrollBar(_G.AchievementFrameStats.ScrollBar)
    hooksecurefunc(_G.AchievementFrameStats.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                child:StripTextures()
                local bg = child:CreateBackdrop()
                bg:SetBackdropEdge("round_white")
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetPoint("TOPLEFT", 2, -E.mult)
                bg:SetPoint("BOTTOMRIGHT", 4, E.mult)
                setupButtonHighlight(child, bg)

                child.__styled = true
            end
        end
    end)

    -- Comparison
    _G.AchievementFrameComparisonHeaderBG:Hide()
    _G.AchievementFrameComparisonHeaderPortrait:Hide()
    _G.AchievementFrameComparisonHeaderPortraitBg:Hide()
    _G.AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", _G.AchievementFrameComparison, "TOPRIGHT", 39, 26)
    local headerbg = S:CreateBackground(_G.AchievementFrameComparisonHeader)
    headerbg:SetPoint("TOPLEFT", 20, -20)
    headerbg:SetPoint("BOTTOMRIGHT", -28, -5)

    _G.AchievementFrameComparison:StripTextures()
    select(5, _G.AchievementFrameComparison:GetChildren()):Hide()
    S:ReskinTrimScrollBar(_G.AchievementFrameComparison.AchievementContainer.ScrollBar)

    local function handleCompareSummary(frame)
        frame:StripTextures()
        local sbar = frame.StatusBar
        setupStatusbar(sbar)
        sbar.Title:SetTextColor(1, 1, 1)
        sbar.Title:SetPoint("LEFT", sbar, "LEFT", 6, 0)
        sbar.Text:SetPoint("RIGHT", sbar, "RIGHT", -5, 0)
    end
    handleCompareSummary(_G.AchievementFrameComparison.Summary.Player)
    handleCompareSummary(_G.AchievementFrameComparison.Summary.Friend)

    local function handleCompareCategory(button)
        button:DisableDrawLayer("BORDER")
        button:HideBackdrop()
        button.Background:Hide()
        local bg = button:CreateBackdrop()
        bg:SetBackdropEdge("round_white")
        bg:SetBackdropColor(0, 0, 0, 0.25)
        bg:SetInside(button, 2, 2)

        button.TitleBar:Hide()
        button.Glow:Hide()
        button.Icon.frame:Hide()
        S:ReskinIcon(button.Icon.texture)
    end

    hooksecurefunc(_G.AchievementFrameComparison.AchievementContainer.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                handleCompareCategory(child.Player)
                child.Player.Description:SetTextColor(0.9, 0.9, 0.9)
                child.Player.Description.SetTextColor = E.Dummy
                handleCompareCategory(child.Friend)

                child.__styled = true
            end
        end
    end)
end

S:AddCallbackForAddon("Blizzard_AchievementUI", "Achievement")
