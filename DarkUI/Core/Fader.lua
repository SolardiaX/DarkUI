local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Core Fader Methods (modified from rLib)
----------------------------------------------------------------------------------------
local defaultFadeIn = { time = 0.4, alpha = 1 }
local defaultFadeOut = { time = 0.3, alpha = 0 }

local frameFadeManager = CreateFrame("FRAME")

-- Generic fade function
local function UIFrameFade(frame, fadeInfo)
    if not frame then return end

    if not fadeInfo.mode then fadeInfo.mode = "IN" end

    local alpha
    if fadeInfo.mode == "IN" then
        if not fadeInfo.startAlpha then fadeInfo.startAlpha = 0 end
        if not fadeInfo.endAlpha then fadeInfo.endAlpha = 1.0 end

        alpha = 0
    elseif fadeInfo.mode == "OUT" then
        if not fadeInfo.startAlpha then fadeInfo.startAlpha = 1.0 end
        if not fadeInfo.endAlpha then fadeInfo.endAlpha = 0 end

        alpha = 1.0
    end

    frame:SetAlpha(fadeInfo.startAlpha)
    frame.fadeInfo = fadeInfo

    local index = 1
    while FADEFRAMES[index] do
        -- If frame is already set to fade then return
        if (FADEFRAMES[index] == frame) then return end

        index = index + 1
    end

    tinsert(FADEFRAMES, frame)
    frameFadeManager:SetScript("OnUpdate", UIFrameFade_OnUpdate)
end

-- Convenience function to do a simple fade in
function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    local fadeInfo = {}

    fadeInfo.mode = "IN"
    fadeInfo.timeToFade = timeToFade
    fadeInfo.startAlpha = startAlpha
    fadeInfo.endAlpha = endAlpha
    UIFrameFade(frame, fadeInfo)
end

-- Convenience function to do a simple fade out
function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    local fadeInfo = {}

    fadeInfo.mode = "OUT"
    fadeInfo.timeToFade = timeToFade
    fadeInfo.startAlpha = startAlpha
    fadeInfo.endAlpha = endAlpha
    UIFrameFade(frame, fadeInfo)
end

--ButtonBarFader func
function E:ButtonBarFader(frame, buttonList, fadeIn, fadeOut)
    if not frame or not buttonList then return end
    if not fadeIn then fadeIn = defaultFadeIn end
    if not fadeOut then fadeOut = defaultFadeOut end

    frame:EnableMouse(true)
    frame:HookScript("OnEnter", function() E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha) end)
    frame:HookScript("OnLeave", function() E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha) end)
    E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha)

    for _, button in pairs(buttonList) do
        if button then
            button:HookScript("OnEnter", function() E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha) end)
            button:HookScript("OnLeave", function() E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha) end)
        end
    end
end

--SpellFlyoutFader func
--the flyout is special, when hovering the flyout the parented bar must not fade out
function E:SpellFlyoutFader(frame, buttonList, fadeIn, fadeOut)
    if not frame or not buttonList then return end
    if not fadeIn then fadeIn = defaultFadeIn end
    if not fadeOut then fadeOut = defaultFadeOut end

    SpellFlyout:HookScript("OnEnter", function() E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha) end)
    SpellFlyout:HookScript("OnLeave", function() E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha) end)

    for _, button in pairs(buttonList) do
        if button then
            button:HookScript("OnEnter", function() E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha) end)
            button:HookScript("OnLeave", function() E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha) end)
        end
    end
end

--FrameFader func
function E:FrameFader(frame, fadeIn, fadeOut)
    if not frame then return end
    if not fadeIn then fadeIn = defaultFadeIn end
    if not fadeOut then fadeOut = defaultFadeOut end

    frame:EnableMouse(true)
    frame:HookScript("OnEnter", function() E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha) end)
    frame:HookScript("OnLeave", function() E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha) end)
    E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha)
end

--CombatFrameFader func
function E:CombatFrameFader(frame, fadeIn, fadeOut)
    if not frame then return end
    if not fadeIn then fadeIn = defaultFadeIn end
    if not fadeOut then fadeOut = defaultFadeOut end

    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    frame:HookScript("OnEvent", function(_, event, ...)
        if event == "PLAYER_REGEN_DISABLED" then
            E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha)
        elseif event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" then
            E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha)
        end
    end)
end
