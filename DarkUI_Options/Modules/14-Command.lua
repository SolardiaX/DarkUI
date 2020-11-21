local _, ns = ...

----------------------------------------------------------------------------------------
--	Command Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[14] = L_CATEGORIES_COMMAND

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[14] = { -- Command
    {0, '/hvb', ' - ', L_OPT_COMMAND_HVB, false},
    {0, '/xct', ' - ', L_OPT_COMMAND_XCT, false},
    {0, '/dmg', ' - ', L_OPT_COMMAND_DMG, false},
    {0, '/aw', ' - ', L_OPT_COMMAND_AW, false},
    {0, '/rc', ' - ', L_OPT_COMMAND_RC, false},
    {0, '/gm', ' - ', L_OPT_COMMAND_GM, false},
    {0, '/rl', ' - ', L_OPT_COMMAND_RL, false},
    {0, '/resetui', ' - ', L_OPT_COMMAND_RESETUI, false},
    {0, '/frame <name>', ' - ', L_OPT_COMMAND_FRAME, false},
    {0, '/align', ' - ', L_OPT_COMMAND_ALIGN, false},
    --{0, '/testui', ' - ', L_OPT_COMMAND_TESTUI, false},
    --{0, '/testroll', ' - ', L_OPT_COMMAND_TESTROLL, false},
}