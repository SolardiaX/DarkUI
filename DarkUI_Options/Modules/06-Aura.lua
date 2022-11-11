local _, ns = ...

----------------------------------------------------------------------------------------
--	Aura Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[6] = L_CATEGORIES_AURA

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[6] = { -- Aura
    { 1, 'aura', 'enable', L_OPT_AURA_ENABLE, false, nil, function(self)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['aura:show_caster']:SetEnabled(self:GetChecked())
        end)
    end },
    { 1, 'aura', 'show_caster', L_OPT_AURA_SHOW_CASTER, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['aura:enable']:GetChecked())
        end)
    end },
    { 1, 'aura', 'enable_flash', L_OPT_AURA_ENABLE_FLASH, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['aura:enable']:GetChecked())
        end)
    end },
    { 1, 'aura', 'enable_animation', L_OPT_AURA_ENABLE_ANIMATION, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['aura:enable']:GetChecked())
        end)
    end },
    {}, --blank
    { 1, 'aura', 'auraWatch.enable', L_OPT_AURA_AURAWATCH_ENABLE, false, nil, function(self)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['aura:auraWatch.clickThrough']:SetEnabled(self:GetChecked())
            ns.opt_widgets['aura:auraWatch.quakeRing']:SetEnabled(self:GetChecked())
        end)
    end },
    { 1, 'aura', 'auraWatch.clickThrough', L_OPT_AURA_AURAWATCH_CLICKTHROUGH, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['aura:auraWatch.enable']:GetChecked())
        end)
    end },
    { 1, 'aura', 'auraWatch.quakeRing', L_OPT_AURA_AURAWATCH_QUAKERING, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['aura:auraWatch.enable']:GetChecked())
        end)
    end },
    {},
    { 1, 'announcement', 'interrupt.enable', L_OPT_ANNOUNCEMENT_INTERRUPT_ENABLE, false, nil, function(self)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['announcement:interrupt.channel']:SetShown(self:GetChecked())
        end)
    end },
    { 4, 'announcement', 'interrupt.channel', L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL, false, {
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_1,
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_2,
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_3,
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_4,
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_5,
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_6
    }, function(self)
        self:HookScript('OnShow', function(self)
            self:SetShown(ns.opt_widgets['announcement:interrupt.enable']:GetChecked())
        end)
    end },
}