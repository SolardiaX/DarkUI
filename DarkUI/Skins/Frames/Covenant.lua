local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Covenant Preview, Sanctum, and Renown frames (Shadowlands)
-- Ported from AuroraClassic AddOns/Blizzard_Covenant.lua (2026-06)
-- Notes:
--   * Three separate addon registrations: CovenantPreviewUI, CovenantSanctum,
--     CovenantRenown — each gated on C.skins.covenant.
--   * Aurora noise overlay dropped; DarkUI backdrop supplies texture.
------------------------------------------------------------------------

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

------------------------------------------------------------------------
-- CovenantPreviewUI
------------------------------------------------------------------------

function S:CovenantPreviewUI()
    if not (C.skins.enable and C.skins.covenant) then return end

    local CovenantPreviewFrame = _G.CovenantPreviewFrame
    S:Reskin(CovenantPreviewFrame.SelectButton)

    local infoPanel = CovenantPreviewFrame.InfoPanel
    infoPanel.Name:SetTextColor(1, 0.8, 0)
    infoPanel.Location:SetTextColor(1, 1, 1)
    infoPanel.Description:SetTextColor(1, 1, 1)
    infoPanel.AbilitiesFrame.AbilitiesLabel:SetTextColor(1, 0.8, 0)
    infoPanel.SoulbindsFrame.SoulbindsLabel:SetTextColor(1, 0.8, 0)
    infoPanel.CovenantFeatureFrame.Label:SetTextColor(1, 0.8, 0)

    hooksecurefunc(CovenantPreviewFrame, "TryShow", function(self)
        if not self.bg then
            self.Background:SetAlpha(0)
            self.BorderFrame:SetAlpha(0)
            self.Title:DisableDrawLayer("BACKGROUND")
            self.Title.Text:SetTextColor(1, 0.8, 0)
            self.Title.Text:SetFontObject(SystemFont_Huge1)
            self.ModelSceneContainer.ModelSceneBorder:SetAlpha(0)
            self.Title:CreateBackdrop()
            S:ReskinClose(self.CloseButton)
            self.bg = S:SetBD(self)
        end
    end)
end

S:AddCallbackForAddon("Blizzard_CovenantPreviewUI", "CovenantPreviewUI")

------------------------------------------------------------------------
-- CovenantSanctum
------------------------------------------------------------------------

local function reskinTalentsList(self)
    for frame in self.talentPool:EnumerateActive() do
        if not frame.bg then
            frame.Border:SetAlpha(0)
            frame.IconBorder:SetAlpha(0)
            frame.TierBorder:SetAlpha(0)
            frame.Background:SetAlpha(0)
            frame.bg = frame:CreateBackdrop()
            frame.bg:SetInside()
            frame.Highlight:SetColorTexture(1, 1, 1, 0.25)
            frame.Highlight:SetInside(frame.bg)
            S:ReskinIcon(frame.Icon)
            frame.Icon:SetPoint("TOPLEFT", 7, -7)

            S:ReplaceIconString(frame.InfoText)
            hooksecurefunc(frame.InfoText, "SetText", function(self) S:ReplaceIconString(self) end)
        end
    end
end

local function replaceCurrencies(displayGroup)
    for frame in displayGroup.currencyFramePool:EnumerateActive() do
        if not frame.__styled then
            S:ReplaceIconString(frame.Text)
            hooksecurefunc(frame.Text, "SetText", function(self) S:ReplaceIconString(self) end)

            frame.__styled = true
        end
    end
end

function S:CovenantSanctum()
    if not (C.skins.enable and C.skins.covenant) then return end

    local CovenantSanctumFrame = _G.CovenantSanctumFrame

    CovenantSanctumFrame:HookScript("OnShow", function(self)
        if not self.bg then
            self.bg = S:SetBD(self)
            self.NineSlice:SetAlpha(0)
            self.LevelFrame.Background:SetAlpha(0)
            S:ReskinClose(self.CloseButton)
        end
    end)

    local upgradesTab = CovenantSanctumFrame.UpgradesTab
    upgradesTab.Background:SetAlpha(0)
    upgradesTab.Background:CreateBackdrop()
    S:Reskin(upgradesTab.DepositButton)
    for _, frame in ipairs(upgradesTab.Upgrades) do
        if frame.TierBorder then frame.TierBorder:SetAlpha(0) end
    end
    upgradesTab.CurrencyBackground:SetAlpha(0)
    replaceCurrencies(upgradesTab.CurrencyDisplayGroup)

    local talentsList = upgradesTab.TalentsList
    talentsList.Divider:SetAlpha(0)
    talentsList:CreateBackdrop()
    talentsList.BackgroundTile:SetAlpha(0)
    talentsList.IntroBox.Background:Hide()
    S:Reskin(talentsList.UpgradeButton)
    hooksecurefunc(talentsList, "Refresh", reskinTalentsList)
end

S:AddCallbackForAddon("Blizzard_CovenantSanctum", "CovenantSanctum")

------------------------------------------------------------------------
-- CovenantRenown
------------------------------------------------------------------------

function S:CovenantRenown()
    if not (C.skins.enable and C.skins.covenant) then return end

    hooksecurefunc(_G.CovenantRenownFrame, "SetUpCovenantData", function(self)
        self:StripTextures()

        if not self.__styled then
            S:SetBD(self)
            S:ReskinClose(self.CloseButton)

            self.__styled = true
        end
    end)
end

S:AddCallbackForAddon("Blizzard_CovenantRenown", "CovenantRenown")
