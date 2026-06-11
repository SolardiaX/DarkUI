local addon = DarkUI_Options
local CHECK, HEADER = addon.CHECK, addon.HEADER

addon:RegisterTab("nameplate", L_CATEGORIES_NAMEPLATE)

addon.OptionList["nameplate"] = {
    { CHECK, "nameplate.enable", L_OPT_NAMEPLATE_ENABLE },
    { CHECK, "nameplate.clamp", L_OPT_NAMEPLATE_CLAMP },
    { CHECK, "nameplate.combat", L_OPT_NAMEPLATE_COMBAT },
    { CHECK, "nameplate.health_value", L_OPT_NAMEPLATE_HEALTH_VALUE },
    { CHECK, "nameplate.show_castbar_name", L_OPT_NAMEPLATE_SHOW_CASTBAR_NAME },
    { CHECK, "nameplate.enhance_threat", L_OPT_NAMEPLATE_ENHANCE_THREAT },
    { CHECK, "nameplate.class_icons", L_OPT_NAMEPLATE_CLASS_ICONS },
    { CHECK, "nameplate.visibility.enemy.totems", L_OPT_NAMEPLATE_TOTEM_ICONS },
    { CHECK, "nameplate.name_abbrev", L_OPT_NAMEPLATE_NAME_ABBREV },
    { CHECK, "nameplate.arrow", L_OPT_NAMEPLATE_ARROW },
    { CHECK, "nameplate.quest", L_OPT_NAMEPLATE_QUEST },
    { HEADER, nil, "Auras" },
    { CHECK, "nameplate.track_debuffs", L_OPT_NAMEPLATE_TRACK_DEBUFFS },
    { CHECK, "nameplate.track_buffs", L_OPT_NAMEPLATE_TRACK_BUFFS },
    { CHECK, "nameplate.player_aura_only", L_OPT_NAMEPLATE_PLAYER_AURA_ONLY },
    { CHECK, "nameplate.show_stealable_buffs", L_OPT_NAMEPLATE_SHOW_STEALABLE_BUFFS },
    { CHECK, "nameplate.show_timers", L_OPT_NAMEPLATE_SHOW_TIMERS },
    { CHECK, "nameplate.show_spiral", L_OPT_NAMEPLATE_SHOW_SPIRAL },
}

addon.Hooks["nameplate"] = function(a)
    local master = a.widgets["nameplate.enable"]
    if not master then return end
    local checked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        for path, w in pairs(a.widgets) do
            if path:find("^nameplate%.") and path ~= "nameplate.enable" then
                w:SetEnabled(self:GetChecked())
            end
        end
    end)
    for path, w in pairs(a.widgets) do
        if path:find("^nameplate%.") and path ~= "nameplate.enable" then
            w:SetEnabled(checked)
        end
    end
end
