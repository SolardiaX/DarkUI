local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end
------------------------------------------------------------------------------------------
--	Set custom position for TalkingHeadFrame
------------------------------------------------------------------------------------------
local Load = CreateFrame("Frame")
Load:RegisterEvent("PLAYER_ENTERING_WORLD")
Load:SetScript("OnEvent", function()
    if not _G.TalkingHeadFrame then
        _G.TalkingHead_LoadUI()
    end
    
    TalkingHeadFrame.ignoreFramePositionManager = true
    TalkingHeadFrame.ignoreFrameLayout = true
    TalkingHeadFrame:ClearAllPoints()
    TalkingHeadFrame:SetPoint(unpack(C.blizzard.talking_head_pos))
    TalkingHeadFrame.SetPoint = E.dummy

    Load:UnregisterEvent("PLAYER_ENTERING_WORLD")

    hooksecurefunc(TalkingHeadFrame, "SetPoint", function(self, _, _, _, _, y)
        if y ~= C.blizzard.talking_head_pos[5] then
            self:ClearAllPoints()
            self:SetPoint(unpack(C.blizzard.talking_head_pos))
        end
    end)
end)
