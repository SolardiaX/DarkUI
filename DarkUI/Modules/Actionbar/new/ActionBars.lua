local E, C, L, M = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	ActionBar (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = M:Module("Actionbar"):Sub("Actionbars")

local LAB = LibStub("LibActionButton-1.0")

local _G = _G
local CreateFrame = CreateFrame
local GetActionTexture = GetActionTexture
local RegisterStateDriver = RegisterStateDriver
local unpack = unpack
local UIParent = _G.UIParent

local num = NUM_ACTIONBAR_BUTTONS

local bars = {}
local BAR_DATA = {
    [1] = {page = 1, bindName = "ACTIONBUTTON", vertical = false, flyout="UP"},
    [2] = {page = 6, bindName = "MULTIACTIONBAR1BUTTON", vertical = false, flyout="UP"},
    [3] = {page = 5, bindName = "MULTIACTIONBAR2BUTTON", vertical = false, flyout="UP"},
    [4] = {page = 3, bindName = "MULTIACTIONBAR3BUTTON", vertical = true, flyout="LEFT"},
    [5] = {page = 4, bindName = "MULTIACTIONBAR4BUTTON", vertical = true, flyout="LEFT"},
    [6] = {page = 13, bindName = "MULTIACTIONBAR5BUTTON", vertical = false, flyout="UP"},
    [7] = {page = 14, bindName = "MULTIACTIONBAR6BUTTON", vertical = false, flyout="UP"},
    [8] = {page = 15, bindName = "MULTIACTIONBAR7BUTTON", vertical = false, flyout="UP"},
}

local fullPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"

local function updateButtonConfig(self, i)
    if not self.buttonConfig then
        self.buttonConfig = {
            hideElements = {},
            text = {
                hotkey = { font = {}, position = {} },
                count = { font = {}, position = {} },
                macro = { font = {}, position = {} },
            }
        }
    end
    self.buttonConfig.clickOnDown = true
    self.buttonConfig.showGrid = true
    self.buttonConfig.flyoutDirection = BAR_DATA[i].flyout

    local lockBars = GetCVarBool("lockActionBars")
    for _, button in next, self.buttons do
        self.buttonConfig.keyBoundTarget = button.bindName
        button.keyBoundTarget = self.buttonConfig.keyBoundTarget

        button:SetAttribute("buttonlock", lockBars)
        button:SetAttribute("unlockedpreventdrag", not lockBars) -- make sure button can drag without being click
        button:SetAttribute("checkmouseovercast", true)
        button:SetAttribute("checkfocuscast", true)
        button:SetAttribute("checkselfcast", true)
        button:SetAttribute("*unit2", "player")
        button:UpdateConfig(self.buttonConfig)

        -- button.backdrop:SetBackdropColor(.2, .2, .2, .25)
    end
end

local function updateBarConfig()
    for i = 1, 8 do
        local frame = _G["DarkUI_ActionBar"..i]
        if frame then
            updateButtonConfig(frame, i)
        end
    end
end

local function reassignBindings()
    if InCombatLockdown() then return end

    for index = 1, 8 do
        local frame = module.bars[index]
        for _, button in next, frame.buttons do
            for _, key in next, {GetBindingKey(button.keyBoundTarget)} do
                if key and key ~= "" then
                    SetOverrideBindingClick(frame, false, key, button:GetName(), "Keybind")
                end
            end
        end
    end
end

local function clearBindings()
    if InCombatLockdown() then return end

    for index = 1, 8 do
        local frame = module.bars[index]
        ClearOverrideBindings(frame)
    end
end

function module:CreateBars()
    self.bars = {}

    for index = 1, 8 do
        local cfg = C.actionbar.bars["bar"..index]
        local data = BAR_DATA[index]

        local bar = CreateFrame("Frame", "DarkUI_ActionBar"..index, UIParent, "SecureHandlerStateTemplate")
        bar.buttons = {}

        bar:SetPoint(unpack(cfg.pos))
        bar:SetHeight(data.vertical and num * cfg.button.size + (num - 1) * cfg.button.space or cfg.button.size)
        bar:SetWidth(data.vertical and cfg.button.size or num * cfg.button.size + (num - 1) * cfg.button.space)

        local previous
        for i = 1, num do 
            local button = LAB:CreateButton(i, "$parentButton"..i, bar)
            button:SetState(0, "action", i)
            button:SetSize(cfg.button.size, cfg.button.size)
            button:ClearAllPoints()
            if i == 1 then
                if data.vertical then
                    button:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
                else
                    button:SetPoint("BOTTOMLEFT", bar, 0, 0)
                end
            else
                if data.vertical then
                    button:SetPoint("TOP", previous, "BOTTOM", 0, -cfg.button.space)
                else
                    button:SetPoint("LEFT", previous, "RIGHT", cfg.button.space, 0)
                end
            end

            previous = button
        
            for k = 1, 18 do
                button:SetState(k, "action", (k - 1) * 12 + i)
            end
        
            if i == 12 then
                button:SetState(GetVehicleBarIndex(), "custom", {
                    func = function()
                        if UnitExists("vehicle") then
                            VehicleExit()
                        else
                            PetDismiss()
                        end
                    end,
                    texture = 136190, -- Spell_Shadow_SacrificialShield
                    tooltip = _G.LEAVE_VEHICLE,
                })
            end

            button.MasqueSkinned = true
            button.bindName = data.bindName..i

            tinsert(bar.buttons, button)
        end

        bar.visibility = index == 1 and "[petbattle] hide; show" or "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"

        bar:SetAttribute("_onstate-page", [[
            self:SetAttribute("state", newstate)
            control:ChildUpdate("state", newstate)
        ]])
        RegisterStateDriver(bar, "page", index == 1 and fullPage or data.page)

        LAB.RegisterCallback(self, "OnButtonUpdate", function(button)
            if not button.backdrop then return end

            if button.Border:IsShown() then
                button.backdrop:SetBackdropBorderColor(0, .7, .1)
            else
                button.backdrop:SetBackdropBorderColor(0, 0, 0)
            end
        end)

        local function delayUpdate()
            updateBarConfig()
            self:UnregisterEvent("PLAYER_REGEN_ENABLED", delayUpdate)
        end
    
        self:RegisterEvent("CVAR_UPDATE", function(_, var)
            if var == "lockActionBars" then
                if InCombatLockdown() then
                    self:RegisterEvent("PLAYER_REGEN_ENABLED", delayUpdate)
                    return
                end
                updateBarConfig()
            end
        end)

        self.bars[index] = bar
    end
end

function module:Init()
    self:CreateBars()

    updateBarConfig()

    if C_PetBattles.IsInBattle() then
        clearBindings()
    else
        reassignBindings()
    end

    module:RegisterEvent("UPDATE_BINDINGS", reassignBindings)
    module:RegisterEvent("PET_BATTLE_CLOSE", reassignBindings)
    module:RegisterEvent("PET_BATTLE_OPENING_DONE", clearBindings)
end
