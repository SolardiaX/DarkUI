local _, ns = ...

----------------------------------------------------------------------------------------
--	General Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[1] = L_CATEGORIES_GENERAL

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[1] = { -- General
    { 4, 'general', 'style', L_OPT_GENERAL_THEME, false, { 'cold', 'warm' }, nil, function(i)
        ns.Variable('general', 'style', i == 1 and 'cold' or 'warm')
    end },
    { 1, 'general', 'liteMode', L_OPT_GENERAL_THEME_LITEMODE, false },
    { 1, 'blizzard', 'style', L_OPT_GENERAL_BLIZZARD_STYLE, false },
    { 1, 'blizzard', 'custom_position', L_OPT_GENERAL_BLIZZARD_CUSTOM_POSITION, false },
    {}, --blank
    { 1, 'general', 'locale_valueformat', L_OPT_GENERAL_LOCALE_VALUEFORMAT, false },
    {},
    { 1, 'general', 'autoScale', L_OPT_GENERAL_AUTOSCALE, false, nil, function(self)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['general:uiScale']:SetShown(not self:GetChecked())
        end)
    end },
    { 3, 'general', 'uiScale', L_OPT_GENERAL_UISCALE, false, { .56, 1.18, 9 }, function(self)
        self:HookScript('OnShow', function(self)
            self:SetShown(not ns.opt_widgets['general:autoScale']:GetChecked())
        end)
    end },
}