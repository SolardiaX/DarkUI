local E, C, L, M = select(2, ...):unpack()

if E.client ~= "zhCN" then return end

L.ValueFormat = function(value)
	if value >= 1e12 then
		return format("%.2f兆", value / 1e12)
	elseif value >= 1e8 then
		return format("%.2f亿", value / 1e8)
	elseif value >= 1e4 then
		return format("%.1f万", value / 1e4)
	else
		return format("%.0f", value)
	end
end

L.WELCOME_LINE                       = "欢迎使用 DarkUI "
L.POPUP_INSTALLUI                    = "该角色首次使用 DarkUI. 你必须重新加载UI来配置."
L.POPUP_RESETUI                      = "此操作将重置 DarkUI 的全部配置为默认参数."

L.MAP_REMOVEFOG                      = "地图全亮"
L.MAP_MOUSEOVER                      = "鼠标"
L.MAP_HIDE_TASK_POI                  = "隐藏任务地点标记"
L.MAP_PLAYER                         = "玩家"
L.MAP_BOUNDS                         = "超出范围"

L.AURA_CAST_BY                       = "来自"
L.AURA_GET_OUT                       = "离开人群"
L.AURA_GET_CLOSE                     = "贴近目标"
L.AURA_CRIT                          = "爆击"
L.AURA_HASTE                         = "急速"
L.AURA_MASTERY                       = "精通"
L.AURA_VERSA                         = "全能"
L.AURA_FREEZE                        = "别动"
L.AURA_MOVE                          = "移动"
L.AURA_COMBO                         = "连击"
L.AURA_ATTACKSPEED                   = "攻速"
L.AURA_CD                            = "冷却"
L.AURA_STRIKE                        = "影袭"
L.AURA_POWER                         = "能量"

L.UNITFRAME_DEAD                     = "死亡"
L.UNITFRAME_GHOST                    = "灵魂"
L.UNITFRAME_OFFLINE                  = "离线"
L.UNITFRAME_AFK                      = "[AFK]"
L.UNITFRAME_DND                      = "[DND]"

L.TOOLTIP_NO_TALENT                  = "没有天赋"
L.TOOLTIP_LOADING                    = "读取中..."
L.TOOLTIP_ACH_STATUS                 = "你的状态:"
L.TOOLTIP_ACH_COMPLETE               = "你的状态: 完成 "
L.TOOLTIP_ACH_INCOMPLETE             = "你的状态: 未完成"
L.TOOLTIP_SPELL_ID                   = "法术ID:"
L.TOOLTIP_ITEM_ID                    = "物品ID:"
L.TOOLTIP_WHO_TARGET                 = "关注"
L.TOOLTIP_ITEM_COUNT                 = "物品数量:"
L.TOOLTIP_INSPECT_OPEN               = "检查框体已打开"

L.ACTIONBAR_BINDING_INCOMBATLOCKDOWN = "不能在战斗状态下设置按键绑定"
L.ACTIONBAR_BINDING_TRIGGER          = "触发"
L.ACTIONBAR_BINDING_NOBINDING        = "未设置任何按键绑定"
L.ACTIONBAR_BINDING_BINDING          = "按键绑定"
L.ACTIONBAR_BINDING_KEY              = "按键"
L.ACTIONBAR_BINDING_ALLCLEAR         = "|cff00ff00%s|r 所有按键绑定已清除"
L.ACTIONBAR_BINDING_BINDTO           = "|cff00ff00 %s 按键已绑定到 %s |r"
L.ACTIONBAR_BINDING_SAVE             = "所有按键绑定已保存"
L.ACTIONBAR_BINDING_DISCARDED        = "按键绑定变动已还原"
L.ACTIONBAR_BINDING_MODETEXT         = "鼠标悬停动作条按钮按下按键后进行绑定，按 ESCAPE 或 鼠标右键 取消当前绑定"
L.ACTIONBAR_BINDING_SAVEBTN          = "确认"
L.ACTIONBAR_BINDING_DISCARDEBTN      = "取消"
L.ACTIONBAR_EXP_REP					 = "经验/声望"
L.ACTIONBAR_REP                      = "声望"
L.ACTIONBAR_EXP                      = "经验"
L.ACTIONBAR_PARAGON_EXP              = "巅峰声望"
L.ACTIONBAR_APB                      = "神器"
L.ACTIONBAR_AP_NAME                  = "装备"
L.ACTIONBAR_AP_TOTAL                 = "总量/等级"
L.ACTIONBAR_AP_UPGRADE               = "升级"

L.CHAT_WHISPER                       = "来自"
L.CHAT_BN_WHISPER                    = "来自"
L.CHAT_AFK                           = "[AFK]"
L.CHAT_DND                           = "[DND]"
L.CHAT_GM                            = "[GM]"
L.CHAT_GUILD                         = "公会"
L.CHAT_PARTY                         = "小队"
L.CHAT_PARTY_LEADER                  = "队长"
L.CHAT_RAID                          = "团队"
L.CHAT_RAID_LEADER                   = "团长"
L.CHAT_RAID_WARNING                  = "团队警告"
L.CHAT_INSTANCE_CHAT                 = "副本"
L.CHAT_INSTANCE_CHAT_LEADER          = "副本领袖"
L.CHAT_OFFICER                       = "官员"
L.CHAT_PET_BATTLE                    = "宠物对战"
L.CHAT_COME_ONLINE                   = "|cff298F00上线了|r。"
L.CHAT_GONE_OFFLINE                  = "|cffff0000下线了|r。"
L.CHAT_INTERRUPTED                   = "打断施法: %s - \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r！"

L.LOOT_RANDOM                        = "随机拾取"
L.LOOT_SELF                          = "自由拾取"
L.LOOT_FISH                          = "钓鱼拾取"
L.LOOT_MONSTER                       = ">> 拾取自 "
L.LOOT_CHEST                         = ">> 拾取自宝箱"
L.LOOT_ANNOUNCE                      = "向频道通告"
L.LOOT_TO_RAID                       = "  团队"
L.LOOT_TO_PARTY                      = "  队伍"
L.LOOT_TO_GUILD                      = "  公会"
L.LOOT_TO_SAY                        = "  说"

L.AUTO_INVITE_KEYWORD                = '邀请'
L.AUTO_INVITE_INFO                   = '接受邀请: '
L.AUTO_DECLINE_DUEL_INFO             = '拒绝决斗请求: '
L.AUTO_DECLINE_DUEL_PET_INFO         = '拒绝宠物决斗请求: '
L.AUTO_REPAIR_GUIDE_INFO             = '修理装备花费了公费: '
L.AUTO_REPAIR_INFO                   = '修理装备花费了现金: '
L.AUTO_REPAIR_NOTENOUGH_INFO         = '没有足够的现金以完成修理!'
L.AUTO_SELL_INFO                     = '出售垃圾收入: '

-- Combat text
L.COMBATTEXT_KILLING_BLOW            = "最后一击"
L.COMBATTEXT_ALREADY_UNLOCKED        = "战斗信息已解锁."
L.COMBATTEXT_ALREADY_LOCKED          = "战斗信息已锁定."
L.COMBATTEXT_TEST_DISABLED           = "战斗信息测试模式已禁用."
L.COMBATTEXT_TEST_ENABLED            = "战斗信息测试模式已启用."
L.COMBATTEXT_TEST_USE_UNLOCK         = "输入 /xct unlock 移动/调整战斗信息框架."
L.COMBATTEXT_TEST_USE_LOCK           = "输入 /xct lock 锁定战斗信息框架."
L.COMBATTEXT_TEST_USE_TEST           = "输入 /xct test 启用/禁用战斗信息测试模式."
L.COMBATTEXT_TEST_USE_RESET          = "输入 /xct reset 恢复默认位置."
L.COMBATTEXT_POPUP                   = "保存战斗信息窗口的位置须重载插件."
L.COMBATTEXT_UNSAVED                 = "战斗信息窗口位置尚未保存,不要忘记重新载入插件."
L.COMBATTEXT_UNLOCKED                = "战斗信息已解锁."

L.DAMAGEMETER_CURRENT                			 = "当前"
L.DAMAGEMETER_TOTAL                  			 = "总计"
L.DAMAGEMETER_OPTION_VISIBLE_BARS                = "计量条显示数量"
L.DAMAGEMETER_OPTION_BAR_WIDTH                   = "计量条宽度"
L.DAMAGEMETER_OPTION_BAR_HEIGHT                  = "计量条高度"
L.DAMAGEMETER_OPTION_SPACING                     = "计量条间距"
L.DAMAGEMETER_OPTION_FONT_SIZE                   = "字体大小"
L.DAMAGEMETER_OPTION_HIDE_TITLE                  = "隐藏标题"
L.DAMAGEMETER_OPTION_CLASS_COLOR_BAR             = "职业着色计量条"
L.DAMAGEMETER_OPTION_CLASS_COLOR_NAME            = "职业着色姓名"
L.DAMAGEMETER_OPTION_SAVE_ONLY_BOSS_FIGHTS       = "仅保存BOSS战斗信息"
L.DAMAGEMETER_OPTION_MERGE_HEAL_AND_ABSORBS      = "合并治疗与吸收"
L.DAMAGEMETER_OPTION_BAR_COLOR                   = "计量条颜色"
L.DAMAGEMETER_OPTION_BACKDROP_COLOR              = "背景颜色"
L.DAMAGEMETER_OPTION_BORDER_COLOR                = "边框颜色"

L.MAIL_MESSAGES                      = "新邮件"
L.MAIL_NEEDMAILBOX                   = "需要邮箱"
L.MAIL_NOMAIL                        = "无邮件"
L.MAIL_COMPLETE                      = "全部已读"
L.MAIL_ENVFULL                       = "背包已满"
L.MAIL_MAXCOUNT                      = "物品已达最大堆叠限制"

L.PANELS_AFK                         = "你处于暂离状态!"
L.PANELS_AFK_RCLICK                  = "右键点击隐藏."
L.PANELS_AFK_LCLICK                  = "左键点击返回."

L.DATATEXT_DAY                       = "天"
L.DATATEXT_HOUR                      = "小时"
L.DATATEXT_MINUTE                    = "分"
L.DATATEXT_SECOND                    = "秒"
L.DATATEXT_MILLISECOND               = "毫秒"
L.DATATEXT_ONLINE                    = "在线: "
L.DATATEXT_FRIEND                    = "好友: "
L.DATATEXT_GUILD                     = "工会: "
L.DATATEXT_BAG                       = "背包: "
L.DATATEXT_DURABILITY                = "耐久: "
L.DATATEXT_AUTO_REPAIR               = "自动修装"
L.DATATEXT_AUTO_SELL                 = "自动出售灰色物品"
L.DATATEXT_ON                        = "启用"
L.DATATEXT_OFF                       = "禁用"
L.DATATEXT_HIDDEN                    = "隐藏"
L.DATATEXT_BANDWIDTH                 = "宽带占用:"
L.DATATEXT_DOWNLOAD                  = "下载:"
L.DATATEXT_MEMORY_USAGE              = "插件内存占用:"
L.DATATEXT_TOTAL_MEMORY_USAGE        = "总内存:"
L.DATATEXT_TOTAL_CPU_USAGE           = "总CPU使用率:"
L.DATATEXT_GARBAGE_COLLECTED         = "整理内存"
L.DATATEXT_CURRENCY_RAID             = "副本徽记"
L.DATATEXT_SERVER_GOLD               = "帐号总现金"
L.DATATEXT_SESSION_GAIN              = "此次在线时段获得/损失金额"
L.DATATEXT_SORTING_BY                = "排列方式: "

L.MISC_BUY_STACK                     = "Alt+右键批量购买"

L.BAG_RESETCATEGORY                  = "重置分类"
L.BAG_BAGCAPTIONS_STUFF              = "材料"
L.BAG_BAGCAPTIONS_NEWITEMS           = "新增"
L.BAG_CLICK_TO_SETCATEGORY           = "Ctrl + Alt 右键物品进行分类"
L.BAG_HINT_TOGGLE                    = "显示/隐藏背包栏"
L.BAG_HINT_RESET_NEW                 = "分类新增物品"
L.BAG_RESTACK                        = "堆叠物品"
