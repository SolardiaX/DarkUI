local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnCombatTextUpdate
------------------------------------------------------------------------

local module = E:Module("CombatText")

local PLAYER_GUID = UnitGUID("player") or "0x0000000000000000"
local PLAYER_NAME = UnitName("player")

C_CombatText.SetActiveUnit("player")

local dataEvent = {}

local function onCombatTextUpdate(event)
  wipe(dataEvent)
    if event ~= "SPELL_ACTIVE" then
        return
    end

    local arg1, arg2 = C_CombatText.GetCurrentEventInfo()


    dataEvent.recipientUnit = "player"
    dataEvent.recipientGUID = PLAYER_GUID
    dataEvent.recipientName = PLAYER_NAME
    dataEvent.eventType = "SELF_SPELL_ACTIVE"
    dataEvent.skillName = arg1

    module.Display.Format(dataEvent)
end

module.handlers = module.handlers or {}
module.handlers["COMBAT_TEXT_UPDATE"] = onCombatTextUpdate
