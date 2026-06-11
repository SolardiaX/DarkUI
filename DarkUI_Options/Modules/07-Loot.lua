local addon = DarkUI_Options
local CHECK, SLIDER, HEADER = addon.CHECK, addon.SLIDER, addon.HEADER

addon:RegisterTab("loot", L_CATEGORIES_LOOT)

addon.OptionList["loot"] = {
    { HEADER, nil, "Loot" },
    { CHECK, "loot.enable", L_OPT_LOOT_LOOT_ENABLE },
    { CHECK, "loot.faster_loot", L_OPT_LOOT_FASTER_LOOT },
    { HEADER, nil, "Bags" },
    { CHECK, "bags.enable", L_OPT_LOOT_BAGS_ENABLE },
    { SLIDER, "bags.itemSlotSize", L_OPT_BAGS_SLOT_SIZE or "Slot Size", { 24, 48, 1 } },
}
