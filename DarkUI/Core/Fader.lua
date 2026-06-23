local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Fader
----------------------------------------------------------------------------------------

local next = next
local defaultFadeIn = { time = 0.4, alpha = 1 }
local defaultFadeOut = { time = 0.3, alpha = 0 }

local FADEFRAMES = {}
local FADEMANAGER = CreateFrame("Frame")
FADEMANAGER.delay = 0.05

local function fadeOnUpdate(_, elapsed)
    FADEMANAGER.timer = (FADEMANAGER.timer or 0) + elapsed

    if FADEMANAGER.timer > FADEMANAGER.delay then
        FADEMANAGER.timer = 0

        for frame, info in next, FADEFRAMES do
            if frame:IsVisible() then
                info.fadeTimer = (info.fadeTimer or 0) + (elapsed + FADEMANAGER.delay)
            else
                info.fadeTimer = info.timeToFade + 1
            end

            if info.fadeTimer < info.timeToFade then
                if info.mode == "IN" then
                    frame:SetAlpha((info.fadeTimer / info.timeToFade) * info.diffAlpha + info.startAlpha)
                else
                    frame:SetAlpha(((info.timeToFade - info.fadeTimer) / info.timeToFade) * info.diffAlpha + info.endAlpha)
                end
            else
                frame:SetAlpha(info.endAlpha)

                if info.fadeHoldTime and info.fadeHoldTime > 0 then
                    info.fadeHoldTime = info.fadeHoldTime - elapsed
                else
                    FADEFRAMES[frame] = nil

                    if info.finishedFunc then info.finishedFunc(frame) end
                end
            end
        end

        if not next(FADEFRAMES) then FADEMANAGER:SetScript("OnUpdate", nil) end
    end
end

function E:UIFrameFade(frame, info)
    if not frame or frame:IsForbidden() then return end

    if not info.mode then info.mode = "IN" end

    if info.mode == "IN" then
        if not info.startAlpha then info.startAlpha = 0 end
        if not info.endAlpha then info.endAlpha = 1 end
        if not info.diffAlpha then info.diffAlpha = info.endAlpha - info.startAlpha end
    else
        if not info.startAlpha then info.startAlpha = 1 end
        if not info.endAlpha then info.endAlpha = 0 end
        if not info.diffAlpha then info.diffAlpha = info.startAlpha - info.endAlpha end
    end

    frame:SetAlpha(info.startAlpha)

    if not FADEFRAMES[frame] then
        FADEFRAMES[frame] = info
        FADEMANAGER:SetScript("OnUpdate", fadeOnUpdate)
    else
        FADEFRAMES[frame] = info
    end
end

function E:UIFrameFadeIn(frame, timeToFade, startAlpha, endAlpha)
    if not frame or frame:IsForbidden() then return end

    if frame.__fadeObject then
        frame.__fadeObject.fadeTimer = nil
    else
        frame.__fadeObject = {}
    end

    frame.__fadeObject.mode = "IN"
    frame.__fadeObject.timeToFade = timeToFade
    frame.__fadeObject.startAlpha = startAlpha
    frame.__fadeObject.endAlpha = endAlpha
    frame.__fadeObject.diffAlpha = endAlpha - startAlpha

    E:UIFrameFade(frame, frame.__fadeObject)
end

function E:UIFrameFadeOut(frame, timeToFade, startAlpha, endAlpha)
    if not frame or frame:IsForbidden() then return end

    if frame.__fadeObject then
        frame.__fadeObject.fadeTimer = nil
    else
        frame.__fadeObject = {}
    end

    frame.__fadeObject.mode = "OUT"
    frame.__fadeObject.timeToFade = timeToFade
    frame.__fadeObject.startAlpha = startAlpha
    frame.__fadeObject.endAlpha = endAlpha
    frame.__fadeObject.diffAlpha = startAlpha - endAlpha

    E:UIFrameFade(frame, frame.__fadeObject)
end

function E:UIFrameFadeRemoveFrame(frame)
    if frame and FADEFRAMES[frame] then
        if frame.__fadeObject then frame.__fadeObject.fadeTimer = nil end
        FADEFRAMES[frame] = nil
    end
end

----------------------------------------------------------------------------------------
-- Bar / Frame Fader Utilities
----------------------------------------------------------------------------------------

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

function E:FrameFader(frame, fadeIn, fadeOut)
    if not frame then return end
    if not fadeIn then fadeIn = defaultFadeIn end
    if not fadeOut then fadeOut = defaultFadeOut end

    frame:EnableMouse(true)
    frame:HookScript("OnEnter", function() E:UIFrameFadeIn(frame, fadeIn.time, frame:GetAlpha(), fadeIn.alpha) end)
    frame:HookScript("OnLeave", function() E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha) end)
    E:UIFrameFadeOut(frame, fadeOut.time, frame:GetAlpha(), fadeOut.alpha)
end

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
