local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Trade Frame
-- Ported from AuroraClassic FrameXML/TradeFrame.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G

function S:Trade()
    if not (C.skins.enable and C.skins.trade) then return end

    TradePlayerEnchantInset:Hide()
    TradePlayerItemsInset:Hide()
    TradeRecipientEnchantInset:Hide()
    TradeRecipientItemsInset:Hide()
    TradePlayerInputMoneyInset:Hide()
    TradeRecipientMoneyInset:Hide()
    TradeRecipientBG:Hide()
    TradeRecipientMoneyBg:Hide()
    TradeRecipientBotLeftCorner:Hide()
    TradeRecipientLeftBorder:Hide()
    select(4, TradePlayerItem7:GetRegions()):Hide()
    select(4, TradeRecipientItem7:GetRegions()):Hide()

    S:ReskinPortraitFrame(TradeFrame)
    TradeFrame.RecipientOverlay:Hide()
    S:Reskin(TradeFrameTradeButton)
    S:Reskin(TradeFrameCancelButton)

    if not TradePlayerInputMoneyFrame:IsForbidden() then
        S:ReskinInput(TradePlayerInputMoneyFrameGold)
        S:ReskinInput(TradePlayerInputMoneyFrameSilver)
        S:ReskinInput(TradePlayerInputMoneyFrameCopper)

        TradePlayerInputMoneyFrameSilver:SetPoint("LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
        TradePlayerInputMoneyFrameCopper:SetPoint("LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)
    end

    local function reskinButton(bu)
        bu:SetNormalTexture(0)
        bu:SetPushedTexture(0)
        local hl = bu:GetHighlightTexture()
        hl:SetColorTexture(1, 1, 1, 0.25)
        hl:SetInside()
        bu.icon:SetTexCoord(unpack(DB.TexCoord))
        bu.icon:SetInside()
        bu.IconOverlay:SetInside()
        bu.IconOverlay2:SetInside()
        bu.bg = bu.icon:CreateBackdrop()
        S:ReskinIconBorder(bu.IconBorder)
    end

    for i = 1, MAX_TRADE_ITEMS do
        _G["TradePlayerItem" .. i .. "SlotTexture"]:Hide()
        _G["TradePlayerItem" .. i .. "NameFrame"]:Hide()
        _G["TradeRecipientItem" .. i .. "SlotTexture"]:Hide()
        _G["TradeRecipientItem" .. i .. "NameFrame"]:Hide()

        reskinButton(_G["TradePlayerItem" .. i .. "ItemButton"])
        reskinButton(_G["TradeRecipientItem" .. i .. "ItemButton"])
    end

    local tradeHighlights = {
        TradeHighlightPlayer,
        TradeHighlightPlayerEnchant,
        TradeHighlightRecipient,
        TradeHighlightRecipientEnchant,
    }
    for _, highlight in pairs(tradeHighlights) do
        highlight:StripTextures()
        highlight:SetFrameStrata("HIGH")
        local bg = highlight:CreateBackdrop()
        bg:SetBackdropColor(0, 1, 0, 0.15)
    end
end

S:AddCallback("Trade")
