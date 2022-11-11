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

-- override default blizzard event function
if E.class == "DRUID" then
	local onEvent = ClassPowerBar.OnEvent
	local frame = CreateFrame("Frame")
	frame:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
	frame:SetScript("OnEvent", function()
		if ClassPowerBar.OnEvent == E.dummy and GetShapeshiftFormID() == CAT_FORM then
			ComboPointDruidPlayerFrame:Setup()
			ComboPointDruidPlayerFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
			ComboPointDruidPlayerFrame:SetPoint("TOP")

			ClassPowerBar.OnEvent = onEvent
		end
	end)

	ClassPowerBar.OnEvent = E.dummy
end