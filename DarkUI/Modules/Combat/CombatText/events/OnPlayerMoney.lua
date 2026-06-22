local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnPlayerMoney
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combat.combatText

local floor = math.floor
local GetMoney = GetMoney

local previousMoney
local dataEvent = {}

local function onPlayerMoney()
    if not cfg.loot then
        return
    end

    local currentMoney = GetMoney()
    if not previousMoney then
        previousMoney = currentMoney
        return
    end

    local moneyChange = currentMoney - previousMoney

    if moneyChange > 0 then
        wipe(dataEvent)

        local moneyChangeGold = floor(moneyChange / 1e4)
        local moneyChangeSilver = floor(moneyChange / 100 % 100)
        local moneyChangeCopper = moneyChange % 100

        dataEvent.eventType = "SELF_MONEY_LOOTED"
        dataEvent.gold = moneyChangeGold
        dataEvent.silver = moneyChangeSilver
        dataEvent.copper = moneyChangeCopper

        module.Display.Format(dataEvent)
    end

    previousMoney = currentMoney
end

module.handlers = module.handlers or {}
module.handlers["PLAYER_MONEY"] = onPlayerMoney
