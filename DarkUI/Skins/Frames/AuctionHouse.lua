local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Auction House UI
-- Ported from AuroraClassic AddOns/Blizzard_AuctionHouseUI.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G
local select, hooksecurefunc = select, hooksecurefunc

local function reskinAuctionButton(button)
    S:ReskinButton(button)
    button:SetSize(22, 22)
end

local function reskinSellPanel(frame)
    frame:StripTextures()

    local itemDisplay = frame.ItemDisplay
    itemDisplay:StripTextures()
    itemDisplay:CreateBackdrop()

    local itemButton = itemDisplay.ItemButton
    if itemButton.IconMask then itemButton.IconMask:Hide() end
    itemButton.EmptyBackground:Hide()
    itemButton:SetPushedTexture(0)
    itemButton.Highlight:SetColorTexture(1, 1, 1, 0.25)
    itemButton.Highlight:SetAllPoints(itemButton.Icon)
    itemButton.bg = S:ReskinIcon(itemButton.Icon)
    S:ReskinIconBorder(itemButton.IconBorder)

    S:ReskinInput(frame.QuantityInput.InputBox, 24)
    S:ReskinButton(frame.QuantityInput.MaxButton)
    S:ReskinInput(frame.PriceInput.MoneyInputFrame.GoldBox, 24)
    S:ReskinInput(frame.PriceInput.MoneyInputFrame.SilverBox, 24)
    if frame.SecondaryPriceInput then
        S:ReskinInput(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox, 24)
        S:ReskinInput(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox, 24)
    end
    S:ReskinDropDown(frame.Duration.Dropdown)
    S:ReskinButton(frame.PostButton)
    if frame.BuyoutModeCheckButton then
        S:ReskinCheck(frame.BuyoutModeCheckButton)
        frame.BuyoutModeCheckButton:SetSize(28, 28)
    end
end

local function reskinListIcon(frame)
    if not frame.tableBuilder then return end

    for i = 1, 22 do
        local row = frame.tableBuilder.rows[i]
        if row then
            for j = 1, 4 do
                local cell = row.cells and row.cells[j]
                if cell and cell.Icon then
                    if not cell.__styled then
                        cell.Icon.bg = S:ReskinIcon(cell.Icon)
                        if cell.IconBorder then cell.IconBorder:Hide() end
                        cell.__styled = true
                    end
                    cell.Icon.bg:SetShown(cell.Icon:IsShown())
                end
            end
        end
    end
end

local function reskinSummaryButtons(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        if child and child.Icon then
            if not child.__styled then
                child.Icon.bg = S:ReskinIcon(child.Icon)
                if child.IconBorder then child.IconBorder:SetAlpha(0) end
                child.__styled = true
            end
            child.Icon.bg:SetShown(child.Icon:IsShown())
        end
    end
end

local function reskinListHeader(frame)
    local maxHeaders = frame.HeaderContainer:GetNumChildren()
    for i = 1, maxHeaders do
        local header = select(i, frame.HeaderContainer:GetChildren())
        if header and not header.__styled then
            header:DisableDrawLayer("BACKGROUND")
            header.bg = header:CreateBackdrop()
            local hl = header:GetHighlightTexture()
            hl:SetColorTexture(1, 1, 1, 0.1)
            hl:SetAllPoints(header.bg)

            header.__styled = true
        end

        if header and header.bg then header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2) end
    end

    reskinListIcon(frame)
end

local function reskinSellList(frame, hasHeader)
    frame:StripTextures()
    if frame.RefreshFrame then reskinAuctionButton(frame.RefreshFrame.RefreshButton) end
    S:ReskinTrimScrollBar(frame.ScrollBar)
    if hasHeader then
        frame.ScrollBox:CreateBackdrop()
        hooksecurefunc(frame, "RefreshScrollFrame", reskinListHeader)
    else
        hooksecurefunc(frame.ScrollBox, "Update", reskinSummaryButtons)
    end
end

local function reskinItemDisplay(itemDisplay, needInit)
    itemDisplay:StripTextures()
    local bg = itemDisplay:CreateBackdrop()
    bg:SetPoint("TOPLEFT", 3, -3)
    bg:SetPoint("BOTTOMRIGHT", -3, 0)
    local itemButton = itemDisplay.ItemButton
    if itemButton.CircleMask then
        itemButton.CircleMask:Hide()
        itemButton.useCircularIconBorder = true
    end
    itemButton.bg = S:ReskinIcon(itemButton.Icon)
    S:ReskinIconBorder(itemButton.IconBorder, needInit)

    local hl = itemButton:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetInside(itemButton.bg)
end

local function reskinItemList(frame, hasHeader)
    frame:StripTextures()
    frame.ScrollBox:CreateBackdrop()
    S:ReskinTrimScrollBar(frame.ScrollBar)
    if frame.RefreshFrame then reskinAuctionButton(frame.RefreshFrame.RefreshButton) end
    if hasHeader then hooksecurefunc(frame, "RefreshScrollFrame", reskinListHeader) end
end

function S:AuctionHouse()
    if not (C.skins.enable and C.skins.auctionhouse) then return end

    S:ReskinPortraitFrame(AuctionHouseFrame)
    AuctionHouseFrame.MoneyFrameBorder:StripTextures()
    AuctionHouseFrame.MoneyFrameBorder:CreateBackdrop()
    AuctionHouseFrame.MoneyFrameInset:StripTextures()
    S:ReskinTab(AuctionHouseFrameBuyTab)
    AuctionHouseFrameBuyTab:SetPoint("BOTTOMLEFT", 20, -30)
    S:ReskinTab(AuctionHouseFrameSellTab)
    S:ReskinTab(AuctionHouseFrameAuctionsTab)

    local searchBar = AuctionHouseFrame.SearchBar
    reskinAuctionButton(searchBar.FavoritesSearchButton)
    S:ReskinInput(searchBar.SearchBox)
    S:ReskinButton(searchBar.SearchButton)

    local filterButton = searchBar.FilterButton
    S:ReskinFilterButton(filterButton)
    S:ReskinFilterReset(filterButton.ClearFiltersButton)

    AuctionHouseFrame.CategoriesList:StripTextures()
    S:ReskinTrimScrollBar(AuctionHouseFrame.CategoriesList.ScrollBar)
    reskinItemList(AuctionHouseFrame.BrowseResultsFrame.ItemList, true)

    hooksecurefunc("AuctionHouseFilterButton_SetUp", function(button)
        button.NormalTexture:SetAlpha(0)
        button.SelectedTexture:SetColorTexture(0, 0.6, 1, 0.3)
        button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
    end)

    local itemBuyFrame = AuctionHouseFrame.ItemBuyFrame
    S:ReskinButton(itemBuyFrame.BackButton)
    S:ReskinButton(itemBuyFrame.BidFrame.BidButton)
    S:ReskinButton(itemBuyFrame.BuyoutFrame.BuyoutButton)
    reskinItemDisplay(itemBuyFrame.ItemDisplay)
    reskinItemList(itemBuyFrame.ItemList, true)
    if BidAmountGold then
        S:ReskinInput(BidAmountGold)
        S:ReskinInput(BidAmountSilver)
    end

    local commBuyFrame = AuctionHouseFrame.CommoditiesBuyFrame
    S:ReskinButton(commBuyFrame.BackButton)
    local buyDisplay = commBuyFrame.BuyDisplay
    buyDisplay:StripTextures()
    S:ReskinInput(buyDisplay.QuantityInput.InputBox)
    S:ReskinButton(buyDisplay.BuyButton)
    reskinItemDisplay(buyDisplay.ItemDisplay)
    reskinItemList(commBuyFrame.ItemList)

    local wowTokenResults = AuctionHouseFrame.WoWTokenResults
    wowTokenResults:StripTextures()
    S:ReskinButton(wowTokenResults.Buyout)
    reskinItemDisplay(wowTokenResults.TokenDisplay, true)
    S:ReskinTrimScrollBar(wowTokenResults.DummyScrollBar)

    local gameTimeTutorial = wowTokenResults.GameTimeTutorial
    S:ReskinPortraitFrame(gameTimeTutorial)
    S:ReskinButton(gameTimeTutorial.RightDisplay.StoreButton)
    gameTimeTutorial.LeftDisplay.Label:SetTextColor(1, 1, 1)
    gameTimeTutorial.LeftDisplay.Tutorial1:SetTextColor(1, 0.8, 0)
    gameTimeTutorial.RightDisplay.Label:SetTextColor(1, 1, 1)
    gameTimeTutorial.RightDisplay.Tutorial1:SetTextColor(1, 0.8, 0)

    local woWTokenSellFrame = AuctionHouseFrame.WoWTokenSellFrame
    woWTokenSellFrame:StripTextures()
    S:ReskinButton(woWTokenSellFrame.PostButton)
    woWTokenSellFrame.DummyItemList:StripTextures()
    woWTokenSellFrame.DummyItemList:CreateBackdrop()
    S:ReskinTrimScrollBar(woWTokenSellFrame.DummyItemList.DummyScrollBar)
    reskinAuctionButton(woWTokenSellFrame.DummyRefreshButton)
    reskinItemDisplay(woWTokenSellFrame.ItemDisplay)

    reskinSellPanel(AuctionHouseFrame.ItemSellFrame)
    reskinSellPanel(AuctionHouseFrame.CommoditiesSellFrame)
    reskinSellList(AuctionHouseFrame.CommoditiesSellList, true)
    reskinSellList(AuctionHouseFrame.ItemSellList, true)
    reskinSellList(AuctionHouseFrameAuctionsFrame.SummaryList)
    reskinSellList(AuctionHouseFrameAuctionsFrame.AllAuctionsList, true)
    reskinSellList(AuctionHouseFrameAuctionsFrame.BidsList, true)
    reskinSellList(AuctionHouseFrameAuctionsFrame.CommoditiesList, true)
    reskinSellList(AuctionHouseFrameAuctionsFrame.ItemList, true)
    reskinItemDisplay(AuctionHouseFrameAuctionsFrame.ItemDisplay)

    S:ReskinTab(AuctionHouseFrameAuctionsFrameAuctionsTab)
    S:ReskinTab(AuctionHouseFrameAuctionsFrameBidsTab)
    S:ReskinButton(AuctionHouseFrameAuctionsFrame.CancelAuctionButton)
    S:ReskinButton(AuctionHouseFrameAuctionsFrame.BidFrame.BidButton)
    S:ReskinButton(AuctionHouseFrameAuctionsFrame.BuyoutFrame.BuyoutButton)

    local buyDialog = AuctionHouseFrame.BuyDialog
    buyDialog:StripTextures()
    S:CreateBackground(buyDialog)
    S:ReskinButton(buyDialog.OkayButton)
    S:ReskinButton(buyDialog.BuyNowButton)
    S:ReskinButton(buyDialog.CancelButton)

    local multisellFrame = AuctionHouseMultisellProgressFrame
    multisellFrame:StripTextures()
    S:CreateBackground(multisellFrame)
    local progressBar = multisellFrame.ProgressBar
    progressBar:StripTextures()
    S:ReskinIcon(progressBar.Icon)
    progressBar:SetStatusBarTexture(C.media.texture.status)
    progressBar:CreateBackdrop()
    local close = multisellFrame.CancelButton
    S:ReskinClose(close)
    close:ClearAllPoints()
    close:SetPoint("LEFT", progressBar, "RIGHT", 3, 0)
end

S:AddCallbackForAddon("Blizzard_AuctionHouseUI", "AuctionHouse")
