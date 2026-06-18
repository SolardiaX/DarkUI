local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- OnBagUpdateDelayed
------------------------------------------------------------------------

local module = E:Module("CombatText")
local cfg = C.combattext

local NUM_BAG_SLOTS = 6

local inventoryCache = {}
local dataEvent = {}

local function buildInventoryCache(cacheToReuse)
    local newInventoryCache = cacheToReuse or {}
    for bag = 0, NUM_BAG_SLOTS do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local itemID = C_Container.GetContainerItemID(bag, slot)

            if itemID then
                local itemName, _, itemQuality = C_Item.GetItemInfo(itemID)

                if not newInventoryCache[itemID] then
                    newInventoryCache[itemID] = {
                        count = C_Item.GetItemCount(itemID),
                        name = itemName,
                        quality = itemQuality,
                    }
                end
            end
        end
    end

    return newInventoryCache
end

local function onBagUpdateDelayed()
    if not cfg.loot then
        return
    end

    local newInventoryCache = buildInventoryCache()

    for itemID, itemInfo in pairs(newInventoryCache) do
        wipe(dataEvent)
        local shouldFire = false

        if inventoryCache[itemID] then
            if itemInfo.count > inventoryCache[itemID].count then
                dataEvent.amount = itemInfo.count - inventoryCache[itemID].count
                shouldFire = true
            end
        else
            dataEvent.amount = itemInfo.count
            shouldFire = true
        end

        if shouldFire then
            if itemInfo.quality then
                dataEvent.eventType = "SELF_ITEM_LOOTED_" .. itemInfo.quality
            else
                dataEvent.eventType = "SELF_ITEM_LOOTED"
            end

            dataEvent.itemID = itemID
            dataEvent.itemName = itemInfo.name
            dataEvent.itemQuality = itemInfo.quality
            dataEvent.totalAmount = itemInfo.count

            module.Display.Format(dataEvent)
        end
    end

    inventoryCache = newInventoryCache
end

local function onPlayerEnteringWorld()
    inventoryCache = buildInventoryCache()
end

module.handlers = module.handlers or {}
module.handlers["PLAYER_ENTERING_WORLD"] = onPlayerEnteringWorld
module.handlers["BAG_UPDATE_DELAYED"] = onBagUpdateDelayed
