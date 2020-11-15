local _, ns = ...

----------------------------------------------------------------------------------------
--	Actionbar Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[2] = L_CATEGORIES_ACTIONBAR

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[2] = { -- Actionbar
    { 1, 'actionbar', 'bars.enable', L_OPT_BARS_ENABLE, false, nil, function(self)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['actionbar:bars.micromenu.enable']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:bars.bags.enable']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:bars.mergebar4andbar5']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:bars.texture']:SetEnabled(self:GetChecked())
            --
            ns.opt_widgets['actionbar:bars.exp.enable']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:bars.artifact.enable']:SetEnabled(self:GetChecked())
            --
            ns.opt_widgets['actionbar:styles.buttons.enable']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:styles.cooldown.enable']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:styles.range.enable']:SetEnabled(self:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'bars.micromenu.enable', L_OPT_BARS_MICROMENU_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'bars.bags.enable', L_OPT_BARS_BAGS_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'bars.texture', L_OPT_BARS_TEXTURE_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'bars.mergebar4andbar5', L_OPT_BARS_MERGEBAR4ANDBAR5, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
    end },
    {},
    { 1, 'actionbar', 'bars.exp.enable', L_OPT_BARS_EXP_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['actionbar:bars.exp.autoswitch']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:bars.exp.disable_at_max_lvl']:SetEnabled(self:GetChecked())
        end)
        self:HookScript('OnEnable', function(self)
            ns.opt_widgets['actionbar:bars.exp.autoswitch']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:bars.exp.disable_at_max_lvl']:SetEnabled(self:GetChecked())
        end)
        self:HookScript('OnDisable', function(self)
            ns.opt_widgets['actionbar:bars.exp.autoswitch']:SetEnabled(false)
            ns.opt_widgets['actionbar:bars.exp.disable_at_max_lvl']:SetEnabled(false)
        end)
    end },
    { 1, 'actionbar', 'bars.exp.autoswitch', L_OPT_BARS_EXP_AUTOSWITCH, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked()
                                    and ns.opt_widgets['actionbar:bars.exp.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'bars.exp.disable_at_max_lvl', L_OPT_BARS_EXP_DISABLE_AT_MAX_LVL, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked()
                                    and ns.opt_widgets['actionbar:bars.exp.enable']:GetChecked())
        end)
    end },
    {},
    { 1, 'actionbar', 'bars.artifact.enable', L_OPT_BARS_ARTIFACT_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['actionbar:bars.artifact.only_at_max_level']:SetEnabled(self:GetChecked())
        end)
        self:HookScript('OnEnable', function(self)
            ns.opt_widgets['actionbar:bars.artifact.only_at_max_level']:SetEnabled(self:GetChecked())
        end)
        self:HookScript('OnDisable', function(self)
            ns.opt_widgets['actionbar:bars.artifact.only_at_max_level']:SetEnabled(false)
        end)
    end },
    { 1, 'actionbar', 'bars.artifact.only_at_max_level', L_OPT_BARS_ARTIFACT_ONLY_AT_MAX_LEVEL, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked()
                                    and ns.opt_widgets['actionbar:bars.artifact.enable']:GetChecked())
        end)
    end },
    {},
    { 1, 'actionbar', 'styles.buttons.enable', L_OPT_BARS_STYLE_BUTTONS_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['actionbar:styles.buttons.showHotkey']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:styles.buttons.showMacroName']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:styles.buttons.showStackCount']:SetEnabled(self:GetChecked())
        end)
        self:HookScript('OnEnable', function(self)
            ns.opt_widgets['actionbar:styles.buttons.showHotkey']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:styles.buttons.showMacroName']:SetEnabled(self:GetChecked())
            ns.opt_widgets['actionbar:styles.buttons.showStackCount']:SetEnabled(self:GetChecked())
        end)
        self:HookScript('OnDisable', function(self)
            ns.opt_widgets['actionbar:styles.buttons.showHotkey']:SetEnabled(false)
            ns.opt_widgets['actionbar:styles.buttons.showMacroName']:SetEnabled(false)
            ns.opt_widgets['actionbar:styles.buttons.showStackCount']:SetEnabled(false)
        end)
    end },
    { 1, 'actionbar', 'styles.buttons.showHotkey', L_OPT_BARS_STYLE_BUTTONS_SHOWHOTKEY_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked()
                                    and ns.opt_widgets['actionbar:styles.buttons.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'styles.buttons.showMacroName', L_OPT_BARS_STYLE_BUTTONS_SHOWMACRONAME_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked()
                                    and ns.opt_widgets['actionbar:styles.buttons.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'styles.buttons.showStackCount', L_OPT_BARS_STYLE_BUTTONS_SHOWSTACKCOUNT_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked()
                                    and ns.opt_widgets['actionbar:styles.buttons.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'styles.cooldown.enable', L_OPT_BARS_STYLE_COOLDOWN_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
    end },
    { 1, 'actionbar', 'styles.range.enable', L_OPT_BARS_STYLE_RANGE_ENABLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['actionbar:bars.enable']:GetChecked())
        end)
    end },
}