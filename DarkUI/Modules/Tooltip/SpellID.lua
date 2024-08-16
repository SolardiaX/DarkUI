local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.spell_id ~= true then return end

----------------------------------------------------------------------------------------
--	Spell/Item IDs(idTip by Silverwind)
----------------------------------------------------------------------------------------

local function addLine(self, id, isItem)
    for i = 1, self:NumLines() do
        local line = _G[self:GetName().."TextLeft"..i]
        if not line then break end
        local text = line:GetText()
        -- if text and (text:match(L.TOOLTIP_ITEM_ID) or text:match(L.TOOLTIP_SPELL_ID)) then return end
        if text and string.find(text, id) then return end
    end
    if isItem then
        self:AddLine("|cffffffff"..L.TOOLTIP_ITEM_ID.." "..id)
    else
        self:AddLine("|cffffffff"..L.TOOLTIP_SPELL_ID.." "..id)
    end
    self:Show()
end


local function attachByAuraInstanceID(self, ...)
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
    local id = aura and aura.spellId
    if id then addLine(self, id) end
end

-- Spells
hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
    local unit, slot = ...
	local aura = C_UnitAuras.GetAuraDataBySlot(unit, slot)
    local id = aura and aura.spellId
	if id then addLine(self, id) end
end)

hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", attachByAuraInstanceID)
hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", attachByAuraInstanceID)

hooksecurefunc("SetItemRef", function(link)
    local id = tonumber(link:match("spell:(%d+)"))
    if id then addLine(ItemRefTooltip, id) end
end)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
    if self ~= GameTooltip or self:IsForbidden() then return end
    if data and data.id then
        addLine(self, data.id)
    end
end)

-- Items
local whiteTooltip = {
    [GameTooltip] = true,
    [ItemRefTooltip] = true,
    [ItemRefShoppingTooltip1] = true,
    [ItemRefShoppingTooltip2] = true,
    [ShoppingTooltip1] = true,
    [ShoppingTooltip2] = true,
}
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self, data)
    if whiteTooltip[self] and not self:IsForbidden() then
        if data and data.id then
            addLine(self, data.id, true)
        end
    end
end)

-- Macros
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(self, data)
    if self:IsForbidden() then return end
    local lineData = data.lines and data.lines[1]
    local tooltipType = lineData and lineData.tooltipType
    if not tooltipType then return end

    if tooltipType == 0 then -- item
        addLine(self, lineData.tooltipID, true)
    elseif tooltipType == 1 then -- spell
        addLine(self, lineData.tooltipID)
    end
end)

-- Toys
TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(self, data)
    if self ~= GameTooltip or self:IsForbidden() then return end
    if data and data.id then
        addLine(self, data.id, true)
    end
end)
