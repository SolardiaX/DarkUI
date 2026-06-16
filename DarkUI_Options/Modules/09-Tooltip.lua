local addon = DarkUI_Options
local CHECK = addon.CHECK

addon:RegisterTab("tooltip", L_CATEGORIES_TOOLTIP)

addon.OptionList["tooltip"] = {
    { CHECK, "tooltip.enable", L_OPT_TOOLTIP_ENABLE },
    { CHECK, "tooltip.cursor", L_OPT_TOOLTIP_CURSOR },
    { CHECK, "tooltip.shift_modifer", L_OPT_TOOLTIP_SHIFT_MODIFER },
    { CHECK, "tooltip.hide_combat", L_OPT_TOOLTIP_HIDE_COMBAT },
    { CHECK, "tooltip.hideforactionbar", L_OPT_TOOLTIP_HIDEFORACTIONBAR },
    { CHECK, "tooltip.health_value", L_OPT_TOOLTIP_HEALTH_VALUE },
    { CHECK, "tooltip.title", L_OPT_TOOLTIP_TITLE },
    { CHECK, "tooltip.realm", L_OPT_TOOLTIP_REALM },
    { CHECK, "tooltip.rank", L_OPT_TOOLTIP_RANK },
    { CHECK, "tooltip.raid_icon", L_OPT_TOOLTIP_RAID_ICON },
    { CHECK, "tooltip.achievements", L_OPT_TOOLTIP_ACHIEVEMENTS },
    { CHECK, "tooltip.instance_lock", L_OPT_TOOLTIP_INSTANCE_LOCK },
    { CHECK, "tooltip.item_count", L_OPT_TOOLTIP_ITEM_COUNT },
    { CHECK, "tooltip.item_icon", L_OPT_TOOLTIP_ITEM_ICON },
    { CHECK, "tooltip.average_lvl", L_OPT_TOOLTIP_AVERAGE_LVL },
    { CHECK, "tooltip.spell_id", L_OPT_TOOLTIP_SPELL_ID },
    { CHECK, "tooltip.talents", L_OPT_TOOLTIP_TALENTS },
    { CHECK, "tooltip.mount", L_OPT_TOOLTIP_MOUNT },
    { CHECK, "tooltip.unit_role", L_OPT_TOOLTIP_UNIT_ROLE },
    { CHECK, "tooltip.unit_target", L_OPT_TOOLTIP_UNIT_TARGET },
    { CHECK, "tooltip.mythic_score", L_OPT_TOOLTIP_MYTHIC_SCORE },
}

addon.Hooks["tooltip"] = function(a)
    local master = a.widgets["tooltip.enable"]
    if not master then return end
    local checked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        for path, w in pairs(a.widgets) do
            if path:find("^tooltip%.") and path ~= "tooltip.enable" then
                w:SetEnabled(self:GetChecked())
            end
        end
    end)
    for path, w in pairs(a.widgets) do
        if path:find("^tooltip%.") and path ~= "tooltip.enable" then
            w:SetEnabled(checked)
        end
    end
end
