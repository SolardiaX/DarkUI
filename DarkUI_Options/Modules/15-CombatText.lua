local addon = DarkUI_Options
local CHECK, DROP, HEADER = addon.CHECK, addon.DROP, addon.HEADER

addon:RegisterTab("combattext", L_CATEGORIES_COMBATTEXT or "Combat Text")

addon.OptionList["combattext"] = {
    { CHECK, "combattext.enable", L_OPT_COMBATTEXT_ENABLE },
    { HEADER, "", L_OPT_COMBATTEXT_HEADER_DISPLAY or "Display" },
    { CHECK, "combattext.incoming", L_OPT_COMBATTEXT_INCOMING },
    { CHECK, "combattext.incoming_heal", L_OPT_COMBATTEXT_INCOMING_HEAL },
    { CHECK, "combattext.outgoing", L_OPT_COMBATTEXT_OUTGOING },
    { CHECK, "combattext.notification", L_OPT_COMBATTEXT_NOTIFICATION },
    { CHECK, "combattext.loot", L_OPT_COMBATTEXT_LOOT },
    { HEADER, "", L_OPT_COMBATTEXT_HEADER_FORMAT or "Format" },
    { CHECK, "combattext.icons", L_OPT_COMBATTEXT_ICONS },
    { CHECK, "combattext.group_unlike_spells", L_OPT_COMBATTEXT_GROUP_UNLIKE_SPELLS },
    { DROP, "combattext.group_appearance", L_OPT_COMBATTEXT_GROUP_APPEARANCE, {
        { L_OPT_COMBATTEXT_GROUP_ALL_ICONS or "All Icons", "ALL_ICONS" },
        { L_OPT_COMBATTEXT_GROUP_FIRST_PLUS_N or "First +N", "FIRST_ICON_PLUS_N" },
    }},
    { HEADER, "", L_OPT_COMBATTEXT_HEADER_ADVANCED or "Advanced" },
    { CHECK, "combattext.hide_blizzard", L_OPT_COMBATTEXT_HIDE_BLIZZARD },
    { CHECK, "combattext.clear_on_combat_exit", L_OPT_COMBATTEXT_CLEAR_ON_EXIT },
}

addon.Hooks["combattext"] = function(a)
    local master = a.widgets["combattext.enable"]
    if not master then return end
    local checked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        for path, w in pairs(a.widgets) do
            if path:find("^combattext%.") and path ~= "combattext.enable" then
                w:SetEnabled(self:GetChecked())
            end
        end
    end)
    for path, w in pairs(a.widgets) do
        if path:find("^combattext%.") and path ~= "combattext.enable" then
            w:SetEnabled(checked)
        end
    end
end
