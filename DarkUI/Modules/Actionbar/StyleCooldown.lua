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
local function Timer_Stop(self)
    self.enabled = nil
    self.start = nil
    self.duration = nil

    self:Hide()
end

local function Timer_OnUpdate(self, elapsed)
    if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			if (self:GetEffectiveScale() / UIParent:GetEffectiveScale()) < cfg.minScale then
				self.text:SetText("")
				self.nextUpdate = 1
			else
				local remain = self.duration - (GetTime() - self.start)
				if floor(remain + 0.5) > 0 then
					local formatStr, time, timeUntilNextUpdate = getTimeText(remain)
                    self.text:SetFormattedText(formatStr, time)
					self.nextUpdate = timeUntilNextUpdate
				else
					Timer_Stop(self)
				end
			end
		end
	end
end

--forces the given timer to update on the next frame
function Timer_ForceUpdate(self)
    self.nextUpdate = 0
    self:Show()
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
local function Timer_OnSizeChanged(self, width)
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
            Timer_ForceUpdate(self)
        end
    end
end

--returns a new timer object
local function Timer_Create(cooldown)
    --a frame to watch for OnSizeChanged events
    --needed since OnSizeChanged has funny triggering if the frame with the handler is not shown
    local scaler = CreateFrame("Frame", nil, cooldown)
    scaler:SetAllPoints(cooldown)

    local timer = CreateFrame("Frame", nil, scaler)
    timer:Hide()
    timer:SetAllPoints(scaler)
    timer:SetScript("OnUpdate", Timer_OnUpdate)

    local text = timer:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", 0, 0)
    text:SetFont(cfg.fontFace, cfg.fontSize, "OUTLINE")
    timer.text = text

    Timer_OnSizeChanged(timer, scaler:GetSize())
    scaler:SetScript("OnSizeChanged", function(_, ...) Timer_OnSizeChanged(timer, ...) end)

    -- prevent display of blizzard cooldown text
    cooldown:SetHideCountdownNumbers(true)

    cooldown.timer = timer
    return timer
end

local Cooldown_MT = getmetatable(_G.ActionButton1Cooldown).__index
local hideNumbers = {}

local function deactivateDisplay(cooldown)
	local timer = cooldown.timer
	if timer then
		Timer_Stop(timer)
	end
end

local function setHideCooldownNumbers(cooldown, hide)
	if hide then
		hideNumbers[cooldown] = true
		deactivateDisplay(cooldown)
	else
		hideNumbers[cooldown] = nil
	end
end

hooksecurefunc(Cooldown_MT, "SetCooldown", function(cooldown, start, duration, modRate)
	if cooldown.noCooldownCount or cooldown:IsForbidden() or hideNumbers[cooldown] then return end

	local show = (start and start > 0) and (duration and duration > cfg.minDuration) and (modRate == nil or modRate > 0)

	if show then
		local parent = cooldown:GetParent()
		if parent and parent.chargeCooldown == cooldown then return end

		local timer = cooldown.timer or Timer_Create(cooldown)
		timer.start = start
		timer.duration = duration
		timer.enabled = true
		timer.nextUpdate = 0
		if timer.fontScale >= cfg.minScale then timer:Show() end
	else
		deactivateDisplay(cooldown)
	end
end)

hooksecurefunc(Cooldown_MT, "Clear", deactivateDisplay)

hooksecurefunc(Cooldown_MT, "SetHideCountdownNumbers", setHideCooldownNumbers)

hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
	setHideCooldownNumbers(cooldown, true)
end)
