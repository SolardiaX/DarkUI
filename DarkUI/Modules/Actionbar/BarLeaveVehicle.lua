local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Leave Vehicle
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("LeaveVehicle")

local cfg = C.actionbar.bars.leave_vehicle

function module:OnInit()
    local frame = CreateFrame("Frame", "DarkUI_LeaveVehicleHolder", UIParent, "SecureHandlerStateTemplate")
    frame:SetSize(cfg.button.size, cfg.button.size)
    frame:SetPoint(unpack(cfg.pos))

    local button = CreateFrame("CheckButton", "DarkUI_LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
    button:SetSize(cfg.button.size, cfg.button.size)
    button:SetPoint("BOTTOMLEFT", frame, 0, 0)
    button:RegisterForClicks("AnyUp")

    button.icon:SetTexture("INTERFACE\\VEHICLES\\UI-Vehicles-Button-Exit-Up")
    button.icon:SetTexCoord(0.216, 0.784, 0.216, 0.784)
    button.icon:SetDrawLayer("ARTWORK")
    button.icon.__lockdown = true
    if button.Arrow then
        button.Arrow:SetAlpha(0)
    end

    E:Module("Actionbar").StyleActionButton(button, true)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        if UnitOnTaxi("player") then
            GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1)
            GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, 1, 0.8, 0, true)
        else
            GameTooltip:SetText(LEAVE_VEHICLE, 1, 1, 1)
        end
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        GameTooltip:Hide()
    end)
    button:SetScript("OnClick", function(self)
        if UnitOnTaxi("player") then
            TaxiRequestEarlyLanding()
        else
            VehicleExit()
        end
        self:SetChecked(true)
    end)
    button:SetScript("OnShow", function(self)
        self:SetChecked(false)
    end)

    frame.buttons = { button }
    frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
    RegisterStateDriver(frame, "exit", frame.frameVisibility)
    frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])

    if not CanExitVehicle() then
        frame:Hide()
    end

    if cfg.fader_mouseover then
        E:ButtonBarFader(frame, frame.buttons, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
    end

    if cfg.fader_combat then
        E:CombatFrameFader(frame, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
    end
end
