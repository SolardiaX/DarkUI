local _, ns = ...
local addon = ns.MagnetButtons

local host = CreateFrame("Frame")

--
-- This is the main start-up script, it's a one-shot, it executes itself then unsubscribes the event.
--
local onEvent = function(_, event)
	if event == "PLAYER_LOGIN" then
		host:UnregisterEvent("PLAYER_LOGIN")

        if not SavedStatsPerChar.ExtraButtons then SavedStatsPerChar.ExtraButtons = {} end
        MagnetButtons_ButtonData = SavedStatsPerChar.ExtraButtons

		addon.VerifyGlobalButtonSettings()
	end

	addon.OnPlayerZoneChange();
end
host:RegisterEvent("PLAYER_LOGIN");
host:RegisterEvent("ZONE_CHANGED");
host:RegisterEvent("ZONE_CHANGED_NEW_AREA");
host:SetScript("OnEvent", onEvent);

-- Static simulated events
addon.TimeSinceLastUpdate = 0;
host:SetScript("OnUpdate", function(_, elapsed)
    -- Add some delay time (Clean this up for C_Timer)
    if (not elapsed) then return end
    addon.TimeSinceLastUpdate = addon.TimeSinceLastUpdate + elapsed;
    if (addon.TimeSinceLastUpdate < 0.2) then return end
    addon.TimeSinceLastUpdate = 0;

    -- Simulated "event" that watches for cursor pick-ups
    local type = GetCursorInfo();
    local shiftDown = IsShiftKeyDown();
    local supportedType = (type == "spell" or type == "item" or type == "petaction" or type == "macro" or type == "flyout" or type == "mount");
    if (shiftDown and supportedType and not MagnetButtonsDropTarget:IsShown()) then
        -- Cursor Pickup
        MagnetButtonsDropTarget:Show();
    elseif ((type == nil or not shiftDown) and MagnetButtonsDropTarget:IsShown()) then
        -- Cursor Drop
        if not InCombatLockdown() then
            addon.DraggingPetSpellIndex = nil;
            MagnetButtonsDropTarget:Hide();
        end
    end

    -- Manage hot key bindings on a Vehicle (retail)
    local inVehicle = addon.PlayerInVehicle();
    if (addon.IsInVehicle ~= inVehicle) then
        addon.IsInVehicle = inVehicle;
        if (addon.IsInVehicle) then
            addon.DisableHotKeysBindings();
        else
            addon.EnableHotKeysBindings();
        end
    end

    -- Manage displaying or hiding the MainMenuBar
    -- addon.ManageMainMenuBar();

    -- Simulate events for when the flyout bar is hidden or shown
    if (SpellFlyout) then
        if (not isFlyoutBeingShown and SpellFlyout:IsShown()) then
            isFlyoutBeingShown = true;
            addon.OnFlyoutShow();
        elseif (isFlyoutBeingShown and not SpellFlyout:IsShown()) then
            isFlyoutBeingShown = false;
            addon.OnFlyoutHide();
        end
    end
end);
