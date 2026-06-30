local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Character Frame
-- Ported from AuroraClassic FrameXML/CharacterFrame.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local select, ipairs, hooksecurefunc = select, ipairs, hooksecurefunc

local function NoTaintArrow(self, direction) -- needs review
    self:StripTextures()

    local tex = self:CreateTexture(nil, "ARTWORK")
    tex:SetAllPoints()
    S:SetupArrow(tex, direction)
    self.__texture = tex

    self:HookScript("OnEnter", S.SetModifiedBackdrop)
    self:HookScript("OnLeave", S.SetOriginalBackdrop)
end

function S:Character()
    if not (C.skins.enable and C.skins.character) then return end

    S:ReskinPortraitFrame(CharacterFrame)
    CharacterFrameInsetRight:StripTextures()

    for i = 1, 3 do
        local tab = _G["CharacterFrameTab" .. i]
        if tab then
            S:ReskinTab(tab)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", _G["CharacterFrameTab" .. (i - 1)], "TOPRIGHT", -5, 0)
            end
        end
    end

    S:ReskinModelControl(CharacterModelScene)
    CharacterModelScene:DisableDrawLayer("BACKGROUND")
    CharacterModelScene:DisableDrawLayer("BORDER")
    CharacterModelScene:DisableDrawLayer("OVERLAY")

    -- [[ Item buttons ]]

    local function colourPopout(self)
        local aR, aG, aB
        local glow = self:GetParent().IconBorder

        if glow:IsShown() then
            aR, aG, aB = glow:GetVertexColor()
        else
            aR, aG, aB = cr, cg, cb
        end

        self.arrow:SetVertexColor(aR, aG, aB)
    end

    local function clearPopout(self) self.arrow:SetVertexColor(1, 1, 1) end

    local function UpdateAzeriteItem(self)
        if not self.__styled then
            self.AzeriteTexture:SetAlpha(0)
            self.RankFrame.Texture:SetTexture("")
            self.RankFrame.Label:ClearAllPoints()
            self.RankFrame.Label:SetPoint("TOPLEFT", self, 2, -1)
            self.RankFrame.Label:SetTextColor(1, 0.5, 0)

            self.__styled = true
        end
    end

    local function UpdateAzeriteEmpoweredItem(self)
        self.AzeriteTexture:SetAtlas("AzeriteIconFrame")
        self.AzeriteTexture:SetInside()
        self.AzeriteTexture:SetDrawLayer("BORDER", 1)
    end

    local function UpdateHighlight(self)
        local highlight = self:GetHighlightTexture()
        highlight:SetColorTexture(1, 1, 1, 0.25)
        highlight:SetInside(self.bg)
    end

    local function UpdateCosmetic(self)
        local itemLink = GetInventoryItemLink("player", self:GetID())
        self.IconOverlay:SetShown(itemLink and C_Item.IsCosmeticItem(itemLink))
    end

    local slots = {
        "Head",
        "Neck",
        "Shoulder",
        "Shirt",
        "Chest",
        "Waist",
        "Legs",
        "Feet",
        "Wrist",
        "Hands",
        "Finger0",
        "Finger1",
        "Trinket0",
        "Trinket1",
        "Back",
        "MainHand",
        "SecondaryHand",
        "Tabard",
    }

    for i = 1, #slots do
        local slot = _G["Character" .. slots[i] .. "Slot"]
        local cooldown = _G["Character" .. slots[i] .. "SlotCooldown"]

        slot:StripTextures()
        slot.icon:SetTexCoord(unpack(DB.TexCoord))
        slot.icon:SetInside()
        slot.bg = S:ReskinIcon(slot.icon)
        slot.bg:SetFrameLevel(3) -- higher than portrait
        cooldown:SetInside()

        slot.ignoreTexture:SetTexture("Interface\\PaperDollInfoFrame\\UI-GearManager-LeaveItem-Transparent")
        slot.IconOverlay:SetAtlas("CosmeticIconFrame")
        slot.IconOverlay:SetInside()
        S:ReskinIconBorder(slot.IconBorder)

        local popout = slot.popoutButton
        popout:SetNormalTexture(0)
        popout:SetHighlightTexture(0)

        local arrow = popout:CreateTexture(nil, "OVERLAY")
        arrow:SetSize(14, 14)
        if slot.verticalFlyout then
            S:SetupArrow(arrow, "down")
            arrow:SetPoint("TOP", slot, "BOTTOM", 0, 1)
        else
            S:SetupArrow(arrow, "right")
            arrow:SetPoint("LEFT", slot, "RIGHT", -1, 0)
        end
        popout.arrow = arrow

        popout:HookScript("OnEnter", clearPopout)
        popout:HookScript("OnLeave", colourPopout)

        hooksecurefunc(slot, "DisplayAsAzeriteItem", UpdateAzeriteItem)
        hooksecurefunc(slot, "DisplayAsAzeriteEmpoweredItem", UpdateAzeriteEmpoweredItem)
    end

    hooksecurefunc("PaperDollItemSlotButton_Update", function(button)
        -- also fires for bag slots, we don't want that
        if button.popoutButton then
            button.icon:SetShown(GetInventoryItemTexture("player", button:GetID()) ~= nil)
            colourPopout(button.popoutButton)
        end
        UpdateCosmetic(button)
        UpdateHighlight(button)
    end)

    -- [[ Stats pane ]]

    local pane = CharacterStatsPane
    pane.ClassBackground:Hide()
    pane.ItemLevelFrame.Corruption:SetPoint("RIGHT", 22, -8)

    local categories = { pane.ItemLevelCategory, pane.AttributesCategory, pane.EnhancementsCategory }
    for _, category in pairs(categories) do
        category.Background:Hide()
        category.Title:SetTextColor(cr, cg, cb)
        local line = category:CreateTexture(nil, "ARTWORK")
        line:SetSize(180, E.mult)
        line:SetPoint("BOTTOM", 0, 5)
        line:SetColorTexture(1, 1, 1, 0.25)
    end

    -- [[ Sidebar tabs ]]
    -- StripTextures the container to clear BOTH DecorLeft and DecorRight (Aurora only
    -- hid DecorRight, leaving DecorLeft visible); ElvUI strips PaperDollSidebarTabs wholesale.
    PaperDollSidebarTabs:StripTextures()

    for i = 1, #PAPERDOLL_SIDEBARS do
        local tab = _G["PaperDollSidebarTab" .. i]

        if i == 1 then
            for j = 1, 4 do
                local region = select(j, tab:GetRegions())
                region:SetTexCoord(0.16, 0.86, 0.16, 0.86)
                region.SetTexCoord = E.Dummy
            end
        end

        tab.bg = tab:CreateBackdrop()
        tab.bg:SetPoint("TOPLEFT", 2, -3)
        tab.bg:SetPoint("BOTTOMRIGHT", 0, -2)

        tab.Icon:SetInside(tab.bg)
        tab.Hider:SetInside(tab.bg)
        tab.Highlight:SetInside(tab.bg)
        tab.Highlight:SetColorTexture(1, 1, 1, 0.25)
        tab.Hider:SetColorTexture(0.3, 0.3, 0.3, 0.4)
        tab.TabBg:SetAlpha(0)
    end

    -- [[ Equipment manager ]]
    S:Reskin(PaperDollFrameEquipSet)
    S:Reskin(PaperDollFrameSaveSet)
    S:ReskinTrimScroll(PaperDollFrame.EquipmentManagerPane.ScrollBar)

    hooksecurefunc(PaperDollFrame.EquipmentManagerPane.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child.icon and not child.__styled then
                child.Stripe:Kill()
                child.BgTop:SetTexture("")
                child.BgMiddle:SetTexture("")
                child.BgBottom:SetTexture("")
                S:ReskinIcon(child.icon)

                child.HighlightBar:SetColorTexture(1, 1, 1, 0.25)
                child.HighlightBar:SetDrawLayer("BACKGROUND")
                child.SelectedBar:SetColorTexture(cr, cg, cb, 0.25)
                child.SelectedBar:SetDrawLayer("BACKGROUND")
                child.Check:SetAtlas("checkmark-minimal")

                child.__styled = true
            end
        end
    end)

    S:ReskinIconSelectionFrame(GearManagerPopupFrame)

    -- TitlePane
    S:ReskinTrimScroll(PaperDollFrame.TitleManagerPane.ScrollBar)

    hooksecurefunc(PaperDollFrame.TitleManagerPane.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                child:DisableDrawLayer("BACKGROUND")
                child.Check:SetAtlas("checkmark-minimal")

                child.__styled = true
            end
        end
    end)

    -- Reputation Frame
    local oldAtlas = {
        ["Options_ListExpand_Right"] = 1,
        ["Options_ListExpand_Right_Expanded"] = 1,
    }
    local function updateCollapse(texture, atlas)
        if (not atlas) or oldAtlas[atlas] then
            if not texture.__owner then texture.__owner = texture:GetParent() end
            if texture.__owner:IsCollapsed() then
                texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Expand")
            else
                texture:SetAtlas("Soulbinds_Collection_CategoryHeader_Collapse")
            end
        end
    end

    local function updateToggleCollapse(button)
        -- DarkUI's S:ReskinCollapse has no Aurora-style __texture:DoCollapse; drive the
        -- +/- glyph straight from the header's collapsed state using DarkUI media.
        local collapsed = button:GetHeader():IsCollapsed()
        button:SetNormalTexture(collapsed and C.media.texture.plus or C.media.texture.minus, true)
    end

    local function updateReputationBars(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child and not child.__styled then
                if child.Right then
                    child:StripTextures()
                    hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
                    hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
                    updateCollapse(child.Right)
                    updateCollapse(child.HighlightRight)
                    child:CreateBackdrop():SetInside(nil, 2, 2)
                end
                local repbar = child.Content and child.Content.ReputationBar
                if repbar then
                    repbar:StripTextures()
                    repbar:SetStatusBarTexture(DB.bdTex)
                    repbar:CreateBackdrop()
                end
                if child.ToggleCollapseButton then
                    child.ToggleCollapseButton:GetPushedTexture():SetAlpha(0)
                    S:ReskinCollapse(child.ToggleCollapseButton, true)
                    updateToggleCollapse(child.ToggleCollapseButton)
                    hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateToggleCollapse)
                end

                child.__styled = true
            end
        end
    end
    hooksecurefunc(ReputationFrame.ScrollBox, "Update", updateReputationBars)

    S:ReskinTrimScroll(ReputationFrame.ScrollBar)
    S:ReskinDropDown(ReputationFrame.filterDropdown)

    local detailFrame = ReputationFrame.ReputationDetailFrame
    detailFrame:StripTextures()
    S:SetBD(detailFrame)
    S:ReskinClose(detailFrame.CloseButton)
    S:ReskinCheck(detailFrame.AtWarCheckbox)
    S:ReskinCheck(detailFrame.MakeInactiveCheckbox)
    S:ReskinCheck(detailFrame.WatchFactionCheckbox)
    S:Reskin(detailFrame.ViewRenownButton)

    -- Token frame
    S:ReskinTrimScroll(TokenFrame.ScrollBar) -- taint if touching thumb, needs review
    S:ReskinDropDown(TokenFrame.filterDropdown)
    if TokenFramePopup.CloseButton then -- blizz typo by parentKey "CloseButton" into "$parent.CloseButton"
        S:ReskinClose(TokenFramePopup.CloseButton)
    else
        S:ReskinClose((select(5, TokenFramePopup:GetChildren())))
    end

    S:Reskin(TokenFramePopup.CurrencyTransferToggleButton)
    S:ReskinCheck(TokenFramePopup.InactiveCheckbox)
    S:ReskinCheck(TokenFramePopup.BackpackCheckbox)

    NoTaintArrow(TokenFrame.CurrencyTransferLogToggleButton, "right") -- taint control, needs review
    S:ReskinPortraitFrame(CurrencyTransferLog)
    S:ReskinTrimScroll(CurrencyTransferLog.ScrollBar)

    local function handleCurrencyIcon(button)
        local icon = button.CurrencyIcon
        if icon then S:ReskinIcon(icon) end
    end
    hooksecurefunc(CurrencyTransferLog.ScrollBox, "Update", function(self) self:ForEachFrame(handleCurrencyIcon) end)

    S:ReskinPortraitFrame(CurrencyTransferMenu)

    local transferMenu = CurrencyTransferMenu.Content
    if transferMenu then
        transferMenu.SourceSelector:CreateBackdrop()
        transferMenu.SourceSelector.SourceLabel:SetWidth(56)
        S:ReskinDropDown(transferMenu.SourceSelector.Dropdown)
        S:ReskinIcon(transferMenu.SourceBalancePreview.BalanceInfo.CurrencyIcon)
        S:ReskinIcon(transferMenu.PlayerBalancePreview.BalanceInfo.CurrencyIcon)
        S:Reskin(transferMenu.ConfirmButton)
        S:Reskin(transferMenu.CancelButton)

        local amountSelector = transferMenu.AmountSelector
        if amountSelector then
            amountSelector:CreateBackdrop()
            S:Reskin(amountSelector.MaxQuantityButton)
            S:ReskinEditBox(amountSelector.InputBox)
            amountSelector.InputBox.backdrop:SetInside(nil, 3, 3)
        end
    end

    hooksecurefunc(TokenFrame.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if child and not child.__styled then
                if child.Right then
                    child:StripTextures()
                    hooksecurefunc(child.Right, "SetAtlas", updateCollapse)
                    hooksecurefunc(child.HighlightRight, "SetAtlas", updateCollapse)
                    updateCollapse(child.Right)
                    updateCollapse(child.HighlightRight)
                    child:CreateBackdrop():SetInside(nil, 2, 2)
                end
                local icon = child.Content and child.Content.CurrencyIcon
                if icon then S:ReskinIcon(icon) end
                if child.ToggleCollapseButton then
                    child.ToggleCollapseButton:GetPushedTexture():SetAlpha(0)
                    S:ReskinCollapse(child.ToggleCollapseButton, true)
                    updateToggleCollapse(child.ToggleCollapseButton)
                    hooksecurefunc(child.ToggleCollapseButton, "RefreshIcon", updateToggleCollapse)
                end

                child.__styled = true
            end
        end
    end)

    TokenFramePopup:StripTextures()
    S:SetBD(TokenFramePopup)

    -- Quick Join
    S:ReskinTrimScroll(QuickJoinFrame.ScrollBar)
    S:Reskin(QuickJoinFrame.JoinQueueButton)

    S:SetBD(QuickJoinRoleSelectionFrame)
    S:Reskin(QuickJoinRoleSelectionFrame.AcceptButton)
    S:Reskin(QuickJoinRoleSelectionFrame.CancelButton)
    S:ReskinClose(QuickJoinRoleSelectionFrame.CloseButton)
    QuickJoinRoleSelectionFrame:StripTextures()

    S:ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonTank, "TANK")
    S:ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonHealer, "HEALER")
    S:ReskinRole(QuickJoinRoleSelectionFrame.RoleButtonDPS, "DPS")
end

S:AddCallback("Character")
