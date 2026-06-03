local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Cooldown
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleCooldown")

local GetTime = GetTime
local floor, max = math.floor, math.max
local round = function(x)
    return floor(x + 0.5)
end

local ICON_SIZE = 26
local DAY, HOUR, MINUTE = 86400, 3600, 60
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY / 2 + 0.5, HOUR / 2 + 0.5, MINUTE / 2 + 0.5

local cfg = C.actionbar.styles.cooldown

local hideNumbers = {}
local active = {}
local hooked = {}

local function getTimeText(s)
    if s < MINUTEISH then
        local seconds = round(s)
        local formatString = seconds > cfg.expiringDuration and cfg.secondsFormat or cfg.expiringFormat
        return formatString, seconds, s - (seconds - 0.51)
    elseif s < HOURISH then
        local minutes = round(s / MINUTE)
        return cfg.minutesFormat, minutes, minutes > 1 and (s - (minutes * MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
    elseif s < DAYISH then
        local hours = round(s / HOUR)
        return cfg.hoursFormat, hours, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
    else
        local days = round(s / DAY)
        return cfg.daysFormat, days, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
    end
end

local function timerStop(self)
    self.enabled = nil
    self:Hide()
end

local function timerOnUpdate(self, elapsed)
    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
    else
        if (self:GetEffectiveScale() / UIParent:GetEffectiveScale()) < cfg.minScale then
            self.text:SetText("")
            self.nextUpdate = 1
        else
            local passTime = GetTime() - self.start
            local remain = passTime >= 0 and ((self.duration - passTime) / self.modRate) or self.duration
            if remain > 0 then
                local formatStr, time, timeUntilNextUpdate = getTimeText(remain)
                self.text:SetFormattedText(formatStr, time)
                self.nextUpdate = timeUntilNextUpdate
            else
                timerStop(self)
            end
        end
    end
end

local function timerForceUpdate(self)
    self.nextUpdate = 0
    self:Show()
end

local function timerOnSizeChanged(self, width)
    local fontScale = round(width) / ICON_SIZE
    if fontScale == self.fontScale then
        return
    end

    self.fontScale = fontScale
    if fontScale < cfg.minScale then
        self:Hide()
    else
        self.text:SetFont(cfg.fontFace, fontScale * cfg.fontSize, "OUTLINE")
        self.text:SetShadowColor(0, 0, 0, 0.8)
        self.text:SetShadowOffset(1, -1)
        if self.enabled then
            timerForceUpdate(self)
        end
    end
end

local function timerCreate(cooldown)
    local scaler = CreateFrame("Frame", nil, cooldown)
    scaler:SetAllPoints(cooldown)

    local timer = CreateFrame("Frame", nil, scaler)
    timer:Hide()
    timer:SetAllPoints(scaler)
    timer:SetScript("OnUpdate", timerOnUpdate)

    local text = timer:CreateFontString(nil, "OVERLAY")
    text:SetPoint("CENTER", 0, 0)
    text:SetFont(cfg.fontFace, cfg.fontSize, "OUTLINE")
    timer.text = text

    timerOnSizeChanged(timer, scaler:GetSize())
    scaler:SetScript("OnSizeChanged", function(_, ...)
        timerOnSizeChanged(timer, ...)
    end)

    cooldown.timer = timer

    if cooldown.SetHideCountdownNumbers then
        cooldown:SetHideCountdownNumbers(true)
    end

    return timer
end

local function deactivateDisplay(cooldown)
    local timer = cooldown.timer
    if timer then
        timerStop(timer)
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

local function onCooldown(cooldown, start, duration, modRate)
    if cooldown:IsForbidden() or cooldown.noCooldownCount or hideNumbers[cooldown] then
        return
    end

    start = tonumber(start) or 0
    duration = tonumber(duration) or 0
    modRate = tonumber(modRate) or 1

    local show = (start > 0) and (duration > cfg.minDuration) and (modRate > 0)

    if show then
        cooldown:SetDrawBling(cfg.drawBling)
        cooldown:SetDrawSwipe(cfg.drawSwipe)
        cooldown:SetDrawEdge(cfg.drawEdge)

        local timer = cooldown.timer or timerCreate(cooldown)
        timer.start = start
        timer.duration = duration
        timer.modRate = modRate
        timer.enabled = true
        timer.nextUpdate = 0

        local parent = cooldown:GetParent()
        local charge = parent and parent.chargeCooldown
        local chargeTimer = charge and charge.timer
        if chargeTimer and chargeTimer ~= timer then
            timerStop(chargeTimer)
        end

        if timer.fontScale >= cfg.minScale then
            timer:Show()
        end
    else
        local timer = cooldown.timer
        if timer then
            timerStop(timer)
        end
    end
end

function module:OnEnable()
    local Cooldown_MT = getmetatable(ActionButton1Cooldown).__index

    hooksecurefunc(Cooldown_MT, "SetCooldown", function(cooldown, start, duration, modRate)
        onCooldown(cooldown, start, duration, modRate)
    end)

    hooksecurefunc(Cooldown_MT, "SetHideCountdownNumbers", function(cooldown, hide)
        local disable = not (hide or cooldown.noCooldownCount or cooldown:IsForbidden())
        if disable then
            cooldown:SetHideCountdownNumbers(true)
        end
    end)

    if CooldownFrame_SetDisplayAsPercentage then
        hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", function(cooldown)
            setHideCooldownNumbers(cooldown, true)
        end)
    end
end
