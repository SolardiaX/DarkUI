local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Stable (hunter pets)
-- Ported from ElvUI Mainline/Skins/Stable.lua (v15.15, 2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function AbilitiesList_Layout(list)
    if not list.abilityPool then return end

    for frame in list.abilityPool:EnumerateActive() do
        if not frame.__styled then
            S:HandleIcon(frame.Icon)
            frame.__styled = true
        end
    end
end

function S:Blizzard_StableUI()
    if not (C.skins.enable and C.skins.stable) then return end

    local StableFrame = _G.StableFrame
    S:HandlePortraitFrame(StableFrame)
    StableFrame.MainHelpButton:Hide()
    S:HandleButton(StableFrame.StableTogglePetButton)
    S:HandleButton(StableFrame.ReleasePetButton)

    local StabledPetList = StableFrame.StabledPetList
    StabledPetList:StripTextures()
    StabledPetList.ListName:FontTemplate(nil, 32)
    StabledPetList.ListCounter:StripTextures()
    StabledPetList.ListCounter:CreateBackdrop("Transparent")

    S:HandleEditBox(StabledPetList.FilterBar.SearchBox)
    S:HandleButton(StableFrame.StabledPetList.FilterBar.FilterDropdown)
    S:HandleCloseButton(StableFrame.StabledPetList.FilterBar.FilterDropdown.ResetButton)

    S:HandleTrimScrollBar(StabledPetList.ScrollBar)

    local modelScene = StableFrame.PetModelScene
    if modelScene then
        local sceneShadow = modelScene.PetModelSceneShadow
        if sceneShadow then sceneShadow:SetInside() end

        local inset = modelScene.Inset
        if inset then
            inset.NineSlice:SetTemplate()
            inset.Bg:Hide()
        end

        local abilitiesList = modelScene.AbilitiesList
        if abilitiesList then hooksecurefunc(abilitiesList, "Layout", AbilitiesList_Layout) end

        local petInfo = modelScene.PetInfo
        if petInfo then
            if petInfo.Type then hooksecurefunc(petInfo.Type, "SetText", S.ReplaceIconString) end

            if petInfo.Specialization then S:HandleDropDownBox(petInfo.Specialization) end
        end
    end

    S:HandleModelSceneControlButtons(modelScene.ControlFrame)
end

S:AddCallbackForAddon("Blizzard_StableUI")
