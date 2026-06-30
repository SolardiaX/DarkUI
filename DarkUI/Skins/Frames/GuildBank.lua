local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Guild Bank UI
-- Ported from AuroraClassic AddOns/Blizzard_GuildBankUI.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G

function S:GuildBank()
    if not (C.skins.enable and C.skins.guildBank) then return end

    GuildBankFrame:StripTextures()
    S:ReskinPortraitFrame(GuildBankFrame)

    GuildBankFrame.Emblem:Hide()
    GuildBankFrame.MoneyFrameBG:Hide()
    S:Reskin(GuildBankFrame.WithdrawButton)
    S:Reskin(GuildBankFrame.DepositButton)
    S:ReskinTrimScroll(GuildBankFrame.Log.ScrollBar)
    S:ReskinTrimScroll(GuildBankInfoScrollFrame.ScrollBar)

    S:Reskin(GuildBankFrame.BuyInfo.PurchaseButton)
    S:Reskin(GuildBankFrame.Info.SaveButton)
    S:ReskinInput(GuildItemSearchBox)

    GuildBankFrame.WithdrawButton:SetPoint("RIGHT", GuildBankFrame.DepositButton, "LEFT", -2, 0)

    for i = 1, 4 do
        local tab = _G["GuildBankFrameTab" .. i]
        S:ReskinTab(tab)

        if i ~= 1 then tab:SetPoint("LEFT", _G["GuildBankFrameTab" .. (i - 1)], "RIGHT", -15, 0) end
    end

    for i = 1, 7 do
        local column = GuildBankFrame.Columns[i]
        column:GetRegions():Hide()

        for j = 1, 14 do
            local button = column.Buttons[j]
            button:SetNormalTexture(0)
            button:SetPushedTexture(0)
            button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
            button.icon:SetTexCoord(unpack(DB.TexCoord))
            button.bg = button:CreateBackdrop()
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
        button:SetCheckedTexture(DB.pushedTex)
        button:CreateBackdrop()
        icon:SetTexCoord(unpack(DB.TexCoord))

        local a1, p, a2, x, y = button:GetPoint()
        button:SetPoint(a1, p, a2, x + E.mult, y)
    end

    S:ReskinIconSelectionFrame(GuildBankPopupFrame)
end

S:AddCallbackForAddon("Blizzard_GuildBankUI", "GuildBank")
