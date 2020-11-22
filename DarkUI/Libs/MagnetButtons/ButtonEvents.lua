local _, ns = ...
local addon = ns.MagnetButtons

----------------------------------------------------------------------------------
-- EVENTS
----------------------------------------------------------------------------------

function addon.OnLoad(self)
    -- self:RegisterForDrag("LeftButton", "RightButton");
    self:RegisterForClicks("AnyUp");
    self.forceUncheck = false;
    self.IsUsable = true;
    self.flashing = 0;
    self.nextUpdate = 0;
    self.cursorX = -1;
    self.cursorY = -1;
    self.HasNormalCursor = true;
    self.HasShiftCursor = false;
    self.HasControlCursor = false;
    self.HasBlockMoveCursor = false;
end

function addon.OnEnter(self)
    if (not addon.IsBlockMoving()) then
        -- This starts the code in onUpdate, that modifies the cursor based on control and shift states,
        -- so that it only runs on the button that has mouse pointer focus

        self.HasCursor = true;
        self.HasNormalCursor = true;
        self.HasShiftCursor = false;
        self.HasControlCursor = false;
        self.HasBlockMoveCursor = false;

        ResetCursor();

    end
end

function addon.OnLeave(self)
    if (not addon.IsBlockMoving()) then
        -- This stop the code in onUpdate, that modifies the cursor based on control and shift states,
        -- so that it only runs on the button that has mouse pointer focus
        self.HasCursor = false;
        self.HasNormalCursor = false;
        self.HasShiftCursor = false;
        self.HasControlCursor = false;
        self.HasBlockMoveCursor = false;
        addon.ClearBlockSelection(self);
        ResetCursor();
    end
end
function addon.OnMouseDown(self, button)
    local shiftDown = IsShiftKeyDown();
    local ctrlDown = IsControlKeyDown();
    local altDown = IsAltKeyDown();
    if (self.HasBlockMoveCursor and (button == "LeftButton")) then
        addon.StartBlockMove(self);
    elseif (not addon.IsButtonLocked()) and (button == "LeftButton") and (shiftDown) then
        addon.StartButtonMove(self)
    end
end
function addon.OnMouseUp(self)
    if (self.HasBlockMoveCursor) then
        --addon.StopBlockMove(self);
    elseif (self.IsMoving) then
        addon.StopButtonMove(self);
    end
end

function addon.OnReceiveDrag(self)
    -- Cursor is holding a spell
    local infoType, info1, info2, info3 = GetCursorInfo();

    -- infoType = "flyout"
    -- flyout, 9, 132161 (Call Pet)... What's the 9 mean, the 132161 is probably a iconID
    addon.Debug("OnReceiveDrag: " .. tostring(infoType) .. ", " .. tostring(info1) .. ", " .. tostring(info2) .. ", " .. tostring(info3) .. ", " .. tostring(inLockdown));

    -- Cancel if in combat lockdown
    if (InCombatLockdown()) then
        ClearCursor();
        return ;
    end

    -- Setup Button
    if (infoType == "mount" and tonumber(info1) == 268435455) then
        addon.SetMacroText(self:GetParent(), "/script SummonRandomFavoriteMount()", "413588", "Summon Random Favorite Mount", nil, "macro", "/dismount");
        addon.SaveButton(self);
    elseif (infoType == "spell") then
        local spellName = GetSpellBookItemName(info1, BOOKTYPE_SPELL);
        if (info1 == 0) then
            spellName = GetSpellInfo(info3);
        end

        --addon.SetButton(self, {
        --	type = "spell"
        --  spell = spellName
        --})
        --addon.Debug(format("OnReceiveDrag: SetSpellBookItem: "..tostring(spellName)));

        addon.SetSpellBookItem(self:GetParent(), spellName);
        addon.SaveButton(self);
        addon.UpdateFlash(self);
    elseif (infoType == "item") then
        local hasItem = CursorHasItem()
        local itemID, toyName, textureId, unknown2;
        if (not addon.system.isClassic) then
            itemID, toyName, textureId, unknown2 = C_ToyBox.GetToyInfo(info1);
        end
        if (hasItem) then
            addon.SetItem(self:GetParent(), info2);
        elseif (toyName) then
            -- FIX TO MAKE TOYS WORK IS TO TURN THEM INTO A "/USE {toyname}" macro
            addon.SetMacroText(self:GetParent(), "/use " .. toyName, textureId);
            self:SetAttribute("tooltip", toyName);
        end
        addon.SaveButton(self);
    elseif (infoType == "mount") then
        local mountName, mountIndex, textureId = addon.FindMount(info1);
        --addon.Debug(format("Type_Mount: "..tostring(mountName)..", "..tostring(mountIndex)..", textureId = "..tostring(textureId)));
        if (mountName == "Chauffeured Mekgineer's Chopper") then
            addon.SetMacroText(self:GetParent(), "/use Summon Chauffeur", textureId, "Mount " .. mountName, "", "macro", "/dismount");
        else
            addon.SetMacroText(self:GetParent(), "/use " .. mountName, textureId, "Mount " .. mountName, "", "macro", "/dismount");
        end
        addon.SaveButton(self);
    elseif (infoType == "macro") then
        local name, iconTexture, body, isLocal = GetMacroInfo(info1);
        --addon.Debug(format("Type_Macro: "..tostring(mountName)..", "..tostring(mountIndex)..", textureId = "..tostring(textureId)));
        addon.SetMacroName(self:GetParent(), name);
        -- Setup texture
        local icon = getglobal(self:GetName() .. "Icon");
        icon:SetTexture(iconTexture);
        self:SetAttribute("texture", icon:GetTexture());
        addon.SaveButton(self);
    elseif (infoType == "companion") then
        -- addon.Debug("OnReceiveDrag: SetCompanion");
        addon.SetCompanion(self:GetParent(), info2, info1);
        addon.SaveButton(self);
        addon.UpdateFlash(self);
    elseif (infoType == "flyout") then
        --addon.Debug("Flyout drop detected...")
        addon.SetFlyout(self:GetParent(), info1, info2);
        addon.SaveButton(self);
    elseif (infoType == "petaction") then
        if (addon.DraggingPetSpellIndex) then
            local spellId = info1;
            if (info2 == nil) then
                addon.SetPetAction(self:GetParent(), addon.DraggingPetSpellIndex, nil);
            else
                addon.SetPetAction(self:GetParent(), addon.DraggingPetSpellIndex, info1);
            end
        else
            addon.SetPetAction(self:GetParent(), info2, info1);
        end
        addon.SaveButton(self);
    end
    addon.UpdateState(self);
    addon.UpdateCooldown(self);

    ClearCursor();
end

---









--- A magnet button's OnEvent handler
---
function addon.OnEvent(self, event, arg1, arg2, ...)
    -- local spell, rank, displayName, icon, startTime, endTime, isTradeSkill, castID, interrupt = UnitCastingInfo("player");
    local tradeskillName, currentLevel, maxLevel;
    if (not addon.system.isClassic) then
        tradeskillName, currentLevel, maxLevel = C_TradeSkillUI.GetTradeSkillLine()
    end

    local spell = addon.GetSpellBookItemName(self);
    local item = addon.GetItemName(self);
    local action = addon.GetPetAction(self);
    if (spell == nil) and (item == nil) and (action == nil) then
        addon.OnUpdate(self);
        return ;
    end

    if (event == "SPELLS_CHANGED" or event == "SPELL_UPDATE_CHARGES") then
        addon.SetButtonItemCount(self);
        return ;
    end

    if (event == "RUNE_POWER_UPDATE") and (arg1 ~= "player") then
        -- addon.Debug("UNIT_RUNIC_POWER, "..tostring(arg1)..", "..tostring(arg2));
        return ;
    end
    if (event == "ACTIONBAR_UPDATE_STATE") then
        --addon.Debug("ACTIONBAR_UPDATE_STATE: "..tostring(arg1)..", "..tostring(arg2));
    end
    if (event == "ACTIONBAR_UPDATE_USABLE") then
        ---addon.Debug("ACTIONBAR_UPDATE_USABLE: "..tostring(arg1)..", "..tostring(arg2));
    end
    if (event == "ACTIONBAR_UPDATE_COOLDOWN") then
        ---addon.Debug("ACTIONBAR_UPDATE_COOLDOWN: "..arg1..", "..arg2);
    end
    if (event == "PLAYER_ENTER_COMBAT") then
        --if (IsAttackSpell(spell)) then
        --addon.StartFlash(self);
        --end
    elseif (event == "PLAYER_LEAVE_COMBAT") then
        --if (IsAttackSpell(spell)) then
        --addon.StopFlash(self);
        --end
    elseif (event == "START_AUTOREPEAT_SPELL") then
        if (IsAutoRepeatSpell(spell)) then
            --addon.StartFlash(self);
        end
    elseif (event == "STOP_AUTOREPEAT_SPELL") then
        if (addon.IsFlashing(self) and not IsAttackSpell(spell)) then
            --addon.StopFlash(self);
        end
    elseif (event == "CURRENT_SPELL_CAST_CHANGED") and (not SpellIsTargeting()) and (tradeskillName == "UNKNOWN") then
        self:SetChecked(false);
    elseif (event == "UI_ERROR_MESSAGE") then
        self:SetChecked(false);
    elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
        -- addon.Debug("UNIT_SPELLCAST_SUCCEEDED: "..tostring(arg2));
        if (arg1 == "player") and (self:GetAttribute("type") == "spell") and (self:GetAttribute("spell") == arg2) then
            -- addon.Debug("UNIT_SPELLCAST_SUCCEEDED: HOOKED");
        end
    elseif (event == "COMBAT_LOG_EVENT") and (arg2 == "SPELL_AURA_APPLIED") and (arg4 == UnitName("player")) and (arg10 == self:GetAttribute("spell") and (self:GetAttribute("type") == "spell")) then
        -- addon.Debug("SPELL_AURA_APPLIED: "..tostring(arg10));
        self.AuraApplied = true;
        -- self:SetChecked(true);
    elseif (event == "COMBAT_LOG_EVENT") and (arg2 == "SPELL_AURA_REMOVED") and (arg4 == UnitName("player")) and (arg10 == self:GetAttribute("spell") and (self:GetAttribute("type") == "spell")) then
        -- addon.Debug("SPELL_AURA_REMOVED: "..tostring(arg10));
        self.AuraApplied = false;
        -- self:SetChecked(false);
    elseif (event == "COMPANION_UPDATE") and (arg1 ~= "MOUNT") then
        --local _, _, _, _, issummoned = GetCompanionInfo(self:GetAttribute("value1"), self:GetAttribute("value2"));
        -- addon.Debug("COMPANION_UPDATE: "..tostring(arg1)..", "..tostring(issummoned));
        self.AuraApplied = issummoned; -- Controls the check state
    end

    if (event == "BAG_UPDATE") and (item ~= nil) then
        addon.SetButtonItemCount(self);
    end

    addon.OnUpdate(self);
end

-- Unused, but in XML
function addon.PreClick(self, button)
end
-- Unused, but in XML
function addon.PostClick(self, button)
end
