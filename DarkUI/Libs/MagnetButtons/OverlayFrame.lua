--[[

	The overlay frame is an invisible frame that sits right on top of the UIParent. Since
	the UIParent's drops can not be used, this frame provides a source for mouse click events
	as if they were to the UIParent. Used for drag-drop button creation.

]]--
local _, ns = ...
local addon = ns.MagnetButtons

local function PostDropMagnetLock(button)
	local parent = button:GetParent();
	
	-- Load the location of all the other existing magnet buttons
	button.OtherFrames = addon.GetOtherFrameLocations(button);

	-- Keep the button center at cursor position and magnet locks for new button creation
	local xpos, ypos = addon.DragUpdateLocation(button, 47);
	
	-- Set button position
	if (xpos ~= nil) and (ypos ~= nil) then
		addon.SetPoint(parent, xpos, ypos);
		addon.SaveButton(button);
	end
end

-- Make a button where the cursor is
local function MakeButtonHere()
	local shiftDown = IsShiftKeyDown();
	local inLockdown = InCombatLockdown()
	--[[ 	The first two conditionals are older code, I don't think all conditionals are used
			since the overlay is ONLY shown with a shift button pressed.
	]]--
	if (CursorHasItem() and not shiftDown) then
		local infoType, info1, info2 = GetCursorInfo();
		local itemName = GetItemInfo(info1);
		StaticPopupDialogs["MAGNET_BUTTONS"].text = "Are you sure you want to destroy "..itemName.."?"
		StaticPopup_Show("MAGNET_BUTTONS")
	elseif (not shiftDown) then
		ClearCursor();
	elseif (not inLockdown) then
		-- Create a new magnet button for the drop
		local button = addon.NewEmptyButton();
		local xpos, ypos = GetCursorPosition();
		local scale = UIParent:GetEffectiveScale();
		ypos = ypos - (button:GetHeight() * scale);
		addon.SetPoint(button:GetParent(), xpos / scale, ypos / scale);
		addon.OnReceiveDrag(button);
		PostDropMagnetLock(button);
	else
		ClearCursor();
	end
end

-- Create Overlay Drop Target
local overlay = CreateFrame("CheckButton", "MagnetButtonsDropTarget", UIParent, "SecureActionButtonTemplate");
overlay:SetFrameStrata("LOW");
overlay:SetScript("OnUpdate", function (self, elapsed)
	if InCombatLockdown() then return end
	local infoType, info1, info2 = GetCursorInfo();
	if (infoType == nil and self:IsShown()) then
		self:Hide();
	end
end);
overlay:SetScript("OnClick", MakeButtonHere);
overlay:SetScript("OnReceiveDrag", MakeButtonHere);
