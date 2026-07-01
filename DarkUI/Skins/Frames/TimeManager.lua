local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Time Manager / Stopwatch
-- Ported from AuroraClassic FrameXML/TimeManager.lua (2026-06)
------------------------------------------------------------------------

local _G = _G

function S:TimeManager()
    if not C.general.skins then return end

    _G.TimeManagerGlobe:Hide()

    local stopwatchCheck = _G.TimeManagerStopwatchCheck
    stopwatchCheck:GetNormalTexture():SetTexCoord(unpack(C.media.texCoord))
    stopwatchCheck:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    stopwatchCheck:SetCheckedTexture(C.media.button.glow)
    stopwatchCheck:CreateBackdrop()

    S:ReskinDropDown(_G.TimeManagerAlarmTimeFrame.HourDropdown)
    S:ReskinDropDown(_G.TimeManagerAlarmTimeFrame.MinuteDropdown)
    S:ReskinDropDown(_G.TimeManagerAlarmTimeFrame.AMPMDropdown)

    S:ReskinPortraitFrame(_G.TimeManagerFrame)
    S:ReskinEditBox(_G.TimeManagerAlarmMessageEditBox)
    S:ReskinCheck(_G.TimeManagerAlarmEnabledButton)
    S:ReskinCheck(_G.TimeManagerMilitaryTimeCheck)
    S:ReskinCheck(_G.TimeManagerLocalTimeCheck)

    _G.StopwatchFrame:StripTextures()
    _G.StopwatchTabFrame:StripTextures()
    S:CreateBackground(_G.StopwatchFrame)
    S:ReskinClose(_G.StopwatchCloseButton, _G.StopwatchFrame, -2, -2)

    local reset = _G.StopwatchResetButton
    reset:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.27, 0.75)
    reset:SetSize(18, 18)
    reset:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    reset:SetPoint("BOTTOMRIGHT", -5, 7)

    local play = _G.StopwatchPlayPauseButton
    play:GetNormalTexture():SetTexCoord(0.25, 0.75, 0.27, 0.75)
    play:SetSize(18, 18)
    play:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
    play:SetPoint("RIGHT", reset, "LEFT", -2, 0)
end

S:AddCallbackForAddon("Blizzard_TimeManager", "TimeManager")
