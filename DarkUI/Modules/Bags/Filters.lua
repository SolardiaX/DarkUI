local E, C, L = select(2, ...):unpack()
local cargBags = select(2, ...).cargBags

------------------------------------------------------------------------
-- Bag Filters
------------------------------------------------------------------------

local module = E:Module("Bags")

local NUM_BAG_SLOTS = 5
local BANK_START = NUM_BAG_SLOTS + 1
local BANK_END = 11
local ACCOUNT_BANK_START = 12
local ACCOUNT_BANK_END = 16

local cbNivaya = cargBags:NewImplementation("Nivaya")
if C.bags and C.bags.enable then
    cbNivaya:RegisterBlizzard()
end
cbNivaya:HookScript("OnShow", function()
    PlaySound(SOUNDKIT.IG_BACKPACK_OPEN)
end)
cbNivaya:HookScript("OnHide", function()
    PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
end)

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
    Armor = true,
    Gem = true,
    Quest = true,
    TradeGoods = true,
    Consumables = true,
    Junk = true,
    Stuff = true,
    ItemSets = true,
    BattlePet = true,
}
module.existsBankBag = {
    Armor = true,
    Gem = true,
    Quest = true,
    TradeGoods = true,
    Consumables = true,
    BattlePet = true,
    Junk = true,
}

local filters = module.filters
local itemClass = module.itemClass
local filterEnabled = module.filterEnabled
local existsBankBag = module.existsBankBag

------------------------------------------------------------------------
-- Basic Filters
------------------------------------------------------------------------

filters.fBags = function(item)
    return item.bagId >= 0 and item.bagId <= NUM_BAG_SLOTS
end

filters.fBank = function(item)
    return item.bagId >= BANK_START and item.bagId <= BANK_END
end

filters.fBankAccount = function(item)
    return item.bagId >= ACCOUNT_BANK_START and item.bagId <= ACCOUNT_BANK_END
end

filters.fBankReagent = function(item)
    return item.bagId == 5
end

filters.fBankFilter = function()
    return module.opts.FilterBank
end

filters.fHideEmpty = function(item)
    if module.opts.CompressEmpty then
        return item.link ~= nil
    end
    return true
end

------------------------------------------------------------------------
-- Item Classification
------------------------------------------------------------------------

filters.fItemClass = function(item, container)
    if not item.id or not item.name then
        return false
    end
    if not itemClass[item.id] then
        cbNivaya:ClassifyItem(item)
    end

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

    if item.quality == 0 then
        itemClass[item.id] = "Junk"
        return true
    end

    if item.type then
        if item.type == L.BAG_ARMOR or item.type == L.BAG_WEAPON then
            itemClass[item.id] = "Armor"
            return true
        elseif item.type == L.BAG_GEM then
            itemClass[item.id] = "Gem"
            return true
        elseif item.type == L.BAG_QUEST then
            itemClass[item.id] = "Quest"
            return true
        elseif item.type == L.BAG_TRADES then
            itemClass[item.id] = "TradeGoods"
            return true
        elseif item.type == L.BAG_CONSUMABLES then
            itemClass[item.id] = "Consumables"
            return true
        elseif item.type == L.BAG_BATTLEPET then
            itemClass[item.id] = "BattlePet"
            return true
        end
    end

    itemClass[item.id] = "NoClass"
end

------------------------------------------------------------------------
-- New Items Filter
------------------------------------------------------------------------

filters.fNewItems = function(item)
    if not module.opts.NewItems then
        return false
    end
    if not (item.bagId >= 0 and item.bagId <= NUM_BAG_SLOTS) then
        return false
    end
    if not item.link then
        return false
    end
    local knownItems = module.knownItems
    if not knownItems then
        return false
    end
    if not knownItems[item.id] then
        return true
    end
    local t = GetItemCount(item.id)
    return t > knownItems[item.id]
end

------------------------------------------------------------------------
-- Item Set Filter
------------------------------------------------------------------------

filters.fItemSets = function(item)
    if not filterEnabled["ItemSets"] then
        return false
    end
    if not item.link then
        return false
    end
    return item.isInSet or false
end
