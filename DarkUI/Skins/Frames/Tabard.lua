local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Tabard Customisation Frame
-- Ported from AuroraClassic FrameXML/TabardFrame.lua (2026-06)
------------------------------------------------------------------------

function S:Tabard()
    if not (C.skins.enable and C.skins.misc) then return end

    S:ReskinPortraitFrame(TabardFrame)
    TabardFrameMoneyInset:Hide()
    TabardFrameMoneyBg:Hide()
    TabardFrameCostFrame:CreateBackdrop()
    S:Reskin(TabardFrameAcceptButton)
    S:Reskin(TabardFrameCancelButton)
    S:ReskinArrow(TabardCharacterModelRotateLeftButton, "left")
    S:ReskinArrow(TabardCharacterModelRotateRightButton, "right")
    TabardCharacterModelRotateRightButton:SetPoint("TOPLEFT", TabardCharacterModelRotateLeftButton, "TOPRIGHT", 1, 0)

    TabardFrameCustomizationBorder:Hide()
    for i = 1, 5 do
        _G["TabardFrameCustomization" .. i]:StripTextures()
        S:ReskinArrow(_G["TabardFrameCustomization" .. i .. "LeftButton"], "left")
        S:ReskinArrow(_G["TabardFrameCustomization" .. i .. "RightButton"], "right")
    end
end

S:AddCallback("Tabard")
