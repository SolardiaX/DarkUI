local addon = DarkUI_Options
local CHECK, SLIDER, DROP, HEADER = addon.CHECK, addon.SLIDER, addon.DROP, addon.HEADER

addon:RegisterTab("aura", L_CATEGORIES_AURA)

addon.OptionList["aura"] = {
    { CHECK, "aura.enable", L_OPT_AURA_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function(self)
            local checked = self:GetChecked()
            for path, w in pairs(a.widgets) do
                if path:find("^aura%.") and path ~= "aura.enable" then
                    w:SetEnabled(checked)
                end
            end
        end)
    end},
    { CHECK, "aura.show_caster", L_OPT_AURA_SHOW_CASTER },
    { CHECK, "aura.show_timers", L_OPT_AURA_SHOW_TIMERS },
    { CHECK, "aura.enable_flash", L_OPT_AURA_ENABLE_FLASH },
    { CHECK, "aura.enable_animation", L_OPT_AURA_ENABLE_ANIMATION },
    { SLIDER, "aura.buff_size", L_OPT_AURA_BUFF_SIZE or "Buff Size", { 20, 48, 1 } },
    { SLIDER, "aura.debuff_size", L_OPT_AURA_DEBUFF_SIZE or "Debuff Size", { 20, 48, 1 } },
    { SLIDER, "aura.row_num", L_OPT_AURA_ROW_NUM or "Icons Per Row", { 8, 24, 1 } },
}

addon.Hooks["aura"] = function(a)
    local master = a.widgets["aura.enable"]
    if not master then return end
    local checked = master:GetChecked()
    for path, w in pairs(a.widgets) do
        if path:find("^aura%.") and path ~= "aura.enable" then
            w:SetEnabled(checked)
        end
    end
end
