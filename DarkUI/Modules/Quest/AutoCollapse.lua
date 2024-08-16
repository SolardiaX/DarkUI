local E, C, L = select(2, ...):unpack()

if not C.quest.enable and not C.quest.auto_collapse then return end

----------------------------------------------------------------------------------------
--	Auto collapse ObjectiveTrackerFrame in instance
----------------------------------------------------------------------------------------
local module = E:Module("Quest"):Sub("AutoCollapse")

local headers = {
	CampaignQuestObjectiveTracker,
	QuestObjectiveTracker,
	AdventureObjectiveTracker,
	AchievementObjectiveTracker,
	MonthlyActivitiesObjectiveTracker,
	ProfessionsRecipeTracker,
	WorldQuestObjectiveTracker,
}

module:RegisterEvent("PLAYER_ENTERING_WORLD", function()
    local inInstance, instanceType = IsInInstance()

    if inInstance then
        if instanceType == "party" or instanceType == "scenario" then
            if instanceType == "party" or instanceType == "scenario" then
                C_Timer.After(0.1, function() -- for some reason it got error after reload in instance
                    for i = 1, #headers do
                        headers[i]:SetCollapsed(true)
                    end
                end)
            else
                C_Timer.After(0.1, function()
                    ObjectiveTrackerFrame:SetCollapsed(true)
                end)
            end
        end
    elseif not InCombatLockdown() then
        for i = 1, #headers do
            if headers[i].isCollapsed then
                headers[i]:SetCollapsed(false)
            end
        end
        if ObjectiveTrackerFrame.collapsed then
            ObjectiveTrackerFrame:SetCollapsed(false)
        end
    end
end)
