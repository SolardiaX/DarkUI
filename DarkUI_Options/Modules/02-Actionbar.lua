local addon = DarkUI_Options
local CHECK, HEADER = addon.CHECK, addon.HEADER

addon:RegisterTab("actionbar", L_CATEGORIES_ACTIONBAR)

addon.OptionList["actionbar"] = {
    { HEADER, nil, "Bars" },
    { CHECK, "actionbar.bars.enable", L_OPT_BARS_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function(self)
            local checked = self:GetChecked()
            for path, w in pairs(a.widgets) do
                if path:find("^actionbar%.") and path ~= "actionbar.bars.enable" then
                    w:SetEnabled(checked)
                end
            end
        end)
    end},
    { CHECK, "actionbar.bars.texture", L_OPT_BARS_TEXTURE_ENABLE },
    { CHECK, "actionbar.bars.bar4.enable", L_OPT_BARS_RIGHTBAR1_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function()
            local master = a.widgets["actionbar.bars.enable"]
            local merge = a.widgets["actionbar.bars.mergeright"]
            if merge and master then
                merge:SetEnabled(master:GetChecked() and (
                    a.widgets["actionbar.bars.bar4.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar5.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar6.enable"]:GetChecked()
                ))
            end
        end)
    end},
    { CHECK, "actionbar.bars.bar5.enable", L_OPT_BARS_RIGHTBAR2_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function()
            local master = a.widgets["actionbar.bars.enable"]
            local merge = a.widgets["actionbar.bars.mergeright"]
            if merge and master then
                merge:SetEnabled(master:GetChecked() and (
                    a.widgets["actionbar.bars.bar4.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar5.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar6.enable"]:GetChecked()
                ))
            end
        end)
    end},
    { CHECK, "actionbar.bars.bar6.enable", L_OPT_BARS_RIGHTBAR3_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function()
            local master = a.widgets["actionbar.bars.enable"]
            local merge = a.widgets["actionbar.bars.mergeright"]
            if merge and master then
                merge:SetEnabled(master:GetChecked() and (
                    a.widgets["actionbar.bars.bar4.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar5.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar6.enable"]:GetChecked()
                ))
            end
        end)
    end},
    { CHECK, "actionbar.bars.mergeright", L_OPT_BARS_MERGERIGHT },
    { CHECK, "actionbar.bars.bar7.enable", L_OPT_BARS_BOTTOMBAR1_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function()
            local master = a.widgets["actionbar.bars.enable"]
            local merge = a.widgets["actionbar.bars.mergebottom"]
            if merge and master then
                merge:SetEnabled(master:GetChecked() and (
                    a.widgets["actionbar.bars.bar7.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar8.enable"]:GetChecked()
                ))
            end
        end)
    end},
    { CHECK, "actionbar.bars.bar8.enable", L_OPT_BARS_BOTTOMBAR2_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function()
            local master = a.widgets["actionbar.bars.enable"]
            local merge = a.widgets["actionbar.bars.mergebottom"]
            if merge and master then
                merge:SetEnabled(master:GetChecked() and (
                    a.widgets["actionbar.bars.bar7.enable"]:GetChecked()
                    or a.widgets["actionbar.bars.bar8.enable"]:GetChecked()
                ))
            end
        end)
    end},
    { CHECK, "actionbar.bars.mergebottom", L_OPT_BARS_MERGEBOTTOM },
    { CHECK, "actionbar.bars.micromenu.enable", L_OPT_BARS_MICROMENU_ENABLE },
    { CHECK, "actionbar.bars.bags.enable", L_OPT_BARS_BAGS_ENABLE },
    { HEADER, nil, "Experience" },
    { CHECK, "actionbar.bars.exp.enable", L_OPT_BARS_EXP_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function(self)
            local checked = self:GetChecked()
            local w1 = a.widgets["actionbar.bars.exp.autoswitch"]
            local w2 = a.widgets["actionbar.bars.exp.disable_at_max_lvl"]
            if w1 then w1:SetEnabled(checked) end
            if w2 then w2:SetEnabled(checked) end
        end)
    end},
    { CHECK, "actionbar.bars.exp.autoswitch", L_OPT_BARS_EXP_AUTOSWITCH },
    { CHECK, "actionbar.bars.exp.disable_at_max_lvl", L_OPT_BARS_EXP_DISABLE_AT_MAX_LVL },
    { HEADER, nil, "Styles" },
    { CHECK, "actionbar.styles.buttons.showHotkey", L_OPT_BARS_STYLE_BUTTONS_SHOWHOTKEY_ENABLE },
    { CHECK, "actionbar.styles.buttons.showMacroName", L_OPT_BARS_STYLE_BUTTONS_SHOWMACRONAME_ENABLE },
    { CHECK, "actionbar.styles.buttons.showStackCount", L_OPT_BARS_STYLE_BUTTONS_SHOWSTACKCOUNT_ENABLE },
    { CHECK, "actionbar.styles.cooldown.enable", L_OPT_BARS_STYLE_COOLDOWN_ENABLE },
    { CHECK, "actionbar.styles.range.enable", L_OPT_BARS_STYLE_RANGE_ENABLE },
}

addon.Hooks["actionbar"] = function(a)
    local master = a.widgets["actionbar.bars.enable"]
    if not master then return end
    local checked = master:GetChecked()
    for path, w in pairs(a.widgets) do
        if path:find("^actionbar%.") and path ~= "actionbar.bars.enable" then
            w:SetEnabled(checked)
        end
    end
    local merge = a.widgets["actionbar.bars.mergeright"]
    if merge then
        merge:SetEnabled(checked and (
            a.widgets["actionbar.bars.bar4.enable"]:GetChecked()
            or a.widgets["actionbar.bars.bar5.enable"]:GetChecked()
            or a.widgets["actionbar.bars.bar6.enable"]:GetChecked()
        ))
    end
    local mergeB = a.widgets["actionbar.bars.mergebottom"]
    if mergeB then
        mergeB:SetEnabled(checked and (
            a.widgets["actionbar.bars.bar7.enable"]:GetChecked()
            or a.widgets["actionbar.bars.bar8.enable"]:GetChecked()
        ))
    end
    local exp = a.widgets["actionbar.bars.exp.enable"]
    if exp then
        local expChecked = checked and exp:GetChecked()
        local w1 = a.widgets["actionbar.bars.exp.autoswitch"]
        local w2 = a.widgets["actionbar.bars.exp.disable_at_max_lvl"]
        if w1 then w1:SetEnabled(expChecked) end
        if w2 then w2:SetEnabled(expChecked) end
    end
end
