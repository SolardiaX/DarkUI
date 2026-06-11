local addon = DarkUI_Options
local CHECK = addon.CHECK

addon:RegisterTab("quest", L_CATEGORIES_QUEST)

addon.OptionList["quest"] = {
    { CHECK, "quest.enable", L_OPT_QUEST_ENABLE, nil, function(widget, a)
        widget:HookScript("OnClick", function(self)
            local checked = self:GetChecked()
            local w1 = a.widgets["quest.auto_collapse"]
            local w2 = a.widgets["quest.auto_button"]
            if w1 then w1:SetEnabled(checked) end
            if w2 then w2:SetEnabled(checked) end
        end)
    end},
    { CHECK, "quest.auto_collapse", L_OPT_QUEST_AUTO_COLLAPSE },
    { CHECK, "quest.auto_button", L_OPT_QUEST_AUTO_BUTTON },
}

addon.Hooks["quest"] = function(a)
    local master = a.widgets["quest.enable"]
    if not master then return end
    local checked = master:GetChecked()
    local w1 = a.widgets["quest.auto_collapse"]
    local w2 = a.widgets["quest.auto_button"]
    if w1 then w1:SetEnabled(checked) end
    if w2 then w2:SetEnabled(checked) end
end
