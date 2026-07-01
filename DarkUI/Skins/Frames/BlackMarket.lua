local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b

------------------------------------------------------------------------
-- Black Market UI
-- Ported from AuroraClassic AddOns/Blizzard_BlackMarketUI.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G
local select, hooksecurefunc = select, hooksecurefunc

function S:BlackMarket()
    if not (C.skins.enable and C.skins.blackMarket) then return end

    BlackMarketFrame:StripTextures()
    BlackMarketFrame.MoneyFrameBorder:SetAlpha(0)
    BlackMarketFrame.HotDeal:StripTextures()
    BlackMarketFrame.HotDeal.Item:CreateBackdrop()
    BlackMarketFrame.HotDeal.Item.IconTexture:SetTexCoord(unpack(C.media.texCoord))

    local headers = { "ColumnName", "ColumnLevel", "ColumnType", "ColumnDuration", "ColumnHighBidder", "ColumnCurrentBid" }
    for _, header in pairs(headers) do
        local col = BlackMarketFrame[header]
        col:StripTextures()
        local bg = col:CreateBackdrop()
        bg:SetPoint("TOPLEFT", 2, 0)
        bg:SetPoint("BOTTOMRIGHT", -1, 0)
    end

    S:CreateBackground(BlackMarketFrame)
    BlackMarketFrame.HotDeal:CreateBackdrop()
    S:ReskinButton(BlackMarketFrame.BidButton)
    S:ReskinClose(BlackMarketFrame.CloseButton)
    S:ReskinInput(BlackMarketBidPriceGold)
    S:ReskinTrimScrollBar(BlackMarketFrame.ScrollBar)

    hooksecurefunc(BlackMarketFrame.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local bu = select(i, self.ScrollTarget:GetChildren())

            bu.Item.IconTexture:SetTexCoord(unpack(C.media.texCoord))
            if not bu.reskinned then
                bu:StripTextures()

                bu.Item:SetNormalTexture(0)
                bu.Item:SetPushedTexture(0)
                bu.Item:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                bu.Item:CreateBackdrop()
                bu.Item.IconBorder:SetAlpha(0)

                local bg = bu:CreateBackdrop()
                bg:SetPoint("TOPLEFT", bu.Item, "TOPRIGHT", 3, E.mult)
                bg:SetPoint("BOTTOMRIGHT", 0, 4)

                bu:SetHighlightTexture(C.media.texture.blank)
                local hl = bu:GetHighlightTexture()
                hl:SetVertexColor(cr, cg, cb, 0.2)
                hl.SetAlpha = E.Dummy
                hl:ClearAllPoints()
                hl:SetAllPoints(bg)

                bu.Selection:ClearAllPoints()
                bu.Selection:SetAllPoints(bg)
                bu.Selection:SetTexture(C.media.texture.blank)
                bu.Selection:SetVertexColor(cr, cg, cb, 0.1)

                bu.reskinned = true
            end

            if bu:IsShown() and bu.itemLink then
                local _, _, quality = C_Item.GetItemInfo(bu.itemLink)
                local r, g, b = C_Item.GetItemQualityColor(quality or 1)
                bu.Name:SetTextColor(r, g, b)
            end
        end
    end)

    hooksecurefunc("BlackMarketFrame_UpdateHotItem", function(self)
        local hotDeal = self.HotDeal
        if hotDeal:IsShown() and hotDeal.itemLink then
            local _, _, quality = C_Item.GetItemInfo(hotDeal.itemLink)
            local r, g, b = C_Item.GetItemQualityColor(quality or 1)
            hotDeal.Name:SetTextColor(r, g, b)
        end
        hotDeal.Item.IconBorder:Hide()
    end)
end

S:AddCallbackForAddon("Blizzard_BlackMarketUI", "BlackMarket")
