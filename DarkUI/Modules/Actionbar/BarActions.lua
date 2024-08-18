local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--    ActionBars (modified from NDui)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("Bars")
local actionButton = LibStub("DarkUI-ActionButton")
local LAB = LibStub("LibActionButton-1.0")

local _G = _G
local CreateFrame = CreateFrame
local GetVehicleBarIndex = GetVehicleBarIndex
local VehicleExit, UnitExists = VehicleExit, UnitExists
local PetDismiss = PetDismiss
local InCombatLockdown = InCombatLockdown
local RegisterStateDriver = RegisterStateDriver
local C_PetBattles_IsInBattle = C_PetBattles.IsInBattle
local Settings = Settings
local unpack, tinsert = unpack, tinsert
local hooksecurefunc = hooksecurefunc
local UIParent = _G.UIParent

local num = NUM_ACTIONBAR_BUTTONS

local BAR_DATA = {
    [1] = {page = 1, bindName = "ACTIONBUTTON", vertical = false, flyout="UP"},
    [2] = {page = 6, bindName = "MULTIACTIONBAR1BUTTON", vertical = false, flyout="UP"},
    [3] = {page = 5, bindName = "MULTIACTIONBAR2BUTTON", vertical = false, flyout="UP"},
    [4] = {page = 3, bindName = "MULTIACTIONBAR3BUTTON", vertical = true, flyout="LEFT"},
    [5] = {page = 4, bindName = "MULTIACTIONBAR4BUTTON", vertical = true, flyout="LEFT"},
    [6] = {page = 13, bindName = "MULTIACTIONBAR5BUTTON", vertical = true, flyout="LEFT"},
    [7] = {page = 14, bindName = "MULTIACTIONBAR6BUTTON", vertical = false, flyout="UP"},
    [8] = {page = 15, bindName = "MULTIACTIONBAR7BUTTON", vertical = false, flyout="UP"},
}

local fullPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"

local function createBar(index, cfg, data)
    if not cfg.enable then return end

    local bar = CreateFrame("Frame", "DarkUI_ActionBar"..index, UIParent, "SecureHandlerStateTemplate")
    bar.buttons = {}
    bar.flyoutDirection = data.flyout

    bar:SetPoint(unpack(cfg.pos))
    bar:SetHeight(data.vertical and num * cfg.button.size + (num - 1) * cfg.button.space or cfg.button.size)
    bar:SetWidth(data.vertical and cfg.button.size or num * cfg.button.size + (num - 1) * cfg.button.space)

    local previous
    for i = 1, num do
        local button = actionButton:CreateButton(bar, i, cfg.button.size, data.bindName..i)

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

        tinsert(bar.buttons, button)
    end

    bar.visibility = index == 1 and "[petbattle] hide; show" or "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"

    bar:SetAttribute("_onstate-page", [[
        self:SetAttribute("state", newstate)
        control:ChildUpdate("state", newstate)
    ]])

    RegisterStateDriver(bar, "page", index == 1 and fullPage or data.page)
    RegisterStateDriver(bar, "visibility", bar.visibility)

    return bar
end

function module:OnInit()
    self.bars = {}

    local rightbars = CreateFrame("Frame", "DarkUI_ActionBarRight", UIParent, "SecureHandlerStateTemplate")
    rightbars.count = 0
    rightbars.buttons = {}
    rightbars.fader_mouseover = nil
    rightbars.fader_combat = nil

    local bottombars = CreateFrame("Frame", "DarkUI_ActionBarBottom", UIParent, "SecureHandlerStateTemplate")
    bottombars.count = 0
    bottombars.buttons = {}
    bottombars.fader_mouseover = nil
    bottombars.fader_combat = nil

    for i = 1, 8 do
        local cfg = C.actionbar.bars["bar"..i]
        local bar = createBar(i, cfg, BAR_DATA[i])

        if bar then
            -- handle right side bars
            if C.actionbar.bars.mergeright and (i == 4 or i == 5 or i == 6) then
                bar:SetParent(rightbars)

                if rightbars.count == 0 then
                    rightbars:SetPoint(bar:GetPoint())
                end

                rightbars.count = rightbars.count + 1
                rightbars:SetWidth(rightbars.count * cfg.button.size + (rightbars.count - 1) * cfg.button.space)
                rightbars:SetHeight(num * cfg.button.size + (num - 1) * cfg.button.space)
                
                for x = 1, num do
                    tinsert(rightbars.buttons, bar.buttons[x])
                end

                if cfg.fader_mouseover and not rightbars.fader_mouseover then
                    rightbars.fader_mouseover = cfg.fader_mouseover
                end
                cfg.fader_mouseover = nil -- disable self

                if cfg.fader_combat and not rightbars.fader_combat then
                    rightbars.fader_combat = cfg.fader_combat
                end
                cfg.fader_combat = nil -- disable self
            end

            -- handle bottom bars
            if C.actionbar.bars.mergebottom and (i == 7 or i == 8) then
                bar:SetParent(bottombars)

                if bottombars.count == 0 then
                    bottombars:SetPoint(bar:GetPoint())
                end

                bottombars.count = bottombars.count + 1
                bottombars:SetHeight(bottombars.count * cfg.button.size + (bottombars.count - 1) * cfg.button.space)
                bottombars:SetWidth(num * cfg.button.size + (num - 1) * cfg.button.space)
                
                for x = 1, num do
                    tinsert(bottombars.buttons, bar.buttons[x])
                end

                if cfg.fader_mouseover and not bottombars.fader_mouseover then
                    bottombars.fader_mouseover = cfg.fader_mouseover
                end
                cfg.fader_mouseover = nil -- disable self

                if cfg.fader_combat and not bottombars.fader_combat then
                    bottombars.fader_combat = cfg.fader_combat
                end
                cfg.fader_combat = nil -- disable self
            end

            --create the mouseover functionality
            if cfg.fader_mouseover then
                E:ButtonBarFader(bar, bar.buttons, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
            end

            --create the combat fader
            if cfg.fader_combat then
                E:CombatFrameFader(bar, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
            end

            bar.fader_mouseover = cfg.fader_mouseover -- keep config for flyout
        end

        self.bars[i] = bar
    end

    if rightbars.count then
        if rightbars.fader_mouseover then
            E:ButtonBarFader(rightbars, rightbars.buttons, rightbars.fader_mouseover.fadeIn, rightbars.fader_mouseover.fadeOut)
        end
        if rightbars.fader_combat then
            E:CombatFrameFader(rightbars, rightbars.fader_combat.fadeIn, rightbars.fader_combat.fadeOut)
        end
    end

    if bottombars.count then
        if bottombars.fader_mouseover then
            E:ButtonBarFader(bottombars, bottombars.buttons, bottombars.fader_mouseover.fadeIn, bottombars.fader_mouseover.fadeOut)
        end
        if bottombars.fader_combat then
            E:CombatFrameFader(bottombars, bottombars.fader_combat.fadeIn, bottombars.fader_combat.fadeOut)
        end
    end

    self.rightbars = rightbars
    self.bottombars = bottombars

    actionButton:UpdateBarConfig(self.bars)

    if C_PetBattles_IsInBattle() then
        actionButton:ClearBindings(self.bars)
    else
        actionButton:ReassignBindings(self.bars)
    end

    self:RegisterEvent("CVAR_UPDATE", function(_, _, var)
        if var == "lockActionBars" then
            if InCombatLockdown() then
                self:RegisterEventOnce("PLAYER_REGEN_ENABLED", function()
                    actionButton:UpdateBarConfig(self.bars)
                end)
            else
                actionButton:UpdateBarConfig(self.bars)
            end
        end
    end)

    self:RegisterEvent("UPDATE_BINDINGS PET_BATTLE_CLOSE", function() actionButton:ReassignBindings(self.bars) end)
    self:RegisterEvent("PET_BATTLE_OPENING_DONE", function() actionButton:ClearBindings(self.bars) end)

    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        -- sync to blizzard settings
        for i = 3, 8 do
            Settings.SetValue("PROXY_SHOW_ACTIONBAR_" .. i-1, C.actionbar.bars["bar"..i].enable)
        end

        hooksecurefunc(_G.SettingsPanel.Container.SettingsList.ScrollBox, 'Update', function(frame)
            for _, child in next, { frame.ScrollTarget:GetChildren() } do
                local option = child.data and child.data.setting
                local variable = option and option.variable
                if variable and strsub(variable, 0, -3) == 'PROXY_SHOW_ACTIONBAR' then
                    child:DisplayEnabled(false)

                    child.CheckBox:SetEnabled(false)
                    child.CheckBox:SetScript('OnEnter', nil)
                    child.Tooltip:SetScript('OnEnter', nil)
                end
            end
        end)
    end)

    -- fader with flyout
    LAB.flyoutHandler:HookScript("OnShow", function(self)
        local bar = self:GetParent():GetParent()
        if bar ~= UIParent then
            bar = bar:GetParent()
        end

        local fader_mouseover = bar.fader_mouseover
        if fader_mouseover then
            self:HookScript("OnEnter", function()
                E:UIFrameFadeIn(bar, fader_mouseover.fadeIn.time, bar:GetAlpha(), fader_mouseover.fadeIn.alpha) 
            end)
            self:HookScript("OnLeave", function() 
                E:UIFrameFadeOut(bar, fader_mouseover.fadeOut.time, bar:GetAlpha(), fader_mouseover.fadeOut.alpha) end
            )
            for _, button in next, LAB.FlyoutButtons do
                button:HookScript("OnEnter", function()
                    E:UIFrameFadeIn(bar, fader_mouseover.fadeIn.time, bar:GetAlpha(), fader_mouseover.fadeIn.alpha) 
                end)
                button:HookScript("OnLeave", function() 
                    E:UIFrameFadeOut(bar, fader_mouseover.fadeOut.time, bar:GetAlpha(), fader_mouseover.fadeOut.alpha) end
                )
            end
        end
    end)
end
