﻿local E, C, L = select(2, ...):unpack()

if not C.quest.enable and not C.quest.auto_collapse then return end

----------------------------------------------------------------------------------------
--	Auto collapse ObjectiveTrackerFrame in instance
----------------------------------------------------------------------------------------
local CreateFrame = CreateFrame
local IsInInstance, InCombatLockdown = IsInInstance, InCombatLockdown
local ObjectiveTracker_Collapse, ObjectiveTracker_Expand = ObjectiveTracker_Collapse, ObjectiveTracker_Expand
local ObjectiveTrackerFrame = ObjectiveTrackerFrame

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	if IsInInstance() then
		ObjectiveTracker_Collapse()
	elseif ObjectiveTrackerFrame.collapsed and not InCombatLockdown() then
		ObjectiveTracker_Expand()
	end
end)
