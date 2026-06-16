local E, C, L, DB = select(2, ...):unpack()

------------------------------------------------------------------------
-- Bag Filters
------------------------------------------------------------------------

local module = E:Module("Bags")
local cfg = C.bags

local C_Item_IsAnimaItemByID = C_Item.IsAnimaItemByID
local C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItemByID

local CURRENT_EXPANSION = LE_EXPANSION_WAR_WITHIN or 10

------------------------------------------------------------------------
-- Custom Filter Overrides
------------------------------------------------------------------------

local CustomFilterList = {
    [37863] = false,
    [187532] = false,
    [141333] = true,
    [141446] = true,
    [153646] = true,
    [153647] = true,
    [161053] = true,
    [221269] = true,
    [225896] = true,
}

local function isCustomFilter(item)
    if not cfg.itemFilter then
        return
    end
    return CustomFilterList[item.id]
end

------------------------------------------------------------------------
-- Basic Bag Membership
------------------------------------------------------------------------

local function isItemInBag(item)
    return item.bagId >= 0 and item.bagId <= 4
end

local function isItemInBagReagent(item)
    return item.bagId == 5
end

local function isItemInBank(item)
    return item.bagId > 5 and item.bagId < 12
end

local function isItemInAccountBank(item)
    return item.bagId > 11 and item.bagId < 17
end

local function isEmptySlot(item)
    return not item.link
end

------------------------------------------------------------------------
-- Category Classifiers
------------------------------------------------------------------------

local function isItemJunk(item)
    if not cfg.itemFilter or not cfg.filterJunk then
        return
    end
    return (item.quality == Enum.ItemQuality.Poor or (module.customJunkList and module.customJunkList[item.id])) and item.hasPrice
end

local function isItemEquipSet(item)
    if not cfg.itemFilter or not cfg.filterEquipSet then
        return
    end
    return item.isInSet
end

local function isAzeriteArmor(item)
    if not cfg.itemFilter or not cfg.filterAzerite then
        return
    end
    if not item.link then
        return
    end
    return C_AzeriteEmpoweredItem_IsAzeriteEmpoweredItemByID(item.link)
end

local function checkEquip(item)
    return item.link and item.quality and item.quality > Enum.ItemQuality.Common and item.ilvl
end

local function isItemEquipment(item)
    if not cfg.itemFilter or not cfg.filterEquipment then
        return
    end
    return checkEquip(item)
end

local function isItemLegacy(item)
    if not cfg.itemFilter or not cfg.filterLegacy then
        return
    end
    return checkEquip(item) and item.expacID and item.expacID < CURRENT_EXPANSION
end

local function isItemLowerLevel(item)
    if not cfg.itemFilter or not cfg.filterLower then
        return
    end
    return checkEquip(item) and item.ilvl < cfg.iLvlToShow
end

local function isItemDecor(item)
    if not cfg.itemFilter or not cfg.filterDecor then
        return
    end
    if not item.link then
        return
    end
    return C_Item.IsDecorItem and C_Item.IsDecorItem(item.link)
end

local consumableClassIDs = {
    [Enum.ItemClass.Consumable] = true,
    [Enum.ItemClass.ItemEnhancement] = true,
}

local function isItemConsumable(item)
    if not cfg.itemFilter or not cfg.filterConsumable then
        return
    end
    if isCustomFilter(item) == false then
        return
    end
    return consumableClassIDs[item.classID]
end

local function isTradeGoods(item)
    if not cfg.itemFilter or not cfg.filterGoods then
        return
    end
    if isCustomFilter(item) == false then
        return
    end
    return item.classID == Enum.ItemClass.Tradegoods
end

local function isQuestItem(item)
    if not cfg.itemFilter or not cfg.filterQuest then
        return
    end
    return item.classID == Enum.ItemClass.Questitem or item.isQuestItem
end

local collectionClassIDs = {
    [Enum.ItemMiscellaneousSubclass.Mount] = Enum.ItemClass.Miscellaneous,
    [Enum.ItemMiscellaneousSubclass.CompanionPet] = Enum.ItemClass.Miscellaneous,
}

local C_ToyBox_GetToyInfo = C_ToyBox.GetToyInfo

local function isItemCollection(item)
    if not cfg.itemFilter or not cfg.filterCollection then
        return
    end
    if item.id and C_ToyBox_GetToyInfo(item.id) then
        return true
    end
    return item.subClassID and collectionClassIDs[item.subClassID] == item.classID
end

local function isAnimaItem(item)
    if not cfg.itemFilter or not cfg.filterAnima then
        return
    end
    if not item.id then
        return
    end
    return C_Item_IsAnimaItemByID(item.id)
end

local CREST_SPELL_ID = 404861
local function isPrimordialStone(item)
    if not cfg.itemFilter or not cfg.filterStone then
        return
    end
    if not item.link then
        return
    end
    local spellName = C_Spell.GetSpellName(CREST_SPELL_ID)
    return item.subType and spellName and item.subType == spellName
end

local function isWarboundUntilEquipped(item)
    if not cfg.itemFilter or not cfg.filterAOE then
        return
    end
    return item.bindOn and item.bindOn == "accountequip"
end

local function isItemCustom(item, index)
    if not cfg.itemFilter then
        return
    end
    return module.customItems and module.customItems[item.id] == index
end

local function hasReagentBagSlots()
    return C_Container.GetContainerNumSlots(5) > 0
end

------------------------------------------------------------------------
-- GetFilters
------------------------------------------------------------------------

function module:GetFilters()
    local filters = {}

    -- Bag filters
    filters.onlyBags = function(item)
        return isItemInBag(item) and not isEmptySlot(item)
    end

    for i = 1, 5 do
        filters["bagCustom" .. i] = function(item)
            return (isItemInBag(item) or isItemInBagReagent(item)) and isItemCustom(item, i)
        end
    end

    filters.onlyBagReagent = function(item)
        return (isItemInBagReagent(item) and not isEmptySlot(item)) or (hasReagentBagSlots() and isItemInBag(item) and isTradeGoods(item))
    end

    filters.bagAzeriteItem = function(item)
        return isItemInBag(item) and isAzeriteArmor(item)
    end
    filters.bagEquipment = function(item)
        return isItemInBag(item) and isItemEquipment(item)
    end
    filters.bagEquipSet = function(item)
        return isItemInBag(item) and isItemEquipSet(item)
    end
    filters.bagAOE = function(item)
        return isItemInBag(item) and isWarboundUntilEquipped(item)
    end
    filters.bagCollection = function(item)
        return isItemInBag(item) and isItemCollection(item)
    end
    filters.bagDecor = function(item)
        return isItemInBag(item) and isItemDecor(item)
    end
    filters.bagGoods = function(item)
        return isItemInBag(item) and isTradeGoods(item)
    end
    filters.bagAnima = function(item)
        return isItemInBag(item) and isAnimaItem(item)
    end
    filters.bagStone = function(item)
        return isItemInBag(item) and isPrimordialStone(item)
    end
    filters.bagConsumable = function(item)
        return isItemInBag(item) and isItemConsumable(item)
    end
    filters.bagQuest = function(item)
        return isItemInBag(item) and isQuestItem(item)
    end
    filters.bagLegacy = function(item)
        return isItemInBag(item) and isItemLegacy(item)
    end
    filters.bagLower = function(item)
        return isItemInBag(item) and isItemLowerLevel(item)
    end
    filters.bagsJunk = function(item)
        return isItemInBag(item) and isItemJunk(item)
    end

    -- Bank filters
    filters.onlyBank = function(item)
        return isItemInBank(item) and not isEmptySlot(item)
    end

    for i = 1, 5 do
        filters["bankCustom" .. i] = function(item)
            return isItemInBank(item) and isItemCustom(item, i)
        end
    end

    filters.bankAzeriteItem = function(item)
        return isItemInBank(item) and isAzeriteArmor(item)
    end
    filters.bankEquipment = function(item)
        return isItemInBank(item) and isItemEquipment(item)
    end
    filters.bankEquipSet = function(item)
        return isItemInBank(item) and isItemEquipSet(item)
    end
    filters.bankAOE = function(item)
        return isItemInBank(item) and isWarboundUntilEquipped(item)
    end
    filters.bankCollection = function(item)
        return isItemInBank(item) and isItemCollection(item)
    end
    filters.bankDecor = function(item)
        return isItemInBank(item) and isItemDecor(item)
    end
    filters.bankGoods = function(item)
        return isItemInBank(item) and isTradeGoods(item)
    end
    filters.bankAnima = function(item)
        return isItemInBank(item) and isAnimaItem(item)
    end
    filters.bankConsumable = function(item)
        return isItemInBank(item) and isItemConsumable(item)
    end
    filters.bankQuest = function(item)
        return isItemInBank(item) and isQuestItem(item)
    end
    filters.bankLegacy = function(item)
        return isItemInBank(item) and isItemLegacy(item)
    end
    filters.bankLower = function(item)
        return isItemInBank(item) and isItemLowerLevel(item)
    end
    filters.bankJunk = function(item)
        return isItemInBank(item) and isItemJunk(item)
    end

    -- Account bank filters
    filters.accountBank = function(item)
        return isItemInAccountBank(item) and not isEmptySlot(item)
    end

    for i = 1, 5 do
        filters["accountCustom" .. i] = function(item)
            return isItemInAccountBank(item) and isItemCustom(item, i)
        end
    end

    filters.accountEquipment = function(item)
        return isItemInAccountBank(item) and isItemEquipment(item)
    end
    filters.accountAOE = function(item)
        return isItemInAccountBank(item) and isWarboundUntilEquipped(item)
    end
    filters.accountGoods = function(item)
        return isItemInAccountBank(item) and isTradeGoods(item)
    end
    filters.accountConsumable = function(item)
        return isItemInAccountBank(item) and isItemConsumable(item)
    end
    filters.accountLegacy = function(item)
        return isItemInAccountBank(item) and isItemLegacy(item)
    end

    return filters
end
