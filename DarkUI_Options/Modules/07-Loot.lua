local addon = DarkUI_Options
local CHECK, SLIDER, HEADER = addon.CHECK, addon.SLIDER, addon.HEADER

addon:RegisterTab("loot", L_CATEGORIES_LOOT)

addon.OptionList["loot"] = {
    { HEADER, nil, "Loot" },
    { CHECK, "loot.enable", L_OPT_LOOT_LOOT_ENABLE },
    { CHECK, "loot.faster_loot", L_OPT_LOOT_FASTER_LOOT },
    { HEADER, nil, "Bags" },
    { CHECK, "bags.enable", L_OPT_LOOT_BAGS_ENABLE },
    { SLIDER, "bags.itemSlotSize", L_OPT_LOOT_SLOT_SIZE or "Slot Size", { 24, 48, 1 } },
    { CHECK, "bags.itemFilter", L_OPT_LOOT_ITEM_FILTER },
    { CHECK, "bags.filterEquipment", L_OPT_LOOT_FILTER_EQUIPMENT },
    { CHECK, "bags.filterConsumable", L_OPT_LOOT_FILTER_CONSUMABLE },
    { CHECK, "bags.filterGoods", L_OPT_LOOT_FILTER_GOODS },
    { CHECK, "bags.filterQuest", L_OPT_LOOT_FILTER_QUEST },
    { CHECK, "bags.filterCollection", L_OPT_LOOT_FILTER_COLLECTION },
    { CHECK, "bags.filterJunk", L_OPT_LOOT_FILTER_JUNK },
    { CHECK, "bags.filterEquipSet", L_OPT_LOOT_FILTER_EQUIPSET },
    { CHECK, "bags.filterAOE", L_OPT_LOOT_FILTER_AOE },
    { CHECK, "bags.filterDecor", L_OPT_LOOT_FILTER_DECOR },
    { CHECK, "bags.filterLegacy", L_OPT_LOOT_FILTER_LEGACY },
}
