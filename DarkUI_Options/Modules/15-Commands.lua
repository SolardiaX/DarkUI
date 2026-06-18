local addon = DarkUI_Options
local BUTTON = addon.BUTTON

addon:RegisterTab("commands", L_CATEGORIES_COMMAND)

addon.OptionList["commands"] = {
    { BUTTON, "/hvb", L_OPT_COMMAND_HVB },
    { BUTTON, "/darkui tpl", L_OPT_COMMAND_TPL },
    { BUTTON, "/align", L_OPT_COMMAND_ALIGN },
    { BUTTON, "/frame", L_OPT_COMMAND_FRAME },
    { BUTTON, "/testroll", L_OPT_COMMAND_TESTROLL },
    { BUTTON, "/rc", L_OPT_COMMAND_RC },
    { BUTTON, "/gm", L_OPT_COMMAND_GM },
    { BUTTON, "/rl", L_OPT_COMMAND_RL },
    { BUTTON, "/resetui", L_OPT_COMMAND_RESETUI },
}
