local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Repair
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoRepair")

local cfg = C.automation
local floor, format = math.floor, string.format

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.auto_repair then return end

    self:RegisterEvent("MERCHANT_SHOW", function()
        if not CanMerchantRepair() then return end

        local cost, possible = GetRepairAllCost()
        if cost <= 0 then return end

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
                DEFAULT_CHAT_FRAME:AddMessage(
                    "|cffffff00" .. (L.AUTO_REPAIR_GUIDE_INFO or "Guild repair: ") .. "|r"
                    .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " "
                    .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " "
                    .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0),
                    255, 255, 255
                )
                return
            end
        end

        if possible then
            RepairAllItems()
            DEFAULT_CHAT_FRAME:AddMessage(
                "|cffffff00" .. (L.AUTO_REPAIR_INFO or "Repair: ") .. "|r"
                .. format(GOLD_AMOUNT_TEXTURE, g, 0, 0) .. " "
                .. format(SILVER_AMOUNT_TEXTURE, s, 0, 0) .. " "
                .. format(COPPER_AMOUNT_TEXTURE, c, 0, 0),
                255, 255, 255
            )
        else
            DEFAULT_CHAT_FRAME:AddMessage(L.AUTO_REPAIR_NOTENOUGH_INFO or "Not enough money to repair!", 255, 0, 0)
        end
    end)
end
