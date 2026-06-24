local E, C, L, DB = select(2, ...):unpack()

------------------------------------------------------------------------
-- Layout — LibEditModeOverride + Anchor (Mover)
------------------------------------------------------------------------

local string_format = string.format
local math_floor = math.floor

------------------------------------------------------------------------
-- LibEditModeOverride
------------------------------------------------------------------------

local LEMO = LibStub("LibEditModeOverride-1.0")
local lemoReady = false

local function initLEMO()
    if lemoReady then return end
    if not LEMO:IsReady() then return end
    lemoReady = true
    LEMO:LoadLayouts()
end

------------------------------------------------------------------------
-- Layout Registry (Edit Mode frames)
------------------------------------------------------------------------

local registry = {}

function E:RegisterLayoutFrame(frame, point) registry[#registry + 1] = { frame = frame, point = point } end

local function resolveFrame(entry)
    local f = entry.frame
    if type(f) == "string" then
        f = _G[f]
        if f then entry.frame = f end
    end
    return f
end

local function resolvePoint(entry)
    local p = entry.point
    if type(p) == "function" then return p() end
    return p
end

local function applyOverrides()
    if InCombatLockdown() then return end
    if not lemoReady then initLEMO() end
    if not lemoReady then return end

    LEMO:LoadLayouts()

    if not LEMO:CanEditActiveLayout() then return end

    local applied = false
    for _, entry in ipairs(registry) do
        local frame = resolveFrame(entry)
        local point = resolvePoint(entry)
        if frame and point and LEMO:HasEditModeSettings(frame) then
            LEMO:ReanchorFrame(frame, unpack(point))
            applied = true
        end
    end

    -- Skip ApplyChanges when nothing was reanchored: entering/exiting Edit Mode
    -- with no real change only taints Blizzard secure code (secret encounter values).
    if applied then LEMO:ApplyChanges() end
end

function E:ApplyLayoutOverrides() applyOverrides() end

local lemoFrame = CreateFrame("Frame")
lemoFrame:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
lemoFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
lemoFrame:SetScript("OnEvent", function()
    initLEMO()
    applyOverrides()
end)

------------------------------------------------------------------------
-- Anchor (Mover for non-Edit-Mode frames)
------------------------------------------------------------------------

local Colors = {
    highlight = { 250 / 255, 250 / 255, 250 / 255 },
    green = { 25 / 255, 178 / 255, 25 / 255 },
    normal = { 229 / 255, 178 / 255, 38 / 255 },
}

local Anchor = {}

-- Holder pattern (NDui/ElvUI style): the mover IS an independent holder placed at
-- the frame's anchor; the frame is pinned to the holder. Dragging the holder moves
-- the frame automatically (no per-frame SetPoint on drag), so SecureGroupHeaders
-- follow precisely and stay visible even when empty. Only the holder position is saved.
Anchor.Create = function(self, frame, name, vkey, width, height)
    local holder = CreateFrame("Button", nil, UIParent)

    for method, func in next, Anchor do
        if method ~= "Create" then holder[method] = func end
    end

    holder:Hide()
    holder:SetFrameStrata("HIGH")
    holder:SetFrameLevel(1000)
    holder:SetMovable(true)
    holder:SetClampedToScreen(true)
    holder:EnableMouse(true)
    holder:SetHitRectInsets(-8, -8, -8, -8)
    holder:RegisterForDrag("LeftButton")
    holder:RegisterForClicks("AnyUp")
    holder:SetScript("OnDragStart", self.OnDragStart)
    holder:SetScript("OnDragStop", self.OnDragStop)
    holder:SetScript("OnClick", self.OnClick)
    holder:SetScript("OnEnter", self.OnEnter)
    holder:SetScript("OnLeave", self.OnLeave)

    -- Size tracks the frame's live size so the holder matches the actually displayed
    -- frames; width/height are only a fallback for group headers that report 0 when empty.
    holder.frame = frame
    holder.minW = width
    holder.minH = height
    holder:SyncSize()

    -- Place the holder exactly where the frame currently sits, preserving its relativeTo,
    -- then pin the frame to the holder (same point, no offset) so it overlaps and follows.
    local point, relTo, relPoint, x, y = frame:GetPoint()
    point = point or "CENTER"
    relPoint = relPoint or point
    holder:SetPoint(point, relTo or UIParent, relPoint, x or 0, y or 0)

    frame:ClearAllPoints()
    frame:SetPoint(point, holder, point, 0, 0)

    local overlay = CreateFrame("Frame", nil, holder, "BackdropTemplate")
    overlay:SetAllPoints()
    overlay:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        tile = true,
        tileSize = 16,
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 },
    })
    overlay:SetBackdropColor(0.1, 0.6, 0.1, 0.55)
    overlay:SetBackdropBorderColor(0.2, 1, 0.2, 1)
    holder.overlay = overlay

    holder.name = overlay:CreateFontText(13, name)
    holder.name:SetTextColor(unpack(Colors.highlight))

    holder.hint = overlay:CreateFontText(11, "")
    holder.hint:ClearAllPoints()
    holder.hint:SetPoint("TOP", overlay, "BOTTOM", 0, -4)
    holder.hint:SetText("")

    holder.frame = frame
    holder.vkey = vkey
    holder.default = { point, relTo or UIParent, relPoint, x or 0, y or 0 }

    return holder
end

-- Match the holder to the frame's current size; fall back to the registered min size
-- when the frame reports ~0 (empty SecureGroupHeader with no members shown).
Anchor.SyncSize = function(self)
    local w, h = self.frame:GetWidth(), self.frame:GetHeight()
    if not w or w <= 1 then w = self.minW or 100 end
    if not h or h <= 1 then h = self.minH or 40 end
    self:SetSize(w, h)
end

Anchor.UpdateHint = function(self)
    local point, _, _, x, y = self:GetPoint()
    local msg = string_format(E:RGBToHex(Colors.highlight) .. "%s  %.0f, %.0f|r", point or "CENTER", x or 0, y or 0)
    msg = msg .. E:RGBToHex(Colors.green) .. "\n" .. L.UF_MOVER_HINT_DRAG .. "|r"
    msg = msg .. E:RGBToHex(Colors.green) .. "\n" .. L.UF_MOVER_HINT_RESET .. "|r"

    self.hint:SetText(msg)
    self.hint:Show()
end

Anchor.OnDragStart = function(self)
    if InCombatLockdown() then return end
    self:StartMoving()
    self.elapsed = 0
    self:SetScript("OnUpdate", self.OnUpdate)
end

Anchor.OnDragStop = function(self)
    self:StopMovingOrSizing()
    self:SetScript("OnUpdate", nil)

    local point, _, relPoint, x, y = self:GetPoint()
    point = point or "CENTER"
    relPoint = relPoint or point
    x = math_floor((x or 0) + 0.5)
    y = math_floor((y or 0) + 0.5)

    -- Normalize to a UIParent-relative anchor so the saved value re-applies cleanly on login.
    self:ClearAllPoints()
    self:SetPoint(point, UIParent, relPoint, x, y)

    self:UpdateHint()

    if self.vkey then DB:Set(self.vkey, { point, "UIParent", relPoint, x, y }) end
end

Anchor.OnClick = function(self, button)
    if button == "RightButton" and self.default then
        if self.vkey then DB:Reset(self.vkey) end

        self:ClearAllPoints()
        self:SetPoint(unpack(self.default))

        self:UpdateHint()
    end
end

Anchor.OnEnter = function(self)
    self:SetAlpha(1)
    self.overlay:SetBackdropBorderColor(unpack(Colors.normal))
    self:UpdateHint()
end

Anchor.OnLeave = function(self)
    self:SetAlpha(0.85)
    self.overlay:SetBackdropBorderColor(0.2, 1, 0.2, 1)
end

Anchor.OnUpdate = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.02 then return end
    self.elapsed = 0

    self:UpdateHint()
end

E.Anchor = Anchor

------------------------------------------------------------------------
-- Mover Registry (toggle all anchors)
------------------------------------------------------------------------

local movers = {}

function E:RegisterMover(frame, name, vkey, width, height)
    if type(frame) == "string" then frame = _G[frame] end
    if not frame then return end

    local anchor = Anchor:Create(frame, name, vkey, width, height)
    movers[#movers + 1] = anchor

    return anchor
end

function E:ToggleMovers()
    if InCombatLockdown() then return end

    self.moversShown = not self.moversShown
    for _, anchor in ipairs(movers) do
        if self.moversShown then anchor:SyncSize() end
        anchor:SetShown(self.moversShown)
    end
end
