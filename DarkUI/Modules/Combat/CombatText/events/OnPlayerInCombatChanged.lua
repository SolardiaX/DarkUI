local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnCombatState
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combattext

local dataEvent = {}

local function onPlayerInCombatChanged(inCombat)
    if not inCombat and cfg.clear_on_combat_exit then
        module.Display.ClearCombatQueues()
    end

    wipe(dataEvent)

    dataEvent.eventType = inCombat and "ENTER_COMBAT" or "EXIT_COMBAT"

    module.Display.Format(dataEvent)
end

module.handlers = module.handlers or {}
module.handlers["PLAYER_IN_COMBAT_CHANGED"] = onPlayerInCombatChanged
