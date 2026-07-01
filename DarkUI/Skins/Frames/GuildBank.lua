local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Guild Bank UI
-- Ported from AuroraClassic AddOns/Blizzard_GuildBankUI.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G

function S:GuildBank()
    if not C.general.skins then return end

    GuildBankFrame:StripTextures()
    S:ReskinPortraitFrame(GuildBankFrame)

    GuildBankFrame.Emblem:Hide()
    GuildBankFrame.MoneyFrameBG:Hide()
    S:ReskinButton(GuildBankFrame.WithdrawButton)
    S:ReskinButton(GuildBankFrame.DepositButton)
    S:ReskinTrimScrollBar(GuildBankFrame.Log.ScrollBar)
    S:ReskinTrimScrollBar(GuildBankInfoScrollFrame.ScrollBar)

    S:ReskinButton(GuildBankFrame.BuyInfo.PurchaseButton)
    S:ReskinButton(GuildBankFrame.Info.SaveButton)
    S:ReskinInput(GuildItemSearchBox)

    GuildBankFrame.WithdrawButton:SetPoint("RIGHT", GuildBankFrame.DepositButton, "LEFT", -2, 0)

    for i = 1, 4 do
        local tab = _G["GuildBankFrameTab" .. i]
        S:ReskinTab(tab)

        if i ~= 1 then tab:SetPoint("LEFT", _G["GuildBankFrameTab" .. (i - 1)], "RIGHT", -5, 0) end
    end

    for i = 1, 7 do
        local column = GuildBankFrame.Columns[i]
        column:GetRegions():Hide()

        for j = 1, 14 do
            local button = column.Buttons[j]
            button:SetNormalTexture(0)
            button:SetPushedTexture(0)
            button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            button.icon:SetTexCoord(unpack(C.media.texCoord))
            button.bg = button:CreateBackdrop()
            button.bg:SetBackdropEdge("round")
            button.bg:SetBackdropColor(0.3, 0.3, 0.3, 0.3)
            button.searchOverlay:SetOutside()
            S:ReskinIconBorder(button.IconBorder)
        end
    end

    for i = 1, 8 do
        local tab = _G["GuildBankTab" .. i]
        local button = tab.Button
        local icon = button.IconTexture

        tab:StripTextures()
        button:SetNormalTexture(0)
        button:SetPushedTexture(0)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        button:SetCheckedTexture(C.media.button.glow)
        button:CreateBackdrop()
        button:CreateBorder()
        button.border:SetOutside(button, 2, 2)
        icon:SetTexCoord(unpack(C.media.texCoord))

        local a1, p, a2, x, y = button:GetPoint()
        button:SetPoint(a1, p, a2, x + 4, y)
    end

    S:ReskinIconSelectionFrame(GuildBankPopupFrame)
end

S:AddCallbackForAddon("Blizzard_GuildBankUI", "GuildBank")
