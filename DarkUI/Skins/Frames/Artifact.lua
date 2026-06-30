local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Artifact Forge UI
-- Ported from AuroraClassic AddOns/Blizzard_ArtifactUI.lua (2026-06)
-- Note: Aurora noise overlay (CreateTex) dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

function S:ArtifactUI()
    if not (C.skins.enable and C.skins.artifact) then return end

    ArtifactFrame:StripTextures()
    S:SetBD(ArtifactFrame)
    S:ReskinTab(ArtifactFrameTab1)
    S:ReskinTab(ArtifactFrameTab2)
    ArtifactFrameTab1:ClearAllPoints()
    ArtifactFrameTab1:SetPoint("TOPLEFT", ArtifactFrame, "BOTTOMLEFT", 10, 0)
    S:ReskinClose(ArtifactFrame.CloseButton)
    ArtifactFrame.Background:Hide()
    ArtifactFrame.PerksTab.BackgroundBack:Hide()
    ArtifactFrame.PerksTab.Model.BackgroundBackShadow:Hide()
    ArtifactFrame.PerksTab.HeaderBackground:Hide()
    ArtifactFrame.PerksTab.TitleContainer.Background:SetAlpha(0)
    ArtifactFrame.PerksTab.Model:SetAlpha(0.5)
    ArtifactFrame.PerksTab.Model.BackgroundFront:Hide()
    ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackground:SetAlpha(0)
    ArtifactFrame.ForgeBadgeFrame.ForgeLevelBackgroundBlack:SetAlpha(0)
    ArtifactFrame.ForgeBadgeFrame.ItemIcon:Hide()
    ArtifactFrame.AppearancesTab.Background:Hide()

    -- Appearance

    for i = 1, 6 do
        local set = ArtifactFrame.AppearancesTab.appearanceSetPool:Acquire()
        set.Background:Hide()
        local bg = set:CreateBackdrop()
        bg:SetPoint("TOPLEFT", 10, -5)
        bg:SetPoint("BOTTOMRIGHT", -10, 5)
        for j = 1, 4 do
            local slot = ArtifactFrame.AppearancesTab.appearanceSlotPool:Acquire()
            slot.Border:SetAlpha(0)
            slot:CreateBackdrop()

            slot.Background:Hide()
            slot.SwatchTexture:SetTexCoord(0.2, 0.8, 0.2, 0.8)
            slot.SwatchTexture:SetAllPoints()
            slot.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
            slot.HighlightTexture:SetAllPoints()

            slot.Selected:SetDrawLayer("BACKGROUND")
            slot.Selected:SetTexture(DB.bdTex)
            slot.Selected:SetVertexColor(1, 1, 0)
            slot.Selected:SetOutside()
        end
    end
end

S:AddCallbackForAddon("Blizzard_ArtifactUI", "ArtifactUI")
