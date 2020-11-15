local E, C, L = select(2, ...):unpack()

if not C.chat.enable and not C.chat.chat_bar then return end

----------------------------------------------------------------------------------------
--  ChatBar (FavChatBar by Favorit)
----------------------------------------------------------------------------------------

local CreateFrame = CreateFrame
local ChatFrame_OpenChat = ChatFrame_OpenChat
local SELECTED_DOCK_FRAME = SELECTED_DOCK_FRAME
local UIParent = UIParent

local cfg = C.chat

local function CreateButton(f, b, l, r, m)
    b:SetSize(16, 16)

    b:CreateTextureBorder(1)
    b:CreateShadow()

    b.texture = b:CreateTexture(nil, "ARTWORK")
    b.texture:SetTexture(C.media.texture.status)
    b.texture:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
    b.texture:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)

    b.highlight = b:CreateTexture(nil, "HIGHLIGHT")
    b.highlight:SetTexture(1, 1, 1, 0.35)
    b.highlight:SetAllPoints(b.texture)

    b:RegisterForClicks("AnyUp")
    b:SetScript("OnClick", function(_, btn)
        if btn == "LeftButton" then
            ChatFrame_OpenChat(l, SELECTED_DOCK_FRAME)
        elseif btn == "RightButton" then
            ChatFrame_OpenChat(r, SELECTED_DOCK_FRAME)
        elseif m and btn == "MiddleButton" then
            ChatFrame_OpenChat(m, SELECTED_DOCK_FRAME)
        end
    end)

    if cfg.chat_bar_mouseover == true then
        b:SetScript("OnEnter", function() f:FadeIn() end)
        b:SetScript("OnLeave", function() f:FadeOut() end)
    end
end

local frame = CreateFrame("Frame", "ChatBar", UIParent)
frame:SetWidth(16)
frame:SetHeight(cfg.background and cfg.height + 4 or cfg.height - 1)
frame:SetPoint("BOTTOMLEFT", UIParent, 2, cfg.background and 30 or 26)

if cfg.chat_bar_mouseover == true then
    frame:SetAlpha(0)
    frame:SetScript("OnEnter", function() frame:FadeIn() end)
    frame:SetScript("OnLeave", function() frame:FadeOut() end)
end

local b1 = CreateFrame("Button", "$parentButton1", frame)
CreateButton(frame, b1, "/s", "/y")
b1:SetPoint("TOP", frame, "TOP", 0, 0)
b1.texture:SetVertexColor(0.8, 0.8, 0.8, 1)

local b2 = CreateFrame("Button", "$parentButton2", frame)
CreateButton(frame, b2, "/g", "/o")
b2:SetPoint("TOP", b1, "BOTTOM", 0, cfg.background and -4 or -3)
b2.texture:SetVertexColor(0, 0.8, 0, 1)

local b3 = CreateFrame("Button", "$parentButton3", frame)
CreateButton(frame, b3, "/p", "/i")
b3:SetPoint("TOP", b2, "BOTTOM", 0, cfg.background and -4 or -3)
b3.texture:SetVertexColor(0.11, 0.5, 0.7, 1)

local b4 = CreateFrame("Button", "$parentButton4", frame)
CreateButton(frame, b4, "/ra", "/rw")
b4:SetPoint("TOP", b3, "BOTTOM", 0, cfg.background and -4 or -3)
b4.texture:SetVertexColor(1, 0.3, 0, 1)

local b5 = CreateFrame("Button", "$parentButton5", frame)
CreateButton(frame, b5, "/1", "/2")
b5:SetPoint("TOP", b4, "BOTTOM", 0, cfg.background and -4 or -3)
b5.texture:SetVertexColor(0.93, 0.8, 0.8, 1)

local b6 = CreateFrame("Button", "$parentButton6", frame)
CreateButton(frame, b6, "/3", "/4")
b6:SetPoint("TOP", b5, "BOTTOM", 0, cfg.background and -4 or -3)
b6.texture:SetVertexColor(1, 0.75, 0.75, 1)
