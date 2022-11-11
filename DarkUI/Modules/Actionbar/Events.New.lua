local E, C, L = select(2, ...):unpack()

if not C.actionbar.bars.enable then return end

----------------------------------------------------------------------------------------
--  Hide Blizzard ActionBars stuff(modified from ShestakUI)
----------------------------------------------------------------------------------------

local NUM_STANCE_SLOTS = NUM_STANCE_SLOTS or 10
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
	MainMenuBar:SetScale(0.00001)
	MainMenuBar:EnableMouse(false)
	OverrideActionBar:SetScale(0.00001)
	OverrideActionBar:EnableMouse(false)
	PetActionBar:EnableMouse(false)
	StanceBar:EnableMouse(false)
	MicroButtonAndBagsBar:SetScale(0.00001)
	MicroButtonAndBagsBar:EnableMouse(false)
	MicroButtonAndBagsBar:ClearAllPoints()
	MainMenuBar:SetMovable(true)
	MainMenuBar:SetUserPlaced(true)
	MainMenuBar.ignoreFramePositionManager = true
	MainMenuBar:SetAttribute("ignoreFramePositionManager", true)

	local elements = {
		MainMenuBar, MainMenuBarArtFrame, OverrideActionBar, PossessBarFrame, PetActionBar, StanceBar,
		MultiBarBottomLeft.QuickKeybindGlow, MultiBarLeft.QuickKeybindGlow, MultiBarBottomRight.QuickKeybindGlow, MultiBarRight.QuickKeybindGlow,
		StatusTrackingBarManager
	}

	if not C_ClassTrial.IsClassTrialCharacter() then
		tinsert(elements, IconIntroTracker)
	end

	for _, element in pairs(elements) do
		if element.UnregisterAllEvents then
			element:UnregisterAllEvents()
		end

		if element ~= MainMenuBar then
			element:Hide()
		end
		element:SetAlpha(0)
	end

	for i = 1, 6 do
		local b = _G["OverrideActionBarButton"..i]
		b:UnregisterAllEvents()
		b:SetAttribute("statehidden", true)
		b:SetAttribute("showgrid", 1)
	end

	hooksecurefunc("TalentFrame_LoadUI", function()
		PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	end)
end)
