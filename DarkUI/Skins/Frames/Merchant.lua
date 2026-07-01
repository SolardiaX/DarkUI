local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Merchant Frame
-- Ported from AuroraClassic FrameXML/MerchantFrame.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function reskinMerchantItem(item)
    local name = item.Name
    local button = item.ItemButton
    local icon = button.icon
    local moneyFrame = _G[item:GetName() .. "MoneyFrame"]

    item:StripTextures()
    item:CreateBackdrop()

    button:StripTextures()
    button:ClearAllPoints()
    button:SetPoint("LEFT", item, 4, 0)
    local hl = button:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetInside()

    icon:SetInside()
    button.bg = S:ReskinIcon(icon)
    S:ReskinIconBorder(button.IconBorder)
    button.IconOverlay:SetInside()
    button.IconOverlay2:SetInside()

    name:SetFontObject(Number12Font)
    name:SetPoint("LEFT", button, "RIGHT", 2, 9)
    moneyFrame:SetPoint("BOTTOMLEFT", button, "BOTTOMRIGHT", 3, 0)
end

local function reskinMerchantInteract(button)
    button:GetRegions():Hide()
    S:ReskinIcon(button.Icon)
    button:SetPushedTexture(0)
    button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
end

function S:Merchant()
    if not (C.skins.enable and C.skins.merchant) then return end

    S:ReskinPortraitFrame(MerchantFrame)
    S:ReskinDropDown(MerchantFrame.FilterDropdown)
    MerchantPrevPageButton:StripTextures()
    S:ReskinArrow(MerchantPrevPageButton, "left")
    MerchantNextPageButton:StripTextures()
    S:ReskinArrow(MerchantNextPageButton, "right")
    MerchantMoneyInset:Hide()
    MerchantMoneyBg:Hide()
    MerchantExtraCurrencyBg:SetAlpha(0)
    MerchantExtraCurrencyInset:SetAlpha(0)
    BuybackBG:SetAlpha(0)

    MerchantFrameTab1:ClearAllPoints()
    MerchantFrameTab1:SetPoint("CENTER", MerchantFrame, "BOTTOMLEFT", 50, -14)
    MerchantFrameTab2:SetPoint("LEFT", MerchantFrameTab1, "RIGHT", -5, 0)

    for i = 1, 2 do
        S:ReskinTab(_G["MerchantFrameTab" .. i])
    end

    for i = 1, BUYBACK_ITEMS_PER_PAGE do
        local item = _G["MerchantItem" .. i]
        reskinMerchantItem(item)

        for j = 1, 3 do
            local texture = _G["MerchantItem" .. i .. "AltCurrencyFrameItem" .. j .. "Texture"]
            local currency = _G["MerchantItem" .. i .. "AltCurrencyFrameItem" .. j]
            currency:SetPoint("BOTTOMLEFT", item.ItemButton, "BOTTOMRIGHT", 3, 0)
            S:ReskinIcon(texture)
        end
    end

    MerchantBuyBackItem:SetHeight(44)
    reskinMerchantItem(MerchantBuyBackItem)

    reskinMerchantInteract(MerchantGuildBankRepairButton)
    reskinMerchantInteract(MerchantRepairAllButton)
    reskinMerchantInteract(MerchantRepairItemButton)
    reskinMerchantInteract(MerchantSellAllJunkButton)

    hooksecurefunc("MerchantFrame_UpdateCurrencies", function()
        for i = 1, MAX_MERCHANT_CURRENCIES do
            local bu = _G["MerchantToken" .. i]
            if bu and not bu.__styled then
                local icon = _G["MerchantToken" .. i .. "Icon"]
                if icon then S:ReskinIcon(icon) end
                local count = _G["MerchantToken" .. i .. "Count"]
                if count then count:SetPoint("TOPLEFT", bu, "TOPLEFT", -2, 0) end

                bu.__styled = true
            end
        end
    end)

    -- StackSplitFrame

    local StackSplitFrame = StackSplitFrame
    StackSplitFrame:StripTextures()
    S:CreateBackground(StackSplitFrame)
    S:ReskinButton(StackSplitFrame.OkayButton)
    S:ReskinButton(StackSplitFrame.CancelButton)
    S:ReskinArrow(StackSplitFrame.LeftButton, "left")
    S:ReskinArrow(StackSplitFrame.RightButton, "right")
end

S:AddCallback("Merchant")
