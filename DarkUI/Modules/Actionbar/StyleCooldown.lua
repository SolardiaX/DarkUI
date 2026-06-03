local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Cooldown
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("StyleCooldown")

local cfg = C.actionbar.cooldown

local numberFormatter = C_StringUtil.CreateNumericRuleFormatter()
local hookedCooldowns = {}
local shinePool = {}

local FONT_FACE = STANDARD_TEXT_FONT
local FONT_SIZE = 13
local FONT_FLAG = "OUTLINE"
local MIN_DURATION = cfg.minDuration or 2
local MIN_EFFECT_DURATION = cfg.minEffectDuration or 30
local EFFECT_TYPE = cfg.effect or "shine"

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

----------------------------------------------------------------------------------------
-- Shine / Pulse Effect
----------------------------------------------------------------------------------------

local function onShineFinished(animGroup)
    local shine = animGroup:GetParent()
    shine:Hide()
    shine:ClearAllPoints()
    tinsert(shinePool, shine)
end

local function createShineFrame()
    local shine = CreateFrame("Frame", nil, UIParent)
    shine:SetFrameStrata("HIGH")
    shine:Hide()

    local texture = shine:CreateTexture(nil, "OVERLAY")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\Cooldown\\star4")
    texture:SetBlendMode("ADD")
    texture:SetAlpha(0)
    shine.texture = texture

    local ag = shine:CreateAnimationGroup()
    ag:SetScript("OnFinished", onShineFinished)

    local scaleUp = ag:CreateAnimation("Scale")
    scaleUp:SetOrigin("CENTER", 0, 0)
    scaleUp:SetFromScale(1, 1)
    scaleUp:SetToScale(4, 4)
    scaleUp:SetDuration(0.3)
    scaleUp:SetOrder(1)

    local fadeIn = ag:CreateAnimation("Alpha")
    fadeIn:SetFromAlpha(0)
    fadeIn:SetToAlpha(1)
    fadeIn:SetDuration(0.3)
    fadeIn:SetOrder(1)

    local scaleDown = ag:CreateAnimation("Scale")
    scaleDown:SetOrigin("CENTER", 0, 0)
    scaleDown:SetFromScale(4, 4)
    scaleDown:SetToScale(1, 1)
    scaleDown:SetDuration(0.4)
    scaleDown:SetOrder(2)

    local fadeOut = ag:CreateAnimation("Alpha")
    fadeOut:SetFromAlpha(1)
    fadeOut:SetToAlpha(0)
    fadeOut:SetDuration(0.4)
    fadeOut:SetOrder(2)

    shine.animGroup = ag
    return shine
end

local function playShine(cooldown)
    local parent = cooldown:GetParent()
    if not parent or not parent:IsVisible() then
        return
    end

    local shine = tremove(shinePool) or createShineFrame()
    shine:SetParent(parent)
    shine:SetAllPoints(parent)
    shine:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    shine:Show()
    shine.animGroup:Play()
end

local function playPulse(cooldown)
    local parent = cooldown:GetParent()
    if not parent or not parent:IsVisible() then
        return
    end

    local icon = parent.icon
    if not icon then
        return
    end

    local shine = tremove(shinePool) or createShineFrame()
    shine:SetParent(parent)
    shine:SetAllPoints(parent)
    shine:SetFrameLevel(cooldown:GetFrameLevel() + 5)
    shine.texture:SetTexture(icon:GetTexture())
    shine.texture:SetBlendMode("BLEND")
    shine.texture:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    shine:Show()
    shine.animGroup:Play()
end

local function playEffect(cooldown)
    if EFFECT_TYPE == "shine" then
        playShine(cooldown)
    elseif EFFECT_TYPE == "pulse" then
        playPulse(cooldown)
    end
end

----------------------------------------------------------------------------------------
-- Cooldown Hook
----------------------------------------------------------------------------------------

local function onCooldownDone(cooldown)
    local duration = cooldown._darkui_duration
    if not duration or duration < MIN_EFFECT_DURATION then
        return
    end
    cooldown._darkui_duration = nil
    playEffect(cooldown)
end

local function trackDuration(cooldown, start, duration)
    if cooldown and start and duration and duration > 0 then
        cooldown._darkui_duration = duration
    end
end

local function updateCooldown(cooldown)
    if not cooldown or hookedCooldowns[cooldown] then
        return
    end

    cooldown:SetCountdownFormatter(numberFormatter)
    cooldown:SetMinimumCountdownDuration(MIN_DURATION)

    local region = cooldown:GetRegions()
    if region and region:IsObjectType("FontString") then
        region:SetFont(FONT_FACE, FONT_SIZE, FONT_FLAG)
    end

    if EFFECT_TYPE ~= "none" then
        cooldown:HookScript("OnCooldownDone", onCooldownDone)
    end

    hookedCooldowns[cooldown] = true
end

function module:OnEnable()
    if not cfg or not cfg.enable then
        return
    end

    local cooldownMT = getmetatable(ActionButton1Cooldown).__index
    local methods = { "SetCooldown", "SetCooldownDuration", "SetHideCountdownNumbers", "SetCooldownFromDurationObject" }
    for _, method in pairs(methods) do
        if cooldownMT[method] then
            hooksecurefunc(cooldownMT, method, updateCooldown)
        end
    end

    -- Track duration for finish effect
    if EFFECT_TYPE ~= "none" then
        hooksecurefunc(cooldownMT, "SetCooldown", trackDuration)
    end

    if CooldownFrame_SetDisplayAsPercentage then
        hooksecurefunc("CooldownFrame_SetDisplayAsPercentage", updateCooldown)
    end

    SetCVar("countdownForCooldowns", 1)
end
