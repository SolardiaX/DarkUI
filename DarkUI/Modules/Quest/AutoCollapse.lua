local E, C, L = select(2, ...):unpack()

if not C.quest.enable and not C.quest.auto_collapse then return end

----------------------------------------------------------------------------------------
--	Auto collapse ObjectiveTrackerFrame in instance
----------------------------------------------------------------------------------------
local module = E:Module("Quest"):Sub("AutoCollapse")

local IsInInstance, InCombatLockdown = IsInInstance, InCombatLockdown
local ObjectiveTracker_Collapse, ObjectiveTracker_Expand = ObjectiveTracker_Collapse, ObjectiveTracker_Expand
local ObjectiveTrackerFrame = ObjectiveTrackerFrame

module:RegisterEvent("PLAYER_ENTERING_WORLD", function()
	if IsInInstance() then
		ObjectiveTracker_Collapse()
	elseif ObjectiveTrackerFrame.collapsed and not InCombatLockdown() then
		ObjectiveTracker_Expand()
	end
end)
