local _, ns = ...

----------------------------------------------------------------------------------------
--	Unitframe Settings for DarkUI Option GUI
----------------------------------------------------------------------------------------

ns.Categories[4] = L_CATEGORIES_UNITFRAME

ns.Hooks[4] = function()
    -- all
    ns.opt_widgets['unitframe:enable']:HookScript('OnClick', function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "unitframe:") and name ~= 'unitframe:enable' then
                if name == 'unitframe:raid.enable' or not string.find(name, 'unitframe:raid.') then
                    opt:SetEnabled(self:GetChecked())
                end
            end
        end
    end)

    for name, opt in pairs(ns.opt_widgets) do
        if string.find(name, "unitframe:") and name ~= 'unitframe:enable' then
            if name == 'unitframe:raid.enable' or not string.find(name, 'unitframe:raid.') then
                opt:HookScript("OnShow", function(self)
                    self:SetEnabled(ns.opt_widgets['unitframe:enable']:GetChecked())
                end)
            end
        end
    end

    -- raid
    ns.opt_widgets['unitframe:raid.enable']:HookScript('OnClick', function(self)
        ns.opt_widgets['unitframe:raid.colorHealth']:SetEnabled(self:GetChecked())
        ns.opt_widgets['unitframe:raid.raidDebuffs.enable']:SetEnabled(self:GetChecked())
    end)

    ns.opt_widgets['unitframe:raid.enable']:HookScript('OnDisable', function(self)
        ns.opt_widgets['unitframe:raid.colorHealth']:SetEnabled(false)
        ns.opt_widgets['unitframe:raid.raidDebuffs.enable']:SetEnabled(false)
    end)

    ns.opt_widgets['unitframe:raid.enable']:HookScript('OnEnable', function(self)
        ns.opt_widgets['unitframe:raid.colorHealth']:SetEnabled(self:GetChecked())
        ns.opt_widgets['unitframe:raid.raidDebuffs.enable']:SetEnabled(self:GetChecked())
    end)

    ns.opt_widgets['unitframe:raid.colorHealth']:HookScript("OnShow", function(self)
        self:SetEnabled(ns.opt_widgets['unitframe:enable']:GetChecked()
                                and ns.opt_widgets['unitframe:raid.enable']:GetChecked())
    end)

    -- raidDebuffs
    ns.opt_widgets['unitframe:raid.raidDebuffs.enable']:HookScript("OnClick", function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "unitframe:raid.raidDebuffs.") and name ~= 'unitframe:raid.raidDebuffs.enable' then
                opt:SetEnabled(self:GetChecked())
            end
        end
    end)

    ns.opt_widgets['unitframe:raid.raidDebuffs.enable']:HookScript('OnDisable', function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "unitframe:raid.raidDebuffs.") and name ~= 'unitframe:raid.raidDebuffs.enable' then
                opt:SetEnabled(false)
            end
        end
    end)

    ns.opt_widgets['unitframe:raid.enable']:HookScript('OnEnable', function(self)
        for name, opt in pairs(ns.opt_widgets) do
            if string.find(name, "unitframe:raid.raidDebuffs.") and name ~= 'unitframe:raid.raidDebuffs.enable' then
                opt:SetEnabled(self:GetChecked())
            end
        end
    end)

    for name, opt in pairs(ns.opt_widgets) do
        if string.find(name, "unitframe:raid.raidDebuffs.") and name ~= 'unitframe:raid.raidDebuffs.enable' then
            opt:HookScript("OnShow", function(self)
                self:SetEnabled(ns.opt_widgets['unitframe:enable']:GetChecked()
                                        and ns.opt_widgets['unitframe:raid.enable']:GetChecked()
                                        and ns.opt_widgets['unitframe:raid.raidDebuffs.enable']:GetChecked())
            end)
        end
    end
end

-- optType, group, key, name, horizon, data, init, callback, tooltip
-- type: 1: CheckBox, 3: Slider, 4: Dropdown

ns.OptionList[4] = { -- UnitFrame
    { 1, 'unitframe', 'enable', L_OPT_UF_ENABLE, false },
    { 1, 'unitframe', 'portrait3D', L_OPT_UF_PORTRAIT3D, false },
    {},
    { 1, 'unitframe', 'player.colorHealth', L_OPT_UF_PLAYER_COLORHEALTH, false },
    { 1, 'unitframe', 'classModule.classpowerbar.blizzard', L_OPT_UF_PLAYER_CLASSBAR_BLIZZARD, false },
    { 1, 'unitframe', 'classModule.classpowerbar.diabolic', L_OPT_UF_PLAYER_CLASSBAR_DIABOLIC, false },
    {},
    { 1, 'unitframe', 'target.colorHealth', L_OPT_UF_TARGET_COLORHEALTH, false },
    { 1, 'unitframe', 'target.aura.player_aura_only', L_OPT_UF_TARGET_PLAYER_AURA_ONLY, false },
    { 1, 'unitframe', 'target.aura.show_stealable_buffs', L_OPT_UF_TARGET_SHOW_STEALABLE_BUFFS, false },
    {},
    { 1, 'unitframe', 'focus.aura.player_aura_only', L_OPT_UF_FOCUS_PLAYER_AURA_ONLY, false },
    { 1, 'unitframe', 'focus.aura.show_stealable_buffs', L_OPT_UF_FOCUS_SHOW_STEALABLE_BUFFS, false },
    {},
    { 1, 'unitframe', 'boss.aura.player_aura_only', L_OPT_UF_BOSS_PLAYER_AURA_ONLY, false },
    { 1, 'unitframe', 'boss.aura.show_stealable_buffs', L_OPT_UF_BOSS_SHOW_STEALABLE_BUFFS, false },
    {},
    { 1, 'unitframe', 'party.showPlayer', L_OPT_UF_PARTY_SHOWPLAYER, false },
    { 1, 'unitframe', 'party.showSolo', L_OPT_UF_PARTY_SHOWSOLO, false },
    { 1, 'unitframe', 'party.aura.player_aura_only', L_OPT_UF_PARTY_PLAYER_AURA_ONLY, false },
    {},
    { 1, 'unitframe', 'raid.enable', L_OPT_UF_RAID_ENABLE, false },
    { 1, 'unitframe', 'raid.colorHealth', L_OPT_UF_RAID_COLORHEALTH, false },
    { 1, 'unitframe', 'raid.raidDebuffs.enable', L_OPT_UF_RAID_RAIDDEBUFF_ENABLE, false },
    { 1, 'unitframe', 'raid.raidDebuffs.enableTooltip', L_OPT_UF_RAID_RAIDDEBUFF_ENABLETOOLTIP, false },
    { 1, 'unitframe', 'raid.raidDebuffs.showDebuffBorder', L_OPT_UF_RAID_RAIDDEBUFF_SHOWDEBUFFBORDER, false },
    { 1, 'unitframe', 'raid.raidDebuffs.filterDispellableDebuff', L_OPT_UF_RAID_RAIDDEBUFF_FILTERDISPELLABLEDEBUFF, false },
}