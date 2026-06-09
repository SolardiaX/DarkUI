local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Item Icons
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("ItemIcons")
local cfg = C.tooltip

local whiteTooltip = {
    [GameTooltip] = true,
    [ItemRefTooltip] = true,
    [ItemRefShoppingTooltip1] = true,
    [ItemRefShoppingTooltip2] = true,
    [ShoppingTooltip1] = true,
    [ShoppingTooltip2] = true,
}

local function setTooltipIcon(self, icon)
    local title = icon and _G[self:GetName() .. "TextLeft1"]
    local text = title and title:GetText()
    if title and text and not text:find("|T" .. icon) then
        title:SetFormattedText("|T%s:20:20:0:0:64:64:5:59:5:59:%d|t %s", icon, 20, text)
    end
end

function module:OnInit()
    if not cfg.enable or not cfg.item_icon then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self, data)
        if whiteTooltip[self] and not self:IsForbidden() then
            if data and data.id then
                setTooltipIcon(self, GetItemIcon(data.id))
            end
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
        if whiteTooltip[self] and not self:IsForbidden() then
            if data and data.id then
                setTooltipIcon(self, C_Spell.GetSpellTexture(data.id))
            end
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(self, data)
        if whiteTooltip[self] and not self:IsForbidden() then
            local lineData = data.lines and data.lines[1]
            local tooltipType = lineData and lineData.tooltipType
            if not tooltipType then return end

            if tooltipType == 0 then -- item
                setTooltipIcon(self, GetItemIcon(lineData.tooltipID))
            elseif tooltipType == 1 then -- spell
                setTooltipIcon(self, C_Spell.GetSpellTexture(lineData.tooltipID))
            end
        end
    end)
end
