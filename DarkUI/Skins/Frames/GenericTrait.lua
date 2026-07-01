local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Generic Trait UI
-- Ported from AuroraClassic AddOns/Blizzard_GenericTraitUI.lua (2026-06)
-- Aurora noise overlay dropped; DarkUI backdrop carries the texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:GenericTrait()
    if not C.general.skins then return end

    local frame = _G.GenericTraitFrame

    frame:StripTextures()
    S:ReskinClose(frame.CloseButton)
    S:CreateBackground(frame)

    S:ReplaceIconString(frame.Currency.UnspentPointsCount)
    hooksecurefunc(frame.Currency.UnspentPointsCount, "SetText", function(self) S:ReplaceIconString(self) end)
end

S:AddCallbackForAddon("Blizzard_GenericTraitUI", "GenericTrait")
