local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b

------------------------------------------------------------------------
-- LFG List (Activity Finder / Group Listing)
-- Ported from AuroraClassic FrameXML/LFGList.lua (2026-06)
-- Note: Aurora noise overlay dropped; DarkUI backdrop already carries texture.
-- Note: B.SetFontSize(obj, sz) → obj:FontTemplate(nil, sz)
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc

local function highlight_OnEnter(self) self.hl:Show() end

local function highlight_OnLeave(self) self.hl:Hide() end

local function handleRoleAnchor(self, role)
    self[role .. "Count"]:SetWidth(24)
    self[role .. "Count"]:FontTemplate(nil, 13)
    self[role .. "Count"]:SetPoint("RIGHT", self[role .. "Icon"], "LEFT", 1, 0)
end

function S:LFGList()
    if not C.general.skins then return end

    local LFGListFrame = _G.LFGListFrame
    LFGListFrame.NothingAvailable.Inset:Hide()

    -- [[ Category selection ]]

    local categorySelection = LFGListFrame.CategorySelection

    S:ReskinButton(categorySelection.FindGroupButton)
    S:ReskinButton(categorySelection.StartGroupButton)
    categorySelection.Inset:Hide()
    categorySelection.CategoryButtons[1]:SetNormalFontObject(GameFontNormal)

    hooksecurefunc("LFGListCategorySelection_AddButton", function(self, btnIndex)
        local bu = self.CategoryButtons[btnIndex]
        if bu and not bu.__styled then
            bu.Cover:Hide()
            bu.Icon:SetTexCoord(0.01, 0.99, 0.01, 0.99)
            bu.Icon:CreateBackdrop():SetBackdropEdge("round")

            bu.__styled = true
        end
    end)

    hooksecurefunc("LFGListSearchEntry_Update", function(self)
        local cancelButton = self.CancelButton
        if not cancelButton.__styled then
            S:ReskinButton(cancelButton)
            cancelButton.__styled = true
        end
    end)

    hooksecurefunc("LFGListSearchEntry_UpdateExpiration", function(self)
        local expirationTime = self.ExpirationTime
        if not expirationTime.fontStyled then
            expirationTime:SetWidth(42)
            expirationTime.fontStyled = true
        end
    end)

    -- [[ Search panel ]]

    local searchPanel = LFGListFrame.SearchPanel

    S:ReskinButton(searchPanel.RefreshButton)
    S:ReskinButton(searchPanel.BackButton)
    S:ReskinButton(searchPanel.BackToGroupButton)
    S:ReskinButton(searchPanel.SignUpButton)
    S:ReskinInput(searchPanel.SearchBox)
    searchPanel.SearchBox:SetHeight(22)
    S:ReskinFilterButton(searchPanel.FilterButton)
    S:ReskinFilterReset(searchPanel.FilterButton.ResetButton)

    searchPanel:HookScript("OnShow", function(self)
        self.FilterButton:SetSize(90, 21) -- needs review, fix blizzard weired size
    end)

    searchPanel.RefreshButton:SetSize(24, 24)
    searchPanel.RefreshButton.Icon:SetPoint("CENTER")
    searchPanel.ResultsInset:Hide()
    searchPanel.AutoCompleteFrame:StripTextures()

    local numResults = 1
    hooksecurefunc("LFGListSearchPanel_UpdateAutoComplete", function(self)
        local AutoCompleteFrame = self.AutoCompleteFrame

        for i = numResults, #AutoCompleteFrame.Results do
            local result = AutoCompleteFrame.Results[i]

            if numResults == 1 then
                result:SetPoint("TOPLEFT", AutoCompleteFrame.LeftBorder, "TOPRIGHT", -8, 1)
                result:SetPoint("TOPRIGHT", AutoCompleteFrame.RightBorder, "TOPLEFT", 5, 1)
            else
                result:SetPoint("TOPLEFT", AutoCompleteFrame.Results[i - 1], "BOTTOMLEFT", 0, 1)
                result:SetPoint("TOPRIGHT", AutoCompleteFrame.Results[i - 1], "BOTTOMRIGHT", 0, 1)
            end

            result:SetNormalTexture(0)
            result:SetPushedTexture(0)
            result:SetHighlightTexture(0)

            local bg = result:CreateBackdrop()
            bg:SetBackdropColor(0, 0, 0, 0.5)
            local hl = result:CreateTexture(nil, "BACKGROUND")
            hl:SetInside(bg)
            hl:SetTexture(C.media.texture.blank)
            hl:SetVertexColor(cr, cg, cb, 0.25)
            hl:Hide()
            result.hl = hl

            result:HookScript("OnEnter", highlight_OnEnter)
            result:HookScript("OnLeave", highlight_OnLeave)

            numResults = numResults + 1
        end
    end)

    local function skinCreateButton(button)
        local child = button:GetChildren()
        if not child.__styled and child:IsObjectType("Button") then
            S:ReskinButton(child)
            child.__styled = true
        end
    end

    local delayStyled -- otherwise it taints while listing
    hooksecurefunc(searchPanel.ScrollBox, "Update", function(self)
        if not delayStyled then
            S:ReskinButton(self.StartGroupButton)
            S:ReskinTrimScrollBar(searchPanel.ScrollBar)
            delayStyled = true
        end
        self:ForEachFrame(skinCreateButton)
    end)

    -- [[ Application viewer ]]

    local applicationViewer = LFGListFrame.ApplicationViewer
    applicationViewer.InfoBackground:Hide()
    applicationViewer.Inset:Hide()

    local prevHeader
    for _, headerName in pairs({ "NameColumnHeader", "RoleColumnHeader", "ItemLevelColumnHeader", "RatingColumnHeader" }) do
        local header = applicationViewer[headerName]

        header:StripTextures()
        header.Label:FontTemplate(nil, 14) -- B.SetFontSize(header.Label, 14)
        header.Label:SetShadowColor(0, 0, 0, 0)
        header:SetHighlightTexture(0)

        local bg = header:CreateBackdrop()
        bg:SetBackdropColor(0, 0, 0, 0.25)
        local hl = header:CreateTexture(nil, "BACKGROUND")
        hl:SetInside(bg)
        hl:SetTexture(C.media.texture.blank)
        hl:SetVertexColor(cr, cg, cb, 0.25)
        hl:Hide()
        header.hl = hl

        header:HookScript("OnEnter", highlight_OnEnter)
        header:HookScript("OnLeave", highlight_OnLeave)

        if prevHeader then header:SetPoint("LEFT", prevHeader, "RIGHT", E.mult, 0) end
        prevHeader = header
    end

    S:ReskinButton(applicationViewer.RefreshButton)
    S:ReskinButton(applicationViewer.RemoveEntryButton)
    S:ReskinButton(applicationViewer.EditButton)
    S:ReskinButton(applicationViewer.BrowseGroupsButton)
    S:ReskinCheck(applicationViewer.AutoAcceptButton)
    S:ReskinTrimScrollBar(applicationViewer.ScrollBar)

    applicationViewer.RefreshButton:SetSize(24, 24)
    applicationViewer.RefreshButton.Icon:SetPoint("CENTER")

    hooksecurefunc("LFGListApplicationViewer_UpdateApplicant", function(button)
        if not button.__styled then
            S:ReskinButton(button.DeclineButton)
            S:ReskinButton(button.InviteButton)
            S:ReskinButton(button.InviteButtonSmall)

            button.__styled = true
        end
    end)

    -- [[ Entry creation ]]

    local entryCreation = LFGListFrame.EntryCreation
    entryCreation.Inset:Hide()
    entryCreation.Description:StripTextures()
    S:ReskinButton(entryCreation.ListGroupButton)
    S:ReskinButton(entryCreation.CancelButton)
    S:ReskinInput(entryCreation.Description)
    S:ReskinInput(entryCreation.Name)
    S:ReskinInput(entryCreation.ItemLevel.EditBox)
    S:ReskinInput(entryCreation.VoiceChat.EditBox)
    S:ReskinDropDown(entryCreation.GroupDropdown)
    S:ReskinDropDown(entryCreation.ActivityDropdown)
    S:ReskinDropDown(entryCreation.PlayStyleDropdown)
    S:ReskinCheck(entryCreation.MythicPlusRating.CheckButton)
    S:ReskinInput(entryCreation.MythicPlusRating.EditBox)
    S:ReskinCheck(entryCreation.PVPRating.CheckButton)
    S:ReskinInput(entryCreation.PVPRating.EditBox)
    if entryCreation.PvpItemLevel then -- Blizzard may rename Pvp → PvP in a future build
        S:ReskinCheck(entryCreation.PvpItemLevel.CheckButton)
        S:ReskinInput(entryCreation.PvpItemLevel.EditBox)
    end
    S:ReskinCheck(entryCreation.ItemLevel.CheckButton)
    S:ReskinCheck(entryCreation.VoiceChat.CheckButton)
    S:ReskinCheck(entryCreation.PrivateGroup.CheckButton)
    S:ReskinCheck(entryCreation.CrossFactionGroup.CheckButton)

    -- [[ Role count ]]

    hooksecurefunc("LFGListGroupDataDisplayRoleCount_Update", function(self)
        if not self.__styled then
            S:ReskinSmallRole(self.TankIcon, "TANK")
            S:ReskinSmallRole(self.HealerIcon, "HEALER")
            S:ReskinSmallRole(self.DamagerIcon, "DPS")
            -- fix for PGFinder
            self.DamagerIcon:ClearAllPoints()
            self.DamagerIcon:SetPoint("RIGHT", -11, 0)

            self.HealerIcon:SetPoint("RIGHT", self.DamagerIcon, "LEFT", -22, 0)
            self.TankIcon:SetPoint("RIGHT", self.HealerIcon, "LEFT", -22, 0)

            handleRoleAnchor(self, "Tank")
            handleRoleAnchor(self, "Healer")
            handleRoleAnchor(self, "Damager")

            self.__styled = true
        end
    end)

    hooksecurefunc("LFGListGroupDataDisplayPlayerCount_Update", function(self)
        if not self.__styled then
            self.Count:SetWidth(24)

            self.__styled = true
        end
    end)

    -- Activity finder

    local activityFinder = entryCreation.ActivityFinder
    activityFinder.Background:SetTexture("")

    local finderDialog = activityFinder.Dialog
    finderDialog:StripTextures()
    S:CreateBackground(finderDialog)
    S:ReskinButton(finderDialog.SelectButton)
    S:ReskinButton(finderDialog.CancelButton)
    S:ReskinInput(finderDialog.EntryBox)
    S:ReskinTrimScrollBar(finderDialog.ScrollBar)

    -- [[ Application dialog ]]

    local LFGListApplicationDialog = _G.LFGListApplicationDialog

    LFGListApplicationDialog:StripTextures()
    S:CreateBackground(LFGListApplicationDialog)
    LFGListApplicationDialog.Description:StripTextures()
    LFGListApplicationDialog.Description:CreateBackdrop()
    LFGListApplicationDialog.Description.backdrop:SetBackdropColor(0, 0, 0, 0.25)
    S:ReskinButton(LFGListApplicationDialog.SignUpButton)
    S:ReskinButton(LFGListApplicationDialog.CancelButton)

    -- [[ Invite dialog ]]

    local LFGListInviteDialog = _G.LFGListInviteDialog

    LFGListInviteDialog:StripTextures()
    S:CreateBackground(LFGListInviteDialog)
    S:ReskinButton(LFGListInviteDialog.AcceptButton)
    S:ReskinButton(LFGListInviteDialog.DeclineButton)
    S:ReskinButton(LFGListInviteDialog.AcknowledgeButton)
end

S:AddCallback("LFGList")
