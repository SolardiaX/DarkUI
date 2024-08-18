local E, C, L = select(2, ...):unpack()

if not C.misc.alt_buy_stack then return end

----------------------------------------------------------------------------------------
--    Alt+Click to buy a stack
----------------------------------------------------------------------------------------

hooksecurefunc("MerchantItemButton_OnModifiedClick", function(self)
    if IsAltKeyDown() then
        local id = self:GetID()
        local itemLink = GetMerchantItemLink(id)
        if not itemLink then return end

        local maxStack = select(8, GetItemInfo(itemLink))
        if maxStack and maxStack > 1 then
            local numAvailable = select(5, GetMerchantItemInfo(id))
            if numAvailable > -1 then
                BuyMerchantItem(id, numAvailable)
            else
                BuyMerchantItem(id, GetMerchantItemMaxStack(id))
            end
        end
    end
end)

ITEM_VENDOR_STACK_BUY = _G.ITEM_VENDOR_STACK_BUY.."\n|cff00ff00<"..L.MISC_BUY_STACK..">|r"
