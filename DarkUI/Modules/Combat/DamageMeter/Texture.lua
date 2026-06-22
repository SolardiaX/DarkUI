local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- DamageMeter Texture (fixed style: thin bar + floating text + edge mode)
------------------------------------------------------------------------

local module = E:Module("Combat"):Sub("DamageMeter")

------------------------------------------------------------------------
-- Constants
------------------------------------------------------------------------

local C_Timer_After = C_Timer.After

local BAR_TEXTURE = C.media.texture.gradient_rev
local BAR_HEIGHT = 6
local ICON_SIZE = 16
local FONT_SIZE = 12
local FONT_FLAG = "OUTLINE"
local SHADOW_X, SHADOW_Y = 1, -1
local WINDOW_WIDTH = 360
local WINDOW_POS = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -4, 70 }

local SCROLL_TOP_INSET = 28
local SCROLL_BOTTOM_INSET = 4
local SCROLL_LEFT_INSET = 4
local SCROLL_RIGHT_INSET = 10

------------------------------------------------------------------------
-- Caches
------------------------------------------------------------------------

local StyledCache = setmetatable({}, { __mode = "k" })
local WindowCache = setmetatable({}, { __mode = "k" })
local ScrollBoxHookCache = setmetatable({}, { __mode = "k" })
local ScrollBarCache = setmetatable({}, { __mode = "k" })
local LocalPlayerHookCache = setmetatable({}, { __mode = "k" })

------------------------------------------------------------------------
-- Entry styling
------------------------------------------------------------------------

local function styleEntry(entry)
    if not entry or not entry.StatusBar then return end
    if StyledCache[entry] then return end

    local bar = entry.StatusBar

    local iconFrame
    for _, child in ipairs({ entry:GetChildren() }) do
        if child ~= bar then
            iconFrame = child
            break
        end
    end

    bar:ClearAllPoints()
    bar:SetPoint("BOTTOMLEFT", entry, "BOTTOMLEFT", ICON_SIZE + 8, 2)
    bar:SetPoint("BOTTOMRIGHT", entry, "BOTTOMRIGHT", -2, 2)
    bar:SetHeight(BAR_HEIGHT)
    bar:SetStatusBarTexture(BAR_TEXTURE)
    bar:SetTemplate("default")
    bar:CreateShadow()

    if bar.Background then
        bar.Background:ClearAllPoints()
        bar.Background:SetAllPoints(bar)
        bar.Background:SetColorTexture(0, 0, 0, 0)
    end
    if bar.BackgroundEdge then
        bar.BackgroundEdge:SetAlpha(0)
    end

    if iconFrame then
        iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
        iconFrame:ClearAllPoints()
        iconFrame:SetPoint("LEFT", entry, "LEFT", 4, -4)
    end

    if bar.Name then
        bar.Name:ClearAllPoints()
        bar.Name:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 2, -6)
        bar.Name:SetPoint("RIGHT", entry, "RIGHT", -80, 0)
        bar.Name:SetFont(STANDARD_TEXT_FONT, FONT_SIZE, FONT_FLAG)
        bar.Name:SetShadowOffset(SHADOW_X, SHADOW_Y)
    end

    if bar.Value then
        bar.Value:ClearAllPoints()
        bar.Value:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", -2, -6)
        bar.Value:SetFont(STANDARD_TEXT_FONT, FONT_SIZE, FONT_FLAG)
        bar.Value:SetShadowOffset(SHADOW_X, SHADOW_Y)
    end

    StyledCache[entry] = true
end

------------------------------------------------------------------------
-- Header
------------------------------------------------------------------------

local function hideHeader(window)
    if not window or not window.Header then return end
    window.Header:SetTexture(nil)
    window.Header:SetAtlas(nil)
    window.Header:SetColorTexture(0, 0, 0, 0)
    window.Header:Hide()
end

local function desaturateHeaderButtons(window)
    local buttons = {
        window.SettingsDropdown,
        window.SessionDropdown,
        window.MinimizeButton,
        window.DamageMeterTypeDropdown,
    }
    for _, btn in ipairs(buttons) do
        if btn and btn.GetRegions then
            for _, region in ipairs({ btn:GetRegions() }) do
                if region.SetDesaturated then
                    region:SetDesaturated(true)
                    region:SetVertexColor(0.7, 0.7, 0.7, 1)
                end
            end
        end
    end
end

------------------------------------------------------------------------
-- ScrollBar / ScrollBox
------------------------------------------------------------------------

local function hideScrollBar(scrollBar)
    if not scrollBar or ScrollBarCache[scrollBar] then return end
    scrollBar:SetAlpha(0)
    scrollBar:EnableMouse(false)
    scrollBar:SetWidth(1)
    if scrollBar.Track then
        scrollBar.Track:SetAlpha(0)
        scrollBar.Track:EnableMouse(false)
        if scrollBar.Track.Thumb then
            scrollBar.Track.Thumb:SetAlpha(0)
            scrollBar.Track.Thumb:EnableMouse(false)
        end
    end
    if scrollBar.Back then
        scrollBar.Back:SetAlpha(0)
        scrollBar.Back:EnableMouse(false)
    end
    if scrollBar.Forward then
        scrollBar.Forward:SetAlpha(0)
        scrollBar.Forward:EnableMouse(false)
    end
    ScrollBarCache[scrollBar] = true
end

local function forceScrollBoxAnchors(scrollBox, window)
    scrollBox:ClearAllPoints()
    scrollBox:SetPoint("TOPLEFT", window, "TOPLEFT", SCROLL_LEFT_INSET, -SCROLL_TOP_INSET)
    scrollBox:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -SCROLL_RIGHT_INSET, SCROLL_BOTTOM_INSET)
end

local function skinScrollArea(window)
    local scrollBar = window.ScrollBar or (window.GetScrollBar and window:GetScrollBar())
    if scrollBar then
        hideScrollBar(scrollBar)
    end

    local scrollBox = window.ScrollBox or (window.GetScrollBox and window:GetScrollBox())
    if not scrollBox then return end

    forceScrollBoxAnchors(scrollBox, window)

    if not ScrollBoxHookCache[scrollBox] then
        hooksecurefunc(scrollBox, "Update", function(self)
            C_Timer_After(0, function()
                if self.ForEachFrame then
                    self:ForEachFrame(function(entry)
                        StyledCache[entry] = nil
                        styleEntry(entry)
                    end)
                end
            end)
        end)

        local updating = false
        hooksecurefunc(scrollBox, "SetPoint", function(self, point)
            if updating then return end
            if point == "TOPLEFT" or point == "BOTTOMRIGHT" then
                updating = true
                forceScrollBoxAnchors(self, window)
                updating = false
            end
        end)

        ScrollBoxHookCache[scrollBox] = true
    end
end

------------------------------------------------------------------------
-- SourceWindow
------------------------------------------------------------------------

local function skinSourceWindow(sourceWindow)
    if not sourceWindow or WindowCache[sourceWindow] then return end

    local scrollBar = sourceWindow.ScrollBar or (sourceWindow.GetScrollBar and sourceWindow:GetScrollBar())
    if scrollBar then
        hideScrollBar(scrollBar)
    end

    local scrollBox = sourceWindow.ScrollBox or (sourceWindow.GetScrollBox and sourceWindow:GetScrollBox())
    if scrollBox and not ScrollBoxHookCache[scrollBox] then
        hooksecurefunc(scrollBox, "Update", function(self)
            C_Timer_After(0, function()
                if self.ForEachFrame then
                    self:ForEachFrame(styleEntry)
                end
            end)
        end)
        ScrollBoxHookCache[scrollBox] = true
    end

    if sourceWindow.Refresh and not sourceWindow._dkHookedRefresh then
        hooksecurefunc(sourceWindow, "Refresh", function(self)
            C_Timer_After(0, function()
                local sb = self.ScrollBox or (self.GetScrollBox and self:GetScrollBox())
                if sb and sb.ForEachFrame then
                    sb:ForEachFrame(styleEntry)
                end
            end)
        end)
        sourceWindow._dkHookedRefresh = true
    end

    WindowCache[sourceWindow] = true
end

------------------------------------------------------------------------
-- LocalPlayer
------------------------------------------------------------------------

local function hideLocalPlayer(window)
    local entry = (window.MinimizeContainer and window.MinimizeContainer.LocalPlayerEntry)
        or window.LocalPlayerEntry
    if not entry then return end
    entry:Hide()
    entry:SetAlpha(0)
    entry:EnableMouse(false)
end

local function hookLocalPlayer(window)
    if LocalPlayerHookCache[window] then return end
    LocalPlayerHookCache[window] = true

    hideLocalPlayer(window)

    if window.ShowLocalPlayerEntry then
        hooksecurefunc(window, "ShowLocalPlayerEntry", function(self)
            hideLocalPlayer(self)
        end)
    end
end

------------------------------------------------------------------------
-- Window scanning
------------------------------------------------------------------------

local function scanWindow(window)
    if not window then return end
    if WindowCache[window] then return end

    window:SetWidth(WINDOW_WIDTH)

    hideHeader(window)
    desaturateHeaderButtons(window)
    skinScrollArea(window)

    local sourceWin = (window.MinimizeContainer and window.MinimizeContainer.SourceWindow)
        or window.SourceWindow
    if sourceWin then
        skinSourceWindow(sourceWin)
    end

    if module.cfg.hideLocalPlayer then
        hookLocalPlayer(window)
    end

    WindowCache[window] = true
end

------------------------------------------------------------------------
-- Init / Refresh
------------------------------------------------------------------------

module.Texture = {}

function module.Texture:Init()
    if _G.DamageMeter then
        hooksecurefunc(_G.DamageMeter, "Show", function()
            C_Timer_After(0, function()
                _G.DamageMeter:SetSize(WINDOW_WIDTH, 200)
                _G.DamageMeter:ClearAllPoints()
                _G.DamageMeter:SetPoint(unpack(WINDOW_POS))
            end)
        end)
    end

    if _G.DamageMeter and _G.DamageMeter.SetupSessionWindow then
        hooksecurefunc(_G.DamageMeter, "SetupSessionWindow", function(_, windowOrIndex)
            C_Timer_After(0, function()
                local window = windowOrIndex
                if type(windowOrIndex) == "number" then
                    window = _G["DamageMeterSessionWindow" .. windowOrIndex]
                end
                scanWindow(window)
            end)
        end)
    end

    module:ForEachWindow(scanWindow)
end

function module.Texture:Refresh()
    module:ForEachWindow(function(window)
        WindowCache[window] = nil
        scanWindow(window)
    end)
end
