local E, C, L = select(2, ...):unpack()

if not C.chat.enable then return end

----------------------------------------------------------------------------------------
--  Bubbles Style
----------------------------------------------------------------------------------------

local pairs, GetCVarBool = pairs, GetCVarBool
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

local function reskinChatBubble(chatbubble)
    if chatbubble.styled then return end

    local frame = chatbubble:GetChildren()
    if frame and not frame:IsForbidden() then
        frame:CreateBackdrop()
        frame.backdrop:SetScale(UIParent:GetEffectiveScale())
        frame.backdrop:SetPoint("TOPLEFT", frame, 12, -12)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, -12, 12)

        frame:DisableDrawLayer("BORDER")
        frame.Tail:SetAlpha(0)
        frame.String:SetFont(unpack(C.media.standard_font))
    end

    chatbubble.styled = true
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

local bubbleHook = CreateFrame("Frame")
for event in next, events do
    bubbleHook:RegisterEvent(event)
end
bubbleHook:SetScript("OnEvent", function(self, event)
    if GetCVarBool(events[event]) then
        self.elapsed = 0
        self:Show()
    end
end)

bubbleHook:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed > .1 then
        for _, chatbubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
            reskinChatBubble(chatbubble)
        end
        self:Hide()
    end
end)
bubbleHook:Hide()
