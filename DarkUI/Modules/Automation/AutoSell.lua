local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Sell
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoSell")

local cfg = C.automation
local floor, format = math.floor, string.format

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.auto_sell then return end

    self:RegisterEvent("MERCHANT_SHOW", function()
        local totalCost = 0
        local numItem = 0

        for bag = 0, NUM_BAG_SLOTS do
            for slot = 0, C_Container.GetContainerNumSlots(bag) do
                local link = C_Container.GetContainerItemLink(bag, slot)
                if link then
                    local _, _, itemRarity, _, _, _, _, _, _, _, itemSellPrice = C_Item.GetItemInfo(link)
                    local info = C_Container.GetContainerItemInfo(bag, slot)
                    if itemSellPrice and itemSellPrice > 0 and itemRarity == 0 then
                        totalCost = totalCost + (itemSellPrice * info.stackCount)
                        numItem = numItem + 1
                        if numItem < 12 then
                            C_Container.UseContainerItem(bag, slot)
                        else
                            C_Timer.After(numItem / 8, function()
                                C_Container.UseContainerItem(bag, slot)
                            end)
                        end
                    end
                end
            end
        end

        if totalCost > 0 then
            local g = floor(totalCost / 10000) or 0
            local s = floor((totalCost % 10000) / 100) or 0
            local c = totalCost % 100
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffffff00" .. (L.AUTO_SELL_INFO or "Sold junk: ") .. "|r"
                .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " "
                .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " "
                .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0),
                255, 255, 255
            )
        end
    end)
end
