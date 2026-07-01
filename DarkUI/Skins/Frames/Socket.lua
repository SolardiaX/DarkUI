local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Item Socketing UI
-- Ported from AuroraClassic AddOns/Blizzard_ItemSocketingUI.lua (2026-06)
------------------------------------------------------------------------

local _G = _G
local ipairs = ipairs
local hooksecurefunc = hooksecurefunc

local GemTypeInfo = {
    Yellow = { r = 0.97, g = 0.82, b = 0.29 },
    Red = { r = 1, g = 0.47, b = 0.47 },
    Blue = { r = 0.47, g = 0.67, b = 1 },
    Hydraulic = { r = 1, g = 1, b = 1 },
    Cogwheel = { r = 1, g = 1, b = 1 },
    Meta = { r = 1, g = 1, b = 1 },
    Prismatic = { r = 1, g = 1, b = 1 },
    PunchcardRed = { r = 1, g = 0.47, b = 0.47 },
    PunchcardYellow = { r = 0.97, g = 0.82, b = 0.29 },
    PunchcardBlue = { r = 0.47, g = 0.67, b = 1 },
    Domination = { r = 0.24, g = 0.5, b = 0.7 },
    Cypher = { r = 1, g = 0.8, b = 0 },
    Tinker = { r = 1, g = 0.47, b = 0.47 },
    Primordial = { r = 1, g = 0, b = 1 },
    Fragrance = { r = 1, g = 1, b = 1 },
    SingingThunder = { r = 0.97, g = 0.82, b = 0.29 },
    SingingSea = { r = 0.47, g = 0.67, b = 1 },
    SingingWind = { r = 1, g = 0.47, b = 0.47 },
    Fiber = { r = 0.9, g = 0.8, b = 0.5 },
}

function S:ItemSocketingUI()
    if not (C.skins.enable and C.skins.socket) then return end

    local frame = _G.ItemSocketingFrame
    local socketingContainer = frame.SocketingContainer

    for _, socket in ipairs(socketingContainer.SocketFrames) do
        socket:StripTextures()
        socket:SetPushedTexture(0)
        socket:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
        socket.Icon:SetTexCoords()
        socket.bg = S:ReskinIcon(socket.Icon)

        socket.Shine:ClearAllPoints()
        socket.Shine:SetOutside()
        socket.BracketFrame:Hide()
        socket.Background:SetAlpha(0)
    end

    hooksecurefunc("ItemSocketingFrame_Update", function()
        for i, socket in ipairs(socketingContainer.SocketFrames) do
            if not socket:IsShown() then break end

            local color = GemTypeInfo[C_ItemSocketInfo.GetSocketTypes(i)] or GemTypeInfo.Cogwheel
            socket.bg:SetBackdropBorderColor(color.r, color.g, color.b)
        end

        _G.ItemSocketingDescription:HideBackdrop()
    end)

    S:ReskinPortraitFrame(frame)
    frame.BackgroundColor:SetAlpha(0)
    _G.ItemSocketingScrollFrame:CreateBackdrop()
    S:ReskinButton(socketingContainer.ApplySocketsButton)
    S:ReskinTrimScrollBar(_G.ItemSocketingScrollFrame.ScrollBar)
end

S:AddCallbackForAddon("Blizzard_ItemSocketingUI", "ItemSocketingUI")
