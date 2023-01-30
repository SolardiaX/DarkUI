local E, C, L = select(2, ...):unpack()

if not C.chat.enable then return end

----------------------------------------------------------------------------------------
--  Bubbles Style
----------------------------------------------------------------------------------------
local module = E:Module("Chat"):Sub("Bubbles")

local pairs, GetCVarBool = pairs, GetCVarBool
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

local function reskinChatBubble(chatbubble)
    local frame = chatbubble:GetChildren()
    
    E:ApplyBackdrop(frame, true)
    
    frame.backdrop:SetScale(UIParent:GetEffectiveScale())
    frame.backdrop:SetPoint("TOPLEFT", frame, 12, -12)
    frame.backdrop:SetPoint("BOTTOMRIGHT", frame, -12, 12)

    frame.gradient:SetPoint("TOPLEFT", frame.backdrop, 2, -2)
    frame.gradient:SetPoint("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT", -2, 2)

    frame:DisableDrawLayer("BORDER")
        
    frame.Tail:SetAlpha(0)
    frame.String:SetFont(unpack(C.media.standard_font))
end

local events = {
    CHAT_MSG_SAY = "chatBubbles",
    CHAT_MSG_YELL = "chatBubbles",
    CHAT_MSG_MONSTER_SAY = "chatBubbles",
    CHAT_MSG_MONSTER_YELL = "chatBubbles",
    CHAT_MSG_PARTY = "chatBubblesParty",
    CHAT_MSG_PARTY_LEADER = "chatBubblesParty",
    CHAT_MSG_MONSTER_PARTY = "chatBubblesParty",
}

function module:OnInit()
    self.elapsed = 0

    for event in next, events do
        self:RegisterEvent(event)
    end

    self:SetScript("OnEvent", function(self, event)
        if GetCVarBool(events[event]) then
            self.elapsed = 0
        end
    end)
    
    self:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed > .1 then
            for _, chatbubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
                reskinChatBubble(chatbubble)
            end
        end
    end)
end
