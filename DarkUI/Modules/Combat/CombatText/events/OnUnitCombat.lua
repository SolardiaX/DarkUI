local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnUnitCombat
------------------------------------------------------------------------

local module = E:Module("CombatText")

local PLAYER_GUID = UnitGUID("player") or "0x0000000000000000"
local PLAYER_NAME = UnitName("player")

local dataBatches = {}

local dataEventPool = {}

local function getDataEvent()
    if #dataEventPool > 0 then
        return table.remove(dataEventPool)
    end
    return {}
end

local function releaseDataEvent(t)
    wipe(t)
    table.insert(dataEventPool, t)
end

local function sendBatch(dataBatch)
    local dataEvent = dataBatch[1]

    if #dataBatch > 1 then
        for i = 2, #dataBatch do
            dataEvent.amount = dataEvent.amount + dataBatch[i].amount
        end
    end

    dataEvent.spellCount = #dataBatch

    module.Display.Format(dataEvent)

    for _, event in ipairs(dataBatch) do
        releaseDataEvent(event)
    end
end

local function unitCombatBatcher(dataEvent)
    local batchDelay = 0.15
    local eventType = dataEvent.eventType

    if not dataBatches[eventType] then
        dataBatches[eventType] = { dataEvent }

        C_Timer.After(batchDelay, function()
            sendBatch(dataBatches[eventType])
            dataBatches[eventType] = nil
        end)
    else
        table.insert(dataBatches[eventType], dataEvent)
    end
end

local function onUnitCombat(...)
    local unitTarget, event, flagText, amount, schoolMask = ...

    if unitTarget ~= "player" then
        return
    end

    local dataEvent = getDataEvent()

    dataEvent.recipientUnit = "player"
    dataEvent.recipientGUID = PLAYER_GUID
    dataEvent.recipientName = PLAYER_NAME
    dataEvent.eventType = "INBOUND_" .. event
    dataEvent.amount = amount
    dataEvent.damageType = schoolMask
    dataEvent.flagText = flagText

    unitCombatBatcher(dataEvent)
end

module.handlers = module.handlers or {}
module.handlers["UNIT_COMBAT"] = onUnitCombat
