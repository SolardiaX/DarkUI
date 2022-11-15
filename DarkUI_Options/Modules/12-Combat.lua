local _, ns = ...

----------------------------------------------------------------------------------------
--	Combat Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[12] = L_CATEGORIES_COMBAT

ns.Hooks[12] = function()
    ns.opt_widgets['combat:combattext.enable']:HookScript("OnClick", function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "combat:combattext.") and name ~= 'combat:combattext.enable' then
                opt:SetEnabled(self:GetChecked())
            end
        end
    end)

    for name, opt in pairs(ns.opt_widgets) do
        if string.find(name, "combat:combattext.") and name ~= 'combat:combattext.enable' then
            opt:HookScript("OnShow", function(self)
                self:SetEnabled(ns.opt_widgets['combat:combattext.enable']:GetChecked())
            end)
        end
    end

    ns.opt_widgets['combat:damagemeter.enable']:HookScript("OnClick", function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "combat:damagemeter.") and name ~= 'combat:damagemeter.enable' then
                opt:SetEnabled(self:GetChecked())
            end
        end
    end)

    for name, opt in pairs(ns.opt_widgets) do
        if string.find(name, "combat:damagemeter.") and name ~= 'combat:damagemeter.enable' then
            opt:HookScript("OnShow", function(self)
                self:SetEnabled(ns.opt_widgets['combat:damagemeter.enable']:GetChecked())
            end)
        end
    end
end

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[12] = { -- Chat
    { 1, 'combat', 'combattext.enable', L_OPT_COMBAT_COMBATTEXT_ENABLE, false },
    { 1, 'combat', 'combattext.blizz_head_numbers', L_OPT_COMBAT_COMBATTEXT_BLIZZ_HEAD_NUMBERS, false },
    { 1, 'combat', 'combattext.damage_style', L_OPT_COMBAT_COMBATTEXT_DAMAGE_STYLE, false },
    { 1, 'combat', 'combattext.damage', L_OPT_COMBAT_COMBATTEXT_DAMAGE, false },
    { 1, 'combat', 'combattext.healing', L_OPT_COMBAT_COMBATTEXT_HEALING, false },
    { 1, 'combat', 'combattext.show_hots', L_OPT_COMBAT_COMBATTEXT_SHOW_HOTS, false },
    { 1, 'combat', 'combattext.show_overhealing', L_OPT_COMBAT_COMBATTEXT_SHOW_OVERHEALING, false },
    { 1, 'combat', 'combattext.incoming', L_OPT_COMBAT_COMBATTEXT_INCOMING, false },
    { 1, 'combat', 'combattext.pet_damage', L_OPT_COMBAT_COMBATTEXT_PET_DAMAGE, false },
    { 1, 'combat', 'combattext.dot_damage', L_OPT_COMBAT_COMBATTEXT_DOT_DAMAGE, false },
    { 1, 'combat', 'combattext.damage_color', L_OPT_COMBAT_COMBATTEXT_DAMAGE_COLOR, false },
    { 1, 'combat', 'combattext.icons', L_OPT_COMBAT_COMBATTEXT_ICONS, false },
    { 1, 'combat', 'combattext.scrollable', L_OPT_COMBAT_COMBATTEXT_SCROLLABLE, false },
    { 1, 'combat', 'combattext.dk_runes', L_OPT_COMBAT_COMBATTEXT_DK_RUNES, false },
    { 1, 'combat', 'combattext.killingblow', L_OPT_COMBAT_COMBATTEXT_KILLINGBLOW, false },
    { 1, 'combat', 'combattext.merge_aoe_spam', L_OPT_COMBAT_COMBATTEXT_MERGE_AOE_SPAM, false },
    { 1, 'combat', 'combattext.merge_melee', L_OPT_COMBAT_COMBATTEXT_MERGE_MELEE, false },
    { 1, 'combat', 'combattext.dispel', L_OPT_COMBAT_COMBATTEXT_DISPEL, false },
    { 1, 'combat', 'combattext.interrupt', L_OPT_COMBAT_COMBATTEXT_INTERRUPT, false },
    { 1, 'combat', 'combattext.direction', L_OPT_COMBAT_COMBATTEXT_DIRECTION, false },
    { 1, 'combat', 'combattext.short_numbers', L_OPT_COMBAT_COMBATTEXT_SHORT_NUMBERS, false },
    {},
    { 1, 'combat', 'damagemeter.enable', L_OPT_COMBAT_DAMAGEMETER_ENABLE, false },
    { 1, 'combat', 'damagemeter.classcolorbar', L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORBAR, false },
    { 1, 'combat', 'damagemeter.classcolorname', L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORNAME, false },
    { 1, 'combat', 'damagemeter.onlyboss', L_OPT_COMBAT_DAMAGEMETER_ONLYBOSS, false },
    { 1, 'combat', 'damagemeter.mergeHealAbsorbs', L_OPT_COMBAT_DAMAGEMETER_MERGEHEALABSORBS, false },
}