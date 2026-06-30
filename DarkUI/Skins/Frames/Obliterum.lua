local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Obliterum Forge UI
-- Ported from AuroraClassic AddOns/Blizzard_ObliterumUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G

function S:Obliterum()
    if not (C.skins.enable and C.skins.obliterum) then return end

    local obliterum = ObliterumForgeFrame

    S:ReskinPortraitFrame(obliterum)
    S:Reskin(obliterum.ObliterateButton)
    S:ReskinIcon(obliterum.ItemSlot.Icon)
end

S:AddCallbackForAddon("Blizzard_ObliterumUI", "Obliterum")
