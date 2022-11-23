local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Fix blank tooltip
----------------------------------------------------------------------------------------
local bug = nil
local FixTooltip = CreateFrame("Frame")
FixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
FixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
FixTooltip:SetScript("OnEvent", function()
    if GameTooltip:IsShown() then
        bug = true
    end
end)

local FixTooltipBags = CreateFrame("Frame")
FixTooltipBags:RegisterEvent("BAG_UPDATE_DELAYED")
FixTooltipBags:SetScript("OnEvent", function()
    if StuffingFrameBags and StuffingFrameBags:IsShown() then
        if GameTooltip:IsShown() then
            bug = true
        end
    end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self)
    if self:IsForbidden() then return end
    if bug and self:NumLines() == 0 then
        self:Hide()
        bug = false
    end
end)

----------------------------------------------------------------------------------------
--	Fix RemoveTalent() taint
----------------------------------------------------------------------------------------
FCF_StartAlertFlash = E.dummy

----------------------------------------------------------------------------------------
--	Fix SearchLFGLeave() taint
----------------------------------------------------------------------------------------
local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function()
    if LFRBrowseFrame.timeToClear then
        LFRBrowseFrame.timeToClear = nil
    end
end)

----------------------------------------------------------------------------------------
--	Collect garbage
----------------------------------------------------------------------------------------
local eventcount = 0
local Garbage = CreateFrame("Frame")
Garbage:RegisterAllEvents()
Garbage:SetScript("OnEvent", function(self, event)
    eventcount = eventcount + 1

    if (InCombatLockdown() and eventcount > 25000) or (not InCombatLockdown() and eventcount > 10000) or event == "PLAYER_ENTERING_WORLD" then
        collectgarbage("collect")
        eventcount = 0
    end
end)

----------------------------------------------------------------------------------------
--	Guild
----------------------------------------------------------------------------------------
if not GuildControlUIRankSettingsFrameRosterLabel then
    GuildControlUIRankSettingsFrameRosterLabel = CreateFrame("frame")
    GuildControlUIRankSettingsFrameRosterLabel:Hide()
end

----------------------------------------------------------------------------------------
--	Fix taint with Actionbars
----------------------------------------------------------------------------------------
-- local barsToUpdate = { MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, StanceBar, PetActionBar, PossessActionBar, MultiBarRight, MultiBarLeft, MultiBar5, MultiBar6, MultiBar7 }
-- for _, bar in ipairs(barsToUpdate) do
--     hooksecurefunc(bar, "UpdateSpellFlyoutDirection", function(self)
--         if not issecurevariable(self, "flyoutDirection") then
--             self.flyoutDirection = nil
--         end
--         if not issecurevariable(self, "snappedToFrame") then
--             self.snappedToFrame = nil
--         end
--     end)
-- end

-- hooksecurefunc("SetClampedTextureRotation", function(texture)
--     local parent = texture and texture:GetParent()
--     if parent and parent.FlyoutArrowPushed and parent.FlyoutArrowHighlight then
--         if not issecurevariable(texture, "rotationDegrees") then
--             texture.rotationDegrees = nil
--         end
--     end
-- end)
