local addon = DarkUI_Options
local CHECK = addon.CHECK

addon:RegisterTab("misc", L_CATEGORIES_MISC)

addon.OptionList["misc"] = {
    { CHECK, "misc.raid_utility.enable", L_OPT_MISC_RAID_UTILITY },
    { CHECK, "misc.focuser", L_OPT_MISC_FOCUSER or "Shift+Click Set Focus" },
    { CHECK, "misc.faster_movie_skip", L_OPT_MISC_FASTER_MOVIE_SKIP or "Faster Movie/Cinematic Skip" },
    { CHECK, "misc.train_all", L_OPT_MISC_TRAIN_ALL },
    { CHECK, "misc.already_known", L_OPT_MISC_ALREADY_KNOWN },
    { CHECK, "misc.profession_tabs", L_OPT_MISC_PROFESSION_TABS },
    { CHECK, "misc.lfg_queue_timer", L_OPT_MISC_LFG_QUEUE_TIMER },
    { CHECK, "misc.pvp_queue_timer", L_OPT_MISC_PVP_QUEUE_TIMER or "PVP Queue Timer" },
    { CHECK, "misc.alt_buy_stack", L_OPT_MISC_ALT_BUY_STACK },
    { CHECK, "misc.merchant_itemlevel", L_OPT_MISC_MERCHANT_ITEMLEVEL },
    { CHECK, "misc.slot_itemlevel", L_OPT_MISC_SLOT_ITEMLEVEL },
}
