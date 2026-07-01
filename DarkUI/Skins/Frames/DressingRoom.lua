local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Dressing Room / Transmog
-- Ported from AuroraClassic FrameXML/DressUpFrames.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

local function ResetToggleTexture(button, texture)
    button:GetNormalTexture():SetTexCoord(unpack(C.media.texCoord))
    button:GetNormalTexture():SetInside()
    button:SetNormalTexture(texture)
    button:GetPushedTexture():SetTexCoord(unpack(C.media.texCoord))
    button:GetPushedTexture():SetInside()
    button:SetPushedTexture(texture)
end

function S:DressingRoom()
    if not C.general.skins then return end

    -- Dressup Frame

    S:ReskinPortraitFrame(DressUpFrame)
    S:ReskinButton(DressUpFrameCancelButton)
    S:ReskinButton(DressUpFrameResetButton)
    S:ReskinMinMax(DressUpFrame.MaximizeMinimizeFrame)
    DressUpFrameResetButton:SetPoint("RIGHT", DressUpFrameCancelButton, "LEFT", -1, 0)

    S:ReskinButton(DressUpFrame.LinkButton)
    S:ReskinButton(DressUpFrame.ToggleCustomSetDetailsButton)
    ResetToggleTexture(DressUpFrame.ToggleCustomSetDetailsButton, 1392954) -- 70_professions_scroll_01

    DressUpFrame.CustomSetDetailsPanel:StripTextures()
    local bg = S:CreateBackground(DressUpFrame.CustomSetDetailsPanel)
    bg:SetInside(nil, 11, 11)

    hooksecurefunc(DressUpFrame.CustomSetDetailsPanel, "Refresh", function(self)
        if self.slotPool then
            for slot in self.slotPool:EnumerateActive() do
                if not slot.bg then
                    slot.bg = S:ReskinIcon(slot.Icon)
                    S:ReskinIconBorder(slot.IconBorder, true, true)
                end
            end
        end
    end)

    S:ReskinCheck(TransmogAndMountDressupFrame.ShowMountCheckButton)
    S:ReskinModelControl(DressUpFrame.ModelScene)

    local selectionPanel = DressUpFrame.SetSelectionPanel
    if selectionPanel then
        selectionPanel:StripTextures()
        S:CreateBackground(selectionPanel):SetInside(nil, 9, 9)

        local function SetupSetButton(button)
            if button.__styled then return end
            button.bg = S:ReskinIcon(button.Icon)
            S:ReskinIconBorder(button.IconBorder, true, true)
            button.BackgroundTexture:SetAlpha(0)
            button.SelectedTexture:SetColorTexture(1, 0.8, 0, 0.25)
            button.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
            button.__styled = true
        end

        hooksecurefunc(selectionPanel.ScrollBox, "Update", function(self) self:ForEachFrame(SetupSetButton) end)
    end

    S:ReskinDropDown(DressUpFrameCustomSetDropdown)
    S:ReskinButton(DressUpFrameCustomSetDropdown.SaveButton)

    -- SideDressUp

    SideDressUpFrame:StripTextures()
    S:CreateBackground(SideDressUpFrame)
    S:ReskinButton(SideDressUpFrame.ResetButton)
    S:ReskinClose(SideDressUpFrameCloseButton)

    SideDressUpFrame:HookScript("OnShow", function(self)
        SideDressUpFrame:ClearAllPoints()
        SideDressUpFrame:SetPoint("LEFT", self:GetParent(), "RIGHT", 3, 0)
    end)

    -- Outfit frame

    local editFrame = WardrobeCustomSetEditFrame
    if editFrame then
        editFrame:StripTextures()
        editFrame.EditBox:DisableDrawLayer("BACKGROUND")
        S:CreateBackground(editFrame)
        local editBg = editFrame.EditBox:CreateBackdrop()
        editBg:SetPoint("TOPLEFT", -5, -3)
        editBg:SetPoint("BOTTOMRIGHT", 5, 3)
        S:ReskinButton(editFrame.AcceptButton)
        S:ReskinButton(editFrame.CancelButton)
        S:ReskinButton(editFrame.DeleteButton)
    end
end

S:AddCallback("DressingRoom")
