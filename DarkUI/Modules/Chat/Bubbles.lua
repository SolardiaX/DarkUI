local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Bubbles
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("Bubbles")

local select, pairs = select, pairs
local tinsert, tremove = table.insert, table.remove
local format = format
local GetTime = GetTime
local GetCVarBool = GetCVarBool
local IsInInstance = IsInInstance
local GetPlayerInfoByGUID = GetPlayerInfoByGUID
local Ambiguate = Ambiguate
local C_ChatBubbles_GetAllChatBubbles = C_ChatBubbles.GetAllChatBubbles
local C_Timer_After = C_Timer.After
local C_Timer_NewTicker = C_Timer.NewTicker
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local cfg = C.chat
local media = C.media

local BG_COLOR = { 0.08, 0.08, 0.1, 0.85 }
local BORDER_COLOR = { 0.2, 0.2, 0.25, 1 }
local BORDER_SIZE = 1
local PADDING = 8
local SENDER_OFFSET_Y = 2

------------------------------------------------------------------------
-- Message Queue
------------------------------------------------------------------------

local messageQueue = {}
local processedBubbles = {}

local function queueMessage(sender, guid) tinsert(messageQueue, { sender = sender, guid = guid, time = GetTime() }) end

local function cleanQueue()
    local now = GetTime()
    for i = #messageQueue, 1, -1 do
        if now - messageQueue[i].time > 2 then tremove(messageQueue, i) end
    end
end

------------------------------------------------------------------------
-- Skin Bubble
------------------------------------------------------------------------

local function skinBubble(container)
    if container.isSkinned then return end

    local frame = container:GetChildren()
    if not frame then return end

    local text
    for i = 1, select("#", frame:GetRegions()) do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "FontString" then
            text = region
            break
        end
    end

    if not text then return end

    -- Hide all Blizzard textures
    for i = 1, select("#", frame:GetRegions()) do
        local region = select(i, frame:GetRegions())
        if region and region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
            region:Hide()
        end
    end

    if frame.Tail then frame.Tail:SetAlpha(0) end

    -- Scale
    frame:SetScale(cfg.bubble_scale or 0.9)

    -- Font
    text:SetFont(media.standard_font[1], cfg.bubble_font_size or 12, "OUTLINE")
    text:SetJustifyH("LEFT")
    text:SetShadowColor(0, 0, 0, 0.8)
    text:SetShadowOffset(1, -1)

    -- Background
    local bg = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetColorTexture(unpack(BG_COLOR))
    bg:SetPoint("TOPLEFT", text, -PADDING, PADDING)
    bg:SetPoint("BOTTOMRIGHT", text, PADDING, -PADDING)

    -- Border (4 lines)
    local bdTop = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bdTop:SetColorTexture(unpack(BORDER_COLOR))
    bdTop:SetHeight(BORDER_SIZE)
    bdTop:SetPoint("TOPLEFT", bg, "TOPLEFT", 0, 0)
    bdTop:SetPoint("TOPRIGHT", bg, "TOPRIGHT", 0, 0)

    local bdBottom = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bdBottom:SetColorTexture(unpack(BORDER_COLOR))
    bdBottom:SetHeight(BORDER_SIZE)
    bdBottom:SetPoint("BOTTOMLEFT", bg, "BOTTOMLEFT", 0, 0)
    bdBottom:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 0, 0)

    local bdLeft = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bdLeft:SetColorTexture(unpack(BORDER_COLOR))
    bdLeft:SetWidth(BORDER_SIZE)
    bdLeft:SetPoint("TOPLEFT", bg, "TOPLEFT", 0, 0)
    bdLeft:SetPoint("BOTTOMLEFT", bg, "BOTTOMLEFT", 0, 0)

    local bdRight = frame:CreateTexture(nil, "BACKGROUND", nil, -7)
    bdRight:SetColorTexture(unpack(BORDER_COLOR))
    bdRight:SetWidth(BORDER_SIZE)
    bdRight:SetPoint("TOPRIGHT", bg, "TOPRIGHT", 0, 0)
    bdRight:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 0, 0)

    -- Sender name (above bubble)
    local sender = container:CreateFontString(nil, "OVERLAY")
    sender:SetFont(media.standard_font[1], (cfg.bubble_font_size or 12) - 1, "OUTLINE")
    sender:SetPoint("BOTTOM", container, "TOP", 0, SENDER_OFFSET_Y)
    sender:SetShadowColor(0, 0, 0, 0.8)
    sender:SetShadowOffset(1, -1)
    container._sender = sender

    -- OnHide: reset skinned flag for bubble reuse
    frame:HookScript("OnHide", function()
        container.isSkinned = false
        processedBubbles[container] = nil
        if container._sender then container._sender:SetText("") end
    end)

    container.isSkinned = true
end

------------------------------------------------------------------------
-- Update Bubble (sender info + reveal)
------------------------------------------------------------------------

local function updateBubble(container, guid, sender)
    if not container._sender then return end

    -- Sender name with class color
    if sender then
        local displayName = Ambiguate(sender, "short")
        local color
        if guid and guid ~= "" then
            local _, class = GetPlayerInfoByGUID(guid)
            if class then color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class] end
        end
        if color then
            container._sender:SetText(format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, displayName))
        else
            container._sender:SetText("|cffcccccc" .. displayName .. "|r")
        end
    end
end

------------------------------------------------------------------------
-- Process Bubbles
------------------------------------------------------------------------

local function shouldHide()
    if cfg.bubble_hide_instance then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "party" or instanceType == "scenario") then return true end
    end
    if cfg.bubble_hide_raid then
        local inInstance, instanceType = IsInInstance()
        if inInstance and instanceType == "raid" then return true end
    end
    return false
end

local function processBubbles()
    if shouldHide() then return end

    for _, container in pairs(C_ChatBubbles_GetAllChatBubbles()) do
        if not processedBubbles[container] then
            skinBubble(container)

            -- Match with queued message
            for i = #messageQueue, 1, -1 do
                local data = messageQueue[i]
                if data then
                    updateBubble(container, data.guid, data.sender)
                    processedBubbles[container] = true
                    tremove(messageQueue, i)
                    break
                end
            end

            if not processedBubbles[container] then processedBubbles[container] = true end
        end
    end

    -- Cleanup hidden bubbles
    for bubble in pairs(processedBubbles) do
        if not bubble:IsShown() then processedBubbles[bubble] = nil end
    end
end

------------------------------------------------------------------------
-- Events
------------------------------------------------------------------------

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

    for event in next, events do
        handler:RegisterEvent(event)
    end

    handler:SetScript("OnEvent", function(_, event, _, sender, _, _, _, _, _, _, _, _, _, guid)
        if not GetCVarBool(events[event]) then return end

        queueMessage(sender, guid)
        cleanQueue()
        C_Timer_After(0.05, processBubbles)
    end)

    C_Timer_NewTicker(0.5, processBubbles)
end
