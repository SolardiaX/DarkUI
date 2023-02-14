local E, C, L = select(2, ...):unpack()

if not C.chat.enable then return end

----------------------------------------------------------------------------------------
--	Systems spam filter
----------------------------------------------------------------------------------------

local ChatFrame_AddMessageEventFilter = ChatFrame_AddMessageEventFilter
local IsResting, UnitIsInMyGuild = IsResting, UnitIsInMyGuild

local cfg = C.chat

if cfg.filter == true then
    ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_SAY", function() if IsResting() then return true end end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_MONSTER_YELL", function() if IsResting() then return true end end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", function() return true end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", function() return true end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function() return true end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function() return true end)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function() return true end)

    DUEL_WINNER_KNOCKOUT = ""
    DUEL_WINNER_RETREAT = ""
    DRUNK_MESSAGE_ITEM_OTHER1 = ""
    DRUNK_MESSAGE_ITEM_OTHER2 = ""
    DRUNK_MESSAGE_ITEM_OTHER3 = ""
    DRUNK_MESSAGE_ITEM_OTHER4 = ""
    DRUNK_MESSAGE_OTHER1 = ""
    DRUNK_MESSAGE_OTHER2 = ""
    DRUNK_MESSAGE_OTHER3 = ""
    DRUNK_MESSAGE_OTHER4 = ""
    DRUNK_MESSAGE_ITEM_SELF1 = ""
    DRUNK_MESSAGE_ITEM_SELF2 = ""
    DRUNK_MESSAGE_ITEM_SELF3 = ""
    DRUNK_MESSAGE_ITEM_SELF4 = ""
    DRUNK_MESSAGE_SELF1 = ""
    DRUNK_MESSAGE_SELF2 = ""
    DRUNK_MESSAGE_SELF3 = ""
    DRUNK_MESSAGE_SELF4 = ""
    ERR_PET_LEARN_ABILITY_S = ""
    ERR_PET_LEARN_SPELL_S = ""
    ERR_PET_SPELL_UNLEARNED_S = ""
    ERR_LEARN_ABILITY_S = ""
    ERR_LEARN_SPELL_S = ""
    ERR_LEARN_PASSIVE_S = ""
    ERR_SPELL_UNLEARNED_S = ""

    -- Prevent empty line
    local function systemFilter(_, _, text)
        if text and text == "" then
            return true
        end
    end
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", systemFilter)
end

----------------------------------------------------------------------------------------
--	Players spam filter(by Evl, Elv22 and Affli)
----------------------------------------------------------------------------------------
if cfg.spam == true then
    -- Repeat spam filter
    local lastMessage

    local function repeatMessageFilter(self, _, text, sender)
        sender = Ambiguate(sender, "guild")
        if sender == E.myName or UnitIsInMyGuild(sender) then return end

        if not self.repeatMessages or self.repeatCount > 100 then
            self.repeatCount = 0
            self.repeatMessages = {}
        end
        lastMessage = self.repeatMessages[sender]
        if lastMessage == text then
            return true
        end
        self.repeatMessages[sender] = text
        self.repeatCount = self.repeatCount + 1
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", repeatMessageFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", repeatMessageFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", repeatMessageFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", repeatMessageFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", repeatMessageFilter)

    -- Gold/portals spam filter
    local SpamList = cfg.spamlist or {}

    local function tradeFilter(_, _, text, sender)
        sender = Ambiguate(sender, "guild")
        if sender == E.myName or UnitIsInMyGuild(sender) then return end

        for _, value in pairs(SpamList) do
            if text:lower():match(value) then
                return true
            end
        end
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", tradeFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", tradeFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", tradeFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", tradeFilter)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", tradeFilter)
end
