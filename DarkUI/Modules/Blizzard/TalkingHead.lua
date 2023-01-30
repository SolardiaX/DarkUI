local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end
------------------------------------------------------------------------------------------
--	Set custom position for TalkingHeadFrame
------------------------------------------------------------------------------------------
local module = E:Module("Blizzard"):Sub("TalkingHead")

module:RegisterEventOnce("PLAYER_ENTERING_WORLD", function()
    if not _G.TalkingHeadFrame then
        _G.TalkingHead_LoadUI()
    end

    TalkingHeadFrame.ignoreFramePositionManager = true
    TalkingHeadFrame.ignoreFrameLayout = true
    TalkingHeadFrame:ClearAllPoints()
    TalkingHeadFrame:SetPoint(unpack(C.blizzard.talking_head_pos))
    TalkingHeadFrame.SetPoint = E.Dummy

    hooksecurefunc(TalkingHeadFrame, "SetPoint", function(self, _, _, _, _, y)
        if y ~= C.blizzard.talking_head_pos[5] then
            self:ClearAllPoints()
            self:SetPoint(unpack(C.blizzard.talking_head_pos))
        end
    end)
end)
