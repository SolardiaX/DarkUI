local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--    ActionBar (modified from NDui)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar")

local _G = _G
local TokenFrame_LoadUI, TokenFrame_Update = TokenFrame_LoadUI, TokenFrame_Update
local hooksecurefunc = hooksecurefunc
local next, tonumber, strmatch = next, tonumber, strmatch
local ACTION_BUTTON_SHOW_GRID_REASON_CVAR = ACTION_BUTTON_SHOW_GRID_REASON_CVAR

local scripts = {
    "OnShow", "OnHide", "OnEvent", "OnEnter", "OnLeave", "OnUpdate", "OnValueChanged", "OnClick", "OnMouseDown", "OnMouseUp",
}

local framesToHide = {
    MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, MultiBar5, MultiBar6, MultiBar7, OverrideActionBar, PossessActionBar, PetActionBar,
}

local framesToDisable = {
    MainMenuBar, MultiBarBottomLeft, MultiBarBottomRight, MultiBarLeft, MultiBarRight, MultiBar5, MultiBar6, MultiBar7, PossessActionBar, PetActionBar,
    MicroButtonAndBagsBar, StatusTrackingBarManager,
    OverrideActionBar,
    OverrideActionBarExpBar, OverrideActionBarHealthBar, OverrideActionBarPowerBar, OverrideActionBarPitchFrame,
}

local function disableAllScripts(frame)
    for _, script in next, scripts do
        if frame:HasScript(script) then
            frame:SetScript(script, nil)
        end
    end
end

local function updateTokenVisibility()
    TokenFrame_LoadUI()
    TokenFrame:Update()
end

local function buttonEventsRegisterFrame(self, added)
    local frames = self.frames
    for index = #frames, 1, -1 do
        local frame = frames[index]
        local wasAdded = frame == added
        if not added or wasAdded then
            if not strmatch(frame:GetName(), "ExtraActionButton%d") then
                self.frames[index] = nil
            end

            if wasAdded then
                break
            end
        end
    end
end

local function disableDefaultBarEvents() -- credit: Simpy
    -- MainMenuBar:ClearAllPoints taint during combat
    _G.MainMenuBar.SetPositionForStatusBars = E.Dummy

    -- Spellbook open in combat taint, only happens sometimes
    _G.MultiActionBar_HideAllGrids = E.Dummy
    _G.MultiActionBar_ShowAllGrids = E.Dummy
    
    -- shut down some events for things we dont use
    _G.ActionBarController:UnregisterAllEvents()
    _G.ActionBarController:RegisterEvent("SETTINGS_LOADED") -- this is needed for page controller to spawn properly
    _G.ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR") -- this is needed to let the ExtraActionBar show
    _G.ActionBarActionEventsFrame:UnregisterAllEvents()
    
    -- used for ExtraActionButton and TotemBar (on wrath)
    _G.ActionBarButtonEventsFrame:UnregisterAllEvents()
    _G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED") -- needed to let the ExtraActionButton show and Totems to swap
    _G.ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN") -- needed for cooldowns of them both
    
    hooksecurefunc(_G.ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
    buttonEventsRegisterFrame(_G.ActionBarButtonEventsFrame)
    
    -- fix keybind error, this actually just prevents reopen of the GameMenu
    _G.SettingsPanel.TransitionBackOpeningPanel = _G.HideUIPanel
end

function module:OnInit()
    for _, frame in next, framesToHide do
        frame:SetParent(E.FrameHider)
    end

    for _, frame in next, framesToDisable do
        frame:UnregisterAllEvents()
        disableAllScripts(frame)
    end

    disableDefaultBarEvents()

    -- Fix maw block anchor
    _G.MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")
    
    -- Update token panel
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", updateTokenVisibility)

    -- Hide blizzard expbar
    StatusTrackingBarManager:UnregisterAllEvents()
    StatusTrackingBarManager:Hide()
end