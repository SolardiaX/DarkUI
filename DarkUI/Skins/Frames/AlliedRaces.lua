local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Allied Races UI
-- Ported from AuroraClassic AddOns/Blizzard_AlliedRacesUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

local select = select

function S:AlliedRacesUI()
    if not (C.skins.enable and C.skins.alliedRaces) then return end

    local AlliedRacesFrame = AlliedRacesFrame
    S:ReskinPortraitFrame(AlliedRacesFrame)
    select(2, AlliedRacesFrame.ModelScene:GetRegions()):Hide()

    local scrollFrame = AlliedRacesFrame.RaceInfoFrame.ScrollFrame
    S:ReskinTrimScroll(scrollFrame.ScrollBar)
    AlliedRacesFrame.RaceInfoFrame.AlliedRacesRaceName:SetTextColor(1, 0.8, 0)
    scrollFrame.Child.RaceDescriptionText:SetTextColor(1, 1, 1)
    scrollFrame.Child.RacialTraitsLabel:SetTextColor(1, 0.8, 0)

    AlliedRacesFrame:HookScript("OnShow", function()
        local parent = scrollFrame.Child
        for i = 1, parent:GetNumChildren() do
            local bu = select(i, parent:GetChildren())

            if bu.Icon and not bu.__styled then
                select(3, bu:GetRegions()):Hide()
                S:ReskinIcon(bu.Icon)
                bu.Text:SetTextColor(1, 1, 1)

                bu.__styled = true
            end
        end
    end)
end

S:AddCallbackForAddon("Blizzard_AlliedRacesUI", "AlliedRacesUI")
