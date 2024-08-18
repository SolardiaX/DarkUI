local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--    Button for Leave Vehicle (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("Actionbar"):Sub("LeaveVehicle")

local _G = _G
local CreateFrame = CreateFrame
local UnitOnTaxi, TaxiRequestEarlyLanding = UnitOnTaxi, TaxiRequestEarlyLanding
local CanExitVehicle, VehicleExit = CanExitVehicle, VehicleExit
local MainMenuBarVehicleLeaveButton = MainMenuBarVehicleLeaveButton
local PossessActionBar = PossessActionBar
local GetPossessInfo, CancelPetPossess = GetPossessInfo, CancelPetPossess
local IsPossessBarVisible = IsPossessBarVisible
local hooksecurefunc = hooksecurefunc
local unpack, tinsert = unpack, tinsert
local UIParent = _G.UIParent
local GameTooltip, GameTooltip_SetTitle = _G.GameTooltip, _G.GameTooltip_SetTitle
local NUM_POSSESS_SLOTS = NUM_POSSESS_SLOTS
local TAXI_CANCEL, TAXI_CANCEL_DESCRIPTION, CANCEL, LEAVE_VEHICLE = TAXI_CANCEL, TAXI_CANCEL_DESCRIPTION, CANCEL, LEAVE_VEHICLE

local cfg = C.actionbar.bars.leave_vehicle

function module:OnInit()
    --create the frame to hold the buttons
    local frame = CreateFrame("Frame", "DarkUI_LeaveVehicleHolder", UIParent)
    frame:SetSize(cfg.button.size, cfg.button.size)
    frame:SetPoint(unpack(cfg.pos))
    frame.buttonList = {}

    --the button
    local button = CreateFrame("CheckButton", "DarkUI_LeaveVehicleButton", UIParent)
    button:SetSize(cfg.button.size, cfg.button.size)
    button:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    button:RegisterForClicks("AnyUp")

    E:StyleButton(button, 2)

    button:SetNormalTexture(C.media.path .. "btn_vehicleexit")
    button:GetNormalTexture():ClearAllPoints()
    button:GetNormalTexture():SetAllPoints()
    
    button:Hide()

    tinsert(frame.buttonList, button)

    --create the mouseover functionality
    if cfg.fader_mouseover then
        E:ButtonBarFader(frame, frame.buttonList, cfg.fader_mouseover.fadeIn, cfg.fader_mouseover.fadeOut)
    end

    --create the combat fader
    if cfg.fader_combat then
        E:CombatFrameFader(frame, cfg.fader_combat.fadeIn, cfg.fader_combat.fadeOut)
    end

    hooksecurefunc(MainMenuBarVehicleLeaveButton, "Update", function()
        if CanExitVehicle() then
            if UnitOnTaxi("player") then
                button:SetScript("OnClick", function(self)
                    TaxiRequestEarlyLanding()
                    self:LockHighlight()
                end)
            else
                button:SetScript("OnClick", function()
                    VehicleExit()
                end)
            end
            button:Show()
        else
            button:UnlockHighlight()
            button:Hide()
        end
    end)

    hooksecurefunc(PossessActionBar, "UpdateState", function()
        for i = 1, NUM_POSSESS_SLOTS do
            local _, _, enabled = GetPossessInfo(i)
            if enabled then
                button:SetScript("OnClick", function()
                    CancelPetPossess()
                end)
                button:Show()
            else
                button:Hide()
            end
        end
    end)

    -- Set tooltip
    button:SetScript("OnEnter", function(self)
        if UnitOnTaxi("player") then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(TAXI_CANCEL, 1, 1, 1)
            GameTooltip:AddLine(TAXI_CANCEL_DESCRIPTION, 1, 0.8, 0, true)
            GameTooltip:Show()
        elseif IsPossessBarVisible() then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip_SetTitle(GameTooltip, CANCEL)
        else
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip_SetTitle(GameTooltip, LEAVE_VEHICLE)
        end
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
end