local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Major factions (renown)
-- Ported from ElvUI Mainline/Skins/MajorFaction.lua (v15.15, 2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function SetupMajorFaction(frame)
    if frame.Divider then frame.Divider:Hide() end
    if frame.NineSlice then frame.NineSlice:Hide() end
    if frame.Border then frame.Border:Hide() end
    if frame.TopLeftBorderDecoration then frame.TopLeftBorderDecoration:Hide() end
    if frame.TopRightBorderDecoration then frame.TopRightBorderDecoration:Hide() end
    if frame.Background then frame.Background:Hide() end
    if frame.BackgroundShadow then frame.BackgroundShadow:Hide() end
    if frame.CloseButton.Border then frame.CloseButton.Border:Hide() end
end

function S:Blizzard_MajorFactionRenown()
    if not (C.skins.enable and C.skins.majorFactions) then return end

    local RenownFrame = _G.MajorFactionRenownFrame
    RenownFrame:SetTemplate("Transparent")
    S:HandleCloseButton(RenownFrame.CloseButton)

    if RenownFrame.LevelSkipButton then S:HandleButton(RenownFrame.LevelSkipButton) end

    if C.skins.parchment_remover then hooksecurefunc(RenownFrame, "SetUpMajorFactionData", SetupMajorFaction) end
end

S:AddCallbackForAddon("Blizzard_MajorFactionRenown")
