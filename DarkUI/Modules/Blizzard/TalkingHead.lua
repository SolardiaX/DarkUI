local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end
------------------------------------------------------------------------------------------
--	Set custom position for TalkingHeadFrame
------------------------------------------------------------------------------------------
local Load = CreateFrame("Frame")
Load:SetPoint(unpack(C.blizzard.talking_head_pos))
Load:RegisterEvent("ADDON_LOADED")
Load:SetScript("OnEvent", function(_, _, addon)
    if addon == "Blizzard_TalkingHeadUI" or (addon == E.addonName and TalkingHeadFrame) then
        TalkingHeadFrame.ignoreFramePositionManager = true
        TalkingHeadFrame:SetParent(Load)
        TalkingHeadFrame:ClearAllPoints()
        TalkingHeadFrame:SetPoint("TOP", Load, "TOP")
	    Load:UnregisterEvent("ADDON_LOADED")
    end
end)
