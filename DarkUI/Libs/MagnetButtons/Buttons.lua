local _, ns = ...
local addon = ns.MagnetButtons

function addon.IsCompanion(self)
    return (addon.GetCompanion(self) ~= nil);
end

-- macrotext, starts with /use and is followed by the name of a toy
function addon.IsToy(self)
    if (addon.system.isClassic) then
        return false;
    end

    return addon.GetToyId(self) == true;
end

-- macrotext, starts with /use and is followed by the name of a toy
function addon.GetToyId(self)
    local t = self:GetAttribute("type");
    local val = self:GetAttribute("macrotext");
    if (t ~= "macro") then return false end
    if (val and string.sub(val, 1, 4) == "/use") then
        local toyCount = C_ToyBox.GetNumToys();
        local what = string.sub(val, 5);
        for idx = 1, toyCount, 1 do
            local toyId = C_ToyBox.GetToyFromIndex(idx)
            local itemId, toyName, icon, isFavorite, hasFanfare, itemQuality = C_ToyBox.GetToyInfo(toyId)
            if (toyName ~= nil) then
                local a = string.match(toyName, what);
                local b = string.match(what, toyName);
                if (a or b) then
                    return toyId;
                end
            end
        end
    end
end

function addon.IsSpell(self)
    return (addon.GetSpellBookItemName(self) ~= nil);
end

function addon.IsItem(self)
    return (addon.GetItemName(self) ~= nil);
end

function addon.IsPetAction(self)
    return (addon.GetPetAction(self) ~= nil);
end

function addon.IsMacro(self)
    return (addon.GetMacroName(self) ~= nil);
end

function addon.IsFlyout(self)
    return (addon.GetFlyout(self) ~= nil);
end

function addon.IsWorldMarker(self)
    return (addon.GetMarker(self) ~= nil);
end

function addon.IsMacroText(self)
    return (addon.GetMacroText(self) ~= nil);
end

function addon.GetMarker(self)
    if (self:GetAttribute("type") == "worldmarker") then
        return self:GetAttribute("marker") or 1;
    end
end

function addon.GetFlyout(self)
    if (self:GetAttribute("type") == "flyout") then
        return self:GetAttribute("spell");
    end
end

function addon.GetCompanion(self)
    return self:GetAttribute("value1"), self:GetAttribute("value2");
end

function addon.GetSpellBookItemName(self)
    --if (self:GetAttribute("type") == "spell") then
    return self:GetAttribute("spell");
    --end
end

function addon.GetItemName(self)
    return self:GetAttribute("item");
end

function addon.GetPetAction(self)
    if (self:GetAttribute("macrotext") ~= nil) then
        return self:GetAttribute("action");
    end
end

function addon.GetMacroName(self)
    return self:GetAttribute("macro");
end

function addon.GetMacroText(self)
    return self:GetAttribute("macrotext");
end

function addon.GetTooltip(self)
    return self:GetAttribute("tooltip");
end

function addon.GetSpell(self)
    return self:GetAttribute("spell");
end

function addon.GetTooltip(self)
    return self:GetAttribute("Tooltip");
end

function addon.GetIcon(self)
    return getglobal(self:GetName() .. "Icon");
end

--[[
function addon.SetDisabled(self, disabled)
	if (disabled) then
		icon:SetAlpha(0.5);		
	else
		icon:SetAlpha(1.0);	
	end
end
]]--

function addon.IsUsable(self)
    return self.IsUsable
end

function addon.SetUsable(self, isUsable, notEnoughMana)
    local name = self:GetName();
    local icon = getglobal(name .. "Icon");
    local normalTexture = getglobal(name .. "NormalTexture");
    local parent = self:GetParent();
    -- icon:SetDesaturated(false);

    if (UnitOnTaxi("player") or UnitIsDeadOrGhost("player")) then
        parent:SetAlpha(0.85);
    else
        parent:SetAlpha(1);
    end

    if (isUsable) and (not self.IsUsable) then
        --DoIt.Debug("MagnetButton: Button is now usable");
        self.IsUsable = true;
        if (self:GetParent():IsShown()) then
            icon:SetVertexColor(1.0, 1.0, 1.0);
            if (normalTexture) then
                normalTexture:SetVertexColor(1.0, 1.0, 1.0);
            end
        end
    elseif (notEnoughMana) and (self.IsUsable) then
        --DoIt.Debug("MagnetButton: Button is now unusable, not enough mana");
        self.IsUsable = false;
        if (self:GetParent():IsShown()) then
            icon:SetVertexColor(0.5, 0.5, 1.0);
            if (normalTexture) then
                normalTexture:SetVertexColor(0.5, 0.5, 1.0);
            end
        end
    elseif (not isUsable) and (self.IsUsable) then
        --DoIt.Debug("MagnetButton: Button is now unusable");
        self.IsUsable = false;
        if (self:GetParent():IsShown()) then
            icon:SetVertexColor(0.4, 0.4, 0.4);
            if (normalTexture) then
                normalTexture:SetVertexColor(1.0, 1.0, 1.0);
            end
        end
    end
end

function IsUsableCompanion(self, value1, value2)
    if (value1 == "MOUNT") then
        return ((not InCombatLockdown()) and (not IsIndoors()));
    end
    return true;
end

function addon.CompanionClickHandler(self)
    -- This calls or dismisses a companion
    if (self:GetAttribute("type") == "companion") then
        local spell = self:GetAttribute("spell");
        local value1 = self:GetAttribute("value1");
        local value2 = self:GetAttribute("value2");
        -- DoIt.Debug("Call companion: "..value1..", "..value2);
        if (addon.PlayerHasAura(spell)) then
            DismissCompanion(value1, value2);
        else
            CallCompanion(value1, value2);
        end
    end
end

function addon.GetOtherFrameLocations(self)
    local myTable = { };
    local trueIndex = 1;
    for index = 1, addon.MaxFrameIndex do
        local frameName = "MagnetButtonFrame" .. tostring(index);
        local f = getglobal(frameName);
        if (f ~= nil) and (f:IsShown()) and (f ~= self:GetParent()) then
            myTable[trueIndex] = { };
            myTable[trueIndex]["name"] = frameName;
            myTable[trueIndex]["rect"] = addon.Rectangle.CreateFromFrame(f);
            trueIndex = trueIndex + 1;
        end
    end
    return myTable;
end

function addon.GetAllPoints(self)
    local array = Classy.Array.new()
    local numPoints = self:GetNumPoints()
    for index = 1, numPoints do
        array:add({ self:GetPoint(index) });
    end
    return array:get()
end