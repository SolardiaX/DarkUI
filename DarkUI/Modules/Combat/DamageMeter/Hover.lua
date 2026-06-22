local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- DamageMeter Hover (header/button fade on mouseover)
------------------------------------------------------------------------

local module = E:Module("Combat"):Sub("DamageMeter")

local GetTime = GetTime
local abs = math.abs
local C_Timer_After = C_Timer.After

local FADE_OUT_DELAY = 1
local FADE_DURATION = 0.25
local CHECK_FREQUENCY = 0.1

local cfg

local windowFadeTargets = setmetatable({}, { __mode = "k" })
local fadeAnimGroups = setmetatable({}, { __mode = "k" })

local fadeManager = { ticker = nil, lastHoverTime = 0, isFaded = false, lastFocusObj = nil, lastCheckResult = false }
local hoverHooked = false

local checkFocus = nil
local checkResult = false

------------------------------------------------------------------------
-- Fade Animation
------------------------------------------------------------------------

local function getOrCreateAnimGroup(object)
    if object.GetFrameType and (object:GetFrameType() == "DropdownButton" or object.OpenMenu) then
        return nil
    end
    if fadeAnimGroups[object] then
        return fadeAnimGroups[object]
    end
    if not object.SetAlpha then
        return nil
    end
    local ag = object:CreateAnimationGroup()
    ag:SetLooping("NONE")
    local anim = ag:CreateAnimation("Alpha")
    anim:SetDuration(FADE_DURATION)
    anim:SetSmoothing("OUT")
    ag.anim = anim
    fadeAnimGroups[object] = ag
    return ag
end

local function smoothFadeObject(object, targetAlpha)
    local ag = getOrCreateAnimGroup(object)
    if not ag then
        if object.SetAlpha then
            object:SetAlpha(targetAlpha)
        end
        return
    end
    local currentAlpha = object:GetAlpha()
    if abs(currentAlpha - targetAlpha) < 0.05 then
        if not ag:IsPlaying() then
            object:SetAlpha(targetAlpha)
        end
        return
    end
    if ag:IsPlaying() then
        ag:Stop()
    end
    ag.anim:SetFromAlpha(currentAlpha)
    ag.anim:SetToAlpha(targetAlpha)
    ag:SetScript("OnFinished", function(self)
        self:GetParent():SetAlpha(targetAlpha)
    end)
    ag:Play()
end

------------------------------------------------------------------------
-- Fade Targets
------------------------------------------------------------------------

local function updateFadeTargets(window)
    if not window then
        return
    end
    local targets = {}
    windowFadeTargets[window] = targets
    local bgMode = cfg.headerBgMode or 1
    local btnMode = cfg.headerBtnMode or 1

    local function add(obj)
        if obj and obj.GetAlpha then
            table.insert(targets, obj)
        end
    end

    if window.Header then
        if bgMode == 2 then
            add(window.Header)
        else
            window.Header:SetAlpha(1)
        end
    end
    if window.bg then
        if bgMode == 2 then
            add(window.bg)
        else
            window.bg:SetAlpha(1)
        end
    end

    if btnMode == 3 then
        add(window.SettingsDropdown)
        add(window.SessionDropdown)
        add(window.MinimizeButton)
        add(window.DamageMeterTypeDropdown)
        add(window.SessionTimer)
    elseif btnMode == 2 then
        add(window.SettingsDropdown)
        add(window.SessionDropdown)
        add(window.MinimizeButton)
        if window.DamageMeterTypeDropdown then
            window.DamageMeterTypeDropdown:SetAlpha(1)
        end
        if window.SessionTimer then
            window.SessionTimer:SetAlpha(1)
        end
    else
        if window.SettingsDropdown then
            window.SettingsDropdown:SetAlpha(1)
        end
        if window.SessionDropdown then
            window.SessionDropdown:SetAlpha(1)
        end
        if window.MinimizeButton then
            window.MinimizeButton:SetAlpha(1)
        end
        if window.DamageMeterTypeDropdown then
            window.DamageMeterTypeDropdown:SetAlpha(1)
        end
        if window.SessionTimer then
            window.SessionTimer:SetAlpha(1)
        end
    end
end

local function setTargetsAlpha(targetAlpha)
    module:ForEachWindow(function(window)
        if not windowFadeTargets[window] then
            updateFadeTargets(window)
        end
        local targets = windowFadeTargets[window]
        if not targets then
            return
        end
        for _, object in ipairs(targets) do
            if targetAlpha == 0 then
                if object.SetAlpha then
                    object:SetAlpha(0)
                end
            else
                smoothFadeObject(object, targetAlpha)
            end
        end
    end)
end

local function forceResetAlpha()
    module:ForEachWindow(function(window)
        local targets = windowFadeTargets[window]
        if targets then
            for _, obj in ipairs(targets) do
                if fadeAnimGroups[obj] then
                    fadeAnimGroups[obj]:Stop()
                end
                if obj.SetAlpha then
                    obj:SetAlpha(1)
                end
            end
        end
        if window.Header then
            window.Header:SetAlpha(1)
        end
        if window.bg then
            window.bg:SetAlpha(1)
        end
        if window.SettingsDropdown then
            window.SettingsDropdown:SetAlpha(1)
        end
        if window.SessionDropdown then
            window.SessionDropdown:SetAlpha(1)
        end
        if window.MinimizeButton then
            window.MinimizeButton:SetAlpha(1)
        end
        if window.DamageMeterTypeDropdown and window.DamageMeterTypeDropdown.SetAlpha then
            window.DamageMeterTypeDropdown:SetAlpha(1)
        end
        if window.SessionTimer then
            window.SessionTimer:SetAlpha(1)
        end
        if window.ScrollBox then
            window.ScrollBox:SetAlpha(1)
        end
    end)
end

------------------------------------------------------------------------
-- Mouse Focus Detection
------------------------------------------------------------------------

local function getCurrentMouseFocus()
    if GetMouseFoci then
        local foci = GetMouseFoci()
        return foci and foci[1]
    end
    return nil
end

local function isFrameOrChild(focus, frame)
    if not focus then
        return false
    end
    if focus == frame then
        return true
    end
    local curr = focus
    local depth = 0
    while curr and depth < 20 do
        if curr == frame then
            return true
        end
        curr = curr:GetParent()
        depth = depth + 1
    end
    return false
end

local function doFocusCheck()
    module:ForEachWindow(function(window)
        if window:IsShown() and isFrameOrChild(checkFocus, window) then
            checkResult = true
        end
    end)
end

local function checkMouseLoop()
    if not cfg.enableHover then
        return
    end
    if EditModeManagerFrame and EditModeManagerFrame:IsShown() then
        if fadeManager.isFaded then
            setTargetsAlpha(1)
            fadeManager.isFaded = false
        end
        return
    end

    local isOverAny = false
    local currentFocus = getCurrentMouseFocus()
    if currentFocus == fadeManager.lastFocusObj and currentFocus ~= nil then
        isOverAny = fadeManager.lastCheckResult
    else
        if _G.DamageMeter then
            checkFocus = currentFocus
            checkResult = false
            pcall(doFocusCheck)
            isOverAny = checkResult
            checkFocus = nil
        end
        fadeManager.lastFocusObj = currentFocus
        fadeManager.lastCheckResult = isOverAny
    end

    if isOverAny then
        if fadeManager.isFaded then
            setTargetsAlpha(1)
            fadeManager.isFaded = false
        end
        fadeManager.lastHoverTime = GetTime()
    else
        if not fadeManager.isFaded and (GetTime() - fadeManager.lastHoverTime > FADE_OUT_DELAY) then
            setTargetsAlpha(0)
            fadeManager.isFaded = true
        end
    end
end

------------------------------------------------------------------------
-- Hover Module
------------------------------------------------------------------------

module.Hover = {}

function module.Hover:RefreshTargets()
    if not _G.DamageMeter then
        return
    end

    if not hoverHooked then
        hooksecurefunc(_G.DamageMeter, "SetupSessionWindow", function(_, windowArg)
            local window = type(windowArg) == "number" and _G["DamageMeterSessionWindow" .. windowArg] or windowArg
            if not window then
                return
            end
            C_Timer_After(0, function()
                if cfg.enableHover and fadeManager.isFaded then
                    if window.Header then
                        window.Header:SetAlpha(0)
                    end
                    if window.bg then
                        window.bg:SetAlpha(0)
                    end
                    if window.SettingsDropdown then
                        window.SettingsDropdown:SetAlpha(0)
                    end
                    if window.SessionDropdown then
                        window.SessionDropdown:SetAlpha(0)
                    end
                    if window.MinimizeButton then
                        window.MinimizeButton:SetAlpha(0)
                    end
                    if window.DamageMeterTypeDropdown then
                        window.DamageMeterTypeDropdown:SetAlpha(0)
                    end
                    if window.SessionTimer then
                        window.SessionTimer:SetAlpha(0)
                    end
                end
            end)
            C_Timer_After(0.5, function()
                if cfg.enableHover then
                    updateFadeTargets(window)
                    if fadeManager.isFaded then
                        local targets = windowFadeTargets[window]
                        if targets then
                            for _, obj in ipairs(targets) do
                                if obj.SetAlpha then
                                    obj:SetAlpha(0)
                                end
                            end
                        end
                    end
                end
            end)
        end)
        hoverHooked = true
    end

    module:ForEachWindow(function(window)
        updateFadeTargets(window)
    end)

    if not cfg.enableHover then
        forceResetAlpha()
    elseif fadeManager.isFaded then
        setTargetsAlpha(0)
    else
        setTargetsAlpha(1)
    end
end

function module.Hover:Init()
    cfg = module.cfg

    if fadeManager.ticker then
        fadeManager.ticker:Cancel()
        fadeManager.ticker = nil
    end
    fadeManager.isFaded = false
    fadeManager.lastFocusObj = nil

    self:RefreshTargets()

    if cfg.enableHover then
        fadeManager.lastHoverTime = GetTime()
        fadeManager.ticker = C_Timer.NewTicker(CHECK_FREQUENCY, checkMouseLoop)
    end
end
