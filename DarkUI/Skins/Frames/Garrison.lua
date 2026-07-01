local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB
local cr, cg, cb = DB.r, DB.g, DB.b

------------------------------------------------------------------------
-- Garrison / Mission / OrderHall / BFA / Covenant Mission UI
-- Ported from AuroraClassic AddOns/Blizzard_GarrisonUI.lua (2026-06)
-- Notes:
--   * Aurora noise overlay (CreateTex) dropped; DarkUI backdrop supplies texture.
--   * VenturePlan / WarPlan third-party addon skins retained faithfully.
--   * B:ReskinGarrisonTooltip inline-expanded (not a DarkUI S: facade).
--   * B:Round → math.floor (Aurora rounding helper, only used in VenturePlan).
--   * B.CreateSD → frame:CreateShadow().
--   * button.styled → button.__styled (per transform table).
--   * C.mult → E.mult.
------------------------------------------------------------------------

local _G = _G
local select, pairs, ceil, floor = select, pairs, ceil, floor
local hooksecurefunc = hooksecurefunc
local C_Timer = C_Timer
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local function reskinGarrisonTooltip(self)
    if self.Icon then S:ReskinIcon(self.Icon) end
    if self.CloseButton then S:ReskinClose(self.CloseButton) end
end

local function reskinMissionPage(self)
    self:StripTextures()
    local bg = self:CreateBackdrop()
    bg:SetPoint("TOPLEFT", 3, 2)
    bg:SetPoint("BOTTOMRIGHT", -3, -10)

    self.Stage.Header:SetAlpha(0)
    if self.StartMissionFrame then self.StartMissionFrame:StripTextures() end
    self.StartMissionButton.Flash:SetTexture("")
    S:Reskin(self.StartMissionButton)
    S:ReskinClose(self.CloseButton, nil, -10, -5)

    if self.EnemyBackground then self.EnemyBackground:Hide() end
    if self.FollowerBackground then self.FollowerBackground:Hide() end

    if self.Followers then
        for i = 1, 3 do
            local follower = self.Followers[i]
            follower:GetRegions():Hide()
            follower:CreateBackdrop()
            -- dedup: backdrop slot used by row bg; clear it so portrait gets its own
            follower.backdrop = nil
            S:ReskinGarrisonPortrait(follower.PortraitFrame)
            follower.PortraitFrame:ClearAllPoints()
            follower.PortraitFrame:SetPoint("TOPLEFT", 0, -3)
        end
    end

    if self.RewardsFrame then
        for i = 1, 10 do
            select(i, self.RewardsFrame:GetRegions()):Hide()
        end
        self.RewardsFrame:CreateBackdrop()

        local overmaxItem = self.RewardsFrame.OvermaxItem
        overmaxItem.IconBorder:SetAlpha(0)
        S:ReskinIcon(overmaxItem.Icon)
    end

    local env = self.Stage.MissionEnvIcon
    env.bg = S:ReskinIcon(env.Texture)

    if self.CostFrame then self.CostFrame.CostIcon:SetTexCoord(unpack(DB.TexCoord)) end
end

local function reskinMissionTabs(self)
    for i = 1, 2 do
        local tab = _G[self:GetName() .. "Tab" .. i]
        if tab then
            tab:StripTextures()
            tab.bg = tab:CreateBackdrop()
            if i == 1 then tab.bg:SetBackdropColor(cr, cg, cb, 0.2) end
        end
    end
end

local function reskinXPBar(self)
    local xpBar = self.XPBar
    if xpBar then
        xpBar:GetRegions():Hide()
        xpBar.XPLeft:Hide()
        xpBar.XPRight:Hide()
        select(4, xpBar:GetRegions()):Hide()
        xpBar:SetStatusBarTexture(DB.bdTex)
        xpBar:CreateBackdrop()
    end
end

local function reskinGarrMaterial(self)
    local frame = self.MaterialFrame
    frame.BG:Hide()
    if frame.LeftFiligree then frame.LeftFiligree:Hide() end
    if frame.RightFiligree then frame.RightFiligree:Hide() end

    S:ReskinIcon(frame.Icon)
    local bg = frame:CreateBackdrop()
    bg:SetPoint("TOPLEFT", 5, -5)
    bg:SetPoint("BOTTOMRIGHT", -5, 6)
end

local function reskinMissionButton(button)
    if not button.__styled then
        local rareOverlay = button.RareOverlay
        local rareText = button.RareText

        button.LocBG:SetDrawLayer("BACKGROUND")
        if button.ButtonBG then button.ButtonBG:Hide() end
        button:StripTextures()
        button:CreateBackdrop()
        button.Highlight:SetColorTexture(0.6, 0.8, 1, 0.15)
        button.Highlight:SetAllPoints()

        if button.CompleteCheck then button.CompleteCheck:SetAtlas("Adventures-Checkmark") end
        if rareText then
            rareText:ClearAllPoints()
            rareText:SetPoint("BOTTOMLEFT", button, 20, 10)
        end
        if rareOverlay then
            rareOverlay:SetDrawLayer("BACKGROUND")
            rareOverlay:SetTexture(DB.bdTex)
            rareOverlay:SetAllPoints()
            rareOverlay:SetVertexColor(0.098, 0.537, 0.969, 0.2)
        end
        if button.Overlay and button.Overlay.Overlay then button.Overlay.Overlay:SetAllPoints() end

        button.__styled = true
    end
end

local function reskinMissionList(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local button = select(i, self.ScrollTarget:GetChildren())
        reskinMissionButton(button)
    end
end

local function reskinMissionComplete(self)
    local missionComplete = self.MissionComplete
    local bonusRewards = missionComplete.BonusRewards
    if bonusRewards then
        select(11, bonusRewards:GetRegions()):SetTextColor(1, 0.8, 0)
        bonusRewards.Saturated:StripTextures()
        for i = 1, 9 do
            select(i, bonusRewards:GetRegions()):SetAlpha(0)
        end
        bonusRewards:CreateBackdrop()
    end
    if missionComplete.NextMissionButton then S:Reskin(missionComplete.NextMissionButton) end
    if missionComplete.CompleteFrame then
        missionComplete:StripTextures()
        local bg = missionComplete:CreateBackdrop()
        bg:SetPoint("TOPLEFT", 3, 2)
        bg:SetPoint("BOTTOMRIGHT", -3, -10)

        missionComplete.CompleteFrame:StripTextures()
        S:Reskin(missionComplete.CompleteFrame.ContinueButton)
        S:Reskin(missionComplete.CompleteFrame.SpeedButton)
        S:Reskin(missionComplete.RewardsScreen.FinalRewardsPanel.ContinueButton)
    end
    if missionComplete.MissionInfo then missionComplete.MissionInfo:StripTextures() end
    if missionComplete.EnemyBackground then missionComplete.EnemyBackground:Hide() end
    if missionComplete.FollowerBackground then missionComplete.FollowerBackground:Hide() end
end

local function reskinFollowerTab(self)
    for i = 1, 2 do
        local trait = self.Traits[i]
        trait.Border:Hide()
        S:ReskinIcon(trait.Portrait)

        local equipment = self.EquipmentFrame.Equipment[i]
        equipment.BG:Hide()
        equipment.Border:Hide()
        S:ReskinIcon(equipment.Icon)
    end
end

local function updateFollowerQuality(self, followerInfo)
    if followerInfo then
        local color = DB.QualityColors[followerInfo.quality or 1]
        self.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

local function reskinFollowerButton(button)
    if not button.__styled then
        button.BG:Hide()
        button.Selection:SetTexture("")
        button.AbilitiesBG:SetTexture("")
        button.bg = button:CreateBackdrop()

        local hl = button:GetHighlightTexture()
        hl:SetColorTexture(cr, cg, cb, 0.1)
        hl:ClearAllPoints()
        hl:SetInside(button.bg)

        local portrait = button.PortraitFrame
        if portrait then
            S:ReskinGarrisonPortrait(portrait)
            portrait:ClearAllPoints()
            portrait:SetPoint("TOPLEFT", 4, -1)
            hooksecurefunc(portrait, "SetupPortrait", updateFollowerQuality)
        end

        if button.BusyFrame then button.BusyFrame:SetInside(button.bg) end

        button.__styled = true
    end

    if button.Counters then
        for i = 1, #button.Counters do
            local counter = button.Counters[i]
            if counter and not counter.bg then counter.bg = S:ReskinIcon(counter.Icon) end
        end
    end

    if button.Selection:IsShown() then
        button.bg:SetBackdropColor(cr, cg, cb, 0.2)
    else
        button.bg:SetBackdropColor(0, 0, 0, 0.25)
    end
end

local function reskinFollowerButtons(self)
    for i = 1, self.ScrollTarget:GetNumChildren() do
        local child = select(i, self.ScrollTarget:GetChildren())
        reskinFollowerButton(child.Follower)
    end
end

local function reskinFollowerList(followerList) hooksecurefunc(followerList.ScrollBox, "Update", reskinFollowerButtons) end

local function updateSpellAbilities(self)
    for abilityFrame in self.autoSpellPool:EnumerateActive() do
        if not abilityFrame.__styled then
            S:ReskinIcon(abilityFrame.Icon)
            if abilityFrame.IconMask then abilityFrame.IconMask:Hide() end
            if abilityFrame.SpellBorder then abilityFrame.SpellBorder:Hide() end

            abilityFrame.__styled = true
        end
    end
end

local function updateFollowerAbilities(followerList)
    local followerTab = followerList.followerTab
    local abilitiesFrame = followerTab.AbilitiesFrame
    if not abilitiesFrame then return end

    local abilities = abilitiesFrame.Abilities
    if abilities then
        for i = 1, #abilities do
            local iconButton = abilities[i].IconButton
            local icon = iconButton and iconButton.Icon
            if icon and not icon.bg then
                iconButton.Border:SetAlpha(0)
                icon.bg = S:ReskinIcon(icon)
            end
        end
    end

    local equipment = abilitiesFrame.Equipment
    if equipment then
        for i = 1, #equipment do
            local equip = equipment[i]
            if equip and not equip.bg then
                equip.Border:SetAlpha(0)
                equip.BG:SetAlpha(0)
                equip.bg = S:ReskinIcon(equip.Icon)
                equip.bg:SetBackdropColor(1, 1, 1, 0.15)
            end
        end
    end

    local combatAllySpell = abilitiesFrame.CombatAllySpell
    if combatAllySpell then
        for i = 1, #combatAllySpell do
            local icon = combatAllySpell[i].iconTexture
            if icon and not icon.bg then icon.bg = S:ReskinIcon(icon) end
        end
    end
end

local function reskinFollowerItem(item)
    if not item then return end

    local icon = item.Icon
    item.Border:Hide()
    S:ReskinIcon(icon)

    local bg = item:CreateBackdrop()
    bg:SetPoint("TOPLEFT", 41, -1)
    bg:SetPoint("BOTTOMRIGHT", 0, 1)
end

local function reskinMissionFrame(self)
    self:StripTextures(0)
    S:SetBD(self)
    self.CloseButton:StripTextures(0)
    S:ReskinClose(self.CloseButton)
    self.GarrCorners:Hide()
    if self.OverlayElements then self.OverlayElements:SetAlpha(0) end
    if self.ClassHallIcon then self.ClassHallIcon:Hide() end
    if self.TitleScroll then
        self.TitleScroll:StripTextures()
        select(4, self.TitleScroll:GetRegions()):SetTextColor(1, 0.8, 0)
    end
    for i = 1, 3 do
        local tab = _G[self:GetName() .. "Tab" .. i]
        if tab then S:ReskinTab(tab) end
    end
    if self.MapTab then self.MapTab.ScrollContainer.Child.TiledBackground:Hide() end

    reskinMissionComplete(self)
    reskinMissionPage(self.MissionTab.MissionPage)
    self.FollowerTab:StripTextures()
    reskinXPBar(self.FollowerTab)
    hooksecurefunc(self.FollowerTab, "UpdateAutoSpellAbilities", updateSpellAbilities)

    reskinFollowerItem(self.FollowerTab.ItemWeapon)
    reskinFollowerItem(self.FollowerTab.ItemArmor)

    local missionList = self.MissionTab.MissionList
    missionList:StripTextures()
    S:ReskinTrimScroll(missionList.ScrollBar)
    reskinGarrMaterial(missionList)
    reskinMissionTabs(missionList)
    S:Reskin(missionList.CompleteDialog.BorderFrame.ViewButton)
    hooksecurefunc(missionList.ScrollBox, "Update", reskinMissionList)

    local followerList = self.FollowerList
    followerList:StripTextures()
    if followerList.SearchBox then S:ReskinEditBox(followerList.SearchBox) end
    S:ReskinTrimScroll(followerList.ScrollBar)
    reskinGarrMaterial(followerList)
    reskinFollowerList(followerList)
    hooksecurefunc(followerList, "ShowFollower", updateFollowerAbilities)
end

-- Missions board in 9.0
local function reskinAbilityIcon(self, anchor, yOffset)
    self:ClearAllPoints()
    self:SetPoint(anchor, self:GetParent().squareBG, "LEFT", -3, yOffset)
    self.Border:SetAlpha(0)
    self.CircleMask:Hide()
    S:ReskinIcon(self.Icon)
end

local function updateFollowerColorOnBoard(self, _, info)
    if self.squareBG then
        local color = DB.QualityColors[info.quality or 1]
        self.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
    end
end

local function resetFollowerColorOnBoard(self)
    if self.squareBG then self.squareBG:SetBackdropBorderColor(0, 0, 0) end
end

local function reskinFollowerBoard(self, group)
    for socketTexture in self[group .. "SocketFramePool"]:EnumerateActive() do
        socketTexture:DisableDrawLayer("BACKGROUND")
    end
    for frame in self[group .. "FramePool"]:EnumerateActive() do
        if not frame.__styled then
            S:ReskinGarrisonPortrait(frame)
            frame.PuckShadow:SetAlpha(0)
            reskinAbilityIcon(frame.AbilityOne, "BOTTOMRIGHT", 1)
            reskinAbilityIcon(frame.AbilityTwo, "TOPRIGHT", -1)
            if frame.SetFollowerGUID then hooksecurefunc(frame, "SetFollowerGUID", updateFollowerColorOnBoard) end
            if frame.SetEmpty then hooksecurefunc(frame, "SetEmpty", resetFollowerColorOnBoard) end

            frame.__styled = true
        end
    end
end

local function reskinMissionBoards(self)
    reskinFollowerBoard(self, "enemy")
    reskinFollowerBoard(self, "follower")
end

function S:Garrison()
    if not (C.skins.enable and C.skins.garrison) then return end

    -- Tooltips (inline-expanded from Aurora's B:ReskinGarrisonTooltip)
    reskinGarrisonTooltip(_G.GarrisonFollowerAbilityWithoutCountersTooltip)
    reskinGarrisonTooltip(_G.GarrisonFollowerMissionAbilityWithoutCountersTooltip)

    -- Building frame
    local GarrisonBuildingFrame = _G.GarrisonBuildingFrame
    GarrisonBuildingFrame:StripTextures()
    S:SetBD(GarrisonBuildingFrame)
    S:ReskinClose(GarrisonBuildingFrame.CloseButton)
    GarrisonBuildingFrame.GarrCorners:Hide()

    -- Tutorial button
    local mainHelpButton = GarrisonBuildingFrame.MainHelpButton
    mainHelpButton.Ring:Hide()
    mainHelpButton:SetPoint("TOPLEFT", GarrisonBuildingFrame, "TOPLEFT", -12, 12)

    -- Building list
    local buildingList = GarrisonBuildingFrame.BuildingList
    buildingList:DisableDrawLayer("BORDER")
    reskinGarrMaterial(buildingList)

    for i = 1, _G.GARRISON_NUM_BUILDING_SIZES do
        local tab = buildingList["Tab" .. i]
        tab:GetNormalTexture():SetAlpha(0)

        local bg = tab:CreateBackdrop()
        bg:SetPoint("TOPLEFT", 6, -7)
        bg:SetPoint("BOTTOMRIGHT", -6, 7)
        tab.bg = bg

        local hl = tab:GetHighlightTexture()
        hl:SetColorTexture(cr, cg, cb, 0.1)
        hl:ClearAllPoints()
        hl:SetInside(bg)
    end

    hooksecurefunc("GarrisonBuildingList_SelectTab", function(tab)
        local list = _G.GarrisonBuildingFrame.BuildingList

        for i = 1, _G.GARRISON_NUM_BUILDING_SIZES do
            local otherTab = list["Tab" .. i]
            if i ~= tab:GetID() then otherTab.bg:SetBackdropColor(0, 0, 0, 0.25) end
        end
        tab.bg:SetBackdropColor(cr, cg, cb, 0.2)

        for _, button in pairs(list.Buttons) do
            if not button.__styled then
                button.BG:Hide()
                S:ReskinIcon(button.Icon)

                local bg = button:CreateBackdrop()
                bg:SetPoint("TOPLEFT", 44, -5)
                bg:SetPoint("BOTTOMRIGHT", 0, 6)

                button.SelectedBG:SetColorTexture(cr, cg, cb, 0.2)
                button.SelectedBG:ClearAllPoints()
                button.SelectedBG:SetInside(bg)

                local hl = button:GetHighlightTexture()
                hl:SetColorTexture(cr, cg, cb, 0.1)
                hl:SetAllPoints(button.SelectedBG)

                button.__styled = true
            end
        end
    end)

    -- Follower list (building frame)
    local bfFollowerList = GarrisonBuildingFrame.FollowerList
    bfFollowerList:ClearAllPoints()
    bfFollowerList:SetPoint("BOTTOMLEFT", 24, 34)
    bfFollowerList:DisableDrawLayer("BACKGROUND")
    bfFollowerList:DisableDrawLayer("BORDER")
    S:ReskinTrimScroll(bfFollowerList.ScrollBar)
    reskinFollowerList(bfFollowerList)
    hooksecurefunc(bfFollowerList, "ShowFollower", updateFollowerAbilities)

    -- Info box
    local infoBox = GarrisonBuildingFrame.InfoBox
    local townHallBox = GarrisonBuildingFrame.TownHallBox
    infoBox:StripTextures()
    infoBox:CreateBackdrop()
    townHallBox:StripTextures()
    townHallBox:CreateBackdrop()
    S:Reskin(infoBox.UpgradeButton)
    S:Reskin(townHallBox.UpgradeButton)
    _G.GarrisonBuildingFrame.MapFrame.TownHall.TownHallName:SetTextColor(1, 0.8, 0)

    local followerPortrait = infoBox.FollowerPortrait
    S:ReskinGarrisonPortrait(followerPortrait)
    followerPortrait:SetPoint("BOTTOMLEFT", 230, 10)
    followerPortrait.RemoveFollowerButton:ClearAllPoints()
    followerPortrait.RemoveFollowerButton:SetPoint("TOPRIGHT", 4, 4)

    hooksecurefunc("GarrisonBuildingInfoBox_ShowFollowerPortrait", function(_, _, ib)
        local portrait = ib.FollowerPortrait
        if portrait:IsShown() then portrait.squareBG:SetBackdropBorderColor(portrait.PortraitRing:GetVertexColor()) end
    end)

    -- Confirmation popup
    local confirmation = GarrisonBuildingFrame.Confirmation
    confirmation:GetRegions():Hide()
    confirmation:CreateBackdrop()
    S:Reskin(confirmation.CancelButton)
    S:Reskin(confirmation.BuildButton)
    S:Reskin(confirmation.UpgradeButton)
    S:Reskin(confirmation.UpgradeGarrisonButton)
    S:Reskin(confirmation.ReplaceButton)
    S:Reskin(confirmation.SwitchButton)

    -- Capacitive display frame
    local GarrisonCapacitiveDisplayFrame = _G.GarrisonCapacitiveDisplayFrame
    _G.GarrisonCapacitiveDisplayFrameLeft:Hide()
    _G.GarrisonCapacitiveDisplayFrameMiddle:Hide()
    _G.GarrisonCapacitiveDisplayFrameRight:Hide()
    GarrisonCapacitiveDisplayFrame.Count:CreateBackdrop()
    GarrisonCapacitiveDisplayFrame.Count:SetWidth(38)
    GarrisonCapacitiveDisplayFrame.Count:SetTextInsets(3, 0, 0, 0)

    S:ReskinPortraitFrame(GarrisonCapacitiveDisplayFrame)
    S:Reskin(GarrisonCapacitiveDisplayFrame.StartWorkOrderButton, true)
    S:Reskin(GarrisonCapacitiveDisplayFrame.CreateAllWorkOrdersButton, true)
    S:ReskinArrow(GarrisonCapacitiveDisplayFrame.DecrementButton, "left")
    S:ReskinArrow(GarrisonCapacitiveDisplayFrame.IncrementButton, "right")

    -- Capacitive display
    local capacitiveDisplay = GarrisonCapacitiveDisplayFrame.CapacitiveDisplay
    capacitiveDisplay.IconBG:SetAlpha(0)
    S:ReskinIcon(capacitiveDisplay.ShipmentIconFrame.Icon)
    S:ReskinGarrisonPortrait(capacitiveDisplay.ShipmentIconFrame.Follower)

    local reagentIndex = 1
    hooksecurefunc("GarrisonCapacitiveDisplayFrame_Update", function()
        local reagents = capacitiveDisplay.Reagents

        local reagent = reagents[reagentIndex]
        while reagent do
            reagent.NameFrame:SetAlpha(0)
            S:ReskinIcon(reagent.Icon)

            local bg = reagent:CreateBackdrop()
            bg:SetPoint("TOPLEFT")
            bg:SetPoint("BOTTOMRIGHT", 0, 2)

            reagentIndex = reagentIndex + 1
            reagent = reagents[reagentIndex]
        end
    end)

    -- Landing page
    local GarrisonLandingPage = _G.GarrisonLandingPage
    GarrisonLandingPage:StripTextures()
    S:SetBD(GarrisonLandingPage)
    S:ReskinClose(GarrisonLandingPage.CloseButton)
    S:ReskinTab(_G.GarrisonLandingPageTab1)
    S:ReskinTab(_G.GarrisonLandingPageTab2)
    S:ReskinTab(_G.GarrisonLandingPageTab3)

    _G.GarrisonLandingPageTab1:ClearAllPoints()
    _G.GarrisonLandingPageTab1:SetPoint("TOPLEFT", GarrisonLandingPage, "BOTTOMLEFT", 70, 2)

    -- Report
    local report = GarrisonLandingPage.Report
    report:StripTextures()
    report.List:StripTextures()
    S:ReskinTrimScroll(report.List.ScrollBar)

    hooksecurefunc(report.List.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            if not button.__styled then
                button.BG:Hide()
                local bg = button:CreateBackdrop()
                bg:SetPoint("TOPLEFT")
                bg:SetPoint("BOTTOMRIGHT", 0, 1)

                for _, reward in pairs(button.Rewards) do
                    reward:GetRegions():Hide()
                    reward.bg = S:ReskinIcon(reward.Icon)
                    S:ReskinIconBorder(reward.IconBorder)
                end

                button.__styled = true
            end
        end
    end)

    for _, tab in pairs({ report.InProgress, report.Available }) do
        tab:SetHighlightTexture(0)
        tab.Text:ClearAllPoints()
        tab.Text:SetPoint("CENTER")

        local bg = tab:CreateBackdrop()

        local selectedTex = bg:CreateTexture(nil, "BACKGROUND")
        selectedTex:SetAllPoints()
        selectedTex:SetColorTexture(cr, cg, cb, 0.2)
        selectedTex:Hide()
        tab.selectedTex = selectedTex

        if tab == report.InProgress then
            bg:SetPoint("TOPLEFT", 5, 0)
            bg:SetPoint("BOTTOMRIGHT")
        else
            bg:SetPoint("TOPLEFT")
            bg:SetPoint("BOTTOMRIGHT", -7, 0)
        end
    end

    hooksecurefunc("GarrisonLandingPageReport_SetTab", function(self)
        local unselectedTab = report.unselectedTab
        unselectedTab:SetHeight(36)
        unselectedTab:SetNormalTexture(0)
        unselectedTab.selectedTex:Hide()
        self:SetNormalTexture(0)
        self.selectedTex:Show()
    end)

    -- Follower list (landing page)
    local landingFollowerList = GarrisonLandingPage.FollowerList
    landingFollowerList:StripTextures()
    S:ReskinEditBox(landingFollowerList.SearchBox)
    S:ReskinTrimScroll(landingFollowerList.ScrollBar)
    reskinFollowerList(_G.GarrisonLandingPageFollowerList)
    hooksecurefunc(_G.GarrisonLandingPageFollowerList, "ShowFollower", updateFollowerAbilities)

    -- Ship follower list
    local shipFollowerList = GarrisonLandingPage.ShipFollowerList
    shipFollowerList:StripTextures()
    S:ReskinEditBox(shipFollowerList.SearchBox)
    S:ReskinTrimScroll(shipFollowerList.ScrollBar)

    -- Follower tab
    local followerTabLP = GarrisonLandingPage.FollowerTab
    reskinXPBar(followerTabLP)
    hooksecurefunc(followerTabLP, "UpdateAutoSpellAbilities", updateSpellAbilities)

    -- Ship follower tab
    local shipFollowerTab = GarrisonLandingPage.ShipFollowerTab
    reskinXPBar(shipFollowerTab)
    reskinFollowerTab(shipFollowerTab)

    -- Mission UI
    local GarrisonMissionFrame = _G.GarrisonMissionFrame
    reskinMissionFrame(GarrisonMissionFrame)

    hooksecurefunc("GarrisonMissonListTab_SetSelected", function(tab, isSelected)
        if isSelected then
            tab.bg:SetBackdropColor(cr, cg, cb, 0.2)
        else
            tab.bg:SetBackdropColor(0, 0, 0, 0.25)
        end
    end)

    hooksecurefunc("GarrisonFollowerButton_AddAbility", function(self, index)
        local ability = self.Abilities[index]

        if not ability.__styled then
            local icon = ability.Icon
            icon:SetSize(19, 19)
            S:ReskinIcon(icon)

            ability.__styled = true
        end
    end)

    hooksecurefunc("GarrisonFollowerButton_SetCounterButton", function(button, _, index)
        local counter = button.Counters[index]
        if counter and not counter.__styled then
            S:ReskinIcon(counter.Icon)
            counter.__styled = true
        end
    end)

    hooksecurefunc("GarrisonMissionButton_SetReward", function(frame)
        if not frame.bg then
            frame:GetRegions():Hide()
            frame.bg = S:ReskinIcon(frame.Icon)
            S:ReskinIconBorder(frame.IconBorder, true)
        end
    end)

    hooksecurefunc("GarrisonMissionPortrait_SetFollowerPortrait", function(portraitFrame, followerInfo)
        if not portraitFrame.__styled then
            S:ReskinGarrisonPortrait(portraitFrame)
            portraitFrame.__styled = true
        end

        local color = DB.QualityColors[followerInfo.quality]
        portraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
        portraitFrame.squareBG:Show()
    end)

    hooksecurefunc("GarrisonMissionPage_SetReward", function(frame)
        if not frame.bg then
            S:ReskinIcon(frame.Icon)
            frame.BG:SetAlpha(0)
            frame.bg = frame.BG:CreateBackdrop()
            frame.IconBorder:SetScale(0.0001)
        end
    end)

    hooksecurefunc(_G.GarrisonMission, "UpdateMissionParty", function(_, followers)
        for followerIndex = 1, #followers do
            local followerFrame = followers[followerIndex]
            if followerFrame.info then
                for i = 1, #followerFrame.Counters do
                    local counter = followerFrame.Counters[i]
                    if not counter.__styled then
                        S:ReskinIcon(counter.Icon)
                        counter.__styled = true
                    end
                end
            end
        end
    end)

    hooksecurefunc(_G.GarrisonMission, "RemoveFollowerFromMission", function(_, frame)
        if frame.PortraitFrame and frame.PortraitFrame.squareBG then frame.PortraitFrame.squareBG:Hide() end
    end)

    hooksecurefunc(_G.GarrisonMission, "SetEnemies", function(_, missionPage, enemies)
        for i = 1, #enemies do
            local frame = missionPage.Enemies[i]
            if frame:IsShown() and not frame.__styled then
                for j = 1, #frame.Mechanics do
                    local mechanic = frame.Mechanics[j]
                    S:ReskinIcon(mechanic.Icon)
                end
                frame.__styled = true
            end
        end
    end)

    hooksecurefunc(_G.GarrisonMission, "UpdateMissionData", function(_, missionPage)
        local buffsFrame = missionPage.BuffsFrame
        if buffsFrame and buffsFrame:IsShown() then
            for i = 1, #buffsFrame.Buffs do
                local buff = buffsFrame.Buffs[i]
                if not buff.__styled then
                    S:ReskinIcon(buff.Icon)
                    buff.__styled = true
                end
            end
        end
    end)

    hooksecurefunc(_G.GarrisonMission, "MissionCompleteInitialize", function(self, missionList, index)
        local mission = missionList[index]
        if not mission then return end

        for i = 1, #mission.followers do
            local frame = self.MissionComplete.Stage.FollowersFrame.Followers[i]
            if frame.PortraitFrame then
                if not frame.bg then
                    frame.PortraitFrame:ClearAllPoints()
                    frame.PortraitFrame:SetPoint("TOPLEFT", 0, -10)
                    S:ReskinGarrisonPortrait(frame.PortraitFrame)

                    local oldBg = frame:GetRegions()
                    oldBg:Hide()
                    frame.bg = oldBg:CreateBackdrop()
                    frame.bg:SetPoint("TOPLEFT", frame.PortraitFrame, -1, 1)
                    frame.bg:SetPoint("BOTTOMRIGHT", -10, 8)
                end

                local quality = select(4, C_Garrison.GetFollowerMissionCompleteInfo(mission.followers[i]))
                if quality then
                    local color = DB.QualityColors[quality]
                    frame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
                    frame.PortraitFrame.squareBG:Show()
                end
            end
        end
    end)

    hooksecurefunc(_G.GarrisonMission, "ShowMission", function(self)
        local envIcon = self:GetMissionPage().Stage.MissionEnvIcon
        if envIcon.bg then envIcon.bg:SetShown(envIcon.Texture:GetTexture()) end
    end)

    -- Recruiter frame
    local GarrisonRecruiterFrame = _G.GarrisonRecruiterFrame
    S:ReskinPortraitFrame(GarrisonRecruiterFrame)

    -- Pick
    local Pick = GarrisonRecruiterFrame.Pick
    S:Reskin(Pick.ChooseRecruits)
    S:ReskinDropDown(Pick.ThreatDropdown)
    S:ReskinRadio(Pick.Radio1)
    S:ReskinRadio(Pick.Radio2)

    -- Unavailable frame
    local UnavailableFrame = GarrisonRecruiterFrame.UnavailableFrame
    S:Reskin(UnavailableFrame:GetChildren())

    -- Recruiter select frame
    local GarrisonRecruitSelectFrame = _G.GarrisonRecruitSelectFrame
    GarrisonRecruitSelectFrame:StripTextures()
    GarrisonRecruitSelectFrame.TitleText:Show()
    GarrisonRecruitSelectFrame.GarrCorners:Hide()
    GarrisonRecruitSelectFrame:CreateBackdrop()
    S:ReskinClose(GarrisonRecruitSelectFrame.CloseButton)

    -- Follower list (recruit select)
    local rsFollowerList = GarrisonRecruitSelectFrame.FollowerList
    rsFollowerList:DisableDrawLayer("BORDER")
    S:ReskinTrimScroll(rsFollowerList.ScrollBar)
    S:ReskinEditBox(rsFollowerList.SearchBox)
    reskinFollowerList(rsFollowerList)
    hooksecurefunc(rsFollowerList, "ShowFollower", updateFollowerAbilities)

    -- Follower selection
    local FollowerSelection = GarrisonRecruitSelectFrame.FollowerSelection
    FollowerSelection:DisableDrawLayer("BORDER")
    for i = 1, 3 do
        local recruit = FollowerSelection["Recruit" .. i]
        S:ReskinGarrisonPortrait(recruit.PortraitFrame)
        S:Reskin(recruit.HireRecruits)
    end

    hooksecurefunc("GarrisonRecruitSelectFrame_UpdateRecruits", function(waiting)
        if waiting then return end

        for i = 1, 3 do
            local frame = FollowerSelection["Recruit" .. i]
            local portrait = frame.PortraitFrame
            portrait.squareBG:SetBackdropBorderColor(portrait.LevelBorder:GetVertexColor())

            if frame:IsShown() then
                local traits = frame.Traits.Entries
                if traits then
                    for index = 1, #traits do
                        local trait = traits[index]
                        if not trait.bg then trait.bg = S:ReskinIcon(trait.Icon) end
                    end
                end
                local abilities = frame.Abilities.Entries
                if abilities then
                    for index = 1, #abilities do
                        local ability = abilities[index]
                        if not ability.bg then ability.bg = S:ReskinIcon(ability.Icon) end
                    end
                end
            end
        end
    end)

    -- Monuments
    local GarrisonMonumentFrame = _G.GarrisonMonumentFrame
    GarrisonMonumentFrame.Background:Hide()
    S:SetBD(GarrisonMonumentFrame, nil, 6, -10, -6, 4)

    for _, name in pairs({ "Left", "Right" }) do
        local button = GarrisonMonumentFrame[name .. "Btn"]
        button.Texture:Hide()
        S:ReskinArrow(button, strlower(name))
        button:SetSize(35, 35)
        button.__texture:SetSize(16, 16)
    end

    -- Shipyard
    local GarrisonShipyardFrame = _G.GarrisonShipyardFrame
    GarrisonShipyardFrame:StripTextures()
    GarrisonShipyardFrame.BorderFrame.GarrCorners:Hide()
    GarrisonShipyardFrame.BackgroundTile:Hide()
    S:SetBD(GarrisonShipyardFrame)
    S:ReskinEditBox(_G.GarrisonShipyardFrameFollowers.SearchBox)
    S:ReskinTrimScroll(GarrisonShipyardFrame.FollowerList.ScrollBar)
    _G.GarrisonShipyardFrameFollowers:StripTextures()
    reskinGarrMaterial(_G.GarrisonShipyardFrameFollowers)

    local shipyardTab = GarrisonShipyardFrame.FollowerTab
    shipyardTab:DisableDrawLayer("BORDER")
    reskinXPBar(shipyardTab)
    reskinFollowerTab(shipyardTab)

    S:ReskinClose(GarrisonShipyardFrame.BorderFrame.CloseButton2)
    S:ReskinTab(_G.GarrisonShipyardFrameTab1)
    S:ReskinTab(_G.GarrisonShipyardFrameTab2)

    local shipyardMission = GarrisonShipyardFrame.MissionTab.MissionPage
    shipyardMission:StripTextures()
    S:ReskinClose(shipyardMission.CloseButton)
    S:Reskin(shipyardMission.StartMissionButton)
    local smbg = shipyardMission.Stage:CreateBackdrop()
    smbg:SetPoint("TOPLEFT", 4, 1)
    smbg:SetPoint("BOTTOMRIGHT", -4, -1)

    shipyardMission.RewardsFrame:StripTextures()
    shipyardMission.RewardsFrame:CreateBackdrop()

    _G.GarrisonShipyardFrame.MissionCompleteBackground:GetRegions():Hide()
    _G.GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog:GetRegions():Hide()
    S:Reskin(_G.GarrisonShipyardFrame.MissionTab.MissionList.CompleteDialog.BorderFrame.ViewButton)
    select(11, _G.GarrisonShipyardFrame.MissionComplete.BonusRewards:GetRegions()):SetTextColor(1, 0.8, 0)
    S:Reskin(_G.GarrisonShipyardFrame.MissionComplete.NextMissionButton)

    -- OrderHall UI
    local OrderHallMissionFrame = _G.OrderHallMissionFrame
    reskinMissionFrame(OrderHallMissionFrame)

    -- Combat ally
    local combatAlly = _G.OrderHallMissionFrameMissions.CombatAllyUI
    S:Reskin(combatAlly.InProgress.Unassign)
    combatAlly:GetRegions():Hide()
    combatAlly:CreateBackdrop()
    S:ReskinIcon(combatAlly.InProgress.CombatAllySpell.iconTexture)

    local allyPortrait = combatAlly.InProgress.PortraitFrame
    S:ReskinGarrisonPortrait(allyPortrait)
    OrderHallMissionFrame:HookScript("OnShow", function()
        if allyPortrait:IsShown() then
            local color = DB.QualityColors[allyPortrait.quality or 1]
            allyPortrait.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
        end
        combatAlly.Available.AddFollowerButton.EmptyPortrait:SetAlpha(0)
        combatAlly.Available.AddFollowerButton.PortraitHighlight:SetAlpha(0)
    end)

    hooksecurefunc(_G.OrderHallCombatAllyMixin, "UnassignAlly", function(self)
        if self.InProgress.PortraitFrame.squareBG then self.InProgress.PortraitFrame.squareBG:Hide() end
    end)

    -- Zone support
    local ZoneSupportMissionPage = OrderHallMissionFrame.MissionTab.ZoneSupportMissionPage
    ZoneSupportMissionPage:StripTextures()
    ZoneSupportMissionPage:CreateBackdrop()
    S:ReskinClose(ZoneSupportMissionPage.CloseButton)
    S:Reskin(ZoneSupportMissionPage.StartMissionButton)
    S:ReskinIcon(ZoneSupportMissionPage.CombatAllySpell.iconTexture)
    ZoneSupportMissionPage.Follower1:GetRegions():Hide()
    ZoneSupportMissionPage.Follower1:CreateBackdrop()
    S:ReskinGarrisonPortrait(ZoneSupportMissionPage.Follower1.PortraitFrame)

    -- BFA Mission UI
    local BFAMissionFrame = _G.BFAMissionFrame
    reskinMissionFrame(BFAMissionFrame)

    -- Covenant Mission UI
    local CovenantMissionFrame = _G.CovenantMissionFrame
    reskinMissionFrame(CovenantMissionFrame)
    CovenantMissionFrame.RaisedBorder:SetAlpha(0)
    _G.CovenantMissionFrameMissions:StripTextures(0)
    _G.CovenantMissionFrameMissions.RaisedFrameEdges:SetAlpha(0)

    hooksecurefunc(CovenantMissionFrame, "SetupTabs", function(self) self.MapTab:SetShown(not self.Tab2:IsShown()) end)

    _G.CombatLog:DisableDrawLayer("BACKGROUND")
    _G.CombatLog.ElevatedFrame:SetAlpha(0)
    _G.CombatLog.CombatLogMessageFrame:StripTextures()
    _G.CombatLog.CombatLogMessageFrame:CreateBackdrop()

    S:Reskin(_G.HealFollowerButtonTemplate)
    local covFollowerTabBg = CovenantMissionFrame.FollowerTab:CreateBackdrop()
    covFollowerTabBg:SetPoint("TOPLEFT", 3, 2)
    covFollowerTabBg:SetPoint("BOTTOMRIGHT", -3, -10)
    CovenantMissionFrame.FollowerTab:StripTextures(0)
    CovenantMissionFrame.FollowerTab.RaisedFrameEdges:SetAlpha(0)
    CovenantMissionFrame.FollowerTab.HealFollowerFrame.ButtonFrame:SetAlpha(0)
    _G.CovenantMissionFrameFollowers.ElevatedFrame:SetAlpha(0)
    S:Reskin(_G.CovenantMissionFrameFollowers.HealAllButton)
    S:ReskinIcon(CovenantMissionFrame.FollowerTab.HealFollowerFrame.CostFrame.CostIcon)

    CovenantMissionFrame.MissionTab.MissionPage.Board:HookScript("OnShow", reskinMissionBoards)
    CovenantMissionFrame.MissionComplete.Board:HookScript("OnShow", reskinMissionBoards)

    -- Addon supports

    local function reskinWidgetFont(font, r, g, b)
        if font and font.SetTextColor then font:SetTextColor(r, g, b) end
    end

    -- WarPlan
    if IsAddOnLoaded("WarPlan") then
        local function reskinWarPlanMissions(self)
            local missions = self.TaskBoard.Missions
            for i = 1, #missions do
                local button = missions[i]
                if not button.__styled then
                    reskinWidgetFont(button.XPReward, 1, 1, 1)
                    reskinWidgetFont(button.Description, 0.8, 0.8, 0.8)
                    reskinWidgetFont(button.CDTDisplay, 1, 1, 1)

                    local groups = button.Groups
                    if groups then
                        for j = 1, #groups do
                            local group = groups[j]
                            S:Reskin(group)
                            reskinWidgetFont(group.Features, 1, 0.8, 0)
                        end
                    end

                    button.__styled = true
                end
            end
        end

        C_Timer.After(0.1, function()
            local WarPlanFrame = _G.WarPlanFrame
            if not WarPlanFrame then return end

            WarPlanFrame:StripTextures()
            S:SetBD(WarPlanFrame)
            WarPlanFrame.ArtFrame:StripTextures()
            S:ReskinClose(WarPlanFrame.ArtFrame.CloseButton)
            reskinWidgetFont(WarPlanFrame.ArtFrame.TitleText, 1, 0.8, 0)

            reskinWarPlanMissions(WarPlanFrame)
            WarPlanFrame:HookScript("OnShow", reskinWarPlanMissions)
            S:Reskin(WarPlanFrame.TaskBoard.AllPurposeButton)

            local entries = WarPlanFrame.HistoryFrame.Entries
            for i = 1, #entries do
                local entry = entries[i]
                entry:DisableDrawLayer("BACKGROUND")
                S:ReskinIcon(entry.Icon)
                entry.Name:SetFontObject("Number12Font")
                entry.Detail:SetFontObject("Number12Font")
            end
        end)
    end

    -- VenturePlan (4.30+)
    if IsAddOnLoaded("VenturePlan") then
        local ANIMA_TEXTURE = 3528288
        local ANIMA_SPELLID = { [347555] = 3, [345706] = 5, [336327] = 35, [336456] = 250 }
        local function getAnimaMultiplier(itemID)
            if not itemID then return end
            local _, spellID = C_Item.GetItemSpell(itemID)
            return ANIMA_SPELLID[spellID]
        end
        local function setAnimaActualCount(self, text)
            local mult = getAnimaMultiplier(self.__owner.itemID)
            if mult then
                if text == "" then text = 1 end
                text = text * mult
                self:SetFormattedText("%s", text)
                self.__owner.Icon:SetTexture(ANIMA_TEXTURE)
            end
        end
        local function adjustFollowerList(self)
            if self.isSetting then return end
            self.isSetting = true

            local numFollowers = #C_Garrison.GetFollowers(123)
            self:SetHeight(135 + 60 * ceil(numFollowers / 5))

            self.isSetting = nil
        end

        local ReplacedRoleTex = {
            ["adventures-tank"] = "Soulbinds_Tree_Conduit_Icon_Protect",
            ["adventures-healer"] = "ui_adv_health",
            ["adventures-dps"] = "ui_adv_atk",
            ["adventures-dps-ranged"] = "Soulbinds_Tree_Conduit_Icon_Utility",
        }
        local function replaceFollowerRole(roleIcon, atlas)
            local newAtlas = ReplacedRoleTex[atlas]
            if newAtlas then roleIcon:SetAtlas(newAtlas) end
        end

        local function updateSelectedBorder(portrait, show)
            if show then
                portrait.__owner.bg:SetBackdropBorderColor(0.6, 0, 0)
            else
                portrait.__owner.bg:SetBackdropBorderColor(0, 0, 0)
            end
        end

        local function updateActiveGlow(border, show) border.__shadow:SetShown(show) end

        local abilityIndex1, abilityIndex2
        local function getAbilitiesIndex(frame)
            if not abilityIndex1 then
                for i = 1, frame:GetNumRegions() do
                    local region = select(i, frame:GetRegions())
                    if region then
                        local width, height = region:GetSize()
                        if floor(width + 0.5) == 17 and floor(height + 0.5) == 17 then
                            if abilityIndex1 then
                                abilityIndex2 = i
                            else
                                abilityIndex1 = i
                            end
                        end
                    end
                end
            end
            return abilityIndex1, abilityIndex2
        end

        local function reskinFollowerAbility(frame, index, first)
            local ability = select(index, frame:GetRegions())
            ability:SetMask("")
            ability:SetSize(14, 14)
            ability.bg = S:ReskinIcon(ability)
            ability.bg:SetFrameLevel(4)
            tinsert(frame.__abilities, ability)
            select(2, ability:GetPoint()):SetAlpha(0)
            ability:SetPoint("CENTER", frame, "LEFT", 11, first and 15 or 0)
        end

        local function updateVisibleAbilities(self)
            local showHealth = self.__owner.__health:IsShown()
            for _, ability in pairs(self.__owner.__abilities) do
                ability:SetDesaturated(not showHealth)
                ability.bg:SetShown(ability:IsShown())
            end
            self.__owner.__role:SetDesaturated(not showHealth)
        end

        local function fixAnchorForModVP(self, _, x, y)
            if x == 5 and y == -18 then self:SetPoint("CENTER", self.__owner, 1, 0) end
        end

        local VPFollowers, VPTroops, VPBooks, numButtons = {}, {}, {}, 0
        function VPEX_OnUIObjectCreated(otype, widget, peek)
            if widget:IsObjectType("Frame") then
                if otype == "MissionButton" then
                    S:Reskin(peek("ViewButton"))
                    S:Reskin(peek("DoomRunButton"))
                    S:Reskin(peek("TentativeClear"))
                    if peek("GroupHints") then S:Reskin(peek("GroupHints")) end
                    reskinWidgetFont(peek("Description"), 0.8, 0.8, 0.8)
                    reskinWidgetFont(peek("enemyHP"), 1, 1, 1)
                    reskinWidgetFont(peek("enemyATK"), 1, 1, 1)
                    reskinWidgetFont(peek("animaCost"), 0.6, 0.8, 1)
                    reskinWidgetFont(peek("duration"), 1, 0.8, 0)
                    reskinWidgetFont(widget.CDTDisplay:GetFontString(), 1, 0.8, 0)
                elseif otype == "CopyBoxUI" then
                    S:Reskin(widget.ResetButton)
                    S:ReskinClose(widget.CloseButton2)
                    reskinWidgetFont(widget.Intro, 1, 1, 1)
                    S:ReskinEditBox(widget.FirstInputBox)
                    reskinWidgetFont(widget.FirstInputBoxLabel, 1, 0.8, 0)
                    S:ReskinEditBox(widget.SecondInputBox)
                    reskinWidgetFont(widget.SecondInputBoxLabel, 1, 0.8, 0)
                    reskinWidgetFont(widget.VersionText, 1, 1, 1)
                elseif otype == "MissionList" then
                    widget:StripTextures()
                    local background = widget:GetChildren()
                    background:StripTextures()
                    background:CreateBackdrop()
                elseif otype == "MissionPage" then
                    widget:StripTextures()
                    S:Reskin(peek("UnButton"))
                    S:Reskin(peek("StartButton"))
                    peek("StartButton"):SetText("|T" .. DB.ArrowUp .. ":16|t")
                elseif otype == "ILButton" then
                    widget:DisableDrawLayer("BACKGROUND")
                    local bg = widget:CreateBackdrop()
                    bg:SetPoint("TOPLEFT", -3, 1)
                    bg:SetPoint("BOTTOMRIGHT", 2, -2)
                    widget.Icon:CreateBackdrop():SetBackdropEdge("round")
                elseif otype == "IconButton" then
                    S:ReskinIcon(widget.Icon)
                    widget:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                    widget:SetPushedTexture(0)
                    widget:SetSize(46, 46)
                    tinsert(VPBooks, widget)
                elseif otype == "AdventurerRoster" then
                    widget:StripTextures()
                    widget:CreateBackdrop()
                    hooksecurefunc(widget, "SetHeight", adjustFollowerList)
                    S:Reskin(peek("HealAllButton"))

                    for i, troop in pairs(VPTroops) do
                        troop:ClearAllPoints()
                        troop:SetPoint("TOPLEFT", (i - 1) * 60 + 5, -35)
                    end
                    for i, follower in pairs(VPFollowers) do
                        follower:ClearAllPoints()
                        follower:SetPoint("TOPLEFT", ((i - 1) % 5) * 60 + 5, -floor((i - 1) / 5) * 60 - 130)
                    end
                    for i, book in pairs(VPBooks) do
                        book:ClearAllPoints()
                        book:SetPoint("BOTTOMLEFT", 24, -46 + i * 50)
                    end
                elseif otype == "AdventurerListButton" then
                    widget.bg = peek("Portrait"):CreateBackdrop()
                    peek("Hi"):SetColorTexture(1, 1, 1, 0.25)
                    peek("Hi"):SetInside(widget.bg)
                    peek("PortraitR"):Hide()
                    peek("PortraitT"):SetTexture(nil)
                    peek("PortraitT").__owner = widget
                    hooksecurefunc(peek("PortraitT"), "SetShown", updateSelectedBorder)

                    numButtons = numButtons + 1
                    if numButtons > 2 then
                        peek("UsedBorder"):SetTexture(nil)
                        peek("UsedBorder").__shadow = peek("Portrait"):CreateShadow(5, true)
                        peek("UsedBorder").__shadow:SetBackdropBorderColor(peek("UsedBorder"):GetVertexColor())
                        hooksecurefunc(peek("UsedBorder"), "SetShown", updateActiveGlow)
                        tinsert(VPFollowers, widget)
                    else
                        tinsert(VPTroops, widget)
                    end

                    peek("HealthBG"):ClearAllPoints()
                    peek("HealthBG"):SetPoint("TOPLEFT", peek("Portrait"), "BOTTOMLEFT", 0, 10)
                    peek("HealthBG"):SetPoint("BOTTOMRIGHT", peek("Portrait"), "BOTTOMRIGHT")
                    local line = widget:CreateTexture(nil, "ARTWORK")
                    line:SetColorTexture(0, 0, 0)
                    line:SetSize(peek("HealthBG"):GetWidth(), E.mult)
                    line:SetPoint("BOTTOM", peek("HealthBG"), "TOP")

                    peek("Health"):SetHeight(10)
                    peek("HealthFrameR"):Hide()
                    peek("TextLabel"):SetFontObject("Game12Font")
                    peek("TextLabel"):ClearAllPoints()
                    peek("TextLabel"):SetPoint("CENTER", peek("HealthBG"), 1, 0)
                    peek("TextLabel").__owner = peek("HealthBG")
                    hooksecurefunc(peek("TextLabel"), "SetPoint", fixAnchorForModVP)

                    peek("Favorite"):ClearAllPoints()
                    peek("Favorite"):SetPoint("TOPLEFT", -2, 2)
                    peek("Favorite"):SetSize(30, 30)
                    peek("Blip"):SetSize(18, 20)
                    peek("Blip"):SetPoint("BOTTOMRIGHT", -8, 12)
                    peek("RoleB"):Hide()
                    peek("Role"):ClearAllPoints()
                    peek("Role"):SetPoint("CENTER", widget.bg, "TOPRIGHT", -2, -2)
                    hooksecurefunc(peek("Role"), "SetAtlas", replaceFollowerRole)

                    local frame = peek("Health"):GetParent()
                    if frame then
                        frame.__abilities = {}
                        frame.__health = peek("Health")
                        frame.__role = peek("Role")
                        local index1, index2 = getAbilitiesIndex(frame)
                        reskinFollowerAbility(frame, index1, true)
                        reskinFollowerAbility(frame, index2)
                        peek("HealthBG").__owner = frame
                        hooksecurefunc(peek("HealthBG"), "SetGradient", updateVisibleAbilities)
                    end
                elseif otype == "ProgressBar" then
                    widget:StripTextures()
                    widget:CreateBackdrop()
                elseif otype == "MissionToast" then
                    S:SetBD(widget)
                    if widget.Background then widget.Background:Hide() end
                    if widget.Detail then widget.Detail:SetFontObject("Game13Font") end
                elseif otype == "RewardFrame" then
                    widget.Quantity.__owner = widget
                    hooksecurefunc(widget.Quantity, "SetText", setAnimaActualCount)
                elseif otype == "MiniHealthBar" then
                    local _, r1, r2 = widget:GetRegions()
                    r1:Hide()
                    r2:Hide()
                end
            end
        end
    end
end

S:AddCallbackForAddon("Blizzard_GarrisonUI", "Garrison")

------------------------------------------------------------------------
-- OrderHall Talent Frame (separate addon registration)
------------------------------------------------------------------------

local atlasToColor = {
    ["none"] = { 0, 0, 0 },
    ["orderhalltalents-spellborder"] = { 0, 0, 0 },
    ["orderhalltalents-spellborder-green"] = { 0.08, 0.7, 0 },
    ["orderhalltalents-spellborder-yellow"] = { 1, 0.8, 0 },
}

local function updateTalentBorder(bu, atlas)
    if not bu.bg then return end

    local color = atlasToColor[atlas] or atlasToColor["none"]
    if color then bu.bg:SetBackdropBorderColor(color[1], color[2], color[3]) end
end

function S:OrderHallUI()
    if not (C.skins.enable and C.skins.garrison) then return end

    local OrderHallTalentFrame = _G.OrderHallTalentFrame

    S:ReskinPortraitFrame(OrderHallTalentFrame)
    S:Reskin(OrderHallTalentFrame.BackButton)
    S:ReskinIcon(OrderHallTalentFrame.Currency.Icon)
    OrderHallTalentFrame.OverlayElements:SetAlpha(0)

    hooksecurefunc(OrderHallTalentFrame, "RefreshAllData", function(self)
        if self.CloseButton.Border then self.CloseButton.Border:SetAlpha(0) end
        if self.CurrencyBG then self.CurrencyBG:SetAlpha(0) end
        self:StripTextures()

        if self.buttonPool then
            for bu in self.buttonPool:EnumerateActive() do
                bu.Border:SetAlpha(0)

                if not bu.bg then
                    bu.Highlight:SetColorTexture(1, 1, 1, 0.25)
                    bu.bg = S:ReskinIcon(bu.Icon)

                    updateTalentBorder(bu, bu.Border:GetAtlas())
                    hooksecurefunc(bu, "SetBorder", updateTalentBorder)
                end
            end
        end

        if self.talentRankPool then
            for rank in self.talentRankPool:EnumerateActive() do
                if not rank.__styled then
                    rank.Background:SetAlpha(0)
                    rank.__styled = true
                end
            end
        end
    end)
end

S:AddCallbackForAddon("Blizzard_OrderHallUI", "OrderHallUI")
