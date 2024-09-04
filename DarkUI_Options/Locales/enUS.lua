
--if GetLocale() ~= "enUS" then return end

L_DARKUI_CONSOLE = 'DarkUI Console'

L_CATEGORIES_GENERAL = 'General'
L_CATEGORIES_ACTIONBAR = 'Actionbar'
L_CATEGORIES_MAP = 'Map'
L_CATEGORIES_UNITFRAME = 'Unitframe'
L_CATEGORIES_NAMEPLATE = 'Nameplate'
L_CATEGORIES_AURA = 'Aura'
L_CATEGORIES_LOOT = 'Loot & Bag'
L_CATEGORIES_DATATEXT = 'Datatext'
L_CATEGORIES_QUEST = 'Quest'
L_CATEGORIES_TOOLTIP = 'Tooltip'
L_CATEGORIES_CHAT = 'Chat'
L_CATEGORIES_COMBAT = 'Combat'
L_CATEGORIES_MISC = 'Misc'
L_CATEGORIES_COMMAND = 'Commands'

L_OPT_GENERAL_THEME = 'Theme'
L_OPT_GENERAL_THEME_LITEMODE = 'Use Lite style'
L_OPT_GENERAL_BLIZZARD_STYLE = 'Beautify Blizzard Frames'
L_OPT_GENERAL_BLIZZARD_CUSTOM_POSITION = 'Optimize raw frames layout (e.g. Achievement/NPC Dialogue/BreathBar etc.)'
L_OPT_GENERAL_BLIZZARD_HIDE_MAW_BUFFS = 'Hide maw Buffs frame in instances'
L_OPT_GENERAL_AUTOSCALE = 'Enable auto-scaling'
L_OPT_GENERAL_UISCALE = 'scaling'
L_OPT_GENERAL_LOCALE_VALUEFORMAT = 'Enable localized value units (requires language pack support)'

L_OPT_BARS_ENABLE = 'Enable module'
L_OPT_BARS_STYLE_BUTTONS_ENABLE = 'Enable actionbar button style'
L_OPT_BARS_STYLE_BUTTONS_SHOWHOTKEY_ENABLE = 'Show hotkeys on actionbar buttons'
L_OPT_BARS_STYLE_BUTTONS_SHOWMACRONAME_ENABLE = 'Show macro name on actionbar buttons'
L_OPT_BARS_STYLE_BUTTONS_SHOWSTACKCOUNT_ENABLE = 'Show item stacked count on actionbar buttons'
L_OPT_BARS_STYLE_COOLDOWN_ENABLE = 'Show cooldown on actionbar buttons '
L_OPT_BARS_STYLE_RANGE_ENABLE = 'Enable range color on actionbar buttons'
L_OPT_BARS_TEXTURE_ENABLE = 'Enable actionbar decoration background'
L_OPT_BARS_MERGERIGHT = 'Merge right side actionbars'
L_OPT_BARS_MICROMENU_ENABLE = 'Enable mouse on top of screen to display menu bar'
L_OPT_BARS_BAGS_ENABLE = 'Enable mouse in bottom right corner of screen to show backpack'
L_OPT_BARS_EXP_ENABLE = 'Enable experience/reputation bar'
L_OPT_BARS_EXP_AUTOSWITCH = 'Enable Auto-Toggle Reputation Progress'
L_OPT_BARS_EXP_DISABLE_AT_MAX_LVL = 'Disable experience/reputation bar when player is max level'
L_OPT_BARS_ARTIFACT_ENABLE = 'Enable artifact bar'
L_OPT_BARS_ARTIFACT_ONLY_AT_MAX_LEVEL = 'Show artifact bar only when player is max level'

L_OPT_MAP_MINIMAP_ENABLE = 'Enable minimap module'
L_OPT_MAP_MINIMAP_AUTOZOOM = 'Enable minimap auto zoom'
L_OPT_MAP_WORLDMAP_ENABLE = 'Enable worldmap module'
L_OPT_MAP_WORLDMAP_REMOVEFOG = 'Enable removal fog option in worldmap'
L_OPT_MAP_WORLDMAP_REWARDICON = 'Enable display daily quests reward types in worldmap'

L_OPT_UF_ENABLE = 'Enable Unitframe module'
L_OPT_UF_PORTRAIT3D = 'Shows 3D portrait (excludes raid frames)'
--
L_OPT_UF_PLAYER_COLORHEALTH = 'Color health by class with player frame'
L_OPT_UF_PLAYER_CLASSBAR_DIABOLIC = 'Enable Diabloic class resource bar (Combopoints/Runes/Soul Shards/...)'
L_OPT_UF_PLAYER_CLASSBAR_BLIZZARD = 'Enable Blizzard class resource bar (Combopoints/Runes/Soul Shards/...)'
--
L_OPT_UF_TARGET_COLORHEALTH = 'Color health by class with target frame'
L_OPT_UF_TARGET_PLAYER_AURA_ONLY = 'Only shows player cast buff/debuff with target frame (includes boss buff/debuff)'
L_OPT_UF_TARGET_SHOW_STEALABLE_BUFFS = 'Show stealable buff with target frame'
--
L_OPT_UF_FOCUS_PLAYER_AURA_ONLY = 'Only shows player cast buff/debuff with focus frame (includes boss buff/debuff)'
L_OPT_UF_FOCUS_SHOW_STEALABLE_BUFFS = 'Show stealable buff with focus frame'
--
L_OPT_UF_BOSS_PLAYER_AURA_ONLY = 'Only shows player cast buff/debuff with boss frame (includes boss buff/debuff)'
L_OPT_UF_BOSS_SHOW_STEALABLE_BUFFS = 'Show stealable buff with boss frame'
--
L_OPT_UF_PARTY_STANDMODE = 'Use standard party frames (Otherwise use raid frame for party)'
L_OPT_UF_PARTY_SHOWPLAYER = 'Show player in party frames'
L_OPT_UF_PARTY_SHOWSOLO = 'Show party frames in solo'
L_OPT_UF_PARTY_PLAYER_AURA_ONLY = 'Only shows player cast buff/debuff with party frame (includes boss buff/debuff)'
--
L_OPT_UF_RAID_ENABLE = 'Enable raid frames'
L_OPT_UF_RAID_COLORHEALTH = 'Color health by class with raid frames'
L_OPT_UF_RAID_RAIDDEBUFF_ENABLE = 'Show raid debuff with raid frames'
L_OPT_UF_RAID_RAIDDEBUFF_ENABLETOOLTIP = 'Enable tooltip on raid debuff'
L_OPT_UF_RAID_RAIDDEBUFF_SHOWDEBUFFBORDER = 'Eable border on raid debuff'
L_OPT_UF_RAID_RAIDDEBUFF_FILTERDISPELLABLEDEBUFF = 'Only show dispellable raid debuff'

L_OPT_NAMEPLATE_ENABLE = 'Enable nameplate module'
L_OPT_NAMEPLATE_CLAMP = 'Always display nameplates within screen'
L_OPT_NAMEPLATE_COMBAT = 'Only show nameplates in combat'
L_OPT_NAMEPLATE_HEALTH_VALUE = 'Show health value'
L_OPT_NAMEPLATE_SHOW_CASTBAR_NAME = 'Show name of casting'
L_OPT_NAMEPLATE_ENHANCE_THREAT = 'Enable color of threat for tank/solo (green for normal, red for abnormal)'
L_OPT_NAMEPLATE_CLASS_ICONS = 'Show class icons'
L_OPT_NAMEPLATE_TOTEM_ICONS = 'Show totem icons'
L_OPT_NAMEPLATE_NAME_ABBREV = 'Auto abbrev name'
L_OPT_NAMEPLATE_TRACK_DEBUFFS = 'Track debuff'
L_OPT_NAMEPLATE_TRACK_BUFFS = 'Track buff'
L_OPT_NAMEPLATE_PLAYER_AURA_ONLY = 'Only shows player cast buff/debuff (includes boss buff)'
L_OPT_NAMEPLATE_SHOW_STEALABLE_BUFFS = 'Show stealable buff'
L_OPT_NAMEPLATE_SHOW_TIMERS = 'Cooldown timer with buff/debuff'
L_OPT_NAMEPLATE_SHOW_SPIRAL = 'cooldown spiral with buff/debuff'
L_OPT_NAMEPLATE_ARROW = 'Show arrow to current target'
L_OPT_NAMEPLATE_HEALER_ICON = 'Show healer icon in battleground/arena'
L_OPT_NAMEPLATE_QUEST = 'Show quest info'

L_OPT_AURA_ENABLE = 'Enable buff/debuff module'
L_OPT_AURA_SHOW_CASTER = 'Show caster of buff/debuff'
L_OPT_AURA_ENABLE_FLASH = 'Enable buff/debuff countdown flash'
L_OPT_AURA_ENABLE_ANIMATION = 'Enable buff/debuff animation'
L_OPT_AURA_AURAWATCH_ENABLE = 'Enable aurawatch'
L_OPT_AURA_AURAWATCH_CLICKTHROUGH = 'Disable tooltip for aurawatch'
L_OPT_AURA_AURAWATCH_QUAKERING = 'Sounds when quakering'

L_OPT_ANNOUNCEMENT_INTERRUPT_ENABLE = 'Enable interrupt module'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL = 'interrupt to'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_1 = 'Say'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_2 = 'Yell'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_3 = 'Emote'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_4 = 'Party'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_5 = 'Raid Only'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_6 = 'Raid'

L_OPT_LOOT_BAGS_ENABLE = 'Enable bag modules'
L_OPT_LOOT_LOOT_ENABLE = 'Enable loot modules'
L_OPT_LOOT_FASTER_LOOT = 'Enable fast loot'

L_OPT_DATATEXT_ENABLE = 'Enable datatext modules'
L_OPT_DATATEXT_LATENCY_ENABLE = 'Enable latency (left-down)'
L_OPT_DATATEXT_MEMORY_ENABLE = 'Enable memory (left-down)'
L_OPT_DATATEXT_FPS_ENABLE = 'Enable FPS (left-down)'
L_OPT_DATATEXT_FRIENDS_ENABLE = 'Enable friends (left-down)'
L_OPT_DATATEXT_GUILD_ENABLE = 'Enable guild (left-down)'
L_OPT_DATATEXT_LOCATION_ENABLE = 'Enable location (down of minimap)'
L_OPT_DATATEXT_COORDS_ENABLE = 'Enable coords (down of minimap)'
L_OPT_DATATEXT_DURABILITY_ENABLE = 'Enable durability (right-down)'
L_OPT_DATATEXT_BAGS_ENABLE = 'Enable bags (right-down)'
L_OPT_DATATEXT_GOLD_ENABLE = 'Enable currencies (right-down)'

L_OPT_QUEST_ENABLE = 'Enable quest module'
L_OPT_QUEST_AUTO_COLLAPSE = 'Auto collapse quest tracker in instance'
L_OPT_QUEST_AUTO_BUTTON = 'Enable quick button for quest'

L_OPT_TOOLTIP_ENABLE = 'Enable tooltip module'
L_OPT_TOOLTIP_CURSOR = 'Tooltip follow cursor (default at right-down corner)'
L_OPT_TOOLTIP_SHIFT_MODIFER = 'Show tooltip only when pressin shift key'
L_OPT_TOOLTIP_HIDE_COMBAT = 'Hide tooltip in combat'
L_OPT_TOOLTIP_HIDEFORACTIONBAR = 'Hide tooltip for actionbar'
L_OPT_TOOLTIP_HEALTH_VALUE = 'Show health value'
L_OPT_TOOLTIP_TARGET = 'Show target'
L_OPT_TOOLTIP_TITLE = 'Show title'
L_OPT_TOOLTIP_REALM = 'Show realm'
L_OPT_TOOLTIP_RANK = 'Show rank'
L_OPT_TOOLTIP_RAID_ICON = 'Show raid icon'
L_OPT_TOOLTIP_WHO_TARGETTING = 'Show who targetting'
L_OPT_TOOLTIP_ACHIEVEMENTS = 'Enable achivements compare'
L_OPT_TOOLTIP_ITEM_TRANSMOGRIFY = 'Show item transmogrify'
L_OPT_TOOLTIP_INSTANCE_LOCK = 'Show instance lock'
L_OPT_TOOLTIP_ITEM_COUNT = 'Show item count'
L_OPT_TOOLTIP_ITEM_ICON = 'Show item icon'
L_OPT_TOOLTIP_AVERAGE_LVL = 'Show average equipment level'
L_OPT_TOOLTIP_SPELL_ID = 'Show spell id'
L_OPT_TOOLTIP_TALENTS = 'Show talent'
L_OPT_TOOLTIP_MOUNT = 'Show source of mount'
L_OPT_TOOLTIP_UNIT_ROLE = 'Show unit role in party/raid'

L_OPT_CHAT_ENABLE = 'Enable chat module'
L_OPT_CHAT_BACKGROUND = 'Enable background for chat'
L_OPT_CHAT_FILTER = 'Filter unused system info (eg. afk/drunked/duel victory)'
L_OPT_CHAT_SPAM = 'Enable spam'
L_OPT_CHAT_AUTO_WIDTH = 'Auto width to screen width'
L_OPT_CHAT_CHAT_BAR = 'Enable channel switch buttons (left/right click to switch channels)'
L_OPT_CHAT_CHAT_BAR_MOUSEOVER = 'Hovering to show channel switch buttons'
L_OPT_CHAT_CHAT_WHISP_SOUND = 'Sounds when whisp'
L_OPT_CHAT_CHAT_ALT_INVITE = 'Alt click to invite'
L_OPT_CHAT_CHAT_BUBBLES = 'Beautify chat bubbles'
L_OPT_CHAT_CHAT_COMBATLOG = 'Show Combat Log Toggle'
L_OPT_CHAT_CHAT_TABS_MOUSEOVER = 'Hovering to show chat tabs'
L_OPT_CHAT_CHAT_STICKY = 'Remember the last channel used'
L_OPT_CHAT_LOOT_ICONS = 'Show loot icons in chat frame'
L_OPT_CHAT_ROLE_ICONS = 'Show role icons in chat frame'

L_OPT_COMBAT_COMBATTEXT_ENABLE = "Enable combat text module (based on xCT)"
L_OPT_COMBAT_COMBATTEXT_BLIZZ_HEAD_NUMBERS = "Enable blizzard head numbers"
L_OPT_COMBAT_COMBATTEXT_DAMAGE_STYLE = "Change Damage style (need restart WoW)"
L_OPT_COMBAT_COMBATTEXT_DAMAGE = "Show outgoing damage in it's own frame"
L_OPT_COMBAT_COMBATTEXT_HEALING = "Show outgoing healing in it's own frame"
L_OPT_COMBAT_COMBATTEXT_SHOW_HOTS = "Show periodic healing effects in healing frame"
L_OPT_COMBAT_COMBATTEXT_SHOW_OVERHEALING = "Show outgoing overhealing"
L_OPT_COMBAT_COMBATTEXT_INCOMING = "Show floating incoming damage and healing"
L_OPT_COMBAT_COMBATTEXT_PET_DAMAGE = "Show your pet damage"
L_OPT_COMBAT_COMBATTEXT_DOT_DAMAGE = "Show damage from your dots"
L_OPT_COMBAT_COMBATTEXT_DAMAGE_COLOR = "Display damage numbers depending on class of magic"
L_OPT_COMBAT_COMBATTEXT_CRIT_PREFIX = "Symbol that will be added before crit (default *)"
L_OPT_COMBAT_COMBATTEXT_CRIT_POSTFIX = "Symbol that will be added after crit (default *)"
L_OPT_COMBAT_COMBATTEXT_ICONS = "Show outgoing damage icons"
L_OPT_COMBAT_COMBATTEXT_SCROLLABLE = "Allows you to scroll frame lines with mousewheel"
L_OPT_COMBAT_COMBATTEXT_DK_RUNES = "Show Death knight's rune recharge"
L_OPT_COMBAT_COMBATTEXT_KILLINGBLOW = "Tells you about your killing blows"
L_OPT_COMBAT_COMBATTEXT_MERGE_AOE_SPAM = "Merges multiple AoE damage spam into single message"
L_OPT_COMBAT_COMBATTEXT_MERGE_MELEE = "Merges multiple auto attack damage spam"
L_OPT_COMBAT_COMBATTEXT_DISPEL = "Tells you about your dispels"
L_OPT_COMBAT_COMBATTEXT_INTERRUPT = "Tells you about your interrupts"
L_OPT_COMBAT_COMBATTEXT_DIRECTION = "Change scrolling direction from bottom to top"
L_OPT_COMBAT_COMBATTEXT_SHORT_NUMBERS = "Use short number"
--
L_OPT_COMBAT_DAMAGEMETER_ENABLE = 'Enable damage/heal meter (based on DamageMeter)'
L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORBAR = 'Color bar by class'
L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORNAME = 'Color name by class'
L_OPT_COMBAT_DAMAGEMETER_ONLYBOSS = 'Only save Boss fighting infomation'
L_OPT_COMBAT_DAMAGEMETER_MERGEHEALABSORBS = 'Merge heal and absorbs'

L_OPT_MISC_BLIZZARD_SLOT_DURABILITY = 'Durability on character slot buttons'
L_OPT_MISC_BLIZZARD_SHIFT_MARK = 'Marks mouseover target when you push Shift (only in group)'
L_OPT_MISC_PROFESSION_TABS = 'Enable profession tabs'
L_OPT_MISC_MERCHANT_ITEMLEVEL = 'Show item level in merchant'
L_OPT_MISC_SLOT_ITEMLEVEL = 'Iten level on character/inspect slot buttons'
L_OPT_MISC_TRAIN_ALL = 'Enable one button train all'
L_OPT_MISC_ALREADY_KNOWN = 'Colorizes recipes/mounts/pets/toys that is already known'
L_OPT_MISC_LFG_QUEUE_TIMER = 'Enable LFG queue timer (Disabled when enale BigWigs/DBM)'
L_OPT_MISC_ALT_BUY_STACK = 'Alt click to buy stack'
L_OPT_MISC_RAID_UTILITY = 'Enable raid utility'
--
L_OPT_MISC_AUTOMATION_ACCEPT_INVITE = 'Auto accept invitations from friends/guild'
L_OPT_MISC_AUTOMATION_AUTO_ROLE = 'Auto set role in party/raid'
L_OPT_MISC_AUTOMATION_AUTO_RELEASE = 'Auto release he spirit in battleground'
L_OPT_MISC_AUTOMATION_DECLINE_DUEL = 'Auto reject duel invitation'
L_OPT_MISC_AUTOMATION_AUTO_REPAIR = 'Auto repair equipment'
L_OPT_MISC_AUTOMATION_AUTO_SELL = 'Auto sell junk'
L_OPT_MISC_AUTOMATION_AUTO_CONFIRM_DE = 'Auto confirm disenchant'
L_OPT_MISC_AUTOMATION_AUTO_GREED = 'Enable auto-greed/disenchant for green item at max level'
L_OPT_MISC_AUTOMATION_AUTO_QUEST = 'Auto accept quest (disabled if hold Shift)'
L_OPT_MISC_AUTOMATION_TAB_BINDER = '\'Tab\' key target only enemy players when in PvP zones, ignores pets and mobs'

L_OPT_COMMAND_HVB = 'Enable hover hotkey binding for actionbar button'
L_OPT_COMMAND_XCT = 'Move/lock combat text (Only available when combat text enabled)'
L_OPT_COMMAND_DMG = 'Move/lock damage meter (Only available when damage meter enabled)'
L_OPT_COMMAND_AW = 'Move/lock aura watch (Only available when aura watch enabled)'
L_OPT_COMMAND_RC = 'Ready check'
L_OPT_COMMAND_GM = 'Call GM'
L_OPT_COMMAND_RL = 'Reload UI'
L_OPT_COMMAND_RESETUI = 'Reset DarkUI'
L_OPT_COMMAND_FRAME = 'Show information of mouse hover frame or with special <name>'
L_OPT_COMMAND_ALIGN = 'Show align grid'
L_OPT_COMMAND_TESTUI = 'Move/lock unitframe (Only available when unitframe enabled, only for test currently)'
L_OPT_COMMAND_TESTROLL = 'Move/lock roll frame (Only available when roll enabled, only for test currently)'

L_TIPS = 'Tips'
L_GLOBAL_OPTION = 'Set as global options (avaliable for all roles of account)'
L_RESET = 'Reset'
L_POPUP_CONFIRM_RELOAD = 'Need reload UI to apply the changes.'
