local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnCurrencyDisplayUpdate
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combat.combatText

local dataEvent = {}

local function onCurrencyDisplayUpdate(...)
    local currencyType, quantity, quantityChange = ...

    if not cfg.loot then
        return
    end

    if quantityChange and quantityChange > 0 then
        wipe(dataEvent)

        dataEvent.eventType = "SELF_CURRENCY_GAINED"
        dataEvent.quantityChange = quantityChange
        dataEvent.currencyName = C_CurrencyInfo.GetCurrencyInfo(currencyType).name
        dataEvent.totalAmount = quantity

        module.Display.Format(dataEvent)
    end
end

module.handlers = module.handlers or {}
module.handlers["CURRENCY_DISPLAY_UPDATE"] = onCurrencyDisplayUpdate
