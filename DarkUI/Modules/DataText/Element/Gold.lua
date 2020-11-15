local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Gold.enable then return end

----------------------------------------------------------------------------------------
--	Gold of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local GetMoney = GetMoney
local GetProfessions = GetProfessions
local C_CurrencyInfo_GetCurrencyListSize = C_CurrencyInfo.GetCurrencyListSize
local C_CurrencyInfo_GetCurrencyListInfo = C_CurrencyInfo.GetCurrencyListInfo
local ToggleCharacter = ToggleCharacter
local format, wipe, abs, tsort, strupper = format, wipe, math.abs, table.sort, strupper
local PROFESSIONS_ARCHAEOLOGY = PROFESSIONS_ARCHAEOLOGY
local PROFESSIONS_COOKING = PROFESSIONS_COOKING
local TRADE_SKILLS = TRADE_SKILLS
local EXPANSION_NAME7 = EXPANSION_NAME7
local CURRENCY = CURRENCY
local TOTAL = TOTAL
local OFF = OFF
local TRACKING = TRACKING
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL
local REFORGE_CURRENT = REFORGE_CURRENT
local WEEKLY = WEEKLY
local GameTooltip = GameTooltip

local t_icon = C.stats.icon_size or 20
local cfg = C.stats.config.Gold
local module = E.datatext

local IsSubTitle = 0
local function Currency(id, weekly, capped)
    local info = C_CurrencyInfo.GetCurrencyInfo(id)
		local name, amount, tex, week, weekmax, maxed, discovered = info.name, info.quantity, info.iconFileID, info.canEarnPerWeek, info.maxWeeklyQuantity, info.maxQuantity, info.discovered
    if amount == 0 then return end
    if IsSubTitle == 1 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(PROFESSIONS_ARCHAEOLOGY, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
    elseif IsSubTitle == 2 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(PROFESSIONS_COOKING, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
    elseif IsSubTitle == 3 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(TRADE_SKILLS, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
    elseif IsSubTitle == 4 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(L.DATATEXT_CURRENCY_RAID, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
    elseif IsSubTitle == 5 then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(EXPANSION_NAME7, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
    end
    IsSubTitle = 0
    if weekly then
        if discovered then GameTooltip:AddDoubleLine(name, format("%s |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t", REFORGE_CURRENT .. ": " .. amount .. " - " .. WEEKLY .. ": " .. week .. " / " .. weekmax, tex, t_icon), 1, 1, 1, 1, 1, 1) end
    elseif capped then
        if id == 392 then maxed = 4000 end
        if discovered then GameTooltip:AddDoubleLine(name, format("%s |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t", amount .. " / " .. maxed, tex, t_icon), 1, 1, 1, 1, 1, 1) end
    else
        if discovered then GameTooltip:AddDoubleLine(name, format("%s |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t", amount, tex, t_icon), 1, 1, 1, 1, 1, 1) end
    end
end

module:Inject("Gold", {
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
        GameTooltip:AddDoubleLine(" ", "-----------------", 1, 1, 1, 0.5, 0.5, 0.5)
        GameTooltip:AddDoubleLine(TOTAL, module:FormatGold(5, total), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1, 1, 1)
        GameTooltip:AddLine(" ")

        local currencies = 0
        for i = 1, C_CurrencyInfo_GetCurrencyListSize() do
            local info = C_CurrencyInfo.GetCurrencyListInfo(i)
            if info and info.isShowInBackpack then
                if currencies == 0 then GameTooltip:AddLine(TRACKING, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b) end
                local r, g, b
                if count > 0 then r, g, b = 1, 1, 1 else r, g, b = 0.5, 0.5, 0.5 end
                GameTooltip:AddDoubleLine(name, format("%d |T%s:" .. t_icon .. ":" .. t_icon .. ":0:0:64:64:5:59:5:59:%d|t", info.quantity, info.iconFileID, t_icon), r, g, b, r, g, b)
                currencies = currencies + 1
            end
        end
        if archaeology and C.stats.currency_archaeology then
            IsSubTitle = 1
            Currency(384)    -- Dwarf Archaeology Fragment
            Currency(385)    -- Troll Archaeology Fragment
            Currency(393)    -- Fossil Archaeology Fragment
            Currency(394)    -- Night Elf Archaeology Fragment
            Currency(397)    -- Orc Archaeology Fragment
            Currency(398)    -- Draenei Archaeology Fragment
            Currency(399)    -- Vrykul Archaeology Fragment
            Currency(400)    -- Nerubian Archaeology Fragment
            Currency(401)    -- Tol'vir Archaeology Fragment
            Currency(676)    -- Pandaren Archaeology Fragment
            Currency(677)    -- Mogu Archaeology Fragment
            Currency(754)    -- Mantid Archaeology Fragment
            Currency(821)    -- Draenor Clans Archaeology Fragment
            Currency(828)    -- Ogre Archaeology Fragment
            Currency(829)    -- Arakkoa Archaeology Fragment
            Currency(1172)   -- Highborne Archaeology Fragment
            Currency(1173)   -- Highmountain Tauren Archaeology Fragment
            Currency(1174)   -- Demonic Archaeology Fragment
            Currency(1534)   -- Zandalari
            Currency(1535)   -- Drust
        end

        if cooking and C.stats.currency_cooking then
            IsSubTitle = 2
            Currency(81)     -- Epicurean's Award
            Currency(402)    -- Ironpaw Token
        end

        if C.stats.currency_professions then
            IsSubTitle = 3
            Currency(910)    -- Secret of Draenor Alchemy
            Currency(999)    -- Secret of Draenor Tailoring
            Currency(1008)    -- Secret of Draenor Jewelcrafting
            Currency(1017)    -- Secret of Draenor Leatherworking
            Currency(1020)    -- Secret of Draenor Blacksmithing
        end

        if C.stats.currency_raid and E.level == MAX_PLAYER_LEVEL then
            IsSubTitle = 4
            Currency(1580, false, true)    -- Seal of Wartorn Fate
        end

        if C.stats.currency_misc then
            IsSubTitle = 5
            Currency(1560)	-- War Resources
            Currency(1565)  -- Rich Azerite Fragment
            Currency(1580)  -- Seal of Wartorn Fate
            Currency(1587)  -- War Supplies
            Currency(1710)	-- Seafarer's Dubloon
            Currency(1716)	-- Honorbound Service Medal
            Currency(1717)	-- 7th Legion Service Medal
            Currency(1718)	-- Titan Residuum
            Currency(1719)	-- Corrupted Mementos
            Currency(1721)	-- Prismatic Manapearl
            Currency(1755)	-- Coalescing Visions
            Currency(1803)	-- Echoes of Ny'alotha
            Currency(515)	-- Darkmoon Prize Ticket
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddDoubleLine(" ", L.DATATEXT_AUTO_SELL .. ": " .. (C.automation.auto_sell and "|cff55ff55" .. L.DATATEXT_ON or "|cffff5555" .. strupper(OFF)), 1, 1, 1, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
        GameTooltip:Show()
    end,
    OnClick = function(_, button)
        if button == "LeftButton" then
            ToggleCharacter("TokenFrame")
        end
    end
})
