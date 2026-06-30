local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Encounter Journal (Lore / Boss / Loot / LootJournal / Suggest / Journeys)
-- Ported from AuroraClassic AddOns/Blizzard_EncounterJournal.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
-- Note: B.SetFontSize → :FontTemplate(nil, sz); SetTextColor("P",...) → Aurora
--       palette shorthand, kept as-is — it is a valid WoW FontString call.
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function reskinHeader(header)
    for i = 4, 18 do
        select(i, header.button:GetRegions()):SetTexture("")
    end
    S:Reskin(header.button)
    header.descriptionBG:SetAlpha(0)
    header.descriptionBGBottom:SetAlpha(0)
    header.description:SetTextColor(1, 1, 1)
    header.button.title:SetTextColor(1, 1, 1)
    header.button.expandedIcon:SetWidth(20) -- don't wrap the text
end

local function reskinSectionHeader()
    local index = 1
    while true do
        local header = _G["EncounterJournalInfoHeader" .. index]
        if not header then return end
        if not header.__styled then
            reskinHeader(header)
            header.button.bg = S:ReskinIcon(header.button.abilityIcon)
            header.__styled = true
        end

        if header.button.abilityIcon:IsShown() then
            header.button.bg:Show()
        else
            header.button.bg:Hide()
        end

        index = index + 1
    end
end

function S:EncounterJournal()
    if not (C.skins.enable and C.skins.encounterjournal) then return end

    -- Tabs
    for i = 1, 7 do
        local tab = _G.EncounterJournal.Tabs[i]
        if tab then
            S:ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", _G.EncounterJournal.Tabs[i - 1], "TOPRIGHT", -5, 0)
            end
        end
    end

    -- Side tabs
    local tabs = { "overviewTab", "modelTab", "bossTab", "lootTab" }
    for _, name in pairs(tabs) do
        local tab = _G.EncounterJournal.encounter.info[name]
        local bg = S:SetBD(tab)
        bg:SetInside(tab, 2, 2)

        tab:SetNormalTexture(0)
        tab:SetPushedTexture(0)
        tab:SetDisabledTexture(0)
        local hl = tab:GetHighlightTexture()
        hl:SetColorTexture(cr, cg, cb, 0.2)
        hl:SetInside(bg)

        if name == "overviewTab" then tab:SetPoint("TOPLEFT", _G.EncounterJournalEncounterFrameInfo, "TOPRIGHT", 9, -35) end
    end

    -- Instance select
    _G.EncounterJournalInstanceSelectBG:SetAlpha(0)
    S:ReskinDropDown(_G.EncounterJournal.instanceSelect.ExpansionDropdown)
    S:ReskinTrimScroll(_G.EncounterJournal.instanceSelect.ScrollBar)
    _G.EncounterJournal.instanceSelect.evergreenBg:SetAlpha(0)

    hooksecurefunc(_G.EncounterJournal.instanceSelect.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                child:SetNormalTexture(0)
                child:SetHighlightTexture(0)
                child:SetPushedTexture(0)

                local bg = child.bgImage:CreateBackdrop()
                bg:SetPoint("TOPLEFT", 3, -3)
                bg:SetPoint("BOTTOMRIGHT", -4, 2)

                child.__styled = true
            end
        end
    end)

    -- Encounter frame
    _G.EncounterJournalEncounterFrameInfo:DisableDrawLayer("BACKGROUND")
    _G.EncounterJournalInstanceSelectBG:Hide()
    _G.EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
    _G.EncounterJournalEncounterFrameInfoModelFrame.dungeonBG:Hide()

    _G.EncounterJournalEncounterFrameInfoEncounterTitle:SetTextColor(1, 0.8, 0)
    _G.EncounterJournal.encounter.instance.LoreScrollingFont:SetTextColor(CreateColor(1, 1, 1))
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor("P", 1, 1, 1)
    _G.EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
    _G.EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 0.8, 0)

    local modelBg = _G.EncounterJournalEncounterFrameInfoModelFrame:CreateBackdrop()
    modelBg:SetBackdropColor(0, 0, 0, 0.25)
    _G.EncounterJournalEncounterFrameInfoCreatureButton1:SetPoint("TOPLEFT", _G.EncounterJournalEncounterFrameInfoModelFrame, 0, -35)

    hooksecurefunc(_G.EncounterJournal.encounter.info.BossesScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                S:Reskin(child, true)
                local hl = child:GetHighlightTexture()
                hl:SetColorTexture(cr, cg, cb, 0.25)
                hl:SetInside(child.__bg)

                child.text:SetTextColor(1, 1, 1)
                child.creature:SetPoint("TOPLEFT", 0, -4)

                child.__styled = true
            end
        end
    end)
    hooksecurefunc("EncounterJournal_ToggleHeaders", reskinSectionHeader)

    hooksecurefunc("EncounterJournal_SetUpOverview", function(self, _, index)
        local header = self.overviews[index]
        if not header.__styled then
            reskinHeader(header)
            header.__styled = true
        end
    end)

    hooksecurefunc("EncounterJournal_SetBullets", function(object)
        local parent = object:GetParent()
        if parent.Bullets then
            for _, bullet in pairs(parent.Bullets) do
                if not bullet.__styled then
                    bullet.Text:SetTextColor("P", 1, 1, 1)
                    bullet.__styled = true
                end
            end
        end
    end)

    hooksecurefunc(_G.EncounterJournal.encounter.info.LootContainer.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.boss and not child.__styled then
                child.boss:SetTextColor(1, 1, 1)
                child.slot:SetTextColor(1, 1, 1)
                child.armorType:SetTextColor(1, 1, 1)
                child.bossTexture:SetAlpha(0)
                child.bosslessTexture:SetAlpha(0)
                child.IconBorder:SetAlpha(0)
                child.icon:SetPoint("TOPLEFT", 1, -1)
                S:ReskinIcon(child.icon)

                local bg = child:CreateBackdrop()
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetPoint("TOPLEFT")
                bg:SetPoint("BOTTOMRIGHT", 0, 1)

                child.__styled = true
            end
        end
    end)

    -- Search results
    _G.EncounterJournalSearchBox:SetFrameLevel(15)
    local showAllResults = _G.EncounterJournalSearchBox.showAllResults
    local previewContainer = _G.EncounterJournalSearchBox.searchPreviewContainer
    previewContainer:StripTextures()
    local bg = S:SetBD(previewContainer)
    bg:SetPoint("TOPLEFT", -3, 3)
    bg:SetPoint("BOTTOMRIGHT", showAllResults, 3, -3)

    for i = 1, _G.EncounterJournalSearchBox:GetNumChildren() do
        local child = select(i, _G.EncounterJournalSearchBox:GetChildren())
        if child.iconFrame then S:StyleSearchButton(child) end
    end
    S:StyleSearchButton(showAllResults)

    do
        local result = _G.EncounterJournalSearchResults
        result:SetPoint("BOTTOMLEFT", _G.EncounterJournal, "BOTTOMRIGHT", 15, -1)
        result:StripTextures()
        local bg = S:SetBD(result)
        bg:SetPoint("TOPLEFT", -10, 0)
        bg:SetPoint("BOTTOMRIGHT")

        S:ReskinClose(_G.EncounterJournalSearchResultsCloseButton)
        S:ReskinTrimScroll(result.ScrollBar)

        hooksecurefunc(result.ScrollBox, "Update", function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local child = select(i, self.ScrollTarget:GetChildren())
                if not child.__styled then
                    child:StripTextures(2)
                    S:ReskinIcon(child.icon)
                    local bg = child:CreateBackdrop()
                    bg:SetBackdropColor(0, 0, 0, 0.25)
                    bg:SetInside()

                    child:SetHighlightTexture(DB.bdTex)
                    local hl = child:GetHighlightTexture()
                    hl:SetVertexColor(cr, cg, cb, 0.25)
                    hl:SetInside(bg)

                    child.__styled = true
                end
            end
        end)
    end

    -- Various controls
    S:ReskinPortraitFrame(_G.EncounterJournal)
    S:ReskinInput(_G.EncounterJournalSearchBox)
    S:ReskinTrimScroll(_G.EncounterJournal.encounter.instance.LoreScrollBar)
    S:ReskinTrimScroll(_G.EncounterJournal.encounter.info.BossesScrollBar)
    S:ReskinTrimScroll(_G.EncounterJournal.encounter.info.LootContainer.ScrollBar)
    S:ReskinTrimScroll(_G.EncounterJournal.encounter.info.overviewScroll.ScrollBar)
    S:ReskinTrimScroll(_G.EncounterJournal.encounter.info.detailsScroll.ScrollBar)
    S:ReskinDropDown(_G.EncounterJournal.encounter.info.LootContainer.filter)
    S:ReskinDropDown(_G.EncounterJournal.encounter.info.LootContainer.slotFilter)
    S:ReskinDropDown(_G.EncounterJournalEncounterFrameInfoDifficulty)

    -- Suggest frame
    local suggestFrame = _G.EncounterJournal.suggestFrame

    -- Suggestion 1
    do
        local suggestion = suggestFrame.Suggestion1
        suggestion.bg:Hide()
        suggestion:CreateBackdrop()
        suggestion.backdrop:SetBackdropColor(0, 0, 0, 0.25)
        suggestion.icon:SetPoint("TOPLEFT", 135, -15)
        suggestion.icon:CreateBackdrop()

        local centerDisplay = suggestion.centerDisplay
        centerDisplay.title.text:SetTextColor(1, 1, 1)
        centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)
        S:Reskin(suggestion.button)

        local reward = suggestion.reward
        reward.text:SetTextColor(0.9, 0.9, 0.9)
        reward.iconRing:Hide()
        reward.iconRingHighlight:SetTexture("")
        reward.icon:CreateBackdrop():SetFrameLevel(3)
        S:ReskinArrow(suggestion.prevButton, "left")
        S:ReskinArrow(suggestion.nextButton, "right")
    end

    -- Suggestion 2 and 3
    for i = 2, 3 do
        local suggestion = suggestFrame["Suggestion" .. i]

        suggestion.bg:Hide()
        suggestion:CreateBackdrop()
        suggestion.backdrop:SetBackdropColor(0, 0, 0, 0.25)
        suggestion.icon:SetPoint("TOPLEFT", 10, -10)
        suggestion.icon:CreateBackdrop()

        local centerDisplay = suggestion.centerDisplay

        centerDisplay:ClearAllPoints()
        centerDisplay:SetPoint("TOPLEFT", 85, -10)
        centerDisplay.title.text:SetTextColor(1, 1, 1)
        centerDisplay.description.text:SetTextColor(0.9, 0.9, 0.9)
        S:Reskin(centerDisplay.button)

        local reward = suggestion.reward
        reward.iconRing:Hide()
        reward.iconRingHighlight:SetTexture("")
        reward.icon:CreateBackdrop():SetFrameLevel(3)
    end

    -- Hook functions
    hooksecurefunc("EJSuggestFrame_RefreshDisplay", function()
        local self = suggestFrame

        if #self.suggestions > 0 then
            local suggestion = self.Suggestion1
            local data = self.suggestions[1]
            suggestion.iconRing:Hide()

            if data.iconPath then
                suggestion.icon:SetMask("")
                suggestion.icon:SetTexCoord(unpack(DB.TexCoord))
            end
        end

        if #self.suggestions > 1 then
            for i = 2, #self.suggestions do
                local suggestion = self["Suggestion" .. i]
                if not suggestion then break end

                local data = self.suggestions[i]
                suggestion.iconRing:Hide()

                if data.iconPath then
                    suggestion.icon:SetMask("")
                    suggestion.icon:SetTexCoord(unpack(DB.TexCoord))
                end
            end
        end
    end)

    hooksecurefunc("EJSuggestFrame_UpdateRewards", function(suggestion)
        local rewardData = suggestion.reward.data
        if rewardData then
            suggestion.reward.icon:SetMask("")
            suggestion.reward.icon:SetTexCoord(unpack(DB.TexCoord))
        end
    end)

    -- LootJournal

    local lootJournal = _G.EncounterJournal.LootJournal
    lootJournal:StripTextures()

    local iconColor = DB.QualityColors[Enum.ItemQuality.Legendary or 5] -- legendary color
    S:ReskinTrimScroll(lootJournal.ScrollBar)

    hooksecurefunc(lootJournal.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                child.Background:SetAlpha(0)
                child.BackgroundOverlay:SetAlpha(0)
                child.UnavailableOverlay:SetAlpha(0)
                child.UnavailableBackground:SetAlpha(0)
                child.CircleMask:Hide()
                child.bg = S:ReskinIcon(child.Icon)
                child.bg:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)

                local bg = child:CreateBackdrop()
                bg:SetBackdropColor(0, 0, 0, 0.25)
                bg:SetPoint("TOPLEFT", 3, 0)
                bg:SetPoint("BOTTOMRIGHT", -2, 1)

                child.__styled = true
            end
        end
    end)

    -- ItemSetsFrame
    if _G.EncounterJournal.LootJournalItems then
        _G.EncounterJournal.LootJournalItems:StripTextures()
        S:ReskinDropDown(_G.EncounterJournal.LootJournalViewDropdown)

        local function reskinBar(bar)
            if not bar.__styled then
                bar.ItemLevel:SetTextColor(1, 1, 1)
                bar.Background:Hide()
                bar:CreateBackdrop()
                bar.backdrop:SetBackdropColor(0, 0, 0, 0.25)

                bar.__styled = true
            end

            local itemButtons = bar.ItemButtons
            for i = 1, #itemButtons do
                local button = itemButtons[i]
                if not button.bg then
                    button.bg = S:ReskinIcon(button.Icon)
                    S:ReskinIconBorder(button.Border, true, true)
                end
            end
        end

        local itemSetsFrame = _G.EncounterJournal.LootJournalItems.ItemSetsFrame
        S:ReskinTrimScroll(itemSetsFrame.ScrollBar)

        hooksecurefunc(itemSetsFrame.ScrollBox, "Update", function(self) self:ForEachFrame(reskinBar) end)
        S:ReskinDropDown(itemSetsFrame.ClassDropdown)
    end

    -- Monthly activities
    local monthlyFrame = _G.EncounterJournalMonthlyActivitiesFrame
    if monthlyFrame then
        monthlyFrame:StripTextures()
        S:ReskinTrimScroll(monthlyFrame.FilterList.ScrollBar)
        S:ReskinTrimScroll(monthlyFrame.ScrollBar)
        if monthlyFrame.ThemeContainer then monthlyFrame.ThemeContainer:SetAlpha(0) end

        local function replaceBlackColor(text, r, g, b)
            if r == 0 and g == 0 and b == 0 then text:SetTextColor(0.7, 0.7, 0.7) end
        end

        local function handleText(button)
            local container = button.TextContainer
            if container and not container.__styled then
                hooksecurefunc(container.NameText, "SetTextColor", replaceBlackColor)
                hooksecurefunc(container.ConditionsText, "SetTextColor", replaceBlackColor)
                container.__styled = true
            end
        end

        hooksecurefunc(monthlyFrame.ScrollBox, "Update", function(self) self:ForEachFrame(handleText) end)
    end

    -- Tutorials
    local tutorialFrame = _G.EncounterJournal.TutorialsFrame
    if tutorialFrame then
        tutorialFrame.Contents.Header:SetTextColor(1, 0.8, 0)
        tutorialFrame.Contents.Description:SetTextColor(1, 1, 1)
        S:Reskin(tutorialFrame.Contents.StartButton)
    end

    -- Journeys
    local journeysFrame = _G.EncounterJournal.JourneysFrame
    if journeysFrame then
        S:ReskinTrimScroll(journeysFrame.ScrollBar)
        S:Reskin(journeysFrame.JourneyProgress.OverviewBtn)
        S:Reskin(journeysFrame.JourneyProgress.LevelSkipButton)
        S:Reskin(journeysFrame.JourneyOverview.OverviewBtn)
    end
end

S:AddCallbackForAddon("Blizzard_EncounterJournal", "EncounterJournal")
