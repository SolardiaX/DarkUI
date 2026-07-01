local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Macro UI
-- Ported from AuroraClassic AddOns/Blizzard_MacroUI.lua (2026-06)
-- Notes:
--   * B:ReskinIconSelector → S:ReskinIconSelectionFrame.
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:MacroUI()
    if not (C.skins.enable and C.skins.macro) then return end

    _G.MacroHorizontalBarLeft:Hide()
    _G.MacroFrameTab1:StripTextures()
    _G.MacroFrameTab2:StripTextures()

    _G.MacroPopupFrame:StripTextures()
    _G.MacroPopupFrame.BorderBox:StripTextures()
    _G.MacroFrameTextBackground:HideBackdrop()

    _G.MacroPopupFrame:SetHeight(525)
    _G.MacroNewButton:ClearAllPoints()
    _G.MacroNewButton:SetPoint("RIGHT", _G.MacroExitButton, "LEFT", -1, 0)

    S:ReskinTrimScrollBar(_G.MacroFrame.MacroSelector.ScrollBar)

    local function handleMacroButton(button)
        if button.__styled then return end
        button.__styled = true
        local bg = S:ReskinIcon(button.Icon)
        button:DisableDrawLayer("BACKGROUND")
        button.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.5)
        button.SelectedTexture:SetInside(bg)
        local hl = button:GetHighlightTexture()
        hl:SetColorTexture(1, 1, 1, 0.25)
        hl:SetInside(bg)
    end
    handleMacroButton(_G.MacroFrameSelectedMacroButton)

    C_Timer.After(0, function() -- delay to avoid taint
        local scrollBox = _G.MacroFrame.MacroSelector.ScrollBox
        hooksecurefunc(scrollBox, "Update", function(self)
            if self.view then self:ForEachFrame(handleMacroButton) end
        end)
        if scrollBox.view then scrollBox:ForEachFrame(handleMacroButton) end
    end)

    S:ReskinIconSelectionFrame(_G.MacroPopupFrame)

    S:ReskinPortraitFrame(_G.MacroFrame)
    _G.MacroFrameScrollFrame:CreateBackdrop()
    S:ReskinTrimScrollBar(_G.MacroFrameScrollFrame.ScrollBar)
    S:ReskinButton(_G.MacroDeleteButton)
    S:ReskinButton(_G.MacroNewButton)
    S:ReskinButton(_G.MacroExitButton)
    S:ReskinButton(_G.MacroEditButton)
    S:ReskinButton(_G.MacroSaveButton)
    S:ReskinButton(_G.MacroCancelButton)
end

S:AddCallbackForAddon("Blizzard_MacroUI", "MacroUI")
