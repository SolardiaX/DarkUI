local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")

------------------------------------------------------------------------
-- Gossip Frame
-- Ported from AuroraClassic FrameXML/GossipFrame.lua (2026-06)
-- Dropped: Aurora noise overlay (B.CreateTex)
------------------------------------------------------------------------

local _G = _G
local select = select
local hooksecurefunc = hooksecurefunc
local gsub, strmatch = gsub, strmatch

local function replaceGossipFormat(button, textFormat, text)
    local newFormat, count = gsub(textFormat, "000000", "ffffff")
    if count > 0 then button:SetFormattedText(newFormat, text) end
end

local replacedGossipColor = {
    ["000000"] = "ffffff",
    ["414141"] = "7b8489",
}
local function replaceGossipText(button, text)
    if text and text ~= "" then
        local newText, count = gsub(text, ":32:32:0:0", ":32:32:0:0:64:64:5:59:5:59")
        if count > 0 then
            text = newText
            button:SetFormattedText("%s", text)
        end

        local colorStr, rawText = strmatch(text, "|c[fF][fF](%x%x%x%x%x%x)(.-)|r")
        colorStr = replacedGossipColor[colorStr]
        if colorStr and rawText then button:SetFormattedText("|cff%s%s|r", colorStr, rawText) end
    end
end

local function replaceTextColor(text, r)
    if r ~= 1 then text:SetTextColor(1, 1, 1) end
end

function S:Gossip()
    if not (C.skins.enable and C.skins.gossip) then return end

    _G.QuestFont:SetTextColor(1, 1, 1)

    S:ReskinButton(_G.GossipFrame.GreetingPanel.GoodbyeButton)
    S:ReskinTrimScrollBar(_G.GossipFrame.GreetingPanel.ScrollBar)

    hooksecurefunc(_G.GossipFrame.GreetingPanel.ScrollBox, "Update", function(self)
        for i = 1, self.ScrollTarget:GetNumChildren() do
            local button = select(i, self.ScrollTarget:GetChildren())
            if not button.__styled then
                local buttonText = button.GreetingText or (button.GetFontString and button:GetFontString())
                if buttonText then
                    buttonText:SetTextColor(1, 1, 1)
                    hooksecurefunc(buttonText, "SetTextColor", replaceTextColor)
                end
                if button.SetText then
                    local fstr = select(3, button:GetRegions())
                    if fstr and fstr:IsObjectType("FontString") then
                        replaceGossipText(button, button:GetText())
                        hooksecurefunc(button, "SetText", replaceGossipText)
                        hooksecurefunc(button, "SetFormattedText", replaceGossipFormat)
                    end
                end

                button.__styled = true
            end
        end
    end)

    for i = 1, 4 do
        local notch = _G.GossipFrame.FriendshipStatusBar["Notch" .. i]
        if notch then
            notch:SetColorTexture(0, 0, 0)
            notch:SetSize(E.mult, 16)
        end
    end
    _G.GossipFrame.FriendshipStatusBar.BarBorder:Hide()

    _G.GossipFrameInset:Hide()
    if _G.GossipFrame.Background then _G.GossipFrame.Background:Hide() end
    S:ReskinPortraitFrame(_G.GossipFrame)

    -- Text on QuestFrame
    _G.QuestFrameGreetingPanel:HookScript("OnShow", function(self)
        for button in self.titleButtonPool:EnumerateActive() do
            if not button.__styled then
                replaceGossipText(button, button:GetText())
                hooksecurefunc(button, "SetFormattedText", replaceGossipFormat)

                button.__styled = true
            end
        end
    end)
end

S:AddCallback("Gossip")
