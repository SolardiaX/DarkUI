local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Obliterum Forge UI
-- Ported from AuroraClassic AddOns/Blizzard_ObliterumUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G

function S:Obliterum()
    if not C.general.skins then return end

    local obliterum = ObliterumForgeFrame

    S:ReskinPortraitFrame(obliterum)
    S:ReskinButton(obliterum.ObliterateButton)
    S:ReskinIcon(obliterum.ItemSlot.Icon)
end

S:AddCallbackForAddon("Blizzard_ObliterumUI", "Obliterum")
