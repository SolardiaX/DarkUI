local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Collapse
------------------------------------------------------------------------

local module = E:Module("Quest"):Sub("AutoCollapse")

local cfg = C.quest

local headers = {
    ScenarioObjectiveTracker,
    BonusObjectiveTracker,
    UIWidgetObjectiveTracker,
    CampaignQuestObjectiveTracker,
    QuestObjectiveTracker,
    AdventureObjectiveTracker,
    AchievementObjectiveTracker,
    MonthlyActivitiesObjectiveTracker,
    ProfessionsRecipeTracker,
    WorldQuestObjectiveTracker,
}

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end
    if not cfg.auto_collapse or cfg.auto_collapse == "NONE" then return end

    local mode = cfg.auto_collapse
    local wasCollapsed = false

    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        local inInstance, instanceType = IsInInstance()

        if mode == "RAID" or mode == true then
            if inInstance then
                C_Timer.After(0.1, function()
                    ObjectiveTrackerFrame:SetCollapsed(true)
                end)
            elseif not InCombatLockdown() then
                if ObjectiveTrackerFrame.isCollapsed then
                    ObjectiveTrackerFrame:SetCollapsed(false)
                end
            end
        elseif mode == "SCENARIO" then
            if inInstance then
                if instanceType == "party" or instanceType == "scenario" then
                    C_Timer.After(0.1, function()
                        for i = 1, #headers do
                            if headers[i] and headers[i].SetCollapsed then
                                headers[i]:SetCollapsed(true)
                            end
                        end
                    end)
                else
                    C_Timer.After(0.1, function()
                        ObjectiveTrackerFrame:SetCollapsed(true)
                    end)
                end
            elseif not InCombatLockdown() then
                for i = 1, #headers do
                    if headers[i] and headers[i].isCollapsed then
                        headers[i]:SetCollapsed(false)
                    end
                end
                if ObjectiveTrackerFrame.isCollapsed then
                    ObjectiveTrackerFrame:SetCollapsed(false)
                end
            end
        elseif mode == "RELOAD" then
            C_Timer.After(0.1, function()
                ObjectiveTrackerFrame:SetCollapsed(true)
            end)
        end
    end)

    self:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        local inInstance, instanceType = IsInInstance()
        local shouldCollapse = false

        if mode == true or mode == "RAID" then
            shouldCollapse = inInstance and (instanceType == "raid" or instanceType == "party")
        elseif mode == "SCENARIO" then
            shouldCollapse = inInstance
        elseif mode == "RELOAD" then
            shouldCollapse = true
        end

        if shouldCollapse and not ObjectiveTrackerFrame:IsCollapsed() then
            wasCollapsed = false
            ObjectiveTrackerFrame:SetCollapsed(true)
        else
            wasCollapsed = ObjectiveTrackerFrame:IsCollapsed()
        end
    end)

    self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        if not wasCollapsed and ObjectiveTrackerFrame:IsCollapsed() then
            ObjectiveTrackerFrame:SetCollapsed(false)
        end
    end)
end
