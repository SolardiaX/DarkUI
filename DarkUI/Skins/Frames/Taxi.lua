local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Taxi / Flight Map Frame
-- Ported from AuroraClassic FrameXML/TaxiFrame.lua (2026-06)
------------------------------------------------------------------------

function S:Taxi()
    if not (C.skins.enable and C.skins.misc) then return end

    TaxiFrame:DisableDrawLayer("BORDER")
    TaxiFrame:DisableDrawLayer("OVERLAY")
    TaxiFrame.Bg:Hide()
    TaxiFrame.TitleBg:Hide()
    TaxiFrame.TopTileStreaks:Hide()

    S:SetBD(TaxiFrame, nil, 3, -23, -5, 3)
    S:ReskinClose(TaxiFrame.CloseButton, TaxiRouteMap)
end

S:AddCallback("Taxi")
