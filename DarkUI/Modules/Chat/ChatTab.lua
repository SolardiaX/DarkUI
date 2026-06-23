local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Chat Tabs (Fane)
------------------------------------------------------------------------

local module = E:Module("Chat"):Sub("ChatTab")

local _G = _G
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local cfg = C.chat

local function updateFS(self, _, ...)
    local fstring = self:GetFontString()
    fstring:SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
    fstring:SetShadowOffset(1, -1)
    if ... then fstring:SetTextColor(...) end
end

local function onEnter(self)
    local emphasis = _G["ChatFrame" .. self:GetID() .. "TabFlash"]:IsShown()
    updateFS(self, emphasis, E.myColor.r, E.myColor.g, E.myColor.b)
end

local function onLeave(self)
    local r, g, b
    local id = self:GetID()
    local emphasis = _G["ChatFrame" .. id .. "TabFlash"]:IsShown()

    if _G["ChatFrame" .. id] == SELECTED_CHAT_FRAME then
        r, g, b = E.myColor.r, E.myColor.g, E.myColor.b
    elseif emphasis then
        r, g, b = 1, 0, 0
    else
        r, g, b = 1, 1, 1
    end

    updateFS(self, emphasis, r, g, b)
end

local function chatFrame2SetAlpha(_, alpha)
    if CombatLogQuickButtonFrame_Custom then CombatLogQuickButtonFrame_Custom:SetAlpha(alpha) end
end

local function chatFrame2GetAlpha()
    if CombatLogQuickButtonFrame_Custom then return CombatLogQuickButtonFrame_Custom:GetAlpha() end
end

local function faneifyTab(frame, selected)
    local i = frame:GetID()

    if frame:GetParent() == _G.ChatConfigFrameChatTabManager then
        if selected then frame.Text:SetTextColor(1, 1, 1) end
        frame:SetAlpha(1)
    else
        if not frame.Fane then
            frame:HookScript("OnEnter", onEnter)
            frame:HookScript("OnLeave", onLeave)
            if not cfg.tabs_mouseover then
                frame:SetAlpha(1)
                if i ~= 2 then
                    frame.SetAlpha = UIFrameFadeRemoveFrame
                else
                    frame.SetAlpha = chatFrame2SetAlpha
                    frame.GetAlpha = chatFrame2GetAlpha
                    if CombatLogQuickButtonFrame_Custom then CombatLogQuickButtonFrame_Custom:SetAlpha(0.4) end
                end
            end
            frame.Fane = true
        end

        if i == SELECTED_CHAT_FRAME:GetID() then
            updateFS(frame, nil, E.myColor.r, E.myColor.g, E.myColor.b)
        else
            updateFS(frame, nil, 1, 1, 1)
        end
    end
end

function module:OnInit()
    if cfg.tabs_mouseover then
        CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
        CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
        CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
        CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
        CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
        CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
    end

    hooksecurefunc("FCF_StartAlertFlash", function(frame)
        local tab = _G["ChatFrame" .. frame:GetID() .. "Tab"]
        updateFS(tab, true, 1, 0, 0)
    end)

    hooksecurefunc("FCFTab_UpdateColors", faneifyTab)

    for i = 1, NUM_CHAT_WINDOWS do
        faneifyTab(_G["ChatFrame" .. i .. "Tab"])
    end

    if C_AddOns.IsAddOnLoaded("Blizzard_CombatLog") then
        if CombatLogQuickButtonFrame_Custom then CombatLogQuickButtonFrame_Custom:SetAlpha(0.4) end
    else
        local function onAddonLoaded(_, _, addon)
            if addon == "Blizzard_CombatLog" then
                self:UnregisterEvent("ADDON_LOADED", onAddonLoaded)
                if CombatLogQuickButtonFrame_Custom then CombatLogQuickButtonFrame_Custom:SetAlpha(0.4) end
            end
        end
        self:RegisterEvent("ADDON_LOADED", onAddonLoaded)
    end
end
