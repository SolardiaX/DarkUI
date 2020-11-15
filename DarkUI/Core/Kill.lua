local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Kill all stuff on default UI that we don't need
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
    if addon == "Blizzard_AchievementUI" then
		if C.tooltip.enable then
        hooksecurefunc("AchievementFrameCategories_DisplayButton", function(button) button.showTooltipFunc = nil end)
    end
	end

	if C.unitframe.enable then
    InterfaceOptionsFrameCategoriesButton10:SetScale(0.00001)
    InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)
    if not InCombatLockdown() then
        CompactRaidFrameManager:Kill()
        CompactRaidFrameContainer:Kill()
    end
		ShowPartyFrame = E.dummy
		HidePartyFrame = E.dummy
		CompactUnitFrameProfiles_ApplyProfile = E.dummy
		CompactRaidFrameManager_UpdateShown = E.dummy
		CompactRaidFrameManager_UpdateOptionsFlowContainer = E.dummy
	end

    Display_UseUIScale:Kill()
	Display_UIScaleSlider:Kill()
	TutorialFrameAlertButton:Kill()
	--FIXME HelpOpenTicketButtonTutorial:Kill()
	-- TalentMicroButtonAlert:Kill()
	-- CollectionsMicroButtonAlert:Kill()
	-- ReagentBankHelpBox:Kill()
	-- BagHelpBox:Kill()
	-- EJMicroButtonAlert:Kill()
	-- PremadeGroupsPvETutorialAlert:Kill()

    SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_WORLD_MAP_FRAME, true)
    SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_PET_JOURNAL, true)
    SetCVarBitfield("closedInfoFrames", LE_FRAME_TUTORIAL_GARRISON_BUILDING, true)

    SetCVar("countdownForCooldowns", 0)
	InterfaceOptionsActionBarsPanelCountdownCooldowns:Kill()

	SetCVar("fstack_preferParentKeys", 0)
	if C.chat.enable then
    SetCVar("chatStyle", "im")
	end
	if C.unitframe.enable then
		InterfaceOptionsCombatPanelTargetOfTarget:Kill()
		SetCVar("showPartyBackground", 0)
	end
	if C.actionbar.enable then
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
		InterfaceOptionsActionBarsPanelStackRightBars:Kill()
		if not InCombatLockdown() then
			SetCVar("multiBarRightVerticalLayout", 0)
		end
	end
	if C.nameplate.enable then
    SetCVar("ShowClassColorInNameplate", 1)
	end

	if C.map.minimap.enable then
		InterfaceOptionsDisplayPanelRotateMinimap:Kill()
	end

	if C.bags.enable then
    SetSortBagsRightToLeft(true)
    SetInsertItemsLeftToRight(false)
	end
end)
local function AcknowledgeTips()
	if InCombatLockdown() then return end
	for frame in _G.HelpTip.framePool:EnumerateActive() do
		frame:Acknowledge()
	end
end
AcknowledgeTips()
hooksecurefunc(_G.HelpTip, "Show", AcknowledgeTips)