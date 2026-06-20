local addon = DarkUI_Options
local CHECK = addon.CHECK

addon:RegisterTab("datatext", L_CATEGORIES_DATATEXT)

addon.OptionList["datatext"] = {
    { CHECK, "datatext.enable", L_OPT_DATATEXT_ENABLE },
    { CHECK, "datatext.latency.enable", L_OPT_DATATEXT_LATENCY_ENABLE },
    { CHECK, "datatext.memory.enable", L_OPT_DATATEXT_MEMORY_ENABLE },
    { CHECK, "datatext.fps.enable", L_OPT_DATATEXT_FPS_ENABLE },
    { CHECK, "datatext.friend.enable", L_OPT_DATATEXT_FRIENDS_ENABLE },
    { CHECK, "datatext.guild.enable", L_OPT_DATATEXT_GUILD_ENABLE },
    { CHECK, "datatext.location.enable", L_OPT_DATATEXT_LOCATION_ENABLE },
    { CHECK, "datatext.coords.enable", L_OPT_DATATEXT_COORDS_ENABLE },
    { CHECK, "datatext.durability.enable", L_OPT_DATATEXT_DURABILITY_ENABLE },
    { CHECK, "datatext.bags.enable", L_OPT_DATATEXT_BAGS_ENABLE },
    { CHECK, "datatext.currencies.enable", L_OPT_DATATEXT_GOLD_ENABLE },
    { CHECK, "datatext.time.enable", L_OPT_DATATEXT_TIME_ENABLE },
}

addon.Hooks["datatext"] = function(a)
    local master = a.widgets["datatext.enable"]
    if not master then return end
    local checked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        for path, w in pairs(a.widgets) do
            if path:find("^datatext%.") and path ~= "datatext.enable" then
                w:SetEnabled(self:GetChecked())
            end
        end
    end)
    for path, w in pairs(a.widgets) do
        if path:find("^datatext%.") and path ~= "datatext.enable" then
            w:SetEnabled(checked)
        end
    end
end
