local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Auto repair
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local CanMerchantRepair, GetRepairAllCost = CanMerchantRepair, GetRepairAllCost
local IsInGuild = IsInGuild
local GetGuildBankWithdrawMoney, GetGuildBankMoney = GetGuildBankWithdrawMoney, GetGuildBankMoney
local CanGuildBankRepair = CanGuildBankRepair
local RepairAllItems = RepairAllItems
local format, floor = format, math.floor
local DEFAULT_CHAT_FRAME = DEFAULT_CHAT_FRAME
local GOLD_AMOUNT_TEXTURE = GOLD_AMOUNT_TEXTURE
local SILVER_AMOUNT_TEXTURE = SILVER_AMOUNT_TEXTURE
local COPPER_AMOUNT_TEXTURE = COPPER_AMOUNT_TEXTURE

local Event = CreateFrame("Frame")
Event:RegisterEvent("MERCHANT_SHOW")
Event:SetScript("OnEvent", function(self)
    if not C.automation.auto_repair then return end -- for dynamic change with datatext

    if CanMerchantRepair() then
        local cost, possible = GetRepairAllCost()
        if cost > 0 then
            local c = cost % 100
            local s = floor((cost % 10000) / 100)
            local g = floor(cost / 10000)
            if IsInGuild() then
                local guildMoney = GetGuildBankWithdrawMoney()
                if guildMoney > GetGuildBankMoney() then
                    guildMoney = GetGuildBankMoney()
                end
                if guildMoney > cost and CanGuildBankRepair() then
                    RepairAllItems(1)
                    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L.AUTO_REPAIR_GUIDE_INFO .. "|r" .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " " .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " " .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0), 255, 255, 255)
                    return
                end
            end
            if possible then
                RepairAllItems()
                DEFAULT_CHAT_FRAME:AddMessage("|cffffff00" .. L.AUTO_REPAIR_INFO .. "|r" .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " " .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " " .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0), 255, 255, 255)
            else
                DEFAULT_CHAT_FRAME:AddMessage(L.AUTO_REPAIR_NOTENOUGH_INFO, 255, 0, 0)
            end
        end
    end
end)