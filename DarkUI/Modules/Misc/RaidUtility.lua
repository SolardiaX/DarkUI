﻿local E, C, L = select(2, ...):unpack()

if not C.misc.raid_utility.enable then return end

----------------------------------------------------------------------------------------
--	Raid Utility(by Elv22)
----------------------------------------------------------------------------------------

local position = C.misc.raid_utility.position

-- Create main frame

local RaidUtilityPanel = CreateFrame("Frame", "RaidUtilityPanel", T_PetBattleFrameHider)
RaidUtilityPanel:CreatePanel("Default", 170, 145, unpack(position))
RaidUtilityPanel:SetFrameStrata("HIGH")
RaidUtilityPanel:SetFrameLevel(9)
if GetCVarBool("watchFrameWidth") then
    RaidUtilityPanel:SetPoint(position[1], position[2], position[3], position[4] + 100, position[5])
end
RaidUtilityPanel.toggled = false

-- Check if We are Raid Leader or Raid Officer
local function CheckRaidStatus()
    local _, instanceType = IsInInstance()
    if ((GetNumGroupMembers() > 0 and UnitIsGroupLeader("player") and not UnitInRaid("player")) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) and (instanceType ~= "pvp" or instanceType ~= "arena") then
        return true
    else
        return false
    end
end

-- Function to create buttons in this module
local function CreateButton(name, parent, template, width, height, point, relativeto, point2, xOfs, yOfs, text)
    local b = CreateFrame("Button", name, parent, template)
    b:SetWidth(width)
    b:SetHeight(height)
    b:SetPoint(point, relativeto, point2, xOfs, yOfs)
    b:EnableMouse(true)
    if text then
        b.t = b:CreateFontString(nil, "OVERLAY")
        b.t:SetFont(unpack(C.media.standard_font))
        b.t:SetPoint("CENTER")
        b.t:SetJustifyH("CENTER")
        b.t:SetText(text)
    end
end

-- Show button
CreateButton("RaidUtilityShowButton", T_PetBattleFrameHider, "UIPanelButtonTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth() / 1.5, 18, "TOP", RaidUtilityPanel, "TOP", 0, 0, RAID_CONTROL)
RaidUtilityShowButton:SetFrameRef("RaidUtilityPanel", RaidUtilityPanel)
RaidUtilityShowButton:SetAttribute("_onclick", [=[self:Hide(); self:GetFrameRef("RaidUtilityPanel"):Show();]=])
RaidUtilityShowButton:SetScript("OnMouseUp", function(_, button)
    if button == "RightButton" then
        if CheckRaidStatus() then
            DoReadyCheck()
        end
    elseif button == "MiddleButton" then
        if CheckRaidStatus() then
            InitiateRolePoll()
        end
    elseif button == "LeftButton" then
        RaidUtilityPanel.toggled = true
    end
end)

-- Close button
CreateButton("RaidUtilityCloseButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureHandlerClickTemplate", RaidUtilityPanel:GetWidth() / 1.5, 18, "TOP", RaidUtilityPanel, "BOTTOM", 0, -1, CLOSE)
RaidUtilityCloseButton:SetFrameRef("RaidUtilityShowButton", RaidUtilityShowButton)
RaidUtilityCloseButton:SetAttribute("_onclick", [=[self:GetParent():Hide(); self:GetFrameRef("RaidUtilityShowButton"):Show();]=])
RaidUtilityCloseButton:SetScript("OnMouseUp", function() RaidUtilityPanel.toggled = false end)

-- Disband Group button
CreateButton("RaidUtilityDisbandButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityPanel, "TOP", 0, -5, L_RAID_UTIL_DISBAND)
RaidUtilityDisbandButton:SetScript("OnMouseUp", function() StaticPopup_Show("DISBAND_RAID") end)

-- Convert Group button
CreateButton("RaidUtilityConvertButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityDisbandButton, "BOTTOM", 0, -5, UnitInRaid("player") and CONVERT_TO_PARTY or CONVERT_TO_RAID)
RaidUtilityConvertButton:SetScript("OnMouseUp", function()
    if UnitInRaid("player") then
    	C_PartyInfo.ConvertToParty()
        RaidUtilityConvertButton.t:SetText(CONVERT_TO_RAID)
    elseif UnitInParty("player") then
    	C_PartyInfo.ConvertToRaid()
        RaidUtilityConvertButton.t:SetText(CONVERT_TO_PARTY)
    end
end)

-- Role Check button
CreateButton("RaidUtilityRoleButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityPanel:GetWidth() * 0.8, 18, "TOP", RaidUtilityConvertButton, "BOTTOM", 0, -5, ROLE_POLL)
RaidUtilityRoleButton:SetScript("OnMouseUp", function() InitiateRolePoll() end)

-- MainTank button
CreateButton("RaidUtilityMainTankButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureActionButtonTemplate", (RaidUtilityDisbandButton:GetWidth() / 2) - 2, 18, "TOPLEFT", RaidUtilityRoleButton, "BOTTOMLEFT", 0, -5, TANK)
RaidUtilityMainTankButton:SetAttribute("type", "maintank")
RaidUtilityMainTankButton:SetAttribute("unit", "target")
RaidUtilityMainTankButton:SetAttribute("action", "toggle")

-- MainAssist button
CreateButton("RaidUtilityMainAssistButton", RaidUtilityPanel, "UIPanelButtonTemplate, SecureActionButtonTemplate", (RaidUtilityDisbandButton:GetWidth() / 2) - 2, 18, "TOPRIGHT", RaidUtilityRoleButton, "BOTTOMRIGHT", 0, -5, MAINASSIST)
RaidUtilityMainAssistButton:SetAttribute("type", "mainassist")
RaidUtilityMainAssistButton:SetAttribute("unit", "target")
RaidUtilityMainAssistButton:SetAttribute("action", "toggle")

-- Ready Check button
CreateButton("RaidUtilityReadyCheckButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityRoleButton:GetWidth() * 0.75, 18, "TOPLEFT", RaidUtilityMainTankButton, "BOTTOMLEFT", 0, -5, READY_CHECK)
RaidUtilityReadyCheckButton:SetScript("OnMouseUp", function() DoReadyCheck() end)

-- World Marker button
CreateButton("RaidUtilityMarkerToggle", RaidUtilityPanel, "UIPanelButtonTemplate", 18, 18, "TOPRIGHT", RaidUtilityMainAssistButton, "BOTTOMRIGHT", 0, -5)

local MarkTexture = RaidUtilityMarkerToggle:CreateTexture(nil, "OVERLAY")
MarkTexture:SetTexture("Interface\\RaidFrame\\Raid-WorldPing")
MarkTexture:SetPoint("CENTER", 0, -1)

local markersFrame = CreateFrame("Frame", "RaidUtilityPanelmarkers", RaidUtilityPanel)
markersFrame:SetSize(100, 200)
markersFrame:SetPoint("TOPLEFT", RaidUtilityMarkerToggle, "TOPRIGHT")
markersFrame:Hide()
RaidUtilityMarkerToggle:SetScript("OnMouseUp", function() markersFrame:SetShown(not markersFrame:IsShown()) end)
local ground = {5, 6, 3, 2, 7, 1, 4, 8}
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
	local b = CreateFrame("Button", "RaidUtilityPanelRaidMarkers", markersFrame, "SecureActionButtonTemplate")
	b:ClearAllPoints()
	if i == 1 then
		b:SetPoint("TOPLEFT", RaidUtilityPanel, "TOPRIGHT", 5, -3)
	else
		b:SetPoint("TOP", prev, "BOTTOM", 0, -5)
	end
	b:SetSize(13, 13)
	b:CreateBackdrop("Overlay")
	b:SetNormalTexture(iconTexture[i])
	b:RegisterForClicks("AnyUp", "AnyDown")
	b:SetAttribute("type", "macro")
	b:SetAttribute("macrotext", format(i == 9 and "/cwm 0" or "/cwm %d\n/wm %d", ground[i], ground[i]))
	prev = b
end
-- Raid Control Panel
CreateButton("RaidUtilityRaidControlButton", RaidUtilityPanel, "UIPanelButtonTemplate", RaidUtilityRoleButton:GetWidth(), 18, "TOPLEFT", RaidUtilityReadyCheckButton, "BOTTOMLEFT", 0, -5, RAID_CONTROL)
RaidUtilityRaidControlButton:SetScript("OnMouseUp", function()
	ToggleFriendsFrame(3)
end)

local function ToggleRaidUtil(self, event)
    if InCombatLockdown() then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        return
    end

    if CheckRaidStatus() then
        if RaidUtilityPanel.toggled == true then
            RaidUtilityShowButton:Hide()
            RaidUtilityPanel:Show()
        else
            RaidUtilityShowButton:Show()
            RaidUtilityPanel:Hide()
        end
    else
        RaidUtilityShowButton:Hide()
        RaidUtilityPanel:Hide()
    end

    if event == "PLAYER_REGEN_ENABLED" then
        self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    end
end

-- Automatically show/hide the frame if we have Raid Leader or Raid Officer
local LeadershipCheck = CreateFrame("Frame")
LeadershipCheck:RegisterEvent("PLAYER_ENTERING_WORLD")
LeadershipCheck:RegisterEvent("GROUP_ROSTER_UPDATE")
LeadershipCheck:SetScript("OnEvent", ToggleRaidUtil)

-- Support Aurora
if C_AddOns.IsAddOnLoaded("Aurora") then
    local F = unpack(Aurora)
    RaidUtilityPanel:SetBackdropColor(0, 0, 0, 0)
    RaidUtilityPanel:SetBackdropBorderColor(0, 0, 0, 0)
    RaidUtilityPanelInnerBorder:SetBackdropBorderColor(0, 0, 0, 0)
    RaidUtilityPanelOuterBorder:SetBackdropBorderColor(0, 0, 0, 0)
    F.CreateBD(RaidUtilityPanel)
end