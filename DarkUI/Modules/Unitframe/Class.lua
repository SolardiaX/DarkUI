local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Special Class Methods of UnitFrame
----------------------------------------------------------------------------------------

local module = E.unitframe

local _G = _G
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local select, unpack, abs, min, max = select, unpack, math.abs, math.min, math.max
local hooksecurefunc = hooksecurefunc
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

module.classModule = {}

-- Combo Points
module.classModule.UpdateClassBarPosition = function(self, ...)
    PlayerFrameBottomManagedFramesContainer:ClearAllPoints()
    PlayerFrameBottomManagedFramesContainer:SetParent(self)
    PlayerFrameBottomManagedFramesContainer:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)
    PlayerFrameBottomManagedFramesContainer.SetPoint = function() end
end

-- override default blizzard event function for Druid class
if E.class == "DRUID" then
    local comboPointDruidEvent = ComboPointDruidPlayerFrame.OnEvent
    ComboPointDruidPlayerFrame:SetScript("OnEvent", function(self, event, ...)
        if self:GetParent() ~= PlayerFrameBottomManagedFramesContainer then
            self:SetParent(PlayerFrameBottomManagedFramesContainer)
        end

        if self.unit ~= "player" then
            self.unit = "player"
        end

        comboPointDruidEvent(self, event, ...)
    end)

    local comboPointDruidUpdateMaxPower = ComboPointDruidPlayerFrame.UpdateMaxPower
    ComboPointDruidPlayerFrame.UpdateMaxPower = function(self)
        self.classResourceButtonPool:ReleaseAll()
        self.classResourceButtonTable = { }

        self.unit = "player"
        self.maxUsablePoints = UnitPowerMax(self.unit, self.powerType);
        for i = 1, self.maxUsablePoints do
            local resourcePoint = self.classResourceButtonPool:Acquire()
            self.classResourceButtonTable[i] = resourcePoint
            if(self.resourcePointSetupFunc) then
                self.resourcePointSetupFunc(resourcePoint)
            end
            resourcePoint.layoutIndex = i
            resourcePoint:Show()
        end

        self:Layout()
    end

    ClassNameplateBarDruidFrame:Kill()
end
