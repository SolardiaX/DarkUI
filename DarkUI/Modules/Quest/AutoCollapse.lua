local E, C, L = select(2, ...):unpack()

if not C.quest.enable and not C.quest.auto_collapse then return end

----------------------------------------------------------------------------------------
--	Auto collapse ObjectiveTrackerFrame in instance
----------------------------------------------------------------------------------------
local module = E:Module("Quest"):Sub("AutoCollapse")

local IsInInstance, InCombatLockdown = IsInInstance, InCombatLockdown
local ObjectiveTracker_Collapse, ObjectiveTracker_Expand = ObjectiveTracker_Collapse, ObjectiveTracker_Expand
local ObjectiveTrackerFrame = ObjectiveTrackerFrame

local headers = {
	SCENARIO_CONTENT_TRACKER_MODULE,
	BONUS_OBJECTIVE_TRACKER_MODULE,
	UI_WIDGET_TRACKER_MODULE,
	CAMPAIGN_QUEST_TRACKER_MODULE,
	QUEST_TRACKER_MODULE,
	ACHIEVEMENT_TRACKER_MODULE,
	WORLD_QUEST_TRACKER_MODULE,
	PROFESSION_RECIPE_TRACKER_MODULE,
	MONTHLY_ACTIVITIES_TRACKER_MODULE
}

module:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    local inInstance, instanceType = IsInInstance()

    if inInstance then
        if instanceType == "party" or instanceType == "scenario" then
            if instanceType == "party" or instanceType == "scenario" then
                C_Timer.After(0.1, function() -- for some reason it got error after reload in instance
                    for i = 3, #headers do
                        local button = headers[i].Header.MinimizeButton
                        if button and not headers[i].collapsed then
                            button:Click()
                        end
                    end
                end)
            else
                C_Timer.After(0.1, function()
                    ObjectiveTracker_Collapse()
                end)
            end
        end
    elseif not InCombatLockdown() then
        for i = 3, #headers do
            local button = headers[i].Header.MinimizeButton
            if button and headers[i].collapsed then
                button:Click()
            end
        end
        if ObjectiveTrackerFrame.collapsed then
            ObjectiveTracker_Expand()
        end
    end
end)
