local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Stable UI (Hunter / Warlock pet stable)
-- Ported from AuroraClassic AddOns/Blizzard_StableUI.lua (2026-06)
-- Notes:
--   * B:ReplaceIconString → S:ReplaceIconString.
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:StableUI()
    if not C.general.skins then return end

    S:ReskinPortraitFrame(_G.StableFrame)
    S:ReskinButton(_G.StableFrame.StableTogglePetButton)
    S:ReskinButton(_G.StableFrame.ReleasePetButton)

    local stabledPetList = _G.StableFrame.StabledPetList
    stabledPetList:StripTextures()
    stabledPetList.ListCounter:StripTextures()
    stabledPetList.ListCounter:CreateBackdrop()
    S:ReskinEditBox(stabledPetList.FilterBar.SearchBox)
    S:ReskinFilterButton(stabledPetList.FilterBar.FilterDropdown)
    S:ReskinTrimScrollBar(stabledPetList.ScrollBar)

    local modelScene = _G.StableFrame.PetModelScene
    if modelScene then
        local petInfo = modelScene.PetInfo
        if petInfo then hooksecurefunc(petInfo.Type, "SetText", function(self) S:ReplaceIconString(self) end) end

        local list = modelScene.AbilitiesList
        if list then
            hooksecurefunc(list, "Layout", function(self)
                for frame in self.abilityPool:EnumerateActive() do
                    if not frame.__styled then
                        S:ReskinIcon(frame.Icon)
                        frame.__styled = true
                    end
                end
            end)
        end

        S:ReskinModelControl(modelScene)

        if petInfo and petInfo.Specialization then S:ReskinDropDown(petInfo.Specialization) end
    end
end

S:AddCallbackForAddon("Blizzard_StableUI", "StableUI")
