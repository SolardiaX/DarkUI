
if GetLocale() ~= "zhCN" then return end

L_DARKUI_CONSOLE = 'DarkUI 控制台'

L_CATEGORIES_GENERAL = '通用设置'
L_CATEGORIES_ACTIONBAR = '动作条'
L_CATEGORIES_MAP = '地图'
L_CATEGORIES_UNITFRAME = '单位框体'
L_CATEGORIES_NAMEPLATE = '姓名板'
L_CATEGORIES_AURA = '法术技能'
L_CATEGORIES_LOOT = '物品背包'
L_CATEGORIES_DATATEXT = '信息条'
L_CATEGORIES_QUEST = '任务追踪'
L_CATEGORIES_TOOLTIP = '鼠标提示'
L_CATEGORIES_CHAT = '聊天框'
L_CATEGORIES_COMBAT = '战斗信息'
L_CATEGORIES_MISC = '杂项配置'
L_CATEGORIES_COMMAND = '内置命令'

L_OPT_GENERAL_THEME = '界面风格'
L_OPT_GENERAL_THEME_LITEMODE = '使用 Lite 风格动作条'
L_OPT_GENERAL_BLIZZARD_STYLE = '美化原始窗体'
L_OPT_GENERAL_BLIZZARD_CUSTOM_POSITION = '优化原始窗体布局 (如 成就提示/NPC对话提示/呼吸条 等)'
L_OPT_GENERAL_BLIZZARD_HIDE_MAW_BUFFS = '隐藏副本 Maw Buffs 信息'
L_OPT_GENERAL_AUTOSCALE = '启用自动缩放'
L_OPT_GENERAL_UISCALE = '缩放比例'
L_OPT_GENERAL_LOCALE_VALUEFORMAT = '启用本地化数字单位（需要语言包提供对应支持）'

L_OPT_BARS_ENABLE = '启用动作条模块'
L_OPT_BARS_STYLE_BUTTONS_ENABLE = '启用动作条按钮样式'
L_OPT_BARS_STYLE_BUTTONS_SHOWHOTKEY_ENABLE = '动作条按钮显示绑定热键'
L_OPT_BARS_STYLE_BUTTONS_SHOWMACRONAME_ENABLE = '动作条按钮显示宏名称'
L_OPT_BARS_STYLE_BUTTONS_SHOWSTACKCOUNT_ENABLE = '动作条按钮显示物品堆叠数量'
L_OPT_BARS_STYLE_COOLDOWN_ENABLE = '动作条按钮显示冷却计时'
L_OPT_BARS_STYLE_RANGE_ENABLE = '动作条按钮按施法距离着色'
L_OPT_BARS_TEXTURE_ENABLE = '启用动作条装饰背景'
L_OPT_BARS_MERGEBAR4ANDBAR5 = '合并右侧动作条'
L_OPT_BARS_MICROMENU_ENABLE = '启用鼠标位于屏幕正顶显示菜单栏'
L_OPT_BARS_BAGS_ENABLE = '启用鼠标位于屏幕右下角显示背包栏'
L_OPT_BARS_EXP_ENABLE = '启用经验/声望条'
L_OPT_BARS_EXP_AUTOSWITCH = '启用自动切换声望进度'
L_OPT_BARS_EXP_DISABLE_AT_MAX_LVL = '玩家满级后禁用经验/声望条'
L_OPT_BARS_ARTIFACT_ENABLE = '启用神器能量条'
L_OPT_BARS_ARTIFACT_ONLY_AT_MAX_LEVEL = '仅在玩家满级后显示神器能量条'

L_OPT_MAP_MINIMAP_ENABLE = '启用小地图模块'
L_OPT_MAP_MINIMAP_AUTOZOOM = '启用小地图自动缩放'
L_OPT_MAP_WORLDMAP_ENABLE = '启用大地图模块'
L_OPT_MAP_WORLDMAP_REMOVEFOG = '启用大地图移除迷雾选项'
L_OPT_MAP_WORLDMAP_REWARDICON = '启用大地图显示日常任务奖励类型'

L_OPT_UF_ENABLE = '启用单位框体模块'
L_OPT_UF_PORTRAIT3D = '单位框体显示 3D 头像 (仅限玩家/目标/小队/焦点)'
--
L_OPT_UF_PLAYER_COLORHEALTH = '玩家框体按职业着色血条'
L_OPT_UF_PLAYER_CLASSBAR_DIABOLIC = '启用扩展玩家职业资源条 (连击点/符文/灵魂碎片/...)'
L_OPT_UF_PLAYER_CLASSBAR_BLIZZARD = '启用系统内置玩家职业资源条 (连击点/符文/灵魂碎片/...)'
--
L_OPT_UF_TARGET_COLORHEALTH = '目标框体按职业着色血条'
L_OPT_UF_TARGET_PLAYER_AURA_ONLY = '目标框体仅显示玩家释放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_UF_TARGET_SHOW_STEALABLE_BUFFS = '目标框体显示玩家可偷取 BUFF'
--
L_OPT_UF_FOCUS_PLAYER_AURA_ONLY = '焦点框体仅显示玩家释放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_UF_FOCUS_SHOW_STEALABLE_BUFFS = '焦点框体显示玩家可偷取 BUFF'
--
L_OPT_UF_BOSS_PLAYER_AURA_ONLY = '首领框体仅显示玩家释放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_UF_BOSS_SHOW_STEALABLE_BUFFS = '首领框体显示玩家可偷取 BUFF'
--
L_OPT_UF_PARTY_SHOWPLAYER = '小队中显示玩家头像'
L_OPT_UF_PARTY_SHOWSOLO = '单人时仍显示小队头像'
--
L_OPT_UF_RAID_ENABLE = '启用团队框体模块'
L_OPT_UF_RAID_COLORHEALTH = '团队框体按职业着色'
L_OPT_UF_RAID_RAIDDEBUFF_ENABLE = '团队框体显示团队 DEBUFF'
L_OPT_UF_RAID_RAIDDEBUFF_ENABLETOOLTIP = '团队 DEBUFF 显示鼠标提示信息'
L_OPT_UF_RAID_RAIDDEBUFF_SHOWDEBUFFBORDER = '团队 DEBUFF 显示边框'
L_OPT_UF_RAID_RAIDDEBUFF_FILTERDISPELLABLEDEBUFF = '团队 DEBUFF 过滤可清除 DEBUFF'

L_OPT_NAMEPLATE_ENABLE = '启用姓名板模块'
L_OPT_NAMEPLATE_CLAMP = '始终在屏幕内显示姓名板'
L_OPT_NAMEPLATE_COMBAT = '仅在战斗中显示'
L_OPT_NAMEPLATE_HEALTH_VALUE = '显示血量数字'
L_OPT_NAMEPLATE_SHOW_CASTBAR_NAME = '显示正在施放技能名称'
L_OPT_NAMEPLATE_ENHANCE_THREAT = '按仇恨着色 (坦克仇恨正常为绿色, 不正常为红色)'
L_OPT_NAMEPLATE_CLASS_ICONS = '显示玩家职业图标'
L_OPT_NAMEPLATE_TOTEM_ICONS = '显示图腾图标'
L_OPT_NAMEPLATE_NAME_ABBREV = '自动截断姓名'
L_OPT_NAMEPLATE_TRACK_DEBUFFS = '开启 DEBUFF 监视'
L_OPT_NAMEPLATE_TRACK_BUFFS = '开启 BUFF 监视'
L_OPT_NAMEPLATE_PLAYER_AURA_ONLY = '仅显示玩家释放 BUFF/DEBUFF (包含 BOSS 自身 BUFF)'
L_OPT_NAMEPLATE_SHOW_STEALABLE_BUFFS = '显示玩家可偷取 BUFF'
L_OPT_NAMEPLATE_SHOW_TIMERS = 'DEBUFF/BUFF 显示冷却计时数字'
L_OPT_NAMEPLATE_SHOW_SPIRAL = 'DEBUFF/BUFF 显示冷却计时旋涡'
L_OPT_NAMEPLATE_ARROW = '显示当前目标指示箭头'
L_OPT_NAMEPLATE_HEALER_ICON = '战场/竞技场中显示治疗角色标识'
L_OPT_NAMEPLATE_QUEST = '显示任务信息'

L_OPT_AURA_ENABLE = '启用 BUFF/DEBUFF 模块'
L_OPT_AURA_SHOW_CASTER = '显示 BUFF/DEBUFF 释放者信息'
L_OPT_AURA_ENABLE_FLASH = '启用 BUFF/DEBUFF 倒计时闪烁'
L_OPT_AURA_ENABLE_ANIMATION = '启用 BUFF/DEBUFF 动画效果'
L_OPT_AURA_AURAWATCH_ENABLE = '启用法术技能监视'
L_OPT_AURA_AURAWATCH_CLICKTHROUGH = '法术技能监视禁用鼠标提示'
L_OPT_AURA_AURAWATCH_QUAKERING = '震荡时播放提示音'

L_OPT_ANNOUNCEMENT_INTERRUPT_ENABLE = '启用目标施法打断通报'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL = '通报频道'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_1 = '说'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_2 = '大喊'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_3 = '表情'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_4 = '小队'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_5 = '仅团队'
L_OPT_ANNOUNCEMENT_INTERRUPT_CHANNEL_6 = '组队频道'

L_OPT_LOOT_BAGS_ENABLE = '启用分类整合背包'
L_OPT_LOOT_LOOT_ENABLE = '启用拾取窗体美化'
L_OPT_LOOT_FASTER_LOOT = '启用快速拾取'

L_OPT_DATATEXT_ENABLE = '启用信息条模块'
L_OPT_DATATEXT_LATENCY_ENABLE = '启用网络时延信息 (左下信息条)'
L_OPT_DATATEXT_MEMORY_ENABLE = '启用内存占用信息 (左下信息条)'
L_OPT_DATATEXT_FPS_ENABLE = '启用画面帧数信息 (左下信息条)'
L_OPT_DATATEXT_FRIENDS_ENABLE = '启用在线好友信息 (左下信息条)'
L_OPT_DATATEXT_GUILD_ENABLE = '启用在线工会信息 (左下信息条)'
L_OPT_DATATEXT_LOCATION_ENABLE = '启用当前位置信息 (小地图下方信息条)'
L_OPT_DATATEXT_COORDS_ENABLE = '启用当前坐标信息 (小地图下方信息条)'
L_OPT_DATATEXT_DURABILITY_ENABLE = '启用装备耐久度信息 (右下信息条)'
L_OPT_DATATEXT_BAGS_ENABLE = '启用背包信息 (右下信息条)'
L_OPT_DATATEXT_GOLD_ENABLE = '启用资金及物资信息 (右下信息条)'

L_OPT_QUEST_ENABLE = '启用任务追踪美化'
L_OPT_QUEST_AUTO_COLLAPSE = '副本中自动隐藏任务追踪'
L_OPT_QUEST_AUTO_BUTTON = '启用任务/道具自动按钮'

L_OPT_TOOLTIP_ENABLE = '启用提示信息框模块'
L_OPT_TOOLTIP_CURSOR = '提示信息跟随鼠标 (默认显示界面右下角)'
L_OPT_TOOLTIP_SHIFT_MODIFER = '仅当按下 SHIFT 键时显示提示信息'
L_OPT_TOOLTIP_HIDE_COMBAT = '战斗中隐藏提示信息'
L_OPT_TOOLTIP_HIDEFORACTIONBAR = '隐藏动作条提示信息'
L_OPT_TOOLTIP_HEALTH_VALUE = '显示血量数字'
L_OPT_TOOLTIP_TARGET = '显示目标'
L_OPT_TOOLTIP_TITLE = '显示头衔'
L_OPT_TOOLTIP_REALM = '显示所在服务器'
L_OPT_TOOLTIP_RANK = '显示工会头衔'
L_OPT_TOOLTIP_RAID_ICON = '显示 RAID 图标'
L_OPT_TOOLTIP_WHO_TARGETTING = '显示关注成员(在队伍/团队中谁以目标为目标)'
L_OPT_TOOLTIP_ACHIEVEMENTS = '启用成就比较'
L_OPT_TOOLTIP_ITEM_TRANSMOGRIFY = '显示装备幻化信息'
L_OPT_TOOLTIP_INSTANCE_LOCK = '显示副本信息'
L_OPT_TOOLTIP_ITEM_COUNT = '显示物品数量'
L_OPT_TOOLTIP_ITEM_ICON = '显示物品图标'
L_OPT_TOOLTIP_AVERAGE_LVL = '显示平均装备等级'
L_OPT_TOOLTIP_ARENA_EXPERIENCE = '显示竞技场等级'
L_OPT_TOOLTIP_SPELL_ID = '显示法术 ID'
L_OPT_TOOLTIP_TALENTS = '显示天赋'
L_OPT_TOOLTIP_MOUNT = '显示坐骑来源'
L_OPT_TOOLTIP_UNIT_ROLE = '显示团队/队伍职责'

L_OPT_CHAT_ENABLE = '启用聊天框模块'
L_OPT_CHAT_BACKGROUND = '聊天框显示背景'
L_OPT_CHAT_FILTER = '屏蔽无用系统信息 (如 暂离/喝醉/决斗胜利 等)'
L_OPT_CHAT_SPAM = '屏蔽玩家发送垃圾信息'
L_OPT_CHAT_AUTO_WIDTH = '聊天框自动适配屏幕宽度'
L_OPT_CHAT_CHAT_BAR = '启用快捷频道切换按钮 (鼠标左右键点击切换不同频道)'
L_OPT_CHAT_CHAT_BAR_MOUSEOVER = '快捷频道鼠标悬停时显示'
L_OPT_CHAT_CHAT_WHISP_SOUND = '接受密语时声音提示'
L_OPT_CHAT_CHAT_ALT_INVITE = 'ALT 点击玩家快速邀请组队'
L_OPT_CHAT_CHAT_BUBBLES = '美化聊天泡泡'
L_OPT_CHAT_CHAT_COMBATLOG = '显示战斗记录切换标签'
L_OPT_CHAT_CHAT_TABS_MOUSEOVER = '鼠标悬停显示频道标签'
L_OPT_CHAT_CHAT_STICKY = '记住上一次使用的频道'
L_OPT_CHAT_LOOT_ICONS = '聊天框显示拾取物品图标'
L_OPT_CHAT_ROLE_ICONS = '聊天框显示团队/小队成员角色'

L_OPT_COMBAT_COMBATTEXT_ENABLE = "启用战斗文字输出模块 (基于xCT)"
L_OPT_COMBAT_COMBATTEXT_BLIZZ_HEAD_NUMBERS = "启用暴雪默认战斗信息"
L_OPT_COMBAT_COMBATTEXT_DAMAGE_STYLE = "改变模型顶部/玩家头像的伤害/治疗字体 (需要重启游戏客户端)"
L_OPT_COMBAT_COMBATTEXT_DAMAGE = "独立显示伤害输出"
L_OPT_COMBAT_COMBATTEXT_HEALING = "独立显示治疗输出"
L_OPT_COMBAT_COMBATTEXT_SHOW_HOTS = "显示 HOT 造成的治疗"
L_OPT_COMBAT_COMBATTEXT_SHOW_OVERHEALING = "显示过量治疗输出"
L_OPT_COMBAT_COMBATTEXT_INCOMING = "浮动显示受到的伤害和治疗"
L_OPT_COMBAT_COMBATTEXT_PET_DAMAGE = "显示宠物伤害输出"
L_OPT_COMBAT_COMBATTEXT_DOT_DAMAGE = "显示DOT造成的伤害"
L_OPT_COMBAT_COMBATTEXT_DAMAGE_COLOR = "伤害文字按法术类型著色"
L_OPT_COMBAT_COMBATTEXT_CRIT_PREFIX = "启用暴击时文本左侧修饰符号 (默认为 *)"
L_OPT_COMBAT_COMBATTEXT_CRIT_POSTFIX = "启用暴击时文本右侧修饰符号 (默认为 *)"
L_OPT_COMBAT_COMBATTEXT_ICONS = "显示伤害输出技能图标"
L_OPT_COMBAT_COMBATTEXT_SCROLLABLE = "允许使用鼠标滚轮滚动区域"
L_OPT_COMBAT_COMBATTEXT_DK_RUNES = "显示死亡骑士符文恢复"
L_OPT_COMBAT_COMBATTEXT_KILLINGBLOW = "显示击杀信息"
L_OPT_COMBAT_COMBATTEXT_MERGE_AOE_SPAM = "将AOE伤害合并为一条信息"
L_OPT_COMBAT_COMBATTEXT_MERGE_MELEE = "将多个自动攻击伤害合并为一条信息"
L_OPT_COMBAT_COMBATTEXT_DISPEL = "当你驱散成功时提示"
L_OPT_COMBAT_COMBATTEXT_INTERRUPT = "当你打断成功时提示"
L_OPT_COMBAT_COMBATTEXT_DIRECTION = "滚动方向从下向上"
L_OPT_COMBAT_COMBATTEXT_SHORT_NUMBERS = "精简数字按单位显示"
--
L_OPT_COMBAT_DAMAGEMETER_ENABLE = '启用轻量级伤害/治疗统计 (基于 DamageMeter)'
L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORBAR = '职业着色计量条'
L_OPT_COMBAT_DAMAGEMETER_CLASSCOLORNAME = '职业着色姓名'
L_OPT_COMBAT_DAMAGEMETER_ONLYBOSS = '仅保存BOSS战斗信息'
L_OPT_COMBAT_DAMAGEMETER_MERGEHEALABSORBS = '合并治疗与吸收'

L_OPT_MISC_BLIZZARD_SLOT_DURABILITY = '人物面板显示装备耐久度'
L_OPT_MISC_BLIZZARD_SHIFT_MARK = '开启 SHIFT 快速标记'
L_OPT_MISC_MISC_SOCIALTABS = '社交面板显示快速切换标签'
L_OPT_MISC_PROFESSION_TABS = '技能面板显示快速切换标签'
L_OPT_MISC_MERCHANT_ITEMLEVEL = '交易面板显示物品等级'
L_OPT_MISC_SLOT_ITEMLEVEL = '人物观察面板显示物品等级'
L_OPT_MISC_TRAIN_ALL = '开启技能一键学习'
L_OPT_MISC_ALREADY_KNOWN = '开启已学习技能物品着色'
L_OPT_MISC_LFG_QUEUE_TIMER = '开启自动组队时间倒计时 (BigWigs/DBM 启用时自动停用)'
L_OPT_MISC_ALT_BUY_STACK = '按住 ALT 键批量购买'
L_OPT_MISC_RAID_UTILITY = '开启团队管理工具'
--
L_OPT_MISC_AUTOMATION_ACCEPT_INVITE = '自动接收来自好友/工会的组队邀请'
L_OPT_MISC_AUTOMATION_AUTO_ROLE = '自动设置在队伍/团队中的职责'
L_OPT_MISC_AUTOMATION_AUTO_RELEASE = '在战场中死亡时自动释放'
L_OPT_MISC_AUTOMATION_DECLINE_DUEL = '自动拒绝决斗邀请'
L_OPT_MISC_AUTOMATION_AUTO_REPAIR = '自动修理装备'
L_OPT_MISC_AUTOMATION_AUTO_SELL = '自动出售垃圾'
L_OPT_MISC_AUTOMATION_AUTO_CONFIRM_DE = '装备 Roll 点时选择分解物品不弹出提示信息'
L_OPT_MISC_AUTOMATION_AUTO_GREED = '满级后绿色装备 Roll 点时自动选择\'贪婪\''
L_OPT_MISC_AUTOMATION_AUTO_QUEST = '自动交接任务 (按住 SHIFT 点击 NPC 可禁用)'
L_OPT_MISC_AUTOMATION_TAB_BINDER = 'PVP 模式下优化目标选择键(默认 TAB)只选中敌对玩家'

L_OPT_COMMAND_HVB = '鼠标悬停动作条按钮绑定快捷键 (不支持 DarkUI 扩展按钮)'
L_OPT_COMMAND_XCT = '移动/锁定战斗文字输出位置 (仅当功能开启时可用)'
L_OPT_COMMAND_DMG = '移动/锁定轻量级伤害/治疗统计位置 (仅当功能开启时可用)'
L_OPT_COMMAND_AW = '移动/锁定法术技能监视位置 (仅当功能开启时可用)'
L_OPT_COMMAND_RC = '就位确认'
L_OPT_COMMAND_GM = '呼叫游戏内 GM'
L_OPT_COMMAND_RL = '立即重载插件'
L_OPT_COMMAND_RESETUI = '重置 DarkUI 配置为默认值'
L_OPT_COMMAND_FRAME = '显示当前鼠标悬停或指定 <name> 名称的窗体信息'
L_OPT_COMMAND_ALIGN = '显示窗体布局位置辅助定位线'
L_OPT_COMMAND_TESTUI = '移动/锁定单位窗体位置 (仅当功能开启时可用, 未完成)'
L_OPT_COMMAND_TESTROLL = '移动/锁定物品掷骰窗体位置 (仅当拾取功能开启时可用, 未完成)'

L_TIPS = '小提示'
L_GLOBAL_OPTION = '使用全局设置 (对当前账号下全部角色有效)'
L_RESET = '重置'
L_POPUP_CONFIRM_RELOAD = '此操作需要重载 UI，请确认是否立即执行.'