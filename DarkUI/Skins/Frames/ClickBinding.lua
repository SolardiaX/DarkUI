local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Click Binding UI
-- Ported from AuroraClassic AddOns/Blizzard_ClickBindingUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

local select = select
local hooksecurefunc = hooksecurefunc

local function updateNewGlow(self)
    if self.NewOutline:IsShown() then
        self.bg:SetBackdropBorderColor(0, 0.7, 0.08)
    else
        self.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local function updateIconGlow(self, show)
    if show then
        self.__owner.bg:SetBackdropBorderColor(0, 0.7, 0.08)
    else
        self.__owner.bg:SetBackdropBorderColor(0, 0, 0)
    end
end

local function reskinScrollChild(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        local icon = child and child.Icon
        if icon and not icon.bg then
            icon.bg = S:ReskinIcon(icon)
            child.Background:Hide()
            child.bg = child.Background:CreateBackdrop()

            S:Reskin(child.DeleteButton)
            child.DeleteButton:SetSize(20, 20)
            child.FrameHighlight:SetInside(child.bg)
            child.FrameHighlight:SetColorTexture(1, 1, 1, 0.15)

            child.NewOutline:SetTexture("")
            child.BindingText:SetFontObject(Game12Font)
            hooksecurefunc(child, "Init", updateNewGlow)

            local iconHighlight = child.IconHighlight
            iconHighlight:SetTexture("")
            iconHighlight.__owner = icon
            hooksecurefunc(iconHighlight, "SetShown", updateIconGlow)
        end
    end
end

function S:ClickBindingUI()
    if not (C.skins.enable and C.skins.misc) then return end

    local frame = _G.ClickBindingFrame

    S:ReskinPortraitFrame(frame)
    frame.TutorialButton.Ring:Hide()
    frame.TutorialButton:SetPoint("TOPLEFT", frame, "TOPLEFT", -12, 12)

    S:Reskin(frame.ResetButton)
    S:Reskin(frame.AddBindingButton)
    S:Reskin(frame.SaveButton)
    S:ReskinTrimScroll(frame.ScrollBar)

    frame.ScrollBoxBackground:Hide()
    hooksecurefunc(frame.ScrollBox, "Update", reskinScrollChild)

    frame.TutorialFrame.NineSlice:Hide()
    S:SetBD(frame.TutorialFrame)

    if frame.EnableMouseoverCastCheckbox then S:ReskinCheck(frame.EnableMouseoverCastCheckbox) end
end

S:AddCallbackForAddon("Blizzard_ClickBindingUI", "ClickBindingUI")
