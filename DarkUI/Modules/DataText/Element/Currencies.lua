local E, C, L, DB = select(2, ...):unpack()

------------------------------------------------------------------------
-- Currencies
------------------------------------------------------------------------

local module = E:Module("DataText")

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_Bank_FetchDepositedMoney = C_Bank.FetchDepositedMoney
local GetMoney = GetMoney
local ToggleCharacter = ToggleCharacter
local format, wipe, abs, tsort = format, wipe, math.abs, table.sort
local ipairs, pairs = ipairs, pairs
local CURRENCY = CURRENCY
local TOTAL = TOTAL
local GameTooltip = GameTooltip

local MAX_BACKPACK_CURRENCIES = 10
local TIER_CHARGE_ID = 3378 -- 12.0 S1 catalyst charges, hidden currency, cannot be tracked in backpack

local t_icon = C.datatext.icon_size or 20
local cfg = module.config.Currencies

local function addCurrencyLine(name, amount, maxAmount, tex)
    local iconStr = format(" |T%d:%d:%d:0:0:64:64:5:59:5:59|t", tex, t_icon, t_icon)
    if maxAmount and maxAmount > 0 then
        GameTooltip:AddDoubleLine(name, amount .. " / " .. maxAmount .. iconStr, 1, 1, 1, 1, 1, 1)
    else
        GameTooltip:AddDoubleLine(name, amount .. iconStr, 1, 1, 1, 1, 1, 1)
    end
end

module:Inject("Currencies", {
    OnLoad = function(self)
        self.started = GetMoney()
        module:RegEvents(self, "PLAYER_LOGIN PLAYER_MONEY MERCHANT_SHOW")
    end,
    OnEvent = function(self)
        module.conf.Gold = GetMoney()
        self.text:SetText(module:FormatGold(cfg.style, module.conf.Gold))
    end,
    OnEnter = function(self)
        local curgold = GetMoney()
        module.conf.Gold = curgold
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint(cfg.tip_anchor, cfg.tip_frame, cfg.tip_x, cfg.tip_y)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(CURRENCY, module.tthead.r, module.tthead.g, module.tthead.b)
        GameTooltip:AddLine(" ")
        if self.started ~= curgold then
            local gained = curgold > self.started
            local color = gained and "|cff55ff55" or "|cffff5555"
            GameTooltip:AddDoubleLine(
                L.DATATEXT_SESSION_GAIN,
                format("%s$|r %s %s$|r", color, module:FormatGold(1, abs(self.started - curgold)), color),
                1,
                1,
                1,
                1,
                1,
                1
            )
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddLine(L.DATATEXT_SERVER_GOLD, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
        local total = 0
        local goldTable = {}
        wipe(goldTable)
        for char, sts in pairs(DB:GetStats(E.realm) or {}) do
            if sts.Gold and sts.Gold > 99 then goldTable[#goldTable + 1] = { char, module:FormatGold(5, sts.Gold), sts.Gold } end
        end
        tsort(goldTable, function(a, b)
            if a and b then return a[3] > b[3] end
        end)
        for _, v in ipairs(goldTable) do
            GameTooltip:AddDoubleLine(v[1], v[2], 1, 1, 1, 1, 1, 1)
            total = total + v[3]
        end
        local accountmoney = C_Bank_FetchDepositedMoney(Enum.BankType.Account)
        if accountmoney then
            GameTooltip:AddDoubleLine(ACCOUNT_BANK_PANEL_TITLE, module:FormatGold(1, accountmoney), 1, 1, 1, 1, 1, 1)
            total = total + accountmoney
        end
        GameTooltip:AddDoubleLine(" ", "-----------------", 1, 1, 1, 0.5, 0.5, 0.5)
        GameTooltip:AddDoubleLine(TOTAL, module:FormatGold(5, total), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)

        local title = false
        local chargeInfo = C_CurrencyInfo_GetCurrencyInfo(TIER_CHARGE_ID)
        if chargeInfo and chargeInfo.quantity then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(CURRENCY, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
            title = true
            addCurrencyLine(chargeInfo.name, chargeInfo.quantity, chargeInfo.maxQuantity, chargeInfo.iconFileID)
        end

        for i = 1, MAX_BACKPACK_CURRENCIES do
            local info = C_CurrencyInfo_GetBackpackCurrencyInfo(i)
            if not info then break end
            if info.name and info.quantity then
                if not title then
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine(CURRENCY, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
                    title = true
                end
                local currencyInfo = C_CurrencyInfo_GetCurrencyInfo(info.currencyTypesID)
                addCurrencyLine(info.name, info.quantity, currencyInfo and currencyInfo.maxQuantity, info.iconFileID)
            end
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(
            " ",
            L.DATATEXT_AUTO_SELL .. ": " .. (C.automation.auto_sell and "|cff55ff55" .. L.DATATEXT_ON or "|cffff5555" .. L.DATATEXT_OFF),
            1,
            1,
            1,
            module.ttsubh.r,
            module.ttsubh.g,
            module.ttsubh.b
        )
        GameTooltip:Show()
    end,
    OnClick = function(self, button)
        if button == "LeftButton" then
            ToggleCharacter("TokenFrame")
        elseif button == "RightButton" then
            C.automation.auto_sell = not C.automation.auto_sell
            DB:Set("automation.auto_sell", C.automation.auto_sell)
            self:GetScript("OnEnter")(self)
        end
    end,
})
