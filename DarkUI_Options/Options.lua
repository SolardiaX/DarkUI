local ns = _G["DarkUI"]
local E, C, L, DB = ns:unpack()

local addon = DarkUI_Options
local CHECK, SLIDER, DROP, HEADER, BUTTON = addon.CHECK, addon.SLIDER, addon.DROP, addon.HEADER, addon.BUTTON

------------------------------------------------------------------------
-- Tab Registration (order matters)
------------------------------------------------------------------------

addon:RegisterTab("general", L_CATEGORIES_GENERAL)
addon:RegisterTab("actionbar", L_CATEGORIES_ACTIONBAR)
addon:RegisterTab("unitframe", L_CATEGORIES_UNITFRAME)
addon:RegisterTab("nameplate", L_CATEGORIES_NAMEPLATE)
addon:RegisterTab("aura", L_CATEGORIES_AURA)
addon:RegisterTab("map", L_CATEGORIES_MAP)
addon:RegisterTab("loot", L_CATEGORIES_LOOT)
addon:RegisterTab("datatext", L_CATEGORIES_DATATEXT)
addon:RegisterTab("tooltip", L_CATEGORIES_TOOLTIP)
addon:RegisterTab("chat", L_CATEGORIES_CHAT)
addon:RegisterTab("quest", L_CATEGORIES_QUEST)
addon:RegisterTab("automation", L_CATEGORIES_AUTOMATION or "Automation")
addon:RegisterTab("misc", L_CATEGORIES_MISC)
addon:RegisterTab("commands", L_CATEGORIES_COMMAND)

------------------------------------------------------------------------
-- General
------------------------------------------------------------------------

addon.OptionList["general"] = {
    { HEADER, nil, L_OPT_GENERAL_THEME },
    { CHECK, "general.autoScale", L_OPT_GENERAL_AUTOSCALE },
    { SLIDER, "general.uiScale", L_OPT_GENERAL_UISCALE, { 0.4, 1.5, 0.01 } },
    { CHECK, "general.liteMode", L_OPT_GENERAL_THEME_LITEMODE },
    { CHECK, "general.useLocalNumberFormat", L_OPT_GENERAL_LOCALE_VALUEFORMAT },
    { HEADER, nil, "Blizzard" },
    { CHECK, "blizzard.style", L_OPT_GENERAL_BLIZZARD_STYLE },
    { CHECK, "blizzard.custom_position", L_OPT_GENERAL_BLIZZARD_CUSTOM_POSITION },
    { CHECK, "blizzard.slot_durability", L_OPT_MISC_BLIZZARD_SLOT_DURABILITY },
    { CHECK, "blizzard.shift_mark", L_OPT_MISC_BLIZZARD_SHIFT_MARK },
}

------------------------------------------------------------------------
-- Actionbar
------------------------------------------------------------------------

addon.OptionList["actionbar"] = {
    { HEADER, nil, "Bars" },
    { CHECK, "actionbar.bars.enable", L_OPT_BARS_ENABLE },
    { CHECK, "actionbar.bars.texture", L_OPT_BARS_TEXTURE_ENABLE },
    { CHECK, "actionbar.bars.mergeright", L_OPT_BARS_MERGERIGHT },
    { CHECK, "actionbar.bars.mergebottom", L_OPT_BARS_MERGEBOTTOM },
    { CHECK, "actionbar.bars.bar4.enable", L_OPT_BARS_RIGHTBAR1_ENABLE },
    { CHECK, "actionbar.bars.bar5.enable", L_OPT_BARS_RIGHTBAR2_ENABLE },
    { CHECK, "actionbar.bars.bar6.enable", L_OPT_BARS_RIGHTBAR3_ENABLE },
    { CHECK, "actionbar.bars.bar7.enable", L_OPT_BARS_BOTTOMBAR1_ENABLE },
    { CHECK, "actionbar.bars.bar8.enable", L_OPT_BARS_BOTTOMBAR2_ENABLE },
    { CHECK, "actionbar.bars.micromenu.enable", L_OPT_BARS_MICROMENU_ENABLE },
    { CHECK, "actionbar.bars.bags.enable", L_OPT_BARS_BAGS_ENABLE },
    { HEADER, nil, "Experience" },
    { CHECK, "actionbar.bars.exp.enable", L_OPT_BARS_EXP_ENABLE },
    { CHECK, "actionbar.bars.exp.autoswitch", L_OPT_BARS_EXP_AUTOSWITCH },
    { CHECK, "actionbar.bars.exp.disable_at_max_lvl", L_OPT_BARS_EXP_DISABLE_AT_MAX_LVL },
    { HEADER, nil, "Styles" },
    { CHECK, "actionbar.styles.buttons.showHotkey", L_OPT_BARS_STYLE_BUTTONS_SHOWHOTKEY_ENABLE },
    { CHECK, "actionbar.styles.buttons.showMacroName", L_OPT_BARS_STYLE_BUTTONS_SHOWMACRONAME_ENABLE },
    { CHECK, "actionbar.styles.buttons.showStackCount", L_OPT_BARS_STYLE_BUTTONS_SHOWSTACKCOUNT_ENABLE },
    { CHECK, "actionbar.styles.cooldown.enable", L_OPT_BARS_STYLE_COOLDOWN_ENABLE },
    { CHECK, "actionbar.styles.range.enable", L_OPT_BARS_STYLE_RANGE_ENABLE },
}

------------------------------------------------------------------------
-- Unitframe
------------------------------------------------------------------------

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
    { CHECK, "unitframe.party.enable", L_OPT_UF_RAID_ENABLE },
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

------------------------------------------------------------------------
-- Nameplate
------------------------------------------------------------------------

addon.OptionList["nameplate"] = {
    { CHECK, "nameplate.enable", L_OPT_NAMEPLATE_ENABLE },
    { CHECK, "nameplate.clamp", L_OPT_NAMEPLATE_CLAMP },
    { CHECK, "nameplate.combat", L_OPT_NAMEPLATE_COMBAT },
    { CHECK, "nameplate.health_value", L_OPT_NAMEPLATE_HEALTH_VALUE },
    { CHECK, "nameplate.show_castbar_name", L_OPT_NAMEPLATE_SHOW_CASTBAR_NAME },
    { CHECK, "nameplate.enhance_threat", L_OPT_NAMEPLATE_ENHANCE_THREAT },
    { CHECK, "nameplate.class_icons", L_OPT_NAMEPLATE_CLASS_ICONS },
    { CHECK, "nameplate.name_abbrev", L_OPT_NAMEPLATE_NAME_ABBREV },
    { CHECK, "nameplate.arrow", L_OPT_NAMEPLATE_ARROW },
    { CHECK, "nameplate.quest", L_OPT_NAMEPLATE_QUEST },
    { HEADER, nil, "Auras" },
    { CHECK, "nameplate.track_debuffs", L_OPT_NAMEPLATE_TRACK_DEBUFFS },
    { CHECK, "nameplate.track_buffs", L_OPT_NAMEPLATE_TRACK_BUFFS },
    { CHECK, "nameplate.player_aura_only", L_OPT_NAMEPLATE_PLAYER_AURA_ONLY },
    { CHECK, "nameplate.show_stealable_buffs", L_OPT_NAMEPLATE_SHOW_STEALABLE_BUFFS },
    { CHECK, "nameplate.show_timers", L_OPT_NAMEPLATE_SHOW_TIMERS },
    { CHECK, "nameplate.show_spiral", L_OPT_NAMEPLATE_SHOW_SPIRAL },
}

------------------------------------------------------------------------
-- Aura
------------------------------------------------------------------------

addon.OptionList["aura"] = {
    { CHECK, "aura.enable", L_OPT_AURA_ENABLE },
    { CHECK, "aura.show_caster", L_OPT_AURA_SHOW_CASTER },
    { CHECK, "aura.show_timers", L_OPT_NAMEPLATE_SHOW_TIMERS },
    { CHECK, "aura.enable_flash", L_OPT_AURA_ENABLE_FLASH },
    { CHECK, "aura.enable_animation", L_OPT_AURA_ENABLE_ANIMATION },
    { SLIDER, "aura.buff_size", L_OPT_AURA_BUFF_SIZE or "Buff Size", { 20, 48, 1 } },
    { SLIDER, "aura.debuff_size", L_OPT_AURA_DEBUFF_SIZE or "Debuff Size", { 20, 48, 1 } },
    { SLIDER, "aura.row_num", L_OPT_AURA_ROW_NUM or "Icons Per Row", { 8, 24, 1 } },
}

------------------------------------------------------------------------
-- Map
------------------------------------------------------------------------

addon.OptionList["map"] = {
    { HEADER, nil, "Minimap" },
    { CHECK, "map.minimap.enable", L_OPT_MAP_MINIMAP_ENABLE },
    { CHECK, "map.minimap.autoZoom", L_OPT_MAP_MINIMAP_AUTOZOOM },
    { HEADER, nil, "World Map" },
    { CHECK, "map.worldmap.enable", L_OPT_MAP_WORLDMAP_ENABLE },
    { CHECK, "map.worldmap.removeFog", L_OPT_MAP_WORLDMAP_REMOVEFOG },
}

------------------------------------------------------------------------
-- Loot & Bag
------------------------------------------------------------------------

addon.OptionList["loot"] = {
    { HEADER, nil, "Loot" },
    { CHECK, "loot.enable", L_OPT_LOOT_LOOT_ENABLE },
    { CHECK, "loot.faster_loot", L_OPT_LOOT_FASTER_LOOT },
    { HEADER, nil, "Bags" },
    { CHECK, "bags.enable", L_OPT_LOOT_BAGS_ENABLE },
    { SLIDER, "bags.itemSlotSize", L_OPT_BAGS_SLOT_SIZE or "Slot Size", { 24, 48, 1 } },
}

------------------------------------------------------------------------
-- DataText
------------------------------------------------------------------------

addon.OptionList["datatext"] = {
    { CHECK, "datatext.enable", L_OPT_DATATEXT_ENABLE },
    { CHECK, "datatext.latency.enable", L_OPT_DATATEXT_LATENCY_ENABLE },
    { CHECK, "datatext.memory.enable", L_OPT_DATATEXT_MEMORY_ENABLE },
    { CHECK, "datatext.fps.enable", L_OPT_DATATEXT_FPS_ENABLE },
    { CHECK, "datatext.friend.enable", L_OPT_DATATEXT_FRIENDS_ENABLE },
    { CHECK, "datatext.guild.enable", L_OPT_DATATEXT_GUILD_ENABLE },
    { CHECK, "datatext.location.enable", L_OPT_DATATEXT_LOCATION_ENABLE },
    { CHECK, "datatext.coords.enable", L_OPT_DATATEXT_COORDS_ENABLE },
    { CHECK, "datatext.durability.enable", L_OPT_DATATEXT_DURABILITY_ENABLE },
    { CHECK, "datatext.bags.enable", L_OPT_DATATEXT_BAGS_ENABLE },
    { CHECK, "datatext.currencies.enable", L_OPT_DATATEXT_GOLD_ENABLE },
}

------------------------------------------------------------------------
-- Tooltip
------------------------------------------------------------------------

addon.OptionList["tooltip"] = {
    { CHECK, "tooltip.enable", L_OPT_TOOLTIP_ENABLE },
    { CHECK, "tooltip.cursor", L_OPT_TOOLTIP_CURSOR },
    { CHECK, "tooltip.shift_modifer", L_OPT_TOOLTIP_SHIFT_MODIFER },
    { CHECK, "tooltip.hide_combat", L_OPT_TOOLTIP_HIDE_COMBAT },
    { CHECK, "tooltip.hideforactionbar", L_OPT_TOOLTIP_HIDEFORACTIONBAR },
    { CHECK, "tooltip.health_value", L_OPT_TOOLTIP_HEALTH_VALUE },
    { CHECK, "tooltip.target", L_OPT_TOOLTIP_TARGET },
    { CHECK, "tooltip.title", L_OPT_TOOLTIP_TITLE },
    { CHECK, "tooltip.realm", L_OPT_TOOLTIP_REALM },
    { CHECK, "tooltip.rank", L_OPT_TOOLTIP_RANK },
    { CHECK, "tooltip.raid_icon", L_OPT_TOOLTIP_RAID_ICON },
    { CHECK, "tooltip.who_targetting", L_OPT_TOOLTIP_WHO_TARGETTING },
    { CHECK, "tooltip.achievements", L_OPT_TOOLTIP_ACHIEVEMENTS },
    { CHECK, "tooltip.item_transmogrify", L_OPT_TOOLTIP_ITEM_TRANSMOGRIFY },
    { CHECK, "tooltip.instance_lock", L_OPT_TOOLTIP_INSTANCE_LOCK },
    { CHECK, "tooltip.item_count", L_OPT_TOOLTIP_ITEM_COUNT },
    { CHECK, "tooltip.item_icon", L_OPT_TOOLTIP_ITEM_ICON },
    { CHECK, "tooltip.average_lvl", L_OPT_TOOLTIP_AVERAGE_LVL },
    { CHECK, "tooltip.spell_id", L_OPT_TOOLTIP_SPELL_ID },
    { CHECK, "tooltip.talents", L_OPT_TOOLTIP_TALENTS },
    { CHECK, "tooltip.mount", L_OPT_TOOLTIP_MOUNT },
    { CHECK, "tooltip.unit_role", L_OPT_TOOLTIP_UNIT_ROLE },
}

------------------------------------------------------------------------
-- Chat
------------------------------------------------------------------------

addon.OptionList["chat"] = {
    { CHECK, "chat.enable", L_OPT_CHAT_ENABLE },
    { CHECK, "chat.background", L_OPT_CHAT_BACKGROUND },
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

------------------------------------------------------------------------
-- Quest
------------------------------------------------------------------------

addon.OptionList["quest"] = {
    { CHECK, "quest.enable", L_OPT_QUEST_ENABLE },
    { CHECK, "quest.auto_collapse", L_OPT_QUEST_AUTO_COLLAPSE },
    { CHECK, "quest.auto_button", L_OPT_QUEST_AUTO_BUTTON },
}

------------------------------------------------------------------------
-- Automation
------------------------------------------------------------------------

addon.OptionList["automation"] = {
    { CHECK, "automation.accept_invite", L_OPT_MISC_AUTOMATION_ACCEPT_INVITE },
    { CHECK, "automation.auto_role", L_OPT_MISC_AUTOMATION_AUTO_ROLE },
    { CHECK, "automation.auto_release", L_OPT_MISC_AUTOMATION_AUTO_RELEASE },
    { CHECK, "automation.decline_duel", L_OPT_MISC_AUTOMATION_DECLINE_DUEL },
    { CHECK, "automation.auto_repair", L_OPT_MISC_AUTOMATION_AUTO_REPAIR },
    { CHECK, "automation.auto_sell", L_OPT_MISC_AUTOMATION_AUTO_SELL },
    { CHECK, "automation.auto_confirm_de", L_OPT_MISC_AUTOMATION_AUTO_CONFIRM_DE },
    { CHECK, "automation.auto_greed", L_OPT_MISC_AUTOMATION_AUTO_GREED },
    { CHECK, "automation.auto_quest", L_OPT_MISC_AUTOMATION_AUTO_QUEST },
    { CHECK, "automation.tab_binder", L_OPT_MISC_AUTOMATION_TAB_BINDER },
    { HEADER, nil, "Announcement" },
    { CHECK, "announcement.interrupt.enable", L_OPT_ANNOUNCEMENT_INTERRUPT_ENABLE },
    { CHECK, "announcement.quest_notification", L_OPT_ANNOUNCEMENT_QUEST_NOTIFICATION or "Quest Progress Notification" },
    {
        DROP,
        "announcement.interrupt.channel",
        L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL,
        {
            { L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_1, 1 },
            { L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_2, 2 },
            { L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_3, 3 },
            { L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_4, 4 },
            { L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_5, 5 },
            { L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_6, 6 },
        },
    },
}

------------------------------------------------------------------------
-- Misc
------------------------------------------------------------------------

addon.OptionList["misc"] = {
    { CHECK, "misc.raid_utility.enable", L_OPT_MISC_RAID_UTILITY },
    { CHECK, "misc.focuser", L_OPT_MISC_FOCUSER or "Shift+Click Set Focus" },
    { CHECK, "misc.faster_movie_skip", L_OPT_MISC_FASTER_MOVIE_SKIP or "Faster Movie/Cinematic Skip" },
    { CHECK, "misc.train_all", L_OPT_MISC_TRAIN_ALL },
    { CHECK, "misc.already_known", L_OPT_MISC_ALREADY_KNOWN },
    { CHECK, "misc.profession_tabs", L_OPT_MISC_PROFESSION_TABS },
    { CHECK, "misc.lfg_queue_timer", L_OPT_MISC_LFG_QUEUE_TIMER },
    { CHECK, "misc.pvp_queue_timer", L_OPT_MISC_PVP_QUEUE_TIMER or "PVP Queue Timer" },
    { CHECK, "misc.alt_buy_stack", L_OPT_MISC_ALT_BUY_STACK },
    { CHECK, "misc.merchant_itemlevel", L_OPT_MISC_MERCHANT_ITEMLEVEL },
    { CHECK, "misc.slot_itemlevel", L_OPT_MISC_SLOT_ITEMLEVEL },
}

------------------------------------------------------------------------
-- Commands (read-only reference)
------------------------------------------------------------------------

addon.OptionList["commands"] = {
    { BUTTON, "/hvb", L_OPT_COMMAND_HVB },
    { BUTTON, "/darkui tpl", L_OPT_COMMAND_TPL },
    { BUTTON, "/align", L_OPT_COMMAND_ALIGN },
    { BUTTON, "/frame", L_OPT_COMMAND_FRAME },
    { BUTTON, "/testroll", L_OPT_COMMAND_TESTROLL },
    { BUTTON, "/rc", L_OPT_COMMAND_RC },
    { BUTTON, "/gm", L_OPT_COMMAND_GM },
    { BUTTON, "/rl", L_OPT_COMMAND_RL },
}
