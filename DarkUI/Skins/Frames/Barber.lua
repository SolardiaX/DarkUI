local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Barber Shop / Character Customize UI
-- Ported from AuroraClassic AddOns/Blizzard_BarbershopUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function reskinCustomizeButton(button)
    S:ReskinButton(button)
    if button.backdrop then button.backdrop:SetInside(nil, 5, 5) end
    if button.gradient then button.gradient:SetInside(nil, 5, 5) end
    button:GetHighlightTexture():SetInside(nil, 5, 5)
end

function S:Barber()
    if not (C.skins.enable and C.skins.barber) then return end

    local frame = BarberShopFrame

    S:ReskinButton(frame.AcceptButton)
    S:ReskinButton(frame.CancelButton)
    S:ReskinButton(frame.ResetButton)
end

function S:CharacterCustomize()
    if not (C.skins.enable and C.skins.barber) then return end

    local frame = CharCustomizeFrame

    reskinCustomizeButton(frame.SmallButtons.ResetCameraButton)
    reskinCustomizeButton(frame.SmallButtons.ZoomOutButton)
    reskinCustomizeButton(frame.SmallButtons.ZoomInButton)
    reskinCustomizeButton(frame.SmallButtons.RotateLeftButton)
    reskinCustomizeButton(frame.SmallButtons.RotateRightButton)
    reskinCustomizeButton(frame.RandomizeAppearanceButton)

    hooksecurefunc(frame, "UpdateOptionButtons", function(self)
        if self.dropdownPool then
            for option in self.dropdownPool:EnumerateActive() do
                if not option.__styled then
                    S:ReskinButton(option.Dropdown)
                    S:ReskinButton(option.DecrementButton)
                    S:ReskinButton(option.IncrementButton)
                    option.__styled = true
                end
            end
        end

        if self.sliderPool then
            for slider in self.sliderPool:EnumerateActive() do
                if not slider.__styled then
                    S:ReskinSlider(slider)
                    slider.__styled = true
                end
            end
        end

        local optionPool = self.pools:GetPool("CustomizationOptionCheckButtonTemplate")
        if optionPool then
            for button in optionPool:EnumerateActive() do
                if not button.__styled then
                    S:ReskinCheck(button.Button)
                    button.__styled = true
                end
            end
        end
    end)
end

S:AddCallbackForAddon("Blizzard_BarbershopUI", "Barber")
S:AddCallbackForAddon("Blizzard_CharacterCustomize", "CharacterCustomize")
