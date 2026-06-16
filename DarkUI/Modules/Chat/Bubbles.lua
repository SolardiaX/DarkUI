local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Bubbles
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("Bubbles")

local pairs, GetCVarBool = pairs, GetCVarBool
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles

local function reskinChatBubble(chatbubble)
    if chatbubble.skinned then
        return
    end

    local frame = chatbubble:GetChildren()
    if not frame then
        return
    end

    frame:CreateBackdrop("default", 16)
    frame.__backdrop:SetBackdropEdge("bolder")

    if frame.backdrop then
        frame.backdrop:SetScale(UIParent:GetEffectiveScale())
        frame.backdrop:SetPoint("TOPLEFT", frame, 12, -12)
        frame.backdrop:SetPoint("BOTTOMRIGHT", frame, -12, 12)
    end

    if frame.gradient then
        frame.gradient:SetPoint("TOPLEFT", frame.backdrop, 2, -2)
        frame.gradient:SetPoint("BOTTOMRIGHT", frame.backdrop, "BOTTOMRIGHT", -2, 2)
    end

    frame:DisableDrawLayer("BORDER")

    if frame.Tail then
        frame.Tail:SetAlpha(0)
    end
    if frame.String then
        frame.String:SetFont(unpack(C.media.standard_font))
    end

    chatbubble.skinned = true
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
    local handler = CreateFrame("Frame")
    handler.elapsed = 0

    for event in next, events do
        handler:RegisterEvent(event)
    end

    handler:SetScript("OnEvent", function(_, event)
        if GetCVarBool(events[event]) then
            handler.elapsed = 0
        end
    end)

    handler:SetScript("OnUpdate", function(_, elapsed)
        handler.elapsed = handler.elapsed + elapsed
        if handler.elapsed > 0.1 then
            for _, chatbubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
                reskinChatBubble(chatbubble)
            end
        end
    end)
end
