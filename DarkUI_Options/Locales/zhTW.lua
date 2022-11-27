
if GetLocale() ~= "zhTW" then return end

L_DARKUI_CONSOLE = 'DarkUI 控制臺'

L_CATEGORIES_GENERAL = '通用設置'
L_CATEGORIES_ACTIONBAR = '動作條'
L_CATEGORIES_MAP = '地圖'
L_CATEGORIES_UNITFRAME = '單位框體'
L_CATEGORIES_NAMEPLATE = '姓名板'
L_CATEGORIES_AURA = '法術技能'
L_CATEGORIES_LOOT = '物品背包'
L_CATEGORIES_DATATEXT = '信息條'
L_CATEGORIES_QUEST = '任務追蹤'
L_CATEGORIES_TOOLTIP = '鼠標提示'
L_CATEGORIES_CHAT = '聊天框'
L_CATEGORIES_COMBAT = '戰鬥信息'
L_CATEGORIES_MISC = '雜項配置'
L_CATEGORIES_COMMAND = '內置命令'

L_OPT_GENERAL_THEME = '界面風格'
L_OPT_GENERAL_THEME_LITEMODE = '使用 Lite 風格動作條'
L_OPT_GENERAL_BLIZZARD_STYLE = '美化原始窗體'
L_OPT_GENERAL_BLIZZARD_CUSTOM_POSITION = '優化原始窗體布局 (如 成就提示/NPC對話提示/呼吸條 等)'
L_OPT_GENERAL_BLIZZARD_HIDE_MAW_BUFFS = '隱藏副本 Maw Buffs 信息'
L_OPT_GENERAL_AUTOSCALE = '啟用自動縮放'
L_OPT_GENERAL_UISCALE = '縮放比例'
L_OPT_GENERAL_LOCALE_VALUEFORMAT = '启用本地化数字单位（需要语言包提供对应支持）'

L_OPT_BARS_ENABLE = '啟用動作條模塊'
L_OPT_BARS_STYLE_BUTTONS_ENABLE = '啟用動作條按鈕樣式'
L_OPT_BARS_STYLE_BUTTONS_SHOWHOTKEY_ENABLE = '動作條按鈕顯示綁定熱鍵'
L_OPT_BARS_STYLE_BUTTONS_SHOWMACRONAME_ENABLE = '動作條按鈕顯示宏名稱'
L_OPT_BARS_STYLE_BUTTONS_SHOWSTACKCOUNT_ENABLE = '動作條按鈕顯示物品堆疊數量'
L_OPT_BARS_STYLE_COOLDOWN_ENABLE = '動作條按鈕顯示冷卻計時'
L_OPT_BARS_STYLE_RANGE_ENABLE = '動作條按鈕按施法距離著色'
L_OPT_BARS_TEXTURE_ENABLE = '啟用動作條裝飾背景'
L_OPT_BARS_MERGEBAR4ANDBAR5 = '合並右側動作條'
L_OPT_BARS_MICROMENU_ENABLE = '啟用鼠標位於屏幕正頂顯示菜單欄'
L_OPT_BARS_BAGS_ENABLE = '啟用鼠標位於屏幕右下角顯示背包欄'
L_OPT_BARS_EXP_ENABLE = '啟用經驗/聲望條'
L_OPT_BARS_EXP_AUTOSWITCH = '啟用自動切換聲望進度'
L_OPT_BARS_EXP_DISABLE_AT_MAX_LVL = '玩家滿級後禁用經驗/聲望條'
L_OPT_BARS_ARTIFACT_ENABLE = '啟用神器能量條'
L_OPT_BARS_ARTIFACT_ONLY_AT_MAX_LEVEL = '僅在玩家滿級後顯示神器能量條'

L_OPT_MAP_MINIMAP_ENABLE = '啟用小地圖模塊'
L_OPT_MAP_MINIMAP_AUTOZOOM = '啟用小地圖自動縮放'
L_OPT_MAP_WORLDMAP_ENABLE = '啟用大地圖模塊'
L_OPT_MAP_WORLDMAP_REMOVEFOG = '啟用大地圖移除迷霧選項'
L_OPT_MAP_WORLDMAP_REWARDICON = '啟用大地圖顯示日常任務獎勵類型'

L_OPT_UF_ENABLE = '啟用單位框體模塊'
L_OPT_UF_PORTRAIT3D = '單位框體顯示 3D 頭像 (僅限玩家/目標/小隊/焦點)'
--
L_OPT_UF_PLAYER_COLORHEALTH = '玩家框體按職業著色血條'
L_OPT_UF_PLAYER_CLASSBAR_DIABOLIC = '啟用擴展玩家職業資源條 (連擊點/符文/靈魂碎片/...)'
L_OPT_UF_PLAYER_CLASSBAR_BLIZZARD = '啟用系統內置玩家職業資源條 (連擊點/符文/靈魂碎片/...)'
--
L_OPT_UF_TARGET_COLORHEALTH = '目標框體按職業著色血條'
L_OPT_UF_TARGET_PLAYER_AURA_ONLY = '目標框體僅顯示玩家釋放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_UF_TARGET_SHOW_STEALABLE_BUFFS = '目標框體顯示玩家可偷取 BUFF'
--
L_OPT_UF_FOCUS_PLAYER_AURA_ONLY = '焦點框體僅顯示玩家釋放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_UF_FOCUS_SHOW_STEALABLE_BUFFS = '焦點框體顯示玩家可偷取 BUFF'
--
L_OPT_UF_BOSS_PLAYER_AURA_ONLY = '首領框體僅顯示玩家釋放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_UF_BOSS_SHOW_STEALABLE_BUFFS = '首領框體顯示玩家可偷取 BUFF'
--
L_OPT_UF_PARTY_SHOWPLAYER = '小隊中顯示玩家頭像'
L_OPT_UF_PARTY_SHOWSOLO = '單人時仍顯示小隊頭像'
--
L_OPT_UF_RAID_ENABLE = '啟用團隊框體模塊'
L_OPT_UF_RAID_COLORHEALTH = '團隊框體按職業著色'
L_OPT_UF_RAID_RAIDDEBUFF_ENABLE = '團隊框體顯示團隊 DEBUFF'
L_OPT_UF_RAID_RAIDDEBUFF_ENABLETOOLTIP = '團隊 DEBUFF 顯示鼠標提示信息'
L_OPT_UF_RAID_RAIDDEBUFF_SHOWDEBUFFBORDER = '團隊 DEBUFF 顯示邊框'
L_OPT_UF_RAID_RAIDDEBUFF_FILTERDISPELLABLEDEBUFF = '團隊 DEBUFF 過濾可清除 DEBUFF'

L_OPT_NAMEPLATE_ENABLE = '啟用姓名板模塊'
L_OPT_NAMEPLATE_CLAMP = '始終在屏幕內顯示姓名板'
L_OPT_NAMEPLATE_COMBAT = '僅在戰鬥中顯示'
L_OPT_NAMEPLATE_HEALTH_VALUE = '顯示血量數字'
L_OPT_NAMEPLATE_SHOW_CASTBAR_NAME = '顯示正在施放技能名稱'
L_OPT_NAMEPLATE_ENHANCE_THREAT = '按仇恨著色 (坦克仇恨正常為綠色, 不正常為紅色)'
L_OPT_NAMEPLATE_CLASS_ICONS = '顯示玩家職業圖標'
L_OPT_NAMEPLATE_TOTEM_ICONS = '顯示圖騰圖標'
L_OPT_NAMEPLATE_NAME_ABBREV = '自動截斷姓名'
L_OPT_NAMEPLATE_TRACK_DEBUFFS = '開啟 DEBUFF 監視'
L_OPT_NAMEPLATE_TRACK_BUFFS = '開啟 BUFF 監視'
L_OPT_NAMEPLATE_PLAYER_AURA_ONLY = '僅顯示玩家釋放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_NAMEPLATE_SHOW_STEALABLE_BUFFS = '顯示玩家可偷取 BUFF'
L_OPT_NAMEPLATE_SHOW_TIMERS = 'DEBUFF/BUFF 顯示冷卻計時數字'
L_OPT_NAMEPLATE_SHOW_SPIRAL = 'DEBUFF/BUFF 顯示冷卻計時旋渦'
L_OPT_NAMEPLATE_ARROW = '顯示當前目標指示箭頭'
L_OPT_NAMEPLATE_HEALER_ICON = '戰場/競技場中顯示治療角色標識'
L_OPT_NAMEPLATE_QUEST = '顯示任務信息'

L_OPT_AURA_ENABLE = '啟用 BUFF/DEBUFF 模塊'
L_OPT_AURA_SHOW_CASTER = '顯示 BUFF/DEBUFF 釋放者信息'
L_OPT_AURA_ENABLE_FLASH = '啟用 BUFF/DEBUFF 倒計時閃爍'
L_OPT_AURA_ENABLE_ANIMATION = '啟用 BUFF/DEBUFF 動畫效果'
L_OPT_AURA_AURAWATCH_ENABLE = '啟用法術技能監視'
L_OPT_AURA_AURAWATCH_CLICKTHROUGH = '法術技能監視禁用鼠標提示'
L_OPT_AURA_AURAWATCH_QUAKERING = '震蕩時播放提示音'

L_OPT_ANNOUNCEMENT_INTERRUPT_ENABLE = '啟用目標施法打斷通報'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL = '通報頻道'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_1 = '說'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_2 = '大喊'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_3 = '表情'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_4 = '小隊'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_5 = '僅團隊'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_6 = '組隊頻道'

L_OPT_LOOT_BAGS_ENABLE = '啟用分類整合背包'
L_OPT_LOOT_LOOT_ENABLE = '啟用拾取窗體美化'
L_OPT_LOOT_FASTER_LOOT = '啟用快速拾取'

L_OPT_DATATEXT_ENABLE = '啟用信息條模塊'
L_OPT_DATATEXT_LATENCY_ENABLE = '啟用網絡時延信息 (左下信息條)'
L_OPT_DATATEXT_MEMORY_ENABLE = '啟用內存占用信息 (左下信息條)'
L_OPT_DATATEXT_FPS_ENABLE = '啟用畫面幀數信息 (左下信息條)'
L_OPT_DATATEXT_FRIENDS_ENABLE = '啟用在線好友信息 (左下信息條)'
L_OPT_DATATEXT_GUILD_ENABLE = '啟用在線工會信息 (左下信息條)'
L_OPT_DATATEXT_LOCATION_ENABLE = '啟用當前位置信息 (小地圖下方信息條)'
L_OPT_DATATEXT_COORDS_ENABLE = '啟用當前坐標信息 (小地圖下方信息條)'
L_OPT_DATATEXT_DURABILITY_ENABLE = '啟用裝備耐久度信息 (右下信息條)'
L_OPT_DATATEXT_BAGS_ENABLE = '啟用背包信息 (右下信息條)'
L_OPT_DATATEXT_GOLD_ENABLE = '啟用資金及物資信息 (右下信息條)'

L_OPT_QUEST_ENABLE = '啟用任務追蹤美化'
L_OPT_QUEST_AUTO_COLLAPSE = '副本中自動隱藏任務追蹤'
L_OPT_QUEST_AUTO_BUTTON = '啟用任務/道具自動按鈕'

L_OPT_TOOLTIP_ENABLE = '啟用提示信息框模塊'
L_OPT_TOOLTIP_CURSOR = '提示信息跟隨鼠標 (默認顯示界面右下角)'
L_OPT_TOOLTIP_SHIFT_MODIFER = '僅當按下 SHIFT 鍵時顯示提示信息'
L_OPT_TOOLTIP_HIDE_COMBAT = '戰鬥中隱藏提示信息'
L_OPT_TOOLTIP_HIDEFORACTIONBAR = '隱藏動作條提示信息'
L_OPT_TOOLTIP_HEALTH_VALUE = '顯示血量數字'
L_OPT_TOOLTIP_TARGET = '顯示目標'
L_OPT_TOOLTIP_TITLE = '顯示頭銜'
L_OPT_TOOLTIP_REALM = '顯示所在服務器'
L_OPT_TOOLTIP_RANK = '顯示工會頭銜'
L_OPT_TOOLTIP_RAID_ICON = '顯示 RAID 圖標'
L_OPT_TOOLTIP_WHO_TARGETTING = '顯示關註成員(在隊伍/團隊中誰以目標為目標)'
L_OPT_TOOLTIP_ACHIEVEMENTS = '啟用成就比較'
L_OPT_TOOLTIP_ITEM_TRANSMOGRIFY = '顯示裝備幻化信息'
L_OPT_TOOLTIP_INSTANCE_LOCK = '顯示副本信息'
L_OPT_TOOLTIP_ITEM_COUNT = '顯示物品數量'
L_OPT_TOOLTIP_ITEM_ICON = '顯示物品圖標'
L_OPT_TOOLTIP_AVERAGE_LVL = '顯示平均裝備等級'
L_OPT_TOOLTIP_ARENA_EXPERIENCE = '顯示競技場等級'
L_OPT_TOOLTIP_SPELL_ID = '顯示法術 ID'
L_OPT_TOOLTIP_TALENTS = '顯示天賦'
L_OPT_TOOLTIP_MOUNT = '顯示坐騎來源'
L_OPT_TOOLTIP_UNIT_ROLE = '顯示團隊/隊伍職責'

L_OPT_CHAT_ENABLE = '啟用聊天框模塊'
L_OPT_CHAT_BACKGROUND = '聊天框顯示背景'
L_OPT_CHAT_FILTER = '屏蔽無用系統信息 (如 暫離/喝醉/決鬥勝利 等)'
L_OPT_CHAT_SPAM = '屏蔽玩家發送垃圾信息'
L_OPT_CHAT_AUTO_WIDTH = '聊天框自動適配屏幕寬度'
L_OPT_CHAT_CHAT_BAR = '啟用快捷頻道切換按鈕 (鼠標左右鍵點擊切換不同頻道)'
L_OPT_CHAT_CHAT_BAR_MOUSEOVER = '快捷頻道鼠標懸停時顯示'
L_OPT_CHAT_CHAT_WHISP_SOUND = '接受密語時聲音提示'
L_OPT_CHAT_CHAT_ALT_INVITE = 'ALT 點擊玩家快速邀請組隊'
L_OPT_CHAT_CHAT_BUBBLES = '美化聊天泡泡'
L_OPT_CHAT_CHAT_COMBATLOG = '顯示戰鬥記錄切換標簽'
L_OPT_CHAT_CHAT_TABS_MOUSEOVER = '鼠標懸停顯示頻道標簽'
L_OPT_CHAT_CHAT_STICKY = '記住上一次使用的頻道'
L_OPT_CHAT_LOOT_ICONS = '聊天框顯示拾取物品圖標'
L_OPT_CHAT_ROLE_ICONS = '聊天框顯示團隊/小隊成員角色'

L_OPT_COMBAT_COMBATTEXT_ENABLE = "啟用戰鬥文字輸出模塊 (基於xCT)"
L_OPT_COMBAT_COMBATTEXT_BLIZZ_HEAD_NUMBERS = "啟用暴雪默認戰鬥信息"
L_OPT_COMBAT_COMBATTEXT_DAMAGE_STYLE = "改變模型頂部/玩家頭像的傷害/治療字體 (需要重啟遊戲客戶端)"
L_OPT_COMBAT_COMBATTEXT_DAMAGE = "獨立顯示傷害輸出"
L_OPT_COMBAT_COMBATTEXT_HEALING = "獨立顯示治療輸出"
L_OPT_COMBAT_COMBATTEXT_SHOW_HOTS = "顯示 HOT 造成的治療"
L_OPT_COMBAT_COMBATTEXT_SHOW_OVERHEALING = "顯示過量治療輸出"
L_OPT_COMBAT_COMBATTEXT_INCOMING = "浮动顯示受到的傷害和治療"
L_OPT_COMBAT_COMBATTEXT_PET_DAMAGE = "顯示寵物傷害輸出"
L_OPT_COMBAT_COMBATTEXT_DOT_DAMAGE = "顯示DOT造成的傷害"
L_OPT_COMBAT_COMBATTEXT_DAMAGE_COLOR = "傷害文字按法術類型著色"
L_OPT_COMBAT_COMBATTEXT_CRIT_PREFIX = "啟用暴擊時文本左側修飾符號 (默認為 *)"
L_OPT_COMBAT_COMBATTEXT_CRIT_POSTFIX = "啟用暴擊時文本右側修飾符號 (默認為 *)"
L_OPT_COMBAT_COMBATTEXT_ICONS = "顯示傷害輸出技能圖標"
L_OPT_COMBAT_COMBATTEXT_SCROLLABLE = "允許使用鼠標滾輪滾動區域"
L_OPT_COMBAT_COMBATTEXT_DK_RUNES = "顯示死亡騎士符文恢復"
L_OPT_COMBAT_COMBATTEXT_KILLINGBLOW = "顯示擊殺信息"
L_OPT_COMBAT_COMBATTEXT_MERGE_AOE_SPAM = "將AOE傷害合並為一條信息"
L_OPT_COMBAT_COMBATTEXT_MERGE_MELEE = "將多個自動攻擊傷害合並為一條信息"
L_OPT_COMBAT_COMBATTEXT_DISPEL = "當你驅散成功時提示"
L_OPT_COMBAT_COMBATTEXT_INTERRUPT = "當你打斷成功時提示"
L_OPT_COMBAT_COMBATTEXT_DIRECTION = "滾動方向從下向上"
L_OPT_COMBAT_COMBATTEXT_SHORT_NUMBERS = "精簡數字按單位顯示"
--
L_OPT_COMBAT_DAMAGEMETER_ENABLE = '啟用輕量級傷害/治療統計 (基於 DamageMeter)'
L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORBAR = '職業著色計量條'
L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORNAME = '職業著色姓名'
L_OPT_COMBAT_DAMAGEMETER_ONLYBOSS = '僅保存BOSS戰鬥信息'
L_OPT_COMBAT_DAMAGEMETER_MERGEHEALABSORBS = '合並治療與吸收'

L_OPT_MISC_BLIZZARD_SLOT_DURABILITY = '人物面板顯示裝備耐久度'
L_OPT_MISC_BLIZZARD_SHIFT_MARK = '開啟 SHIFT 快速標記'
L_OPT_MISC_MISC_SOCIALTABS = '社交面板顯示快速切換標簽'
L_OPT_MISC_PROFESSION_TABS = '技能面板顯示快速切換標簽'
L_OPT_MISC_MERCHANT_ITEMLEVEL = '交易面板顯示物品等級'
L_OPT_MISC_SLOT_ITEMLEVEL = '人物觀察面板顯示物品等級'
L_OPT_MISC_TRAIN_ALL = '開啟技能一鍵學習'
L_OPT_MISC_ALREADY_KNOWN = '開啟已學習技能物品著色'
L_OPT_MISC_LFG_QUEUE_TIMER = '開啟自動組隊時間倒計時 (BigWigs/DBM 啟用時自動停用)'
L_OPT_MISC_ALT_BUY_STACK = '按住 ALT 鍵批量購買'
L_OPT_MISC_RAID_UTILITY = '開啟團隊管理工具'
--
L_OPT_MISC_AUTOMATION_ACCEPT_INVITE = '自動接收來自好友/工會的組隊邀請'
L_OPT_MISC_AUTOMATION_AUTO_ROLE = '自動設置在隊伍/團隊中的職責'
L_OPT_MISC_AUTOMATION_AUTO_RELEASE = '在戰場中死亡時自動釋放'
L_OPT_MISC_AUTOMATION_DECLINE_DUEL = '自動拒絕決鬥邀請'
L_OPT_MISC_AUTOMATION_AUTO_REPAIR = '自動修理裝備'
L_OPT_MISC_AUTOMATION_AUTO_SELL = '自動出售垃圾'
L_OPT_MISC_AUTOMATION_AUTO_CONFIRM_DE = '裝備 Roll 點時選擇分解物品不彈出提示信息'
L_OPT_MISC_AUTOMATION_AUTO_GREED = '滿級後綠色裝備 Roll 點時自動選擇\'貪婪\''
L_OPT_MISC_AUTOMATION_AUTO_QUEST = '自動交接任務 (按住 SHIFT 點擊 NPC 可禁用)'
L_OPT_MISC_AUTOMATION_TAB_BINDER = 'PVP 模式下優化目標選擇鍵(默認 TAB)只選中敵對玩家'

L_OPT_COMMAND_HVB = '鼠標懸停動作條按鈕綁定快捷鍵 (不支持 DarkUI 擴展按鈕)'
L_OPT_COMMAND_XCT = '移動/鎖定戰鬥文字輸出位置 (僅當功能開啟時可用)'
L_OPT_COMMAND_DMG = '移動/鎖定輕量級傷害/治療統計位置 (僅當功能開啟時可用)'
L_OPT_COMMAND_AW = '移動/鎖定法術技能監視位置 (僅當功能開啟時可用)'
L_OPT_COMMAND_RC = '就位確認'
L_OPT_COMMAND_GM = '呼叫遊戲內 GM'
L_OPT_COMMAND_RL = '立即重載插件'
L_OPT_COMMAND_RESETUI = '重置 DarkUI 配置為默認值'
L_OPT_COMMAND_FRAME = '顯示當前鼠標懸停或指定 <name> 名稱的窗體信息'
L_OPT_COMMAND_ALIGN = '顯示窗體布局位置輔助定位線'
L_OPT_COMMAND_TESTUI = '移動/鎖定單位窗體位置 (僅當功能開啟時可用, 未完成)'
L_OPT_COMMAND_TESTROLL = '移動/鎖定物品擲骰窗體位置 (僅當拾取功能開啟時可用, 未完成)'

L_TIPS = '小提示'
L_GLOBAL_OPTION = '使用全局設置 (對當前賬號下全部角色有效)'
L_RESET = '重置'
L_POPUP_CONFIRM_RELOAD = '此操作需要重載 UI，請確認是否立即執行.'