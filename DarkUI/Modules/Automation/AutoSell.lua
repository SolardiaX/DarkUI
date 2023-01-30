local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Auto repair
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("AutoSell")

local CreateFrame = CreateFrame
local GetContainerNumSlots, GetContainerItemLink = C_Container.GetContainerNumSlots, C_Container.GetContainerItemLink
local GetContainerItemInfo, UseContainerItem = C_Container.GetContainerItemInfo, C_Container.UseContainerItem
local GetItemInfo, PickupMerchantItem = GetItemInfo, PickupMerchantItem
local select, format, floor = select, format, math.floor
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GOLD_AMOUNT_TEXTURE = GOLD_AMOUNT_TEXTURE
local SILVER_AMOUNT_TEXTURE = SILVER_AMOUNT_TEXTURE
local COPPER_AMOUNT_TEXTURE = COPPER_AMOUNT_TEXTURE

module:RegisterEvent("MERCHANT_SHOW", function(self)
    if not C.automation.auto_sell then return end -- for dynamic change with datatext

    local Cost = 0

    local numItem = 0
    for bag = 0, NUM_BAG_SLOTS do 
        for slot = 0, GetContainerNumSlots(bag) do
            local link = GetContainerItemLink(bag, slot)
            if link then
                local _, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = GetItemInfo(link)
                local info = GetContainerItemInfo(bag, slot)
                if itemSellPrice and itemSellPrice > 0 and itemRarity == 0 then
                    Cost = Cost + (itemSellPrice * info.stackCount)
                    numItem = numItem + 1
                    if numItem < 12 then
                        UseContainerItem(bag, slot)
                    else
                        C_Timer.After(numItem/8, function()
                            UseContainerItem(bag, slot)
                        end)
                    end
                end
            end
        end 
    end

    if Cost > 0 then
        local g, s, c = floor(Cost / 10000) or 0, floor((Cost % 10000) / 100) or 0, Cost % 100
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L.AUTO_SELL_INFO .. "|r" .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " " .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " " .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0), 255, 255, 255)
    end
end)
