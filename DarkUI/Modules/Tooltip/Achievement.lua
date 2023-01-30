local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.achievements ~= true then return end

----------------------------------------------------------------------------------------
-- Your achievement status in tooltip(Enhanced Achievements by Syzgyn)
----------------------------------------------------------------------------------------

local GetAchievementInfo = GetAchievementInfo
local UnitGUID = UnitGUID
local format, find = string.format, string.find
local hooksecurefunc = hooksecurefunc
local ACHIEVEMENT_EARNED_BY = ACHIEVEMENT_EARNED_BY
local ACHIEVEMENT_NOT_COMPLETED_BY = ACHIEVEMENT_NOT_COMPLETED_BY
local ACHIEVEMENT_COMPLETED_BY = ACHIEVEMENT_COMPLETED_BY
local GameTooltip, ItemRefTooltip = GameTooltip, ItemRefTooltip

local function SetHyperlink(tooltip, refString)
    if select(3, find(refString, "(%a-):")) ~= "achievement" then return end

    local _, _, achievementID = find(refString, ":(%d+):")
    local _, _, GUID = find(refString, ":%d+:(.-):")

    if GUID == UnitGUID("player") then
        tooltip:Show()
        return
    end

    tooltip:AddLine(" ")
    local _, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

    if completed then

        if earnedBy then
            if earnedBy ~= "" then
                tooltip:AddLine(format(ACHIEVEMENT_EARNED_BY, earnedBy))
            end
            if not wasEarnedByMe then
                tooltip:AddLine(format(ACHIEVEMENT_NOT_COMPLETED_BY, E.myName))
            elseif E.myName ~= earnedBy then
                tooltip:AddLine(format(ACHIEVEMENT_COMPLETED_BY, E.myName))
            end
        end
    end
    tooltip:Show()
end

hooksecurefunc(GameTooltip, "SetHyperlink", SetHyperlink)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", SetHyperlink)