local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Professions (Crafting UI)
-- Ported from AuroraClassic AddOns/Blizzard_Professions.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
-- Note: B.CreateBDFrame(f, alpha) → f:CreateBackdrop() (alpha via SetBackdropColor).
------------------------------------------------------------------------

local _G = _G
local select, pairs = select, pairs
local hooksecurefunc = hooksecurefunc

local function reskinFlyoutButton(button)
    if not button.__styled then
        button.bg = S:ReskinIcon(button.Icon)
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        S:ReskinIconBorder(button.IconBorder, true)

        button.__styled = true
    end
end

local function refreshFlyoutButtons(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local button = select(i, self.ScrollTarget:GetChildren())
        if button.IconBorder then reskinFlyoutButton(button) end
    end
end

local flyoutFrame
local function resetFrameStrata(frame) frame.bg:SetFrameStrata("LOW") end

local function reskinProfessionsFlyout(_, parent)
    if flyoutFrame then return end

    for i = 1, parent:GetNumChildren() do
        local child = select(i, parent:GetChildren())
        local checkbox = child.HideUnownedCheckbox
        if checkbox then
            flyoutFrame = child

            flyoutFrame:StripTextures()
            flyoutFrame.bg = S:SetBD(flyoutFrame)
            hooksecurefunc(flyoutFrame, "SetParent", resetFrameStrata)
            S:ReskinCheck(checkbox)
            checkbox.bg:SetInside(nil, 6, 6)
            S:ReskinTrimScroll(flyoutFrame.ScrollBar)
            reskinFlyoutButton(flyoutFrame.UndoItem)
            hooksecurefunc(flyoutFrame.ScrollBox, "Update", refreshFlyoutButtons)

            break
        end
    end
end

local function resetButton(button)
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    local hl = button:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetInside(button.bg)
end

local function reskinSlotButton(button)
    if button and not button.__styled then
        button.bg = S:ReskinIcon(button.Icon)
        S:ReskinIconBorder(button.IconBorder, true, true)
        if button.SlotBackground then button.SlotBackground:Hide() end
        resetButton(button)
        hooksecurefunc(button, "Update", resetButton)

        button.__styled = true
    end
end

local function reskinArrowInput(box)
    box:DisableDrawLayer("BACKGROUND")
    S:ReskinEditBox(box)
    S:ReskinArrow(box.DecrementButton, "left")
    S:ReskinArrow(box.IncrementButton, "right")
end

local function reskinQualityContainer(container)
    local button = container.Button
    button:SetNormalTexture(0)
    button:SetPushedTexture(0)
    button:SetHighlightTexture(0)
    button.bg = S:ReskinIcon(button.Icon)
    S:ReskinIconBorder(button.IconBorder, true)
    reskinArrowInput(container.EditBox)
end

local function reskinProfessionForm(form)
    local button = form.OutputIcon
    if button then
        button.CircleMask:Hide()
        button.bg = S:ReskinIcon(button.Icon)
        S:ReskinIconBorder(button.IconBorder, nil, true)
        local hl = button:GetHighlightTexture()
        hl:SetColorTexture(1, 1, 1, 0.25)
        hl:SetInside(button.bg)
    end

    local trackBox = form.TrackRecipeCheckbox
    if trackBox then
        S:ReskinCheck(trackBox)
        trackBox:SetSize(24, 24)
    end

    local checkBox = form.AllocateBestQualityCheckbox
    if checkBox then
        S:ReskinCheck(checkBox)
        checkBox:SetSize(24, 24)
    end

    local qDialog = form.QualityDialog
    if qDialog then
        qDialog:StripTextures()
        S:SetBD(qDialog)
        S:ReskinClose(qDialog.ClosePanelButton)
        S:Reskin(qDialog.AcceptButton)
        S:Reskin(qDialog.CancelButton)

        reskinQualityContainer(qDialog.Container1)
        reskinQualityContainer(qDialog.Container2)
        reskinQualityContainer(qDialog.Container3)
    end

    hooksecurefunc(form, "Init", function(self)
        for slot in self.reagentSlotPool:EnumerateActive() do
            reskinSlotButton(slot.Button)
        end

        local salvageSlot = form.salvageSlot
        if salvageSlot then reskinSlotButton(salvageSlot.Button) end

        local enchantSlot = form.enchantSlot
        if enchantSlot then reskinSlotButton(enchantSlot.Button) end
    end)
end

local function reskinOutputButtons(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        if not child.__styled then
            local itemContainer = child.ItemContainer
            if itemContainer then
                local item = itemContainer.Item
                item:SetNormalTexture(0)
                item:SetPushedTexture(0)
                item:SetHighlightTexture(0)

                local icon = item:GetRegions()
                item.bg = S:ReskinIcon(icon)
                S:ReskinIconBorder(item.IconBorder, true)
                itemContainer.CritFrame:SetAlpha(0)
                itemContainer.BorderFrame:Hide()
                itemContainer.HighlightNameFrame:SetAlpha(0)
                itemContainer.PushedNameFrame:SetAlpha(0)
                -- backdrop slot freed so next CreateBackdrop is independent
                itemContainer.backdrop = nil
                itemContainer.bg = itemContainer.HighlightNameFrame:CreateBackdrop()
                itemContainer.bg:SetBackdropColor(0, 0, 0, 0.25)
            end

            local bonus = child.CreationBonus
            if bonus then
                local item = bonus.Item
                item:StripTextures(1)
                local icon = item:GetRegions()
                S:ReskinIcon(icon)
            end

            child.__styled = true
        end

        local itemContainer = child.ItemContainer
        if itemContainer then
            local itemBG = itemContainer.bg
            if itemBG then
                if itemContainer.CritFrame:IsShown() then
                    itemBG:SetBackdropBorderColor(1, 0.8, 0)
                else
                    itemBG:SetBackdropBorderColor(0, 0, 0)
                end
            end
        end
    end
end

local function reskinOutputLog(outputLog)
    outputLog:StripTextures()
    S:SetBD(outputLog)
    S:ReskinClose(outputLog.ClosePanelButton)
    S:ReskinTrimScroll(outputLog.ScrollBar)
    hooksecurefunc(outputLog.ScrollBox, "Update", reskinOutputButtons)
end

local function reskinRankBar(rankBar)
    rankBar.Border:Hide()
    rankBar.Background:Hide()
    rankBar.Rank.Text:SetFontObject(Game12Font)
    local fillBg = rankBar.Fill:CreateBackdrop()
    fillBg:SetBackdropColor(0, 0, 0, 1)
    S:ReskinArrow(rankBar.ExpansionDropdownButton, "down")
end

function S:Professions()
    if not (C.skins.enable and C.skins.tradeskill) then return end

    -- Flyout is loaded with ProfessionsTemplates (FrameXML), hook once
    if _G.OpenProfessionsItemFlyout then hooksecurefunc("OpenProfessionsItemFlyout", reskinProfessionsFlyout) end

    local frame = _G.ProfessionsFrame
    local craftingPage = frame.CraftingPage

    S:ReskinPortraitFrame(frame)
    craftingPage.TutorialButton.Ring:Hide()
    S:Reskin(craftingPage.CreateButton)
    S:Reskin(craftingPage.CreateAllButton)
    S:Reskin(craftingPage.ViewGuildCraftersButton)
    reskinArrowInput(craftingPage.CreateMultipleInputBox)
    S:ReskinMinMax(frame.MaximizeMinimize)
    S:ReskinEditBox(craftingPage.MinimizedSearchBox)
    S:ReskinIcon(craftingPage.ConcentrationDisplay.Icon)

    local guildFrame = craftingPage.GuildFrame
    guildFrame:StripTextures()
    local guildBg = guildFrame:CreateBackdrop()
    guildBg:SetBackdropColor(0, 0, 0, 0.25)
    guildFrame.Container:StripTextures()
    local guildContBg = guildFrame.Container:CreateBackdrop()
    guildContBg:SetBackdropColor(0, 0, 0, 0.25)
    S:ReskinTrimScroll(guildFrame.Container.ScrollBar)

    for i = 1, 3 do
        local tab = select(i, frame.TabSystem:GetChildren())
        if tab then S:ReskinTab(tab) end
    end

    -- Tools
    local slots = {
        "Prof0ToolSlot",
        "Prof0Gear0Slot",
        "Prof0Gear1Slot",
        "Prof1ToolSlot",
        "Prof1Gear0Slot",
        "Prof1Gear1Slot",
        "CookingToolSlot",
        "CookingGear0Slot",
        "FishingToolSlot",
        "FishingGear0Slot",
        "FishingGear1Slot",
    }
    for _, name in pairs(slots) do
        local button = craftingPage[name]
        if button then
            button.bg = S:ReskinIcon(button.icon)
            S:ReskinIconBorder(button.IconBorder)
            button:SetNormalTexture(0)
            button:SetPushedTexture(0)
        end
    end

    local recipeList = craftingPage.RecipeList
    recipeList:StripTextures()
    S:ReskinTrimScroll(recipeList.ScrollBar)
    if recipeList.BackgroundNineSlice then recipeList.BackgroundNineSlice:Hide() end
    local recipeListBg = recipeList:CreateBackdrop()
    recipeListBg:SetBackdropColor(0, 0, 0, 0.25)
    recipeListBg:SetInside()
    S:ReskinEditBox(recipeList.SearchBox)
    S:ReskinFilterButton(recipeList.FilterDropdown)

    local form = craftingPage.SchematicForm
    form:StripTextures()
    form.Background:SetAlpha(0)
    local formBg = form:CreateBackdrop()
    formBg:SetBackdropColor(0, 0, 0, 0.25)
    formBg:SetInside()
    reskinProfessionForm(form)
    form.MinimalBackground:SetAlpha(0)

    local rankBar = craftingPage.RankBar
    reskinRankBar(rankBar)

    S:ReskinArrow(craftingPage.LinkButton, "right")
    craftingPage.LinkButton:SetSize(20, 20)
    craftingPage.LinkButton:SetPoint("LEFT", rankBar.Fill, "RIGHT", 3, 0)

    local specPage = frame.SpecPage
    S:Reskin(specPage.UnlockTabButton)
    S:Reskin(specPage.ApplyButton)
    S:Reskin(specPage.ViewTreeButton)
    S:Reskin(specPage.BackToFullTreeButton)
    S:Reskin(specPage.ViewPreviewButton)
    S:Reskin(specPage.BackToPreviewButton)
    specPage.TopDivider:Hide()
    specPage.VerticalDivider:Hide()
    specPage.PanelFooter:Hide()
    specPage.TreeView:StripTextures()
    specPage.TreeView.Background:Hide()
    local treeViewBG = specPage.TreeView:CreateBackdrop()
    treeViewBG:SetBackdropColor(0, 0, 0, 0.25)
    treeViewBG:SetInside()

    hooksecurefunc(specPage, "UpdateTabs", function(self)
        for tab in self.tabsPool:EnumerateActive() do
            if not tab.__styled then
                tab.__styled = true
                S:ReskinTab(tab)
            end
        end
    end)

    local view = specPage.DetailedView
    view:StripTextures()
    local detailedViewBG = view:CreateBackdrop()
    detailedViewBG:SetBackdropColor(0, 0, 0, 0.25)
    detailedViewBG:SetInside()
    S:Reskin(view.UnlockPathButton)
    S:Reskin(view.SpendPointsButton)
    S:ReskinIcon(view.UnspentPoints.Icon)

    treeViewBG:SetPoint("BOTTOMRIGHT", detailedViewBG, "BOTTOMLEFT", -3, 0)

    -- log
    reskinOutputLog(craftingPage.CraftingOutputLog)

    -- Order page
    if not frame.OrdersPage then return end

    local browseFrame = frame.OrdersPage.BrowseFrame
    S:Reskin(browseFrame.SearchButton)
    S:Reskin(browseFrame.FavoritesSearchButton)
    browseFrame.FavoritesSearchButton:SetSize(22, 22)

    local browseRecipeList = browseFrame.RecipeList
    browseRecipeList:StripTextures()
    S:ReskinTrimScroll(browseRecipeList.ScrollBar)
    if browseRecipeList.BackgroundNineSlice then browseRecipeList.BackgroundNineSlice:Hide() end
    local browseListBg = browseRecipeList:CreateBackdrop()
    browseListBg:SetBackdropColor(0, 0, 0, 0.25)
    browseListBg:SetInside()
    S:ReskinEditBox(browseRecipeList.SearchBox)
    S:ReskinFilterButton(browseRecipeList.FilterDropdown)

    S:ReskinTab(browseFrame.PublicOrdersButton)
    S:ReskinTab(browseFrame.GuildOrdersButton)
    S:ReskinTab(browseFrame.PersonalOrdersButton)
    S:ReskinTab(browseFrame.NpcOrdersButton)
    browseFrame.OrdersRemainingDisplay:StripTextures()
    local ordersRemainingBg = browseFrame.OrdersRemainingDisplay:CreateBackdrop()
    ordersRemainingBg:SetBackdropColor(0, 0, 0, 0.25)

    local orderList = browseFrame.OrderList
    orderList:StripTextures()
    orderList.Background:SetAlpha(0)
    local orderListBg = orderList:CreateBackdrop()
    orderListBg:SetBackdropColor(0, 0, 0, 0.25)
    orderListBg:SetInside()
    S:ReskinTrimScroll(orderList.ScrollBar)

    hooksecurefunc(frame.OrdersPage, "SetupTable", function()
        local maxHeaders = orderList.HeaderContainer:GetNumChildren()
        for i = 1, maxHeaders do
            local header = select(i, orderList.HeaderContainer:GetChildren())
            if not header.__styled then
                header:DisableDrawLayer("BACKGROUND")
                header.bg = header:CreateBackdrop()
                header.bg:SetBackdropColor(0, 0, 0, 0)
                local hl = header:GetHighlightTexture()
                hl:SetColorTexture(1, 1, 1, 0.1)
                hl:SetAllPoints(header.bg)
                header.bg:SetPoint("TOPLEFT", 0, -2)
                header.bg:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)

                header.__styled = true
            end
        end
    end)
    frame.OrdersPage:SetupTable()

    local orderView = frame.OrdersPage.OrderView
    S:Reskin(orderView.CreateButton)
    S:Reskin(orderView.StartRecraftButton)
    S:Reskin(orderView.StopRecraftButton)
    S:Reskin(orderView.CompleteOrderButton)
    reskinOutputLog(orderView.CraftingOutputLog)
    reskinRankBar(orderView.RankBar)

    local orderInfo = orderView.OrderInfo
    orderInfo:StripTextures()
    local orderInfoBg = orderInfo:CreateBackdrop()
    orderInfoBg:SetBackdropColor(0, 0, 0, 0.25)
    orderInfoBg:SetInside()
    S:Reskin(orderInfo.BackButton)
    S:Reskin(orderInfo.StartOrderButton)
    S:Reskin(orderInfo.DeclineOrderButton)
    S:Reskin(orderInfo.ReleaseOrderButton)
    orderInfo.NoteBox:StripTextures()
    local noteBoxBg = orderInfo.NoteBox:CreateBackdrop()
    noteBoxBg:SetBackdropColor(0, 0, 0, 0.25)
    S:Reskin(orderInfo.SocialDropdown)

    local orderDetails = orderView.OrderDetails
    orderDetails:StripTextures()
    orderDetails.Background:SetAlpha(0)
    local orderDetailsBg = orderDetails:CreateBackdrop()
    orderDetailsBg:SetBackdropColor(0, 0, 0, 0.25)
    orderDetailsBg:SetInside()
    reskinProfessionForm(orderDetails.SchematicForm)

    orderDetails.FulfillmentForm.NoteEditBox:StripTextures()
    local fulfillNoteBg = orderDetails.FulfillmentForm.NoteEditBox:CreateBackdrop()
    fulfillNoteBg:SetBackdropColor(0, 0, 0, 0.25)
    S:ReskinIcon(orderView.ConcentrationDisplay.Icon)

    local rewardsFrame = orderInfo.NPCRewardsFrame
    if rewardsFrame then
        rewardsFrame.Background:Hide()
        local rewardsBg = rewardsFrame.Background:CreateBackdrop()
        rewardsBg:SetBackdropColor(0, 0, 0, 0.25)

        local function handleRewardButton(button)
            if not button then return end
            button:StripTextures()
            button.bg = S:ReskinIcon(button.Icon)
            S:ReskinIconBorder(button.IconBorder, true, true)
        end
        handleRewardButton(rewardsFrame.RewardItem1)
        handleRewardButton(rewardsFrame.RewardItem2)
    end

    -- InspectRecipeFrame
    local inspectFrame = _G.InspectRecipeFrame
    if inspectFrame then
        S:ReskinPortraitFrame(inspectFrame)

        local inspectForm = inspectFrame.SchematicForm
        reskinProfessionForm(inspectForm)
        inspectForm.MinimalBackground:SetAlpha(0)
        local inspectFormBg = inspectForm:CreateBackdrop()
        inspectFormBg:SetBackdropColor(0, 0, 0, 0.25)
        inspectFormBg:SetInside()
    end
end

S:AddCallbackForAddon("Blizzard_Professions", "Professions")
