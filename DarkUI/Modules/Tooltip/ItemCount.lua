﻿local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.item_count ~= true then return end

----------------------------------------------------------------------------------------
--	Item count in bags and bank(by Tukz)
----------------------------------------------------------------------------------------

local function OnTooltipSetItem(self, data)
    if self ~= GameTooltip or self:IsForbidden() then return end
    local num = GetItemCount(data.id, true)
    if num > 1 then
        self:AddLine("|cffffffff"..L.TOOLTIP_ITEM_COUNT.." "..num.."|r")
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
