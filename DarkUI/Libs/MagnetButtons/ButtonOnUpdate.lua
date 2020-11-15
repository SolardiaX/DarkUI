local _, ns = ...
local addon = ns.MagnetButtons

-- EACH button has this as their OnUpdate, do not do more than is needed here, use DoIt! Timers instead.
function addon.OnUpdate(self, elapsed)
    -- Why blizzard? Ignore these OnUpdate events
    if (not elapsed) then elapsed = 0.01 end

    -- This code block is used to both keep the button centered on the cursor when moving, and to snap with other buttons
    if (self.IsMoving) then
        -- If the button's location needs updating, xpos and ypos will not be nil
        -- The constant is the range of the magnetic lock
        local xpos, ypos = addon.DragUpdateLocation(self, 39);

        -- Set button position
        if (xpos ~= nil) and (ypos ~= nil) then
            local parent = self:GetParent();
            addon.SetPoint(parent, xpos, ypos);
        end
        return ;
    end

    -- OnUpdate happens way too often, so ignore some/most.
    -- TODO: switch this to DoIt Timers, then this is not required!!!
    self.TimeSinceLastUpdate = self.TimeSinceLastUpdate + elapsed;
    if (self.TimeSinceLastUpdate < 0.05) then return end
    self.TimeSinceLastUpdate = 0;
    if (addon.IsBlockMoving()) then
        SetCursor("Interface/CURSOR/openhandglow");
        return ;
    end
    -- Change Cursor for when ctrl or shift are pressed
    if (self.HasCursor == true) and (not CursorHasItem()) and (not CursorHasMacro()) and (not CursorHasMoney()) and (not CursorHasSpell()) then
        local inCombat = (UnitAffectingCombat("player") or InCombatLockdown());
        local shiftCursor = (IsShiftKeyDown() and (not IsControlKeyDown()) and (not IsAltKeyDown()) and (not inCombat));
        local controlCursor = (IsControlKeyDown() and (not IsShiftKeyDown()) and (not IsAltKeyDown()) and (not inCombat));
        local blockMoveCursor = (IsControlKeyDown() and IsShiftKeyDown() and (not IsAltKeyDown()) and (not inCombat));
        if ((not shiftCursor) and (not controlCursor) and (not blockMoveCursor) and (not self.HasNormalCursor)) then
            self.HasNormalCursor = true;
            self.HasShiftCursor = false;
            self.HasControlCursor = false;
            self.HasBlockMoveCursor = false;
            addon.ClearBlockSelection(self);
            ResetCursor();
        elseif (blockMoveCursor and (not self.HasBlockMoveCursor)) then
            self.HasNormalCursor = false;
            self.HasShiftCursor = false;
            self.HasControlCursor = false;
            self.HasBlockMoveCursor = true;
            -- Builds a selection set
            addon.SetBlockSelection(self);
            -- Sets the cursor
            SetCursor("Interface/CURSOR/openhandglow");
        elseif (controlCursor and (not self.HasControlCursor)) then
            self.HasNormalCursor = false;
            self.HasShiftCursor = false;
            self.HasBlockMoveCursor = false;
            self.HasControlCursor = true;
            addon.ClearBlockSelection(self);
            SetCursor("INSPECT_CURSOR");
        elseif (shiftCursor and (not self.HasShiftCursor)) then
            self.HasNormalCursor = false;
            self.HasControlCursor = false;
            self.HasBlockMoveCursor = false;
            self.HasShiftCursor = true;
            addon.ClearBlockSelection(self);
            SetCursor("ITEM_CURSOR");
        end
    end

    -- Add tooltips for macros and updates cooldown times in tooltips
    addon.DisplayTooltip(self);

    -- Hide/Show Pet Buttons when appropate
    local parentFrame = self:GetParent();
    if (addon.IsPetAction(self)) and (PetHasActionBar() and UnitIsVisible("pet")) then
        if (not parentFrame:IsShown()) then
            parentFrame:Show();
        end
    elseif (addon.IsPetAction(self)) then
        if (parentFrame:IsShown()) then
            parentFrame:Hide();
        end
    end

    addon.UpdateState(self);
    addon.UpdateUsable(self);
    addon.UpdateCooldown(self);

    -- oldCode();
end

local function oldCode()
    local currentTime = GetTime();

    if (addon.IsUsable(self)) then
        if (addon.IsFlashing(self) and false) then
            -- LOGIC DISABLED
            if (self.nextUpdate < currentTime) then
                local overtime = -(self.nextUpdate - currentTime);
                if (overtime >= ATTACK_BUTTON_FLASH_TIME) then
                    overtime = 0;
                end
                --addon.Debug("Flashing");
                self.nextUpdate = currentTime + ATTACK_BUTTON_FLASH_TIME - overtime;

                local flashTexture = getglobal(self:GetName() .. "Flash");
                if (flashTexture:IsShown()) then
                    flashTexture:Hide();
                else
                    flashTexture:Show();
                end
            end
        end
        --addon.UpdateFlash(self);
    end
    if (action ~= nil) then
        addon.UpdatePetButtonState(self:GetParent());
    end
end

function addon.DisplayTooltip(self)
    -- Is cursor over a magnet button
    if (not self.HasCursor) then return end

    if (GetCVar("UberTooltips") == "1") then
        GameTooltip_SetDefaultAnchor(GameTooltip, self);
    else
        local parent = self:GetParent();
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
    end

    local tooltip = addon.GetTooltip(self);
    if (tooltip and tooltip ~= "") then
        GameTooltip:SetText(tooltip);
    elseif (addon.IsSpell(self) or addon.IsFlyout(self)) then
        local id = addon.FindSpellID(addon.GetSpellBookItemName(self))
        if (id) then
            GameTooltip:SetSpellBookItem(id, BOOKTYPE_SPELL);
        else
            GameTooltip:SetText("Unavailable");
        end
    elseif (addon.IsItem(self) and addon.GetItemName(self)) then
        -- [Shriveled Heart]
        local _, hyperlink = GetItemInfo(addon.GetItemName(self));
        if (hyperlink) then
            GameTooltip:SetHyperlink(hyperlink);
        end
    elseif (addon.IsCompanion(self)) then
        -- GameTooltip:SetHyperlink(addon.GetSpellBookItemName(self));
        GameTooltip:SetText("DarkUI Extra Buttons (based on MagnetButtons)");
    elseif (addon.IsFlyout(self)) then
        --local id = addon.FindSpellID(addon.GetFlyout(self))
        --GameTooltip:SetSpell(id, BOOKTYPE_SPELL);
        --skillType, special = GetSpellBookItemInfo(spellName or index, bookType)
        local name = "Flyout";
        local propName = self:GetAttribute("name");
        if (propName) then
            name = propName;
        end
        GameTooltip:SetText(name);
    elseif (addon.IsMacro(self)) then
        GameTooltip:AddLine(addon.GetMacroName(self), 1, 1, 1)
    elseif (addon.IsMacroText(self)) then
        local spell = addon.GetSpell(self);
        local name, rank, icon, castTime, minRange, maxRange, spellId = GetSpellInfo(spell);
        local link = GetSpellLink(spellId);
        if (tooltip) then
            GameTooltip:SetText(tooltip);
        elseif (link ~= nil) then
            GameTooltip:SetHyperlink(link);
        elseif (name ~= nil) then
            GameTooltip:SetText(name);
        else
            GameTooltip:SetText("DarkUI Extra Button");
        end
    elseif (addon.IsWorldMarker(self)) then
        GameTooltip:SetText("World Marker " .. (addon.GetMarker(self) or "1"));
    elseif (addon.GetTooltip(self)) then
        GameTooltip:SetText(addon.GetTooltip(self))
    else
        GameTooltip:SetText("DarkUI Extra Button");
    end

    if (not GameTooltip:IsShown()) then GameTooltip:Show() end
end

function addon.UpdateUsable(self)
    if (UnitOnTaxi("player") or UnitIsDeadOrGhost("player")) then
        if (MagnetButtons_Global.FadeBlizzardUI) then
            --addon.MainMenuBarFade(true);
        end
        addon.SetUsable(self, false);
        return ;
    else
        --addon.MainMenuBarFade(false);
        addon.SetUsable(self, true);
    end

    if (addon.IsCompanion(self)) then
        local compType, index = addon.GetCompanion(self);
        addon.SetUsable(self, IsUsableCompanion(compType, index) and HasFullControl());
    elseif (addon.IsMacro(self) or addon.IsMacroText(self)) then
        --local macroName = addon.GetMacroName(self);
        --addon.SetUsable(self, IsUsableItem(itemName));
        addon.SetUsable(self, true);
    elseif (addon.IsSpell(self)) then
        local spellName = addon.GetSpellBookItemName(self);
        addon.SetUsable(self, IsUsableSpell(spellName));
    elseif (addon.IsPetAction(self)) then
        -- See addon.UpdatePetButtonState
    elseif (addon.IsItem(self)) then
        local itemName = addon.GetItemName(self);
        addon.SetUsable(self, IsUsableItem(itemName));
    end
end

function addon.UpdatePetButtonState(parent)
    local button = getglobal(parent:GetName() .. "CheckButton");
    local icon = getglobal(parent:GetName() .. "CheckButtonIcon");
    local petSlot = button:GetAttribute("action");
    local petAutoCastableTexture = getglobal(parent:GetName() .. "CheckButtonAutoCastable");
    local petAutoCastShine = getglobal(parent:GetName() .. "CheckButtonShine");
    local name, subtext, texture, isToken, isActive, autoCastAllowed, autoCastEnabled = GetPetActionInfo(petSlot);
    if (not isToken) then
        icon:SetTexture(texture);
    else
        icon:SetTexture(getglobal(texture));
    end
    if (isActive) and (petSlot == 1) and (not UnitName("pettarget")) then
        button:SetChecked(0);
    elseif (isActive) then
        button:SetChecked(1);
    else
        button:SetChecked(0);
    end
    if (autoCastAllowed) then
        petAutoCastableTexture:Show();
    else
        petAutoCastableTexture:Hide();
    end
    if (autoCastEnabled) then
        AutoCastShine_AutoCastStart(petAutoCastShine);
    else
        AutoCastShine_AutoCastStop(petAutoCastShine);
    end
    if (name) and (UnitName("pet") ~= nil) then
        if (not parent:IsShown()) then
            parent:Show();
        end
    else
        parent:Hide();
    end
    if (texture) then
        if (GetPetActionSlotUsable(petSlot)) then
            SetDesaturation(icon, nil);
        else
            SetDesaturation(icon, 1);
        end
        icon:Show();
        button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot2");
    else
        icon:Hide();
        button:SetNormalTexture("Interface\\Buttons\\UI-Quickslot");
    end
end

function addon.UpdateCooldown(self)
    local start, duration, enable;
    local cooldown = getglobal(self:GetName() .. "Cooldown");

    if (addon.IsSpell(self)) then
        start, duration, enable = GetSpellCooldown(addon.GetSpellBookItemName(self));
    elseif (addon.IsItem(self)) then
        start, duration, enable = addon.GetItemCooldownInfo(addon.GetItemName(self));
    elseif (addon.IsPetAction(self)) then
        start, duration, enable = GetPetActionCooldown(addon.GetPetAction(self));
    elseif (addon.IsCompanion(self)) then
        start, duration, enable = GetCompanionCooldown(addon.GetCompanion(self));
    elseif (addon.IsToy(self)) then
        local toyId = addon.GetToyId(self);
        local itemId, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(toyId)
        --addon.Debug("DEBUG: "..tostring(itemId))
        if (itemId and type(itemId) == "number") then
            --	local usable = C_ToyBox.IsToyUsable(toyId)
            start, duration, enable = GetItemCooldown(itemId)
        end
    end

    if (start ~= nil) then
        CooldownFrame_Set(cooldown, start, duration, enable);
    else
        -- What is this doing besides causing ADDON_ACTION_BLOCKED while in-combat
        if (not InCombatLockdown()) then
            self:Enable();
        end
        local cd = getglobal(self:GetName() .. "Cooldown");
        if (cd) then
            CooldownFrame_Clear(cd);
        end
    end
end

function addon.UpdateState(self)
    local isChecked = false;
    if (addon.IsSpell(self)) then
        local spell = addon.GetSpellBookItemName(self);
        if (spell) then
            isChecked = (IsCurrentSpell(spell) or IsAutoRepeatSpell(spell) or self.AuraApplied);
        end
    elseif (addon.IsPetAction(self)) then
        local action = addon.GetPetAction(self);
        if (action) then
            isChecked = (IsCurrentAction(action) or IsAutoRepeatAction(action));
        end
    elseif (addon.IsItem(self)) then
        local item = addon.GetItemName(self);
        if (item) then
            isChecked = IsCurrentItem(item);
        end
    elseif (addon.IsCompanion(self)) then
        local spell = addon.GetSpellBookItemName(self);
        if (spell) then
            isChecked = addon.PlayerHasAura(spell);
        end
    end
    if (isChecked) then
        --self:SetChecked(true);
    else
        --self:SetChecked(false);
    end
    self:SetChecked(false);
end

function addon.UpdateFlash(self)
    local startFlash = false;
    if (addon.IsSpell(self)) then
        local spell = addon.GetSpellBookItemName(self);
        --=addon.Debug("IsSpell: "..tostring(spell)..", "..tostring(IsAttackSpell(spell))..", "..tostring(IsCurrentSpell(spell))..", "..tostring(IsAutoRepeatSpell(spell)))
        startFlash = ((IsAttackSpell(spell) and IsCurrentSpell(spell)) or IsAutoRepeatSpell(spell));
    elseif (addon.IsPetAction(self)) then
        local action = addon.GetPetAction(self);
        startFlash = ((IsAttackAction(action) and IsCurrentAction(action)) or IsAutoRepeatAction(action));
    end

    --addon.Debug("UpdateFlash: "..tostring(startFlash));

    -- Items never flash
    if (startFlash) then
        --addon.Debug("Start Flash!"..tostring(startFlash));
        --addon.StartFlash(self);
    else
        --addon.StopFlash(self);
    end

    local flasher = _G[self:GetName() .. "Flash"];
    if (flasher:IsShown()) then
        flasher:Hide()
    end
    self:SetChecked(false);
end

function addon.StartFlash(self)
    if (self.flashing == 0) then
        -- addon.Debug("StartFlashing: "..self:GetName());
        -- _G[self:GetName().."Flash"]:Show();
    end
    --self.flashing = 1;
    --self.flashtime = 0;
    --addon.UpdateState(self);
end

function addon.StopFlash(self)
    if (self.flashing == 1) then
        -- addon.Debug("StopFlashing: "..self:GetName());
    end
    --self.flashing = 0;
    --getglobal(self:GetName().."Flash"):Hide();
    --addon.UpdateState(self);
end

function addon.IsFlashing(self)
    if (self.flashing == 1) then
        --return 1;
    end
    return nil;
end

-- GetItemCooldown
function addon.GetItemCooldownInfo(searchItem)
    local _, searchItemLink = GetItemInfo(searchItem);
    local bagID = 0;
    local bagName = GetBagName(bagID);
    while (bagName ~= nil) do
        local slots = GetContainerNumSlots(bagID);
        for slot = 1, slots, 1 do
            local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(bagID, slot);
            if (itemLink ~= nil and itemLink == searchItemLink) then
                local startTime, duration, isEnabled = GetContainerItemCooldown(bagID, slot);

                if (startTime ~= nil and startTime > 0) then
                    return startTime, duration, isEnabled;
                end
            end
        end
        -- Restart While Loop
        bagID = bagID + 1;
        bagName = GetBagName(bagID);
    end
    return nil;
end
