local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnUnitAura
------------------------------------------------------------------------

local module = E:Module("CombatText")

local activeAurasByInstanceID = {}

local dataEvent = {}

local function onUnitAura(...)
    local unitTarget, updateInfo = ...

    if unitTarget ~= "player" then return end

    if updateInfo.addedAuras and #updateInfo.addedAuras > 0 then
        for _, auraInfo in ipairs(updateInfo.addedAuras) do
            wipe(dataEvent)

            dataEvent.eventType = "AURA_ADDED"
            dataEvent.skillName = auraInfo.name
            dataEvent.skillID = auraInfo.spellId
            dataEvent.skillIcon = auraInfo.icon

            module.Display.Format(dataEvent)

            activeAurasByInstanceID[auraInfo.auraInstanceID] = auraInfo
        end
    end

    if updateInfo.removedAuraInstanceIDs and #updateInfo.removedAuraInstanceIDs > 0 then
        for _, removedInstanceID in ipairs(updateInfo.removedAuraInstanceIDs) do
            wipe(dataEvent)

            if activeAurasByInstanceID[removedInstanceID] then
                dataEvent.eventType = "AURA_REMOVED"
                dataEvent.skillName = activeAurasByInstanceID[removedInstanceID].name
                dataEvent.skillID = activeAurasByInstanceID[removedInstanceID].spellId
                dataEvent.skillIcon = activeAurasByInstanceID[removedInstanceID].icon

                module.Display.Format(dataEvent)

                activeAurasByInstanceID[removedInstanceID] = nil
            end
        end
    end
end

module.handlers = module.handlers or {}
module.handlers["UNIT_AURA"] = onUnitAura
