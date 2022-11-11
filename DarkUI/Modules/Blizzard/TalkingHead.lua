local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end
------------------------------------------------------------------------------------------
--	Set custom position for TalkingHeadFrame
------------------------------------------------------------------------------------------
local Load = CreateFrame("Frame")
Load:RegisterEvent("ADDON_LOADED")
Load:SetScript("OnEvent", function(_, _, addon)
    if addon == "Blizzard_TalkingHeadUI" or (addon == E.addonName and IsAddOnLoaded("Blizzard_TalkingHeadUI")) then
        TalkingHeadFrame.ignoreFramePositionManager = true
        TalkingHeadFrame:ClearAllPoints()
        TalkingHeadFrame:SetPoint(unpack(C.blizzard.talking_head_pos))
	Load:UnregisterEvent("ADDON_LOADED")
    end
end)
