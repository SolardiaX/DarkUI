local addon = DarkUI_Options
local CHECK, HEADER = addon.CHECK, addon.HEADER

addon:RegisterTab("unitframe", L_CATEGORIES_UNITFRAME)

addon.OptionList["unitframe"] = {
    { HEADER, nil, "General" },
    { CHECK, "unitframe.enable", L_OPT_UF_ENABLE },
    { CHECK, "unitframe.portrait3D", L_OPT_UF_PORTRAIT3D },
    { HEADER, nil, "Player" },
    { CHECK, "unitframe.player.colorHealth", L_OPT_UF_PLAYER_COLORHEALTH },
    { CHECK, "unitframe.classModule.classpowerbar.diabolic", L_OPT_UF_PLAYER_CLASSBAR_DIABOLIC },
    { CHECK, "unitframe.classModule.classpowerbar.blizzard", L_OPT_UF_PLAYER_CLASSBAR_BLIZZARD },
    { HEADER, nil, "Target" },
    { CHECK, "unitframe.target.colorHealth", L_OPT_UF_TARGET_COLORHEALTH },
    { CHECK, "unitframe.target.aura.player_aura_only", L_OPT_UF_TARGET_PLAYER_AURA_ONLY },
    { CHECK, "unitframe.target.aura.show_stealable_buffs", L_OPT_UF_TARGET_SHOW_STEALABLE_BUFFS },
    { HEADER, nil, "Focus" },
    { CHECK, "unitframe.focus.aura.player_aura_only", L_OPT_UF_FOCUS_PLAYER_AURA_ONLY },
    { CHECK, "unitframe.focus.aura.show_stealable_buffs", L_OPT_UF_FOCUS_SHOW_STEALABLE_BUFFS },
    { HEADER, nil, "Boss" },
    { CHECK, "unitframe.boss.aura.player_aura_only", L_OPT_UF_BOSS_PLAYER_AURA_ONLY },
    { CHECK, "unitframe.boss.aura.show_stealable_buffs", L_OPT_UF_BOSS_SHOW_STEALABLE_BUFFS },
    { HEADER, nil, "Party" },
    { CHECK, "unitframe.party.enable", L_OPT_UF_PARTY_ENABLE },
    { CHECK, "unitframe.party.standalone", L_OPT_UF_PARTY_STANDMODE },
    { CHECK, "unitframe.party.showPlayer", L_OPT_UF_PARTY_SHOWPLAYER },
    { CHECK, "unitframe.party.showSolo", L_OPT_UF_PARTY_SHOWSOLO },
    { CHECK, "unitframe.party.aura.player_aura_only", L_OPT_UF_PARTY_PLAYER_AURA_ONLY },
    { HEADER, nil, "Raid" },
    { CHECK, "unitframe.raid.enable", L_OPT_UF_RAID_ENABLE },
    { CHECK, "unitframe.raid.colorHealth", L_OPT_UF_RAID_COLORHEALTH },
    { CHECK, "unitframe.raid.raidDebuffs.enable", L_OPT_UF_RAID_RAIDDEBUFF_ENABLE },
    { CHECK, "unitframe.raid.raidDebuffs.enableTooltip", L_OPT_UF_RAID_RAIDDEBUFF_ENABLETOOLTIP },
    { CHECK, "unitframe.raid.raidDebuffs.showDebuffBorder", L_OPT_UF_RAID_RAIDDEBUFF_SHOWDEBUFFBORDER },
    { CHECK, "unitframe.raid.raidDebuffs.filterDispellableDebuff", L_OPT_UF_RAID_RAIDDEBUFF_FILTERDISPELLABLEDEBUFF },
}

addon.Hooks["unitframe"] = function(a)
    local master = a.widgets["unitframe.enable"]
    if not master then return end

    local masterChecked = master:GetChecked()
    master:HookScript("OnClick", function(self)
        local checked = self:GetChecked()
        for path, w in pairs(a.widgets) do
            if path:find("^unitframe%.") and path ~= "unitframe.enable" then w:SetEnabled(checked) end
        end
    end)

    local standalone = a.widgets["unitframe.party.standalone"]
    if standalone then
        standalone:HookScript("OnClick", function(self)
            local checked = self:GetChecked() and masterChecked
            local w1 = a.widgets["unitframe.party.showPlayer"]
            local w2 = a.widgets["unitframe.party.showSolo"]
            local w3 = a.widgets["unitframe.party.aura.player_aura_only"]
            if w1 then w1:SetEnabled(checked) end
            if w2 then w2:SetEnabled(checked) end
            if w3 then w3:SetEnabled(checked) end
        end)
    end

    local raidEnable = a.widgets["unitframe.raid.enable"]
    if raidEnable then
        raidEnable:HookScript("OnClick", function(self)
            local checked = self:GetChecked() and masterChecked
            for path, w in pairs(a.widgets) do
                if path:find("^unitframe%.raid%.") and path ~= "unitframe.raid.enable" then w:SetEnabled(checked) end
            end
        end)
    end

    local raidDebuffs = a.widgets["unitframe.raid.raidDebuffs.enable"]
    if raidDebuffs then
        raidDebuffs:HookScript("OnClick", function(self)
            local checked = self:GetChecked() and masterChecked and raidEnable:GetChecked()
            for path, w in pairs(a.widgets) do
                if path:find("^unitframe%.raid%.raidDebuffs%.") and path ~= "unitframe.raid.raidDebuffs.enable" then w:SetEnabled(checked) end
            end
        end)
    end

    -- Apply initial state
    for path, w in pairs(a.widgets) do
        if path:find("^unitframe%.") and path ~= "unitframe.enable" then w:SetEnabled(masterChecked) end
    end
    if standalone and raidEnable then
        local partyChecked = masterChecked and standalone:GetChecked()
        local w1 = a.widgets["unitframe.party.showPlayer"]
        local w2 = a.widgets["unitframe.party.showSolo"]
        local w3 = a.widgets["unitframe.party.aura.player_aura_only"]
        if w1 then w1:SetEnabled(partyChecked) end
        if w2 then w2:SetEnabled(partyChecked) end
        if w3 then w3:SetEnabled(partyChecked) end

        local raidChecked = masterChecked and raidEnable:GetChecked()
        for path, w in pairs(a.widgets) do
            if path:find("^unitframe%.raid%.") and path ~= "unitframe.raid.enable" then w:SetEnabled(raidChecked) end
        end
        if raidDebuffs then
            local debuffChecked = raidChecked and raidDebuffs:GetChecked()
            for path, w in pairs(a.widgets) do
                if path:find("^unitframe%.raid%.raidDebuffs%.") and path ~= "unitframe.raid.raidDebuffs.enable" then w:SetEnabled(debuffChecked) end
            end
        end
    end
end
