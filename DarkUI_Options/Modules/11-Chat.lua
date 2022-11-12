local _, ns = ...

----------------------------------------------------------------------------------------
--	Chat Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[11] = L_CATEGORIES_CHAT

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[11] = { -- Chat
    { 1, 'chat', 'enable', L_OPT_CHAT_ENABLE, false, nil, function(self)
        self:HookScript("OnClick", function(self)
            for name, opt in pairs(ns.opt_widgets) do
                if string.find(name, "chat:") and name ~= 'chat:enable' then
                    opt:SetEnabled(self:GetChecked())
                end
            end
        end)
    end },
    { 1, 'chat', 'background', L_OPT_CHAT_BACKGROUND, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'filter', L_OPT_CHAT_FILTER, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'spam', L_OPT_CHAT_SPAM, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'auto_width', L_OPT_CHAT_AUTO_WIDTH, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'chat_bar', L_OPT_CHAT_CHAT_BAR, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'chat_bar_mouseover', L_OPT_CHAT_CHAT_BAR_MOUSEOVER, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'whisp_sound', L_OPT_CHAT_CHAT_WHISP_SOUND, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'alt_invite', L_OPT_CHAT_CHAT_ALT_INVITE, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'bubbles', L_OPT_CHAT_CHAT_BUBBLES, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'combatlog', L_OPT_CHAT_CHAT_COMBATLOG, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'tabs_mouseover', L_OPT_CHAT_CHAT_TABS_MOUSEOVER, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'sticky', L_OPT_CHAT_CHAT_STICKY, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'loot_icons', L_OPT_CHAT_LOOT_ICONS, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
    { 1, 'chat', 'role_icons', L_OPT_CHAT_ROLE_ICONS, false, nil, function(self)
        self:HookScript('OnShow', function(self)
            self:SetEnabled(ns.opt_widgets['chat:enable']:GetChecked())
        end)
    end },
}