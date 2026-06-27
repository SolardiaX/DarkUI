local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Item upgrade
-- Ported from ElvUI Mainline/Skins/ItemUpgrade.lua (v15.15, 2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function Update(frame)
    if frame.upgradeInfo then
        frame.UpgradeItemButton:GetPushedTexture():SetColorTexture(0.9, 0.8, 0.1, 0.3)
    else
        frame.UpgradeItemButton:GetNormalTexture():SetInside()
    end
end

function S:Blizzard_ItemUpgradeUI()
    if not (C.skins.enable and C.skins.itemUpgrade) then return end

    local frame = _G.ItemUpgradeFrame
    S:HandlePortraitFrame(frame) -- DarkUI container look (hides portrait + NineSlice via StripTextures)
    _G.ItemUpgradeFrameBg:Hide()
    _G.ItemUpgradeFramePlayerCurrenciesBorder:StripTextures()

    frame.UpgradeCostFrame.BGTex:StripTextures()

    frame.TopTileStreaks:Hide()
    frame.BottomBG:CreateBackdrop("Transparent")
    frame.ItemInfo.UpgradeTo:SetFontObject("GameFontHighlightMedium")

    local button = frame.UpgradeItemButton
    button:StripTextures()
    button:SetTemplate()
    button:StyleButton(nil, true)
    button:GetNormalTexture():SetInside()

    button.icon:SetInside(button)
    S:HandleIcon(button.icon)

    if C.skins.parchment_remover then
        frame.BottomBGShadow:Hide()
        frame.BottomBG:Hide()
        frame.TopBG:Hide()

        local holder = button.ButtonFrame
        holder:StripTextures()
        holder:CreateBackdrop("Transparent")
    else
        frame.TopBG:CreateBackdrop("Transparent")
    end

    --hooksecurefunc(frame, 'Update', Update) -- FIX ME 11.0

    S:HandleIconBorder(button.IconBorder)
    S:HandleButton(frame.UpgradeButton, true)
    S:HandleDropDownBox(frame.ItemInfo.Dropdown, 130)
    S:HandleCloseButton(_G.ItemUpgradeFrameCloseButton)
end

S:AddCallbackForAddon("Blizzard_ItemUpgradeUI")
