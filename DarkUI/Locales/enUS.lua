local E, C, L = select(2, ...):unpack()

-- if E.locale ~= "enUS" then return end

L.WELCOME_LINE                                   = "Welcome to DarkUI "
L.POPUP_INSTALLUI                                = "You are the first time to use DarkUI. Require RELOAD UI to complete setup."
L.POPUP_RESETUI                                  = "Will reset DarkUI to default configration."

L.MAP_REMOVEFOG                                  = "Remove Fog"
L.MAP_MOUSEOVER                                  = "Mouse"
L.MAP_HIDE_TASK_POI                              = "Hide task POI"
L.MAP_PLAYER                                     = "Player"
L.MAP_BOUNDS                                     = "Out of Bounds"
L.MINIMAP_SWITCHGARRISONTYPE                     = "Right click to switch garrisons"

L.AURA_CAST_BY                                   = "CastBy"
L.AURA_GET_OUT                                   = "GET OUT"
L.AURA_GET_CLOSE                                 = "GET CLOSE"
L.AURA_CRIT                                      = "CRIT"
L.AURA_HASTE                                     = "HASTE"
L.AURA_MASTERY                                   = "MASTERY"
L.AURA_VERSA                                     = "VERSA"
L.AURA_FREEZE                                    = "FREEZE"
L.AURA_MOVE                                      = "MOVE"
L.AURA_COMBO                                     = "COMBO"
L.AURA_ATTACKSPEED                               = "ATTACKSPEED"
L.AURA_CD                                        = "COOLDOWN"
L.AURA_STRIKE                                    = "STRIKE"
L.AURA_POWER                                     = "POWER"
L.AURA_SPEED                                     = "SPEED"

L.UNITFRAME_DEAD                                 = "Dead"
L.UNITFRAME_GHOST                                = "Ghost"
L.UNITFRAME_OFFLINE                              = "Offline"
L.UNITFRAME_AFK                                  = "[AFK]"
L.UNITFRAME_DND                                  = "[DND]"

L.TOOLTIP_NO_TALENT                              = "No Talent"
L.TOOLTIP_LOADING                                = "Loading..."
L.TOOLTIP_ACH_STATUS                             = "Status:"
L.TOOLTIP_ACH_COMPLETE                           = "Status: Complete "
L.TOOLTIP_ACH_INCOMPLETE                         = "Status: Incomplete"
L.TOOLTIP_SPELL_ID                               = "SpellID:"
L.TOOLTIP_ITEM_ID                                = "ItemID:"
L.TOOLTIP_WHO_TARGET                             = "TargetBy"
L.TOOLTIP_ITEM_COUNT                             = "Count:"
L.TOOLTIP_INSPECT_OPEN                           = "InspectFrame is opened"

L.ACTIONBAR_BINDING_INCOMBATLOCKDOWN             = "Can't set key binding in combat"
L.ACTIONBAR_BINDING_TRIGGER                      = "Trigger"
L.ACTIONBAR_BINDING_NOBINDING                    = "No Binding"
L.ACTIONBAR_BINDING_BINDING                      = "Binding"
L.ACTIONBAR_BINDING_KEY                          = "Key"
L.ACTIONBAR_BINDING_ALLCLEAR                     = "|cff00ff00%s|r All keybindings have been cleaned"
L.ACTIONBAR_BINDING_BINDTO                       = "|cff00ff00 %s is binding to %s |r"
L.ACTIONBAR_BINDING_SAVE                         = "All keybindings have been saved"
L.ACTIONBAR_BINDING_DISCARDED                    = "All newly set keybindings have been discarded"
L.ACTIONBAR_BINDING_MODETEXT                     = "Hover your mouse over any actionbutton to bind it. Press the escape key or right click to clear the current actionbutton's keybinding"
L.ACTIONBAR_BINDING_SAVEBTN                      = "Save"
L.ACTIONBAR_BINDING_DISCARDEBTN                  = "Discard"
L.ACTIONBAR_EXP_REP                              = "Exp/Rep"
L.ACTIONBAR_REP                                  = "Rep"
L.ACTIONBAR_EXP                                  = "Exp"
L.ACTIONBAR_PARAGON_EXP                          = "Paragon Exp"
L.ACTIONBAR_APB                                  = "APB"
L.ACTIONBAR_AP_NAME                              = "Equip"
L.ACTIONBAR_AP_TOTAL                             = "Total/Level"
L.ACTIONBAR_AP_UPGRADE                           = "Upgrade"

L.CHAT_WHISPER                                   = "From"
L.CHAT_BN_WHISPER                                = "From"
L.CHAT_AFK                                       = "[AFK]"
L.CHAT_DND                                       = "[DND]"
L.CHAT_GM                                        = "[GM]"
L.CHAT_GUILD                                     = "G"
L.CHAT_PARTY                                     = "P"
L.CHAT_PARTY_LEADER                              = "PL"
L.CHAT_RAID                                      = "R"
L.CHAT_RAID_LEADER                               = "RL"
L.CHAT_RAID_WARNING                              = "RW"
L.CHAT_INSTANCE_CHAT                             = "I"
L.CHAT_INSTANCE_CHAT_LEADER                      = "IL"
L.CHAT_OFFICER                                   = "O"
L.CHAT_PET_BATTLE                                = "PB"
L.CHAT_COME_ONLINE                               = "has come |cff298F00online|r。"
L.CHAT_GONE_OFFLINE                              = "has come |cffff0000offline|r。"
L.CHAT_INTERRUPTED                               = "Interrupted: %s - \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r！"

L.LOOT_RANDOM                                    = "Random Player"
L.LOOT_SELF                                      = "Self Loot"
L.LOOT_FISH                                      = "Fishing loot"
L.LOOT_MONSTER                                   = ">> Loot from "
L.LOOT_CHEST                                     = ">> Loot from chest"
L.LOOT_ANNOUNCE                                  = "Announce to"
L.LOOT_TO_RAID                                   = "  Raid"
L.LOOT_TO_PARTY                                  = "  Party"
L.LOOT_TO_GUILD                                  = "  Guild"
L.LOOT_TO_SAY                                    = "  Say"

L.AUTO_INVITE_KEYWORD                            = 'inv'
L.AUTO_INVITE_INFO                               = 'Accepted invite from '
L.AUTO_DECLINE_DUEL_INFO                         = 'Declined duel request from '
L.AUTO_DECLINE_DUEL_PET_INFO                     = 'Declined pet duel request from '
L.AUTO_REPAIR_GUIDE_INFO                         = 'Repair from guild bank '
L.AUTO_REPAIR_INFO                               = 'Repair cost'
L.AUTO_REPAIR_NOTENOUGH_INFO                     = 'No enough money to auto repair!'
L.AUTO_SELL_INFO                                 = 'AutoSell junk '

-- Combat text
L.COMBATTEXT_ALREADY_UNLOCKED                    = "Combat text is already unlocked."
L.COMBATTEXT_ALREADY_LOCKED                      = "Combat text is already locked."
L.COMBATTEXT_TEST_DISABLED                       = "Combat text test mode disabled."
L.COMBATTEXT_TEST_ENABLED                        = "Combat text test mode enabled."
L.COMBATTEXT_TEST_USE_UNLOCK                     = "Type /xct unlock to move and resize combat text frames."
L.COMBATTEXT_TEST_USE_LOCK                       = "Type /xct lock to lock combat text frames."
L.COMBATTEXT_TEST_USE_TEST                       = "Type /xct test to toggle combat text testmode."
L.COMBATTEXT_TEST_USE_RESET                      = "Type /xct reset to restore default positions."
L.COMBATTEXT_POPUP                               = "To save combat text window positions you need to reload your UI."
L.COMBATTEXT_UNSAVED                             = "Combat text window positions unsaved, don't forget to reload UI."
L.COMBATTEXT_UNLOCKED                            = "Combat text unlocked."

L.DAMAGEMETER_CURRENT                            = "Current"
L.DAMAGEMETER_TOTAL                              = "Total"
L.DAMAGEMETER_OPTION_VISIBLE_BARS                = "Visible bars"
L.DAMAGEMETER_OPTION_BAR_WIDTH                   = "Bar width"
L.DAMAGEMETER_OPTION_BAR_HEIGHT                  = "Bar Height"
L.DAMAGEMETER_OPTION_SPACING                     = "Bar spacing"
L.DAMAGEMETER_OPTION_FONT_SIZE                   = "Font size"
L.DAMAGEMETER_OPTION_HIDE_TITLE                  = "Hide title"
L.DAMAGEMETER_OPTION_CLASS_COLOR_BAR             = "Color bar by class"
L.DAMAGEMETER_OPTION_CLASS_COLOR_NAME            = "Color name by class"
L.DAMAGEMETER_OPTION_SAVE_ONLY_BOSS_FIGHTS       = "Only save Boss fighting infomation"
L.DAMAGEMETER_OPTION_MERGE_HEAL_AND_ABSORBS      = "Merge heal and absorbs"
L.DAMAGEMETER_OPTION_BAR_COLOR                   = "Bar color"
L.DAMAGEMETER_OPTION_BACKDROP_COLOR              = "Background color"
L.DAMAGEMETER_OPTION_BORDER_COLOR                = "Border color"

L.MAIL_MESSAGES                                  = "New mail"
L.MAIL_NEEDMAILBOX                               = "Need a mailbox"
L.MAIL_NOMAIL                                    = "No mail"
L.MAIL_COMPLETE                                  = "All done"
L.MAIL_ENVFULL                                   = "Env is full"
L.MAIL_MAXCOUNT                                  = "Reached max item count"

L.PANELS_AFK                                     = "YOU ARE AFK!"
L.PANELS_AFK_RCLICK                              = "Right-Click to hide."
L.PANELS_AFK_LCLICK                              = "Left-Click to go back."

L.DATATEXT_DAY                                   = "D"
L.DATATEXT_HOUR                                  = "H"
L.DATATEXT_MINUTE                                = "M"
L.DATATEXT_SECOND                                = "S"
L.DATATEXT_MILLISECOND                           = "ms"
L.DATATEXT_ONLINE                                = "Online: "
L.DATATEXT_FRIEND                                = "Friend: "
L.DATATEXT_GUILD                                 = "Guild: "
L.DATATEXT_BAG                                   = "Bag: "
L.DATATEXT_DURABILITY                            = "Durability: "
L.DATATEXT_AUTO_REPAIR                           = "AutoRepair"
L.DATATEXT_AUTO_SELL                             = "AutoSell junk"
L.DATATEXT_ON                                    = "ON"
L.DATATEXT_OFF                                   = "OFF"
L.DATATEXT_HIDDEN                                = "Hidden"
L.DATATEXT_BANDWIDTH                             = "Bandwidth:"
L.DATATEXT_DOWNLOAD                              = "Down:"
L.DATATEXT_MEMORY_USAGE                          = "UI Memory Usage:"
L.DATATEXT_TOTAL_MEMORY_USAGE                    = "Total Memory Usage:"
L.DATATEXT_TOTAL_CPU_USAGE                       = "Total CPU Usage:"
L.DATATEXT_GARBAGE_COLLECTED                     = "Garbage collected"
L.DATATEXT_CURRENCY_RAID                         = "Raid Seals"
L.DATATEXT_SERVER_GOLD                           = "Server Gold"
L.DATATEXT_SESSION_GAIN                          = "Session Gain/Loss"
L.DATATEXT_SORTING_BY                            = "Sorting by: "

L.MISC_BUY_STACK                                 = "Alt-Click to buy a stack"
L.MISC_RAID_UTIL_DISBAND                         = "Disband Group"

L.BAG_CAPTIONS_STUFF                             = "Stuff"
L.BAG_CAPTIONS_NEWITEMS                          = "New Items"
L.BAG_HINT_TOGGLE                                = "Toggle bags"
L.BAG_HINT_RESET_NEW                             = "Reset New"
L.BAG_HINT_RESTACK                               = "Restack"
L.BAG_HINT_ACOUNT_DEPOSIT_INCLUDE_REAGENTS       = "Auto deposit includes reagents"