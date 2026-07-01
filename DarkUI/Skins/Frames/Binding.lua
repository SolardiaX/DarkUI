local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Quick Keybind Frame
-- Ported from AuroraClassic FrameXML/QuickKeybind.lua (2026-06)
------------------------------------------------------------------------

function S:Binding()
    if not C.general.skins then return end

    local frame = QuickKeybindFrame
    frame:StripTextures()
    frame.Header:StripTextures()
    S:CreateBackground(frame)
    S:ReskinCheck(frame.UseCharacterBindingsButton)
    frame.UseCharacterBindingsButton:SetSize(24, 24)
    S:ReskinButton(frame.OkayButton)
    S:ReskinButton(frame.DefaultsButton)
    S:ReskinButton(frame.CancelButton)
end

S:AddCallback("Binding")
