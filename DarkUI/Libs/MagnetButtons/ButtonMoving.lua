--[[

    The block-move frame is an invisible frame that is the actual frame being moved when moving
    multiple buttons. The magnet buttons are added to this window first, so it just appears that
    people are moving multiple frames at the same time.

]] --
local _, ns = ...
local addon = ns.MagnetButtons

---
--- Clears the block selection set for the target button (butoon that has the cursor)
---
function addon.ClearBlockSelection(self)
    -- If no selection set, just return
    if (not self.select_set) then return end

    -- Clear the selection set
    self.select_set = nil;
end

---
--- This function is called when both shift and control are pressed down, it triggers a start of 
--- block move of buttons. It should hightlight all buttons to be included in the block move.
---
function addon.SetBlockSelection(self)
    -- Create an empty single array for a selection
    self.select_set = Classy.SingleArray.new();

    -- This function get's a button's neighbors (up to four buttons),
    -- then recursively calls it's self on the subset buttons. Recursion stops when a
    -- frame that is already in the selection set is passed as an argument.
    function findNeighbors(frame)
        -- Stop recursing if the frame is already in the selection set
        if (not frame or self.select_set:find(frame)) then return end

        -- add this frame to the selection set
        self.select_set:add(frame);

        -- scan for other magnet button frames
        local otherFrames = addon.GetOtherFrameLocations(frame);

        -- Create a subset and find neighboring frames.
        local subset = Classy.SingleArray.new();
        local scale = addon.Round(frame:GetParent():GetScale());
        local rect = addon.Rectangle.CreateFromFrame(frame);

        for index = 1, #otherFrames do
            local frameName = otherFrames[index]["name"]; -- use or remove
            local targetFrame = getglobal(frameName); -- use or remove
            local targetScale = addon.Round(targetFrame:GetScale());

            if (scale == targetScale) then
                local isAdjacent = addon.Rectangle.IsAdjacent(rect,
                                                        otherFrames[index]["rect"]);
                if (isAdjacent) then subset:add(targetFrame); end
            end
        end

        -- process all frames in the subset		
        for i = 1, subset:length() do findNeighbors(subset:get(i)); end
    end -- end declaration of the findNeighbors internal recursive function

    -- Find neighbors, initial start of the recursive function 
    findNeighbors(self:GetParent());
end

--[[
		Moving multiple frames simultaneously? frame:StartMoving() can't be called on a different frame until you call frame:StopMovingOrSizing().
		Use mouse events to provide an (x, y) offset to change the (xOfs, yOfs) of a button's single anchor point.
]] --

---
--- This function is called to start moving a block of magnet buttons
---
local actual_handler = nil;
function addon.IsBlockMoving()
	return (actual_handler ~= nil);
end
function addon.StartBlockMove(self)
	-- Sanity Check
	if (addon.IsBlockMoving()) then return end

	--addon.Debug("Start block move... ")
	local select_set = self.select_set;

	local mouseMoveHandler = function (offsetX, offsetY)
		-- scale offset
		local scale = UIParent:GetEffectiveScale();
		local bScale = self:GetParent()	:GetScale();
		offsetX = offsetX / scale / bScale;
		offsetY = offsetY / scale / bScale;
	
		for i = 1, select_set:length() do
			local parent = select_set:get(i);
			local frameName = parent:GetName() .. "CheckButton";
			local frame = getglobal(frameName);
			
			-- Disable button and clicks
			frame:Disable();
			frame:RegisterForClicks();

			-- Change offsets
			local point, relativeTo, relativePoint, xOfs, yOfs = parent:GetPoint(1);
			parent:ClearAllPoints();
			parent:SetPoint(point, relativeTo, relativePoint, xOfs - offsetX, yOfs - offsetY)
		end
	end

    local host = CreateFrame("Frame");
    local function SetOnMouseMove(callback)
        local function onUpdate(h)
            local cursorX, cursorY = GetCursorPosition();
            if (h._cursorX ~= cursorX) or (h._cursorY ~= cursorY) then
                local isDown = IsMouseButtonDown("LeftButton");
                local oldX = h._cursorX;
                local oldY = h._cursorY;
                h._cursorX = cursorX;
                h._cursorY = cursorY;
                callback(cursorX, cursorY, oldX, oldY, isDown);
            end
        end

        host:RegisterAllEvents();
        host:SetScript("OnUpdate", onUpdate);
    end

    local function UnSetOnMouseMove()
        host:UnregisterAllEvents();
    end

	actual_handler = function(x, y, oldX, oldY, isDown)
		if (isDown) then
			-- Still dragging, handle event
			mouseMoveHandler(oldX - x, oldY - y);
		else
			--addon.Debug("Stop block move...")
            UnSetOnMouseMove()
			for i = 1, select_set:length() do
				local parent = select_set:get(i);
				local frameName = parent:GetName() .. "CheckButton";
				local frame = getglobal(frameName);

				-- Save button position
				addon.SaveButton(frame);

				-- Reenable frame and clicks
				frame:Enable();
				frame:RegisterForClicks("AnyUp");
			end
			actual_handler = nil;
			GameTooltip:Hide()
        end
	end
	
	-- Subscribe to onMouseMove event handler
    SetOnMouseMove(actual_handler);
end

-- This function adjusts x and y during the drag and determines if near other buttons
function addon.DragUpdateLocation(self, distanceResolution)
    local xpos, ypos = GetCursorPosition();
    local rectThis = addon.Rectangle.CreateFromFrame(self);
    local scale = UIParent:GetEffectiveScale();
    local buttonScale = self:GetParent():GetScale();
    local count = 0;
    local found = false;

    -- scale
    xpos = xpos / scale;
    ypos = ypos / scale;

    -- adjust for offset point
    xpos = xpos - (self:GetWidth() / 2);
    ypos = ypos - (self:GetHeight() / 2);

    -- scan for other magnet button frames
    for index = 1, #self.OtherFrames do
        -- get the Rectangle of the other frame
        local rectFrame = self.OtherFrames[index]["rect"];
        local frameName = self.OtherFrames[index]["name"]; -- use or remove
        local targetFrame = getglobal(frameName); -- use or remove
        local targetScale = targetFrame:GetScale();

        if (targetScale == buttonScale) then
            -- bIntersect set to true only means the other return values are not null.
            -- local bIntersect, offsetX, offsetY = addon.Rectangle.Intersect(rectThis, rectFrame);
            local bIntersect, offsetX, offsetY =
            addon.Rectangle.ZoneIntersect(rectThis, rectFrame, distanceResolution);
            local oldX = xpos;
            local oldY = ypos;
            -- We're intersection with another button
            if (bIntersect) then
                -- local side = "";
                count = count + 1;

                -- 'a' squared plus 'b' squared is equal to 'c' squared.
                local length = math.sqrt(offsetX * offsetX + offsetY * offsetY);

                -- What side?
                local angle = math.atan2(offsetX, offsetY);
                angle = 180 - (angle * (180 / 3.141592653589793));

                if (angle > 45) and (angle <= 135) then
                    -- side = "left";
                    xpos = rectFrame["x"] - rectFrame["width"];
                    ypos = rectFrame["y"];
                elseif (angle > 135) and (angle <= 225) then
                    -- side = "bottom";
                    ypos = rectFrame["y"] - rectFrame["width"];
                    xpos = rectFrame["x"];
                elseif (angle > 225) and (angle <= 315) then
                    -- side = "right";
                    xpos = rectFrame["x"] + rectFrame["width"];
                    ypos = rectFrame["y"];
                else
                    -- side = "top";
                    ypos = rectFrame["y"] + rectFrame["width"];
                    xpos = rectFrame["x"];
                end
                ypos = ypos * buttonScale;
                xpos = xpos * buttonScale;
                found = true;
            end

            -- Prevent two buttons from having the same location
            if (bIntersect) then
                local i;
                local targetRect = addon.Rectangle.Create(xpos, ypos, 0, 0);
                for i = 1, #self.OtherFrames do
                    local rectTest = self.OtherFrames[i]["rect"];
                    if (addon.Rectangle.IsSameLocation(targetRect, rectTest)) then
                        xpos = oldX;
                        ypos = oldY;
                        found = false;
                        break
                    end
                end
            end
        end
    end
    return xpos, ypos, found;
end

function addon.IsButtonLocked(self) return false; end

function addon.StartButtonMove(self)
    local parent = self:GetParent();

    self.IsMoving = true;
    self.OtherFrames = addon.GetOtherFrameLocations(self);
    self:RegisterForClicks();
    self:Disable();
    parent:StartMoving();
end

function addon.StopButtonMove(self)
    local parent = self:GetParent();

    self.IsMoving = false;
    self.OtherFrames = nil;
    parent:StopMovingOrSizing();
    addon.SaveButton(self);
    self:Enable();
    self:RegisterForClicks("AnyUp");
end

