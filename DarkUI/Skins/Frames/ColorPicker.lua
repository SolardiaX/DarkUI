local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Color Picker Frame
-- Ported from AuroraClassic FrameXML/ColorPickerFrame.lua (2026-06)
------------------------------------------------------------------------

function S:ColorPicker()
    if not (C.skins.enable and C.skins.misc) then return end

    ColorPickerFrame.Header:StripTextures()
    ColorPickerFrame.Header:ClearAllPoints()
    ColorPickerFrame.Header:SetPoint("TOP", ColorPickerFrame, 0, 10)
    ColorPickerFrame.Border:Hide()

    S:SetBD(ColorPickerFrame)
    S:Reskin(ColorPickerFrame.Footer.OkayButton)
    S:Reskin(ColorPickerFrame.Footer.CancelButton)
end

S:AddCallback("ColorPicker")
