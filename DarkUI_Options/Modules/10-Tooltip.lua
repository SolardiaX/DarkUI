local _, ns = ...

----------------------------------------------------------------------------------------
--	Tooltip Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[10] = L_CATEGORIES_TOOLTIP

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[10] = { -- Tooltip
    { 1, 'tooltip', 'enable', L_OPT_TOOLTIP_ENABLE, false, nil, function(self)
        self:HookScript("OnClick", function(self)
            for name, opt in pairs(ns.opt_widgets) do
                if string.find(name, "tooltip:") and name ~= 'tooltip:enable' then
                    opt:SetEnabled(self:GetChecked())
                end
            end
        end)
    end },
    { 1, 'tooltip', 'cursor', L_OPT_TOOLTIP_CURSOR, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'shift_modifer', L_OPT_TOOLTIP_SHIFT_MODIFER, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'hide_combat', L_OPT_TOOLTIP_HIDE_COMBAT, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'hideforactionbar', L_OPT_TOOLTIP_HIDEFORACTIONBAR, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'health_value', L_OPT_TOOLTIP_HEALTH_VALUE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'target', L_OPT_TOOLTIP_TARGET, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'title', L_OPT_TOOLTIP_TITLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'realm', L_OPT_TOOLTIP_REALM, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'rank', L_OPT_TOOLTIP_RANK, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'raid_icon', L_OPT_TOOLTIP_RAID_ICON, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'who_targetting', L_OPT_TOOLTIP_WHO_TARGETTING, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'achievements', L_OPT_TOOLTIP_ACHIEVEMENTS, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'item_transmogrify', L_OPT_TOOLTIP_ITEM_TRANSMOGRIFY, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'instance_lock', L_OPT_TOOLTIP_INSTANCE_LOCK, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'item_count', L_OPT_TOOLTIP_ITEM_COUNT, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'item_icon', L_OPT_TOOLTIP_ITEM_ICON, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'average_lvl', L_OPT_TOOLTIP_AVERAGE_LVL, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'spell_id', L_OPT_TOOLTIP_SPELL_ID, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'talents', L_OPT_TOOLTIP_TALENTS, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'mount', L_OPT_TOOLTIP_MOUNT, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
    { 1, 'tooltip', 'unit_role', L_OPT_TOOLTIP_UNIT_ROLE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['tooltip:enable']:GetChecked())
        end)
    end },
}