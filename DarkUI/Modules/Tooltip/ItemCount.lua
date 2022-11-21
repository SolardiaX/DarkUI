local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.item_count ~= true then return end

----------------------------------------------------------------------------------------
--	Item count in tooltip(by Tukz)
----------------------------------------------------------------------------------------

local function OnTooltipSetItem(self)
        local _, link = self:GetItem()
        local num = GetItemCount(link, true)

    if num > 1 then
        self:AddLine("|cffffffff"..L.TOOLTIP_ITEM_COUNT.." "..num.."|r")
    end
end

local function OnTooltipSetItem(self)
    local _, link = TooltipUtil.GetDisplayedItem(self)
    local num = GetItemCount(link, true)
    if num > 1 then
        self:AddLine("|cffffffff"..L.TOOLTIP_ITEM_COUNT.." "..num.."|r")
    end
end

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
