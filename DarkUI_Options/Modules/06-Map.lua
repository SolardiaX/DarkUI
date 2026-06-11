local addon = DarkUI_Options
local CHECK, HEADER = addon.CHECK, addon.HEADER

addon:RegisterTab("map", L_CATEGORIES_MAP)

addon.OptionList["map"] = {
    { HEADER, nil, "Minimap" },
    { CHECK, "map.minimap.enable", L_OPT_MAP_MINIMAP_ENABLE },
    { CHECK, "map.minimap.autoZoom", L_OPT_MAP_MINIMAP_AUTOZOOM },
    { HEADER, nil, "World Map" },
    { CHECK, "map.worldmap.enable", L_OPT_MAP_WORLDMAP_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function(self)
            local w = a.widgets["map.worldmap.revealMap"]
            if w then w:SetEnabled(self:GetChecked()) end
        end)
    end},
    { CHECK, "map.worldmap.revealMap", L_OPT_MAP_WORLDMAP_REVEALMAP },
}

addon.Hooks["map"] = function(a)
    local master = a.widgets["map.worldmap.enable"]
    local child = a.widgets["map.worldmap.revealMap"]
    if master and child then
        child:SetEnabled(master:GetChecked())
    end
end
