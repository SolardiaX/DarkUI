local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB

------------------------------------------------------------------------
-- Friends Frame
-- Ported from AuroraClassic FrameXML/FriendsFrame.lua (2026-06)
-- Dropped: Aurora noise overlay (B.CreateTex)
-- Note: B.ResetTabAnchor has no S: equivalent — tab anchor reset omitted
------------------------------------------------------------------------

local _G = _G
local select, pairs = select, pairs
local hooksecurefunc = hooksecurefunc

local atlasToTex = {
    ["friendslist-invitebutton-horde-normal"] = "Interface\\FriendsFrame\\PlusManz-Horde",
    ["friendslist-invitebutton-alliance-normal"] = "Interface\\FriendsFrame\\PlusManz-Alliance",
    ["friendslist-invitebutton-default-normal"] = "Interface\\FriendsFrame\\PlusManz-PlusManz",
}
local function replaceInviteTex(self, atlas)
    local tex = atlasToTex[atlas]
    if tex then self.ownerIcon:SetTexture(tex) end
end

local function reskinFriendButton(button)
    if not button.__styled then
        local gameIcon = button.gameIcon
        gameIcon:SetSize(22, 22)
        button.background:Hide()
        button:SetHighlightTexture(DB.bdTex)
        button:GetHighlightTexture():SetVertexColor(0.24, 0.56, 1, 0.2)

        local travelPass = button.travelPassButton
        travelPass:SetSize(22, 22)
        travelPass:SetPoint("TOPRIGHT", -3, -6)
        travelPass:CreateBackdrop()
        travelPass.NormalTexture:SetAlpha(0)
        travelPass.PushedTexture:SetAlpha(0)
        travelPass.DisabledTexture:SetAlpha(0)
        travelPass.HighlightTexture:SetColorTexture(1, 1, 1, 0.25)
        travelPass.HighlightTexture:SetAllPoints()
        gameIcon:SetPoint("TOPRIGHT", travelPass, "TOPLEFT", -4, 0)

        local icon = travelPass:CreateTexture(nil, "ARTWORK")
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:SetAllPoints()
        button.newIcon = icon
        travelPass.NormalTexture.ownerIcon = icon
        hooksecurefunc(travelPass.NormalTexture, "SetAtlas", replaceInviteTex)

        button.__styled = true
    end
end

function S:Friends()
    if not (C.skins.enable and C.skins.friends) then return end

    for i = 1, 4 do
        local tab = _G["FriendsFrameTab" .. i]
        if tab then
            S:ReskinTab(tab)
            -- (tab text re-centering is handled globally by E:ReskinTab's
            --  PanelTemplates_SelectTab/DeselectTab hook, so no ResetTabAnchor needed)
            if i ~= 1 then
                tab:ClearAllPoints()
                tab:SetPoint("TOPLEFT", _G["FriendsFrameTab" .. (i - 1)], "TOPRIGHT", -5, 0)
            end
        end
    end
    _G.FriendsFrameIcon:Hide()

    local ignoreWin = _G.FriendsFrame.IgnoreListWindow
    ignoreWin:StripTextures()
    S:SetBD(ignoreWin)
    local closeButton = ignoreWin.CloseButton or select(4, ignoreWin:GetChildren())
    if closeButton then S:ReskinClose(closeButton) end
    S:ReskinTrimScroll(ignoreWin.ScrollBar)
    S:Reskin(ignoreWin.UnignorePlayerButton)

    local INVITE_RESTRICTION_NONE = 9
    hooksecurefunc("FriendsFrame_UpdateFriendButton", function(button)
        if button.gameIcon then reskinFriendButton(button) end

        if button.newIcon and button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
            if FriendsFrame_GetInviteRestriction(button.id) == INVITE_RESTRICTION_NONE then
                button.newIcon:SetVertexColor(1, 1, 1)
            else
                button.newIcon:SetVertexColor(0.5, 0.5, 0.5)
            end
        end
    end)

    hooksecurefunc("FriendsFrame_UpdateFriendInviteButton", function(button)
        if not button.__styled then
            S:Reskin(button.AcceptButton)
            S:Reskin(button.DeclineButton)

            button.__styled = true
        end
    end)

    hooksecurefunc("FriendsFrame_UpdateFriendInviteHeaderButton", function(button)
        if not button.__styled then
            button:DisableDrawLayer("BACKGROUND")
            local bg = button:CreateBackdrop()
            bg:SetInside(button, 2, 2)
            local hl = button:GetHighlightTexture()
            hl:SetColorTexture(0.24, 0.56, 1, 0.2)
            hl:SetInside(bg)

            button.__styled = true
        end
    end)

    -- FriendsFrameBattlenetFrame
    _G.FriendsFrameBattlenetFrame:GetRegions():Hide()
    local bnetBg = _G.FriendsFrameBattlenetFrame:CreateBackdrop()
    bnetBg:SetPoint("TOPLEFT", 0, -2)
    bnetBg:SetPoint("BOTTOMRIGHT", -2, 2)
    bnetBg:SetBackdropColor(0, 0.6, 1, 0.25)

    local menuButton = _G.FriendsFrameBattlenetFrame.ContactsMenuButton
    if menuButton then
        S:ReskinArrow(menuButton, "down")
        menuButton.Icon:Hide()
        menuButton:SetSize(22, 22)
    end

    local broadcastFrame = _G.FriendsFrameBattlenetFrame.BroadcastFrame
    broadcastFrame:StripTextures()
    S:SetBD(broadcastFrame, nil, 10, -10, -10, 10)
    broadcastFrame.EditBox:DisableDrawLayer("BACKGROUND")
    _G.FriendsFrameBattlenetFrame.BroadcastFrame.EditBox.backdrop = nil
    local broadcastEditBg = broadcastFrame.EditBox:CreateBackdrop()
    broadcastEditBg:SetPoint("TOPLEFT", -2, -2)
    broadcastEditBg:SetPoint("BOTTOMRIGHT", 2, 2)
    S:Reskin(broadcastFrame.UpdateButton)
    S:Reskin(broadcastFrame.CancelButton)
    broadcastFrame:ClearAllPoints()
    broadcastFrame:SetPoint("TOPLEFT", _G.FriendsFrame, "TOPRIGHT", 3, 0)

    local unavailableFrame = _G.FriendsFrameBattlenetFrame.UnavailableInfoFrame
    unavailableFrame:StripTextures()
    S:SetBD(unavailableFrame)
    unavailableFrame:SetPoint("TOPLEFT", _G.FriendsFrame, "TOPRIGHT", 3, -18)

    S:ReskinPortraitFrame(_G.FriendsFrame)
    S:Reskin(_G.FriendsFrameAddFriendButton)
    S:Reskin(_G.FriendsFrameSendMessageButton)
    S:ReskinTrimScroll(_G.FriendsListFrame.ScrollBar)
    S:ReskinTrimScroll(_G.WhoFrame.ScrollBar)
    S:ReskinTrimScroll(_G.FriendsFriendsFrame.ScrollBar)
    S:ReskinDropDown(_G.FriendsFrameStatusDropdown)
    S:ReskinDropDown(_G.WhoFrameDropdown)
    S:ReskinDropDown(_G.FriendsFriendsFrameDropdown)
    _G.FriendsFrameStatusDropdown:SetWidth(58)
    S:Reskin(_G.FriendsListFrameContinueButton)
    S:ReskinInput(_G.AddFriendNameEditBox)
    _G.AddFriendFrame:StripTextures()
    S:SetBD(_G.AddFriendFrame)
    _G.FriendsFriendsFrame:StripTextures()
    S:SetBD(_G.FriendsFriendsFrame)
    S:Reskin(_G.FriendsFriendsFrame.SendRequestButton)
    S:Reskin(_G.FriendsFriendsFrame.CloseButton)
    S:Reskin(_G.WhoFrameWhoButton)
    S:Reskin(_G.WhoFrameAddFriendButton)
    S:Reskin(_G.WhoFrameGroupInviteButton)
    S:Reskin(_G.AddFriendEntryFrameAcceptButton)
    S:Reskin(_G.AddFriendEntryFrameCancelButton)

    for i = 1, 4 do
        _G["WhoFrameColumnHeader" .. i]:StripTextures()
    end

    _G.WhoFrameListInset:StripTextures()
    _G.WhoFrameEditBox.Backdrop:Hide()
    local whoBg = _G.WhoFrameEditBox:CreateBackdrop()
    whoBg:SetPoint("TOPLEFT", _G.WhoFrameEditBox, -3, -2)
    whoBg:SetPoint("BOTTOMRIGHT", _G.WhoFrameEditBox, -1, 2)

    for i = 1, 3 do
        local tab = select(i, _G.FriendsTabHeader.TabSystem:GetChildren())
        if tab then S:ReskinTab(tab) end
    end

    -- Recruit a Friend frame
    _G.RecruitAFriendFrame.SplashFrame.Description:SetTextColor(1, 1, 1)
    S:Reskin(_G.RecruitAFriendFrame.SplashFrame.OKButton)
    _G.RecruitAFriendFrame.RewardClaiming:StripTextures()
    S:Reskin(_G.RecruitAFriendFrame.RewardClaiming.ClaimOrViewRewardButton)
    S:Reskin(_G.RecruitAFriendFrame.RecruitmentButton)

    local recruitList = _G.RecruitAFriendFrame.RecruitList
    recruitList.Header:StripTextures()
    recruitList.Header:CreateBackdrop()
    recruitList.ScrollFrameInset:Hide()
    S:ReskinTrimScroll(recruitList.ScrollBar)

    local recruitmentFrame = _G.RecruitAFriendRecruitmentFrame
    recruitmentFrame:StripTextures()
    S:ReskinClose(recruitmentFrame.CloseButton)
    S:SetBD(recruitmentFrame)
    recruitmentFrame.EditBox:StripTextures()
    recruitmentFrame.EditBox.backdrop = nil
    local recruitEditBg = recruitmentFrame.EditBox:CreateBackdrop()
    recruitEditBg:SetPoint("TOPLEFT", -3, -3)
    recruitEditBg:SetPoint("BOTTOMRIGHT", 0, 3)
    S:Reskin(recruitmentFrame.GenerateOrCopyLinkButton)

    local rewardsFrame = _G.RecruitAFriendRewardsFrame
    rewardsFrame:StripTextures()
    S:ReskinClose(rewardsFrame.CloseButton)
    S:SetBD(rewardsFrame)

    rewardsFrame:HookScript("OnShow", function(self)
        for i = 1, self:GetNumChildren() do
            local child = select(i, self:GetChildren())
            local button = child and child.Button
            if button and not button.__styled then
                S:ReskinIcon(button.Icon)
                button.IconBorder:Hide()
                button:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)

                button.__styled = true
            end
        end
    end)
end

S:AddCallback("Friends")
