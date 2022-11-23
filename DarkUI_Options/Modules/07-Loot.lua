local _, ns = ...

----------------------------------------------------------------------------------------
--	Loot & Bags Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[7] = L_CATEGORIES_LOOT

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[7] = { -- Aura
    { 1, 'bags', 'enable', L_OPT_LOOT_BAGS_ENABLE, false },
    { 1, 'loot', 'enable', L_OPT_LOOT_LOOT_ENABLE, false },
    { 1, 'loot', 'faster_loot', L_OPT_LOOT_FASTER_LOOT, false },
}