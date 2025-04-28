--Translation ZamestoTV ver. 1.0.2
local E, C, L = select(2, ...):unpack()

if E.locale ~= "ruRU" then return end

L.ValueFormat = function(value)
    if value >= 1e12 then
        return format("%.2f трлн", value / 1e12)
    elseif value >= 1e9 then
        return format("%.2f млрд", value / 1e9)
    elseif value >= 1e6 then
        return format("%.1f млн", value / 1e6)
    elseif value >= 1e3 then
        return format("%.1f тыс", value / 1e3)
    else
        return format("%.0f", value)
    end
end

L.WELCOME_LINE                                   = "Добро пожаловать в DarkUI "
L.POPUP_INSTALLUI                                = "Вы впервые используете DarkUI. Требуется ПЕРЕЗАГРУЗКА интерфейса для завершения настройки."
L.POPUP_RESETUI                                  = "Сбросит DarkUI до стандартной конфигурации."

L.MAP_REMOVEFOG                                  = "Убрать туман"
L.MAP_MOUSEOVER                                  = "Мышь"
L.MAP_HIDE_TASK_POI                              = "Скрыть точки задач"
L.MAP_PLAYER                                     = "Игрок"
L.MAP_BOUNDS                                     = "За пределами"
L.MINIMAP_SWITCHGARRISONTYPE                     = "Щелкните правой кнопкой мыши для переключения гарнизонов"

L.AURA_CAST_BY                                   = "Наложено"
L.AURA_GET_OUT                                   = "УБИРАЙСЯ"
L.AURA_GET_CLOSE                                 = "ПОДХОДИ БЛИЖЕ"
L.AURA_CRIT                                      = "КРИТ"
L.AURA_HASTE                                     = "СКОРОСТЬ"
L.AURA_MASTERY                                   = "ИСКУСНОСТЬ"
L.AURA_VERSA                                     = "УНИВЕРСАЛЬНОСТЬ"
L.AURA_FREEZE                                    = "ЗАМОРОЗКА"
L.AURA_MOVE                                      = "ДВИЖЕНИЕ"
L.AURA_COMBO                                     = "КОМБО"
L.AURA_ATTACKSPEED                               = "СКОРОСТЬ АТАКИ"
L.AURA_CD                                        = "ПЕРЕЗАРЯДКА"
L.AURA_STRIKE                                    = "УДАР"
L.AURA_POWER                                     = "СИЛА"
L.AURA_SPEED                                     = "СКОРОСТЬ"

L.UNITFRAME_DEAD                                 = "Мертв"
L.UNITFRAME_GHOST                                = "Призрак"
L.UNITFRAME_OFFLINE                              = "Не в сети"
L.UNITFRAME_AFK                                  = "[Отошел]"
L.UNITFRAME_DND                                  = "[Не беспокоить]"

L.TOOLTIP_NO_TALENT                              = "Нет таланта"
L.TOOLTIP_LOADING                                = "Загрузка..."
L.TOOLTIP_ACH_STATUS                             = "Статус:"
L.TOOLTIP_ACH_COMPLETE                           = "Статус: Завершено "
L.TOOLTIP_ACH_INCOMPLETE                         = "Статус: Не завершено"
L.TOOLTIP_SPELL_ID                               = "ID заклинания:"
L.TOOLTIP_ITEM_ID                                = "ID предмета:"
L.TOOLTIP_WHO_TARGET                             = "Цель:"
L.TOOLTIP_ITEM_COUNT                             = "Количество:"
L.TOOLTIP_INSPECT_OPEN                           = "Окно осмотра открыто"

L.ACTIONBAR_BINDING_INCOMBATLOCKDOWN             = "Невозможно настроить привязку клавиш в бою"
L.ACTIONBAR_BINDING_TRIGGER                      = "Триггер"
L.ACTIONBAR_BINDING_NOBINDING                    = "Нет привязки"
L.ACTIONBAR_BINDING_BINDING                      = "Привязка"
L.ACTIONBAR_BINDING_KEY                          = "Клавиша"
L.ACTIONBAR_BINDING_ALLCLEAR                     = "|cff00ff00%s|r Все привязки клавиш очищены"
L.ACTIONBAR_BINDING_BINDTO                       = "|cff00ff00 %s привязано к %s |r"
L.ACTIONBAR_BINDING_SAVE                         = "Все привязки клавиш сохранены"
L.ACTIONBAR_BINDING_DISCARDED                    = "Все новые привязки клавиш отменены"
L.ACTIONBAR_BINDING_MODETEXT                     = "Наведите курсор на любую кнопку действия для привязки. Нажмите Escape или щелкните правой кнопкой мыши, чтобы очистить текущую привязку кнопки действия"
L.ACTIONBAR_BINDING_SAVEBTN                      = "Сохранить"
L.ACTIONBAR_BINDING_DISCARDEBTN                  = "Отменить"
L.ACTIONBAR_EXP_REP                              = "Опыт/Репутация"
L.ACTIONBAR_REP                                  = "Репутация"
L.ACTIONBAR_EXP                                  = "Опыт"
L.ACTIONBAR_PARAGON_EXP                          = "Парагон опыт"
L.ACTIONBAR_APB                                  = "APB"
L.ACTIONBAR_AP_NAME                              = "Экипировка"
L.ACTIONBAR_AP_TOTAL                             = "Всего/Уровень"
L.ACTIONBAR_AP_UPGRADE                           = "Улучшение"

L.CHAT_WHISPER                                   = "От"
L.CHAT_BN_WHISPER                                = "От"
L.CHAT_AFK                                       = "[Отошел]"
L.CHAT_DND                                       = "[Не беспокоить]"
L.CHAT_GM                                        = "[ГМ]"
L.CHAT_GUILD                                     = "Г"
L.CHAT_PARTY                                     = "Гр"
L.CHAT_PARTY_LEADER                              = "ЛГр"
L.CHAT_RAID                                      = "Р"
L.CHAT_RAID_LEADER                               = "ЛР"
L.CHAT_RAID_WARNING                              = "ПР"
L.CHAT_INSTANCE_CHAT                             = "И"
L.CHAT_INSTANCE_CHAT_LEADER                      = "ЛИ"
L.CHAT_OFFICER                                   = "О"
L.CHAT_PET_BATTLE                                = "БП"
L.CHAT_COME_ONLINE                               = "появился |cff298F00в сети|r."
L.CHAT_GONE_OFFLINE                              = "ушел |cffff0000из сети|r."
L.CHAT_INTERRUPTED                               = "Прервано: %s - \124cff71d5ff\124Hspell:%d:0\124h[%s]\124h\124r！"

L.LOOT_RANDOM                                    = "Случайный игрок"
L.LOOT_SELF                                      = "Собственный лут"
L.LOOT_FISH                                      = "Рыболовный лут"
L.LOOT_MONSTER                                   = ">> Лут с "
L.LOOT_CHEST                                     = ">> Лут из сундука"
L.LOOT_ANNOUNCE                                  = "Объявить в"
L.LOOT_TO_RAID                                   = "  Рейд"
L.LOOT_TO_PARTY                                  = "  Группа"
L.LOOT_TO_GUILD                                  = "  Гильдия"
L.LOOT_TO_SAY                                    = "  Сказать"

L.AUTO_INVITE_KEYWORD                            = 'пригл'
L.AUTO_INVITE_INFO                               = 'Принято приглашение от '
L.AUTO_DECLINE_DUEL_INFO                         = 'Отклонен запрос на дуэль от '
L.AUTO_DECLINE_DUEL_PET_INFO                     = 'Отклонен запрос на дуэль питомца от '
L.AUTO_REPAIR_GUIDE_INFO                         = 'Ремонт из банка гильдии '
L.AUTO_REPAIR_INFO                               = 'Стоимость ремонта'
L.AUTO_REPAIR_NOTENOUGH_INFO                     = 'Недостаточно денег для авторемонта!'
L.AUTO_SELL_INFO                                 = 'Автопродажа хлама '

-- Combat text
L.COMBATTEXT_ALREADY_UNLOCKED                    = "Боевой текст уже разблокирован."
L.COMBATTEXT_ALREADY_LOCKED                      = "Боевой текст уже заблокирован."
L.COMBATTEXT_TEST_DISABLED                       = "Режим тестирования боевого текста отключен."
L.COMBATTEXT_TEST_ENABLED                        = "Режим тестирования боевого текста включен."
L.COMBATTEXT_TEST_USE_UNLOCK                     = "Введите /xct unlock, чтобы перемещать и изменять размер рамок боевого текста."
L.COMBATTEXT_TEST_USE_LOCK                       = "Введите /xct lock, чтобы заблокировать рамки боевого текста."
L.COMBATTEXT_TEST_USE_TEST                       = "Введите /xct test, чтобы включить/выключить режим тестирования боевого текста."
L.COMBATTEXT_TEST_USE_RESET                      = "Введите /xct reset, чтобы восстановить позиции по умолчанию."
L.COMBATTEXT_POPUP                               = "Для сохранения позиций окон боевого текста необходимо перезагрузить интерфейс."
L.COMBATTEXT_UNSAVED                             = "Позиции окон боевого текста не сохранены, не забудьте перезагрузить интерфейс."
L.COMBATTEXT_UNLOCKED                            = "Боевой текст разблокирован."

L.DAMAGEMETER_CURRENT                            = "Текущий"
L.DAMAGEMETER_TOTAL                              = "Общий"
L.DAMAGEMETER_OPTION_VISIBLE_BARS                = "Видимые полосы"
L.DAMAGEMETER_OPTION_BAR_WIDTH                   = "Ширина полосы"
L.DAMAGEMETER_OPTION_BAR_HEIGHT                  = "Высота полосы"
L.DAMAGEMETER_OPTION_SPACING                     = "Интервал между полосами"
L.DAMAGEMETER_OPTION_FONT_SIZE                   = "Размер шрифта"
L.DAMAGEMETER_OPTION_HIDE_TITLE                  = "Скрыть заголовок"
L.DAMAGEMETER_OPTION_CLASS_COLOR_BAR             = "Окраска полосы по классу"
L.DAMAGEMETER_OPTION_CLASS_COLOR_NAME            = "Окраска имени по классу"
L.DAMAGEMETER_OPTION_SAVE_ONLY_BOSS_FIGHTS       = "Сохранять только информацию о боях с боссами"
L.DAMAGEMETER_OPTION_MERGE_HEAL_AND_ABSORBS      = "Объединять исцеление и поглощение"
L.DAMAGEMETER_OPTION_BAR_COLOR                   = "Цвет полосы"
L.DAMAGEMETER_OPTION_BACKDROP_COLOR              = "Цвет фона"
L.DAMAGEMETER_OPTION_BORDER_COLOR                = "Цвет границы"

L.MAIL_MESSAGES                                  = "Новая почта"
L.MAIL_NEEDMAILBOX                               = "Нужен почтовый ящик"
L.MAIL_NOMAIL                                    = "Нет почты"
L.MAIL_COMPLETE                                  = "Все готово"
L.MAIL_ENVFULL                                   = "Инвентарь полон"
L.MAIL_MAXCOUNT                                  = "Достигнуто максимальное количество предметов"

L.PANELS_AFK                                     = "ВЫ ОТОШЛИ!"
L.PANELS_AFK_RCLICK                              = "Щелкните правой кнопкой мыши, чтобы скрыть."
L.PANELS_AFK_LCLICK                              = "Щелкните левой кнопкой мыши, чтобы вернуться."

L.DATATEXT_DAY                                   = "Д"
L.DATATEXT_HOUR                                  = "Ч"
L.DATATEXT_MINUTE                                = "М"
L.DATATEXT_SECOND                                = "С"
L.DATATEXT_MILLISECOND                           = "мс"
L.DATATEXT_ONLINE                                = "В сети: "
L.DATATEXT_FRIEND                                = "Друзья: "
L.DATATEXT_GUILD                                 = "Гильдия: "
L.DATATEXT_BAG                                   = "Сумки: "
L.DATATEXT_DURABILITY                            = "Прочность: "
L.DATATEXT_AUTO_REPAIR                           = "Авторемонт"
L.DATATEXT_AUTO_SELL                             = "Автопродажа хлама"
L.DATATEXT_ON                                    = "ВКЛ"
L.DATATEXT_OFF                                   = "ВЫКЛ"
L.DATATEXT_HIDDEN                                = "Скрыто"
L.DATATEXT_BANDWIDTH                             = "Пропускная способность:"
L.DATATEXT_DOWNLOAD                              = "Загрузка:"
L.DATATEXT_MEMORY_USAGE                          = "Использование памяти UI:"
L.DATATEXT_TOTAL_MEMORY_USAGE                    = "Общее использование памяти:"
L.DATATEXT_TOTAL_CPU_USAGE                       = "Общее использование процессора:"
L.DATATEXT_GARBAGE_COLLECTED                     = "Собрано мусора"
L.DATATEXT_CURRENCY_RAID                         = "Рейдовые печати"
L.DATATEXT_SERVER_GOLD                           = "Золото на сервере"
L.DATATEXT_SESSION_GAIN                          = "Прибыль/убыток за сессию"
L.DATATEXT_SORTING_BY                            = "Сортировка по: "

L.MISC_BUY_STACK                                 = "Alt+Клик для покупки стопки"
L.MISC_RAID_UTIL_DISBAND                         = "Распустить группу"

L.BAG_CAPTIONS_STUFF                             = "Вещи"
L.BAG_CAPTIONS_NEWITEMS                          = "Новые предметы"
L.BAG_HINT_TOGGLE                                = "Переключить сумки"
L.BAG_HINT_RESET_NEW                             = "Сбросить новые"
L.BAG_HINT_RESTACK                               = "Пересобрать"
L.BAG_HINT_ACOUNT_DEPOSIT_INCLUDE_REAGENTS       = "Автодепозит включает реагенты"
