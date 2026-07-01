local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Professions Customer Orders
-- Ported from AuroraClassic AddOns/Blizzard_ProfessionsCustomerOrders.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
-- Note: B.CreateBDFrame(f, alpha) → f:CreateBackdrop() + SetBackdropColor.
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function hideCategoryButton(button)
    button.NormalTexture:Hide()
    button.SelectedTexture:SetColorTexture(0, 0.6, 1, 0.3)
    button.HighlightTexture:SetColorTexture(1, 1, 1, 0.1)
end

local function reskinListIcon(frame)
    if not frame.tableBuilder then return end

    for i = 1, 22 do
        local row = frame.tableBuilder.rows[i]
        if row then
            local cell = row.cells and row.cells[1]
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

local function reskinListHeader(headerContainer)
    local maxHeaders = headerContainer:GetNumChildren()
    for i = 1, maxHeaders do
        local header = select(i, headerContainer:GetChildren())
        if header and not header.__styled then
            header:DisableDrawLayer("BACKGROUND")
            header.bg = header:CreateBackdrop()
            header.bg:SetBackdropColor(0, 0, 0, 0)
            local hl = header:GetHighlightTexture()
            hl:SetColorTexture(1, 1, 1, 0.1)
            hl:SetAllPoints(header.bg)

            header.__styled = true
        end

        if header and header.bg then header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2) end
    end
end

local function reskinBrowseOrders(frame)
    local headerContainer = frame.RecipeList and frame.RecipeList.HeaderContainer
    if headerContainer then reskinListHeader(headerContainer) end
end

local function reskinMoneyInput(box)
    S:ReskinEditBox(box)
    box.backdrop:SetPoint("TOPLEFT", 0, -3)
    box.backdrop:SetPoint("BOTTOMRIGHT", 0, 3)
end

local function reskinContainer(container)
    local button = container.Button
    button.bg = S:ReskinIcon(button.Icon)
    S:ReskinIconBorder(button.IconBorder)
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

    local box = container.EditBox
    box:DisableDrawLayer("BACKGROUND")
    S:ReskinEditBox(box)
    S:ReskinArrow(box.DecrementButton, "left")
    S:ReskinArrow(box.IncrementButton, "right")
end

local function reskinOrderIcon(child)
    if child.__styled then return end

    local button = child:GetChildren()
    if button and button.IconBorder then
        button.bg = S:ReskinIcon(button.Icon)
        S:ReskinIconBorder(button.IconBorder)
    end
    child.__styled = true
end

function S:ProfessionsOrders()
    if not (C.skins.enable and C.skins.tradeskill) then return end

    local frame = _G.ProfessionsCustomerOrdersFrame

    S:ReskinPortraitFrame(frame)
    for i = 1, 2 do
        S:ReskinTab(frame.Tabs[i])
    end
    frame.MoneyFrameBorder:StripTextures()
    local moneyBg = frame.MoneyFrameBorder:CreateBackdrop()
    moneyBg:SetBackdropColor(0, 0, 0, 0.25)
    frame.MoneyFrameInset:StripTextures()

    local searchBar = frame.BrowseOrders.SearchBar
    S:ReskinButton(searchBar.FavoritesSearchButton)
    searchBar.FavoritesSearchButton:SetSize(22, 22)
    S:ReskinEditBox(searchBar.SearchBox)
    S:ReskinButton(searchBar.SearchButton)
    S:ReskinFilterButton(searchBar.FilterDropdown)

    frame.BrowseOrders.CategoryList:StripTextures()
    S:ReskinTrimScrollBar(frame.BrowseOrders.CategoryList.ScrollBar)

    hooksecurefunc(frame.BrowseOrders.CategoryList.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.Text and not child.__styled then
                hideCategoryButton(child)
                hooksecurefunc(child, "Init", hideCategoryButton)

                child.__styled = true
            end
        end
    end)

    local recipeList = frame.BrowseOrders.RecipeList
    recipeList:StripTextures()
    local recipeScrollBg = recipeList.ScrollBox:CreateBackdrop()
    recipeScrollBg:SetBackdropColor(0, 0, 0, 0.25)
    recipeScrollBg:SetInside()
    S:ReskinTrimScrollBar(recipeList.ScrollBar)

    hooksecurefunc(frame.BrowseOrders, "SetupTable", reskinBrowseOrders)
    hooksecurefunc(frame.BrowseOrders, "StartSearch", reskinListIcon)

    -- Form
    S:ReskinButton(frame.Form.BackButton)
    S:ReskinCheck(frame.Form.AllocateBestQualityCheckbox)
    S:ReskinCheck(frame.Form.TrackRecipeCheckbox.Checkbox)

    frame.Form.RecipeHeader:Hide()
    local recipeHeaderBg = frame.Form.RecipeHeader:CreateBackdrop()
    recipeHeaderBg:SetBackdropColor(0, 0, 0, 0.25)
    frame.Form.LeftPanelBackground:StripTextures()
    frame.Form.RightPanelBackground:StripTextures()

    local itemButton = frame.Form.OutputIcon
    itemButton.CircleMask:Hide()
    itemButton.bg = S:ReskinIcon(itemButton.Icon)
    S:ReskinIconBorder(itemButton.IconBorder, true, true)

    local hl = itemButton:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetInside(itemButton.bg)

    S:ReskinEditBox(frame.Form.OrderRecipientTarget)
    frame.Form.OrderRecipientTarget.backdrop:SetPoint("TOPLEFT", -8, -2)
    frame.Form.OrderRecipientTarget.backdrop:SetPoint("BOTTOMRIGHT", 0, 2)
    S:ReskinDropDown(frame.Form.OrderRecipientDropdown)
    S:ReskinDropDown(frame.Form.MinimumQuality.Dropdown)

    local paymentContainer = frame.Form.PaymentContainer
    paymentContainer.NoteEditBox:StripTextures()
    local noteBg = paymentContainer.NoteEditBox:CreateBackdrop()
    noteBg:SetBackdropColor(0, 0, 0, 0.25)
    noteBg:SetPoint("TOPLEFT", 15, 5)
    noteBg:SetPoint("BOTTOMRIGHT", -18, 0)

    reskinMoneyInput(paymentContainer.TipMoneyInputFrame.GoldBox)
    reskinMoneyInput(paymentContainer.TipMoneyInputFrame.SilverBox)
    S:ReskinDropDown(paymentContainer.DurationDropdown)
    S:ReskinButton(paymentContainer.ListOrderButton)
    S:ReskinButton(paymentContainer.CancelOrderButton)

    local viewButton = paymentContainer.ViewListingsButton
    viewButton:SetAlpha(0)
    local buttonFrame = CreateFrame("Frame", nil, paymentContainer)
    buttonFrame:SetInside(viewButton)
    local tex = buttonFrame:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    tex:SetTexture("Interface\\CURSOR\\Crosshair\\Repair")

    local current = frame.Form.CurrentListings
    current:StripTextures()
    S:CreateBackground(current)
    S:ReskinButton(current.CloseButton)
    S:ReskinTrimScrollBar(current.OrderList.ScrollBar)
    reskinListHeader(current.OrderList.HeaderContainer)
    current.OrderList:StripTextures()
    current:ClearAllPoints()
    current:SetPoint("LEFT", frame, "RIGHT", 10, 0)

    local function resetButton(button)
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
        local bhl = button:GetHighlightTexture()
        bhl:SetColorTexture(1, 1, 1, 0.25)
        bhl:SetInside(button.bg)
    end

    hooksecurefunc(frame.Form, "UpdateReagentSlots", function(self)
        for slot in self.reagentSlotPool:EnumerateActive() do
            local button = slot.Button
            if button and not button.__styled then
                button.bg = S:ReskinIcon(button.Icon)
                S:ReskinIconBorder(button.IconBorder, true, true)
                if button.SlotBackground then button.SlotBackground:Hide() end
                S:ReskinCheck(slot.Checkbox)
                button.HighlightTexture:SetColorTexture(1, 0.8, 0, 0.5)
                button.HighlightTexture:SetInside(button.bg)
                resetButton(button)
                hooksecurefunc(button, "Update", resetButton)

                button.__styled = true
            end
        end
    end)

    local qualityDialog = frame.Form.QualityDialog
    qualityDialog:StripTextures()
    S:CreateBackground(qualityDialog)
    S:ReskinClose(qualityDialog.ClosePanelButton)
    S:ReskinButton(qualityDialog.AcceptButton)
    S:ReskinButton(qualityDialog.CancelButton)
    for i = 1, 3 do
        reskinContainer(qualityDialog["Container" .. i])
    end

    S:ReskinButton(frame.Form.OrderRecipientDisplay.SocialDropdown)

    -- Orders
    S:ReskinButton(frame.MyOrdersPage.RefreshButton)
    frame.MyOrdersPage.OrderList:StripTextures()
    local myOrdersBg = frame.MyOrdersPage.OrderList:CreateBackdrop()
    myOrdersBg:SetBackdropColor(0, 0, 0, 0.25)
    reskinListHeader(frame.MyOrdersPage.OrderList.HeaderContainer)
    S:ReskinTrimScrollBar(frame.MyOrdersPage.OrderList.ScrollBar)

    hooksecurefunc(frame.MyOrdersPage.OrderList.ScrollBox, "Update", function(self) self:ForEachFrame(reskinOrderIcon) end)
end

S:AddCallbackForAddon("Blizzard_ProfessionsCustomerOrders", "ProfessionsOrders")
