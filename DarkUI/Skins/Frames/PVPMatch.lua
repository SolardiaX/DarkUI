local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- PVP Match Scoreboard / Ready Dialog / Results
-- Ported from AuroraClassic FrameXML/PVPMatch.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:PVPMatch()
    if not C.general.skins then return end

    -- ready dialog
    local PVPReadyDialog = _G.PVPReadyDialog

    PVPReadyDialog:StripTextures()
    _G.PVPReadyDialogBackground:Hide()
    S:CreateBackground(PVPReadyDialog)

    S:ReskinButton(PVPReadyDialog.enterButton)
    S:ReskinButton(PVPReadyDialog.leaveButton)
    S:ReskinClose(_G.PVPReadyDialogCloseButton)

    local function stripBorders(self) self:StripTextures() end

    _G.ReadyStatus.Border:SetAlpha(0)
    S:CreateBackground(_G.ReadyStatus)
    S:ReskinClose(_G.ReadyStatus.CloseButton)

    -- match score
    S:CreateBackground(_G.PVPMatchScoreboard)
    _G.PVPMatchScoreboard:HookScript("OnShow", stripBorders)
    S:ReskinClose(_G.PVPMatchScoreboard.CloseButton)

    do
        local content = _G.PVPMatchScoreboard.Content
        local tabContainer = content.TabContainer

        content:StripTextures()
        local bg = content:CreateBackdrop()
        bg:SetBackdropColor(0, 0, 0, 0.25)
        bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
        S:ReskinTrimScrollBar(content.ScrollBar)

        tabContainer:StripTextures()
        for i = 1, 3 do
            tabContainer.TabGroup["Tab" .. i]:StripTextures() -- ReskinTab might taint the score board
        end
    end

    -- match results
    S:CreateBackground(_G.PVPMatchResults)
    _G.PVPMatchResults:HookScript("OnShow", stripBorders)
    S:ReskinClose(_G.PVPMatchResults.CloseButton)
    _G.PVPMatchResults.overlay:StripTextures()

    do
        local content = _G.PVPMatchResults.content
        local tabContainer = content.tabContainer

        content:StripTextures()
        local bg = content:CreateBackdrop()
        bg:SetBackdropColor(0, 0, 0, 0.25)
        bg:SetPoint("BOTTOMRIGHT", tabContainer.InsetBorderTop, 4, -1)
        content.earningsArt:StripTextures()
        S:ReskinTrimScrollBar(content.scrollBar)

        tabContainer:StripTextures()
        for i = 1, 3 do
            S:ReskinTab(tabContainer.tabGroup["tab" .. i])
        end

        local buttonContainer = _G.PVPMatchResults.buttonContainer
        S:ReskinButton(buttonContainer.leaveButton)
        S:ReskinButton(buttonContainer.requeueButton)
    end
end

S:AddCallback("PVPMatch")
