local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Guild Registrar Frame
-- Ported from AuroraClassic FrameXML/GuildRegistrarFrame.lua (2026-06)
------------------------------------------------------------------------

local _G = _G

function S:GuildRegistrar()
    if not (C.skins.enable and C.skins.guild) then return end

    _G.GuildRegistrarFrameEditBox:SetHeight(20)
    _G.AvailableServicesText:SetTextColor(1, 1, 1)
    _G.AvailableServicesText:SetShadowColor(0, 0, 0)

    S:ReskinPortraitFrame(_G.GuildRegistrarFrame)
    _G.GuildRegistrarFrameEditBox:DisableDrawLayer("BACKGROUND")
    _G.GuildRegistrarFrameEditBox:CreateBackdrop()
    S:ReskinButton(_G.GuildRegistrarFrameGoodbyeButton)
    S:ReskinButton(_G.GuildRegistrarFramePurchaseButton)
    S:ReskinButton(_G.GuildRegistrarFrameCancelButton)
end

S:AddCallback("GuildRegistrar")
