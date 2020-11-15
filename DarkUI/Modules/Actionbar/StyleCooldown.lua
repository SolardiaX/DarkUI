local E, C, L = select(2, ...):unpack()

if not C.actionbar.styles.cooldown.enable then return end

----------------------------------------------------------------------------------------
--	Cooldown count (modified from tullaCC)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local GetTime = GetTime
local C_Timer_After = C_Timer.After
local hooksecurefunc = hooksecurefunc
local getmetatable = getmetatable
local pairs = pairs
local floor, max = math.floor, math.max
local round = function(x) return floor(x + 0.5) end
local UIParent = UIParent

--sexy constants!
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5 --used for calculating next update times
local MIN_DELAY = 0.01

local cfg = C.actionbar.styles.cooldown

local Timer = {}
local timers = {}

--returns both what text to display, and how long until the next update
local function getTimeText(s)
    --format text as seconds when at 90 seconds or below
    if s < MINUTEISH then
        --format text as minutes when below an hour
        local seconds = round(s)
        local formatString = seconds > cfg.expiringDuration and cfg.secondsFormat or cfg.expiringFormat
        return formatString, seconds, s - (seconds - 0.51)
    elseif s < HOURISH then
        --format text as hours when below a day
        local minutes = round(s / MINUTE)
        return cfg.minutesFormat, minutes, minutes > 1 and (s - (minutes * MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
    elseif s < DAYISH then
        --format text as days
        local hours = round(s / HOUR)
        return cfg.hoursFormat, hours, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
    else
        local days = round(s / DAY)
        return cfg.daysFormat, days, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
    end
end

function Timer.SetNextUpdate(self, duration)
    C_Timer_After(max(duration, MIN_DELAY), self.OnTimerDone)
end

--stops the timer
function Timer.Stop(self)
    self.enabled = nil
    self.start = nil
    self.duration = nil

    self:Hide()
end

function Timer.UpdateText(self)
    local remain = self.enabled and (self.duration - (GetTime() - self.start)) or 0

    if round(remain) > 0 then
        if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < cfg.minScale then
            self.text:SetText("")
            Timer.SetNextUpdate(self, 1)
        else
            local formatStr, time, timeUntilNextUpdate = getTimeText(remain)
            self.text:SetFormattedText(formatStr, time)
            Timer.SetNextUpdate(self, timeUntilNextUpdate)
        end
    else
        Timer.Stop(self)
    end
end

--forces the given timer to update on the next frame
function Timer.ForceUpdate(self)
    Timer.UpdateText(self)

    self:Show()
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
function Timer.OnSizeChanged(self, width, _)
    local fontScale = round(width) / ICON_SIZE
    if fontScale == self.fontScale then return end

    self.fontScale = fontScale
    if fontScale < cfg.minScale then
        self:Hide()
    else
        self.text:SetFont(cfg.fontFace, fontScale * cfg.fontSize, "OUTLINE")
        self.text:SetShadowColor(0, 0, 0, 0.8)
        self.text:SetShadowOffset(1, -1)
        if self.enabled then
            Timer.ForceUpdate(self)
        end
    end
end

--returns a new timer object
function Timer.Create(cooldown)
    --a frame to watch for OnSizeChanged events
    --needed since OnSizeChanged has funny triggering if the frame with the handler is not shown
    local scaler = CreateFrame("Frame", nil, cooldown)
    scaler:SetAllPoints(cooldown)

    local timer = CreateFrame("Frame", nil, scaler)
    timer:Hide()
    timer:SetAllPoints(scaler)

    timer.OnTimerDone = function() Timer.UpdateText(timer) end

    local text = timer:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", 0, 0)
    text:SetFont(cfg.fontFace, cfg.fontSize, "OUTLINE")
    timer.text = text

    Timer.OnSizeChanged(timer, scaler:GetSize())
    scaler:SetScript("OnSizeChanged", function(_, ...) Timer.OnSizeChanged(timer, ...) end)

    -- prevent display of blizzard cooldown text
    cooldown:SetHideCountdownNumbers(true)

    timers[cooldown] = timer

    return timer
end

function Timer.Start(cooldown, start, duration, ...)
    --start timer
    if start > 0 and duration > cfg.minDuration and (not cooldown.noCooldownCount) then
        --stop timer
        cooldown:SetDrawBling(cfg.drawBling)
        cooldown:SetDrawSwipe(cfg.drawSwipe)
        cooldown:SetDrawEdge(cfg.drawEdge)

        local timer = timers[cooldown] or Timer.Create(cooldown)

        timer.enabled = true
        timer.start = start
        timer.duration = duration
        Timer.UpdateText(timer)

        if timer.fontScale >= cfg.minScale then timer:Show() end
    else
        local timer = timers[cooldown]
        if timer then Timer.Stop(timer) end
    end
end

local f = CreateFrame('Frame')
f:RegisterEvent('PLAYER_ENTERING_WORLD')
f:SetScript('OnEvent', function()
    for _, timer in pairs(timers) do
        Timer.ForceUpdate(timer)
    end
end)

hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer.Start)
