local addon = DarkUI_Options
local CHECK, SLIDER, DROP, HEADER = addon.CHECK, addon.SLIDER, addon.DROP, addon.HEADER

addon:RegisterTab("combat", L_CATEGORIES_COMBAT or "Combat")

addon.OptionList["combat"] = {
    -- Combat Text
    { CHECK, "combat.combatText.enable", L_OPT_COMBATTEXT_ENABLE },
    { HEADER, "", L_OPT_COMBATTEXT_HEADER_DISPLAY or "Display" },
    { CHECK, "combat.combatText.incoming", L_OPT_COMBATTEXT_INCOMING },
    { CHECK, "combat.combatText.incoming_heal", L_OPT_COMBATTEXT_INCOMING_HEAL },
    { CHECK, "combat.combatText.outgoing", L_OPT_COMBATTEXT_OUTGOING },
    { CHECK, "combat.combatText.outgoing_heal", L_OPT_COMBATTEXT_OUTGOING_HEAL },
    { CHECK, "combat.combatText.outgoing_miss", L_OPT_COMBATTEXT_OUTGOING_MISS },
    { CHECK, "combat.combatText.notification", L_OPT_COMBATTEXT_NOTIFICATION },
    { CHECK, "combat.combatText.loot", L_OPT_COMBATTEXT_LOOT },
    { HEADER, "", L_OPT_COMBATTEXT_HEADER_FORMAT or "Format" },
    { CHECK, "combat.combatText.icons", L_OPT_COMBATTEXT_ICONS },
    { CHECK, "combat.combatText.group_unlike_spells", L_OPT_COMBATTEXT_GROUP_UNLIKE_SPELLS },
    { DROP, "combat.combatText.group_appearance", L_OPT_COMBATTEXT_GROUP_APPEARANCE, {
        { L_OPT_COMBATTEXT_GROUP_ALL_ICONS or "All Icons", "ALL_ICONS" },
        { L_OPT_COMBATTEXT_GROUP_FIRST_PLUS_N or "First +N", "FIRST_ICON_PLUS_N" },
    }},
    { HEADER, "", L_OPT_COMBATTEXT_HEADER_ADVANCED or "Advanced" },
    { CHECK, "combat.combatText.hide_blizzard", L_OPT_COMBATTEXT_HIDE_BLIZZARD },
    { CHECK, "combat.combatText.clear_on_combat_exit", L_OPT_COMBATTEXT_CLEAR_ON_EXIT },
    -- Damage Meter
    { HEADER, "", L_CATEGORIES_DMETER or "Damage Meter" },
    { CHECK, "combat.damageMeter.enable", L_OPT_DMETER_ENABLE or "Enable Damage Meter skin" },
    { HEADER, "", L_OPT_DMETER_HEADER_DISPLAY or "Display" },
    { CHECK, "combat.damageMeter.hideLocalPlayer", L_OPT_DMETER_HIDE_LOCALPLAYER or "Hide local player sticky bar" },
    { HEADER, "", L_OPT_DMETER_HEADER_HOVER or "Auto Fade" },
    { CHECK, "combat.damageMeter.enableHover", L_OPT_DMETER_HOVER_ENABLE or "Enable mouseover fade" },
    { DROP, "combat.damageMeter.headerBgMode", L_OPT_DMETER_HEADER_BG or "Header background display", {
        { L_OPT_DMETER_ALWAYS or "Always Show", 1 },
        { L_OPT_DMETER_MOUSEOVER or "Mouseover Only", 2 },
    }},
    { DROP, "combat.damageMeter.headerBtnMode", L_OPT_DMETER_HEADER_BTN or "Header elements display", {
        { L_OPT_DMETER_BTN_ALWAYS or "Always Show", 1 },
        { L_OPT_DMETER_BTN_KEEP_LEFT or "Keep Left Elements", 2 },
        { L_OPT_DMETER_BTN_HIDE_ALL or "Hide All", 3 },
    }},
    { HEADER, "", L_OPT_DMETER_HEADER_SNAP or "Snapping" },
    { CHECK, "combat.damageMeter.enableSnap", L_OPT_DMETER_SNAP_ENABLE or "Enable window snapping" },
    { DROP, "combat.damageMeter.win2Position", L_OPT_DMETER_WIN2_POS or "Window 2 position", {
        { L_OPT_DMETER_POS_TOP or "Top", "TOP" },
        { L_OPT_DMETER_POS_BOTTOM or "Bottom", "BOTTOM" },
        { L_OPT_DMETER_POS_LEFT or "Left", "LEFT" },
        { L_OPT_DMETER_POS_RIGHT or "Right", "RIGHT" },
    }},
    { CHECK, "combat.damageMeter.win2CustomSize", L_OPT_DMETER_WIN2_CUSTOM or "Window 2 custom size" },
    { SLIDER, "combat.damageMeter.win2SizeVal", L_OPT_DMETER_WIN2_SIZE or "Window 2 size", { 50, 600, 1 } },
    { DROP, "combat.damageMeter.win3Target", L_OPT_DMETER_WIN3_TARGET or "Window 3 target", {
        { L_OPT_DMETER_TARGET_MAIN or "Main Window", 1 },
        { L_OPT_DMETER_TARGET_WIN2 or "Window 2", 2 },
    }},
    { DROP, "combat.damageMeter.win3Position", L_OPT_DMETER_WIN3_POS or "Window 3 position", {
        { L_OPT_DMETER_POS_TOP or "Top", "TOP" },
        { L_OPT_DMETER_POS_BOTTOM or "Bottom", "BOTTOM" },
        { L_OPT_DMETER_POS_LEFT or "Left", "LEFT" },
        { L_OPT_DMETER_POS_RIGHT or "Right", "RIGHT" },
    }},
    { CHECK, "combat.damageMeter.win3CustomSize", L_OPT_DMETER_WIN3_CUSTOM or "Window 3 custom size" },
    { SLIDER, "combat.damageMeter.win3SizeVal", L_OPT_DMETER_WIN3_SIZE or "Window 3 size", { 50, 600, 1 } },
    { HEADER, "", L_OPT_DMETER_HEADER_RESET or "Reset Policy" },
    { DROP, "combat.damageMeter.resetMode", L_OPT_DMETER_RESET_MODE or "Reset mode", {
        { L_OPT_DMETER_RST_SMART or "Smart (Recommended)", "smart" },
        { L_OPT_DMETER_RST_COMBAT or "Every Combat", "combat" },
        { L_OPT_DMETER_RST_INSTANCE or "Instance Entry", "instance" },
        { L_OPT_DMETER_RST_BOSS or "Boss Only", "boss" },
        { L_OPT_DMETER_RST_MPLUS or "M+ Only", "mplus" },
        { L_OPT_DMETER_RST_NEVER or "Never", "never" },
    }},
    { CHECK, "combat.damageMeter.resetNotice", L_OPT_DMETER_RESET_NOTICE or "Announce reset to chat" },
    { CHECK, "combat.damageMeter.quickReset", L_OPT_DMETER_QUICK_RESET or "Quick reset (Ctrl+Click)" },
}

addon.Hooks["combat"] = function(a)
    local ctMaster = a.widgets["combat.combatText.enable"]
    if ctMaster then
        local checked = ctMaster:GetChecked()
        ctMaster:HookScript("OnClick", function(self)
            for path, w in pairs(a.widgets) do
                if path:find("^combat%.combatText%.") and path ~= "combat.combatText.enable" then
                    w:SetEnabled(self:GetChecked())
                end
            end
        end)
        for path, w in pairs(a.widgets) do
            if path:find("^combat%.combatText%.") and path ~= "combat.combatText.enable" then
                w:SetEnabled(checked)
            end
        end
    end

    local dmMaster = a.widgets["combat.damageMeter.enable"]
    if dmMaster then
        local checked = dmMaster:GetChecked()
        dmMaster:HookScript("OnClick", function(self)
            for path, w in pairs(a.widgets) do
                if path:find("^combat%.damageMeter%.") and path ~= "combat.damageMeter.enable" then
                    w:SetEnabled(self:GetChecked())
                end
            end
        end)
        for path, w in pairs(a.widgets) do
            if path:find("^combat%.damageMeter%.") and path ~= "combat.damageMeter.enable" then
                w:SetEnabled(checked)
            end
        end
    end
end
