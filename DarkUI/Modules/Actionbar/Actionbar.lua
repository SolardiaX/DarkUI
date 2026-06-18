local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- ActionBar
----------------------------------------------------------------------------------------
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
    MainActionBar,
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
    StanceBar,
}

local framesToDisable = {
    MainActionBar,
    MultiBarBottomLeft,
    MultiBarBottomRight,
    MultiBarLeft,
    MultiBarRight,
    MultiBar5,
    MultiBar6,
    MultiBar7,
    PossessActionBar,
    PetActionBar,
    StanceBar,
    MicroButtonAndBagsBar,
    StatusTrackingBarManager,
    MainMenuBarVehicleLeaveButton,
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
    ActionBarController:UnregisterAllEvents()
    ActionBarController:RegisterEvent("SETTINGS_LOADED")
    ActionBarController:RegisterEvent("UPDATE_EXTRA_ACTIONBAR")
    ActionBarActionEventsFrame:UnregisterAllEvents()

    ActionBarButtonEventsFrame:UnregisterAllEvents()
    ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_SLOT_CHANGED")
    ActionBarButtonEventsFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    hooksecurefunc(ActionBarButtonEventsFrame, "RegisterFrame", buttonEventsRegisterFrame)
    buttonEventsRegisterFrame(ActionBarButtonEventsFrame)

    MultiActionBar_ShowAllGrids = E.Dummy
end

function module:OnInit()
    C_CVar.SetCVar("multiBarRightVerticalLayout", 0)
    C_CVar.SetCVar("lockActionBars", 1)
    C_CVar.SetCVar("alwaysShowActionBars", 1)

    for _, frame in next, framesToHide do
        frame:SetParent(E.FrameHider)
    end

    for _, frame in next, framesToDisable do
        frame:UnregisterAllEvents()
        disableAllScripts(frame)
    end

    disableDefaultBarEvents()

    MainMenuBarVehicleLeaveButton:RegisterEvent("PLAYER_ENTERING_WORLD")

    StatusTrackingBarManager:UnregisterAllEvents()
    StatusTrackingBarManager:Hide()
end

function module:OnEnable()
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", function()
        if TokenFrame and TokenFrame.Update then
            TokenFrame:Update()
        end
    end)
end
