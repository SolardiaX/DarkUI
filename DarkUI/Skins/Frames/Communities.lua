local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Communities Frame
-- Ported from AuroraClassic AddOns/Blizzard_Communities.lua (2026-06)
-- Dropped: Aurora noise overlay (B.CreateTex)
-- Note: B:NotSecretValue has no S: equivalent — secretvalue guard replaced
--       with a plain truthiness check (safe: IsShown returns non-secret bool)
------------------------------------------------------------------------

local _G = _G
local select, pairs, next = select, pairs, next
local hooksecurefunc = hooksecurefunc

local function reskinCommunityTab(tab)
    tab:GetRegions():Hide()
    S:ReskinIcon(tab.Icon)
    tab:SetCheckedTexture(DB.pushedTex)
    local hl = tab:GetHighlightTexture()
    hl:SetColorTexture(1, 1, 1, 0.25)
    hl:SetAllPoints(tab.Icon)
end

local cardGroup = { "First", "Second", "Third" }
local function reskinGuildCards(cards)
    for _, name in pairs(cardGroup) do
        local guildCard = cards[name .. "Card"]
        guildCard:StripTextures()
        guildCard:CreateBackdrop()
        S:Reskin(guildCard.RequestJoin)
    end
    S:ReskinArrow(cards.PreviousPage, "left")
    S:ReskinArrow(cards.NextPage, "right")
end

local function reskinCommunityCard(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        if not child.__styled then
            child.CircleMask:Hide()
            child.LogoBorder:Hide()
            child.Background:Hide()
            S:ReskinIcon(child.CommunityLogo)
            S:Reskin(child)

            child.__styled = true
        end
    end
end

local function reskinRequestCheckbox(self)
    for button in self.SpecsPool:EnumerateActive() do
        if button.Checkbox then
            S:ReskinCheck(button.Checkbox)
            button.Checkbox:SetSize(26, 26)
        end
    end
end

local function updateNameFrame(self)
    if not self.expanded then return end
    if not self.bg then self.bg = self.Class:CreateBackdrop() end
    local memberInfo = self:GetMemberInfo()
    if memberInfo and memberInfo.classID then
        local classInfo = C_CreatureInfo.GetClassInfo(memberInfo.classID)
        if classInfo then S:ClassIconTexCoord(self.Class, classInfo.classFile) end
    end
end

local function replacedRoleTex(icon, x1, x2, y1, y2)
    if x1 == 0 and x2 == 19 / 64 and y1 == 22 / 64 and y2 == 41 / 64 then
        S:ReskinSmallRole(icon, "TANK")
    elseif x1 == 20 / 64 and x2 == 39 / 64 and y1 == 1 / 64 and y2 == 20 / 64 then
        S:ReskinSmallRole(icon, "HEALER")
    elseif x1 == 20 / 64 and x2 == 39 / 64 and y1 == 22 / 64 and y2 == 41 / 64 then
        S:ReskinSmallRole(icon, "DAMAGER")
    end
end

local function UpdateRoleTexture(icon)
    if not icon then return end
    replacedRoleTex(icon, icon:GetTexCoord())
    hooksecurefunc(icon, "SetTexCoord", replacedRoleTex)
end

local function reskinCommunitiesListButton(button)
    button.Background:Hide()
    button.CircleMask:Hide()
    button.IconRing:Hide()
    if button.IconBorder then button.IconBorder:Hide() end

    -- NOTE: do NOT skin the Icon via S:ReskinIcon here. S:ReskinIcon -> E:StyleIcon
    -- creates its backdrop on the icon's PARENT (= this button) at button.backdrop,
    -- which then dedups against the row backdrop below into a single frame.
    if not button.backdrop then
        button:CreateBackdrop()
        button.backdrop:SetBackdropEdge("round_white")

        button.backdrop:ClearAllPoints()
        button.backdrop:SetPoint("TOPLEFT", 4, -8)
        button.backdrop:SetPoint("BOTTOMRIGHT", -8, 8)
    end

    button.Icon:ClearAllPoints()
    button.Icon:SetPoint("TOPLEFT", 15, -18)

    local hl = button:GetHighlightTexture()
    hl:SetTexture(DB.bdTex)
    hl:SetVertexColor(1, 1, 1, 0.3)
    hl:SetInside(button.backdrop, 2, 2)

    button.Selection:SetAtlas(nil)
    button.Selection:SetTexture(DB.bdTex)
    button.Selection:SetInside(button.backdrop, 2, 2)

    -- green (guild) vs battlenet (community) selection tint, refreshed per call
    local color = (button.Background:GetAtlas() == "communities-nav-button-green-normal" and GREEN_FONT_COLOR) or BATTLENET_FONT_COLOR
    button.Selection:SetVertexColor(color.r, color.g, color.b, 0.2)
end

local function updateMemberName(self, info)
    if not info then return end

    local class = self.Class
    if not class.bg then class.bg = class:CreateBackdrop() end

    local classTag = select(2, GetClassInfo(info.classID))
    if classTag then S:ClassIconTexCoord(class, classTag) end
end

function S:Communities()
    if not (C.skins.enable and C.skins.communities) then return end

    local CommunitiesFrame = _G.CommunitiesFrame

    S:ReskinPortraitFrame(CommunitiesFrame)
    CommunitiesFrame.NineSlice:Hide()
    CommunitiesFrame.PortraitOverlay:SetAlpha(0)
    S:ReskinDropDown(CommunitiesFrame.StreamDropdown)
    S:ReskinDropDown(CommunitiesFrame.CommunitiesListDropdown)
    S:ReskinMinMax(CommunitiesFrame.MaximizeMinimizeFrame)
    CommunitiesFrame.AddToChatButton:StripTextures()
    S:ReskinArrow(CommunitiesFrame.AddToChatButton, "down")

    local calendarButton = CommunitiesFrame.CommunitiesCalendarButton
    calendarButton:SetSize(24, 24)
    calendarButton:SetNormalTexture(1103070)
    calendarButton:SetPushedTexture(1103070)
    calendarButton:GetPushedTexture():SetTexCoord(unpack(DB.TexCoord))
    calendarButton:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    S:ReskinIcon(calendarButton:GetNormalTexture())

    for _, name in next, { "GuildFinderFrame", "InvitationFrame", "TicketFrame", "CommunityFinderFrame", "ClubFinderInvitationFrame" } do
        local frame = CommunitiesFrame[name]
        if frame then
            frame:StripTextures()
            frame.InsetFrame:Hide()
            if frame.CircleMask then
                frame.CircleMask:Hide()
                frame.IconRing:Hide()
                S:ReskinIcon(frame.Icon)
            end
            if frame.FindAGuildButton then S:Reskin(frame.FindAGuildButton) end
            if frame.AcceptButton then S:Reskin(frame.AcceptButton) end
            if frame.DeclineButton then S:Reskin(frame.DeclineButton) end
            if frame.ApplyButton then S:Reskin(frame.ApplyButton) end

            local optionsList = frame.OptionsList
            if optionsList then
                S:ReskinDropDown(optionsList.ClubFilterDropdown)
                S:ReskinDropDown(optionsList.ClubSizeDropdown)
                S:ReskinDropDown(optionsList.SortByDropdown)
                S:ReskinRole(optionsList.TankRoleFrame, "TANK")
                S:ReskinRole(optionsList.HealerRoleFrame, "HEALER")
                S:ReskinRole(optionsList.DpsRoleFrame, "DPS")
                S:ReskinInput(optionsList.SearchBox)
                optionsList.SearchBox:SetSize(118, 22)
                S:Reskin(optionsList.Search)
                optionsList.Search:ClearAllPoints()
                optionsList.Search:SetPoint("TOPRIGHT", optionsList.SearchBox, "BOTTOMRIGHT", 0, -2)
            end

            local requestFrame = frame.RequestToJoinFrame
            if requestFrame then
                requestFrame:StripTextures()
                S:SetBD(requestFrame)
                requestFrame.MessageFrame:StripTextures()
                requestFrame.MessageFrame.MessageScroll:StripTextures()
                requestFrame.MessageFrame.MessageScroll:CreateBackdrop()
                S:Reskin(requestFrame.Apply)
                S:Reskin(requestFrame.Cancel)
                hooksecurefunc(requestFrame, "Initialize", reskinRequestCheckbox)
            end

            for _, tabName in next, { "ClubFinderSearchTab", "ClubFinderPendingTab" } do
                local tab = frame[tabName]
                if tab then
                    reskinCommunityTab(tab)

                    -- nudge right by 4px (shift the chain root; siblings follow)
                    local point, relativeTo, relativePoint, x, y = tab:GetPoint()
                    if point and relativeTo ~= frame.ClubFinderSearchTab and relativeTo ~= frame.ClubFinderPendingTab then
                        tab:SetPoint(point, relativeTo, relativePoint, (x or 0) + 4, y or 0)
                    end
                end
            end
            if frame.GuildCards then reskinGuildCards(frame.GuildCards) end
            if frame.PendingGuildCards then reskinGuildCards(frame.PendingGuildCards) end
            if frame.CommunityCards then
                S:ReskinTrimScroll(frame.CommunityCards.ScrollBar)
                hooksecurefunc(frame.CommunityCards.ScrollBox, "Update", reskinCommunityCard)
            end
            if frame.PendingCommunityCards then
                S:ReskinTrimScroll(frame.PendingCommunityCards.ScrollBar)
                hooksecurefunc(frame.PendingCommunityCards.ScrollBox, "Update", reskinCommunityCard)
            end
        end
    end

    _G.CommunitiesFrameCommunitiesList:StripTextures()
    _G.CommunitiesFrameCommunitiesList.InsetFrame:Hide()
    _G.CommunitiesFrameCommunitiesList.FilligreeOverlay:Hide()
    _G.CommunitiesFrameCommunitiesList.ScrollBar:GetChildren():Hide()
    S:ReskinTrimScroll(_G.CommunitiesFrameCommunitiesList.ScrollBar)

    hooksecurefunc(_G.CommunitiesFrameCommunitiesList.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            reskinCommunitiesListButton(select(i, self.ScrollTarget:GetChildren()))
        end
    end)

    -- the Add / Find / Guild-finder entries reconfigure their art on Set*Community,
    -- so re-skin on those too (not just the scroll Update)
    hooksecurefunc(_G.CommunitiesListEntryMixin, "SetAddCommunity", reskinCommunitiesListButton)
    hooksecurefunc(_G.CommunitiesListEntryMixin, "SetFindCommunity", reskinCommunitiesListButton)
    hooksecurefunc(_G.CommunitiesListEntryMixin, "SetGuildFinder", reskinCommunitiesListButton)

    local tabNames = { "ChatTab", "RosterTab", "GuildBenefitsTab", "GuildInfoTab" }
    local isTab = {}
    for _, name in next, tabNames do
        isTab[CommunitiesFrame[name]] = true
    end
    for _, name in next, tabNames do
        local tab = CommunitiesFrame[name]
        if tab then
            reskinCommunityTab(tab)

            -- nudge the group right by 6px: shift only tabs anchored to a non-sibling
            -- (the chain root); tabs anchored to another tab follow automatically
            local point, relativeTo, relativePoint, x, y = tab:GetPoint()
            if point and not isTab[relativeTo] then tab:SetPoint(point, relativeTo, relativePoint, (x or 0) + 4, y or 0) end
        end
    end

    -- ChatTab
    S:Reskin(CommunitiesFrame.InviteButton)
    CommunitiesFrame.Chat:StripTextures()
    S:ReskinTrimScroll(CommunitiesFrame.Chat.ScrollBar)
    CommunitiesFrame.ChatEditBox:DisableDrawLayer("BACKGROUND")
    -- dedup: Chat.InsetFrame backdrop separate from ChatEditBox backdrop
    local bg1 = CommunitiesFrame.Chat.InsetFrame:CreateBackdrop()
    bg1:SetPoint("TOPLEFT", 1, -3)
    bg1:SetPoint("BOTTOMRIGHT", -3, 22)
    CommunitiesFrame.Chat.InsetFrame.backdrop = nil
    CommunitiesFrame.ChatEditBox.backdrop = nil
    local bg2 = CommunitiesFrame.ChatEditBox:CreateBackdrop()
    bg2:SetPoint("TOPLEFT", -5, -5)
    bg2:SetPoint("BOTTOMRIGHT", 4, 5)

    do
        local dialog = CommunitiesFrame.NotificationSettingsDialog
        dialog:StripTextures()
        S:SetBD(dialog)
        S:ReskinDropDown(dialog.CommunitiesListDropdown)
        if dialog.Selector then
            dialog.Selector:StripTextures()
            S:Reskin(dialog.Selector.OkayButton)
            S:Reskin(dialog.Selector.CancelButton)
        end
        S:ReskinCheck(dialog.ScrollFrame.Child.QuickJoinButton)
        dialog.ScrollFrame.Child.QuickJoinButton:SetSize(25, 25)
        S:Reskin(dialog.ScrollFrame.Child.AllButton)
        S:Reskin(dialog.ScrollFrame.Child.NoneButton)
        S:ReskinTrimScroll(dialog.ScrollFrame.ScrollBar)

        hooksecurefunc(dialog, "Refresh", function(self)
            local frame = self.ScrollFrame.Child
            for i = 1, frame:GetNumChildren() do
                local child = select(i, frame:GetChildren())
                if child.StreamName and not child.__styled then
                    S:ReskinRadio(child.ShowNotificationsButton)
                    S:ReskinRadio(child.HideNotificationsButton)

                    child.__styled = true
                end
            end
        end)
    end

    do
        local dialog = CommunitiesFrame.EditStreamDialog
        dialog:StripTextures()
        S:SetBD(dialog)
        dialog.NameEdit:DisableDrawLayer("BACKGROUND")
        local bg = dialog.NameEdit:CreateBackdrop()
        bg:SetPoint("TOPLEFT", -3, -3)
        bg:SetPoint("BOTTOMRIGHT", -4, 3)
        dialog.Description:StripTextures()
        dialog.Description:CreateBackdrop()
        S:ReskinCheck(dialog.TypeCheckbox)
        S:Reskin(dialog.Accept)
        S:Reskin(dialog.Delete)
        S:Reskin(dialog.Cancel)
    end

    do
        local dialog = _G.CommunitiesTicketManagerDialog
        dialog:StripTextures()
        S:SetBD(dialog)
        dialog.Background:Hide()
        S:Reskin(dialog.LinkToChat)
        S:Reskin(dialog.Copy)
        S:Reskin(dialog.Close)
        S:ReskinArrow(dialog.MaximizeButton, "down")
        S:ReskinDropDown(dialog.ExpiresDropdown)
        S:ReskinDropDown(dialog.UsesDropdown)
        S:Reskin(dialog.GenerateLinkButton)

        dialog.InviteManager.ArtOverlay:Hide()
        dialog.InviteManager.ColumnDisplay:StripTextures()
        dialog.InviteManager.ScrollBar:GetChildren():Hide()
        S:ReskinTrimScroll(dialog.InviteManager.ScrollBar)

        hooksecurefunc(dialog, "Update", function(self)
            local column = self.InviteManager.ColumnDisplay
            for i = 1, column:GetNumChildren() do
                local child = select(i, column:GetChildren())
                if not child.__styled then
                    child:StripTextures()
                    local bg = child:CreateBackdrop()
                    bg:SetPoint("TOPLEFT", 4, -2)
                    bg:SetPoint("BOTTOMRIGHT", 0, 2)

                    child.__styled = true
                end
            end
        end)

        hooksecurefunc(dialog.InviteManager.ScrollBox, "Update", function(self)
            for i = 1, self.ScrollTarget:GetNumChildren() do
                local button = select(i, self.ScrollTarget:GetChildren())
                if not button.__styled then
                    S:Reskin(button.CopyLinkButton)
                    button.CopyLinkButton.Background:Hide()
                    S:Reskin(button.RevokeButton)
                    button.RevokeButton:SetSize(18, 18)

                    button.__styled = true
                end
            end
        end)
    end

    -- Roster
    CommunitiesFrame.MemberList.InsetFrame:Hide()
    CommunitiesFrame.MemberList.ColumnDisplay:StripTextures()
    S:ReskinDropDown(CommunitiesFrame.GuildMemberListDropdown)
    CommunitiesFrame.MemberList.ScrollBar:GetChildren():Hide()
    S:ReskinTrimScroll(CommunitiesFrame.MemberList.ScrollBar)

    hooksecurefunc(CommunitiesFrame.MemberList.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                hooksecurefunc(child, "RefreshExpandedColumns", updateNameFrame)
                child.__styled = true
            end

            local header = child.ProfessionHeader
            if header and not header.__styled then
                for i = 1, 3 do
                    select(i, header:GetRegions()):Hide()
                end
                header.bg = header:CreateBackdrop()
                header.bg:SetInside()
                header:SetHighlightTexture(DB.bdTex)
                header:GetHighlightTexture():SetVertexColor(cr, cg, cb, 0.25)
                header:GetHighlightTexture():SetInside(header.bg)
                header.Icon:CreateBackdrop()
                header.__styled = true
            end

            if child and child.bg then child.bg:SetShown(child.Class:IsShown()) end
        end
    end)

    S:ReskinCheck(CommunitiesFrame.MemberList.ShowOfflineButton)
    CommunitiesFrame.MemberList.ShowOfflineButton:SetSize(25, 25)
    S:Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildControlButton)
    S:Reskin(CommunitiesFrame.CommunitiesControlFrame.GuildRecruitmentButton)
    S:Reskin(CommunitiesFrame.CommunitiesControlFrame.CommunitiesSettingsButton)
    S:ReskinDropDown(CommunitiesFrame.CommunityMemberListDropdown)

    local detailFrame = CommunitiesFrame.GuildMemberDetailFrame
    detailFrame:StripTextures()
    S:SetBD(detailFrame)
    S:ReskinClose(detailFrame.CloseButton)
    S:Reskin(detailFrame.RemoveButton)
    S:Reskin(detailFrame.GroupInviteButton)
    S:ReskinDropDown(detailFrame.RankDropdown)
    detailFrame.NoteBackground:StripTextures()
    detailFrame.NoteBackground:CreateBackdrop()
    detailFrame.OfficerNoteBackground:StripTextures()
    detailFrame.OfficerNoteBackground:CreateBackdrop()
    detailFrame:ClearAllPoints()
    detailFrame:SetPoint("TOPLEFT", CommunitiesFrame, "TOPRIGHT", 34, 0)

    do
        local dialog = _G.CommunitiesSettingsDialog
        dialog.BG:Hide()
        S:SetBD(dialog)
        S:Reskin(dialog.ChangeAvatarButton)
        S:Reskin(dialog.Accept)
        S:Reskin(dialog.Delete)
        S:Reskin(dialog.Cancel)
        S:ReskinInput(dialog.NameEdit)
        S:ReskinInput(dialog.ShortNameEdit)
        dialog.Description:StripTextures()
        dialog.Description:CreateBackdrop()
        dialog.MessageOfTheDay:StripTextures()
        dialog.MessageOfTheDay:CreateBackdrop()
        S:ReskinCheck(dialog.ShouldListClub.Button)
        S:ReskinCheck(dialog.AutoAcceptApplications.Button)
        S:ReskinCheck(dialog.MaxLevelOnly.Button)
        S:ReskinCheck(dialog.MinIlvlOnly.Button)
        S:ReskinInput(dialog.MinIlvlOnly.EditBox)
        S:ReskinDropDown(dialog.ClubFocusDropdown)
        S:ReskinDropDown(dialog.LookingForDropdown)
        S:ReskinDropDown(dialog.LanguageDropdown)
    end

    do
        local dialog = _G.CommunitiesAvatarPickerDialog
        dialog:StripTextures()
        S:SetBD(dialog)
        S:ReskinTrimScroll(_G.CommunitiesAvatarPickerDialog.ScrollBar)
        if dialog.Selector then
            dialog.Selector:StripTextures()
            S:Reskin(dialog.Selector.OkayButton)
            S:Reskin(dialog.Selector.CancelButton)
        end
    end

    hooksecurefunc(CommunitiesFrame.MemberList, "RefreshListDisplay", function(self)
        for i = 1, self.ColumnDisplay:GetNumChildren() do
            local child = select(i, self.ColumnDisplay:GetChildren())
            if not child.__styled then
                child:StripTextures()
                child:CreateBackdrop()

                child.__styled = true
            end
        end
    end)

    -- Benefits
    CommunitiesFrame.GuildBenefitsFrame.Perks:GetRegions():SetAlpha(0)
    CommunitiesFrame.GuildBenefitsFrame.Rewards.Bg:SetAlpha(0)
    CommunitiesFrame.GuildBenefitsFrame:StripTextures()
    S:ReskinTrimScroll(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBar)

    local function handleRewardButton(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local child = select(i, self.ScrollTarget:GetChildren())
            if not child.__styled then
                local iconbg = S:ReskinIcon(child.Icon)
                child:StripTextures()
                child.backdrop = nil
                child.bg = child:CreateBackdrop()
                child.bg:ClearAllPoints()
                child.bg:SetPoint("TOPLEFT", iconbg)
                child.bg:SetPoint("BOTTOMLEFT", iconbg)
                child.bg:SetWidth(child:GetWidth() - 5)

                child.__styled = true
            end
        end
    end
    hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Perks.ScrollBox, "Update", handleRewardButton)
    hooksecurefunc(CommunitiesFrame.GuildBenefitsFrame.Rewards.ScrollBox, "Update", handleRewardButton)

    local factionFrameBar = CommunitiesFrame.GuildBenefitsFrame.FactionFrame.Bar
    factionFrameBar:StripTextures()
    local factionBg = factionFrameBar:CreateBackdrop()
    factionFrameBar.Progress:SetTexture(DB.bdTex)
    factionBg:SetOutside(factionFrameBar.Progress)

    -- Guild Info
    S:Reskin(CommunitiesFrame.GuildLogButton)
    _G.CommunitiesFrameGuildDetailsFrameInfo:StripTextures()
    _G.CommunitiesFrameGuildDetailsFrameNews:StripTextures()
    S:ReskinTrimScroll(_G.CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame.ScrollBar)
    local motdBg = _G.CommunitiesFrameGuildDetailsFrameInfoMOTDScrollFrame:CreateBackdrop()
    motdBg:SetPoint("TOPLEFT", 0, 3)
    motdBg:SetPoint("BOTTOMRIGHT", -5, -4)

    _G.CommunitiesGuildTextEditFrame:StripTextures()
    S:SetBD(_G.CommunitiesGuildTextEditFrame)
    _G.CommunitiesGuildTextEditFrameBg:Hide()
    _G.CommunitiesGuildTextEditFrame.Container:StripTextures()
    _G.CommunitiesGuildTextEditFrame.Container:CreateBackdrop()
    S:ReskinTrimScroll(_G.CommunitiesGuildTextEditFrame.Container.ScrollFrame.ScrollBar)
    S:ReskinClose(_G.CommunitiesGuildTextEditFrameCloseButton)
    S:Reskin(_G.CommunitiesGuildTextEditFrameAcceptButton)
    local guildTextClose = select(4, _G.CommunitiesGuildTextEditFrame:GetChildren())
    S:Reskin(guildTextClose)

    S:ReskinTrimScroll(_G.CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame.ScrollBar)
    _G.CommunitiesFrameGuildDetailsFrameInfo.DetailsFrame:CreateBackdrop()
    _G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar:GetChildren():Hide()
    S:ReskinTrimScroll(_G.CommunitiesFrameGuildDetailsFrameNews.ScrollBar)
    _G.CommunitiesFrameGuildDetailsFrame:StripTextures()

    hooksecurefunc("GuildNewsButton_SetNews", function(button)
        if button.header:IsShown() then button.header:SetAlpha(0) end
    end)

    _G.CommunitiesGuildNewsFiltersFrame:StripTextures()
    _G.CommunitiesGuildNewsFiltersFrameBg:Hide()
    S:SetBD(_G.CommunitiesGuildNewsFiltersFrame)
    S:ReskinClose(_G.CommunitiesGuildNewsFiltersFrame.CloseButton)
    for _, name in
        next,
        { "GuildAchievement", "Achievement", "DungeonEncounter", "EpicItemLooted", "EpicItemPurchased", "EpicItemCrafted", "LegendaryItemLooted" }
    do
        local filter = _G.CommunitiesGuildNewsFiltersFrame[name]
        S:ReskinCheck(filter)
    end

    _G.CommunitiesGuildLogFrame:StripTextures()
    _G.CommunitiesGuildLogFrameBg:Hide()
    S:SetBD(_G.CommunitiesGuildLogFrame)
    S:ReskinClose(_G.CommunitiesGuildLogFrameCloseButton)
    S:ReskinTrimScroll(_G.CommunitiesGuildLogFrame.Container.ScrollFrame.ScrollBar)
    _G.CommunitiesGuildLogFrame.Container:StripTextures()
    _G.CommunitiesGuildLogFrame.Container:CreateBackdrop()
    local guildLogClose = select(3, _G.CommunitiesGuildLogFrame:GetChildren())
    S:Reskin(guildLogClose)

    local bossModel = _G.CommunitiesFrameGuildDetailsFrameNews.BossModel
    bossModel:StripTextures()
    bossModel:ClearAllPoints()
    bossModel:SetPoint("LEFT", CommunitiesFrame, "RIGHT", 40, 0)
    local textFrame = bossModel.TextFrame
    textFrame:StripTextures()
    local bossBg = S:SetBD(bossModel)
    if bossBg then bossBg:SetOutside(bossModel, nil, nil, textFrame) end

    -- Recruitment dialog
    do
        local dialog = CommunitiesFrame.RecruitmentDialog
        dialog:StripTextures()
        S:SetBD(dialog)
        S:ReskinCheck(dialog.ShouldListClub.Button)
        S:ReskinCheck(dialog.MaxLevelOnly.Button)
        S:ReskinCheck(dialog.MinIlvlOnly.Button)
        S:ReskinDropDown(dialog.ClubFocusDropdown)
        S:ReskinDropDown(dialog.LookingForDropdown)
        S:ReskinDropDown(dialog.LanguageDropdown)
        dialog.RecruitmentMessageFrame:StripTextures()
        dialog.RecruitmentMessageFrame.RecruitmentMessageInput:StripTextures()
        S:ReskinTrimScroll(dialog.RecruitmentMessageFrame.RecruitmentMessageInput.ScrollBar)
        S:ReskinInput(dialog.RecruitmentMessageFrame)
        S:ReskinInput(dialog.MinIlvlOnly.EditBox)
        S:Reskin(dialog.Accept)
        S:Reskin(dialog.Cancel)
    end

    -- ApplicantList
    local applicantList = CommunitiesFrame.ApplicantList
    applicantList:StripTextures()
    applicantList.ColumnDisplay:StripTextures()

    local listBG = applicantList:CreateBackdrop()
    listBG:SetPoint("TOPLEFT", 0, 0)
    listBG:SetPoint("BOTTOMRIGHT", -15, 0)

    local function reskinApplicant(button)
        if button.__styled then return end

        button:SetPoint("LEFT", listBG, E.mult, 0)
        button:SetPoint("RIGHT", listBG, -E.mult, 0)
        button:SetHighlightTexture(DB.bdTex)
        local hl = button:GetHighlightTexture()
        hl:SetVertexColor(cr, cg, cb, 0.25)
        hl:SetInside(button)
        button.InviteButton:SetSize(66, 18)
        button.CancelInvitationButton:SetSize(20, 18)

        S:Reskin(button.InviteButton)
        S:Reskin(button.CancelInvitationButton)
        hooksecurefunc(button, "UpdateMemberInfo", updateMemberName)

        UpdateRoleTexture(button.RoleIcon1)
        UpdateRoleTexture(button.RoleIcon2)
        UpdateRoleTexture(button.RoleIcon3)
        button.__styled = true
    end

    hooksecurefunc(applicantList, "BuildList", function(self)
        local columnDisplay = self.ColumnDisplay
        for i = 1, columnDisplay:GetNumChildren() do
            local child = select(i, columnDisplay:GetChildren())
            if not child.__styled then
                child:StripTextures()

                local bg = child:CreateBackdrop()
                bg:SetPoint("TOPLEFT", 4, -2)
                bg:SetPoint("BOTTOMRIGHT", 0, 2)

                child:SetHighlightTexture(DB.bdTex)
                local hl = child:GetHighlightTexture()
                hl:SetVertexColor(cr, cg, cb, 0.25)
                hl:SetInside(bg)

                child.__styled = true
            end
        end
    end)

    applicantList.ScrollBar:GetChildren():Hide()
    S:ReskinTrimScroll(applicantList.ScrollBar)

    hooksecurefunc(applicantList.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            reskinApplicant(button)
        end
    end)
end

S:AddCallbackForAddon("Blizzard_Communities", "Communities")
