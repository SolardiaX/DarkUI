local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Achievement
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("Achievement")
local cfg = C.tooltip

local format, find = string.format, string.find

local function setHyperlink(tooltip, refString)
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

function module:OnInit()
    if not cfg.enable or not cfg.achievements then return end

    hooksecurefunc(GameTooltip, "SetHyperlink", setHyperlink)
    hooksecurefunc(ItemRefTooltip, "SetHyperlink", setHyperlink)
end
