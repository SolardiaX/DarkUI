local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Collections (Mounts / Pets / Toys / Heirlooms / Wardrobe / Warband)
-- Ported from AuroraClassic AddOns/Blizzard_Collections.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local select, ipairs, unpack = select, ipairs, unpack
local hooksecurefunc = hooksecurefunc

local function reskinFrameButton(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        if not child.__styled then
            child:GetRegions():Hide()
            child:SetHighlightTexture(0)
            child.iconBorder:SetTexture("")
            child.selectedTexture:SetTexture("")

            local bg = child:CreateBackdrop()
            bg:SetBackdropEdge("round_white")
            bg:SetPoint("TOPLEFT", 3, -1)
            bg:SetPoint("BOTTOMRIGHT", 0, 1)
            bg:SetBackdropColor(0, 0, 0, 0.25) -- initial fill; selection re-tints the fill (Aurora style)
            bg:SetBackdropBorderColor(0, 0, 0) -- constant row border
            child.bg = bg
            -- Release the .backdrop slot: DarkUI's CreateBackdrop dedups on it,
            -- so without this the icon's ReskinIcon below would reuse THIS row
            -- frame (Aurora's CreateBDFrame makes a fresh frame each call) and
            -- SetOutside would shrink the row highlight onto the icon -> the
            -- selection tint becomes invisible. Keep row bg and icon bg separate.
            child.backdrop = nil

            local icon = child.icon
            icon:SetSize(40, 40)
            icon.bg = S:ReskinIcon(icon)
            child.name:SetParent(bg)

            if child.DragButton then
                -- active (summoned) cue moves to ActiveTexture as a yellow tint,
                -- freeing the icon border for the quality color (ElvUI style)
                child.DragButton.ActiveTexture:SetColorTexture(0.9, 0.8, 0.1, 0.3)
                child.DragButton.ActiveTexture:SetAllPoints(icon)
                child.DragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                child.DragButton:GetHighlightTexture():SetAllPoints(icon)
            else
                child.dragButton.ActiveTexture:SetColorTexture(0.9, 0.8, 0.1, 0.3)
                child.dragButton.ActiveTexture:SetAllPoints(icon)
                child.dragButton.levelBG:SetAlpha(0)
                child.dragButton.level:SetFontObject(GameFontNormal)
                child.dragButton.level:SetTextColor(1, 1, 1)
                child.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                child.dragButton:GetHighlightTexture():SetAllPoints(icon)
            end

            child.__styled = true
        end
    end
end

local function repositionCollectionsTabs()
    local prev
    for i = 1, 6 do
        local tab = _G["CollectionsJournalTab" .. i]
        if tab and tab:IsShown() then
            if prev then
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", prev, "TOPRIGHT", -5, 0)
            end
            prev = tab
        end
    end
end

function S:Collectables()
    if not (C.skins.enable and C.skins.collections) then return end

    -- [[ General ]]

    CollectionsJournal.bg = S:ReskinPortraitFrame(CollectionsJournal) -- need this for Rematch skin
    for i = 1, 6 do
        local tab = _G["CollectionsJournalTab" .. i]
        if tab then S:ReskinTab(tab) end
    end

    -- Blizzard re-clears the wardrobe/heirloom tab points when toggling the
    -- heirlooms tab; re-anchor the whole chain so it follows (5px gap at 5px inset).
    repositionCollectionsTabs()
    hooksecurefunc("CollectionsJournal_CheckAndDisplayHeirloomsTab", repositionCollectionsTabs)

    -- [[ Mounts and pets ]]

    local PetJournal = PetJournal
    local MountJournal = MountJournal

    MountJournal.LeftInset:Hide()
    MountJournal.RightInset:Hide()
    MountJournal.MountDisplay.YesMountsTex:SetAlpha(0)
    MountJournal.MountDisplay.NoMountsTex:SetAlpha(0)
    MountJournal.MountDisplay.ShadowOverlay:Hide()
    PetJournal.LeftInset:Hide()
    PetJournal.RightInset:SetAlpha(0)
    PetJournal.PetCardInset:Hide()
    PetJournal.loadoutBorder:SetAlpha(0)
    PetJournalTutorialButton.Ring:Hide()

    MountJournal.MountCount:StripTextures()
    MountJournal.MountCount:CreateBackdrop()
    PetJournal.PetCount:StripTextures()
    PetJournal.PetCount:CreateBackdrop()
    PetJournal.PetCount:SetWidth(140)
    MountJournal.MountDisplay.ModelScene:CreateBackdrop()
    S:ReskinIcon(MountJournal.MountDisplay.InfoButton.Icon)
    S:ReskinModelControl(MountJournal.MountDisplay.ModelScene)

    S:Reskin(MountJournalMountButton)
    S:Reskin(PetJournalSummonButton)
    S:Reskin(PetJournalFindBattle)

    S:ReskinTrimScroll(MountJournal.ScrollBar)
    hooksecurefunc(MountJournal.ScrollBox, "Update", reskinFrameButton)
    hooksecurefunc("MountJournal_InitMountButton", function(button)
        if not button.bg then return end

        button.icon:SetShown(button.index ~= nil)

        -- selection tints the row fill (Aurora style); mounts have no quality so
        -- the icon border stays default, active is shown via ActiveTexture.
        if button.selectedTexture:IsShown() then
            button.bg:SetBackdropColor(cr, cg, cb, 0.25)
        else
            button.bg:SetBackdropColor(0, 0, 0, 0.25)
        end
    end)

    S:ReskinTrimScroll(PetJournal.ScrollBar)
    hooksecurefunc(PetJournal.ScrollBox, "Update", reskinFrameButton)
    hooksecurefunc("PetJournal_InitPetButton", function(button)
        if not button.bg then return end
        local index = button.index
        if not index then return end

        local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)
        local r, g, b = 0.5, 0.5, 0.5 -- not owned
        if petID and isOwned then
            local rarity = select(5, C_PetJournal.GetPetStats(petID))
            if rarity then
                r, g, b = C_Item.GetItemQualityColor(rarity - 1)
            else
                r, g, b = 1, 1, 1
            end
        end
        button.name:SetTextColor(r, g, b)
        button.icon.bg:SetBackdropBorderColor(r, g, b) -- quality border (ElvUI style)

        if button.selectedTexture:IsShown() then
            button.bg:SetBackdropColor(cr, cg, cb, 0.25)
        else
            button.bg:SetBackdropColor(0, 0, 0, 0.25)
        end
    end)

    S:ReskinEditBox(MountJournalSearchBox)
    S:ReskinEditBox(PetJournalSearchBox)
    S:ReskinFilterButton(PetJournal.FilterDropdown)
    S:ReskinFilterButton(MountJournal.FilterDropdown)

    local togglePlayer = MountJournal.MountDisplay.ModelScene.TogglePlayer
    S:ReskinCheck(togglePlayer)
    togglePlayer:SetSize(28, 28)

    MountJournal.BottomLeftInset:StripTextures()
    local bottomBg = MountJournal.BottomLeftInset:CreateBackdrop()
    bottomBg:SetPoint("TOPLEFT", 3, 0)
    bottomBg:SetPoint("BOTTOMRIGHT", -24, 2)
    PetJournalTutorialButton:SetPoint("TOPLEFT", PetJournal, "TOPLEFT", -14, 14)

    local function reskinToolButton(button)
        button.Border:Hide()
        button:SetPushedTexture(0)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        S:ReskinIcon(button.Icon)
    end
    reskinToolButton(PetJournal.HealPetSpellFrame.Button)
    reskinToolButton(PetJournal.SummonRandomPetSpellFrame.Button)

    PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
    PetJournalLoadoutBorderSlotHeaderText:SetPoint("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 4)

    -- Favourite mount button

    reskinToolButton(MountJournal.SummonRandomFavoriteSpellFrame.Button)

    local function reskinDynamicButton(button, index)
        if button.Border then button.Border:Hide() end
        button:SetPushedTexture(0)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        S:ReskinIcon(select(index, button:GetRegions()), nil)
        button:SetNormalTexture(0)
    end
    reskinDynamicButton(MountJournal.ToggleDynamicFlightFlyoutButton, 3)

    local flyout = MountJournal.ToggleDynamicFlightFlyoutButton.popup or MountJournal.DynamicFlightFlyout
    if flyout then
        flyout.Background:Hide()
        reskinDynamicButton(flyout.OpenDynamicFlightSkillTreeButton, 4)
        reskinDynamicButton(flyout.DynamicFlightModeButton, 4)
    end

    -- Pet card

    local card = PetJournalPetCard

    PetJournalPetCardBG:Hide()
    card.PetInfo.levelBG:SetAlpha(0)
    card.PetInfo.qualityBorder:SetAlpha(0)
    card.AbilitiesBG1:SetAlpha(0)
    card.AbilitiesBG2:SetAlpha(0)
    card.AbilitiesBG3:SetAlpha(0)

    card.PetInfo.level:SetFontObject(GameFontNormal)
    card.PetInfo.level:SetTextColor(1, 1, 1)

    card.PetInfo.icon.bg = S:ReskinIcon(card.PetInfo.icon)

    card:CreateBackdrop()

    for i = 2, 12 do
        select(i, card.xpBar:GetRegions()):Hide()
    end

    card.xpBar:SetStatusBarTexture(DB.bdTex)
    card.xpBar:CreateBackdrop()

    PetJournalPetCardHealthFramehealthStatusBarLeft:Hide()
    PetJournalPetCardHealthFramehealthStatusBarRight:Hide()
    PetJournalPetCardHealthFramehealthStatusBarMiddle:Hide()
    PetJournalPetCardHealthFramehealthStatusBarBGMiddle:Hide()

    card.HealthFrame.healthBar:SetStatusBarTexture(DB.bdTex)
    card.HealthFrame.healthBar:CreateBackdrop()

    for i = 1, 6 do
        local bu = card["spell" .. i]
        S:ReskinIcon(bu.icon)
    end

    hooksecurefunc("PetJournal_UpdatePetCard", function(self)
        local border = self.PetInfo.qualityBorder
        local r, g, b

        if border:IsShown() then
            r, g, b = self.PetInfo.qualityBorder:GetVertexColor()
        else
            r, g, b = 0, 0, 0
        end

        self.PetInfo.icon.bg:SetBackdropBorderColor(r, g, b)
    end)

    -- Pet loadout

    for i = 1, 3 do
        local bu = PetJournal.Loadout["Pet" .. i]

        _G["PetJournalLoadoutPet" .. i .. "BG"]:Hide()

        bu.iconBorder:SetAlpha(0)
        bu.qualityBorder:SetTexture("")
        bu.levelBG:SetAlpha(0)
        bu.helpFrame:GetRegions():Hide()
        bu.dragButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

        bu.level:SetFontObject(GameFontNormal)
        bu.level:SetTextColor(1, 1, 1)

        bu.icon.bg = S:ReskinIcon(bu.icon)

        bu.setButton:GetRegions():SetPoint("TOPLEFT", bu.icon, -5, 5)
        bu.setButton:GetRegions():SetPoint("BOTTOMRIGHT", bu.icon, 5, -5)

        bu:CreateBackdrop()

        for j = 2, 12 do
            select(j, bu.xpBar:GetRegions()):Hide()
        end

        bu.xpBar:SetStatusBarTexture(DB.bdTex)
        bu.xpBar:CreateBackdrop()

        bu.healthFrame.healthBar:StripTextures()
        bu.healthFrame.healthBar:SetStatusBarTexture(DB.bdTex)
        bu.healthFrame.healthBar:CreateBackdrop()

        for j = 1, 3 do
            local spell = bu["spell" .. j]

            spell:SetPushedTexture(0)
            spell:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            spell.selected:SetTexture(DB.pushedTex)
            spell:GetRegions():Hide()

            local flyoutArrow = spell.FlyoutArrow
            S:SetupArrow(flyoutArrow, "down")
            flyoutArrow:SetSize(14, 14)
            flyoutArrow:SetTexCoord(0, 1, 0, 1)

            S:ReskinIcon(spell.icon)
        end
    end

    hooksecurefunc("PetJournal_UpdatePetLoadOut", function()
        for i = 1, 3 do
            local bu = PetJournal.Loadout["Pet" .. i]

            bu.icon.bg:SetShown(not bu.helpFrame:IsShown())
            bu.icon.bg:SetBackdropBorderColor(bu.qualityBorder:GetVertexColor())

            bu.dragButton:SetEnabled(not bu.helpFrame:IsShown())
        end
    end)

    PetJournal.SpellSelect.BgEnd:Hide()
    PetJournal.SpellSelect.BgTiled:Hide()

    for i = 1, 2 do
        local bu = PetJournal.SpellSelect["Spell" .. i]

        bu:SetCheckedTexture(DB.pushedTex)
        bu:SetPushedTexture(0)
        bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

        S:ReskinIcon(bu.icon)
    end

    -- [[ Toy box ]]

    local ToyBox = ToyBox
    local iconsFrame = ToyBox.iconsFrame

    iconsFrame:StripTextures()
    S:ReskinEditBox(ToyBox.searchBox)
    S:ReskinFilterButton(ToyBox.FilterDropdown)
    S:ReskinArrow(ToyBox.PagingFrame.PrevPageButton, "left")
    S:ReskinArrow(ToyBox.PagingFrame.NextPageButton, "right")

    -- Progress bar

    local toyProgress = ToyBox.progressBar
    toyProgress.border:Hide()
    toyProgress:DisableDrawLayer("BACKGROUND")

    toyProgress.text:SetPoint("CENTER", 0, 1)
    toyProgress:SetStatusBarTexture(DB.bdTex)

    toyProgress:CreateBackdrop()

    -- Toys!

    local function changeTextColor(text)
        if text.isSetting then return end
        text.isSetting = true

        local bu = text:GetParent()
        local itemID = bu.itemID

        if PlayerHasToy(itemID) then
            local quality = select(3, C_Item.GetItemInfo(itemID))
            if quality then
                local r, g, b = C_Item.GetItemQualityColor(quality)
                text:SetTextColor(r, g, b)
                if bu.iconbg then bu.iconbg:SetBackdropBorderColor(r, g, b) end -- quality border
            else
                text:SetTextColor(1, 1, 1)
                if bu.iconbg then bu.iconbg:SetBackdropBorderColor(0, 0, 0) end
            end
        else
            text:SetTextColor(0.5, 0.5, 0.5)
            if bu.iconbg then bu.iconbg:SetBackdropBorderColor(0, 0, 0) end
        end

        text.isSetting = nil
    end

    for i = 1, 18 do
        local bu = iconsFrame["spellButton" .. i]
        local ic = bu.iconTexture

        bu:SetPushedTexture(0)
        bu:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        bu:GetHighlightTexture():SetAllPoints(ic)
        bu.cooldown:SetAllPoints(ic)
        bu.slotFrameCollected:SetTexture("")
        bu.slotFrameUncollected:SetTexture("")
        bu.iconbg = S:ReskinIcon(ic)

        hooksecurefunc(bu.name, "SetTextColor", changeTextColor)
    end

    -- [[ Heirlooms ]]

    local HeirloomsJournal = HeirloomsJournal
    local heirloomIcons = HeirloomsJournal.iconsFrame

    heirloomIcons:StripTextures()
    S:ReskinEditBox(HeirloomsJournalSearchBox)
    S:ReskinDropDown(HeirloomsJournal.ClassDropdown)
    S:ReskinFilterButton(HeirloomsJournal.FilterDropdown)
    S:ReskinArrow(HeirloomsJournal.PagingFrame.PrevPageButton, "left")
    S:ReskinArrow(HeirloomsJournal.PagingFrame.NextPageButton, "right")

    hooksecurefunc(HeirloomsJournal, "UpdateButton", function(_, button)
        button.level:SetFontObject("GameFontWhiteSmall")
        button.special:SetTextColor(1, 0.8, 0)
    end)

    -- Progress bar

    local heirloomProgress = HeirloomsJournal.progressBar
    heirloomProgress.border:Hide()
    heirloomProgress:DisableDrawLayer("BACKGROUND")

    heirloomProgress.text:SetPoint("CENTER", 0, 1)
    heirloomProgress:SetStatusBarTexture(DB.bdTex)

    heirloomProgress:CreateBackdrop()

    -- Buttons

    local hr, hg, hb = C_Item.GetItemQualityColor(Enum.ItemQuality.Heirloom or 7) -- heirloom quality color

    hooksecurefunc("HeirloomsJournal_UpdateButton", function(button)
        if not button.__styled then
            local ic = button.iconTexture

            button.slotFrameCollected:SetTexture("")
            button.slotFrameUncollected:SetTexture("")
            button.levelBackground:SetAlpha(0)
            button:SetPushedTexture(0)
            button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            button:GetHighlightTexture():SetAllPoints(ic)

            button.iconTextureUncollected:SetTexCoord(unpack(DB.TexCoord))
            button.bg = S:ReskinIcon(ic)

            button.level:ClearAllPoints()
            button.level:SetPoint("BOTTOM", 0, 1)

            local newLevelBg = button:CreateTexture(nil, "OVERLAY")
            newLevelBg:SetColorTexture(0, 0, 0, 0.5)
            newLevelBg:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 4, 5)
            newLevelBg:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 5)
            newLevelBg:SetHeight(11)
            button.newLevelBg = newLevelBg

            button.__styled = true
        end

        if button.iconTexture:IsShown() then
            button.name:SetTextColor(1, 1, 1)
            button.bg:SetBackdropBorderColor(hr, hg, hb)
            button.newLevelBg:Show()
        else
            button.name:SetTextColor(0.5, 0.5, 0.5)
            button.bg:SetBackdropBorderColor(0, 0, 0)
            button.newLevelBg:Hide()
        end
    end)

    hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", function()
        for i = 1, #HeirloomsJournal.heirloomHeaderFrames do
            local header = HeirloomsJournal.heirloomHeaderFrames[i]
            if not header.__styled then
                header.text:SetTextColor(1, 1, 1)
                header.text:FontTemplate(nil, 16)

                header.__styled = true
            end
        end

        for i = 1, #HeirloomsJournal.heirloomEntryFrames do
            local button = HeirloomsJournal.heirloomEntryFrames[i]

            if button.iconTexture:IsShown() then
                button.name:SetTextColor(1, 1, 1)
                if button.bg then button.bg:SetBackdropBorderColor(hr, hg, hb) end
                if button.newLevelBg then button.newLevelBg:Show() end
            else
                button.name:SetTextColor(0.5, 0.5, 0.5)
                if button.bg then button.bg:SetBackdropBorderColor(0, 0, 0) end
                if button.newLevelBg then button.newLevelBg:Hide() end
            end
        end
    end)

    -- [[ WardrobeCollectionFrame ]]

    local WardrobeCollectionFrame = WardrobeCollectionFrame
    local ItemsCollectionFrame = WardrobeCollectionFrame.ItemsCollectionFrame

    ItemsCollectionFrame:StripTextures()
    S:ReskinFilterButton(WardrobeCollectionFrame.FilterButton)
    S:ReskinEditBox(WardrobeCollectionFrameSearchBox)
    S:ReskinDropDown(WardrobeCollectionFrame.ClassDropdown)
    S:ReskinDropDown(ItemsCollectionFrame.WeaponDropdown)

    hooksecurefunc(WardrobeCollectionFrame, "SetTab", function(self, tabID)
        for index = 1, 2 do
            local tab = self.Tabs[index]
            if not tab.bg then S:ReskinTab(tab) end
            if tabID == index then
                tab.bg:SetBackdropColor(cr, cg, cb, 0.25)
            else
                tab.bg:SetBackdropColor(0, 0, 0, 0.25)
            end
        end
    end)

    S:ReskinArrow(ItemsCollectionFrame.PagingFrame.PrevPageButton, "left")
    S:ReskinArrow(ItemsCollectionFrame.PagingFrame.NextPageButton, "right")
    ItemsCollectionFrame.BGCornerTopLeft:SetAlpha(0)
    ItemsCollectionFrame.BGCornerTopRight:SetAlpha(0)

    local wardrobeProgress = WardrobeCollectionFrame.progressBar
    wardrobeProgress:DisableDrawLayer("BACKGROUND")
    select(2, wardrobeProgress:GetRegions()):Hide()
    wardrobeProgress.text:SetPoint("CENTER", 0, 1)
    wardrobeProgress:SetStatusBarTexture(DB.bdTex)
    wardrobeProgress:CreateBackdrop()

    -- ItemSetsCollection

    local SetsCollectionFrame = WardrobeCollectionFrame.SetsCollectionFrame
    SetsCollectionFrame.LeftInset:Hide()
    SetsCollectionFrame.RightInset:Hide()
    SetsCollectionFrame.Model:CreateBackdrop()

    S:ReskinTrimScroll(SetsCollectionFrame.ListContainer.ScrollBar)
    hooksecurefunc(SetsCollectionFrame.ListContainer.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                child.Background:Hide()
                child.HighlightTexture:SetTexture("")

                local icon = child.IconFrame and child.IconFrame.Icon or child.Icon
                if icon then
                    icon:SetSize(42, 42)
                    S:ReskinIcon(icon)
                    if child.IconCover then child.IconCover:SetOutside(icon) end
                end

                child.SelectedTexture:SetDrawLayer("BACKGROUND")
                child.SelectedTexture:SetColorTexture(cr, cg, cb, 0.25)
                child.SelectedTexture:ClearAllPoints()
                child.SelectedTexture:SetPoint("TOPLEFT", 4, -2)
                child.SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)
                child.SelectedTexture:CreateBackdrop()

                child.__styled = true
            end
        end
    end)

    local DetailsFrame = SetsCollectionFrame.DetailsFrame
    DetailsFrame.ModelFadeTexture:Hide()
    DetailsFrame.IconRowBackground:Hide()
    S:ReskinDropDown(DetailsFrame.VariantSetsDropdown)

    hooksecurefunc(SetsCollectionFrame, "SetItemFrameQuality", function(_, itemFrame)
        local ic = itemFrame.Icon
        if not ic.bg then ic.bg = S:ReskinIcon(ic) end
        itemFrame.IconBorder:SetTexture("")

        if itemFrame.collected then
            local quality = C_TransmogCollection.GetSourceInfo(itemFrame.sourceID).quality
            local color = DB.QualityColors[quality or 1]
            ic.bg:SetBackdropBorderColor(color.r, color.g, color.b)
        else
            ic.bg:SetBackdropBorderColor(0, 0, 0)
        end
    end)

    -- HPetBattleAny
    local reskinHPet
    CollectionsJournal:HookScript("OnShow", function()
        if not C_AddOns.IsAddOnLoaded("HPetBattleAny") then return end
        if not reskinHPet then
            if HPetInitOpenButton then S:Reskin(HPetInitOpenButton) end
            if HPetAllInfoButton then
                HPetAllInfoButton:StripTextures()
                S:Reskin(HPetAllInfoButton)
            end

            if PetJournalBandageButton then
                PetJournalBandageButton:SetPushedTexture(0)
                PetJournalBandageButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                PetJournalBandageButtonBorder:Hide()
                PetJournalBandageButton:SetPoint("TOPRIGHT", PetJournalHealPetButton, "TOPLEFT", -3, 0)
                PetJournalBandageButton:SetPoint("BOTTOMLEFT", PetJournalHealPetButton, "BOTTOMLEFT", -35, 0)
                S:ReskinIcon(PetJournalBandageButtonIcon)
            end
            reskinHPet = true
        end
    end)

    -- WarbandSceneJournal
    if WarbandSceneJournal then
        local warbandIcons = WarbandSceneJournal.IconsFrame
        if warbandIcons then
            warbandIcons:StripTextures()

            local controls = warbandIcons.Icons and warbandIcons.Icons.Controls
            if controls then
                local showCheck = controls and controls.ShowOwned and controls.ShowOwned.Checkbox
                if showCheck then
                    -- Checkbox sits in a 20x20 ShowOwned slot laid out by a
                    -- HorizontalLayoutFrame; do NOT SetSize it (28 overflows the
                    -- slot and breaks the row's vertical centering). Reskin only.
                    S:ReskinCheck(showCheck)
                end

                if controls.PagingControls then
                    S:ReskinArrow(controls.PagingControls.PrevPageButton, "left")
                    S:ReskinArrow(controls.PagingControls.NextPageButton, "right")

                    -- ReskinArrow resized the buttons; re-flow the horizontal
                    -- layout frames so PageText + arrows re-center on new sizes
                    -- (otherwise the arrows keep the original, higher baseline).
                    if controls.PagingControls.Layout then controls.PagingControls:Layout() end
                    if controls.Layout then controls:Layout() end
                end
            end
        end
    end
end

S:AddCallbackForAddon("Blizzard_Collections", "Collectables")
