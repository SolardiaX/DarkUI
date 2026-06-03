local E, C, L = select(2, ...):unpack()

-- ActionBar
local module = E:Module("Actionbar")
module:SetSecure()
module:SetConfigKey("actionbar.bars")

local scripts = {
    "OnShow",
    "OnHide",
    "OnEvent",
    "OnEnter",
    "OnLeave",
    "OnUpdate",
    "OnValueChanged",
    "OnClick",
    "OnMouseDown",
    "OnMouseUp",
}

local framesToHide = {
    MainMenuBar,
    MultiBarBottomLeft,
    MultiBarBottomRight,
    MultiBarLeft,
    MultiBarRight,
    MultiBar5,
    MultiBar6,
    MultiBar7,
    OverrideActionBar,
    PossessActionBar,
    PetActionBar,
}

local framesToDisable = {
    MainMenuBar,
    MultiBarBottomLeft,
    MultiBarBottomRight,
    MultiBarLeft,
    MultiBarRight,
    MultiBar5,
    MultiBar6,
    MultiBar7,
    PossessActionBar,
    PetActionBar,
    MicroButtonAndBagsBar,
    StatusTrackingBarManager,
    OverrideActionBar,
    OverrideActionBarExpBar,
    OverrideActionBarHealthBar,
    OverrideActionBarPowerBar,
    OverrideActionBarPitchFrame,
}

local function disableAllScripts(frame)
    for _, script in next, scripts do
        if frame:HasScript(script) then
            frame:SetScript(script, nil)
        end
    end
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

local function disableDefaultBarEvents()
    MainMenuBar.SetPositionForStatusBars = E.Dummy
    MultiActionBar_HideAllGrids = E.Dummy
    MultiActionBar_ShowAllGrids = E.Dummy

    ActionBarController:UnregisterAllEvents()
    ActionBarController:RegisterEvent("SETTINGS_LOADED")
    ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
    ActionBarActionEventsFrame:UnregisterAllEvents()

    ActionBarButtonEventsFrame:UnregisterAllEvents()
    ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")

    hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
    buttonEventsRegisterFrame(ActionBarButtonEventsFrame)

    SettingsPanel.TransitionBackOpeningPanel = HideUIPanel
end

function module:OnInit()
    for _, frame in next, framesToHide do
        if frame then
            frame:SetParent(E.FrameHider)
        end
    end

    for _, frame in next, framesToDisable do
        if frame then
            frame:UnregisterAllEvents()
            disableAllScripts(frame)
        end
    end

    disableDefaultBarEvents()

    MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")

    if StatusTrackingBarManager then
        StatusTrackingBarManager:UnregisterAllEvents()
        StatusTrackingBarManager:Hide()
    end
end

function module:OnEnable()
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", function()
        if TokenFrame and TokenFrame.Update then
            TokenFrame:Update()
        end
    end)
end
