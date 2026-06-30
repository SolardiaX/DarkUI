local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Major Factions / Renown frame (Dragonflight)
-- Ported from AuroraClassic AddOns/Blizzard_MajorFactions.lua (2026-06)
-- Notes:
--   * Aurora source is minimal (7 lines of body); ported faithfully.
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
------------------------------------------------------------------------

local _G = _G

function S:MajorFactions()
    if not (C.skins.enable and C.skins.majorFactions) then return end

    local frame = _G.MajorFactionRenownFrame
    if not frame then return end

    frame:StripTextures()
    S:SetBD(frame)
    S:ReskinClose(frame.CloseButton)
    frame.NineSlice:SetAlpha(0)
    frame.Background:SetAlpha(0)
    S:Reskin(frame.LevelSkipButton)
end

S:AddCallbackForAddon("Blizzard_MajorFactions", "MajorFactions")
