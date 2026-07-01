local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Delves (Companion Config / Dashboard / Difficulty Picker)
-- Ported from AuroraClassic AddOns/Blizzard_Delves.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
-- Note: Three separate Blizzard addons collapsed into one S: function per addon.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function reskinButton(button)
    if button.__styled then return end
    if button.Border then button.Border:SetAlpha(0) end
    if button.Icon then S:ReskinIcon(button.Icon) end
    button.__styled = true
end

local function updateButton(self) self:ForEachFrame(reskinButton) end

local function reskinOptionSlot(frame, skip)
    local option = frame.OptionsList
    option:StripTextures()
    local bg = S:CreateBackground(option, nil, -5, 5, 5, -5)
    bg:SetFrameLevel(3)
    if not skip then hooksecurefunc(option.ScrollBox, "Update", updateButton) end
end

function S:DelvesCompanionConfiguration()
    if not C.general.skins then return end

    S:ReskinPortraitFrame(_G.DelvesCompanionConfigurationFrame)
    S:ReskinButton(_G.DelvesCompanionConfigurationFrame.CompanionConfigShowAbilitiesButton)

    reskinOptionSlot(_G.DelvesCompanionConfigurationFrame.CompanionCombatRoleSlot, true)
    reskinOptionSlot(_G.DelvesCompanionConfigurationFrame.CompanionUtilityTrinketSlot)
    reskinOptionSlot(_G.DelvesCompanionConfigurationFrame.CompanionCombatTrinketSlot)

    S:ReskinPortraitFrame(_G.DelvesCompanionAbilityListFrame)
    S:ReskinDropDown(_G.DelvesCompanionAbilityListFrame.DelvesCompanionRoleDropdown)
    S:ReskinArrow(_G.DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.PrevPageButton, "left")
    S:ReskinArrow(_G.DelvesCompanionAbilityListFrame.DelvesCompanionAbilityListPagingControls.NextPageButton, "right")

    hooksecurefunc(_G.DelvesCompanionAbilityListFrame, "UpdatePaginatedButtonDisplay", function(self)
        for _, button in pairs(self.buttons) do
            if not button.__styled then
                if button.Icon then S:ReskinIcon(button.Icon) end

                button.__styled = true
            end
        end
    end)
end

S:AddCallbackForAddon("Blizzard_DelvesCompanionConfiguration", "DelvesCompanionConfiguration")

function S:DelvesDashboardUI()
    if not C.general.skins then return end

    _G.DelvesDashboardFrame.DashboardBackground:SetAlpha(0)
    S:ReskinButton(_G.DelvesDashboardFrame.ButtonPanelLayoutFrame.CompanionConfigButtonPanel.CompanionConfigButton)
end

S:AddCallbackForAddon("Blizzard_DelvesDashboardUI", "DelvesDashboardUI")

local function handleReward(rewardFrame)
    if not rewardFrame.bg then
        rewardFrame:CreateBackdrop()
        rewardFrame.backdrop:SetBackdropColor(0, 0, 0, 0.25)
        rewardFrame.NameFrame:SetAlpha(0)
        rewardFrame.bg = S:ReskinIcon(rewardFrame.Icon)
        S:ReskinIconBorder(rewardFrame.IconBorder, true)
    end
end

function S:DelvesDifficultyPicker()
    if not C.general.skins then return end

    S:ReskinPortraitFrame(_G.DelvesDifficultyPickerFrame)
    S:ReskinDropDown(_G.DelvesDifficultyPickerFrame.Dropdown)
    S:ReskinButton(_G.DelvesDifficultyPickerFrame.EnterDelveButton)

    hooksecurefunc(_G.DelvesDifficultyPickerFrame.DelveRewardsContainerFrame.ScrollBox, "Update", function(self) self:ForEachFrame(handleReward) end)
end

S:AddCallbackForAddon("Blizzard_DelvesDifficultyPicker", "DelvesDifficultyPicker")
