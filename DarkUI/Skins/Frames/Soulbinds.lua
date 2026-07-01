local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Soulbinds Viewer (Shadowlands)
-- Ported from AuroraClassic AddOns/Blizzard_Soulbinds.lua (2026-06)
-- Notes:
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function reskinConduitList(frame)
    local header = frame.CategoryButton.Container
    if header and not header.__styled then
        header:DisableDrawLayer("BACKGROUND")
        local bg = header:CreateBackdrop()
        bg:SetPoint("TOPLEFT", 2, 0)
        bg:SetPoint("BOTTOMRIGHT", 15, 0)

        header.__styled = true
    end

    for button in frame.pool:EnumerateActive() do
        if button and not button.__styled then
            button.Spec.IconOverlay:Hide()
            S:ReskinIcon(button.Spec.Icon):SetFrameLevel(8)

            button.__styled = true
        end
    end
end

function S:Soulbinds()
    if not (C.skins.enable and C.skins.soulbinds) then return end

    local SoulbindViewer = _G.SoulbindViewer

    SoulbindViewer:StripTextures()
    SoulbindViewer.Background:SetAlpha(0)
    S:CreateBackground(SoulbindViewer)
    S:ReskinClose(SoulbindViewer.CloseButton)
    S:ReskinButton(SoulbindViewer.CommitConduitsButton)
    S:ReskinButton(SoulbindViewer.ActivateSoulbindButton)

    local numChildrenStyled = 0
    hooksecurefunc(SoulbindViewer.ConduitList.ScrollBox, "Update", function(self)
        local numChildren = self.ScrollTarget:GetNumChildren()
        if numChildren > numChildrenStyled then
            for i = 1, numChildren do
                local list = select(i, self.ScrollTarget:GetChildren())
                if list and not list.hooked then
                    hooksecurefunc(list, "Layout", reskinConduitList)
                    list.hooked = true
                end
            end

            numChildrenStyled = numChildren
        end
    end)
end

S:AddCallbackForAddon("Blizzard_Soulbinds", "Soulbinds")
