local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Trading Post (Perks Program) UI
-- Ported from AuroraClassic AddOns/Blizzard_PerksProgram.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
-- Note: bg.__shadow → bg.shadow (DarkUI CreateShadow field name).
------------------------------------------------------------------------

local hooksecurefunc = hooksecurefunc

local function ReskinCustomizeButton(button)
    S:Reskin(button)
    button.bg:SetInside(nil, 5, 5)
end

local function ReskinCartToggle(button)
    if not button.__styled then
        button:GetNormalTexture():SetAlpha(0)
        button:GetPushedTexture():SetAlpha(0)
        button:GetDisabledTexture():SetAlpha(0)
        button:GetHighlightTexture():SetAlpha(0)
        button.__styled = true
    end
    if not button.tex then
        button.tex = button:CreateTexture()
        button.tex:SetPoint("BOTTOMLEFT", 5, 5)
        button.tex:SetSize(22, 22)
        button.tex:SetAtlas("Perks-shoppingcart")
        button.tex.isIgnored = true
    end
    if not button.state then
        button.state = button:CreateFontString()
        button.state:SetPoint("TOPRIGHT", -3, 0)
        button.state:SetFontObject(Game20Font)
    end
    button.state:SetText(button.itemInCart and "|cffff0000-|r" or "|cff00ff00+|r")
end

local function ReskinRewardButton(button)
    if button.__styled then return end

    local container = button.ContentsContainer
    if container then
        S:ReskinIcon(container.Icon)
        S:ReskinIcon(container.PriceIcon)
        ReskinCartToggle(container.CartToggleButton)
        hooksecurefunc(container.CartToggleButton, "UpdateCartState", ReskinCartToggle)
    end
    button.__styled = true
end

local function SetupSetButton(button)
    if button.bg then return end
    button.IconMask:Hide()
    button.bg = S:ReskinIcon(button.Icon)
    button.IconBorder:SetAlpha(0)
    button.BackgroundTexture:SetAlpha(0)
    local bg = button.BackgroundTexture:CreateBackdrop()
    bg:SetInside(button.BackgroundTexture, 3, 3)
    button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
    button.HighlightTexture:SetInside(bg)
end

local function SetupFramBG(frame)
    local bg = S:SetBD(frame)
    bg:SetFrameLevel(0)
    if bg.shadow then bg.shadow:SetFrameLevel(0) end
end

local function SetupCartItem(button)
    if button.__styled then return end
    if button.Icon then SetupSetButton(button) end
    if button.PriceIcon then S:ReskinIcon(button.PriceIcon) end
    if button.RemoveFromCartItemButton then S:ReskinFilterReset(button.RemoveFromCartItemButton.RemoveFromListButton) end
    button.__styled = true
end

function S:PerksProgram()
    if not (C.skins.enable and C.skins.perksProgram) then return end

    local frame = PerksProgramFrame
    if not frame then return end

    local footerFrame = frame.FooterFrame
    if footerFrame then
        ReskinCustomizeButton(footerFrame.LeaveButton)
        ReskinCustomizeButton(footerFrame.PurchaseButton)
        ReskinCustomizeButton(footerFrame.RefundButton)
        ReskinCustomizeButton(footerFrame.AddToCartButton)
        ReskinCustomizeButton(footerFrame.RemoveFromCartButton)
        S:ReskinCheck(footerFrame.TogglePlayerPreview)
        S:ReskinCheck(footerFrame.ToggleHideArmor)
        S:ReskinCheck(footerFrame.ToggleAttackAnimation)
        S:ReskinCheck(footerFrame.ToggleMountSpecial)
        ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateLeftButton)
        ReskinCustomizeButton(footerFrame.RotateButtonContainer.RotateRightButton)

        ReskinCustomizeButton(footerFrame.ViewCartButton)
        local tex = footerFrame.ViewCartButton:CreateTexture()
        tex:SetInside(nil, 10, 10)
        tex:SetAtlas("Perks-shoppingcart")

        hooksecurefunc(GlowEmitterFactory, "Show", function(frame, target, show)
            local button = footerFrame.PurchaseButton
            if button and target == button and show then frame:Hide(target) end
        end)
    end

    local productsFrame = frame.ProductsFrame
    if productsFrame then
        S:ReskinFilterButton(productsFrame.PerksProgramFilter)
        S:ReskinIcon(productsFrame.PerksProgramCurrencyFrame.Icon)
        productsFrame.PerksProgramProductDetailsContainerFrame:StripTextures()
        SetupFramBG(productsFrame.PerksProgramProductDetailsContainerFrame)
        S:ReskinTrimScroll(productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBar)

        hooksecurefunc(
            productsFrame.PerksProgramProductDetailsContainerFrame.SetDetailsScrollBoxContainer.ScrollBox,
            "Update",
            function(self) self:ForEachFrame(SetupSetButton) end
        )

        local productsContainer = productsFrame.ProductsScrollBoxContainer
        productsContainer:StripTextures()
        SetupFramBG(productsContainer)
        S:ReskinTrimScroll(productsContainer.ScrollBar)
        productsContainer.PerksProgramHoldFrame:StripTextures()
        local holdBg = productsContainer.PerksProgramHoldFrame:CreateBackdrop()
        holdBg:SetInside(nil, 3, 3)

        hooksecurefunc(productsContainer.ScrollBox, "Update", function(self) self:ForEachFrame(ReskinRewardButton) end)

        local cartFrame = productsFrame.PerksProgramShoppingCartFrame
        if cartFrame then
            cartFrame:StripTextures()
            SetupFramBG(cartFrame)
            S:ReskinTrimScroll(cartFrame.ItemList.ScrollBar)
            S:ReskinClose(cartFrame.CloseButton)
            ReskinCustomizeButton(cartFrame.PurchaseCartButton)

            ReskinCustomizeButton(cartFrame.ClearCartButton)
            local tex = cartFrame.ClearCartButton:CreateTexture()
            tex:SetInside(nil, 10, 10)
            tex:SetAtlas("common-icon-undo")
            tex:SetVertexColor(1, 0, 0)

            hooksecurefunc(cartFrame.ItemList.ScrollBox, "Update", function(self) self:ForEachFrame(SetupCartItem) end)
        end
    end
end

S:AddCallbackForAddon("Blizzard_PerksProgram", "PerksProgram")
