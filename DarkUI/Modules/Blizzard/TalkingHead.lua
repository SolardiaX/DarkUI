local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end
------------------------------------------------------------------------------------------
--	Set custom position for TalkingHeadFrame
------------------------------------------------------------------------------------------
local Load = CreateFrame("Frame")
Load:RegisterEvent("PLAYER_ENTERING_WORLD")
Load:SetScript("OnEvent", function(_, _, addon)
    if not _G.TalkingHeadFrame then
        _G.TalkingHead_LoadUI()
    end
    
    TalkingHeadFrame.ignoreFramePositionManager = true
    TalkingHeadFrame.ignoreFrameLayout = true
    TalkingHeadFrame:ClearAllPoints()
    TalkingHeadFrame:SetPoint(unpack(C.blizzard.talking_head_pos))

    --Iterate through all alert subsystems in order to find the one created for TalkingHeadFrame, and then remove it.
    --We do this to prevent alerts from anchoring to this frame when it is shown.
    for index, alertFrameSubSystem in ipairs(_G.AlertFrame.alertFrameSubSystems) do
        if alertFrameSubSystem.anchorFrame and alertFrameSubSystem.anchorFrame == _G.TalkingHeadFrame then
            tremove(_G.AlertFrame.alertFrameSubSystems, index)
        end
    end
end)
