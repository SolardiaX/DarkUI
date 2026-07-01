local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Archaeology UI
-- Ported from AuroraClassic AddOns/Blizzard_ArchaeologyUI.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop carries texture.
------------------------------------------------------------------------

local _G = _G

function S:ArchaeologyUI()
    if not C.general.skins then return end

    S:ReskinPortraitFrame(ArchaeologyFrame)
    ArchaeologyFrame:DisableDrawLayer("BACKGROUND")
    S:ReskinButton(ArchaeologyFrameArtifactPageSolveFrameSolveButton)
    S:ReskinButton(ArchaeologyFrameArtifactPageBackButton)

    ArchaeologyFrameSummaryPageTitle:SetTextColor(1, 1, 1)
    ArchaeologyFrameArtifactPageHistoryTitle:SetTextColor(1, 0.8, 0)
    ArchaeologyFrameArtifactPageHistoryScrollChildText:SetTextColor(1, 1, 1)
    ArchaeologyFrameHelpPageTitle:SetTextColor(1, 1, 1)
    ArchaeologyFrameHelpPageDigTitle:SetTextColor(1, 1, 1)
    ArchaeologyFrameHelpPageHelpScrollHelpText:SetTextColor(1, 1, 1)
    ArchaeologyFrameCompletedPage:GetRegions():SetTextColor(1, 1, 1)
    ArchaeologyFrameCompletedPageTitle:SetTextColor(1, 1, 1)
    ArchaeologyFrameCompletedPageTitleTop:SetTextColor(1, 1, 1)
    ArchaeologyFrameCompletedPageTitleMid:SetTextColor(1, 1, 1)
    ArchaeologyFrameCompletedPagePageText:SetTextColor(1, 1, 1)
    ArchaeologyFrameSummaryPagePageText:SetTextColor(1, 1, 1)
    for i = 1, ARCHAEOLOGY_MAX_RACES do
        local bu = _G["ArchaeologyFrameSummaryPageRace" .. i]
        bu.raceName:SetTextColor(1, 1, 1)
    end

    for i = 1, ARCHAEOLOGY_MAX_COMPLETED_SHOWN do
        local buttonName = "ArchaeologyFrameCompletedPageArtifact" .. i
        local button = _G[buttonName]
        local icon = _G[buttonName .. "Icon"]
        local name = _G[buttonName .. "ArtifactName"]
        local subText = _G[buttonName .. "ArtifactSubText"]
        button:StripTextures()
        S:ReskinIcon(icon)
        name:SetTextColor(1, 0.8, 0)
        subText:SetTextColor(1, 1, 1)
        local bg = button:CreateBackdrop()
        bg:SetPoint("TOPLEFT", -4, 4)
        bg:SetPoint("BOTTOMRIGHT", 4, -4)
    end

    ArchaeologyFrameInfoButton:SetPoint("TOPLEFT", 3, -3)
    ArchaeologyFrameSummarytButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -50)
    ArchaeologyFrameSummarytButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)
    ArchaeologyFrameCompletedButton:SetPoint("TOPLEFT", ArchaeologyFrame, "TOPRIGHT", 1, -120)
    ArchaeologyFrameCompletedButton:SetFrameLevel(ArchaeologyFrame:GetFrameLevel() - 1)

    S:ReskinDropDown(ArchaeologyFrameRaceFilter)
    S:ReskinTrimScrollBar(ArchaeologyFrameArtifactPageHistoryScroll.ScrollBar)
    S:ReskinArrow(ArchaeologyFrameCompletedPagePrevPageButton, "left")
    S:ReskinArrow(ArchaeologyFrameCompletedPageNextPageButton, "right")
    ArchaeologyFrameCompletedPagePrevPageButtonIcon:Hide()
    ArchaeologyFrameCompletedPageNextPageButtonIcon:Hide()
    S:ReskinArrow(ArchaeologyFrameSummaryPagePrevPageButton, "left")
    S:ReskinArrow(ArchaeologyFrameSummaryPageNextPageButton, "right")
    ArchaeologyFrameSummaryPagePrevPageButtonIcon:Hide()
    ArchaeologyFrameSummaryPageNextPageButtonIcon:Hide()

    ArchaeologyFrameRankBar:StripTextures()
    ArchaeologyFrameRankBarBar:SetTexture(C.media.texture.blank)
    ArchaeologyFrameRankBarBar:SetGradient("VERTICAL", CreateColor(0, 0.65, 0, 1), CreateColor(0, 0.75, 0, 1))
    ArchaeologyFrameRankBar:SetHeight(14)
    ArchaeologyFrameRankBar:CreateBackdrop()
    S:ReskinIcon(ArchaeologyFrameArtifactPageIcon)

    ArchaeologyFrameArtifactPageSolveFrameStatusBar:StripTextures()
    ArchaeologyFrameArtifactPageSolveFrameStatusBar:CreateBackdrop()
    local barTexture = ArchaeologyFrameArtifactPageSolveFrameStatusBar:GetStatusBarTexture()
    barTexture:SetTexture(C.media.texture.blank)
    barTexture:SetGradient("VERTICAL", CreateColor(0.65, 0.25, 0, 1), CreateColor(0.75, 0.35, 0.1, 1))

    -- ArcheologyDigsiteProgressBar

    ArcheologyDigsiteProgressBar:StripTextures()
    S:CreateBackground(ArcheologyDigsiteProgressBar.FillBar)
    ArcheologyDigsiteProgressBar.FillBar:SetStatusBarTexture(C.media.texture.status)
    ArcheologyDigsiteProgressBar.FillBar:SetStatusBarColor(0.7, 0.3, 0.2)

    local ticks = {}
    ArcheologyDigsiteProgressBar:HookScript("OnShow", function(self)
        local bar = self.FillBar
        if not bar then return end
        S:CreateAndUpdateBarTicks(bar, ticks, bar.fillBarMax)
    end)
end

S:AddCallbackForAddon("Blizzard_ArchaeologyUI", "ArchaeologyUI")
