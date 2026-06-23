local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- URL Copy
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("URLCopy")

local gsub, format = gsub, string.format

local cfg = C.chat

local urlColor = "ff149bfd"

local function convertLink(url) return format(" |H%s|h|c%s[%s]|r|h ", "url:" .. url, urlColor, url) end

local urlPatterns = {
    -- protocol://domain
    "(%s?)(%a+://[%w_/%.%?%%=~&-'%-]+)(%s?)",
    -- www.domain
    "(%s?)(www%.[%w_/%.%?%%=~&-'%-]+)(%s?)",
    -- IP:port
    "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?:%d%d?%d?%d?%d?)(%s?)",
    -- IP
    "(%s?)(%d%d?%d?%.%d%d?%d?%.%d%d?%d?%.%d%d?%d?)(%s?)",
    -- host:port
    "(%s?)([%w_-]+%.?[%w_-]+%.[%w_-]+:%d%d%d?%d?%d?)(%s?)",
    -- email
    "(%s?)([_%w-%.~-]+@[_%w-]+%.[_%w-%.]+)(%s?)",
}

local function highlightURL(pre, url, post) return pre .. convertLink(url) .. post end

local function filterURL(self, event, message, ...)
    if not message then return end
    for _, pattern in ipairs(urlPatterns) do
        message = gsub(message, pattern, highlightURL)
    end
    return false, message, ...
end

------------------------------------------------------------------------
-- URL Click Handler
------------------------------------------------------------------------

local copyFrame, copyBox

local function createCopyFrame()
    copyFrame = CreateFrame("Frame", "DarkUI_URLCopy", UIParent, "BackdropTemplate")
    copyFrame:SetTemplate("Transparent")
    copyFrame:SetSize(400, 50)
    copyFrame:SetPoint("CENTER")
    copyFrame:SetFrameStrata("DIALOG")
    copyFrame:Hide()
    tinsert(UISpecialFrames, "DarkUI_URLCopy")

    copyBox = CreateFrame("EditBox", nil, copyFrame)
    copyBox:SetFontObject(ChatFontNormal)
    copyBox:SetPoint("TOPLEFT", 8, -12)
    copyBox:SetPoint("BOTTOMRIGHT", -8, 12)
    copyBox:SetAutoFocus(true)
    copyBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
    copyBox:SetScript("OnEditFocusLost", function() copyFrame:Hide() end)
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    local events = {
        "CHAT_MSG_SAY",
        "CHAT_MSG_YELL",
        "CHAT_MSG_GUILD",
        "CHAT_MSG_OFFICER",
        "CHAT_MSG_PARTY",
        "CHAT_MSG_PARTY_LEADER",
        "CHAT_MSG_RAID",
        "CHAT_MSG_RAID_LEADER",
        "CHAT_MSG_RAID_WARNING",
        "CHAT_MSG_INSTANCE_CHAT",
        "CHAT_MSG_INSTANCE_CHAT_LEADER",
        "CHAT_MSG_WHISPER",
        "CHAT_MSG_WHISPER_INFORM",
        "CHAT_MSG_BN_WHISPER",
        "CHAT_MSG_BN_WHISPER_INFORM",
        "CHAT_MSG_CHANNEL",
    }

    for _, event in ipairs(events) do
        ChatFrame_AddMessageEventFilter(event, filterURL)
    end

    local SetHyperlink = ItemRefTooltip.SetHyperlink
    function ItemRefTooltip:SetHyperlink(link, ...)
        if link and link:sub(1, 4) == "url:" then
            if not copyFrame then createCopyFrame() end
            local url = link:sub(5)
            copyBox:SetText(url)
            copyFrame:Show()
            copyBox:SetFocus()
            copyBox:HighlightText()
            return
        end
        return SetHyperlink(self, link, ...)
    end
end
