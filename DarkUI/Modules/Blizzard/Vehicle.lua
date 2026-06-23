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
    anchor:SetPoint(unpack(cfg.vehicle_pos))

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
        for i = 1, self:GetNumChildren() do
            local child = select(i, self:GetChildren())
            if child and child:IsObjectType("Button") and not child.__darkHooked then
                child:HookScript("OnEnter", function() VehicleSeatIndicator:SetAlpha(1) end)
                child:HookScript("OnLeave", function() VehicleSeatIndicator:SetAlpha(0) end)
                child.__darkHooked = true
            end
        end
    end)
    VehicleSeatIndicator:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
    VehicleSeatIndicator:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
end
