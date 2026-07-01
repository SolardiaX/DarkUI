local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Petition Frame
-- Ported from AuroraClassic FrameXML/PetitionFrame.lua (2026-06)
------------------------------------------------------------------------

local _G = _G

function S:Petition()
    if not (C.skins.enable and C.skins.petition) then return end

    S:ReskinPortraitFrame(_G.PetitionFrame)
    S:ReskinButton(_G.PetitionFrameSignButton)
    S:ReskinButton(_G.PetitionFrameRequestButton)
    S:ReskinButton(_G.PetitionFrameRenameButton)
    S:ReskinButton(_G.PetitionFrameCancelButton)

    _G.PetitionFrameCharterTitle:SetTextColor(1, 0.8, 0)
    _G.PetitionFrameCharterTitle:SetShadowColor(0, 0, 0)
    _G.PetitionFrameMasterTitle:SetTextColor(1, 0.8, 0)
    _G.PetitionFrameMasterTitle:SetShadowColor(0, 0, 0)
    _G.PetitionFrameMemberTitle:SetTextColor(1, 0.8, 0)
    _G.PetitionFrameMemberTitle:SetShadowColor(0, 0, 0)
end

S:AddCallback("Petition")
