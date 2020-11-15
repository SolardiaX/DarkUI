local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--  ActionBars events to hide Blizzard (modified from rActionBarStyler)
----------------------------------------------------------------------------------------

local _G = _G
local ActionButton_ShowGrid = ActionButton_ShowGrid
local CreateFrame = CreateFrame
local GetCVar = GetCVar
local InCombatLockdown = InCombatLockdown
local tonumber, next = tonumber, next
local hooksecurefunc = hooksecurefunc
local ACTION_BUTTON_SHOW_GRID_REASON_CVAR = ACTION_BUTTON_SHOW_GRID_REASON_CVAR

local scripts = {
    "OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}

local framesToHide = {
    MainMenuBar, OverrideActionBar,
}

local framesToDisable = {
    MainMenuBar,
    MicroButtonAndBagsBar, MainMenuBarArtFrame, StatusTrackingBarManager,
    ActionBarDownButton, ActionBarUpButton, MainMenuBarVehicleLeaveButton,
    OverrideActionBar,
    OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame,
}

local function DisableAllScripts(frame)
    for _, script in next, scripts do
        if frame:HasScript(script) then
            frame:SetScript(script, nil)
        end
    end
end

-- Update button grid
local function buttonShowGrid(name, showgrid)
    for i = 1, 12 do
        local button = _G[name .. i]
		if button then
        	button:SetAttribute("showgrid", showgrid)
            button:ShowGrid(ACTION_BUTTON_SHOW_GRID_REASON_CVAR)
        end
    end
end

local toggle = CreateFrame("Frame")
local updateAfterCombat = false
local function ToggleButtonGrid()
    if InCombatLockdown() then
        updateAfterCombat = true
        toggle:RegisterEvent("PLAYER_REGEN_ENABLED")
        toggle:SetScript("OnEvent", ToggleButtonGrid)
    else
        local showgrid = tonumber(GetCVar("alwaysShowActionBars"))
        buttonShowGrid("ActionButton", showgrid)
        buttonShowGrid("MultiBarLeftButton", showgrid)
        buttonShowGrid("MultiBarRightButton", showgrid)
        buttonShowGrid("MultiBarBottomLeftButton", showgrid)
        buttonShowGrid("MultiBarBottomRightButton", showgrid)
        if updateAfterCombat then
            toggle:UnregisterEvent("PLAYER_REGEN_ENABLED")
            updateAfterCombat = false
        end
    end
end

for _, frame in next, framesToHide do frame:Kill() end

for _, frame in next, framesToDisable do
    frame:UnregisterAllEvents()
    DisableAllScripts(frame)
end

hooksecurefunc("MultiActionBar_UpdateGridVisibility", ToggleButtonGrid)

local function updateToken()
    TokenFrame_LoadUI()
    TokenFrame_Update()
    BackpackTokenFrame_Update()
end

-- Update token panel
local updater = CreateFrame("Frame")
updater:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
updater:SetScript("OnEvent", updateToken)