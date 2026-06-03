local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Cooldown
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleCooldown")

local numberFormatter = C_StringUtil.CreateNumericRuleFormatter()
local hookedCooldowns = {}

local ROUNDING_UP = Enum.NumericRuleFormatRounding.Up
local ROUNDING_NEAREST = Enum.NumericRuleFormatRounding.Nearest
local COLOR_RED = CreateColor(1, 0, 0, 1)
local COLOR_YELLOW = CreateColor(1, 1, 0, 1)
local COLOR_DARK = CreateColor(0.8, 0.8, 0.2, 1)

local breakPoints = {
    { threshold = 0, format = COLOR_RED:WrapTextInColorCode("%.1f"), components = { { step = 0.1, rounding = ROUNDING_UP } } },
    { threshold = 3, format = COLOR_YELLOW:WrapTextInColorCode("%d"), components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
    { threshold = 10, format = COLOR_DARK:WrapTextInColorCode("%d"), components = { { div = 1, step = 1, rounding = ROUNDING_UP } } },
    { threshold = 60, format = "%d:%02d", components = { { div = 60 }, { mod = 60 } } },
    { threshold = 600, format = "%d" .. E.myColorString .. "m", components = { { div = 60, step = 1, rounding = ROUNDING_NEAREST } } },
    { threshold = 7200, format = "%d" .. E.myColorString .. "h", components = { { div = 3600, step = 1, rounding = ROUNDING_NEAREST } } },
    { threshold = 86400, format = "%d" .. E.myColorString .. "d", components = { { div = 86400, step = 1, rounding = ROUNDING_NEAREST } } },
}

numberFormatter:SetBreakpoints(breakPoints)

local function updateCooldown(cooldown)
    if not cooldown or hookedCooldowns[cooldown] then
        return
    end
    cooldown:SetCountdownFormatter(numberFormatter)
    hookedCooldowns[cooldown] = true
end

function module:OnEnable()
    local cooldownMT = getmetatable(ActionButton1Cooldown).__index
    local methods = { "SetCooldown", "SetCooldownDuration", "SetHideCountdownNumbers", "SetCooldownFromDurationObject" }
    for _, method in pairs(methods) do
        if cooldownMT[method] then
            hooksecurefunc(cooldownMT, method, updateCooldown)
        end
    end

    if CooldownFrame_SetDisplayAsPercentage then
        hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", updateCooldown)
    end

    SetCVar("countdownForCooldowns", 1)
end
