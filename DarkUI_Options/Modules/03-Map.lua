local _, ns = ...

----------------------------------------------------------------------------------------
--	Map Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[3] = L_CATEGORIES_MAP

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[3] = { -- Map
    { 1, 'map', 'minimap.enable', L_OPT_MAP_MINIMAP_ENABLE, false },
    { 1, 'map', 'minimap.autoZoom', L_OPT_MAP_MINIMAP_AUTOZOOM, false },
    { 1, 'map', 'worldmap.enable', L_OPT_MAP_WORLDMAP_ENABLE, false, nil, function(self)
        self:HookScript('OnClick', function(self)
            ns.opt_widgets['map:worldmap.removeFog']:SetEnabled(self:GetChecked())
            ns.opt_widgets['map:worldmap.rewardIcon']:SetEnabled(self:GetChecked())
        end)
    end },
    { 1, 'map', 'worldmap.removeFog', L_OPT_MAP_WORLDMAP_REMOVEFOG, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['map:worldmap.enable']:GetChecked())
        end)
    end },
    { 1, 'map', 'worldmap.rewardIcon', L_OPT_MAP_WORLDMAP_REWARDICON, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['map:worldmap.enable']:GetChecked())
        end)
    end },
}