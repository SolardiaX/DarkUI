local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Kill all stuff on default UI that we don't need
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
    if C.unitframe.enable then
        -- if not InCombatLockdown() then
        --     CompactRaidFrameManager:Kill()
        --     CompactRaidFrameContainer:Kill()
        -- end
        -- ShowPartyFrame = E.dummy
        -- HidePartyFrame = E.dummy
        -- CompactUnitFrameProfiles_ApplyProfile = E.dummy
        -- CompactRaidFrameManager_UpdateShown = E.dummy
        -- CompactRaidFrameManager_UpdateOptionsFlowContainer = E.dummy
        if CompactRaidFrameManager then
            local function HideFrames()
                CompactRaidFrameManager:UnregisterAllEvents()
                CompactRaidFrameContainer:UnregisterAllEvents()
                if not InCombatLockdown() then
                    CompactRaidFrameManager:Hide()
                    local shown = CompactRaidFrameManager_GetSetting("IsShown")
                    if shown and shown ~= "0" then
                        CompactRaidFrameManager_SetSetting("IsShown", "0")
                    end
                end
            end
            local hiddenFrame = CreateFrame("Frame")
            hiddenFrame:Hide()
            hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideFrames)
            CompactRaidFrameManager:HookScript("OnShow", HideFrames)
            CompactRaidFrameContainer:HookScript("OnShow", HideFrames)
            HideFrames()
        end
    end

    TutorialFrameAlertButton:Kill()

    if C.chat.enable then
        SetCVar("chatStyle", "im")
    end

    if C.unitframe.enable then
        SetCVar("showPartyBackground", 0)
    end

    if C.actionbar.bars.enable then
        if not InCombatLockdown() then
            SetCVar("multiBarRightVerticalLayout", 0)
        end
    end

    if C.nameplate.enable then
        SetCVar("ShowClassColorInNameplate", 1)
    end

    if C.map.minimap.enable then
        SetCVar("minimapTrackingShowAll", 1)
    end

    if C.actionbar.bars.enable and C.actionbar.bars.bags.enable then
        if not E.newPatch then -- BETA
			SetSortBagsRightToLeft(true)
			SetInsertItemsLeftToRight(false)
		else
			C_Container.SetSortBagsRightToLeft(true)
			C_Container.SetInsertItemsLeftToRight(false)
		end
    end

    if C.combat.combattext.enable then
		--BETA InterfaceOptionsCombatPanelEnableFloatingCombatText:Hide()
		if C.combat.combattext.incoming then
			SetCVar("enableFloatingCombatText", 1)
		else
			SetCVar("enableFloatingCombatText", 0)
		end
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