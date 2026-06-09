local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Currencies
------------------------------------------------------------------------

local module = E:Module("DataText")

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_CurrencyInfo_GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
local C_CurrencyInfo_GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
local C_CurrencyInfo_ExpandCurrencyList = C_CurrencyInfo.ExpandCurrencyList
local C_Bank_FetchDepositedMoney = C_Bank.FetchDepositedMoney
local GetMoney = GetMoney
local GetProfessions = GetProfessions
local ToggleCharacter = ToggleCharacter
local format, wipe, abs, tsort = format, wipe, math.abs, table.sort
local ipairs, pairs, table_insert = ipairs, pairs, table.insert
local CURRENCY = CURRENCY
local DUNGEONS_AND_RAIDS = DUNGEONS .. QUEST_LOGIC_AND .. RAIDS
local OTHER = OTHER
local PROFESSIONS_ARCHAEOLOGY = PROFESSIONS_ARCHAEOLOGY
local PROFESSIONS_COOKING = PROFESSIONS_COOKING
local PVP = PVP
local REFORGE_CURRENT = REFORGE_CURRENT
local TOTAL = TOTAL
local TRACKING = TRACKING
local WEEKLY = WEEKLY
local GameTooltip = GameTooltip

local t_icon = C.stats.icon_size or 20
local cfg = module.config.Currencies

local function hasAvailableChildren(list, withZero)
    if not list or #list == 0 then
        return false
    end
    if withZero then
        return true
    end
    for _, info in ipairs(list) do
        if info.quantity > 0 then
            return true
        end
    end
    return false
end

local function addCurrenciesToTooltip(name, list, withZero)
    if hasAvailableChildren(list, withZero) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(name, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
        for _, info in ipairs(list) do
            local cName, amount, tex = info.name, info.quantity, info.iconFileID
            local week, weekmax, maxed = info.canEarnPerWeek, info.maxWeeklyQuantity, info.maxQuantity
            local r, g, b
            if info.isShowInBackpack and info.quantity > 0 then
                r, g, b = 1, 1, 1
            else
                r, g, b = 0.5, 0.5, 0.5
            end
            if amount > 0 or withZero then
                if week then
                    GameTooltip:AddDoubleLine(
                        cName,
                        format(
                            "%s |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t",
                            REFORGE_CURRENT .. ": " .. amount .. " - " .. WEEKLY .. ": " .. weekmax,
                            tex,
                            t_icon
                        ),
                        r,
                        g,
                        b,
                        1,
                        1,
                        1
                    )
                elseif maxed and maxed > 0 then
                    GameTooltip:AddDoubleLine(
                        cName,
                        format("%s |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t", amount .. " / " .. maxed, tex, t_icon),
                        r,
                        g,
                        b,
                        1,
                        1,
                        1
                    )
                else
                    GameTooltip:AddDoubleLine(
                        cName,
                        format("%s |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t", amount, tex, t_icon),
                        r,
                        g,
                        b,
                        1,
                        1,
                        1
                    )
                end
            end
        end
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
        local _, _, archaeology, _, cooking = GetProfessions()
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
        for char, sts in pairs(SavedStats[E.realm]) do
            if sts.Gold and sts.Gold > 99 then
                goldTable[#goldTable + 1] = { char, module:FormatGold(5, sts.Gold), sts.Gold }
            end
        end
        tsort(goldTable, function(a, b)
            if a and b then
                return a[3] > b[3]
            end
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
        GameTooltip:AddLine(" ")

        local currencies = {}
        local collapsed = {}
        local header = nil
        local listSize = C_CurrencyInfo_GetCurrencyListSize()
        local i = 1

        while listSize >= i do
            local info = C_CurrencyInfo_GetCurrencyListInfo(i)
            if info.isShowInBackpack then
                if not currencies[TRACKING] then
                    currencies[TRACKING] = {}
                end
                table_insert(currencies[TRACKING], info)
            elseif info.isHeader then
                header = info.name
                currencies[header] = {}
                if not info.isHeaderExpanded then
                    C_CurrencyInfo_ExpandCurrencyList(i, true)
                    listSize = C_CurrencyInfo_GetCurrencyListSize()
                    collapsed[header] = true
                end
            elseif header and currencies[header] then
                table_insert(currencies[header], info)
            end
            i = i + 1
        end

        if archaeology then
            local list = {}
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(384))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(385))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(393))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(394))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(397))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(398))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(399))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(400))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(401))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(676))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(677))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(754))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(821))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(828))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(829))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(1172))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(1173))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(1174))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(1534))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(1535))
            currencies[PROFESSIONS_ARCHAEOLOGY] = list
        end

        if cooking then
            local list = {}
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(81))
            table_insert(list, C_CurrencyInfo_GetCurrencyInfo(402))
            currencies[PROFESSIONS_COOKING] = list
        end

        local orders = {
            { name = TRACKING, withZero = true, visible = C.stats.currencies.tracking },
            { name = CURRENT_EXPANSION, withZero = true, visible = C.stats.currencies.expansion },
            { name = PROFESSIONS_ARCHAEOLOGY, withZero = false, visible = C.stats.currencies.archaeology },
            { name = PROFESSIONS_COOKING, withZero = false, visible = C.stats.currencies.cooking },
            { name = DUNGEONS_AND_RAIDS, withZero = false, visible = C.stats.currencies.raid },
            { name = PVP, withZero = false, visible = C.stats.currencies.pvp },
            { name = OTHER, withZero = false, visible = C.stats.currencies.other },
        }

        for _, tip in ipairs(orders) do
            if tip.visible and currencies[tip.name] then
                addCurrenciesToTooltip(tip.name, currencies[tip.name], tip.withZero)
                currencies[tip.name] = nil
            end
        end

        i = C_CurrencyInfo_GetCurrencyListSize()
        while i > 0 do
            local info = C_CurrencyInfo_GetCurrencyListInfo(i)
            if info and info.isHeader then
                if collapsed[info.name] then
                    C_CurrencyInfo_ExpandCurrencyList(i, false)
                elseif currencies[info.name] then
                    if info.name ~= CURRENT_EXPANSION and info.name ~= DUNGEONS_AND_RAIDS and info.name ~= PVP and info.name ~= OTHER then
                        addCurrenciesToTooltip(info.name, currencies[info.name], true)
                    end
                end
            end
            i = i - 1
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
            E:SetVariable("automation", "auto_sell", C.automation.auto_sell)
            self:GetScript("OnEnter")(self)
        end
    end,
})
