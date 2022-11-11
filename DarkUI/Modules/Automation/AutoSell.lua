local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Auto repair
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local GetContainerNumSlots, GetContainerItemLink = GetContainerNumSlots, GetContainerItemLink
local GetContainerItemInfo, GetItemInfo = GetContainerItemInfo, GetItemInfo
local UseContainerItem = UseContainerItem
local PickupMerchantItem = PickupMerchantItem
local select, format, floor = select, format, math.floor
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GOLD_AMOUNT_TEXTURE = GOLD_AMOUNT_TEXTURE
local SILVER_AMOUNT_TEXTURE = SILVER_AMOUNT_TEXTURE
local COPPER_AMOUNT_TEXTURE = COPPER_AMOUNT_TEXTURE

local Event = CreateFrame("Frame")
Event:RegisterEvent("MERCHANT_SHOW")
Event:SetScript("OnEvent", function(self)
    if not C.automation.auto_sell then return end -- for dynamic change with datatext

    local Cost = 0
    for BagID = 0, 4 do
        for SlotID = 1, GetContainerNumSlots(BagID) do
            local Link = GetContainerItemLink(BagID, SlotID)
            if Link and GetItemInfo(Link) ~= nil then
                local p = select(11, GetItemInfo(Link)) * select(2, GetContainerItemInfo(BagID, SlotID))
                if select(3, GetItemInfo(Link)) == 0 and p > 0 then
                    UseContainerItem(BagID, SlotID)
                    PickupMerchantItem()
                    Cost = Cost + p
                end
            end
        end
    end
    if Cost > 0 then
        local g, s, c = floor(Cost / 10000) or 0, floor((Cost % 10000) / 100) or 0, Cost % 100
        DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L.AUTO_SELL_INFO .. "|r" .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " " .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " " .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0), 255, 255, 255)
    end
end)
