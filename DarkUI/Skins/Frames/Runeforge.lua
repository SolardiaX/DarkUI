local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Runeforge UI
-- Ported from AuroraClassic AddOns/Blizzard_RuneforgeUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc
local gsub = string.gsub

local function updateSelectedTexture(texture, shown)
    local button = texture.__owner
    if shown then
        button.bg:SetBackdropBorderColor(1, 0.8, 0)
    else
        button.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local function replaceCurrencyDisplay(self)
    if not self.currencyID then return end
    local text = GetCurrencyString(self.currencyID, self.amount, self.colorCode, self.abbreviate)
    local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
    if count > 0 then self:SetText(newText) end
end

local function SetCurrenciesHook(self)
    if self.currencyFramePool then
        for frame in self.currencyFramePool:EnumerateActive() do
            if not frame.hooked then
                replaceCurrencyDisplay(frame)
                hooksecurefunc(frame, "SetCurrencyFromID", replaceCurrencyDisplay)
                frame.hooked = true
            end
        end
    end
end

function S:Runeforge()
    if not (C.skins.enable and C.skins.runeforge) then return end

    local frame = RuneforgeFrame
    S:ReskinClose(frame.CloseButton, nil, -70, -70)

    local createFrame = frame.CreateFrame
    S:ReskinButton(createFrame.CraftItemButton)

    hooksecurefunc(frame.CurrencyDisplay, "SetCurrencies", SetCurrenciesHook)
    hooksecurefunc(createFrame.Cost.Currencies, "SetCurrencies", SetCurrenciesHook)

    local powerFrame = frame.CraftingFrame.PowerFrame
    powerFrame:StripTextures()
    S:CreateBackground(powerFrame)

    hooksecurefunc(powerFrame.PowerList, "RefreshListDisplay", function(self)
        if not self.elements then return end

        for i = 1, self:GetNumElementFrames() do
            local button = self.elements[i]
            if button and not button.bg then
                button.Border:SetAlpha(0)
                button.CircleMask:Hide()
                button.bg = S:ReskinIcon(button.Icon)
                button.SelectedTexture:SetTexture("")
                button.SelectedTexture.__owner = button
                hooksecurefunc(button.SelectedTexture, "SetShown", updateSelectedTexture)
            end
        end
    end)

    local pageControl = powerFrame.PageControl
    S:ReskinArrow(pageControl.BackwardButton, "left")
    S:ReskinArrow(pageControl.ForwardButton, "right")

    -- TODO: no S: facade for ReskinTooltip
end

S:AddCallbackForAddon("Blizzard_RuneforgeUI", "Runeforge")
