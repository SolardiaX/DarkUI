local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Quest Frame
-- Ported from NDui QuestFrame.lua + ElvUI Quest.lua (2026-07)
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc
local strmatch = strmatch
local MAX_REQUIRED_ITEMS = MAX_REQUIRED_ITEMS

local function updateProgressItemQuality(self)
    local button = self.__owner
    local index = button:GetID()
    local buttonType = button.type
    local objectType = button.objectType

    local quality
    if objectType == "item" then
        quality = select(4, GetQuestItemInfo(buttonType, index))
    elseif objectType == "currency" then
        local info = C_QuestOffer.GetQuestRequiredCurrencyInfo(index)
        quality = info and info.quality
    end

    local color = C.media.qualityColors[quality or 1]
    button.bg:SetBackdropBorderColor(color.r, color.g, color.b)
end

function S:QuestFrame()
    if not C.general.skins then return end

    S:ReskinPortraitFrame(_G.QuestFrame)

    _G.QuestFrameDetailPanel:StripTextures()
    _G.QuestFrameRewardPanel:StripTextures()
    _G.QuestFrameProgressPanel:StripTextures()
    _G.QuestFrameGreetingPanel:StripTextures()

    _G.QuestDetailScrollFrame:StripTextures()
    _G.QuestProgressScrollFrame:StripTextures()
    _G.QuestGreetingScrollFrame:StripTextures()
    _G.QuestRewardScrollFrame:StripTextures()
    _G.QuestLogPopupDetailFrameScrollFrame:StripTextures()
    _G.QuestDetailScrollChildFrame:StripTextures()
    _G.QuestRewardScrollChildFrame:StripTextures()

    _G.QuestFrameDetailPanel.SealMaterialBG:SetAlpha(0)
    _G.QuestFrameRewardPanel.SealMaterialBG:SetAlpha(0)
    _G.QuestFrameProgressPanel.SealMaterialBG:SetAlpha(0)
    _G.QuestFrameGreetingPanel.SealMaterialBG:SetAlpha(0)

    if _G.QuestFrameDetailPanelBg then 
        _G.QuestFrameDetailPanelBg:SetAlpha(0)
        local bg = _G.QuestFrameDetailPanelBg:CreateBackdrop()
        bg:SetAlpha(1)
    end
    if _G.QuestFrameRewardPanelBg then 
        _G.QuestFrameRewardPanelBg:SetAlpha(0)
        local bg = _G.QuestFrameRewardPanelBg:CreateBackdrop()
        bg:SetAlpha(1)
    end
    if _G.QuestFrameProgressPanelBg then 
        _G.QuestFrameProgressPanelBg:SetAlpha(0)
        local bg = _G.QuestFrameProgressPanelBg:CreateBackdrop()
        bg:SetAlpha(1)
    end

    -- Greeting break line
    local line = _G.QuestFrameGreetingPanel:CreateTexture()
    line:SetColorTexture(1, 1, 1, 0.25)
    line:SetSize(256, E.mult)
    line:SetPoint("CENTER", _G.QuestGreetingFrameHorizontalBreak)
    _G.QuestGreetingFrameHorizontalBreak:SetTexture("")
    _G.QuestFrameGreetingPanel:HookScript("OnShow", function()
        line:SetShown(_G.QuestGreetingFrameHorizontalBreak:IsShown())
    end)

    -- Progress items
    for i = 1, MAX_REQUIRED_ITEMS do
        local button = _G["QuestProgressItem" .. i]
        if button then
            button.NameFrame:Hide()
            button.bg = S:ReskinIcon(button.Icon)
            button.Icon.__owner = button
            hooksecurefunc(button.Icon, "SetTexture", updateProgressItemQuality)

            button.backdrop = nil
            local bg = button:CreateBackdrop()
            bg:SetBackdropColor(0, 0, 0, 0.25)
            bg:SetPoint("TOPLEFT", button.bg, "TOPRIGHT", 2, 0)
            bg:SetPoint("BOTTOMRIGHT", button.bg, 100, 0)
        end
    end

    _G.QuestDetailScrollFrame:SetWidth(302)

    -- Money text color
    hooksecurefunc(_G.QuestProgressRequiredMoneyText, "SetTextColor", function(self, r)
        if r == 0 then
            self:SetTextColor(0.8, 0.8, 0.8)
        elseif r == 0.2 then
            self:SetTextColor(1, 1, 1)
        end
    end)

    -- Buttons
    S:ReskinButton(_G.QuestFrameAcceptButton)
    S:ReskinButton(_G.QuestFrameDeclineButton)
    S:ReskinButton(_G.QuestFrameCompleteQuestButton)
    S:ReskinButton(_G.QuestFrameCompleteButton)
    S:ReskinButton(_G.QuestFrameGoodbyeButton)
    S:ReskinButton(_G.QuestFrameGreetingGoodbyeButton)

    -- Scroll bars
    S:ReskinTrimScrollBar(_G.QuestProgressScrollFrame.ScrollBar)
    S:ReskinTrimScrollBar(_G.QuestRewardScrollFrame.ScrollBar)
    S:ReskinTrimScrollBar(_G.QuestDetailScrollFrame.ScrollBar)
    S:ReskinTrimScrollBar(_G.QuestGreetingScrollFrame.ScrollBar)
    S:ReskinTrimScrollBar(_G.QuestLogPopupDetailFrameScrollFrame.ScrollBar)

    -- Text colors
    _G.QuestProgressRequiredItemsText:SetTextColor(1, 0.8, 0)
    _G.QuestProgressRequiredItemsText:SetShadowColor(0, 0, 0)
    _G.QuestProgressRequiredItemsText.SetTextColor = E.Dummy
    _G.QuestProgressTitleText:SetTextColor(1, 0.8, 0)
    _G.QuestProgressTitleText:SetShadowColor(0, 0, 0)
    _G.QuestProgressTitleText.SetTextColor = E.Dummy
    _G.QuestProgressText:SetTextColor(1, 1, 1)
    _G.QuestProgressText.SetTextColor = E.Dummy
    _G.GreetingText:SetTextColor(1, 1, 1)
    _G.GreetingText.SetTextColor = E.Dummy
    _G.AvailableQuestsText:SetTextColor(1, 0.8, 0)
    _G.AvailableQuestsText.SetTextColor = E.Dummy
    _G.AvailableQuestsText:SetShadowColor(0, 0, 0)
    _G.CurrentQuestsText:SetTextColor(1, 0.8, 0)
    _G.CurrentQuestsText.SetTextColor = E.Dummy
    _G.CurrentQuestsText:SetShadowColor(0, 0, 0)

    -- Quest NPC model
    _G.QuestModelScene:StripTextures()
    local bg = S:CreateBackground(_G.QuestModelScene)
    _G.QuestModelScene.ModelTextFrame:StripTextures()
    bg:SetPoint("BOTTOMRIGHT", _G.QuestModelScene.ModelTextFrame, "BOTTOMRIGHT")

    _G.QuestNPCModelText:SetTextColor(1, 1, 1)

    if _G.QuestNPCModelTextScrollFrame then
        S:ReskinTrimScrollBar(_G.QuestNPCModelTextScrollFrame.ScrollBar)
    end

    hooksecurefunc("QuestFrame_ShowQuestPortrait", function(parentFrame, _, _, _, _, _, x, y)
        x = (x or 0) + 6
        _G.QuestModelScene:ClearAllPoints()
        _G.QuestModelScene:SetPoint("TOPLEFT", parentFrame, "TOPRIGHT", x, y or 0)
    end)

    -- Friendship status bar (same pattern as Gossip.lua)
    if _G.QuestFrame.FriendshipStatusBar then
        for i = 1, 4 do
            local notch = _G.QuestFrame.FriendshipStatusBar["Notch" .. i]
            if notch then
                notch:SetColorTexture(0, 0, 0)
                notch:SetSize(E.mult, 16)
            end
        end
        _G.QuestFrame.FriendshipStatusBar.BarBorder:Hide()
    end

    -- QuestLogPopupDetailFrame
    local QuestLogPopupDetailFrame = _G.QuestLogPopupDetailFrame
    S:ReskinPortraitFrame(QuestLogPopupDetailFrame)
    S:ReskinButton(_G.QuestLogPopupDetailFrameAbandonButton)
    S:ReskinButton(_G.QuestLogPopupDetailFrameShareButton)
    S:ReskinButton(_G.QuestLogPopupDetailFrameTrackButton)

    local showMapButton = QuestLogPopupDetailFrame.ShowMapButton
    showMapButton:StripTextures()
    S:ReskinButton(showMapButton)
    showMapButton.Text:ClearAllPoints()
    showMapButton.Text:SetPoint("CENTER")
    showMapButton:SetSize(showMapButton:GetWidth() - 30, showMapButton:GetHeight() - 40)
end

S:AddCallback("QuestFrame")
