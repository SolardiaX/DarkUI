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
    ActionBarDownButton, ActionBarUpButton,
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

local function updateTokenVisibility()
	TokenFrame_LoadUI()
	TokenFrame_Update()
end

MainMenuBar:SetMovable(true)
MainMenuBar:SetUserPlaced(true)
MainMenuBar.ignoreFramePositionManager = true
MainMenuBar:SetAttribute("ignoreFramePositionManager", true)
for _, frame in next, framesToHide do frame:SetParent(E.FrameHider) end

for _, frame in next, framesToDisable do
    frame:UnregisterAllEvents()
    DisableAllScripts(frame)
end

-- Fix maw block anchor
MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Update token panel
E:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)