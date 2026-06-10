local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Frame
------------------------------------------------------------------------

local module = E:Module("Chat")
module:SetConfigKey("chat")

local gsub, strfind, format = gsub, strfind, string.format

local cfg = C.chat
local isScaling = false

------------------------------------------------------------------------
-- Global Chat Strings
------------------------------------------------------------------------

_G.CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE_CHAT|h[" .. L.CHAT_INSTANCE_CHAT .. "]|h %s:\32"
_G.CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE_CHAT|h[" .. L.CHAT_INSTANCE_CHAT_LEADER .. "]|h %s:\32"
_G.CHAT_BN_WHISPER_GET = L.CHAT_BN_WHISPER .. " %s:\32"
_G.CHAT_GUILD_GET = "|Hchannel:GUILD|h[" .. L.CHAT_GUILD .. "]|h %s:\32"
_G.CHAT_OFFICER_GET = "|Hchannel:OFFICER|h[" .. L.CHAT_OFFICER .. "]|h %s:\32"
_G.CHAT_PARTY_GET = "|Hchannel:PARTY|h[" .. L.CHAT_PARTY .. "]|h %s:\32"
_G.CHAT_PARTY_LEADER_GET = "|Hchannel:PARTY|h[" .. L.CHAT_PARTY_LEADER .. "]|h %s:\32"
_G.CHAT_PARTY_GUIDE_GET = _G.CHAT_PARTY_LEADER_GET
_G.CHAT_RAID_GET = "|Hchannel:RAID|h[" .. L.CHAT_RAID .. "]|h %s:\32"
_G.CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[" .. L.CHAT_RAID_LEADER .. "]|h %s:\32"
_G.CHAT_RAID_WARNING_GET = "[" .. L.CHAT_RAID_WARNING .. "] %s:\32"
_G.CHAT_PET_BATTLE_COMBAT_LOG_GET = "|Hchannel:PET_BATTLE_COMBAT_LOG|h[" .. L.CHAT_PET_BATTLE .. "]|h:\32"
_G.CHAT_PET_BATTLE_INFO_GET = "|Hchannel:PET_BATTLE_INFO|h[" .. L.CHAT_PET_BATTLE .. "]|h:\32"
_G.CHAT_SAY_GET = "%s:\32"
_G.CHAT_WHISPER_GET = L.CHAT_WHISPER .. " %s:\32"
_G.CHAT_YELL_GET = "%s:\32"
_G.CHAT_FLAG_AFK = "|cffE7E716" .. L.CHAT_AFK .. "|r "
_G.CHAT_FLAG_DND = "|cffFF0000" .. L.CHAT_DND .. "|r "
_G.CHAT_FLAG_GM = "|cff4154F5" .. L.CHAT_GM .. "|r "
_G.ERR_FRIEND_ONLINE_SS = "|Hplayer:%s|h[%s]|h " .. L.CHAT_COME_ONLINE
_G.ERR_FRIEND_OFFLINE_S = "[%s] " .. L.CHAT_GONE_OFFLINE

------------------------------------------------------------------------
-- AddMessage Hook
------------------------------------------------------------------------

local origs = {}

local function strip(info, name)
    return format("|Hplayer:%s|h[%s]|h", info, name:gsub("%-[^|]+", ""))
end

local function addMessage(self, text, ...)
    if type(text) == "string" and canaccessvalue(text) then
        text = text:gsub("|h%[(%d+)%. .-%]|h", "|h[%1]|h")
        text = text:gsub("|Hplayer:(.-)|h%[(.-)%]|h", strip)
    end
    return origs[self](self, text, ...)
end

------------------------------------------------------------------------
-- Chat Style
------------------------------------------------------------------------

local function setChatStyle(frame)
    local id = frame:GetID()
    local chat = frame:GetName()

    _G[chat]:SetFrameLevel(5)
    _G[chat]:SetClampedToScreen(false)
    _G[chat]:SetFading(false)

    _G[chat .. "EditBox"]:ClearAllPoints()
    _G[chat .. "EditBox"]:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -10, 23)
    _G[chat .. "EditBox"]:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 11, 23)

    for j = 1, #CHAT_FRAME_TEXTURES do
        _G[chat .. CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
    end

    local tab = _G[format("ChatFrame%sTab", id)]
    tab.Left:Kill()
    tab.Middle:Kill()
    tab.Right:Kill()
    tab.ActiveLeft:Kill()
    tab.ActiveMiddle:Kill()
    tab.ActiveRight:Kill()
    tab.HighlightLeft:Kill()
    tab.HighlightMiddle:Kill()
    tab.HighlightRight:Kill()

    local bf = frame.buttonFrame
    if bf then bf:SetGhost() end

    _G[format("ChatFrame%sTabGlow", id)]:Kill()
    frame.ScrollBar:Kill()

    local editLeft = _G[format("ChatFrame%sEditBoxLeft", id)]
    if editLeft then editLeft:Kill() end
    local editMid = _G[format("ChatFrame%sEditBoxMid", id)]
    if editMid then editMid:Kill() end
    local editRight = _G[format("ChatFrame%sEditBoxRight", id)]
    if editRight then editRight:Kill() end

    _G[chat .. "EditBox"]:StripTextures(2)

    if frame.ScrollToBottomButton then
        frame.ScrollToBottomButton:ClearAllPoints()
        frame.ScrollToBottomButton:SetPoint("BOTTOMRIGHT", frame, 0, -4)
        frame:HookScript("OnUpdate", function(self)
            if not self:AtBottom() then
                frame.ScrollToBottomButton:Show()
            else
                frame.ScrollToBottomButton:Hide()
            end
        end)
    end

    local tab_convo = _G[chat .. "Tab"].conversationIcon
    if tab_convo then tab_convo:Kill() end

    local eb = _G[chat .. "EditBox"]
    eb:SetAltArrowKeyMode(false)
    eb:SetClampedToScreen(true)

    local lang = _G[chat .. "EditBoxLanguage"]
    if lang then
        lang:GetRegions():SetAlpha(0)
        lang:SetPoint("TOPLEFT", eb, "TOPRIGHT", 5, 0)
        lang:SetPoint("BOTTOMRIGHT", eb, "BOTTOMRIGHT", 29, 0)
        E:ApplyBackdrop(lang, true)
    end

    if cfg.background == true and cfg.tabs_mouseover ~= true then
        local editBoxBg = CreateFrame("Frame", nil, _G[chat .. "EditBox"], "BackdropTemplate")
        editBoxBg:SetPoint("TOPLEFT", _G[chat .. "EditBox"], "TOPLEFT", 7, -5)
        editBoxBg:SetPoint("BOTTOMRIGHT", _G[chat .. "EditBox"], "BOTTOMRIGHT", -7, 4)
        editBoxBg:SetFrameStrata("LOW")
        editBoxBg:SetFrameLevel(1)
        E:ApplyBackdrop(editBoxBg, true)

        local function colorize(r, g, b)
            if editBoxBg.__backdrop then
                editBoxBg.__backdrop:SetBackdropBorderColor(r, g, b)
            end
        end

        hooksecurefunc("ChatEdit_UpdateHeader", function()
            local chatType = _G[chat .. "EditBox"]:GetAttribute("chatType")
            if not chatType then
                return
            end

            local chanTarget = _G[chat .. "EditBox"]:GetAttribute("channelTarget")
            local chanName = chanTarget and GetChannelName(chanTarget)
            if chanName and chatType == "CHANNEL" then
                if chanName == 0 then
                    colorize(unpack(C.media.border_color))
                else
                    colorize(ChatTypeInfo[chatType .. chanName].r, ChatTypeInfo[chatType .. chanName].g, ChatTypeInfo[chatType .. chanName].b)
                end
            else
                colorize(ChatTypeInfo[chatType].r, ChatTypeInfo[chatType].g, ChatTypeInfo[chatType].b)
            end
        end)
    end

    if _G[chat] == _G["ChatFrame2"] then
        if CombatLogQuickButtonFrame_Custom then
            CombatLogQuickButtonFrame_Custom:StripTextures()
            CombatLogQuickButtonFrame_Custom:CreateBackdrop()
            CombatLogQuickButtonFrame_Custom.__backdrop:SetPoint("TOPLEFT", 1, -4)
            CombatLogQuickButtonFrame_Custom.__backdrop:SetPoint("BOTTOMRIGHT", -22, 0)

            E:ReskinCloseButton(CombatLogQuickButtonFrame_CustomAdditionalFilterButton, CombatLogQuickButtonFrame_Custom.__backdrop)
            CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetSize(12, 12)
            CombatLogQuickButtonFrame_CustomAdditionalFilterButton:SetHitRectInsets(0, 0, 0, 0)

            CombatLogQuickButtonFrame_CustomProgressBar:ClearAllPoints()
            CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("TOPLEFT", CombatLogQuickButtonFrame_Custom.__backdrop, 2, -2)
            CombatLogQuickButtonFrame_CustomProgressBar:SetPoint("BOTTOMRIGHT", CombatLogQuickButtonFrame_Custom.__backdrop, -2, 2)
            CombatLogQuickButtonFrame_CustomProgressBar:SetStatusBarTexture(C.media.texture.status_f)

            CombatLogQuickButtonFrameButton1:SetPoint("BOTTOM", 0, 0)
        end
    end

    if _G[chat] ~= _G["ChatFrame2"] then
        origs[_G[chat]] = _G[chat].AddMessage
        _G[chat].AddMessage = addMessage
        _G.TIMESTAMP_FORMAT_HHMM = E:RGBToHex(unpack(cfg.time_color)) .. "[%I:%M]|r "
        _G.TIMESTAMP_FORMAT_HHMMSS = E:RGBToHex(unpack(cfg.time_color)) .. "[%I:%M:%S]|r "
        _G.TIMESTAMP_FORMAT_HHMMSS_24HR = E:RGBToHex(unpack(cfg.time_color)) .. "[%H:%M:%S]|r "
        _G.TIMESTAMP_FORMAT_HHMMSS_AMPM = E:RGBToHex(unpack(cfg.time_color)) .. "[%I:%M:%S %p]|r "
        _G.TIMESTAMP_FORMAT_HHMM_24HR = E:RGBToHex(unpack(cfg.time_color)) .. "[%H:%M]|r "
        _G.TIMESTAMP_FORMAT_HHMM_AMPM = E:RGBToHex(unpack(cfg.time_color)) .. "[%I:%M %p]|r "
    end

    frame.skinned = true
end

------------------------------------------------------------------------
-- Tab Channel Switch
------------------------------------------------------------------------

local cycles = {
    {
        chatType = "SAY",
        use = function()
            return 1
        end,
    },
    {
        chatType = "PARTY",
        use = function()
            return not IsInRaid() and IsInGroup(LE_PARTY_CATEGORY_HOME)
        end,
    },
    {
        chatType = "RAID",
        use = function()
            return IsInRaid(LE_PARTY_CATEGORY_HOME)
        end,
    },
    {
        chatType = "INSTANCE_CHAT",
        use = function()
            return IsPartyLFG()
        end,
    },
    {
        chatType = "GUILD",
        use = function()
            return IsInGuild()
        end,
    },
    {
        chatType = "OFFICER",
        use = function()
            return C_GuildInfo.IsGuildOfficer()
        end,
    },
    {
        chatType = "SAY",
        use = function()
            return 1
        end,
    },
}

local function updateTabChannelSwitch(self)
    if strsub(tostring(self:GetText()), 1, 1) == "/" then
        return
    end
    local currChatType = self:GetAttribute("chatType")

    if IsShiftKeyDown() and (currChatType == "WHISPER" or currChatType == "BN_WHISPER") then
        self:SetAttribute("chatType", "SAY")
        ChatEdit_UpdateHeader(self)
        return
    end

    for i, curr in ipairs(cycles) do
        if curr.chatType == currChatType then
            local h, r, step = i + 1, #cycles, 1
            if IsShiftKeyDown() then
                h, r, step = i - 1, 1, -1
            end
            for j = h, r, step do
                if cycles[j]:use(self, currChatType) then
                    self:SetAttribute("chatType", cycles[j].chatType)
                    ChatEdit_UpdateHeader(self)
                    return
                end
            end
        end
    end
end

------------------------------------------------------------------------
-- Loot Icons
------------------------------------------------------------------------

local function addLootIcons(_, _, message, ...)
    local function icon(link)
        local texture = C_Item.GetItemIconByID(link)
        return "\124T" .. texture .. ":12:12:0:0:64:64:5:59:5:59\124t" .. link
    end
    message = message:gsub("(\124c%x+\124Hitem:.-\124h\124r)", icon)
    return false, message, ...
end

------------------------------------------------------------------------
-- Remove Realm Name
------------------------------------------------------------------------

local function removeRealmName(_, _, msg, author, ...)
    local realm = gsub(E.realm, " ", "")
    if msg:find("-" .. realm) then
        return false, gsub(msg, "%-" .. realm, ""), author, ...
    end
end

------------------------------------------------------------------------
-- Typo History
------------------------------------------------------------------------

local function typoHistoryPosthook(chat, text)
    if text and canaccessvalue(text) and strfind(text, HELP_TEXT_SIMPLE) then
        ChatEdit_AddHistory(chat.editBox)
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    SetCVar("chatStyle", "classic")
    SetCVar("chatMouseScroll", 1)

    GeneralDockManagerOverflowButton:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 0, 5)
    hooksecurefunc(GeneralDockManagerScrollFrame, "SetPoint", function(self, point, anchor, attachTo, x, y)
        if anchor == GeneralDockManagerOverflowButton and x == 0 and y == 0 then
            self:SetPoint(point, anchor, attachTo, 0, -4)
        end
    end)

    local function setupChat()
        for i = 1, NUM_CHAT_WINDOWS do
            local frame = _G[format("ChatFrame%s", i)]
            if not frame.skinned then
                setChatStyle(frame)
            end
        end

        local var = cfg.sticky and 1 or 0
        ChatTypeInfo.SAY.sticky = var
        ChatTypeInfo.PARTY.sticky = var
        ChatTypeInfo.PARTY_LEADER.sticky = var
        ChatTypeInfo.GUILD.sticky = var
        ChatTypeInfo.OFFICER.sticky = var
        ChatTypeInfo.RAID.sticky = var
        ChatTypeInfo.RAID_WARNING.sticky = var
        ChatTypeInfo.INSTANCE_CHAT.sticky = var
        ChatTypeInfo.INSTANCE_CHAT_LEADER.sticky = var
        ChatTypeInfo.WHISPER.sticky = var
        ChatTypeInfo.BN_WHISPER.sticky = var
        ChatTypeInfo.CHANNEL.sticky = var
    end

    if C_AddOns.IsAddOnLoaded("Blizzard_CombatLog") then
        setupChat()
    else
        local function onAddonLoaded(_, _, addon)
            if addon == "Blizzard_CombatLog" then
                self:UnregisterEvent("ADDON_LOADED", onAddonLoaded)
                setupChat()
            end
        end
        self:RegisterEvent("ADDON_LOADED", onAddonLoaded)
    end

    hooksecurefunc("FCF_OpenTemporaryWindow", function()
        local frame = FCF_GetCurrentChatFrame()
        if not frame.skinned then
            setChatStyle(frame)
        end
    end)

    hooksecurefunc("ChatEdit_CustomTabPressed", updateTabChannelSwitch)

    if cfg.loot_icons then
        ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", addLootIcons)
    end

    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", removeRealmName)

    for i = 1, NUM_CHAT_WINDOWS do
        if i ~= 2 then
            hooksecurefunc(_G["ChatFrame" .. i], "AddMessage", typoHistoryPosthook)
        end
    end
end

function module:OnEnable()
    local function updateChatSize()
        if isScaling then return end
        isScaling = true

        ChatFrame1:ClearAllPoints()
        -- ChatFrame1:SetSize(cfg.width, cfg.height)
        if cfg.background then
            ChatFrame1:SetPoint(cfg.pos[1], cfg.pos[2], cfg.pos[3], cfg.pos[4], cfg.pos[5] + 4)
        else
            ChatFrame1:SetPoint(cfg.pos[1], cfg.pos[2], cfg.pos[3], cfg.pos[4], cfg.pos[5])
        end
        FCF_SavePositionAndDimensions(ChatFrame1)

        isScaling = false
    end

    for i = 1, NUM_CHAT_WINDOWS do
        local chat = _G[format("ChatFrame%s", i)]
        local id = chat:GetID()
        local _, fontSize = FCF_GetChatWindowInfo(id)

        if fontSize < 11 then
            FCF_SetChatWindowFontSize(nil, chat, 11)
        else
            FCF_SetChatWindowFontSize(nil, chat, fontSize)
        end

        chat:SetFont(STANDARD_TEXT_FONT, fontSize, "")
        chat:SetShadowOffset(1, -1)

        if i == 1 then
            updateChatSize()
        elseif i == 2 then
            if not cfg.combatlog then
                FCF_DockFrame(chat)
                ChatFrame2Tab:EnableMouse(false)
                ChatFrame2TabText:Hide()
                ChatFrame2Tab:SetWidth(0.001)
                ChatFrame2Tab.SetWidth = E.Dummy
                FCF_DockUpdate()
            end
        end

        chat:SetScript("OnMouseWheel", FloatingChatFrame_OnMouseScroll)
    end

    self:RegisterEvent("UI_SCALE_CHANGED", updateChatSize)

    hooksecurefunc(ChatFrame1, "SetPoint", function(_, _, _, _, x)
        if isScaling then return end
        if x ~= cfg.pos[4] then
            updateChatSize()
        end
    end)
end
