local _, ns = ...

----------------------------------------------------------------------------------------
--	Misc Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[13] = L_CATEGORIES_MISC

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[13] = { -- Misc
    { 1, 'blizzard', 'slot_durability', L_OPT_MISC_BLIZZARD_SLOT_DURABILITY, false },
    { 1, 'misc', 'slot_itemlevel', L_OPT_MISC_SLOT_ITEMLEVEL, false },
    { 1, 'blizzard', 'shift_mark', L_OPT_MISC_BLIZZARD_SHIFT_MARK, false },
    { 1, 'misc', 'raid_utility.enable', L_OPT_MISC_RAID_UTILITY, false },
    { 1, 'misc', 'socialtabs.enable', L_OPT_MISC_MISC_SOCIALTABS, false },
    { 1, 'misc', 'profession_tabs', L_OPT_MISC_PROFESSION_TABS, false },
    { 1, 'misc', 'merchant_itemlevel', L_OPT_MISC_MERCHANT_ITEMLEVEL, false },
    { 1, 'misc', 'train_all', L_OPT_MISC_TRAIN_ALL, false },
    { 1, 'misc', 'already_known', L_OPT_MISC_ALREADY_KNOWN, false },
    { 1, 'misc', 'lfg_queue_timer', L_OPT_MISC_LFG_QUEUE_TIMER, false },
    { 1, 'misc', 'alt_buy_stack', L_OPT_MISC_ALT_BUY_STACK, false },
    {},
    { 1, 'automation', 'accept_invite', L_OPT_MISC_AUTOMATION_ACCEPT_INVITE, false },
    { 1, 'automation', 'auto_role', L_OPT_MISC_AUTOMATION_AUTO_ROLE, false },
    { 1, 'automation', 'auto_release', L_OPT_MISC_AUTOMATION_AUTO_RELEASE, false },
    { 1, 'automation', 'decline_duel', L_OPT_MISC_AUTOMATION_DECLINE_DUEL, false },
    { 1, 'automation', 'auto_repair', L_OPT_MISC_AUTOMATION_AUTO_REPAIR, false },
    { 1, 'automation', 'auto_sell', L_OPT_MISC_AUTOMATION_AUTO_SELL, false },
    { 1, 'automation', 'auto_confirm_de', L_OPT_MISC_AUTOMATION_AUTO_CONFIRM_DE, false },
    { 1, 'automation', 'auto_greed', L_OPT_MISC_AUTOMATION_AUTO_GREED, false },
    { 1, 'automation', 'auto_quest', L_OPT_MISC_AUTOMATION_AUTO_QUEST, false },
    { 1, 'automation', 'tab_binder', L_OPT_MISC_AUTOMATION_TAB_BINDER, false },
}