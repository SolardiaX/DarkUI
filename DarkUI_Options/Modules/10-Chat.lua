local addon = DarkUI_Options
local CHECK = addon.CHECK

addon:RegisterTab("chat", L_CATEGORIES_CHAT)

addon.OptionList["chat"] = {
    { CHECK, "chat.enable", L_OPT_CHAT_ENABLE },
    { CHECK, "chat.editbox_color", L_OPT_CHAT_EDITBOX_COLOR },
    { CHECK, "chat.filter", L_OPT_CHAT_FILTER },
    { CHECK, "chat.spam", L_OPT_CHAT_SPAM },
    { CHECK, "chat.chat_bar", L_OPT_CHAT_CHAT_BAR },
    { CHECK, "chat.chat_bar_mouseover", L_OPT_CHAT_CHAT_BAR_MOUSEOVER },
    { CHECK, "chat.alt_invite", L_OPT_CHAT_CHAT_ALT_INVITE },
    { CHECK, "chat.combatlog", L_OPT_CHAT_CHAT_COMBATLOG },
    { CHECK, "chat.tabs_mouseover", L_OPT_CHAT_CHAT_TABS_MOUSEOVER },
    { CHECK, "chat.sticky", L_OPT_CHAT_CHAT_STICKY },
    { CHECK, "chat.loot_icons", L_OPT_CHAT_LOOT_ICONS },
}

addon.Hooks["chat"] = function(a)
    local master = a.widgets["chat.enable"]
    if not master then return end
    local checked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        for path, w in pairs(a.widgets) do
            if path:find("^chat%.") and path ~= "chat.enable" then
                w:SetEnabled(self:GetChecked())
            end
        end
    end)
    for path, w in pairs(a.widgets) do
        if path:find("^chat%.") and path ~= "chat.enable" then
            w:SetEnabled(checked)
        end
    end
end
