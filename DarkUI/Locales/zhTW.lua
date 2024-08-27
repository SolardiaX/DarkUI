local E, C, L = select(2, ...):unpack()

if E.locale ~= "zhTW" then return end

L.ValueFormat = function(value)
    if value >= 1e12 then
        return format("%.2f兆", value / 1e12)
    elseif value >= 1e8 then
        return format("%.2f億", value / 1e8)
    elseif value >= 1e4 then
        return format("%.1f萬", value / 1e4)
    else
        return format("%.0f", value)
    end
end

L.WELCOME_LINE                                   = "歡迎使用 DarkUI "
L.POPUP_INSTALLUI                                = "該角色首次使用 DarkUI. 你必須重新加載UI來配置."
L.POPUP_RESETUI                                  = "此操作將重置 DarkUI 的全部配置為默認參數."

L.MAP_REMOVEFOG                                  = "地圖全亮"
L.MAP_MOUSEOVER                                  = "鼠標"
L.MAP_HIDE_TASK_POI                              = "隱藏任務地點標記"
L.MAP_PLAYER                                     = "玩家"
L.MAP_BOUNDS                                     = "超出範圍"
L.MINIMAP_SWITCHGARRISONTYPE                     = "右鍵點擊切換顯示"

L.AURA_CAST_BY                                   = "來自"
L.AURA_GET_OUT                                   = "離開人群"
L.AURA_GET_CLOSE                                 = "貼近目標"
L.AURA_CRIT                                      = "爆擊"
L.AURA_HASTE                                     = "急速"
L.AURA_MASTERY                                   = "精通"
L.AURA_VERSA                                     = "全能"
L.AURA_FREEZE                                    = "別動"
L.AURA_MOVE                                      = "移動"
L.AURA_COMBO                                     = "連擊"
L.AURA_ATTACKSPEED                               = "攻速"
L.AURA_CD                                        = "冷卻"
L.AURA_STRIKE                                    = "影襲"
L.AURA_POWER                                     = "能量"

L.UNITFRAME_DEAD                                 = "死亡"
L.UNITFRAME_GHOST                                = "靈魂"
L.UNITFRAME_OFFLINE                              = "離線"
L.UNITFRAME_AFK                                  = "[AFK]"
L.UNITFRAME_DND                                  = "[DND]"

L.TOOLTIP_NO_TALENT                              = "沒有天賦"
L.TOOLTIP_LOADING                                = "讀取中..."
L.TOOLTIP_ACH_STATUS                             = "你的狀態:"
L.TOOLTIP_ACH_COMPLETE                           = "你的狀態: 完成 "
L.TOOLTIP_ACH_INCOMPLETE                         = "你的狀態: 未完成"
L.TOOLTIP_SPELL_ID                               = "法術ID:"
L.TOOLTIP_ITEM_ID                                = "物品ID:"
L.TOOLTIP_WHO_TARGET                             = "關註"
L.TOOLTIP_ITEM_COUNT                             = "物品數量:"
L.TOOLTIP_INSPECT_OPEN                           = "檢查框體已打開"

L.ACTIONBAR_BINDING_INCOMBATLOCKDOWN             = "不能在戰鬥狀態下設置按鍵綁定"
L.ACTIONBAR_BINDING_TRIGGER                      = "觸發"
L.ACTIONBAR_BINDING_NOBINDING                    = "未設置任何按鍵綁定"
L.ACTIONBAR_BINDING_BINDING                      = "按鍵綁定"
L.ACTIONBAR_BINDING_KEY                          = "按鍵"
L.ACTIONBAR_BINDING_ALLCLEAR                     = "|cff00ff00%s|r 所有按鍵綁定已清除"
L.ACTIONBAR_BINDING_BINDTO                       = "|cff00ff00 %s 按鍵已綁定到 %s |r"
L.ACTIONBAR_BINDING_SAVE                         = "所有按鍵綁定已保存"
L.ACTIONBAR_BINDING_DISCARDED                    = "按鍵綁定變動已還原"
L.ACTIONBAR_BINDING_MODETEXT                     = "鼠標懸停動作條按鈕按下按鍵後進行綁定，按 ESCAPE 或 鼠標右鍵 取消當前綁定"
L.ACTIONBAR_BINDING_SAVEBTN                      = "確認"
L.ACTIONBAR_BINDING_DISCARDEBTN                  = "取消"
L.ACTIONBAR_EXP_REP                              = "經驗/聲望"
L.ACTIONBAR_REP                                  = "聲望"
L.ACTIONBAR_EXP                                  = "經驗"
L.ACTIONBAR_PARAGON_EXP                          = "巔峰聲望"
L.ACTIONBAR_APB                                  = "神器"
L.ACTIONBAR_AP_NAME                              = "裝備"
L.ACTIONBAR_AP_TOTAL                             = "總量/等級"
L.ACTIONBAR_AP_UPGRADE                           = "升級"

L.CHAT_WHISPER                                   = "來自"
L.CHAT_BN_WHISPER                                = "來自"
L.CHAT_AFK                                       = "[AFK]"
L.CHAT_DND                                       = "[DND]"
L.CHAT_GM                                        = "[GM]"
L.CHAT_GUILD                                     = "公會"
L.CHAT_PARTY                                     = "小隊"
L.CHAT_PARTY_LEADER                              = "隊長"
L.CHAT_RAID                                      = "團隊"
L.CHAT_RAID_LEADER                               = "團長"
L.CHAT_RAID_WARNING                              = "團隊警告"
L.CHAT_INSTANCE_CHAT                             = "副本"
L.CHAT_INSTANCE_CHAT_LEADER                      = "副本領袖"
L.CHAT_OFFICER                                   = "官員"
L.CHAT_PET_BATTLE                                = "寵物對戰"
L.CHAT_COME_ONLINE                               = "|cff298F00上線了|r。"
L.CHAT_GONE_OFFLINE                              = "|cffff0000下線了|r。"
L.CHAT_INTERRUPTED                               = "打斷施法: %s - \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r！"

L.LOOT_RANDOM                                    = "隨機拾取"
L.LOOT_SELF                                      = "自由拾取"
L.LOOT_FISH                                      = "釣魚拾取"
L.LOOT_MONSTER                                   = ">> 拾取自 "
L.LOOT_CHEST                                     = ">> 拾取自寶箱"
L.LOOT_ANNOUNCE                                  = "向頻道通告"
L.LOOT_TO_RAID                                   = "  團隊"
L.LOOT_TO_PARTY                                  = "  隊伍"
L.LOOT_TO_GUILD                                  = "  公會"
L.LOOT_TO_SAY                                    = "  說"

L.AUTO_INVITE_KEYWORD                            = '邀請'
L.AUTO_INVITE_INFO                               = '接受邀請: '
L.AUTO_DECLINE_DUEL_INFO                         = '拒絕決鬥請求: '
L.AUTO_DECLINE_DUEL_PET_INFO                     = '拒絕寵物決鬥請求: '
L.AUTO_REPAIR_GUIDE_INFO                         = '修理裝備花費了公費: '
L.AUTO_REPAIR_INFO                               = '修理裝備花費了現金: '
L.AUTO_REPAIR_NOTENOUGH_INFO                     = '沒有足夠的現金以完成修理!'
L.AUTO_SELL_INFO                                 = '出售垃圾收入: '

-- Combat text
L.COMBATTEXT_ALREADY_UNLOCKED                    = "戰鬥信息已解鎖."
L.COMBATTEXT_ALREADY_LOCKED                      = "戰鬥信息已鎖定."
L.COMBATTEXT_TEST_DISABLED                       = "戰鬥信息測試模式已禁用."
L.COMBATTEXT_TEST_ENABLED                        = "戰鬥信息測試模式已啟用."
L.COMBATTEXT_TEST_USE_UNLOCK                     = "輸入 /xct unlock 移動/調整戰鬥信息框架."
L.COMBATTEXT_TEST_USE_LOCK                       = "輸入 /xct lock 鎖定戰鬥信息框架."
L.COMBATTEXT_TEST_USE_TEST                       = "輸入 /xct test 啟用/禁用戰鬥信息測試模式."
L.COMBATTEXT_TEST_USE_RESET                      = "輸入 /xct reset 恢復默認位置."
L.COMBATTEXT_POPUP                               = "保存戰鬥信息窗口的位置須重載插件."
L.COMBATTEXT_UNSAVED                             = "戰鬥信息窗口位置尚未保存,不要忘記重新載入插件."
L.COMBATTEXT_UNLOCKED                            = "戰鬥信息已解鎖."

L.DAMAGEMETER_CURRENT                            = "當前"
L.DAMAGEMETER_TOTAL                              = "總計"
L.DAMAGEMETER_OPTION_VISIBLE_BARS                = "計量條顯示數量"
L.DAMAGEMETER_OPTION_BAR_WIDTH                   = "計量條寬度"
L.DAMAGEMETER_OPTION_BAR_HEIGHT                  = "計量條高度"
L.DAMAGEMETER_OPTION_SPACING                     = "計量條間距"
L.DAMAGEMETER_OPTION_FONT_SIZE                   = "字體大小"
L.DAMAGEMETER_OPTION_HIDE_TITLE                  = "隱藏標題"
L.DAMAGEMETER_OPTION_CLASS_COLOR_BAR             = "職業著色計量條"
L.DAMAGEMETER_OPTION_CLASS_COLOR_NAME            = "職業著色姓名"
L.DAMAGEMETER_OPTION_SAVE_ONLY_BOSS_FIGHTS       = "僅保存BOSS戰鬥信息"
L.DAMAGEMETER_OPTION_MERGE_HEAL_AND_ABSORBS      = "合並治療與吸收"
L.DAMAGEMETER_OPTION_BAR_COLOR                   = "計量條顏色"
L.DAMAGEMETER_OPTION_BACKDROP_COLOR              = "背景顏色"
L.DAMAGEMETER_OPTION_BORDER_COLOR                = "邊框顏色"

L.MAIL_MESSAGES                                  = "新郵件"
L.MAIL_NEEDMAILBOX                               = "需要郵箱"
L.MAIL_NOMAIL                                    = "無郵件"
L.MAIL_COMPLETE                                  = "全部已讀"
L.MAIL_ENVFULL                                   = "背包已滿"
L.MAIL_MAXCOUNT                                  = "物品已達最大堆疊限制"

L.PANELS_AFK                                     = "你處於暫離狀態!"
L.PANELS_AFK_RCLICK                              = "右鍵點擊隱藏."
L.PANELS_AFK_LCLICK                              = "左鍵點擊返回."

L.DATATEXT_DAY                                   = "天"
L.DATATEXT_HOUR                                  = "小時"
L.DATATEXT_MINUTE                                = "分"
L.DATATEXT_SECOND                                = "秒"
L.DATATEXT_MILLISECOND                           = "毫秒"
L.DATATEXT_ONLINE                                = "在線: "
L.DATATEXT_FRIEND                                = "好友: "
L.DATATEXT_GUILD                                 = "工會: "
L.DATATEXT_BAG                                   = "背包: "
L.DATATEXT_DURABILITY                            = "耐久: "
L.DATATEXT_AUTO_REPAIR                           = "自動修裝"
L.DATATEXT_AUTO_SELL                             = "自動出售灰色物品"
L.DATATEXT_ON                                    = "啟用"
L.DATATEXT_OFF                                   = "禁用"
L.DATATEXT_HIDDEN                                = "隱藏"
L.DATATEXT_BANDWIDTH                             = "寬帶占用:"
L.DATATEXT_DOWNLOAD                              = "下載:"
L.DATATEXT_MEMORY_USAGE                          = "插件內存占用:"
L.DATATEXT_TOTAL_MEMORY_USAGE                    = "總內存:"
L.DATATEXT_TOTAL_CPU_USAGE                       = "總CPU使用率:"
L.DATATEXT_GARBAGE_COLLECTED                     = "整理內存"
L.DATATEXT_CURRENCY_RAID                         = "副本徽記"
L.DATATEXT_SERVER_GOLD                           = "帳號總現金"
L.DATATEXT_SESSION_GAIN                          = "此次在線時段獲得/損失金額"
L.DATATEXT_SORTING_BY                            = "排列方式: "

L.MISC_BUY_STACK                                 = "Alt+右鍵批量購買"
L.MISC_RAID_UTIL_DISBAND                         = "解散團隊"

L.BAG_RESETCATEGORY                              = "重置分類"
L.BAG_BAGCAPTIONS_STUFF                          = "材料"
L.BAG_BAGCAPTIONS_NEWITEMS                       = "新增"
L.BAG_CLICK_TO_SETCATEGORY                       = "Ctrl + Alt 右鍵物品進行分類"
L.BAG_HINT_TOGGLE                                = "顯示/隱藏背包欄"
L.BAG_HINT_RESET_NEW                             = "分類新增物品"
L.BAG_RESTACK                                    = "堆疊物品"
