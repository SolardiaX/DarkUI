local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Chromie Time UI
-- Ported from AuroraClassic AddOns/Blizzard_ChromieTimeUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

function S:ChromieTimeUI()
    if not (C.skins.enable and C.skins.chromieTime) then return end

    local frame = ChromieTimeFrame

    frame:StripTextures()
    S:CreateBackground(frame)
    S:ReskinClose(frame.CloseButton)
    S:ReskinButton(frame.SelectButton)

    local header = frame.Title
    header:DisableDrawLayer("BACKGROUND")
    header.Text:SetFontObject(SystemFont_Huge1)
    header:CreateBackdrop()

    frame.CurrentlySelectedExpansionInfoFrame.Name:SetTextColor(1, 0.8, 0)
    frame.CurrentlySelectedExpansionInfoFrame.Description:SetTextColor(1, 1, 1)
end

S:AddCallbackForAddon("Blizzard_ChromieTimeUI", "ChromieTimeUI")
