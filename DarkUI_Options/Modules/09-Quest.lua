local _, ns = ...

----------------------------------------------------------------------------------------
--	Quest Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[9] = L_CATEGORIES_QUEST

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[9] = { -- Quest
    { 1, 'quest', 'enable', L_OPT_QUEST_ENABLE, false, nil, function(self)
        self:HookScript("OnClick", function(self)
            ns.opt_widgets['quest:auto_collapse']:SetEnabled(self:GetChecked())
        end)
    end },
    { 1, 'quest', 'auto_collapse', L_OPT_QUEST_AUTO_COLLAPSE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['quest:enable']:GetChecked())
        end)
    end },
}