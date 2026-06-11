local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Raid Utility
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("RaidUtility")

local cfg = C.misc.raid_utility

local format = format
local InCombatLockdown = InCombatLockdown
local GetNumGroupMembers = GetNumGroupMembers
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsGroupAssistant = UnitIsGroupAssistant
local UnitInRaid = UnitInRaid
local IsInInstance = IsInInstance
local IsInRaid = IsInRaid
local DoReadyCheck = DoReadyCheck
local InitiateRolePoll = InitiateRolePoll
local GetRaidRosterInfo = GetRaidRosterInfo
local GetReadyCheckStatus = GetReadyCheckStatus
local GetInstanceInfo = GetInstanceInfo

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local function checkRaidStatus()
    local _, instanceType = IsInInstance()
    if instanceType == "pvp" or instanceType == "arena" then return false end
    if GetNumGroupMembers() > 0 and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
        return true
    end
    return false
end

local function createButton(name, parent, template, width, height, text)
    local b = CreateFrame("Button", name, parent, template)
    b:SetSize(width, height)
    b:EnableMouse(true)
    if text then
        local fs = b:CreateFontString(nil, "OVERLAY")
        fs:SetFont(C.media.standard_font[1], 11, "OUTLINE")
        fs:SetPoint("CENTER")
        fs:SetText(text)
        b.text = fs
    end
    return b
end

------------------------------------------------------------------------
-- Panel
------------------------------------------------------------------------

local panel, showButton

local function getMaxGroup()
    local _, instType, difficulty = GetInstanceInfo()
    if (instType == "party" or instType == "scenario") and not IsInRaid() then
        return 1
    elseif instType ~= "raid" then
        return 8
    elseif difficulty == 8 or difficulty == 1 or difficulty == 2 then
        return 1
    elseif difficulty == 14 or difficulty == 15 then
        return 6
    elseif difficulty == 16 then
        return 4
    elseif difficulty == 3 or difficulty == 5 then
        return 2
    elseif difficulty == 9 then
        return 8
    else
        return 5
    end
end

local function toggleVisibility()
    if InCombatLockdown() then return end

    if checkRaidStatus() then
        if panel.toggled then
            showButton:Hide()
            panel:Show()
        else
            showButton:Show()
            panel:Hide()
        end
    else
        showButton:Hide()
        panel:Hide()
    end
end

------------------------------------------------------------------------
-- Disband confirmation
------------------------------------------------------------------------

StaticPopupDialogs["DARKUI_DISBAND_RAID"] = {
    text = L.MISC_RAID_UTIL_DISBAND .. "?",
    button1 = ACCEPT,
    button2 = CANCEL,
    OnAccept = function()
        if InCombatLockdown() then return end
        local numGroup = GetNumGroupMembers()
        if numGroup > 0 then
            for i = 1, numGroup do
                local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
                if online and name ~= E.myName then
                    UninviteUnit(name)
                end
            end
        end
        C_PartyInfo.LeaveParty()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

------------------------------------------------------------------------

function module:OnInit()
    if not cfg.enable then return end

    local pos = cfg.position
    local panelWidth = 170
    local panelHeight = 130
    local btnWidth = panelWidth * 0.8
    local btnHeight = 18

    -- Main panel
    panel = CreateFrame("Frame", "DarkUI_RaidUtilityPanel", E.PetBattleFrameHider, "BackdropTemplate")
    panel:SetSize(panelWidth, panelHeight)
    panel:SetPoint(unpack(pos))
    panel:SetTemplate("Default")
    panel:SetFrameStrata("HIGH")
    panel:SetFrameLevel(9)
    panel:Hide()
    panel.toggled = false

    -- Show button (toggle)
    showButton = createButton("DarkUI_RaidUtilityShow", E.PetBattleFrameHider, "UIPanelButtonTemplate, SecureHandlerClickTemplate", panelWidth / 1.5, btnHeight, RAID_CONTROL)
    showButton:SetPoint("TOP", panel, "TOP", 0, 0)
    showButton:SetFrameRef("panel", panel)
    showButton:SetAttribute("_onclick", [=[self:Hide(); self:GetFrameRef("panel"):Show();]=])
    showButton:RegisterForClicks("AnyUp")
    showButton:SetScript("OnMouseUp", function(_, button)
        if button == "RightButton" then
            if checkRaidStatus() then DoReadyCheck() end
        elseif button == "MiddleButton" then
            if checkRaidStatus() then InitiateRolePoll() end
        elseif button == "LeftButton" then
            panel.toggled = true
        end
    end)

    -- Close button
    local closeBtn = createButton(nil, panel, "UIPanelButtonTemplate, SecureHandlerClickTemplate", panelWidth / 1.5, btnHeight, CLOSE)
    closeBtn:SetPoint("TOP", panel, "BOTTOM", 0, -1)
    closeBtn:SetFrameRef("show", showButton)
    closeBtn:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("show"):Show();]=])
    closeBtn:SetScript("OnMouseUp", function() panel.toggled = false end)

    -- Disband
    local disbandBtn = createButton(nil, panel, "UIPanelButtonTemplate", btnWidth, btnHeight, L.MISC_RAID_UTIL_DISBAND)
    disbandBtn:SetPoint("TOP", panel, "TOP", 0, -8)
    disbandBtn:SetScript("OnClick", function() StaticPopup_Show("DARKUI_DISBAND_RAID") end)

    -- Convert
    local convertBtn = createButton(nil, panel, "UIPanelButtonTemplate", btnWidth, btnHeight, UnitInRaid("player") and CONVERT_TO_PARTY or CONVERT_TO_RAID)
    convertBtn:SetPoint("TOP", disbandBtn, "BOTTOM", 0, -5)
    convertBtn:SetScript("OnClick", function()
        if UnitInRaid("player") then
            C_PartyInfo.ConvertToParty()
            convertBtn.text:SetText(CONVERT_TO_RAID)
        elseif IsInGroup() then
            C_PartyInfo.ConvertToRaid()
            convertBtn.text:SetText(CONVERT_TO_PARTY)
        end
    end)

    -- Role poll
    local roleBtn = createButton(nil, panel, "UIPanelButtonTemplate", btnWidth, btnHeight, ROLE_POLL)
    roleBtn:SetPoint("TOP", convertBtn, "BOTTOM", 0, -5)
    roleBtn:SetScript("OnClick", function() InitiateRolePoll() end)

    -- Main Tank / Main Assist
    local halfWidth = (btnWidth / 2) - 2
    local tankBtn = createButton(nil, panel, "UIPanelButtonTemplate, SecureActionButtonTemplate", halfWidth, btnHeight, TANK)
    tankBtn:SetPoint("TOPLEFT", roleBtn, "BOTTOMLEFT", 0, -5)
    tankBtn:SetAttribute("type", "maintank")
    tankBtn:SetAttribute("unit", "target")
    tankBtn:SetAttribute("action", "toggle")

    local assistBtn = createButton(nil, panel, "UIPanelButtonTemplate, SecureActionButtonTemplate", halfWidth, btnHeight, MAINASSIST)
    assistBtn:SetPoint("TOPRIGHT", roleBtn, "BOTTOMRIGHT", 0, -5)
    assistBtn:SetAttribute("type", "mainassist")
    assistBtn:SetAttribute("unit", "target")
    assistBtn:SetAttribute("action", "toggle")

    -- Ready check
    local readyBtn = createButton(nil, panel, "UIPanelButtonTemplate", btnWidth * 0.75, btnHeight, READY_CHECK)
    readyBtn:SetPoint("TOPLEFT", tankBtn, "BOTTOMLEFT", 0, -5)
    readyBtn:SetScript("OnClick", function() DoReadyCheck() end)

    -- World markers
    local markerBtn = createButton(nil, panel, "UIPanelButtonTemplate, SecureHandlerClickTemplate", btnHeight, btnHeight)
    markerBtn:SetPoint("TOPRIGHT", assistBtn, "BOTTOMRIGHT", 0, -5)
    local markTex = markerBtn:CreateTexture(nil, "OVERLAY")
    markTex:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")
    markTex:SetPoint("CENTER")
    markTex:SetSize(14, 14)

    local markersFrame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    markersFrame:SetSize(24, 220)
    markersFrame:SetPoint("TOPLEFT", panel, "TOPRIGHT", 2, 0)
    markersFrame:SetTemplate("Default")
    markersFrame:Hide()

    markerBtn:RegisterForClicks("AnyUp")
    markerBtn:SetFrameRef("markers", markersFrame)
    markerBtn:SetAttribute("_onclick", [=[
        local f = self:GetFrameRef("markers")
        if f:IsShown() then f:Hide() else f:Show() end
    ]=])

    local ground = { 5, 6, 3, 2, 7, 1, 4, 8 }
    local iconTexture = {
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_1",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_2",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_3",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_4",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_5",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_6",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_7",
        "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8",
        "Interface\\Buttons\\UI-GroupLoot-Pass-Up",
    }

    local prev
    for i = 1, 9 do
        local b = CreateFrame("Button", nil, markersFrame, "SecureActionButtonTemplate")
        b:SetSize(18, 18)
        if i == 1 then
            b:SetPoint("TOP", markersFrame, "TOP", 0, -4)
        else
            b:SetPoint("TOP", prev, "BOTTOM", 0, -4)
        end
        b:SetNormalTexture(iconTexture[i])
        b:RegisterForClicks("AnyUp", "AnyDown")
        b:SetAttribute("type", "macro")
        b:SetAttribute("macrotext", i == 9 and "/cwm 0" or format("/cwm %d\n/wm %d", ground[i], ground[i]))
        prev = b
    end

    -- Raid control (open social frame)
    local controlBtn = createButton(nil, panel, "UIPanelButtonTemplate", btnWidth, btnHeight, RAID_CONTROL)
    controlBtn:SetPoint("TOPLEFT", readyBtn, "BOTTOMLEFT", 0, -5)
    controlBtn:SetScript("OnClick", function() ToggleFriendsFrame(3) end)

    -- Visibility driver
    self:RegisterEvent("PLAYER_ENTERING_WORLD", toggleVisibility)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", toggleVisibility)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", toggleVisibility)
end
