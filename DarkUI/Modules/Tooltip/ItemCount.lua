local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Item Count
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("ItemCount")
local cfg = C.tooltip

local function onTooltipSetItem(self, data)
    if self ~= GameTooltip or self:IsForbidden() then return end
    local num = GetItemCount(data.id, true)
    if num > 1 then
        self:AddLine("|cffffffff" .. L.TOOLTIP_ITEM_COUNT .. " " .. num .. "|r")
    end
end

function module:OnInit()
    if not cfg.enable or not cfg.item_count then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, onTooltipSetItem)
end
