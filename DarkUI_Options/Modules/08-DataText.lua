local _, ns = ...

----------------------------------------------------------------------------------------
--	DataText Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[8] = L_CATEGORIES_DATATEXT

ns.Hooks[8] = function()
    ns.opt_widgets['stats:enable']:HookScript("OnClick", function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "stats:") and name ~= 'stats:enable' then
                opt:SetEnabled(self:GetChecked())
            end
        end
    end)

    for name, opt in pairs(ns.opt_widgets) do
        if string.find(name, "stats:") and name ~= 'stats:enable' then
            opt:HookScript("OnShow", function(self)
                self:SetEnabled(ns.opt_widgets['stats:enable']:GetChecked())
            end)
        end
    end
end

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[8] = { -- DataText
    { 1, 'stats', 'enable', L_OPT_DATATEXT_ENABLE, false },
    {},
    { 1, 'stats', 'latency', L_OPT_DATATEXT_LATENCY_ENABLE, false },
    { 1, 'stats', 'memory', L_OPT_DATATEXT_MEMORY_ENABLE, false },
    { 1, 'stats', 'fps', L_OPT_DATATEXT_FPS_ENABLE, false },
    { 1, 'stats', 'friend', L_OPT_DATATEXT_FRIENDS_ENABLE, false },
    { 1, 'stats', 'guild', L_OPT_DATATEXT_GUILD_ENABLE, false },
    {},
    { 1, 'stats', 'location', L_OPT_DATATEXT_LOCATION_ENABLE, false },
    { 1, 'stats', 'coords', L_OPT_DATATEXT_COORDS_ENABLE, false },
    {},
    { 1, 'stats', 'durability', L_OPT_DATATEXT_DURABILITY_ENABLE, false },
    { 1, 'stats', 'bags', L_OPT_DATATEXT_BAGS_ENABLE, false },
    { 1, 'stats', 'currencies', L_OPT_DATATEXT_GOLD_ENABLE, false },
}