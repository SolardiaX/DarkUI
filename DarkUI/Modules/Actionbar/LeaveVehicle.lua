local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--	Button for Leave Vehicle (modified from ShestakUI)
----------------------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local UnitOnTaxi, TaxiRequestEarlyLanding = UnitOnTaxi, TaxiRequestEarlyLanding
local CanExitVehicle, VehicleExit = CanExitVehicle, VehicleExit
local MainMenuBarVehicleLeaveButton_OnEnter = MainMenuBarVehicleLeaveButton_OnEnter
local GameTooltip_Hide = GameTooltip_Hide
local RegisterStateDriver = RegisterStateDriver
local unpack = unpack
local UIParent = _G.UIParent

local cfg = C.actionbar.bars.leave_vehicle


--create the frame to hold the buttons
local frame = CreateFrame("Frame", "DarkUI_LeaveVehicleHolder", UIParent, "SecureHandlerStateTemplate")
frame:SetWidth(cfg.button.size)
frame:SetHeight(cfg.button.size)
frame:SetPoint(unpack(cfg.pos))

--the button
local button = CreateFrame("CheckButton", "LeaveVehicleButton", frame, "ActionButtonTemplate, SecureHandlerClickTemplate")
button:SetSize(cfg.button.size, cfg.button.size)
button:SetAllPoints()
button:RegisterForClicks("AnyUp")
button.icon:SetTexture(C.media.button.vehicleexit)
button:SetNormalTexture(nil)

local function onClick(self)
    if UnitOnTaxi("player") then
        TaxiRequestEarlyLanding()
    else
        VehicleExit()
    end
    self:SetChecked(false)
end
button:SetScript("OnClick", onClick)
button:SetScript("OnEnter", MainMenuBarVehicleLeaveButton_OnEnter)
button:SetScript("OnLeave", GameTooltip_Hide)

--frame visibility
frame.frameVisibility = "[canexitvehicle]c;[mounted]m;n"
RegisterStateDriver(frame, "exit", frame.frameVisibility)

frame:SetAttribute("_onstate-exit", [[ if CanExitVehicle() then self:Show() else self:Hide() end ]])
if not CanExitVehicle() then frame:Hide() end
