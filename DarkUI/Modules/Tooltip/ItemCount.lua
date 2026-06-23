local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Item Count
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("ItemCount")
local cfg = C.tooltip
local parent = E:Module("Tooltip")
local whiteTooltip = parent.whiteTooltips
local InfoColor = parent.InfoColor

local select = select
local C_Item_GetItemCount = C_Item.GetItemCount
local C_Item_GetItemInfo = C_Item.GetItemInfo

local function onTooltipSetItem(self, data)
    if not whiteTooltip[self] or self:IsForbidden() then return end
    if not data or not data.id then return end

    local bagCount = C_Item_GetItemCount(data.id)
    local bankCount = C_Item_GetItemCount(data.id, true, nil, true, true) - bagCount

    if bagCount <= 0 and bankCount <= 0 then return end

    if bankCount > 0 then
        self:AddDoubleLine(BAGSLOT .. "/" .. BANK .. ":", InfoColor .. bagCount .. "/" .. bankCount .. "|r")
    elseif bagCount > 0 then
        self:AddDoubleLine(BAGSLOT .. ":", InfoColor .. bagCount .. "|r")
    end

    local itemStackCount = select(8, C_Item_GetItemInfo(data.id))
    if itemStackCount and itemStackCount > 1 then self:AddDoubleLine(L.TOOLTIP_STACK_CAP .. ":", InfoColor .. itemStackCount .. "|r") end
end

function module:OnInit()
    if not cfg.enable or not cfg.item_count then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, onTooltipSetItem)
end
