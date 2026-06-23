local E, C, L = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bag Filters
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local NUM_BAG_SLOTS = 5
local BANK_START = NUM_BAG_SLOTS + 1
local BANK_END = 11
local ACCOUNT_BANK_START = 12
local ACCOUNT_BANK_END = 16

local cbNivaya = cargBags:NewImplementation("Nivaya")
if cfg and cfg.enable then cbNivaya:RegisterBlizzard() end
cbNivaya:HookScript("OnShow", function() PlaySound(SOUNDKIT.IG_BACKPACK_OPEN) end)
cbNivaya:HookScript("OnHide", function() PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE) end)

function cbNivaya:UpdateBags()
    for i = 0, ACCOUNT_BANK_END do
        cbNivaya:UpdateBag(i)
    end
end

------------------------------------------------------------------------
-- State
------------------------------------------------------------------------

module.filters = {}
module.itemClass = {}
module.filterEnabled = {
    Equipment = true,
    Consumables = true,
    TradeGoods = true,
    Quest = true,
    Collection = true,
    Junk = true,
    ItemSets = false,
    AOE = true,
    Decor = true,
    Legacy = false,
}
module.existsBankBag = {
    Equipment = true,
    Consumables = true,
    TradeGoods = true,
    Quest = true,
    Collection = true,
    Junk = true,
}

local filters = module.filters
local itemClass = module.itemClass
local filterEnabled = module.filterEnabled
local existsBankBag = module.existsBankBag

------------------------------------------------------------------------
-- Basic Filters
------------------------------------------------------------------------

filters.fBags = function(item) return item.bagId >= 0 and item.bagId <= NUM_BAG_SLOTS end

filters.fBank = function(item) return item.bagId >= BANK_START and item.bagId <= BANK_END end

filters.fBankAccount = function(item) return item.bagId >= ACCOUNT_BANK_START and item.bagId <= ACCOUNT_BANK_END end

filters.fBankReagent = function(item) return item.bagId == 5 end

filters.fBankFilter = function() return module.opts.FilterBank end

filters.fHideEmpty = function(item)
    if module.opts.CompressEmpty then return item.link ~= nil end
    return true
end

------------------------------------------------------------------------
-- Item Classification (NDui-style)
------------------------------------------------------------------------

local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID

local CURRENT_EXPANSION = LE_EXPANSION_WAR_WITHIN or 10

local consumableClassIDs = {
    [Enum.ItemClass.Consumable] = true,
    [Enum.ItemClass.ItemEnhancement] = true,
}

local collectionClassIDs = {
    [Enum.ItemMiscellaneousSubclass.Mount] = Enum.ItemClass.Miscellaneous,
    [Enum.ItemMiscellaneousSubclass.CompanionPet] = Enum.ItemClass.Miscellaneous,
}

filters.fItemClass = function(item, container)
    if not item.id or not item.name then return false end
    if not itemClass[item.id] then cbNivaya:ClassifyItem(item) end

    local t = itemClass[item.id]
    local isBankBag = item.bagId >= BANK_START and item.bagId <= BANK_END
    local isBankAccountBag = item.bagId >= ACCOUNT_BANK_START and item.bagId <= ACCOUNT_BANK_END
    local bag

    if isBankBag then
        bag = (existsBankBag[t] and module.opts.FilterBank and filterEnabled[t]) and "Bank" .. t or "Bank"
    elseif isBankAccountBag then
        bag = "BankAccount"
    else
        bag = (t ~= "NoClass" and filterEnabled[t]) and t or "Bag"
    end

    return bag == container
end

function cbNivaya:ClassifyItem(item)
    local tC = module.catInfo and module.catInfo[item.id]
    if tC then
        itemClass[item.id] = tC
        return true
    end

    -- Junk (quality 0 with sell price)
    if item.quality == 0 and item.hasPrice then
        itemClass[item.id] = "Junk"
        return true
    end

    -- Equipment sets
    if item.isInSet and cfg.filterEquipSet then
        itemClass[item.id] = "ItemSets"
        return true
    end

    -- Warbound until equipped (AOE)
    if cfg.filterAOE and item.bindOn and item.bindOn == "accountequip" then
        itemClass[item.id] = "AOE"
        return true
    end

    -- Decor items
    if cfg.filterDecor and item.link and C_Item.IsDecorItem and C_Item.IsDecorItem(item.link) then
        itemClass[item.id] = "Decor"
        return true
    end

    -- Legacy expansion equipment
    if
        cfg.filterLegacy
        and item.link
        and item.quality
        and item.quality > Enum.ItemQuality.Common
        and item.ilvl
        and item.expacID
        and item.expacID < CURRENT_EXPANSION
    then
        itemClass[item.id] = "Legacy"
        return true
    end

    -- Collection (toys, mounts, pets)
    if cfg.filterCollection then
        if item.id and C_ToyBox_GetToyInfo(item.id) then
            itemClass[item.id] = "Collection"
            return true
        end
        if item.subClassID and collectionClassIDs[item.subClassID] == item.classID then
            itemClass[item.id] = "Collection"
            return true
        end
    end

    -- Equipment (armor/weapon with ilvl)
    if item.classID == Enum.ItemClass.Armor or item.classID == Enum.ItemClass.Weapon then
        if item.quality and item.quality > Enum.ItemQuality.Common and item.ilvl then
            itemClass[item.id] = "Equipment"
            return true
        end
    end

    -- Consumables
    if consumableClassIDs[item.classID] then
        itemClass[item.id] = "Consumables"
        return true
    end

    -- Trade goods
    if item.classID == Enum.ItemClass.Tradegoods then
        itemClass[item.id] = "TradeGoods"
        return true
    end

    -- Quest items
    if item.classID == Enum.ItemClass.Questitem or item.isQuestItem then
        itemClass[item.id] = "Quest"
        return true
    end

    -- Battle pets
    if item.classID == Enum.ItemClass.Miscellaneous and item.subClassID == Enum.ItemMiscellaneousSubclass.CompanionPet then
        itemClass[item.id] = "Collection"
        return true
    end

    itemClass[item.id] = "NoClass"
end

------------------------------------------------------------------------
-- New Items Filter
------------------------------------------------------------------------

filters.fNewItems = function(item)
    if not module.opts.NewItems then return false end
    if not (item.bagId >= 0 and item.bagId <= NUM_BAG_SLOTS) then return false end
    if not item.link then return false end
    local knownItems = module.knownItems
    if not knownItems then return false end
    if not knownItems[item.id] then return true end
    local t = GetItemCount(item.id)
    return t > knownItems[item.id]
end

------------------------------------------------------------------------
-- Item Set Filter
------------------------------------------------------------------------

filters.fItemSets = function(item)
    if not filterEnabled["ItemSets"] then return false end
    if not item.link then return false end
    return item.isInSet or false
end
