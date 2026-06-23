local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Tools (unified toolbar: Copy + System Buttons)
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("ChatTools")

local cfg = C.chat

local BUTTON_SIZE = 24
local BUTTON_SPACING = 2

------------------------------------------------------------------------
-- Copy Frame
------------------------------------------------------------------------

local copyFrame, copyEditBox, copyFontString, isCreated

local sizes = { ":14:14", ":15:15", ":16:16", ":12:20", ":14" }

local function createCopyFrame()
    copyFrame = CreateFrame("Frame", "DarkUI_CopyChat", UIParent, "BackdropTemplate")
    copyFrame:SetTemplate("Default")
    copyFrame:SetSize(540, 300)
    copyFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 100)
    copyFrame:SetFrameStrata("DIALOG")
    tinsert(UISpecialFrames, "DarkUI_CopyChat")
    copyFrame:Hide()
    copyFrame:EnableMouse(true)

    copyEditBox = CreateFrame("EditBox", nil, copyFrame)
    copyEditBox:SetMultiLine(true)
    copyEditBox:SetMaxLetters(0)
    copyEditBox:SetAutoFocus(false)
    copyEditBox:SetFontObject(ChatFontNormal)
    copyEditBox:SetSize(500, 300)
    copyEditBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
    copyEditBox:SetScript("OnTextSet", function(self)
        local text = self:GetText()
        for _, size in pairs(sizes) do
            if string.find(text, size) and not string.find(text, size .. "]") then self:SetText(string.gsub(text, size, ":12:12")) end
        end
    end)

    local scrollArea = CreateFrame("ScrollFrame", nil, copyFrame, "ScrollFrameTemplate")
    scrollArea:SetPoint("TOPLEFT", copyFrame, "TOPLEFT", 8, -30)
    scrollArea:SetPoint("BOTTOMRIGHT", copyFrame, "BOTTOMRIGHT", -27, 8)
    scrollArea:SetScrollChild(copyEditBox)

    local close = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT", -2, -2)
    E:StyleCloseButton(close)

    copyFontString = copyFrame:CreateFontString(nil, nil, "GameFontNormal")
    copyFontString:Hide()

    isCreated = true
end

local function canChangeMessage(arg1, id)
    if id and arg1 == "" then return id end
end

local function messageIsProtected(message) return message and (message ~= gsub(message, "(:?|?)|K(.-)|k", canChangeMessage)) end

local function copyChat(cf)
    if not isCreated then createCopyFrame() end

    if copyFrame:IsShown() then
        copyFrame:Hide()
        return
    end

    local text = ""
    for i = 1, cf:GetNumMessages() do
        local line = cf:GetMessageInfo(i)
        if line and canaccessvalue(line) and not messageIsProtected(line) then
            copyFontString:SetFormattedText("%s \n", line)
            local cleanLine = copyFontString:GetText() or ""
            text = text .. cleanLine
        end
    end

    text = text:gsub("|T[^\\]+\\[^\\]+\\[Uu][Ii]%-[Rr][Aa][Ii][Dd][Tt][Aa][Rr][Gg][Ee][Tt][Ii][Nn][Gg][Ii][Cc][Oo][Nn]_(%d)[^|]+|t", "{rt%1}")
    text = text:gsub("|T13700([1-8])[^|]+|t", "{rt%1}")
    text = text:gsub("|T[^|]+|t", "")
    text = text:gsub("|A[^|]+|a", "")

    copyEditBox:SetText(text)
    copyFrame:Show()

    C_Timer.After(0, function()
        local scrollArea = copyEditBox:GetParent()
        if scrollArea and scrollArea.SetVerticalScroll then scrollArea:SetVerticalScroll(scrollArea:GetVerticalScrollRange() or 0) end
    end)
end

------------------------------------------------------------------------
-- QuickJoin Toast Setup
------------------------------------------------------------------------

local function setupQuickJoin(button)
    if not button then return end
    hooksecurefunc(button, "ToastToFriendFinished", function(self)
        self.FriendsButton:SetShown(not self.displayedToast)
        if self.FriendCount then self.FriendCount:SetShown(not self.displayedToast) end
    end)
    hooksecurefunc(button, "UpdateQueueIcon", function(self)
        if not self.displayedToast then return end
        self.FriendsButton:SetShown(false)
        if self.FriendCount then self.FriendCount:SetShown(false) end
    end)

    if button.Toast then
        button.Toast:SetParent(UIParent)
        button.Toast:ClearAllPoints()
        button.Toast:SetPoint(unpack(cfg.bn_popup))
        button.Toast.Background:SetTexture("")
    end

    BNToastFrame:ClearAllPoints()
    BNToastFrame:SetPoint(unpack(cfg.bn_popup))
    hooksecurefunc(BNToastFrame, "SetPoint", function(self, _, anchor)
        if anchor == button then
            self:ClearAllPoints()
            self:SetPoint(unpack(cfg.bn_popup))
        end
    end)
    hooksecurefunc(BNToastFrame, "ShowToast", function(self)
        if not self.IsSkinned then
            self.CloseButton:SetSize(16, 16)
            E:StyleCloseButton(self.CloseButton, self)
            self.IsSkinned = true
        end
    end)
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.chat_copy then return end

    -- Copy buttons (one per ChatFrame, original ChatCopy style)
    local copyButtons = {}

    for i = 1, NUM_CHAT_WINDOWS do
        local cf = _G[format("ChatFrame%d", i)]
        local button = CreateFrame("Button", nil, cf)
        button:SetPoint("BOTTOMRIGHT", 0, 1)
        button:SetSize(20, 20)
        button:SetAlpha(0)

        local icon = button:CreateTexture(nil, "ARTWORK")
        icon:SetPoint("CENTER")
        icon:SetTexture("Interface\\BUTTONS\\UI-GuildButton-PublicNote-Up")
        icon:SetSize(16, 16)

        button:SetScript("OnMouseUp", function(_, btn)
            if btn == "RightButton" then
                if ChatFrameMenuButton and ChatFrameMenuButton.OpenMenu then ChatFrameMenuButton:OpenMenu() end
            elseif btn == "MiddleButton" then
                RandomRoll(1, 100)
            else
                copyChat(cf)
            end
        end)
        button:SetScript("OnEnter", function() button:FadeIn() end)
        button:SetScript("OnLeave", function() button:FadeOut() end)

        copyButtons[i] = button
    end

    if copyButtons[1] then
        ChatFrame1:HookScript("OnEnter", function() copyButtons[1]:FadeIn() end)
        ChatFrame1:HookScript("OnLeave", function() copyButtons[1]:FadeOut() end)
    end

    -- System buttons toolbar (right side, vertical)
    local systemButtons = {
        QuickJoinToastButton,
        TextToSpeechButton,
        ChatFrameChannelButton,
        ChatFrameToggleVoiceDeafenButton,
        ChatFrameToggleVoiceMuteButton,
        ChatFrameMenuButton,
    }

    local validButtons = {}
    for _, button in ipairs(systemButtons) do
        if button then tinsert(validButtons, button) end
    end

    if #validButtons > 0 then
        local panelHeight = #validButtons * BUTTON_SIZE + (#validButtons - 1) * BUTTON_SPACING + 4

        local toolbar = CreateFrame("Frame", "DarkUI_ChatTools", ChatFrame1)
        toolbar:SetSize(BUTTON_SIZE + 4, panelHeight)
        toolbar:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMRIGHT", 4, 0)
        toolbar:SetAlpha(0)
        toolbar:SetFrameStrata("MEDIUM")

        local function showToolbar() toolbar:FadeIn() end
        local function hideToolbar()
            if not toolbar:IsMouseOver() then toolbar:FadeOut() end
        end

        toolbar:SetScript("OnEnter", showToolbar)
        toolbar:SetScript("OnLeave", hideToolbar)
        ChatFrame1:HookScript("OnEnter", showToolbar)
        ChatFrame1:HookScript("OnLeave", hideToolbar)

        for i, sysBtn in ipairs(validButtons) do
            sysBtn:SetParent(toolbar)
            sysBtn:ClearAllPoints()
            sysBtn:SetSize(BUTTON_SIZE, BUTTON_SIZE)
            if i == 1 then
                sysBtn:SetPoint("TOP", toolbar, "TOP", 0, -2)
            else
                sysBtn:SetPoint("TOP", validButtons[i - 1], "BOTTOM", 0, -BUTTON_SPACING)
            end
            sysBtn:HookScript("OnEnter", showToolbar)
            sysBtn:HookScript("OnLeave", hideToolbar)
        end
    end

    -- QuickJoin toast setup
    setupQuickJoin(QuickJoinToastButton)

    -- Slash command
    SlashCmdList.COPY_CHAT = function() copyChat(ChatFrame1) end
end
