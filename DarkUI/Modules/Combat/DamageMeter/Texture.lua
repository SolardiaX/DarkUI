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
local SPEC_ICON_ATLAS = C.media.texture.class_spec
local BAR_HEIGHT = 6
local ICON_SIZE = 16
local FONT_SIZE = 12
local FONT_FLAG = "OUTLINE"
local SHADOW_X, SHADOW_Y = 1, -1
local WINDOW_POS = { "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -4, 70 }

local SCROLL_TOP_INSET = 28
local SCROLL_BOTTOM_INSET = 4
local SCROLL_LEFT_INSET = 4
local SCROLL_RIGHT_INSET = 10

------------------------------------------------------------------------
-- Spec icon atlas (tex_class_spec, 512x512, 64px grid)
--
-- Maps a unit's spec to a cell of the shared spec-icon atlas. The atlas
-- shares the same grid layout as HDSkada's HDspec.tga, so the coordinate
-- table is reused verbatim. See DarkUI/REFERENCES.md.
------------------------------------------------------------------------

-- Blizzard spec icon FileDataID -> specID (the icon Blizzard sets on each entry)
local FILEID_TO_SPECID = {
    [608952] = 270,
    [608953] = 269,
    [608951] = 268,
    [136145] = 265,
    [136172] = 266,
    [136186] = 267,
    [135932] = 62,
    [135810] = 63,
    [135846] = 64,
    [4511811] = 1467,
    [4511812] = 1468,
    [5198700] = 1473,
    [1247264] = 577,
    [1247265] = 581,
    [7455385] = 1480,
    [7455386] = 1480,
    [4574311] = 1465,
    [135940] = 256,
    [237542] = 257,
    [136207] = 258,
    [461112] = 253,
    [236179] = 254,
    [461113] = 255,
    [135920] = 65,
    [236264] = 66,
    [135873] = 70,
    [136048] = 262,
    [237581] = 263,
    [136052] = 264,
    [136096] = 102,
    [132115] = 103,
    [132276] = 104,
    [136041] = 105,
    [132355] = 71,
    [132347] = 72,
    [132341] = 73,
    [135770] = 250,
    [135773] = 251,
    [135775] = 252,
    [236270] = 259,
    [236286] = 260,
    [132320] = 261,
}

-- specID -> { left, right, top, bottom } texcoords in the atlas
local SPECID_TO_COORDS = {
    [577] = { 128 / 512, 192 / 512, 256 / 512, 320 / 512 },
    [581] = { 192 / 512, 256 / 512, 256 / 512, 320 / 512 },
    [1480] = { 448 / 512, 512 / 512, 256 / 512, 320 / 512 },
    [250] = { 0, 64 / 512, 0, 64 / 512 },
    [251] = { 64 / 512, 128 / 512, 0, 64 / 512 },
    [252] = { 128 / 512, 192 / 512, 0, 64 / 512 },
    [102] = { 192 / 512, 256 / 512, 0, 64 / 512 },
    [103] = { 256 / 512, 320 / 512, 0, 64 / 512 },
    [104] = { 320 / 512, 384 / 512, 0, 64 / 512 },
    [105] = { 384 / 512, 448 / 512, 0, 64 / 512 },
    [253] = { 448 / 512, 512 / 512, 0, 64 / 512 },
    [254] = { 0, 64 / 512, 64 / 512, 128 / 512 },
    [255] = { 64 / 512, 128 / 512, 64 / 512, 128 / 512 },
    [62] = { (128 / 512) + 0.001953125, 192 / 512, 64 / 512, 128 / 512 },
    [63] = { 192 / 512, 256 / 512, 64 / 512, 128 / 512 },
    [64] = { 256 / 512, 320 / 512, 64 / 512, 128 / 512 },
    [268] = { 320 / 512, 384 / 512, 64 / 512, 128 / 512 },
    [269] = { 448 / 512, 512 / 512, 64 / 512, 128 / 512 },
    [270] = { 384 / 512, 448 / 512, 64 / 512, 128 / 512 },
    [65] = { 0, 64 / 512, 128 / 512, 192 / 512 },
    [66] = { 64 / 512, 128 / 512, 128 / 512, 192 / 512 },
    [70] = { (128 / 512) + 0.001953125, 192 / 512, 128 / 512, 192 / 512 },
    [256] = { 192 / 512, 256 / 512, 128 / 512, 192 / 512 },
    [257] = { 256 / 512, 320 / 512, 128 / 512, 192 / 512 },
    [258] = { (320 / 512) + (0.001953125 * 4), 384 / 512, 128 / 512, 192 / 512 },
    [259] = { 384 / 512, 448 / 512, 128 / 512, 192 / 512 },
    [260] = { 448 / 512, 512 / 512, 128 / 512, 192 / 512 },
    [261] = { 0, 64 / 512, 192 / 512, 256 / 512 },
    [262] = { 64 / 512, 128 / 512, 192 / 512, 256 / 512 },
    [263] = { 128 / 512, 192 / 512, 192 / 512, 256 / 512 },
    [264] = { 192 / 512, 256 / 512, 192 / 512, 256 / 512 },
    [265] = { 256 / 512, 320 / 512, 192 / 512, 256 / 512 },
    [266] = { 320 / 512, 384 / 512, 192 / 512, 256 / 512 },
    [267] = { 384 / 512, 448 / 512, 192 / 512, 256 / 512 },
    [71] = { 448 / 512, 512 / 512, 192 / 512, 256 / 512 },
    [72] = { 0, 64 / 512, 256 / 512, 320 / 512 },
    [73] = { 64 / 512, 128 / 512, 256 / 512, 320 / 512 },
    [1467] = { 256 / 512, 320 / 512, 256 / 512, 320 / 512 },
    [1468] = { 320 / 512, 384 / 512, 256 / 512, 320 / 512 },
    [1473] = { 384 / 512, 448 / 512, 256 / 512, 320 / 512 },
    [1465] = { 256 / 512, 320 / 512, 256 / 512, 320 / 512 },
}

-- Class -> default specID, used when the entry exposes a class but no spec icon
local CLASS_TO_DEFAULT_SPEC = {
    DEATHKNIGHT = 250,
    DEMONHUNTER = 577,
    DRUID = 102,
    EVOKER = 1467,
    HUNTER = 253,
    MAGE = 62,
    MONK = 268,
    PALADIN = 65,
    PRIEST = 256,
    ROGUE = 259,
    SHAMAN = 262,
    WARLOCK = 265,
    WARRIOR = 71,
}

-- Non-class affiliations (pets, enemies, factions) -> a representative specID
local FALLBACK_CLASS_TO_SPEC = {
    PET = 253,
    ENEMY = 71,
    MONSTER = 71,
    UNGROUPPLAYER = 71,
    UNKNOW = 71,
    Alliance = 65,
    Horde = 71,
}

------------------------------------------------------------------------
-- Caches
------------------------------------------------------------------------

local StyledCache = setmetatable({}, { __mode = "k" })
local WindowCache = setmetatable({}, { __mode = "k" })
local ScrollBoxHookCache = setmetatable({}, { __mode = "k" })
local ScrollBarCache = setmetatable({}, { __mode = "k" })
local LocalPlayerHookCache = setmetatable({}, { __mode = "k" })
local IconHookCache = setmetatable({}, { __mode = "k" })

------------------------------------------------------------------------
-- Spec icon
------------------------------------------------------------------------

local function getPlayerSpecID()
    local index = C_SpecializationInfo.GetSpecialization()
    if not index then
        return
    end
    return (GetSpecializationInfo(index))
end

local function applySpecIcon(entry, data)
    if not entry or entry.spellID then
        return
    end

    local iconTex = entry.Icon and entry.Icon.Icon or entry.Icon
    if not iconTex or not iconTex.SetTexture then
        return
    end

    local specID
    local fileID = (data and data.specIconID) or entry.specIconID
    if fileID then
        specID = FILEID_TO_SPECID[tonumber(fileID) or fileID]
    end

    if not specID then
        local isPlayer = entry == (_G.DamageMeter and _G.DamageMeter.LocalPlayerEntry) or (data and data.isLocalPlayer)
        if isPlayer then
            specID = getPlayerSpecID()
        end
    end

    local coords = specID and SPECID_TO_COORDS[specID]
    if not coords and entry.classFilename then
        local fallback = CLASS_TO_DEFAULT_SPEC[entry.classFilename] or FALLBACK_CLASS_TO_SPEC[entry.classFilename]
        coords = fallback and SPECID_TO_COORDS[fallback]
    end

    if coords then
        iconTex:SetTexture(SPEC_ICON_ATLAS)
        iconTex:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    end
end

------------------------------------------------------------------------
-- Entry styling
------------------------------------------------------------------------

local function styleEntry(entry)
    if not entry or not entry.StatusBar then
        return
    end
    if StyledCache[entry] then
        return
    end

    local bar = entry.StatusBar

    local iconFrame
    for _, child in ipairs({ entry:GetChildren() }) do
        if child ~= bar then
            iconFrame = child
            break
        end
    end

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

    if entry.UpdateIcon and not IconHookCache[entry] then
        hooksecurefunc(entry, "UpdateIcon", applySpecIcon)
        IconHookCache[entry] = true
    end
    applySpecIcon(entry)

    StyledCache[entry] = true
end

------------------------------------------------------------------------
-- Header
------------------------------------------------------------------------

local function hideHeader(window)
    if not window or not window.Header then
        return
    end
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
    if not scrollBar or ScrollBarCache[scrollBar] then
        return
    end
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
    if not scrollBox then
        return
    end

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
            if updating then
                return
            end
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
    if not sourceWindow or WindowCache[sourceWindow] then
        return
    end

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
    local entry = (window.MinimizeContainer and window.MinimizeContainer.LocalPlayerEntry) or window.LocalPlayerEntry
    if not entry then
        return
    end
    entry:Hide()
    entry:SetAlpha(0)
    entry:EnableMouse(false)
end

local function hookLocalPlayer(window)
    if LocalPlayerHookCache[window] then
        return
    end
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
    if not window then
        return
    end
    if WindowCache[window] then
        return
    end

    hideHeader(window)
    desaturateHeaderButtons(window)
    skinScrollArea(window)

    local sourceWin = (window.MinimizeContainer and window.MinimizeContainer.SourceWindow) or window.SourceWindow
    if sourceWin then
        skinSourceWindow(sourceWin)
    end

    local background = window.MinimizeContainer and window.MinimizeContainer.Background or nil
    if background then
        C_Timer_After(0, function()
            background:SetAlpha(0)
        end)
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
