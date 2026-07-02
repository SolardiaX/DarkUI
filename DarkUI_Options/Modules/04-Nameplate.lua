local addon = DarkUI_Options
local CHECK, SLIDER, HEADER = addon.CHECK, addon.SLIDER, addon.HEADER

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
    { HEADER, nil, "Friendly" },
    { CHECK, "nameplate.friendly.nameOnly", L_OPT_NAMEPLATE_FRIENDLY_NAMEONLY },
    { CHECK, "nameplate.friendly.hideInInstance", L_OPT_NAMEPLATE_FRIENDLY_HIDE_IN_INSTANCE },
    { HEADER, nil, "Auras" },
    { CHECK, "nameplate.show_auras", L_OPT_NAMEPLATE_SHOW_AURAS },
    { CHECK, "nameplate.show_dispel", L_OPT_NAMEPLATE_SHOW_DISPEL },
    { CHECK, "nameplate.desaturate", L_OPT_NAMEPLATE_DESATURATE },
    { SLIDER, "nameplate.max_auras", L_OPT_NAMEPLATE_MAX_AURAS, { 1, 10, 1 } },
    { SLIDER, "nameplate.auras_size", L_OPT_NAMEPLATE_AURAS_SIZE, { 16, 32, 1 } },
    { CHECK, "nameplate.show_timers", L_OPT_NAMEPLATE_SHOW_TIMERS },
    { CHECK, "nameplate.show_spiral", L_OPT_NAMEPLATE_SHOW_SPIRAL },
    { HEADER, nil, "CC" },
    { CHECK, "nameplate.show_cc", L_OPT_NAMEPLATE_SHOW_CC },
    { SLIDER, "nameplate.num_cc", L_OPT_NAMEPLATE_NUM_CC, { 1, 5, 1 } },
    { SLIDER, "nameplate.cc_size", L_OPT_NAMEPLATE_CC_SIZE, { 16, 36, 1 } },
}

addon.Hooks["nameplate"] = function(a)
    local master = a.widgets["nameplate.enable"]
    if not master then return end
    local checked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        for path, w in pairs(a.widgets) do
            if path:find("^nameplate%.") and path ~= "nameplate.enable" then w:SetEnabled(self:GetChecked()) end
        end
    end)
    for path, w in pairs(a.widgets) do
        if path:find("^nameplate%.") and path ~= "nameplate.enable" then w:SetEnabled(checked) end
    end
end
