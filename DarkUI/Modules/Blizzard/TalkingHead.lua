local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Talking Head
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("TalkingHead")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    self:RegisterEventOnce("PLAYER_ENTERING_WORLD", function()
        if not _G.TalkingHeadFrame then TalkingHead_LoadUI() end

        TalkingHeadFrame.ignoreFramePositionManager = true
        TalkingHeadFrame.ignoreFrameLayout = true
        TalkingHeadFrame:ClearAllPoints()
        TalkingHeadFrame:SetPoint(unpack(cfg.talking_head_pos))

        hooksecurefunc(TalkingHeadFrame, "SetPoint", function(self, _, _, _, _, y)
            if y ~= cfg.talking_head_pos[5] then
                self:ClearAllPoints()
                self:SetPoint(unpack(cfg.talking_head_pos))
            end
        end)
    end)
end
