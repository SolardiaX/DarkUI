local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end

----------------------------------------------------------------------------------------
--	Based on oMirrorBars(by Haste)
----------------------------------------------------------------------------------------
local module = E:Module("Blizzard"):Sub("MirrorBar")

local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

local Spawn, PauseAll
do
    local barPool = {}

    local loadPosition = function(self)
        local pos = C.blizzard.mirrorbar[string.lower(self.type)].pos

        return self:SetPoint(unpack(pos))
    end

    local OnUpdate = function(self)
        if self.paused then return end

        self:SetValue(GetMirrorTimerProgress(self.type) / 1e3)
    end

    local Start = function(self, value, maxvalue, _, paused, text)
        if paused > 0 then
            self.paused = 1
        elseif self.paused then
            self.paused = nil
        end

        self.text:SetText(text)

        self:SetMinMaxValues(0, maxvalue / 1e3)
        self:SetValue(value / 1e3)

        if not self:IsShown() then self:Show() end
    end

    function Spawn(type)
        if barPool[type] then return barPool[type] end
        local frame = CreateFrame("StatusBar", nil, UIParent)

        frame:SetScript("OnUpdate", OnUpdate)

        local r, g, b = unpack(C.blizzard.mirrorbar[string.lower(type)].color)

        local bg = frame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(frame)
        bg:SetTexture(C.media.texture.status)
        bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3)

        local border = frame:CreateTexture(nil, "BORDER")
        border:SetPoint("CENTER", frame, 0, -1)
        border:SetTexture(bar_border)

        local text = frame:CreateFontString(nil, "OVERLAY")
        text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        text:SetJustifyH("CENTER")
        text:SetShadowOffset(0, 0)
        text:SetTextColor(1, 1, 1)

        text:SetPoint("LEFT", frame)
        text:SetPoint("RIGHT", frame)
        text:SetPoint("TOP", frame, 0, 1)
        text:SetPoint("BOTTOM", frame)

        frame:SetSize(198, 12)

        frame:SetStatusBarTexture(C.media.texture.status)
        frame:SetStatusBarColor(r, g, b)

        frame.type = type
        frame.text = text
        frame.border = border
        frame.bg = bg

        frame.Start = Start
        frame.Stop = Stop

        loadPosition(frame)

        barPool[type] = frame
        return frame
    end

    function PauseAll(val)
        for _, bar in next, barPool do
            bar.paused = val
        end
    end
end

function module:ADDON_LOADED(_, addon)
    if addon == E.addonName then
        UIParent:UnregisterEvent("MIRROR_TIMER_START")

        self:UnregisterEvent("ADDON_LOADED")
        self.ADDON_LOADED = nil
    end
end

function module:PLAYER_ENTERING_WORLD()
    for i = 1, MIRRORTIMER_NUMTIMERS do
        local type, value, maxvalue, scale, paused, text = GetMirrorTimerInfo(i)
        if type ~= "UNKNOWN" then
            Spawn(type):Start(value, maxvalue, scale, paused, text)
        end
    end
end

function module:MIRROR_TIMER_START(_, type, value, maxvalue, scale, paused, text)
    return Spawn(type):Start(value, maxvalue, scale, paused, text)
end

function module:MIRROR_TIMER_STOP(_, type)

    return Spawn(type):Hide()
end

function module:MIRROR_TIMER_PAUSE(_, duration)
    return PauseAll((duration > 0 and duration) or nil)
end

module:RegisterEvent("ADDON_LOADED PLAYER_ENTERING_WORLD MIRROR_TIMER_START MIRROR_TIMER_STOP MIRROR_TIMER_PAUSE")
