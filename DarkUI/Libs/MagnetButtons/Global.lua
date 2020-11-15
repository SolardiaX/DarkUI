local _, ns = ...
local _G = _G

local addon = ns.MagnetButtons

function addon.ResetButtons()
    MagnetButtons_ButtonData = nil;
    MagnetButtons_GlobalButtonData[addon.GetFullPlayerName()] = nil;
end

function addon.VerifyGlobalButtonSettings()
    if (MagnetButtons_GlobalButtonData[addon.GetFullPlayerName()] ~= nil) then
        MagnetButtons_ButtonData = MagnetButtons_GlobalButtonData[addon.GetFullPlayerName()];
    end
    MagnetButtons_GlobalButtonData[addon.GetFullPlayerName()] = MagnetButtons_ButtonData;
end

function addon.CopyButtonDataFrom(playername)
    local characterData = MagnetButtons_GlobalButtonData[playername];
    if (characterData ~= nil) then
        MagnetButtons_ButtonData = addon.DeepCopy(characterData);
        MagnetButtons_GlobalButtonData[addon.GetFullPlayerName()] = MagnetButtons_ButtonData;
        return true;
    end
    return false;
end

function addon.SetFlyoutCheckedState(isShown)
    for index = 1, addon.MaxFrameIndex do
        local button = getglobal("MagnetButtonFrame" .. index .. "CheckButton");
        if (button and addon.IsFlyout(button)) then
            addon.Debug(button:GetName());
            --if (button:) then
            --button:Click();
            button:SetChecked(false);
            --end
        end
    end
end

function addon.SetPoint(frame, x, y)
    if (frame ~= nil) then
        local button = getglobal(frame:GetName() .. "CheckButton");
        local scale = button:GetAttribute("scale");
        frame:SetAttribute("xPos", x);
        frame:SetAttribute("yPos", y);
        if (scale == nil) then
            scale = 1.0;
            button:SetAttribute("scale", 1.0);
        end
        frame:ClearAllPoints();
        frame:SetPoint("BOTTOMLEFT", x / scale, y / scale);
    end
end

function addon.SetScale(frame, scale, xPos, yPos)
    if (frame ~= nil) then
        -- Set Scale
        if (not scale) then
            scale = 1.0;
        end
        local button = getglobal(frame:GetName() .. "CheckButton");
        local bottom, left = frame:GetBottom(), frame:GetLeft();
        -- addon.Debug("SetScale of "..tostring(frame:GetName()).." to "..tostring(scale));
        frame:SetScale(scale);

        -- Set Location
        if (xPos == nil) then
            xPos = UIParent:GetWidth() / 2;
        end
        if (yPos == nil) then
            yPos = UIParent:GetHeight() / 2;
        end
        addon.SetPoint(frame, xPos, yPos);
    else
        addon.Debug("Failed call to SetScale, nil frame")
    end
end

function addon.FindSpellID(spellName, bookType)
    local i = 0
    if (not bookType) then bookType = BOOKTYPE_SPELL end
    while true do
        local spell, rank = GetSpellBookItemName(i + 1, bookType);
        if (not spell) then
            break
        end
        i = i + 1
    end

    while true do
        local spell, rank = GetSpellBookItemName(i, bookType);
        if (not spell) then
            return ;
        elseif (spell == spellName) then
            return i;
        end
        i = i - 1
    end
end

function addon.FindMount(id)
    local idx = 0;
    for idx = 1, GetNumCompanions("MOUNT"), 1 do
        local creatureName, _, icon, active, isUsable, _, _, _, _, _, _, mountID = C_MountJournal.GetDisplayedMountInfo(idx);
        --addon.Debug("Creature: "..tostring(creatureName)..", "..tostring(mountID)..", "..tostring(icon))
        if (id == mountID) then
            return creatureName, idx, icon;
        end
    end
    return 0;
end

function addon.EnableHotKeysBindings()
    for index = 1, addon.MaxFrameIndex do
        local button = getglobal("MagnetButtonFrame" .. index .. "CheckButton");
        if (button) then
            local hotkey;
            for idx = 1, 5 do
                if (idx == 1) then
                    hotkey = button:GetAttribute("hotkey")
                else
                    hotkey = button:GetAttribute("hotkey" .. tostring(idx))
                end
                if (type(hotkey) == "string" and string.len(hotkey) > 0) then
                    -- PlayerFrame:LeftButton
                    SetOverrideBindingClick(button:GetParent(), true, hotkey, button:GetName(), addon.clicks[idx]);
                end
            end
        end
    end
end

function addon.DisableHotKeysBindings()
    for index = 1, addon.MaxFrameIndex do
        local button = getglobal("MagnetButtonFrame" .. index .. "CheckButton");
        if (button) then
            local oldHotkey;
            for idx = 1, 5 do
                if (idx == 1) then
                    oldHotkey = button:GetAttribute("hotkey")
                else
                    oldHotkey = button:GetAttribute("hotkey" .. tostring(idx))
                end
                if (type(oldHotkey) == "string" and string.len(oldHotkey) > 0) then
                    SetOverrideBinding(button:GetParent(), false, oldHotkey, nil);
                end
            end
        end
    end
end

function addon.ClearButtonAttributes(button)
    local count = getglobal(button:GetName() .. "Count");
    local attributes = addon.allAttributes;
    count:SetText("");
    local oldHotkey;
    for idx = 1, 5 do
        local oldHotkey;
        if (idx == 1) then
            oldHotkey = button:GetAttribute("hotkey")
        else
            oldHotkey = button:GetAttribute("hotkey")
        end
        if (type(oldHotkey) == "string" and string.len(oldHotkey) > 0) then
            SetOverrideBinding(button:GetParent(), false, oldHotkey, nil);
        end
    end
    for attribIndex, attrib in ipairs(attributes) do
        button:SetAttribute(attrib, nil);
    end
end

-- Reuse button indices
local function GetUnusedButtonIndex()
    for index, attributes in ipairs(MagnetButtons_ButtonData) do
        if (#attributes == 0) then
            return index;
        end
    end
    return nil;
end

function addon.NewEmptyButton(scale)
    local f = addon.CreateButtonFrame(GetUnusedButtonIndex());
    if (scale) then
        addon.SetScale(f, scale);
    end
    local button = getglobal(f:GetName() .. "CheckButton");
    button:SetAttribute("type", ATTRIBUTE_NOOP);
    button:SetAttribute("clampedToScreen", "true");
    return button;
end

function addon.ListButtons()
    local index;
    for index = 1, addon.MaxFrameIndex do
        local parentName = "MagnetButtonFrame" .. tostring(index);
        local frameName = parentName .. "CheckButton";
        local f = getglobal(frameName);
        local p = getglobal(parentName);
        if (f) then
            local type = f:GetAttribute("type");
            local name = "";
            local point, relativeTo, relativePoint, xOfs, yOfs = p:GetPoint(1);
            if (type == "spell") then
                name = f:GetAttribute("spell");
            elseif (type == "item") then
                name = f:GetAttribute("item");
            elseif (type == "pet") then
                name = f:GetAttribute("action");
            elseif (type == "companion") then
                name = f:GetAttribute("spell");
            elseif (type == "flyout") then
                name = f:GetAttribute("spell");
            elseif (type == "macro") then
                name = f:GetAttribute("macro");
            end
            if (f ~= nil) then
                addon.Debug("Button " .. index .. ", " .. tostring(type) .. ", " .. tostring(name) .. ", " .. tostring(point) .. ", " .. tostring(relativeTo) .. ", " .. tostring(relativePoint) .. ", " .. xOfs .. ", " .. yOfs);
            elseif (f == nil) then
                addon.Debug("Empty Button " .. index);
            end
        else
            addon.Debug("Frame not found: " .. frameName);
        end
    end
end

function addon.SetMacroName(parent, macroName)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");

    if (macroName ~= nil) then
        --addon.Debug("Macro = "..tostring(macroName));

        addon.ClearButtonAttributes(button);
        button:SetAttribute("type", "macro");
        button:SetAttribute("macro", macroName);

        button:UnregisterAllEvents();
        addon.RegisterStandardEvents(button);

        -- Show frame
        parent:Show();
    else
        -- Remove frame
        addon.RemoveButtonFrame(parent);
    end
end

function addon.SetMacroText(parent, macroText, textureId, tooltip, spell, t2, m2)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");

    if (macroText ~= nil) then
        addon.ClearButtonAttributes(button);
        button:SetAttribute("texture", textureId);
        button:SetAttribute("type", "macro");
        button:SetAttribute("macrotext", macroText);
        button:SetAttribute("tooltip", tooltip);
        button:SetAttribute("spell", spell);
        button:SetAttribute("type2", t2);
        button:SetAttribute("macrotext2", m2);

        button:UnregisterAllEvents();
        addon.RegisterStandardEvents(button);

        -- Setup texture
        icon:SetTexture(textureId);

        -- Show frame
        parent:Show();
    else
        -- Remove frame
        addon.RemoveButtonFrame(parent);
    end
end

function addon.SetFlyout(parent, flyout, textureId, flyoutDirection)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");
    --local skillType, flyoutId = GetSpellBookItemInfo(flyout,  "spell");
    local name, decription, numSlots, isKnown = GetFlyoutInfo(flyout);
    --local count = GetNumFlyouts();
    if (flyoutDirection == nil) then
        flyoutDirection = "UP";
    end

    if (flyout ~= nil and textureId ~= nil and name ~= nil) then
        addon.ClearButtonAttributes(button);
        button:SetAttribute("type", "flyout");
        button:SetAttribute("spell", flyout);
        button:SetAttribute("texture", textureId);
        button:SetAttribute("name", name)
        button:SetAttribute("flyoutDirection", flyoutDirection);

        button:UnregisterAllEvents();
        addon.RegisterStandardEvents(button);

        -- Setup texture
        icon:SetTexture(textureId);

        -- Show frame
        parent:Show();
    else
        -- Remove frame
        addon.RemoveButtonFrame(parent);
    end
end

local function GetGlobalActionTexture(name)
    if (name == "Assist") then
        return PET_ASSIST_TEXTURE;
    elseif (name == "Follow") then
        return PET_FOLLOW_TEXTURE;
    elseif (name == "Stay") then
        return PET_WAIT_TEXTURE;
    elseif (name == "Move To") then
        return PET_MOVE_TO_TEXTURE;
    elseif (name == "Defensive") then
        return PET_DEFENSIVE_TEXTURE;
    elseif (name == "Aggressive") then
        return PET_AGGRESSIVE_TEXTURE;
    elseif (name == "Passive") then
        return PET_PASSIVE_TEXTURE;
    elseif (name == "Assist") then
        return PET_ASSIST_TEXTURE;
    elseif (name == "Attack") then
        return PET_ATTACK_TEXTURE;
    end
end

local function GetPetMacroText(name)
    if (name == "Assist") then
        return "/petassist";
    elseif (name == "Follow") then
        return "/petfollow";
    elseif (name == "Stay") then
        return "/petstay";
    elseif (name == "Move To") then
        return "/petmoveto";
    elseif (name == "Defensive") then
        return "/petdefensive";
    elseif (name == "Aggressive") then
        return "/petaggressive";
    elseif (name == "Passive") then
        return "/petpassive";
    elseif (name == "Assist") then
        return "/petassist";
    elseif (name == "Attack") then
        return "/petattack";
    end
end

-- Assigns a pet action to the specified button's parent frame
-- Rather than use the pet type, which is supported by SecureActionButtonTemplate... I've implemented these as macro instead,
-- because GetCursorInfo returns the pet bar index rather than a spellbook index.
function addon.SetPetAction(parent, actionId, spellId)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");

    addon.Debug("SetPetAction: " .. parent:GetName() .. ", " .. tostring(actionId) .. ", " .. tostring(spellId));

    local rank, textureId, castTime, minRange, maxRange, skillType, name, subtext, isToken, isActive, macroText;
    if (not spellId) then
        skillType, num1, test = GetSpellBookItemInfo(actionId, "pet");
        name, subname = GetSpellBookItemName(actionId, "pet");
        textureId = GetGlobalActionTexture(name);
        macroText = GetPetMacroText(name);
        addon.Debug("SetPetAction(Global): " .. tostring(name) .. ", " .. tostring(actionId) .. ", " .. tostring(num1) .. ", " .. tostring(textureId));
    else
        skillType, num1, test = GetSpellBookItemInfo(actionId, "pet");
        name, rank, textureId, castTime, minRange, maxRange = GetSpellInfo(spellId);
        addon.Debug("SetPetAction(Spell): " .. tostring(name) .. ", " .. tostring(actionId) .. ", " .. tostring(spellId) .. ", " .. tostring(textureId));
    end
    --local autocastable, autostate = GetSpellAutocast(spellId)
    -- /petstay /petattack, /petassist, /cast Dash, /petpassive, /petaggressive, /petfollow
    --if (flyout ~= nil and textureId ~= nil and name ~= nil) then
    addon.ClearButtonAttributes(button);
    if (macroText) then
        button:SetAttribute("type", "macro");
        button:SetAttribute("macrotext", macroText);
        button:SetAttribute("tooltip", name)
        button:SetAttribute("texture", textureId);
    else
        --button:SetAttribute("type", "pet");
        --button:SetAttribute("action", actionId);
        button:SetAttribute("type", "macro");
        button:SetAttribute("macrotext", "/cast " .. tostring(name));
        button:SetAttribute("action", actionId);
        button:SetAttribute("spell", spellId); -- Save with button
        button:SetAttribute("texture", textureId); -- Save with button
        --button:SetAttribute("unit", "pettarget");

        -- Support right-click to toggle autocastable (DEBUG!!!!!!!!!!!!!!!!!!!!!!! THIS WILL NOT SAVE, FIX!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!)
        button:SetAttribute("type2", "macro");
        button:SetAttribute("macrotext2", "/petautocasttoggle " .. tostring(name));
    end
    button:UnregisterAllEvents();
    addon.RegisterStandardEvents(button);
    --button:RegisterEvent("PET_BAR_UPDATE");
    --button:RegisterEvent("PET_UI_UPDATE");
    --button:RegisterEvent("PET_BAR_UPDATE_COOLDOWN");
    --button:RegisterEvent("PET_BAR_SHOWGRID");
    --button:RegisterEvent("PET_BAR_HIDEGRID");
    --button:RegisterEvent("PET_BAR_HIDE");
    --button:RegisterEvent("PLAYER_CONTROL_LOST");
    --button:RegisterEvent("PLAYER_CONTROL_GAINED");
    --button:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED");
    button:RegisterEvent("UNIT_PET");
    --button:RegisterEvent("UNIT_FLAGS");
    --button:RegisterEvent("UNIT_AURA");

    -- Setup texture
    icon:SetTexture(textureId);

    -- Show frame
    parent:Show();


    --else
    -- Remove frame
    --addon.RemoveButtonFrame(parent);
    --end
end

function addon.SetCompanion(parent, companionType, companionIndex)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");
    -- addon.Debug("SetCompanion: "..parent:GetName()..", companionType = "..tostring(companionType)..", companionIndex = "..tostring(companionIndex));
    local _, creatureName, _, texture, issummoned = GetCompanionInfo(companionType, companionIndex);
    -- addon.Debug("SetCompanion: "..parent:GetName()..", companion = "..tostring(creatureName)..", companionType = "..tostring(companionType)..", companionIndex = "..tostring(companionIndex)..", texture = "..tostring(texture));
    if (texture ~= nil) then
        addon.ClearButtonAttributes(button);
        button:SetAttribute("texture", texture);
        button:SetAttribute("type", "companion");
        button:SetAttribute("spell", creatureName);
        button:SetAttribute("value1", companionType);
        button:SetAttribute("value2", companionIndex);

        button:UnregisterAllEvents();
        addon.RegisterStandardEvents(button);

        -- Does this button have an associated applied aura?
        local _, _, _, _, issummoned = GetCompanionInfo(button:GetAttribute("value1"), button:GetAttribute("value2"));
        local hasAura = (addon.PlayerHasAura(creatureName) or issummoned);
        button.AuraApplied = false;
        if (hasAura) then
            -- addon.Debug("Player has creature active... "..button:GetAttribute("spell"));
            button.AuraApplied = true;
        end

        -- Setup texture
        icon:SetTexture(texture);

        -- Show frame
        parent:Show();
    else
        -- Remove frame
        addon.RemoveButtonFrame(parent);
    end
end

-- Assigns an item to the specified button's parent frame
function addon.SetItem(parent, itemName, skipAttributes)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");
    local texture = GetItemIcon(itemName);

    --addon.Debug("SetItem: "..parent:GetName()..", item = "..tostring(itemName));

    if (texture ~= nil) then
        -- Setup Attributes
        addon.ClearButtonAttributes(button);
        button:SetAttribute("texture", texture);
        button:SetAttribute("type", "item");
        button:SetAttribute("item", itemName);
        button:SetAttribute("checkselfcast", true);
        button:SetAttribute("checkfocuscast", true);
        if (not skipAttributes) then
            addon.SaveButton(button);
        end

        -- Setup item events
        button:UnregisterAllEvents();
        addon.RegisterStandardEvents(button);

        -- Set the texture and item count
        icon:SetTexture(texture);

        -- Set item count for item buttons
        addon.SetButtonItemCount(button);

        -- Show frame
        parent:Show();
    else
        -- Remove frame
        addon.RemoveButtonFrame(parent);
    end
end

-- Assigns a spell to the specified button's parent frame
function addon.SetSpellBookItem(parent, spellName, skipAttributes)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");

    local texture = GetSpellTexture(tostring(spellName));
    if (texture ~= nil) then
        --addon.Debug("SetSpellBookItem: texture = "..tostring(texture)..", spell = "..tostring(spellName));
        -- Setup Attributes
        addon.ClearButtonAttributes(button);
        button:SetAttribute("texture", texture);
        button:SetAttribute("type", "spell");
        button:SetAttribute("spell", spellName);
        button:SetAttribute("checkselfcast", true);
        button:SetAttribute("checkfocuscast", true);
        if (not skipAttributes) then
            addon.SaveButton(button);
        end

        -- Register Spell Events
        button:UnregisterAllEvents();
        addon.RegisterStandardEvents(button);

        -- Does this button have an associated applied aura?
        button.AuraApplied = false;
        if (addon.PlayerHasAura(spellName)) then
            button.AuraApplied = true;
        end

        -- Set the texture and item count
        icon:SetTexture(texture);

        -- Show frame
        parent:Show();
    else
        -- Remove frame
        --addon.Debug("SetSpellBookItem: texture = "..tostring(texture)..", spell = "..tostring(spellName));
        addon.RemoveButtonFrame(parent);
    end
end

function addon.RegisterStandardEvents(button)
    button:RegisterEvent("SPELLS_CHANGED");
    button:RegisterEvent("SPELL_UPDATE_CHARGES");
    button:RegisterEvent("ACTIONBAR_UPDATE_STATE");
    button:RegisterEvent("ACTIONBAR_UPDATE_USABLE");
    button:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN");
    button:RegisterEvent("PLAYER_ALIVE");
    button:RegisterEvent("PLAYER_DEAD");
    button:RegisterEvent("CURRENT_SPELL_CAST_CHANGED");
    button:RegisterEvent("UI_ERROR_MESSAGE");
    button:RegisterEvent("SPELL_UPDATE_COOLDOWN");
    button:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED");
    button:RegisterEvent("COMBAT_LOG_EVENT");
    button:RegisterEvent("MODIFIER_STATE_CHANGED");
    button:RegisterEvent("PLAYER_ENTER_COMBAT");
    button:RegisterEvent("PLAYER_LEAVE_COMBAT");
    button:RegisterEvent("BAG_UPDATE");
    button:RegisterEvent("ACTIONBAR_SHOWGRID");
    button:RegisterEvent("ACTIONBAR_HIDEGRID");
    button:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN");
    -- Retail only events
    if (not addon.system.isClassic) then
        button:RegisterEvent("RUNE_POWER_UPDATE");
        button:RegisterEvent("COMPANION_UPDATE");
    end
end

function addon.CreateButtonFrame(index)
    if (index == nil) then
        index = addon.MaxFrameIndex + 1;
    end
    if (index > addon.MaxFrameIndex) then
        addon.MaxFrameIndex = index;
    end
    local frameName = "MagnetButtonFrame" .. tostring(index);
    local f = getglobal(frameName);
    if (f == nil) then
        -- New frame
        f = CreateFrame("Frame", frameName, UIParent, "MagnetButtonFrameDefault");
    else
        -- Reuse old frame, but reposition frame to starting position
        -- f:ClearAllPoints()
        -- f:SetPoint("CENTER", UIParent);
    end
    f:SetID(tostring(index));
    f.used = true;
    return f;
end

function addon.RemoveButtonFrame(f)
    if (f ~= nil) then
        -- Unregister all events
        local button = getglobal(f:GetName() .. "CheckButton");

        addon.ClearButtonAttributes(button);
        addon.SaveButton(button);
        button:UnregisterAllEvents();

        -- Set to a disabled state, since they can't be deleted, reuse later
        -- if needed.
        f.used = false;
        f:Hide();
    end
end

function addon.RemoveButtonFrameByID(id)
    local frameName = "MagnetButtonFrame" .. tostring(id);
    local f = getglobal(frameName);
    addon.RemoveButtonFrame(f);
end

local function ProcessAttributes(attributes)
    local attribIndex, attrib = nil, nil;
    local name, bType, texture, xPos, yPos, item, unit, scale, zoneType;
    for attribIndex, attrib in ipairs(attributes) do
        local a = attrib[1];
        local value = attrib[2];
        if (value ~= "") then
            if (a == "type") then
                bType = value;
            elseif (a == "item") then
                item = value;
            elseif (a == "texture") then
                texture = value;
            elseif (a == "xPos") then
                xPos = value;
            elseif (a == "yPos") then
                yPos = value;
            elseif (a == "unit") then
                unit = value;
            elseif (a == "scale") then
                scale = value;
            elseif (a == "zoneType") then
                zoneType = value;
            end
        end
    end
    return item, name, bType, scale, texture, xPos, yPos;
end
function addon.SetButton(button, attributes)
    local item, name, buttonType, scale, texture, xPos, yPos = ProcessAttributes(attributes);
    local parent = button:GetParent();
    -- Set attributes
    local attribIndex, attrib = nil, nil;
    for attribIndex, attrib in ipairs(attributes) do
        button:SetAttribute(attrib[1], attrib[2]);
    end
    button:SetAttribute("clampedToScreen", true);
    button:SetAttribute("checkselfcast", true);
    button:SetAttribute("checkfocuscast", true);
    -- Set Button Item Count
    addon.SetButtonItemCount(button);
    -- Set scale and location of button
    addon.SetScale(parent, scale, xPos, yPos);
    -- Set the texture/icon
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");
    if (icon and texture) then
        icon:SetTexture(texture);
    end
    -- Register events
    button:UnregisterAllEvents();
    addon.RegisterStandardEvents(button);
    -- Show frame
    button:Show();
end

function addon.MakeButton(index, attributes)
    -- Set attributes for the new frame
    local _, _, buttonType, _, _, _, _ = ProcessAttributes(attributes);

    if (buttonType == nil) then
        -- This is perfectly fine, it's just a deleted button
        return ;
    end

    -- Create the button
    local parent = addon.CreateButtonFrame(index);
    local button = getglobal(parent:GetName() .. "CheckButton");
    addon.ClearButtonAttributes(button);

    -- Setup button with the specified attributes
    addon.SetButton(button, attributes)

    -- Set HotKey
    for idx = 1, 5 do
        local hotkey;
        if (idx == 1) then
            hotkey = button:GetAttribute("hotkey");
        else
            hotkey = button:GetAttribute("hotkey" .. tostring(idx));
        end
        if (type(hotkey) == "string" and string.len(hotkey) > 0) then
            SetOverrideBindingClick(button:GetParent(), true, hotkey, button:GetName(), addon.clicks[idx]);
        end
    end
end

-- Insert a "key-value pair" into the table
local function tableInsert(tbl, property, value)
    if (tbl and property and (value ~= nil)) then
        table.insert(tbl, { property, value });
    end
end

local function GetAttribute(obj, prop)
    local value = obj:GetAttribute(prop);
    if (value == "") then return nil end
    return value;
end

function addon.SaveButton(button)
    local parentID = button:GetParent():GetID();
    local icon = getglobal(button:GetName() .. "Icon");

    -- Get the texture
    local texture = icon:GetTexture();

    --addon.Debug("SaveButton: Start... "..tostring(texture));

    local typeOf = button:GetAttribute("type");
    if (typeOf == nil or typeOf == ATTRIBUTE_NOOP) then
        --addon.Debug("Error: SaveButton: NULL TYPE!");
        MagnetButtons_ButtonData[parentID] = { };
        addon.ClearButtonAttributes(button);
        return ;
    end

    -- Add attributes to table
    local attributes = { };

    for attribIndex, attrib in ipairs(addon.allAttributes) do
        tableInsert(attributes, attrib, GetAttribute(button, attrib));
    end

    local scale = button:GetParent():GetScale();
    local xPos = button:GetParent():GetLeft() * scale;
    local yPos = button:GetParent():GetBottom() * scale;
    if (not scale) then scale = 1 end
    tableInsert(attributes, "yPos", yPos);
    tableInsert(attributes, "xPos", xPos);
    tableInsert(attributes, "scale", scale);

    MagnetButtons_ButtonData[parentID] = attributes;

    addon.VerifyGlobalButtonSettings();
end

-- Update Item and Spell Charge counts
function addon.SetButtonItemCount(button)
    local item = button:GetAttribute("item")
    local spell = button:GetAttribute("spell")
    local count = getglobal(button:GetName() .. "Count");
    if (item and (count ~= nil)) then
        local _, _, _, _, _, _, _, itemStackCount = GetItemInfo(item);
        if (itemStackCount ~= nil and itemStackCount > 1) then
            -- Set item count
            local itemCount = GetItemCount(addon.GetItemName(button), false, true);
            count:SetText(itemCount);
            return ;
        end
    elseif (spell and (count ~= nil)) then
        local currentCharges, maxCharges, cooldownStart, cooldownDuration, chargeModRate = GetSpellCharges(spell);
        if (maxCharges and maxCharges > 1) then
            count:SetText(currentCharges);
            return ;
        end
    end
    if (count ~= nil) then
        -- No count used
        count:SetText("");
    end
end

local allClassic = function(alpha)
    ReputationWatchBar:SetAlpha(alpha)
    MainMenuExpBar:SetAlpha(alpha)
    StanceBarFrame:SetAlpha(alpha)
    PetActionBarFrame:SetAlpha(alpha)
    MainMenuBarArtFrame:SetAlpha(alpha)
end

local allRetail = function(alpha)
    PossessBarFrame:SetAlpha(alpha)
    MicroButtonAndBagsBar:SetAlpha(alpha)
    ReputationWatchBar:SetAlpha(alpha)
    MainMenuExpBar:SetAlpha(alpha)
    StanceBarFrame:SetAlpha(alpha)
    PetActionBarFrame:SetAlpha(alpha)
    MainMenuBarArtFrame:SetAlpha(alpha)
end

local function setAllAlphas(alpha)
    if (addon.system.isClassic) then
        allClassic(alpha);
    else
        allRetail(alpha);
    end
end

function addon.MainMenuBarFade(state)
    state = not state;
    if (not state) then
        setAllAlphas(0.25);
    else
        setAllAlphas(1);
    end
end

function addon.ShowMainMenuBar(state)
    if true then return true end -- Disabled
    if (not state) then
        if (not addon.system.isClassic) then
            PossessBarFrame:Hide()
            MicroButtonAndBagsBar:Hide()
        end
        StanceBarFrame:Hide()
        PetActionBarFrame:Hide()
        MainMenuBarArtFrame:Hide()
        if (addon.system.isClassic) then
            MainMenuBarPerformanceBar:Hide();
        end
    else
        if (GetNumShapeshiftForms() > 0) then
            StanceBarFrame:Show()
        end
        if (HasPetUI()) then
            PetActionBarFrame:Show()
        end
        MainMenuBarArtFrame:Show()
        if (not addon.system.isClassic) then
            MicroButtonAndBagsBar:Show()
        else
            MainMenuBarPerformanceBar:Show();
        end
    end
end

function addon.ManageMainMenuBar()
    -- MainMenuBar
    --local areAnyShown = StanceBarFrame:IsShown() or PetActionBarFrame:IsShown() or MainMenuBarArtFrame:IsShown() or (MicroButtonAndBagsBar and MicroButtonAndBagsBar:IsShown());
    --local areAllHidden = not (StanceBarFrame:IsShown() or PetActionBarFrame:IsShown() or MainMenuBarArtFrame:IsShown() or (MicroButtonAndBagsBar and MicroButtonAndBagsBar:IsShown()));
    --if (not addon.IsInVehicle and areAnyShown and not addon.ShouldMainMenuBeVisible()) then
    --	addon.ShowMainMenuBar(false);
    --elseif (not addon.IsInVehicle and areAllHidden and addon.ShouldMainMenuBeVisible()) then
    --	addon.ShowMainMenuBar(true);
    --end
end

function addon.OnPlayerZoneChange()
    local zone, area, world, zoneType, isManaged = addon.GetPlayerInfo();

    --addon.Debug("OnPlayerZoneChange: "..tostring(zone)..", "..tostring(area)..", "..tostring(world)..", "..tostring(zoneType)..", "..tostring(isManaged)..", LOC1 = "..tostring(isControlled1)..", LOC2 = "..tostring(isControlled2));

    local index;
    for index = 1, addon.MaxFrameIndex do
        local parent = getglobal("MagnetButtonFrame" .. index);
        local button = getglobal("MagnetButtonFrame" .. index .. "CheckButton");
        if (parent and button) then
            local buttonType = button:GetAttribute("type")
            local buttonZoneType = button:GetAttribute("zoneType");
            if (butonType and buttonType ~= "") then
                --addon.Debug("NOT InDesign Mode")
                if (buttonZoneType == nil or zoneType == buttonZoneType) then
                    parent:Show()
                else
                    parent:Hide()
                end
            end
        end
    end
end

function addon.Test(value)
    local index;
    for index = 1, addon.MaxFrameIndex do
        local parent = getglobal("MagnetButtonFrame" .. index);
        if (parent) then
            local button = getglobal("MagnetButtonFrame" .. index .. "CheckButton");
            if (button) then
                button:SetAttribute("zoneType", value);
                addon.SaveButton(button);
            end
        end
    end
    addon.OnPlayerZoneChange();
end

function addon.ShouldMainMenuBeVisible()
    -- A true value indicates that it
    local world = MagnetButtons_Global.HideBars.world;
    local dungeon = MagnetButtons_Global.HideBars.dungeon;
    local raid = MagnetButtons_Global.HideBars.raid;
    local arena = MagnetButtons_Global.HideBars.arena;
    local _, _, _, zoneType = addon.GetPlayerInfo();

    if (zoneType == "world" and not world) then
        return true;
    elseif (zoneType == "dungeon" and not dungeon) then
        return true;
    elseif (zoneType == "raid" and not raid) then
        return true;
    elseif (zoneType == "arena" and not arena) then
        return true;
    end
    return false;
end

function addon.PlayerInVehicle()
    local inVehice = (UnitInVehicle and UnitInVehicle("player"));
    local override = (OverrideActionBar and OverrideActionBar:IsShown());
    return (inVehice or override);
end

local isFlyoutBeingShown = false;
function addon.OnFlyoutShow()
    --addon.Debug("OnFlyoutShow()");
    --addon.SetFlyoutCheckedState(true);
end

function addon.OnFlyoutHide()
    --addon.Debug("OnFlyoutHide()");
    addon.SetFlyoutCheckedState(false);
end

addon.DraggingPetSpellIndex = nil;
local function OnDragStart(self, button)
    --MagnetButtonsDropTarget:Show();
    local order = { 1, 7, 2, 8, 3, 9, 4, 10, 5, 11, 6, 12 }
    local buttonIndex = tonumber(string.sub(self:GetName(), 12));
    local abilityIndex = order[buttonIndex];
    local infoType, spellId, actionId = GetCursorInfo();
    if (infoType == "petaction") then
        addon.DraggingPetSpellIndex = abilityIndex;
        --addon.Debug("OnDragStart: "..tostring(self:GetName())..", "..tostring(buttonIndex)..", "..tostring(abilityIndex)..", "..tostring(spellId)..", "..tostring(actionId));
    end
end

local function OnDragStop(self, dropTarget, arg1, arg2)
    --local infoType, info1, info2 = GetCursorInfo();
    --addon.Debug("OnDragStop: "..tostring(infoType)..", "..tostring(info1)..", "..tostring(info2)..", "..tostring(dropTarget)..tostring(arg1));
    --MagnetButtonsDropTarget:Hide();
    --addon.DraggingPetSpellIndex = nil;
end

local function OnLeave(self)
    addon.Debug("OnLeave: " .. tostring(self:GetName()));
end

local function starts_with(str, start)
    return strsub(1, #start) == start
end

local function HookScript(button, scriptName, func)
    if (button:GetScript(scriptName)) then
        button:HookScript(scriptName, func);
    else
        button:SetScript(scriptName, func);
    end
end

local function HookButtons(prefix, suffix, maxCount)
    for index = 1, maxCount do
        local button = getglobal(prefix .. index .. suffix);
        if (button) then
            HookScript(button, "OnDragStart", OnDragStart);
            HookScript(button, "OnDragStop", OnDragStop);
            --HookScript(button, "OnLeave", OnLeave)
        end
    end
end

-- Temp patch for pet button drops
HookButtons("SpellButton", "", 12);

