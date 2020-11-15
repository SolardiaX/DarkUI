local _, ns = ...

----------------------------------------------------------------------------------------
--	Nameplate Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[5] = L_CATEGORIES_NAMEPLATE

ns.Hooks[5] = function()
    ns.opt_widgets['nameplate:enable']:HookScript('OnClick', function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "nameplate:") and name ~= 'nameplate:enable' then
                opt:SetEnabled(self:GetChecked())
            end
        end
    end)

    for name, opt in pairs(ns.opt_widgets) do
        if string.find(name, "nameplate:") and name ~= 'nameplate:enable' then
            opt:HookScript("OnShow", function(self)
                self:SetEnabled(ns.opt_widgets['nameplate:enable']:GetChecked())
            end)
        end
    end

    -- update to version 8.3.0-b1.0.4
    if SavedOptions['nameplate'] and SavedOptions['nameplate']['track_auras'] ~= nil then
        SavedOptions['nameplate']['track_debuffs'] = SavedOptions['nameplate']['track_auras']
        SavedOptions['nameplate']['track_auras'] = nil
    end
    if SavedOptionsPerChar['nameplate'] and SavedOptionsPerChar['nameplate']['track_auras'] ~= nil then
        SavedOptionsPerChar['nameplate']['track_debuffs'] = SavedOptionsPerChar['nameplate']['track_auras']
        SavedOptionsPerChar['nameplate']['track_auras'] = nil
    end
end

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[5] = { -- Nameplate
    { 1, 'nameplate', 'enable', L_OPT_NAMEPLATE_ENABLE, false },
    { 1, 'nameplate', 'clamp', L_OPT_NAMEPLATE_CLAMP, false },
    { 1, 'nameplate', 'combat', L_OPT_NAMEPLATE_COMBAT, false },
    { 1, 'nameplate', 'health_value', L_OPT_NAMEPLATE_HEALTH_VALUE, false },
    { 1, 'nameplate', 'show_castbar_name', L_OPT_NAMEPLATE_SHOW_CASTBAR_NAME, false },
    { 1, 'nameplate', 'enhance_threat', L_OPT_NAMEPLATE_ENHANCE_THREAT, false },
    { 1, 'nameplate', 'class_icons', L_OPT_NAMEPLATE_CLASS_ICONS, false },
    { 1, 'nameplate', 'totem_icons', L_OPT_NAMEPLATE_TOTEM_ICONS, false },
    { 1, 'nameplate', 'name_abbrev', L_OPT_NAMEPLATE_NAME_ABBREV, false },
    { 1, 'nameplate', 'track_debuffs', L_OPT_NAMEPLATE_TRACK_DEBUFFS, false },
    { 1, 'nameplate', 'track_buffs', L_OPT_NAMEPLATE_TRACK_BUFFS, false },
    { 1, 'nameplate', 'player_aura_only', L_OPT_NAMEPLATE_PLAYER_AURA_ONLY, false },
    { 1, 'nameplate', 'show_stealable_buffs', L_OPT_NAMEPLATE_SHOW_STEALABLE_BUFFS, false },
    { 1, 'nameplate', 'show_spiral', L_OPT_NAMEPLATE_SHOW_SPIRAL, false },
    { 1, 'nameplate', 'arrow', L_OPT_NAMEPLATE_ARROW, false },
    { 1, 'nameplate', 'healer_icon', L_OPT_NAMEPLATE_HEALER_ICON, false },
}
