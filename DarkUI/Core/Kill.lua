local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Kill all stuff on default UI that we don't need
----------------------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(_, _, addon)
    if C.unitframe.enable then
        if not InCombatLockdown() then
            CompactRaidFrameManager:Kill()
            CompactRaidFrameContainer:Kill()
        end
        ShowPartyFrame = E.dummy
        HidePartyFrame = E.dummy
        CompactUnitFrameProfiles_ApplyProfile = E.dummy
        -- CompactRaidFrameManager_UpdateShown = E.dummy
        -- CompactRaidFrameManager_UpdateOptionsFlowContainer = E.dummy
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

    if C.minimap.enable then
		SetCVar("minimapTrackingShowAll", 1)
	end

    if C.actionbar.bars.enable and C.actionbar.bars.bags.enable then
        if E.isBeta then
            C_Container.SetSortBagsRightToLeft(true)
			C_Container.SetInsertItemsLeftToRight(false)
        else
            SetSortBagsRightToLeft(true)
            SetInsertItemsLeftToRight(false)
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