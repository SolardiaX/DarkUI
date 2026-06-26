local addon = DarkUI_Options
local CHECK, SLIDER, DROP, HEADER = addon.CHECK, addon.SLIDER, addon.DROP, addon.HEADER

addon:RegisterTab("general", L_CATEGORIES_GENERAL)

addon.OptionList["general"] = {
    { HEADER, nil, L_OPT_GENERAL_THEME },
    { DROP, "general.style", L_OPT_GENERAL_THEME, {
        { L_OPT_GENERAL_THEME_COLD, "cold" },
        { L_OPT_GENERAL_THEME_WARM, "warm" },
    } },
    { CHECK, "general.liteMode", L_OPT_GENERAL_THEME_LITEMODE },
    {
        CHECK,
        "general.autoScale",
        L_OPT_GENERAL_AUTOSCALE,
        nil,
        function(widget, a)
            widget:HookScript("OnClick", function(self)
                local slider = a.widgets["general.uiScale"]
                if slider then slider:SetShown(not self:GetChecked()) end
            end)
        end,
    },
    {
        SLIDER,
        "general.uiScale",
        L_OPT_GENERAL_UISCALE,
        { 0.4, 1.5, 0.01 },
        function(widget, a)
            widget:HookScript("OnShow", function(self) self:SetShown(not a.widgets["general.autoScale"]:GetChecked()) end)
        end,
    },
    { CHECK, "general.useLocalNumberFormat", L_OPT_GENERAL_LOCALE_VALUEFORMAT },
    { HEADER, nil, "Blizzard" },
    { CHECK, "blizzard.custom_position", L_OPT_GENERAL_BLIZZARD_CUSTOM_POSITION },
    { CHECK, "blizzard.slot_durability", L_OPT_GENERAL_SLOT_DURABILITY },
    { CHECK, "blizzard.shift_mark", L_OPT_GENERAL_SHIFT_MARK },
}
