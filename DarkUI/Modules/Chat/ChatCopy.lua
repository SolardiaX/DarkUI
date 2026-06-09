local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Copy
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("ChatCopy")

local cfg = C.chat

local frame, editBox, fontString, isCreated
local sizes = {
    ":14:14",
    ":15:15",
    ":16:16",
    ":12:20",
    ":14",
}

local function createCopyFrame()
    frame = CreateFrame("Frame", "DarkUI_CopyChat", UIParent, "BackdropTemplate")
    frame:SetTemplate("Transparent")
    frame:SetSize(540, 300)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    frame:SetFrameStrata("DIALOG")
    tinsert(UISpecialFrames, "DarkUI_CopyChat")
    frame:Hide()
    frame:EnableMouse(true)

    editBox = CreateFrame("EditBox", nil, frame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(0)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(ChatFontNormal)
    editBox:SetSize(500, 300)
    editBox:SetScript("OnEscapePressed", function()
        frame:Hide()
    end)

    editBox:SetScript("OnTextSet", function(self)
        local text = self:GetText()
        for _, size in pairs(sizes) do
            if string.find(text, size) and not string.find(text, size .. "]") then
                self:SetText(string.gsub(text, size, ":12:12"))
            end
        end
    end)

    local scrollArea = CreateFrame("ScrollFrame", nil, frame, "ScrollFrameTemplate")
    scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
    scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -27, 8)
    scrollArea:SetScrollChild(editBox)

    local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    E:ReskinCloseButton(close)

    fontString = frame:CreateFontString(nil, nil, "GameFontNormal")
    fontString:Hide()

    isCreated = true
end

local function canChangeMessage(arg1, id)
    if id and arg1 == "" then
        return id
    end
end

local function messageIsProtected(message)
    return message and (message ~= gsub(message, "(:?|?)|K(.-)|k", canChangeMessage))
end

local function copyChat(cf)
    if not isCreated then
        createCopyFrame()
    end

    local text = ""
    for i = 1, cf:GetNumMessages() do
        local line = cf:GetMessageInfo(i)
        if line and canaccessvalue(line) and not messageIsProtected(line) then
            fontString:SetFormattedText("%s \n", line)
            local cleanLine = fontString:GetText() or ""
            text = text .. cleanLine
        end
    end

    text = text:gsub("|T[^\\]+\\[^\\]+\\[Uu][Ii]%-[Rr][Aa][Ii][Dd][Tt][Aa][Rr][Gg][Ee][Tt][Ii][Nn][Gg][Ii][Cc][Oo][Nn]_(%d)[^|]+|t", "{rt%1}")
    text = text:gsub("|T13700([1-8])[^|]+|t", "{rt%1}")
    text = text:gsub("|T[^|]+|t", "")
    text = text:gsub("|A[^|]+|a", "")

    if frame:IsShown() then
        frame:Hide()
        return
    end

    editBox:SetText(text)
    frame:Show()

    C_Timer.After(0, function()
        local scrollArea = editBox:GetParent()
        if scrollArea and scrollArea.SetVerticalScroll then
            scrollArea:SetVerticalScroll(scrollArea:GetVerticalScrollRange() or 0)
        end
    end)
end

function module:OnInit()
    if not cfg.chat_copy then
        return
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G[format("ChatFrame%d", i)]
        local button = CreateFrame("Button", nil, cf)
        button:SetPoint("BOTTOMRIGHT", 0, 1)
        button:SetSize(20, 20)
        button:SetAlpha(0)

        local icon = button:CreateTexture(nil, "BORDER")
        icon:SetPoint("CENTER")
        icon:SetTexture("Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up")
        icon:SetSize(16, 16)

        button:SetScript("OnMouseUp", function(_, btn)
            if btn == "RightButton" then
                if ChatFrameMenuButton and ChatFrameMenuButton.OpenMenu then
                    ChatFrameMenuButton:OpenMenu()
                end
            elseif btn == "MiddleButton" then
                RandomRoll(1, 100)
            else
                copyChat(cf)
            end
        end)
        button:SetScript("OnEnter", function()
            button:FadeIn()
        end)
        button:SetScript("OnLeave", function()
            button:FadeOut()
        end)
    end

    SlashCmdList.COPY_CHAT = function()
        copyChat(ChatFrame1)
    end
end
