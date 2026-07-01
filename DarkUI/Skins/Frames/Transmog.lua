local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Transmogrification UI
-- Ported from AuroraClassic AddOns/Blizzard_Transmog.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc
local pairs = pairs

function S:Transmog()
    if not (C.skins.enable and C.skins.transmogrify) then return end

    S:ReskinPortraitFrame(TransmogFrame)

    TransmogFrame.OutfitCollection:StripTextures()
    S:ReskinTrimScrollBar(TransmogFrame.OutfitCollection.OutfitList.ScrollBar)
    S:ReskinButton(TransmogFrame.OutfitCollection.SaveOutfitButton)
    S:ReskinButton(TransmogFrame.OutfitCollection.PurchaseOutfitButton)
    TransmogFrame.OutfitCollection.MoneyFrame:StripTextures()
    TransmogFrame.OutfitCollection.MoneyFrame:CreateBackdrop()

    S:ReskinIconSelectionFrame(TransmogFrame.OutfitPopup)
    TransmogFrame.CharacterPreview:StripTextures()
    TransmogFrame.CharacterPreview:CreateBackdrop():SetInside()
    TransmogFrame.CharacterPreview.Gradients:Hide()
    S:ReskinCheck(TransmogFrame.CharacterPreview.ToggleOptions.HideIgnoredToggle.Checkbox)
    S:ReskinCheck(TransmogFrame.CharacterPreview.ToggleOptions.SheatheWeaponToggle.Checkbox)
    S:ReskinButton(TransmogFrame.CharacterPreview.ClearAllPendingButton)

    TransmogFrame.WardrobeCollection:StripTextures()
    for _, tab in pairs(TransmogFrame.WardrobeCollection.TabHeaders.tabs) do
        if tab then S:ReskinTab(tab) end
    end

    local TabContent = TransmogFrame.WardrobeCollection.TabContent
    if TabContent then
        TabContent:StripTextures()
        S:ReskinEditBox(TabContent.ItemsFrame.SearchBox)
        S:ReskinFilterButton(TabContent.ItemsFrame.FilterButton)
        S:ReskinDropDown(TabContent.ItemsFrame.WeaponDropdown)
        S:ReskinEditBox(TabContent.SetsFrame.SearchBox)
        S:ReskinFilterButton(TabContent.SetsFrame.FilterButton)
        S:ReskinButton(TabContent.CustomSetsFrame.NewCustomSetButton)
        S:ReskinButton(TabContent.SituationsFrame.DefaultsButton)
        S:ReskinCheck(TabContent.SituationsFrame.EnabledToggle.Checkbox)
        S:ReskinButton(TabContent.SituationsFrame.ApplyButton)

        hooksecurefunc(TabContent.SituationsFrame, "Init", function()
            for frame in TabContent.SituationsFrame.SituationFramePool:EnumerateActive() do
                if not frame.__styled then
                    if frame.Dropdown then S:ReskinDropDown(frame.Dropdown) end
                    frame.__styled = true
                end
            end
        end)

        S:ReskinArrow(TabContent.ItemsFrame.PagedContent.PagingControls.PrevPageButton, "left")
        S:ReskinArrow(TabContent.ItemsFrame.PagedContent.PagingControls.NextPageButton, "right")
        S:ReskinArrow(TabContent.SetsFrame.PagedContent.PagingControls.PrevPageButton, "left")
        S:ReskinArrow(TabContent.SetsFrame.PagedContent.PagingControls.NextPageButton, "right")
        S:ReskinArrow(TabContent.CustomSetsFrame.PagedContent.PagingControls.PrevPageButton, "left")
        S:ReskinArrow(TabContent.CustomSetsFrame.PagedContent.PagingControls.NextPageButton, "right")
    end
end

S:AddCallbackForAddon("Blizzard_Transmog", "Transmog")
