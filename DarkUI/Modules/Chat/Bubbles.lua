local E, C, L = select(2, ...):unpack()

if not C.chat.enable or IsAddOnLoaded("NiceBubbles") then return end

----------------------------------------------------------------------------------------
--  Bubbles Style (modified from DiabolicUI)
----------------------------------------------------------------------------------------

-- Lua API
local _G = _G

local math_abs = math.abs
local math_floor = math.floor
local pairs = pairs
local select = select

-- WoW API
local CreateFrame = _G.CreateFrame
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent
local WorldFrame = _G.WorldFrame

-- Bubble Data
local bubbles = {} -- local bubble registry
local numChildren, numBubbles = -1, 0 -- bubble counters

local fontsize = 14 -- bubble font size
local offsetX, offsetY = 0, -100 -- bubble offset from its original position

-- Textures
local BLANK_TEXTURE = [[Interface\ChatFrame\ChatFrameBackground]]
local BUBBLE_TEXTURE = [[Interface\Tooltips\ChatBubble-Background]]
local TOOLTIP_BORDER = [[Interface\Tooltips\UI-Tooltip-Border]]

local getPadding = function()
    return fontsize / 1.2
end

-- let the bubble size scale from 400 to 660ish (font size 22)
local getMaxWidth = function()
    return 400 + math_floor((fontsize - 12) / 22 * 260)
end

local getBackdrop = function(scale)
    return {
        bgFile   = BLANK_TEXTURE,
        edgeFile = TOOLTIP_BORDER,
        edgeSize = 16 * scale,
        insets   = {
            left   = 2.5 * scale,
            right  = 2.5 * scale,
            top    = 2.5 * scale,
            bottom = 2.5 * scale
        }
    }
end

------------------------------------------------------------------------------
-- 	Namebubble Detection & Update Cycle
------------------------------------------------------------------------------
-- this needs to run even when the UI is hidden
local Updater = CreateFrame("Frame", nil, WorldFrame)
Updater:SetFrameStrata("TOOLTIP")

-- check whether the given frame is a bubble or not
Updater.IsBubble = function(_, bubble)
    if (bubble.IsForbidden and bubble:IsForbidden()) then
        return
    end
    local name = bubble.GetName and bubble:GetName()
    local region = bubble.GetRegions and bubble:GetRegions()
    if name or not region then
        return
    end
    local texture = region.GetTexture and region:GetTexture()
    return texture and texture == BUBBLE_TEXTURE
end

Updater.OnUpdate = function(self)
    local children = select("#", WorldFrame:GetChildren())
    if numChildren ~= children then
        for i = 1, children do
            local frame = select(i, WorldFrame:GetChildren())
            if not (bubbles[frame]) and self:IsBubble(frame) then
                self:InitBubble(frame)
            end
        end
        numChildren = children
    end

    -- bubble, bubble.text = original bubble and message
    -- bubbles[bubble], bubbles[bubble].text = our custom bubble and message
    local scale = WorldFrame:GetHeight() / UIParent:GetHeight()
    for bubble in pairs(bubbles) do
        local msg = bubble and bubble.text:GetText()
        if bubble:IsShown() and msg and (msg ~= "") then
            -- continuing the fight against overlaps blending into each other!
            bubbles[bubble]:SetFrameLevel(bubble:GetFrameLevel()) -- this works?

            local blizzTextWidth = math_floor(bubble.text:GetWidth())
            local blizzTextHeight = math_floor(bubble.text:GetHeight())
            local point, _, rpoint, blizzX, blizzY = bubble.text:GetPoint()
            local r, g, b = bubble.text:GetTextColor()
            bubbles[bubble].color[1] = r
            bubbles[bubble].color[2] = g
            bubbles[bubble].color[3] = b
            if blizzTextWidth and blizzTextHeight and point and rpoint and blizzX and blizzY then
                if (not bubbles[bubble]:IsShown()) then
                    bubbles[bubble]:Show()
                end
                local msg = bubble.text:GetText()
                if msg and (bubbles[bubble].last ~= msg) then
                    bubbles[bubble].text:SetText(msg or "")
                    bubbles[bubble].text:SetTextColor(r, g, b)
                    bubbles[bubble].last = msg
                    local sWidth = bubbles[bubble].text:GetStringWidth()
                    local maxWidth = getMaxWidth()
                    if sWidth > maxWidth then
                        bubbles[bubble].text:SetWidth(maxWidth)
                    else
                        bubbles[bubble].text:SetWidth(sWidth)
                    end
                end
                local space = getPadding()
                local ourTextWidth = bubbles[bubble].text:GetWidth()
                local ourTextHeight = bubbles[bubble].text:GetHeight()
                local ourX = math_floor(offsetX + (blizzX - blizzTextWidth / 2) / scale - (ourTextWidth - blizzTextWidth) / 2) -- chatbubbles are rendered at BOTTOM, WorldFrame, BOTTOMLEFT, x, y
                local ourY = math_floor(offsetY + blizzY / scale - (ourTextHeight - blizzTextHeight) / 2) -- get correct bottom coordinate
                local ourWidth = math_floor(ourTextWidth + space * 2)
                local ourHeight = math_floor(ourTextHeight + space * 2)
                bubbles[bubble]:Hide() -- hide while sizing and moving, to gain fps
                bubbles[bubble]:SetSize(ourWidth, ourHeight)
                local oldX, oldY = select(4, bubbles[bubble]:GetPoint())
                if not (oldX and oldY) or ((math_abs(oldX - ourX) > .5) or (math_abs(oldY - ourY) > .5)) then
                    -- avoid updates if we can. performance.
                    bubbles[bubble]:ClearAllPoints()
                    bubbles[bubble]:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", ourX, ourY)
                end
                bubbles[bubble]:SetBackdropColor(0, 0, 0, .5)
                bubbles[bubble]:SetBackdropBorderColor(0, 0, 0, .25)
                bubbles[bubble]:Show() -- show the bubble again
            end
            bubble.text:SetTextColor(r, g, b, 0)
        else
            if bubbles[bubble]:IsShown() then
                bubbles[bubble]:Hide()
            else
                bubbles[bubble].last = nil -- to avoid repeated messages not being shown
            end
        end
    end
end

Updater.HideBlizzard = function(_, bubble)
    local r, g, b = bubble.text:GetTextColor()
    bubbles[bubble].color[1] = r
    bubbles[bubble].color[2] = g
    bubbles[bubble].color[3] = b
    bubble.text:SetTextColor(r, g, b, 0)
    for region, _ in pairs(bubbles[bubble].regions) do
        region:SetTexture(nil)
    end
end

Updater.ShowBlizzard = function(_, bubble)
    bubble.text:SetTextColor(bubbles[bubble].color[1], bubbles[bubble].color[2], bubbles[bubble].color[3], 1)
    for region, texture in pairs(bubbles[bubble].regions) do
        region:SetTexture(texture)
    end
end

Updater.InitBubble = function(self, bubble)
    numBubbles = numBubbles + 1

    local space = getPadding()
    bubbles[bubble] = CreateFrame("Frame", nil, self.BubbleBox, "BackdropTemplate")
    bubbles[bubble]:Hide()
    bubbles[bubble]:SetFrameStrata("BACKGROUND")
    bubbles[bubble]:SetFrameLevel(numBubbles % 128 + 1) -- try to avoid overlapping bubbles blending into each other
    bubbles[bubble]:SetBackdrop(getBackdrop(1))

    bubbles[bubble].text = bubbles[bubble]:CreateFontString()
    bubbles[bubble].text:SetPoint("BOTTOMLEFT", space, space)
    bubbles[bubble].text:SetFontObject(ChatFontNormal)
    bubbles[bubble].text:SetFont(ChatFontNormal:GetFont(), fontsize, "")
    bubbles[bubble].text:SetShadowOffset(-.75, -.75)
    bubbles[bubble].text:SetShadowColor(0, 0, 0, 1)

    bubbles[bubble].regions = {}
    bubbles[bubble].color = { 1, 1, 1, 1 }

    -- gather up info about the existing blizzard bubble
    for i = 1, bubble:GetNumRegions() do
        local region = select(i, bubble:GetRegions())
        if region:GetObjectType() == "Texture" then
            bubbles[bubble].regions[region] = region:GetTexture()
        elseif region:GetObjectType() == "FontString" then
            bubble.text = region
        end
    end

    -- hide the blizzard bubble
    self:HideBlizzard(bubble)
end

Updater.UpdateBubbleDisplay = function(self)
    local _, instanceType = IsInInstance()

    if (instanceType == "none") then
        --SetCVar("chatBubbles", 1)
        self:SetScript("OnUpdate", self.OnUpdate)
    else
        self:SetScript("OnUpdate", nil)
        --SetCVar("chatBubbles", 0)
        --for bubble in pairs(bubbles) do
        --    bubbles[bubble]:Hide()
        --end
    end
end

Updater.OnEvent = function(self, event)
    -- Enforcing this now
    if event == "PLAYER_LOGIN" then
        -- this will be our bubble parent
        self.BubbleBox = CreateFrame("Frame", nil, UIParent)
        self.BubbleBox:SetAllPoints()
        self.BubbleBox:Show()

        SetCVar("chatBubbles", 1)

        for bubble in pairs(bubbles) do
            self:HideBlizzard(bubble)
        end
    end

    self:UpdateBubbleDisplay()
end

Updater:RegisterEvent("PLAYER_LOGIN")
Updater:RegisterEvent("PLAYER_ENTERING_WORLD")
Updater:SetScript("OnEvent", Updater.OnEvent)

-- Escape the dungeon
tinsert(UISpecialFrames, "Updater")