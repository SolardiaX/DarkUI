----------------------------------------------------------------------------------------
--  Default configuration of Modules
----------------------------------------------------------------------------------------
local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--  Configuration of General
----------------------------------------------------------------------------------------
C.general = {
    uiScale   = 0.74,
    autoScale = true,
    style     = "cold", -- avaliable style is: cold, warm
    liteMode  = false,
    locale_valueformat = false, -- use localized value unit for HP/MP etc.
}

----------------------------------------------------------------------------------------
--  Configuration of Actionbar
----------------------------------------------------------------------------------------
local fader_mouseover = {
    fadeIn  = { time = 0.4, alpha = 1 },
    fadeOut = { time = 0.3, alpha = 0.4 }
}

local fader_combat = {
    fadeIn  = { time = 0.4, alpha = 1 },
    fadeOut = { time = 0.3, alpha = 0.2 }
}

local styles = {
    buttons  = {
        enable         = true,
        showMacroName  = true,
        showCooldown   = true,
        showHotkey     = true,
        showStackCount = true
    },
    cooldown = {
        enable           = true,
        drawBling        = false,
        drawEdge         = false,
        drawSwipe        = true,
        fontFace         = STANDARD_TEXT_FONT,
        fontSize         = 18,
        minScale         = 0.3,
        minDuration      = 3,
        expiringDuration = 5,
        expiringFormat   = "|cffff0000%d|r",
        secondsFormat    = "|cffffff00%d|r",
        minutesFormat    = "|cffffffff%dm|r",
        hoursFormat      = "|cff66ffff%dh|r",
        daysFormat       = "|cff6666ff%dd|r"
    },
    range    = {
        enable = true,
        -- enable range coloring on pet actions
        petActions = true,
    
        -- enable flash animations,
        flashAnimations = true,
        flashDuration = ATTACK_BUTTON_FLASH_TIME * 1.5,

        -- default color (r, g, b, a)
        normal = {1, 1, 1, 1},
        -- out of range
        oor = {1, 0.3, 0.1, 1},
        -- out of mana
        oom = {0.1, 0.3, 1, 1},
        -- unusable action
        unusable = {0.4, 0.4, 0.4, 1}
    }
}

local hover_binding = {
    enable = true
}

local bars = {
    enable           = true,
    mergebar4andbar5 = true,
    texture          = true,
    bar1             = {
        pos    = { "BOTTOM", "UIParent", "BOTTOM", 0, 30 },
        button = {
            size  = 28,
            space = 6.15
        }
    },
    bar2             = {
        pos    = { "BOTTOM", "DarkUI_ActionBar1Holder", "TOP", -2.5, 22 },
        button = {
            size  = 33,
            space = 7.6
        }
    },
    bar3             = {
        pos    = { "BOTTOM", "DarkUI_ActionBar2Holder", "TOP", 0, 12 },
        button = {
            size  = 33,
            space = 7.6
        }
    },
    bar4             = {
        pos             = { "RIGHT", "UIParent", "RIGHT", -4, 0 },
        button          = {
            size  = 28,
            space = 6
        },
        fader_mouseover = fader_mouseover,
        fader_combat    = fader_combat
    },
    bar5             = {
        pos             = { "RIGHT", "UIParent", "RIGHT", -36, 0 },
        button          = {
            size  = 28,
            space = 6
        },
        fader_mouseover = fader_mouseover,
        fader_combat    = fader_combat
    },
    bar6             = {
        pos    = { "CENTER", "UIParent", "CENTER", 0, 10 },
        button = {
            size  = 28,
            space = 6
        }
    },
    bar7             = {
        pos    = { "CENTER", "UIParent", "CENTER", 0, 50 },
        button = {
            size  = 28,
            space = 6
        }
    },
    bar8             = {
        pos    = { "CENTER", "UIParent", "CENTER", 0, 90 },
        button = {
            size  = 28,
            space = 6
        }
    },
    barpet           = {
        pos             = { "BOTTOM", "DarkUI_ActionBar3Holder", "TOP", 0, 10 },
        button          = {
            size  = 24,
            space = 6
        },
        fader_mouseover = fader_mouseover,
        fader_combat    = fader_combat
    },
    barstance        = {
        pos             = { "BOTTOM", "DarkUI_ActionBar3Holder", "TOP", 0, 10 },
        button          = {
            size  = 24,
            space = 6
        },
        fader_mouseover = fader_mouseover,
        fader_combat    = fader_combat
    },
    barextra         = {
        pos             = { "BOTTOM", "UIParent", "BOTTOM", 0, 220 },
        button          = {
            size  = 36,
            space = 6
        },
        fader_mouseover = nil,
        fader_combat    = nil
    },
    leave_vehicle    = {
        pos             = { "BOTTOM", "UIParent", "BOTTOM", 0, 340 },
        button          = {
            size  = 32,
            space = 6
        },
        fader_mouseover = nil,
        fader_combat    = nil
    },
    micromenu        = {
        enable          = true,
        pos             = { "TOP", "UIParent", "TOP", 0, -15 },
        button          = {
            size  = 24,
            space = 2
        },
        scale           = 1,
        fader_mouseover = {
            fadeIn  = { time = 0.4, alpha = 1 },
            fadeOut = { time = 0.3, alpha = 0 }
        }
    },
    bags             = {
        enable          = true,
        pos             = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -4, 34 },
        scale           = 0.82,
        button          = {
            size  = 24,
            space = 4
        },
        fader_mouseover = {
            fadeIn  = { time = 0.4, alpha = 1 },
            fadeOut = { time = 0.3, alpha = 0 }
        }
    },
    exp              = {
        enable             = true,
        scale              = 1,
        width              = 408,
        height             = 6,
        pos                = { "BOTTOM", "DarkUI_ActionBar1Holder", "BOTTOM", 0, -15 },
        autoswitch         = true,
        disable_at_max_lvl = false,
        bflevel            = 1,
        bfstrata           = "BACKGROUND",
        statusbar          = C.media.texture.status,
        xpcolor            = { r = 0.8, g = 0, b = 0.8 },
        repcolor           = { r = 1, g = 0.6, b = 0 },
        restcolor          = { r = 1, g = 0.7, b = 0 }
    },
    artifact         = {
        enable            = true,
        scale             = 1,
        width             = 408,
        height            = 6,
        pos               = { "BOTTOM", "DarkUI_ActionBar1Holder", "BOTTOM", 0, -23 },
        only_at_max_level = false,
        bflevel           = 1,
        bfstrata          = "BACKGROUND",
        statusbar         = C.media.texture.status
    },
}

C.actionbar = {
    bars          = bars,
    styles        = styles,
    hover_binding = hover_binding
}

----------------------------------------------------------------------------------------
--  Configuration of Announcement
----------------------------------------------------------------------------------------
C.announcement = {
    interrupt = {
        enable  = true,
        channel = 6 -- channels = { 'SAY', 'YELL', 'EMOTE', 'PARTY', 'RAID_ONLY', 'RAID' }
    }
}

----------------------------------------------------------------------------------------
--  Configuration of Aura
----------------------------------------------------------------------------------------
C.aura = {
    enable           = true,
    show_caster      = true, -- enable/disable show caster of aura when mouse over
    show_timers      = true, -- enable/disable buffs/debuffs timers
    row_num          = 16, -- buffs/debuffs num per row
    spacing          = 6, -- spacing between icons
    icon_padding     = 2, -- spacing between icon and it's background or shadow
    buff_pos         = { "TOPRIGHT", "UIParent", -260, -20 }, -- buffs position
    debuff_pos       = { "TOPRIGHT", "UIParent", -260, -100 }, -- debuffs position
    dur_pos          = { "BOTTOM", 0, -5 }, -- buffs/debuffs timer position
    count_pos        = { "TOPRIGHT", 0, 0 }, -- buffs/debuffs counter position
    buff_size        = 28, -- buff icons size
    debuff_size      = 32, -- debuff icons size
    enchant_size     = 28, -- enchant icons size
    enable_flash     = true, -- enable cooldown flash
    enable_animation = true, -- enable animiation
    flash_timer      = 30,
    dur_font_style   = { STANDARD_TEXT_FONT, 12, "THINOUTLINE" }, -- timer font style
    count_font_style = { STANDARD_TEXT_FONT, 14, "THINOUTLINE" } -- count font style
}

----------------------------------------------------------------------------------------
--  Configuration of Automation
----------------------------------------------------------------------------------------
C.automation = {
    accept_invite   = true, -- enable/disable auto accept invite
    invite_keyword  = "inv",
    auto_release    = true, -- enable/disable auto release in battleground when death
    decline_duel    = true, -- enable/disable auto reject duel
    auto_repair     = true, -- enable/disable auto repair equipment when visit a merchant
    auto_role       = true, -- enable/disable auto set role
    auto_sell       = true, -- enable/disable auto sell garbage when visit a merchant
    auto_confirm_de = true, -- enable/disable auto accept disenchant confirmation
    auto_greed      = true, -- enable/disable auto greed in party/raid
    auto_quest      = true, -- enable/disable auto accept quest, can use shift+click npc to manual choice quest
    tab_binder      = true -- enable/disable auto change tab key to only target enemy players in PVP
}

----------------------------------------------------------------------------------------
--  Configuration of bag
----------------------------------------------------------------------------------------
C.bags = {
    enable       = true,
    itemSlotSize = 32, -- Size of item slots
    font_size    = 14,
    sizes        = {
        bags = {
            columnsSmall   = 8,
            columnsLarge   = 10,
            largeItemCount = 64, -- Switch to columnsLarge when >= this number of items in your bags
        },
        bank = {
            columnsSmall   = 12,
            columnsLarge   = 14,
            largeItemCount = 96, -- Switch to columnsLarge when >= this number of items in the bank
        },
    }
}

----------------------------------------------------------------------------------------
--  Configuration of Blizzard
----------------------------------------------------------------------------------------
C.blizzard = {
    custom_position     = true,
    hide_maw_buffs      = false,
    achievement_pos     = { "TOP", UIParent, "TOP", 0, -21 },
    capturebar_pos      = { "TOP", UIParent, "TOP", 0, -20 },
    battlescore_pos     = { "TOP", UIParent, "TOP", 0, -25 },
    talking_head_pos    = { "TOP", UIParent, "TOP", 0, -45 },
    alt_powerbar_pos    = { "TOP", UIParent, "TOP", 0, -45 },
    quest_tracker_pos   = { "TOPRIGHT", MinimapCluster, "BOTTOMRIGHT", -70, -25 },
    uiwidget_top_pos    = { "TOP", UIParent, "TOP", 0, -21 },
    uiwidget_below_pos  = { "TOP", UIWidgetTopCenterContainerFrame, "BOTTOM", 0, -15 },
    mirrorbar           = {
        breath     = {
            pos   = { "TOP", "UIParent", "TOP", 0, -96 },
            color = { 0.31, 0.45, 0.63 }
        },
        exhaustion = {
            pos   = { "TOP", "UIParent", "TOP", 0, -116 },
            color = { 1, 0.9, 0 }
        },
        feigndeath = {
            pos   = { "TOP", "UIParent", "TOP", 0, -142 },
            color = { 1, 0.7, 0 }
        },
        death      = {
            color = { 1, 0.7, 0 }
        }
    },
    slot_durability   = true,
    shift_mark        = true,
    style             = true,
    esc_for_gamemenu  = true,
}

----------------------------------------------------------------------------------------
--  Configuration of Chat
----------------------------------------------------------------------------------------
C.chat = {
    enable             = true, -- Enable chat
    pos                = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 24, 26 },
    bn_popup           = { "BOTTOMLEFT", UIParent, "BOTTOMLEFT", 21, 23 },
    background         = false, -- Enable background for chat
    background_alpha   = 0.7, -- Background alpha
    filter             = true, -- Removing some systems spam ("Player1" won duel "Player2")
    spam               = false, -- Removing some players spam (gold/portals/etc)
    auto_width         = true,
    width              = 350, -- Chat width
    height             = 112, -- Chat height
    chat_bar           = true, -- Lite Button Bar for switch chat channel
    chat_bar_mouseover = false, -- Lite Button Bar on mouseover
    time_color         = { 1, 1, 0 }, -- Timestamp coloring (http://www.december.com/html/spec/colorcodescompact.html)
    whisp_sound        = true, -- Sound when whisper
    alt_invite         = true, -- Alt click to invite Player
    bubbles            = true, -- Skin Blizzard chat bubbles
    combatlog          = true, -- Show CombatLog tab
    tabs_mouseover     = true, -- Chat tabs on mouseover
    sticky             = true, -- Remember last channel,
    loot_icons         = true, -- Show loot icons in chat,
    role_icons         = true, -- Show role icons in chat,
}

----------------------------------------------------------------------------------------
--  Configuration of Combat
----------------------------------------------------------------------------------------
C.combat = {
    combattext  = {
        enable             = true, -- Global enable combat text
        blizz_head_numbers = false, -- Use blizzard damage/healing output(above mob/player head)
        damage_style       = true, -- Change default damage/healing font above mobs/player heads(you need to restart WoW to see changes)
        damage             = true, -- Show outgoing damage in it's own frame
        healing            = true, -- Show outgoing healing in it's own frame
        show_hots          = true, -- Show periodic healing effects in healing frame
        show_overhealing   = true, -- Show outgoing overhealing
        incoming           = true, -- Show incoming damage and healing
        pet_damage         = true, -- Show your pet damage
        dot_damage         = true, -- Show damage from your dots
        damage_color       = true, -- Display damage numbers depending on school of magic
        short_numbers      = true, -- Use short numbers ("25.3k" instead of "25342")
        crit_prefix        = "*", -- Symbol that will be added before crit
        crit_postfix       = "*", -- Symbol that will be added after crit
        icons              = true, -- Show outgoing damage icons
        icon_size          = 16, -- Icon size of spells in outgoing damage frame, also has effect on dmg font size
        treshold           = 1, -- Minimum damage to show in damage frame
        heal_treshold      = 1, -- Minimum healing to show in incoming/outgoing healing messages
        scrollable         = false, -- Allows you to scroll frame lines with mousewheel
        max_lines          = 15, -- Max lines to keep in scrollable mode(more lines = more memory)
        time_visible       = 3, -- Time(seconds) a single message will be visible
        dk_runes           = true, -- Show deathknight rune recharge
        killingblow        = true, -- Tells you about your killingblows
        merge_aoe_spam     = true, -- Merges multiple aoe damage spam into single message
        merge_melee        = true, -- Merges multiple auto attack damage spam
        dispel             = true, -- Tells you about your dispels(works only with damage = true)
        interrupt          = true, -- Tells you about your interrupts(works only with damage = true)
        direction          = true, -- Change scrolling direction from bottom to top
        font               = {
            combat_text_font        = STANDARD_TEXT_FONT,
            combat_text_font_size   = 16,
            combat_text_font_style  = "THINOUTLINE",
            combat_text_font_shadow = true
        }
    },

    damagemeter = {
        enable           = true,
        pos              = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -20, 35 },
        classcolorbar    = true,
        onlyboss         = false,
        classcolorname   = false,
        mergeHealAbsorbs = false,
        sortby           = DAMAGE,
        barheight        = 8,
        spacing          = 18,
        maxbars          = 8,
        width            = 240,
        maxfights        = 10,
        reportstrings    = 10,
        backdrop_color   = { 0.01, 0.01, 0.01, 0 },
        border_color     = { 0.01, 0.01, 0.01, 0 },
        border_size      = 1,
        font_style       = "OUTLINE",
        font_size        = 13,
        hidetitle        = true,
        barcolor         = { 0.4, 0.4, 0.4, 1 },
    }
}

----------------------------------------------------------------------------------------
--  Configuration of Loot
----------------------------------------------------------------------------------------
C.loot = {
    enable         = true,
    width          = 220, -- loot window width
    icon_size      = 32, -- icon size in loot window
    pos            = { "TOPLEFT", UIParent, "TOPLEFT", 400, -400 }, -- default loot window position
    group_loot_pos = { "CENTER", UIParent, "CENTER", 240, 240 } -- roll loot position
}

----------------------------------------------------------------------------------------
--  Configuration of Map
----------------------------------------------------------------------------------------
C.map = {
    minimap  = {
        enable   = true, -- enable/disable minimap modules
        position = { "TOPRIGHT", "UIParent", "TOPRIGHT", -35, -35 }, -- minimap position
        iconSize = 20, -- default icon size on minimap
        iconpos  = {
            mail  = { "TOPRIGHT", Minimap, "BOTTOMRIGHT", -30, -8 }, -- position of mail icon
            garrison = { "TOPRIGHT", Minimap, "TOPRIGHT", -32, 14 }, -- position of garrison icon
            queue = { "RIGHT", Minimap, "LEFT", 40, -50  }, -- position of queue icon
            instance = { "TOPRIGHT", Minimap, "TOPRIGHT", 20, 20 }, -- position of instance difficultye
            time = { "BOTTOM", Minimap, "BOTTOM", 1, 1 }, -- position of game time
            clock = { "TOP", Minimap, "BOTTOM", -2, -10 }, -- position of clock
        },
        autoZoom = true, -- enable/disable minimap auto zoom
    },
    worldmap = {
        enable     = true, -- enable/disable worldmap modules
        iconSize   = 28, -- party/raid member icon size on worldmap
        removeFog  = true, -- enable/disable remove fog
        rewardIcon = true, -- eanble/disable the Reward Quest Item Icon
        position   = { "BOTTOM", UIParent, "BOTTOM", 0, 320 }, -- worldmap position
    }
}

----------------------------------------------------------------------------------------
--  Configuration of Misc
----------------------------------------------------------------------------------------
C.misc = {
    socialtabs         = {
        enable  = false,
        lfguild = true, -- always show looking for guild tab
        scale   = 1, -- scale of unified window
        hookpve = true -- hook new 5.0 PvE frame
    },
    raid_utility       = {
        enable   = true,
        position = { "TOPLEFT", UIParent, "TOPLEFT", 400, 1 }
    },
    train_all          = true,
    already_known      = true,
    profession_tabs    = true,
    lfg_queue_timer    = true,
    pvp_queue_timer    = true,
    alt_buy_stack      = true,
    merchant_itemlevel = true,
    slot_itemlevel     = true,
}

----------------------------------------------------------------------------------------
--  Configuration of Quest
----------------------------------------------------------------------------------------
C.quest = {
    enable            = true,
    auto_collapse     = true,
    quest_tracker_pos = { "TOPRIGHT", Minimap, "BOTTOMRIGHT", -60, -60 },
    auto_button       = true,
    auto_button_pos   = { "CENTER", UIParent, "CENTER", 0, -20 },
}

----------------------------------------------------------------------------------------
--  Configuration of Tooltip
----------------------------------------------------------------------------------------
C.tooltip = {
    enable            = true, -- Enable tooltip
    position          = { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -30, 30 }, -- Default position of tooltip
    cursor            = true, -- Display tooltip at above of cursor
    shift_modifer     = false, -- Show tooltip when Shift is pushed
    hide_combat       = false, -- Hide tooltip in combat
    hideforactionbar  = false, -- Hide tooltip for actions bars
    health_value      = true, -- Numeral health value
    target            = true, -- Target player in tooltip
    title             = false, -- Player title in tooltip
    realm             = true, -- Player realm name in tooltip
    rank              = true, -- Player guild-rank in tooltip
    raid_icon         = false, -- Raid icon
    who_targetting    = true, -- Show who is targetting the unit(in raid or party)
    achievements      = true, -- Comparing achievements in tooltip
    item_transmogrify = false, -- Displays items can not be transmogrified
    instance_lock     = false, -- Your instance lock status in tooltip
    item_count        = true, -- Item count in tooltip
    item_icon         = true, -- Item icon in tooltip
    average_lvl       = true, -- Average items level
    arena_experience  = false, -- Player PvP experience in arena
    spell_id          = true, -- Id number spells
    talents           = true, -- Show tooltip talents
    unit_role         = true -- Unit role in tooltip
}

----------------------------------------------------------------------------------------
--  Configuration of Nameplate
----------------------------------------------------------------------------------------
C.nameplate = {
    enable               = true, -- Enable nameplate
    height               = 12, -- Nameplate height
    width                = 300, -- Nameplate width
    distance             = 60, -- Show nameplates for units within this range
    ad_height            = 0, -- Additional height for selected nameplate
    ad_width             = 40, -- Additional width for selected nameplate
    combat               = false, -- Automatically show nameplate in combat
    health_value         = true, -- Numeral health value
    show_castbar_name    = true, -- Show castbar name
    enhance_threat       = true, -- If tank good aggro = green, bad = red
    class_icons          = true, -- Icons by class in PvP
    name_abbrev          = true, -- Display abbreviated names
    clamp                = true, -- Clamp nameplates to the top of the screen when outside of view
    good_color           = { 0.2, 0.8, 0.2 }, -- Good threat color
    near_color           = { 1, 1, 0 }, -- Near threat color
    bad_color            = { 1, 0, 0 }, -- Bad threat color
    offtank_color        = { 0, 0.5, 1 }, -- Offtank threat color
    custom_color         = { 0, 0.8, 0.3 }, -- Custom unit color
    track_debuffs        = true, -- Show debuffs (from the list)
    track_buffs          = true, -- Show buffs above player nameplate (from the list)
    player_aura_only     = true, -- Show player aura only (boss cast aura always shown)
    show_stealable_buffs = true, -- Show stealable buffs
    auras_size           = 22, -- Debuffs size
    healer_icon          = true, -- Show icon above enemy healers nameplate in battlegrounds
    totem_icons          = true, -- Show icon above enemy totems nameplate
    show_spiral          = true, -- Spiral on aura icons
    show_timers          = true, -- cooldown timer on aura
    icon_spacing         = 4, -- spacing between icon
    arrow                = true, -- enable/disable show arrow of current target
    quest                = true, -- show quest infomation
}
----------------------------------------------------------------------------------------
--  Configuration of Unitframe
----------------------------------------------------------------------------------------
C.unitframe = {
    enable       = true,
    mediaPath    = C.media.path, -- path of media, see media.lua
    scale        = 0.9, -- unitframe scale
    portrait3D   = false, -- enable/disable 3D portrait on unitframe
    -- player
    player       = {
        position    = { "CENTER", UIParent, -320, -120 }, -- position of player frame
        colorHealth = false, -- enable/disable health color by class
        castbar     = {
            position    = { "BOTTOMRIGHT", "DarkUIPlayerFrame", "TOPRIGHT", 80, 20 }, -- position of player castbar
            enableFader = true -- enable/disable castbar fade in/out
        },
        fader       = {
            Combat             = 1, -- alpha value when in combat, 0~1, 0 is invisiable, 1 is normal visiable
            Arena              = 1, -- alpha value when in arena, 0~1, 0 is invisiable, 1 is normal visiable
            Instance           = 1, -- alpha value when in instance, 0~1, 0 is invisiable, 1 is normal visiable
            PlayerTarget       = 1, -- alpha value when player has target, 0~1, 0 is invisiable, 1 is normal visiable
            PlayerNotMaxHealth = 1, -- alpha value when player not get max health, 0~1, 0 is invisiable, 1 is normal visiable
            PlayerNotMaxMana   = 1, -- alpha value when player not get max mana, 0~1, 0 is invisiable, 1 is normal visiable
            Stealth            = 1, -- alpha value when player in stealth mode, 0~1, 0 is invisiable, 1 is normal visiable
            notCombat          = 1, -- alpha value when player not in combat, 0~1, 0 is invisiable, 1 is normal visiable
            PlayerTaxi         = 1, -- alpha value when player is taking taxi, 0~1, 0 is invisiable, 1 is normal visiable
            Resting            = 1, -- alpha value when player is in resting mode, 0~1, 0 is invisiable, 1 is normal visiable
            NormalAlpha        = 1 -- alpha value of default, 0~1, 0 is invisiable, 1 is normal visiable
        }
    },
    target       = {
        position    = { "CENTER", UIParent, 320, -120 },
        colorHealth = false,
        castbar     = {
            position    = { "BOTTOMLEFT", "DarkUITargetFrame", "TOPLEFT", -80, 20 },
            enableFader = true -- enable/disable castbar fade in/out
        },
        aura        = {
            player_aura_only     = true,
            show_stealable_buffs = true
        },
        fader       = {
            Combat           = 1,
            Arena            = 1,
            Instance         = 1,
            UnitTaxi         = 1,
            notCombat        = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana   = 1,
            NormalAlpha      = 1
        }
    },
    targettarget = {
        position = { "TOPLEFT", "DarkUITargetFrame", "BOTTOMLEFT", -42, -2 },
        fader    = {
            Combat           = 1,
            Arena            = 1,
            Instance         = 1,
            UnitTarget       = 1,
            UnitTaxi         = 1,
            notCombat        = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana   = 1,
            NormalAlpha      = 1
        }
    },
    pet          = {
        position = { "TOPRIGHT", "DarkUIPlayerFrame", "BOTTOMRIGHT", 42, -2 },
        fader    = {
            Combat           = 1,
            Arena            = 1,
            Instance         = 1,
            UnitTarget       = 1,
            UnitTaxi         = 1,
            notCombat        = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana   = 1,
            NormalAlpha      = 1
        }
    },
    focus        = {
        position = { "CENTER", UIParent, -435, 200 },
        aura     = {
            player_aura_only     = false,
            show_stealable_buffs = true
        },
        fader    = {
            Combat           = 1,
            Arena            = 1,
            Instance         = 1,
            UnitTarget       = 1,
            UnitTaxi         = 1,
            notCombat        = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana   = 1,
            NormalAlpha      = 1
        }
    },
    focustarget  = {
        position = { "BOTTOMLEFT", "DarkUIFocusFrame", "BOTTOMRIGHT", 25, 25 },
        fader    = {
            Combat           = 1,
            Arena            = 1,
            Instance         = 1,
            UnitTarget       = 1,
            UnitTaxi         = 1,
            notCombat        = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana   = 1,
            NormalAlpha      = 1
        }
    },
    boss         = {
        position = { "TOPRIGHT", UIParent, "TOPRIGHT", -150, -300 },
        spacing  = 60,
        aura     = {
            player_aura_only     = true,
            show_Stealable_buffs = true
        },
        fader    = {
            Combat           = 1,
            Arena            = 1,
            Instance         = 1,
            UnitTarget       = 1,
            UnitTaxi         = 1,
            notCombat        = 1,
            notUnitMaxHealth = 1,
            notUnitMaxMana   = 1,
            NormalAlpha      = 1
        }
    },
    party        = {
        position       = {
            auto   = true,
            dps    = { "TOPLEFT", UIParent, "TOPLEFT", 20, -55 },
            healer = { "CENTER", UIParent, "CENTER", 620, -80 }
        },
        unitsPerColumn = 5,
        showPlayer     = true,
        showSolo       = false,
        fader          = {
            Range = {
                insideAlpha  = 1,
                outsideAlpha = 0.5
            }
        }
    },
    raid         = {
        enable      = true,
        position    = { "TOPLEFT", UIParent, "TOPLEFT", 20, -20 },
        showSolo    = false,
        colorHealth = false,
        size        = 96,
        raidDebuffs = {
            enable                  = true,
            enableTooltip           = false,
            showDebuffBorder        = true,
            filterDispellableDebuff = false
        },
        fader       = {
            Range = {
                insideAlpha  = 1,
                outsideAlpha = 0.3
            }
        }
    },
    -- class stuff
    classModule  = {
        DEATHKNIGHT = {
            recolor    = true,
            showRunes  = true,
            showTotems = true
        },
        DEMONHUNTER = {},
        DRUID       = {
            showTotems          = true,
            showAdditionalPower = true
        },
        HUNTER      = {
            showTotems = true
        },
        MAGE        = {
            showArcaneStacks = true,
            showTotems       = true
        },
        MONK        = {
            showStagger         = true,
            showChi             = true,
            showTotems          = true,
            showAdditionalPower = true
        },
        PALADIN     = {
            showHolyPower       = true,
            showTotems          = true,
            showAdditionalPower = true
        },
        PRIEST      = {
            showInsanity        = true,
            showAdditionalPower = true
        },
        ROGUE       = {},
        SHAMAN      = {
            showTotems          = true,
            showAdditionalPower = true
        },
        WARLOCK     = {
            showShards = true,
            showTotems = true
        },
        WARRIOR     = {
            showTotems = true
        }
    }
}

C.autobutton = {
    -- Daily Quests
    [32971] = true,		-- Water Bucket
    [38689] = true,		-- Chicken Net
    [52507] = true,		-- Stardust No.2
    [62829] = true,		-- Magnetized Scrap Collector
    [63351] = true,		-- Tahret Dynasty Mallet
    [69235] = true,		-- Fang of the Wolf
    [69240] = true,		-- Enchanted Salve
    [69981] = true,		-- Ironforge Rations
    [71978] = true,		-- Darkmoon Bandage
    [77475] = true,		-- Stack of Mantras
    [78947] = true,		-- Silken Rope
    [79885] = true,		-- Barrel of Fireworks
    [80127] = true,		-- Shadelight Truffle Spores
    [80403] = true,		-- Angler's Fishing Spear
    [80599] = true,		-- Goblin Fishing Bomb
    [82346] = true,		-- Pot of Fire
    [82381] = true,		-- Yak's Milk Flask
    [82807] = true,		-- Shado-Pan Dragon Gun
    [83134] = true,		-- Bronze Claws
    [84762] = true,		-- Highly Explosive Yaungol Oil
    [85884] = true,		-- Sonic Emitter
    [86532] = true,		-- Bag of Shado-Pan Gas Bombs
    [87394] = true,		-- Sonic Disruption Fork
    [87841] = true,		-- Korven's Experimental Grenades
    [92019] = true,		-- The Bilgewater Molotov
    [93180] = true,		-- Re-Configured Remote
    [93668] = true,		-- Saur Fetish
    [93751] = true,		-- Blessed Torch
    [93761] = true,		-- Arcane Emancipator
    [93806] = true,		-- Resonance Siphon
    -- Seaforium
    [46847] = true,		-- Seaforium Bombs
    [47030] = true,		-- Huge Seaforium Bombs
    -- Other
    [45072] = true,		-- Brightly Colored Egg (Noblegarden)
    -- Legion
    [118330] = true,	-- Pile of Weapons
    [122100] = true,	-- Soul Gem
    [127030] = true,	-- Granny's Flare Grenades
    [127295] = true,	-- Blazing Torch
    [128651] = true,	-- Critter Hand Cannon
    [128772] = true,	-- Branch of the Runewood
    [129161] = true,	-- Stormforged Horn
    [129725] = true,	-- Smoldering Torch
    [131931] = true,	-- Khadgar's Wand
    [133756] = true,	-- Fresh Mound of Flesh
    [133882] = true,	-- Trap Rune
    [133897] = true,	-- Telemancy Beacon
    [133925] = true,	-- Fel Lash
    [133999] = true,	-- Inert Crystal
    [136605] = true,	-- Solendra's Compassion
    [137299] = true,	-- Nightborne Spellblad
    [138146] = true,	-- Rediant Ley Crystal
    [138965] = true,	-- Wand of Siphoning
    [140916] = true,	-- Satchel of Locklimb Powder
    [142509] = true,	-- Withered Targeting Orb
    [128329] = true,	-- Depleted Leyflame Burner
    [130260] = true,	-- Thaedris' Elixir
    [140257] = true,	-- Advanced Telemancy Beacon
    [142401] = true,	-- Telemancy Orbs
    -- BfA
    [166905] = true,	-- Hunting Knife
    [168183] = true,	-- Rare Metal Collector
    [168253] = true,	-- Fathom Hook
    [168482] = true,	-- Plug the Geysers
    -- Shadowlands
    [177836] = true,	-- Wingpierce Javelin
    [180280] = true,	-- Soulforged Core
    [183045] = true,	-- Korinna's Allaying Crook
    [180170] = true,	-- Pulsing Animacone
    [180876] = true,	-- Aqueous Material Accumulator
    [188697] = true,	-- Kinematic Micro-Life Recalibrator
}