local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- SpellID
------------------------------------------------------------------------
local module = E:Module("Tooltip"):Sub("SpellID")

local cfg = C.tooltip

local function addLine(self, id, isItem)
    if issecretvalue(id) then return end
    for i = 1, self:NumLines() do
        local line = _G[self:GetName() .. "TextLeft" .. i]
        if not line then break end
        local text = line:GetText()
        if not canaccessvalue(text) then break end
        if text and string.find(text, id) then return end
    end
    if isItem then
        self:AddLine("|cffffffff" .. L.TOOLTIP_ITEM_ID .. " " .. id)
    else
        self:AddLine("|cffffffff" .. L.TOOLTIP_SPELL_ID .. " " .. id)
    end
    self:Show()
end

local function attachByAuraInstanceID(self, ...)
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
    local id = aura and aura.spellId
    if id then addLine(self, id) end
end

function module:OnInit()
    if not cfg.enable or not cfg.spell_id then return end

    hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
        local unit, slot = ...
        if not unit and not slot then return end
        local aura = C_UnitAuras.GetAuraDataBySlot(unit, slot)
        local id = aura and aura.spellId
        if id then addLine(self, id) end
    end)

    hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", attachByAuraInstanceID)
    hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", attachByAuraInstanceID)
    hooksecurefunc(GameTooltip, "SetUnitAuraByAuraInstanceID", attachByAuraInstanceID)

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

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(self, data)
        if self:IsForbidden() then return end
        local lineData = data.lines and data.lines[1]
        local tooltipType = lineData and lineData.tooltipType
        if not tooltipType then return end

        if tooltipType == 0 then
            addLine(self, lineData.tooltipID, true)
        elseif tooltipType == 1 then
            addLine(self, lineData.tooltipID)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(self, data)
        if self ~= GameTooltip or self:IsForbidden() then return end
        if data and data.id then
            addLine(self, data.id, true)
        end
    end)
end
