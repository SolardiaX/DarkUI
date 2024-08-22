local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Currencies.enable then return end

----------------------------------------------------------------------------------------
--    Currencies of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_CurrencyInfo_GetBackpackCurrencyInfo = C_CurrencyInfo.GetBackpackCurrencyInfo
local C_CurrencyInfo_GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
local C_CurrencyInfo_GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
local C_CurrencyInfo_ExpandCurrencyList = C_CurrencyInfo.ExpandCurrencyList
local C_Bank_FetchDepositedMoney = C_Bank.FetchDepositedMoney
local GetMoney = GetMoney
local GetProfessions = GetProfessions
local ToggleCharacter = ToggleCharacter
local format, wipe, abs, tsort, strupper = format, wipe, math.abs, table.sort, strupper
local CURRENCY = CURRENCY
local DUNGEONS_AND_RAIDS = DUNGEONS .. QUEST_LOGIC_AND .. RAIDS
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local OFF = OFF
local OTHER = OTHER
local PROFESSIONS_ARCHAEOLOGY = PROFESSIONS_ARCHAEOLOGY
local PROFESSIONS_COOKING = PROFESSIONS_COOKING
local PVP = PVP
local REFORGE_CURRENT = REFORGE_CURRENT
local TOTAL = TOTAL
local TRACKING = TRACKING
local TRADE_SKILLS = TRADE_SKILLS
local WEEKLY = WEEKLY
local GameTooltip = GameTooltip

local t_icon = C.stats.icon_size or 20
local cfg = C.stats.config.Currencies
local tracking_group_index = 99999


local function hasAvaliableChildren(list, withZero)
    if not list or #list == 0 then return false end

    if withZero then return true end

    for _, info in ipairs(list) do
        if info.quantity > 0 then return true end
    end

    return false
end

local function AddCurrenciesToTooltip(name, list, withZero)
    if hasAvaliableChildren(list, withZero) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(name, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
        
        for _, info in ipairs(list) do
            local name, amount, tex, week, weekmax, maxed = info.name, info.quantity, info.iconFileID, info.canEarnPerWeek, info.maxWeeklyQuantity, info.maxQuantity

            local r, g, b
            if info.isShowInBackpack and info.quantity > 0 then r, g, b = 1, 1, 1 else r, g, b = 0.5, 0.5, 0.5 end

            if amount > 0 or withZero then
                if week then
                    GameTooltip:AddDoubleLine(name, format("%s |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", REFORGE_CURRENT..": ".. amount.." - "..WEEKLY..": "..weekmax, tex, t_icon), r, g, b, 1, 1, 1)
                elseif maxed > 0 then
                    GameTooltip:AddDoubleLine(name, format("%s |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", amount.." / "..maxed, tex, t_icon), r, g, b, 1, 1, 1)
                else
                    GameTooltip:AddDoubleLine(name, format("%s |T%s:"..t_icon..":"..t_icon..":0:0:64:64:5:59:5:59:%d|t", amount, tex, t_icon), r, g, b, 1, 1, 1)
                end
            end
        end
    end
end

module:Inject("Currencies", {
    OnLoad  = function(self)
        self.started = GetMoney()
        module:RegEvents(self, "PLAYER_LOGIN PLAYER_MONEY MERCHANT_SHOW")
    end,
    OnEvent = function(self, _)
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
            GameTooltip:AddDoubleLine(L.DATATEXT_SESSION_GAIN, format("%s$|r %s %s$|r", color, module:FormatGold(1, abs(self.started - curgold)), color), 1, 1, 1, 1, 1, 1)
            GameTooltip:AddLine(" ")
        end
        GameTooltip:AddLine(L.DATATEXT_SERVER_GOLD, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
        local total = 0
        local goldTable = {}
        local charIndex = 0
        wipe(goldTable)
        for char, sts in pairs(SavedStats[E.realm]) do
            if sts.Gold and sts.Gold > 99 then
                charIndex = charIndex + 1
                goldTable[charIndex] = { char, module:FormatGold(5, sts.Gold), sts.Gold }
            end
        end
        tsort(goldTable, function(a, b)
            if (a and b) then
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

        local listSize, i = C_CurrencyInfo_GetCurrencyListSize(), 1

        while listSize >= i do
            local info = C_CurrencyInfo_GetCurrencyListInfo(i)

            if info.isShowInBackpack then
                if not currencies[TRACKING] then
                    currencies[TRACKING] = {}
                end

                table.insert(currencies[TRACKING], info)
            elseif info.isHeader then
                header = info.name
                currencies[header] = {}

                if not info.isHeaderExpanded then
                    C_CurrencyInfo_ExpandCurrencyList(i, true)
                    listSize = C_CurrencyInfo_GetCurrencyListSize()
                    collapsed[header] = true
                end
            elseif header and currencies[header] then
                table.insert(currencies[header], info)
            end

            i = i + 1
        end

        if archaeology then
            local list = {}

            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(384))    -- Dwarf Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(385))    -- Troll Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(393))    -- Fossil Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(394))    -- Night Elf Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(397))    -- Orc Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(398))    -- Draenei Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(399))    -- Vrykul Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(400))    -- Nerubian Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(401))    -- Tol'vir Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(676))    -- Pandaren Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(677))    -- Mogu Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(754))    -- Mantid Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(821))    -- Draenor Clans Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(828))    -- Ogre Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(829))    -- Arakkoa Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(1172))   -- Highborne Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(1173))   -- Highmountain Tauren Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(1174))   -- Demonic Archaeology Fragment
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(1534))   -- Zandalari
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(1535))   -- Drust

            currencies[PROFESSIONS_ARCHAEOLOGY] = list
        end

        if cooking then
            local list = {}
            
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(81))      -- Epicurean's Award
            table.insert(list, C_CurrencyInfo_GetCurrencyInfo(402))     -- Ironpaw Token

            currencies[PROFESSIONS_COOKING] = list
        end

        local orders = {
            [1] = { name = TRACKING, withZero = true, visiable = C.stats.currency_tracking },
            [2] = { name = CURRENT_EXPANSION, withZero = true, visiable = C.stats.currency_expansion },
            [3] = { name = PROFESSIONS_ARCHAEOLOGY, withZero = false, visiable = C.stats.currency_expansion },
            [4] = { name = PROFESSIONS_COOKING, withZero = false, visiable = C.stats.currency_cooking },
            [5] = { name = DUNGEONS_AND_RAIDS, withZero = false, visiable = C.stats.currency_raid },
            [6] = { name = PVP, withZero = false, visiable = C.stats.currency_pvp },
            [7] = { name = OTHER, withZero = false, visiable = C.stats.currency_other },
        }

        for index, tip in ipairs(orders) do
            if tip.visiable and currencies[tip.name] then
                AddCurrenciesToTooltip(tip.name, currencies[tip.name], tip.withZero)
                currencies[tip.name] = nil
            end
        end
    
        i = C_CurrencyInfo_GetCurrencyListSize()
        while i > 0 do
            local info = C_CurrencyInfo_GetCurrencyListInfo(i)
            if info and info.isHeader then
                if collapsed[info.name] then
                    C_CurrencyInfo_ExpandCurrencyList(i, false)
                    listSize = C_CurrencyInfo_GetCurrencyListSize()
                elseif currencies[info.name] then
                    if info.name ~= CURRENT_EXPANSION 
                        and info.name ~= DUNGEONS_AND_RAIDS 
                        and info.name ~= PVP 
                        and info.name ~= OTHER 
                    then
                        AddCurrenciesToTooltip(info.name, currencies[info.name], true)
                    end
                end
            end

            i = i - 1
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(" ", L.DATATEXT_AUTO_SELL .. ": " .. (C.automation.auto_sell and "|cff55ff55" .. L.DATATEXT_ON or "|cffff5555" .. L.DATATEXT_OFF), 1, 1, 1, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
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
    end
})
