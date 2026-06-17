local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Queue Timer
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("QueueTimer")

local cfg = C.misc
local GetTime = GetTime

local function createTimerBar(parent, duration, event)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOP", parent, "BOTTOM", 0, -10)
    frame:SetSize(280, 10)
    frame:SetTemplate("transparent")
    frame:CreateBorder("thin")

    frame.bar = CreateFrame("StatusBar", nil, frame)
    frame.bar:SetStatusBarTexture(C.media.texture.status)
    frame.bar:SetAllPoints()
    frame.bar:SetFrameLevel(parent:GetFrameLevel() + 1)
    frame.bar:SetStatusBarColor(1, 0.7, 0)

    parent.nextUpdate = 0

    frame:RegisterEvent(event)
    frame:SetScript("OnEvent", function()
        if not parent:IsShown() then return end

        local startTime = GetTime()
        parent.nextUpdate = 0
        parent:SetScript("OnUpdate", function(self, elapsed)
            self.nextUpdate = self.nextUpdate + elapsed
            if self.nextUpdate > 0.1 then
                local newTime = GetTime()
                if (newTime - startTime) < duration then
                    local width = frame:GetWidth() * (newTime - startTime) / duration
                    frame.bar:SetPoint("BOTTOMRIGHT", frame, -width, 0)
                else
                    self:SetScript("OnUpdate", nil)
                end
                self.nextUpdate = 0
            end
        end)
    end)
end

function module:OnInit()
    local hasDBM = C_AddOns.IsAddOnLoaded("DBM-Core")
    local hasBW = C_AddOns.IsAddOnLoaded("BigWigs")

    if cfg.lfg_queue_timer and not hasDBM and not hasBW then
        createTimerBar(LFGDungeonReadyDialog, 40, "LFG_PROPOSAL_SHOW")
    end

    if cfg.pvp_queue_timer and not hasDBM then
        createTimerBar(PVPReadyDialog, 90, "UPDATE_BATTLEFIELD_STATUS")
    end
end
