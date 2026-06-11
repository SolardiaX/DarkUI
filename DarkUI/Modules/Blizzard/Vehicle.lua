local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Vehicle Seat Indicator
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("Vehicle")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    local anchor = CreateFrame("Frame", "DarkUI_VehicleAnchor", UIParent)
    anchor:SetSize(130, 130)
    anchor:SetPoint("BOTTOM", UIParent, "BOTTOM", -350, 80)

    hooksecurefunc(VehicleSeatIndicator, "SetPoint", function(self, _, parent)
        if parent and parent ~= anchor then
            self:ClearAllPoints()
            self:SetPoint("BOTTOM", anchor, "BOTTOM", 0, 0)
            self:SetFrameStrata("LOW")
        end
    end)

    VehicleSeatIndicator:SetAlpha(0)
    VehicleSeatIndicator:HookScript("OnShow", function(self)
        self:SetAlpha(0)
    end)
    VehicleSeatIndicator:HookScript("OnEnter", function(self)
        self:SetAlpha(1)
    end)
    VehicleSeatIndicator:HookScript("OnLeave", function(self)
        self:SetAlpha(0)
    end)

    hooksecurefunc("VehicleSeatIndicator_SetUpVehicle", function(self, vehicleID)
        if not self:IsShown() then return end
        local _, numSeat = GetVehicleUIIndicator(vehicleID)
        for i = 1, numSeat do
            local button = _G["VehicleSeatIndicatorButton" .. i]
            if button then
                button:HookScript("OnEnter", function()
                    VehicleSeatIndicator:SetAlpha(1)
                end)
                button:HookScript("OnLeave", function()
                    VehicleSeatIndicator:SetAlpha(0)
                end)
            end
        end
    end)
end
