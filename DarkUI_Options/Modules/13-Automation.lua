local addon = DarkUI_Options
local CHECK, DROP, HEADER = addon.CHECK, addon.DROP, addon.HEADER

addon:RegisterTab("automation", L_CATEGORIES_AUTOMATION or "Automation")

addon.OptionList["automation"] = {
    { CHECK, "automation.accept_invite", L_OPT_AUTOMATION_ACCEPT_INVITE },
    { CHECK, "automation.auto_role", L_OPT_AUTOMATION_AUTO_ROLE },
    { CHECK, "automation.auto_release", L_OPT_AUTOMATION_AUTO_RELEASE },
    { CHECK, "automation.decline_duel", L_OPT_AUTOMATION_DECLINE_DUEL },
    { CHECK, "automation.auto_repair", L_OPT_AUTOMATION_AUTO_REPAIR },
    { CHECK, "automation.auto_sell", L_OPT_AUTOMATION_AUTO_SELL },
    { CHECK, "automation.auto_confirm_de", L_OPT_AUTOMATION_AUTO_CONFIRM_DE },
    { CHECK, "automation.auto_greed", L_OPT_AUTOMATION_AUTO_GREED },
    {
        CHECK,
        "automation.auto_quest",
        L_OPT_AUTOMATION_AUTO_QUEST,
        nil,
        function(widget, a)
            widget:HookScript("OnClick", function(self)
                local checked = self:GetChecked()
                local w1 = a.widgets["automation.auto_quest_pausekey"]
                local w2 = a.widgets["automation.auto_quest_pausekey_reverse"]
                local w3 = a.widgets["automation.auto_quest_reward"]
                if w1 then w1:SetShown(checked) end
                if w2 then w2:SetShown(checked) end
                if w3 then w3:SetShown(checked) end
            end)
        end,
    },
    {
        DROP,
        "automation.auto_quest_pausekey",
        L_OPT_AUTOMATION_QUEST_PAUSEKEY,
        {
            { "SHIFT", "SHIFT" },
            { "CTRL", "CTRL" },
            { "ALT", "ALT" },
        },
    },
    { CHECK, "automation.auto_quest_pausekey_reverse", L_OPT_AUTOMATION_QUEST_PAUSEKEY_REVERSE },
    {
        DROP,
        "automation.auto_quest_reward",
        L_OPT_AUTOMATION_QUEST_REWARD,
        {
            { L_OPT_AUTOMATION_QUEST_REWARD_1, 1 },
            { L_OPT_AUTOMATION_QUEST_REWARD_2, 2 },
            { L_OPT_AUTOMATION_QUEST_REWARD_3, 3 },
            { L_OPT_AUTOMATION_QUEST_REWARD_4, 4 },
        },
    },
    { CHECK, "automation.tab_binder", L_OPT_AUTOMATION_TAB_BINDER },
    { HEADER, nil, L_OPT_AUTOMATION_HEADER_ANNOUNCEMENT },
    {
        CHECK,
        "announcement.interrupt.enable",
        L_OPT_AUTOMATION_INTERRUPT_ENABLE,
        nil,
        function(widget, a)
            widget:HookScript("OnClick", function(self)
                local w = a.widgets["announcement.interrupt.channel"]
                if w then w:SetShown(self:GetChecked()) end
            end)
        end,
    },
    { CHECK, "announcement.quest_notification", L_OPT_AUTOMATION_QUEST_NOTIFICATION or "Quest Progress Notification" },
    {
        DROP,
        "announcement.interrupt.channel",
        L_OPT_AUTOMATION_INTERRUPT_CHANNEL,
        {
            { L_OPT_AUTOMATION_INTERRUPT_CHANNEL_1, 1 },
            { L_OPT_AUTOMATION_INTERRUPT_CHANNEL_2, 2 },
            { L_OPT_AUTOMATION_INTERRUPT_CHANNEL_3, 3 },
            { L_OPT_AUTOMATION_INTERRUPT_CHANNEL_4, 4 },
            { L_OPT_AUTOMATION_INTERRUPT_CHANNEL_5, 5 },
            { L_OPT_AUTOMATION_INTERRUPT_CHANNEL_6, 6 },
        },
    },
}

addon.Hooks["automation"] = function(a)
    local master = a.widgets["announcement.interrupt.enable"]
    local child = a.widgets["announcement.interrupt.channel"]
    if master and child then child:SetShown(master:GetChecked()) end

    local questEnabled = a.widgets["automation.auto_quest"]
    local checked = questEnabled and questEnabled:GetChecked()
    local w1 = a.widgets["automation.auto_quest_pausekey"]
    local w2 = a.widgets["automation.auto_quest_pausekey_reverse"]
    local w3 = a.widgets["automation.auto_quest_reward"]
    if w1 then w1:SetShown(checked) end
    if w2 then w2:SetShown(checked) end
    if w3 then w3:SetShown(checked) end
end
