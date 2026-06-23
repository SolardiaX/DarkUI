local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Alert Frames
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("AlertFrames")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    local anchor = CreateFrame("Frame", "DarkUI_AchievementAnchor", UIParent)
    anchor:SetSize(230, 50)
    anchor:SetPoint(unpack(cfg.achievement_pos))

    local alertBlacklist = {
        GroupLootContainer = true,
        TalkingHeadFrame = true,
    }

    local POSITION, ANCHOR_POINT, YOFFSET, FIRST_YOFFSET = "BOTTOM", "TOP", -9, 0

    local function checkGrow()
        local point = anchor:GetPoint()
        if string.find(point, "TOP") or point == "CENTER" or point == "LEFT" or point == "RIGHT" then
            POSITION = "TOP"
            ANCHOR_POINT = "BOTTOM"
            YOFFSET = 9
            FIRST_YOFFSET = YOFFSET - 2
        else
            POSITION = "BOTTOM"
            ANCHOR_POINT = "TOP"
            YOFFSET = -9
            FIRST_YOFFSET = YOFFSET + 2
        end
    end

    local function queueAdjustAnchors(self, relativeAlert)
        checkGrow()
        for alertFrame in self.alertFramePool:EnumerateActive() do
            alertFrame:ClearAllPoints()
            alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
            relativeAlert = alertFrame
        end
        return relativeAlert
    end

    local function simpleAdjustAnchors(self, relativeAlert)
        checkGrow()
        if self.alertFrame:IsShown() then
            self.alertFrame:ClearAllPoints()
            self.alertFrame:SetPoint(POSITION, relativeAlert, ANCHOR_POINT, 0, YOFFSET)
            return self.alertFrame
        end
        return relativeAlert
    end

    local function anchorAdjustAnchors(self, relativeAlert)
        if self.anchorFrame:IsShown() then return self.anchorFrame end
        return relativeAlert
    end

    local function replaceAnchors(alertFrameSubSystem)
        if alertFrameSubSystem.alertFramePool then
            if alertBlacklist[alertFrameSubSystem.alertFramePool.frameTemplate] then
                return alertFrameSubSystem.alertFramePool.frameTemplate, true
            else
                alertFrameSubSystem.AdjustAnchors = queueAdjustAnchors
            end
        elseif alertFrameSubSystem.alertFrame then
            local frame = alertFrameSubSystem.alertFrame
            if alertBlacklist[frame:GetName()] then
                return frame:GetName(), true
            else
                alertFrameSubSystem.AdjustAnchors = simpleAdjustAnchors
            end
        elseif alertFrameSubSystem.anchorFrame then
            local frame = alertFrameSubSystem.anchorFrame
            if alertBlacklist[frame:GetName()] then
                return frame:GetName(), true
            else
                alertFrameSubSystem.AdjustAnchors = anchorAdjustAnchors
            end
        end
    end

    GroupLootContainer:EnableMouse(false)
    GroupLootContainer.ignoreInLayout = true

    hooksecurefunc("GroupLootContainer_Update", function()
        checkGrow()
        GroupLootContainer:ClearAllPoints()
        GroupLootContainer:SetPoint(POSITION, anchor, POSITION, 2, FIRST_YOFFSET)
    end)

    hooksecurefunc(AlertFrame, "UpdateAnchors", function(self)
        checkGrow()
        self:ClearAllPoints()
        self:SetPoint(POSITION, anchor, POSITION, 2, FIRST_YOFFSET)
    end)

    hooksecurefunc(AlertFrame, "AddAlertFrameSubSystem", function(_, alertFrameSubSystem)
        local _, isBlacklisted = replaceAnchors(alertFrameSubSystem)
        if isBlacklisted then
            for i, alertSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
                if alertFrameSubSystem == alertSubSystem then return tremove(AlertFrame.alertFrameSubSystems, i) end
            end
        end
    end)

    local remove = {}
    for i, alertFrameSubSystem in ipairs(AlertFrame.alertFrameSubSystems) do
        local _, isBlacklisted = replaceAnchors(alertFrameSubSystem)
        if isBlacklisted then remove[i] = true end
    end
    for i in next, remove do
        tremove(AlertFrame.alertFrameSubSystems, i)
    end
end
