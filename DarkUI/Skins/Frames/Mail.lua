local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Mail Frame
-- Ported from AuroraClassic FrameXML/MailFrame.lua (2026-06)
-- Dropped: Aurora noise-overlay CreateTex (DarkUI backdrop carries texture)
------------------------------------------------------------------------

local _G = _G
local hooksecurefunc = hooksecurefunc

function S:Mail()
    if not C.general.skins then return end

    local texL, texR, texT, texB = unpack(C.media.texCoord)

    SendMailMoneyInset:DisableDrawLayer("BORDER")
    InboxFrame:GetRegions():Hide()
    SendMailMoneyBg:Hide()
    SendMailMoneyInset:Hide()
    OpenMailHorizontalBarLeft:Hide()
    SendMailFrame:StripTextures()
    OpenStationeryBackgroundLeft:Hide()
    OpenStationeryBackgroundRight:Hide()
    SendStationeryBackgroundLeft:Hide()
    SendStationeryBackgroundRight:Hide()
    InboxPrevPageButton:GetRegions():Hide()
    InboxNextPageButton:GetRegions():Hide()

    S:ReskinPortraitFrame(MailFrame)
    S:ReskinPortraitFrame(OpenMailFrame)
    S:ReskinButton(SendMailMailButton)
    S:ReskinButton(SendMailCancelButton)
    S:ReskinButton(OpenMailReplyButton)
    S:ReskinButton(OpenMailDeleteButton)
    S:ReskinButton(OpenMailCancelButton)
    S:ReskinButton(OpenMailReportSpamButton)
    S:ReskinButton(OpenAllMail)
    S:ReskinInput(SendMailNameEditBox, 20, 85)
    S:ReskinInput(SendMailSubjectEditBox, nil, 200)
    S:ReskinInput(SendMailMoneyGold)
    S:ReskinInput(SendMailMoneySilver)
    S:ReskinInput(SendMailMoneyCopper)
    S:ReskinTrimScrollBar(SendMailScrollFrame.ScrollBar)
    S:ReskinTrimScrollBar(OpenMailScrollFrame.ScrollBar)
    S:ReskinRadio(SendMailSendMoneyButton)
    S:ReskinRadio(SendMailCODButton)
    S:ReskinArrow(InboxPrevPageButton, "left")
    S:ReskinArrow(InboxNextPageButton, "right")

    OpenMailScrollFrame:CreateBackdrop()
    local bg = SendMailScrollFrame:CreateBackdrop()
    bg:SetPoint("TOPLEFT", 6, 0)

    SendMailMailButton:SetPoint("RIGHT", SendMailCancelButton, "LEFT", -1, 0)
    OpenMailDeleteButton:SetPoint("RIGHT", OpenMailCancelButton, "LEFT", -1, 0)
    OpenMailReplyButton:SetPoint("RIGHT", OpenMailDeleteButton, "LEFT", -1, 0)

    SendMailMoneySilver:SetPoint("LEFT", SendMailMoneyGold, "RIGHT", 1, 0)
    SendMailMoneyCopper:SetPoint("LEFT", SendMailMoneySilver, "RIGHT", 1, 0)

    SendMailSubjectEditBox:SetPoint("TOPLEFT", SendMailNameEditBox, "BOTTOMLEFT", 0, -1)

    for i = 1, 2 do
        S:ReskinTab(_G["MailFrameTab" .. i])
    end
    MailFrameTab2:ClearAllPoints()
    MailFrameTab2:SetPoint("TOPLEFT", MailFrameTab1, "TOPRIGHT", -5, 0)

    for _, button in pairs({ OpenMailLetterButton, OpenMailMoneyButton }) do
        button:StripTextures()
        button.icon:SetTexCoord(texL, texR, texT, texB)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        button:CreateBackdrop()
    end

    for i = 1, INBOXITEMS_TO_DISPLAY do
        local item = _G["MailItem" .. i]
        local button = _G["MailItem" .. i .. "Button"]
        item:StripTextures()
        button:StripTextures()
        button:SetCheckedTexture(C.media.button.glow)
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        button.Icon:SetTexCoord(texL, texR, texT, texB)
        button.IconBorder:SetAlpha(0)
        button:CreateBackdrop()
    end

    for i = 1, ATTACHMENTS_MAX_SEND do
        local button = _G["SendMailAttachment" .. i]
        button:StripTextures()
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        button.bg = button:CreateBackdrop()
        S:ReskinIconBorder(button.IconBorder)
    end

    hooksecurefunc("SendMailFrame_Update", function()
        for i = 1, ATTACHMENTS_MAX_SEND do
            local button = SendMailFrame.SendMailAttachments[i]
            if HasSendMailItem(i) then button:GetNormalTexture():SetTexCoord(texL, texR, texT, texB) end
        end
    end)

    for i = 1, ATTACHMENTS_MAX_RECEIVE do
        local button = _G["OpenMailAttachmentButton" .. i]
        button:StripTextures()
        button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        button.icon:SetTexCoord(texL, texR, texT, texB)
        button.bg = button:CreateBackdrop()
        S:ReskinIconBorder(button.IconBorder)
    end

    MailFont_Large:SetTextColor(1, 1, 1)
    MailFont_Large:SetShadowColor(0, 0, 0, 0)
    MailTextFontNormal:SetTextColor(1, 1, 1)
    MailTextFontNormal:SetShadowColor(0, 0, 0, 0)
    InvoiceTextFontNormal:SetTextColor(1, 1, 1)
    InvoiceTextFontSmall:SetTextColor(1, 1, 1)
end

S:AddCallback("Mail")
