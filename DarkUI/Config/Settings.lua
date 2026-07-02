local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Settings
----------------------------------------------------------------------------------------

----------------------------------------------------------------------------------------
-- General
----------------------------------------------------------------------------------------
C.general = {
    uiScale = 0.74,
    autoScale = true,
    style = "cold",
    liteMode = false,
    useLocalNumberFormat = true,
    skins = true, -- Blizzard panel skinning (global on/off)
}

----------------------------------------------------------------------------------------
-- Actionbar
----------------------------------------------------------------------------------------
local fader_mouseover = {
    fadeIn = { time = 0.4, alpha = 1 },
    fadeOut = { time = 0.3, alpha = 0.4 },
}

local fader_combat = {
    fadeIn = { time = 0.4, alpha = 1 },
    fadeOut = { time = 0.3, alpha = 0.2 },
}

C.actionbar = {
    bars = {
        enable = true,
        texture = true,
        mergeright = true,
        mergebottom = true,
        bar1 = {
            enable = true,
            pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 30 },
            button = { size = 28, space = 6.84 },
        },
        bar2 = {
            enable = true,
            pos = { "BOTTOM", "DarkUI_ActionBar1", "TOP", 0, 22 },
            button = { size = 33, space = 8.54 },
        },
        bar3 = {
            enable = true,
            pos = { "BOTTOM", "DarkUI_ActionBar2", "TOP", 0, 12 },
            button = { size = 33, space = 8.54 },
        },
        bar4 = {
            enable = true,
            pos = { "RIGHT", "UIParent", "RIGHT", -4, 0 },
            button = { size = 28, space = 6 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        bar5 = {
            enable = true,
            pos = { "RIGHT", "UIParent", "RIGHT", -36, 0 },
            button = { size = 28, space = 6 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        bar6 = {
            enable = false,
            pos = { "RIGHT", "UIParent", "RIGHT", -68, 0 },
            button = { size = 28, space = 6 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        bar7 = {
            enable = false,
            pos = { "BOTTOM", "DarkUI_ActionBar1", "TOP", 0, 140 },
            button = { size = 28, space = 6 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        bar8 = {
            enable = false,
            pos = { "BOTTOM", "DarkUI_ActionBar1", "TOP", 0, 172 },
            button = { size = 28, space = 6 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        barpet = {
            pos = { "BOTTOM", "DarkUI_ActionBar3", "TOP", 0, 10 },
            button = { size = 24, space = 6 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        barstance = {
            pos = { "BOTTOM", "DarkUI_ActionBar3", "TOP", 0, 10 },
            button = { size = 24, space = 4 },
            fader_mouseover = fader_mouseover,
            fader_combat = fader_combat,
        },
        barextra = {
            pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 220 },
            button = { size = 36, space = 6 },
        },
        leave_vehicle = {
            pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 340 },
            button = { size = 36, space = 6 },
        },
        micromenu = {
            enable = true,
            pos = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -40, 34 },
            button = { size = 24, space = 2 },
            scale = 1,
            fader_mouseover = { fadeIn = { time = 0.4, alpha = 1 }, fadeOut = { time = 0.3, alpha = 0.1 } },
        },
        bags = {
            enable = true,
            pos = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -360, 10 },
            scale = 0.98,
            button = { size = 24, space = 4 },
            fader_mouseover = { fadeIn = { time = 0.4, alpha = 1 }, fadeOut = { time = 0.3, alpha = 0.01 } },
        },
        exp = {
            enable = true,
            scale = 1,
            width = 408,
            height = 8,
            pos = { "BOTTOM", "DarkUI_ActionBar1", "BOTTOM", 0, -15 },
            autoswitch = true,
            disable_at_max_lvl = false,
            bflevel = 1,
            bfstrata = "BACKGROUND",
            xpcolor = { r = 0.8, g = 0, b = 0.8 },
            repcolor = { r = 1, g = 0.6, b = 0 },
            restcolor = { r = 1, g = 0.7, b = 0 },
        },
    },
    styles = {
        enable = true,
        buttons = {
            showMacroName = true,
            showCooldown = true,
            showHotkey = true,
            showStackCount = true,
        },
        cooldown = {
            enable = true,
            effect = "shine",
            minEffectDuration = 30,
        },
        range = {
            enable = true,
            petActions = true,
            flashAnimations = true,
            flashDuration = 0.6,
            normal = { 1, 1, 1, 1 },
            oor = { 1, 0.3, 0.1, 1 },
            oom = { 0.1, 0.3, 1, 1 },
            unusable = { 0.4, 0.4, 0.4, 1 },
        },
    },
    hover_binding = true,
}

----------------------------------------------------------------------------------------
-- Announcement
----------------------------------------------------------------------------------------
C.announcement = {
    interrupt = {
        enable = true,
        channel = 6,
    },
    quest_notification = true,
}

----------------------------------------------------------------------------------------
-- Aura
----------------------------------------------------------------------------------------
C.aura = {
    enable = true,
    show_caster = true,
    show_timers = true,
    row_num = 16,
    spacing = 6,
    icon_padding = 2,
    buff_pos = { "TOPRIGHT", "UIParent", -260, -20 },
    debuff_pos = { "TOPRIGHT", "UIParent", -260, -100 },
    private_aura_pos = { "TOP", "UIParent", "TOP", 0, -180 },
    private_aura_size = 36,
    dur_pos = { "BOTTOM", 0, -6 },
    count_pos = { "TOPRIGHT", -2, 4 },
    buff_size = 28,
    debuff_size = 32,
    enchant_size = 28,
    enable_flash = true,
    enable_animation = true,
    flash_timer = 30,
    dur_font_style = { STANDARD_TEXT_FONT, 14, "THINOUTLINE" },
    count_font_style = { STANDARD_TEXT_FONT, 12, "THINOUTLINE" },
    coolDownViewer = {
        enable = true,
        spacing = 4,
        barSpacing = 2,
        viewers = {
            EssentialCooldownViewer = {
                pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 300 },
            },
            UtilityCooldownViewer = {
                pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 240 },
            },
            BuffIconCooldownViewer = {
                pos = { "BOTTOM", "UIParent", "BOTTOM", 0, 380 },
            },
            BuffBarCooldownViewer = {
                pos = { "CENTER", "UIParent", "CENTER", 400, -100 },
                iconSize = 22,
                barWidth = 150,
                barHeight = 12,
            },
        },
        style = {
            swipeAlpha = 0.7,
        },
    },
}

----------------------------------------------------------------------------------------
-- Automation
----------------------------------------------------------------------------------------
C.automation = {
    accept_invite = true,
    invite_keyword = "inv",
    auto_release = true,
    decline_duel = true,
    auto_repair = true,
    auto_role = true,
    auto_sell = true,
    auto_confirm_de = true,
    auto_greed = true,
    auto_quest = true,
    auto_quest_pausekey = "SHIFT",
    auto_quest_pausekey_reverse = false,
    auto_quest_reward = 2,
    tab_binder = true,
}

----------------------------------------------------------------------------------------
-- Bags
----------------------------------------------------------------------------------------
C.bags = {
    enable = true,
    itemSlotSize = 32,
    font_size = 14,
    columns = { bag = 12, bank = 14 },
    itemFilter = true,
    filterEquipment = true,
    filterConsumable = true,
    filterGoods = true,
    filterQuest = true,
    filterCollection = true,
    filterJunk = true,
    filterEquipSet = false,
    filterAOE = true,
    filterDecor = true,
    filterLegacy = false,
}

----------------------------------------------------------------------------------------
-- DataText
----------------------------------------------------------------------------------------
C.datatext = {
    enable = true,
    font = {
        font = STANDARD_TEXT_FONT,
        color = { 1, 1, 1 },
        size = 12,
        alpha = 1,
        outline = 3,
        shadow = { alpha = 1, x = 1, y = -1 },
    },
    icon_size = 12,
    latency = { enable = true },
    memory = { enable = true, max_addons = nil },
    fps = { enable = true },
    friend = { enable = true },
    guild = { enable = true, maxguild = nil, threshold = 1, sorting = "class" },
    location = { enable = true, subzone = true, truncate = 0 },
    coords = { enable = true },
    durability = { enable = true, man = true, gear_icons = false },
    bags = { enable = true },
    currencies = {
        enable = true,
        style = 1,
        expansion = true,
        tracking = true,
        archaeology = true,
        cooking = true,
        raid = true,
        pvp = true,
        other = true,
    },
    time = { enable = true },
}

----------------------------------------------------------------------------------------
-- Blizzard
----------------------------------------------------------------------------------------
C.blizzard = {
    custom_position = true,
    achievement_pos = { "TOP", "UIParent", "TOP", 0, -21 },
    talking_head_pos = { "TOP", "UIParent", "TOP", 0, -45 },
    alt_powerbar_pos = { "TOP", "UIParent", "TOP", 0, -45 },
    uiwidget_top_pos = { "TOP", "UIParent", "TOP", 0, -21 },
    uiwidget_below_pos = { "TOP", "UIWidgetTopCenterContainerFrame", "BOTTOM", 0, -15 },
    mirrorbar = {
        breath = { pos = { "TOP", "UIParent", "TOP", 0, -96 }, color = { 0.31, 0.45, 0.63 } },
        exhaustion = { pos = { "TOP", "UIParent", "TOP", 0, -116 }, color = { 1, 0.9, 0 } },
        feigndeath = { pos = { "TOP", "UIParent", "TOP", 0, -142 }, color = { 1, 0.7, 0 } },
        death = { color = { 1, 0.7, 0 } },
    },
    slot_durability = true,
    shift_mark = true,
    style = true,
    vehicle_pos = { "BOTTOM", "UIParent", "BOTTOM", -350, 80 },
}

----------------------------------------------------------------------------------------
-- Chat
----------------------------------------------------------------------------------------
C.chat = {
    enable = true,
    pos = { "BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 24, 26 },
    bn_popup = { "BOTTOMLEFT", "ChatFrame1", "TOPLEFT", 0, 55 },
    editbox_color = false,
    filter = true,
    spam = true,
    chat_bar = true,
    chat_bar_mouseover = false,
    chat_copy = true,
    time_color = { 0.6, 0.6, 0.6 },
    time_format = "%H:%M",
    alt_invite = true,
    combatlog = true,
    tabs_mouseover = true,
    sticky = true,
    loot_icons = true,
    bubble_font_size = 12,
    bubble_scale = 0.9,
    bubble_hide_instance = true,
    bubble_hide_raid = true,
}

----------------------------------------------------------------------------------------
-- Loot
----------------------------------------------------------------------------------------
C.loot = {
    enable = true,
    faster_loot = true,
    width = 220,
    icon_size = 32,
    pos = { "TOPLEFT", "UIParent", "TOPLEFT", 400, -400 },
    group_loot_pos = { "CENTER", "UIParent", "CENTER", 240, 240 },
}

----------------------------------------------------------------------------------------
-- Map
----------------------------------------------------------------------------------------
C.map = {
    minimap = {
        enable = true,
        position = { "TOPRIGHT", "UIParent", "TOPRIGHT", -35, -35 },
        autoZoom = true,
        recycleBin = false,
    },
    worldmap = {
        enable = true,
        revealMap = true,
        revealGlow = true,
        scale = 0.8,
        maxScale = 0.7,
        position = { "BOTTOM", "UIParent", "BOTTOM", 0, 320 },
    },
}

----------------------------------------------------------------------------------------
-- Misc
----------------------------------------------------------------------------------------
C.misc = {
    raid_utility = {
        enable = true,
        position = { "TOPLEFT", "UIParent", "TOPLEFT", 400, 1 },
    },
    focuser = true,
    faster_movie_skip = true,
    train_all = true,
    already_known = true,
    profession_tabs = true,
    lfg_queue_timer = true,
    pvp_queue_timer = true,
    alt_buy_stack = true,
    merchant_itemlevel = true,
    slot_itemlevel = true,
}

----------------------------------------------------------------------------------------
-- Quest
----------------------------------------------------------------------------------------
C.quest = {
    enable = true,
    auto_collapse = "SCENARIO", -- "NONE", "RAID", "SCENARIO", "RELOAD", or true (= RAID)
    auto_button = true,
    tracker_pos = { "TOPRIGHT", "Minimap", "BOTTOMRIGHT", 0, -60 },
    tracker_height = 700,
}

----------------------------------------------------------------------------------------
-- Tooltip
----------------------------------------------------------------------------------------
C.tooltip = {
    enable = true,
    position = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -30, 30 },
    cursor = true,
    shift_modifer = false,
    hide_combat = false,
    hideforactionbar = false,
    health_value = true,
    title = true,
    realm = true,
    rank = true,
    raid_icon = true,
    achievements = true,
    instance_lock = true,
    item_count = true,
    item_icon = true,
    average_lvl = true,
    spell_id = true,
    talents = true,
    mount = true,
    unit_role = true,
    unit_target = true,
    mythic_score = true,
}

----------------------------------------------------------------------------------------
-- Nameplate
----------------------------------------------------------------------------------------
C.nameplate = {
    enable = true,
    height = 8,
    width = 160,
    distance = 60,
    ad_height = 0,
    ad_width = 40,
    combat = false,
    health_value = true,
    show_castbar_name = true,
    enhance_threat = true,
    class_icons = true,
    name_abbrev = true,
    clamp = true,
    only_name = false,
    good_color = { 0.2, 0.8, 0.2 },
    near_color = { 1, 1, 0 },
    bad_color = { 1, 0, 0 },
    offtank_color = { 0, 0.5, 1 },
    custom_color = { 0, 0.8, 0.3 },
    show_auras = true,
    max_auras = 5,
    auras_per_row = 5,
    auras_size = 22,
    show_dispel = true,
    desaturate = true,
    show_spiral = true,
    show_timers = true,
    icon_spacing = 4,
    show_cc = true,
    num_cc = 2,
    cc_size = 26,
    arrow = true,
    quest = true,
    friendly = {
        nameOnly = true,
        hideInInstance = true,
    },
    visibility = {
        showAll = true,
        enemy = {
            totems = true,
            minions = false,
            guardians = false,
            pets = false,
            minus = true,
        },
        friendly = {
            npcs = true,
            totems = false,
            minions = false,
            guardians = false,
            pets = false,
        },
    },
}

----------------------------------------------------------------------------------------
-- Combat
----------------------------------------------------------------------------------------
C.combat = {
    combatText = {
        enable = true,
        incoming = true,
        incoming_heal = true,
        notification = true,
        outgoing = true,
        outgoing_heal = true,
        outgoing_miss = true,
        loot = true,
        icons = true,
        icon_size = 18,
        font = STANDARD_TEXT_FONT,
        font_size = 14,
        font_size_crit = 20,
        font_style = "OUTLINE",
        group_unlike_spells = false,
        group_appearance = "ALL_ICONS", -- "ALL_ICONS" or "FIRST_ICON_PLUS_N"
        hide_blizzard = true,
        clear_on_combat_exit = true,
    },
    damageMeter = {
        enable = true,
        hideLocalPlayer = true,
        enableHover = true,
        headerBgMode = 2,
        headerBtnMode = 3,
        enableSnap = true,
        win2Position = "TOP",
        win2CustomSize = false,
        win2SizeVal = 150,
        win3Target = 2,
        win3Position = "TOP",
        win3CustomSize = false,
        win3SizeVal = 150,
        resetMode = "smart",
        resetNotice = true,
        quickReset = true,
    },
}

----------------------------------------------------------------------------------------
-- Unitframe
----------------------------------------------------------------------------------------
C.unitframe = {
    enable = true,
    mediaPath = C.media.path,
    scale = 0.9,
    portrait3D = false,
    player = {
        position = { "CENTER", "UIParent", -320, -120 },
        colorHealth = false,
        castbar = {
            position = { "BOTTOMRIGHT", "DarkUIPlayerFrame", "TOPRIGHT", 80, 20 },
            enableFader = true,
        },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            PlayerTarget = 1,
            PlayerNotMaxHealth = 1,
            PlayerNotMaxMana = 1,
            Stealth = 1,
            notCombat = 1,
            PlayerTaxi = 1,
            Resting = 1,
            NormalAlpha = 1,
        },
    },
    target = {
        position = { "CENTER", "UIParent", 320, -120 },
        colorHealth = false,
        castbar = {
            position = { "BOTTOMLEFT", "DarkUITargetFrame", "TOPLEFT", -80, 20 },
            enableFader = true,
        },
        aura = { player_aura_only = true, show_stealable_buffs = true },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            UnitTaxi = 1,
            notCombat = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana = 1,
            NormalAlpha = 1,
        },
    },
    targettarget = {
        position = { "TOPLEFT", "DarkUITargetFrame", "BOTTOMLEFT", -42, -2 },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            UnitTarget = 1,
            UnitTaxi = 1,
            notCombat = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana = 1,
            NormalAlpha = 1,
        },
    },
    pet = {
        position = { "TOPRIGHT", "DarkUIPlayerFrame", "BOTTOMRIGHT", 42, -2 },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            UnitTarget = 1,
            UnitTaxi = 1,
            notCombat = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana = 1,
            NormalAlpha = 1,
        },
    },
    focus = {
        position = { "CENTER", "UIParent", -435, 200 },
        aura = { player_aura_only = false, show_stealable_buffs = true },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            UnitTarget = 1,
            UnitTaxi = 1,
            notCombat = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana = 1,
            NormalAlpha = 1,
        },
    },
    focustarget = {
        position = { "BOTTOMLEFT", "DarkUIFocusFrame", "BOTTOMRIGHT", 25, 25 },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            UnitTarget = 1,
            UnitTaxi = 1,
            notCombat = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana = 1,
            NormalAlpha = 1,
        },
    },
    boss = {
        position = { "TOPRIGHT", "UIParent", "TOPRIGHT", -250, -400 },
        spacing = 60,
        aura = { player_aura_only = true, show_stealable_buffs = true },
        fader = {
            Combat = 1,
            Arena = 1,
            Instance = 1,
            UnitTarget = 1,
            UnitTaxi = 1,
            notCombat = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana = 1,
            NormalAlpha = 1,
        },
    },
    party = {
        enable = true,
        standalone = true,
        position = {
            auto = true,
            dps = { "TOPLEFT", "UIParent", "TOPLEFT", 30, -30 },
            healer = { "CENTER", "UIParent", "CENTER", 620, -80 },
        },
        unitsPerColumn = 5,
        showPlayer = false,
        showSolo = false,
        aura = { player_aura_only = true },
        fader = { Range = { insideAlpha = 1, outsideAlpha = 0.5 } },
    },
    partypet = {
        enable = false,
        position = { "TOP", "DarkUIPartyHeader", "BOTTOM", 0, -40 },
        fader = { Range = { insideAlpha = 1, outsideAlpha = 0.5 } },
    },
    raid = {
        enable = true,
        position = { "TOPLEFT", "UIParent", "TOPLEFT", 10, -10 },
        showSolo = false,
        colorHealth = false,
        size = 96,
        raidDebuffs = {
            enable = true,
            enableTooltip = false,
            showDebuffBorder = true,
            filterDispellableDebuff = false,
        },
        spellsIndicator = true,
        buffsIndicator = true,
        debuffsIndicator = true,
        indicatorSize = 16,
        fader = { Range = { insideAlpha = 1, outsideAlpha = 0.3 } },
    },
    classModule = {
        classpowerbar = {
            diabolic = false,
            blizzard = true,
            position = { "CENTER", "UIParent", "CENTER", 0, -120 },
        },
    },
}
