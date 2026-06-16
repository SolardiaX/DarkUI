local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Voice Panel
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("VoicePanel")

local cfg = C.chat

local BUTTON_SIZE = 24
local BUTTON_SPACING = 2
local PANEL_PADDING = 2

local homeTex = "Interface\\HELPFRAME\\ReportLagIcon-Chat"

------------------------------------------------------------------------
-- Fading
------------------------------------------------------------------------

local panel, toggle

local function onEnter()
    if panel then panel:FadeIn() end
    if toggle then toggle:FadeIn() end
end

local function onLeave()
    if panel then panel:FadeOut() end
    if toggle then toggle:FadeOut() end
end

------------------------------------------------------------------------
-- QuickJoinToastButton Setup
------------------------------------------------------------------------

local function setupQuickJoin(button)
    hooksecurefunc(button, "ToastToFriendFinished", function(self)
        self.FriendsButton:SetShown(not self.displayedToast)
        if self.FriendCount then
            self.FriendCount:SetShown(not self.displayedToast)
        end
    end)

    hooksecurefunc(button, "UpdateQueueIcon", function(self)
        if not self.displayedToast then return end
        self.FriendsButton:SetShown(false)
        if self.FriendCount then
            self.FriendCount:SetShown(false)
        end
    end)

    button.Toast:SetParent(UIParent)
    button.Toast:ClearAllPoints()
    button.Toast:SetPoint(unpack(cfg.bn_popup))
    button.Toast.Background:SetTexture("")
 
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
    local channelButtons = {
        QuickJoinToastButton,
        TextToSpeechButton,
        ChatFrameChannelButton,
        ChatFrameToggleVoiceDeafenButton,
        ChatFrameToggleVoiceMuteButton,
        ChatFrameMenuButton,
    }

    local validButtons = {}
    for _, button in ipairs(channelButtons) do
        if button then
            tinsert(validButtons, button)
        end
    end

    if #validButtons == 0 then return end

    local panelHeight = #validButtons * BUTTON_SIZE + (#validButtons - 1) * BUTTON_SPACING + PANEL_PADDING * 2

    toggle = CreateFrame("Button", nil, ChatFrame1)
    toggle:SetSize(20, 20)
    toggle:SetPoint("BOTTOMLEFT", ChatFrame1, "BOTTOMRIGHT", 4, 0)
    toggle:SetAlpha(0.1)
    toggle:SetFrameStrata("MEDIUM")

    local toggleIcon = toggle:CreateTexture(nil, "ARTWORK")
    toggleIcon:SetAllPoints()
    toggleIcon:SetTexture(homeTex)

    toggle:SetScript("OnEnter", onEnter)
    toggle:SetScript("OnLeave", onLeave)

    ChatFrame1:HookScript("OnEnter", function()
        toggle:FadeIn()
    end)
    ChatFrame1:HookScript("OnLeave", function()
        if not panel:IsMouseOver() and not toggle:IsMouseOver() then
            toggle:FadeOut()
        end
    end)

    panel = CreateFrame("Frame", "DarkUI_VoicePanel", ChatFrame1)
    panel:SetSize(BUTTON_SIZE + PANEL_PADDING * 2, panelHeight)
    panel:SetPoint("BOTTOM", toggle, "TOP", 0, 2)
    panel:SetAlpha(0)
    panel:SetFrameStrata("MEDIUM")

    panel:SetScript("OnEnter", onEnter)
    panel:SetScript("OnLeave", onLeave)

    for i, button in ipairs(validButtons) do
        button:SetParent(panel)
        button:ClearAllPoints()
        button:SetSize(BUTTON_SIZE, BUTTON_SIZE)

        if i == 1 then
            button:SetPoint("TOP", panel, "TOP", 0, -PANEL_PADDING)
        else
            button:SetPoint("TOP", validButtons[i - 1], "BOTTOM", 0, -BUTTON_SPACING)
        end

        button:HookScript("OnEnter", onEnter)
        button:HookScript("OnLeave", onLeave)
    end

    if QuickJoinToastButton then
        setupQuickJoin(QuickJoinToastButton)
    end
end
