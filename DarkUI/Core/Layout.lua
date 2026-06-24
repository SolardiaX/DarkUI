local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Layout — LibEditModeOverride + Anchor (Mover)
------------------------------------------------------------------------

local string_format = string.format

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

    for _, entry in ipairs(registry) do
        local frame = resolveFrame(entry)
        local point = resolvePoint(entry)
        if frame and point and LEMO:HasEditModeSettings(frame) then LEMO:ReanchorFrame(frame, unpack(point)) end
    end

    LEMO:ApplyChanges()
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

local function getVariable(t, vkey)
    for k in gmatch(vkey, "([^.%s]+)") do
        t = t[k]
        if t == nil then return end
    end
    return t
end

local getPosition = function(frame)
    local worldHeight = WorldFrame:GetHeight()
    local worldWidth = WorldFrame:GetWidth()
    local uiScale = UIParent:GetEffectiveScale()
    local uiWidth = UIParent:GetWidth() * uiScale
    local uiHeight = UIParent:GetHeight() * uiScale
    local uiBottom = UIParent:GetBottom() * uiScale
    local uiLeft = UIParent:GetLeft() * uiScale
    local uiTop = UIParent:GetTop() * uiScale - worldHeight
    local uiRight = UIParent:GetRight() * uiScale - worldWidth

    local frameScale = frame:GetEffectiveScale()
    local x, y = frame:GetCenter()
    x = x * frameScale
    y = y * frameScale
    local bottom = frame:GetBottom() * frameScale
    local left = frame:GetLeft() * frameScale
    local top = frame:GetTop() * frameScale - worldHeight
    local right = frame:GetRight() * frameScale - worldWidth

    left = left - uiLeft
    bottom = bottom - uiBottom
    right = right - uiRight
    top = top - uiTop

    if y < uiHeight * 1 / 3 then
        if x < uiWidth * 1 / 3 then
            return "BOTTOMLEFT", left / frameScale, bottom / frameScale
        elseif x > uiWidth * 2 / 3 then
            return "BOTTOMRIGHT", right / frameScale, bottom / frameScale
        else
            return "BOTTOM", (x - uiWidth / 2) / frameScale, bottom / frameScale
        end
    elseif y > uiHeight * 2 / 3 then
        if x < uiWidth * 1 / 3 then
            return "TOPLEFT", left / frameScale, top / frameScale
        elseif x > uiWidth * 2 / 3 then
            return "TOPRIGHT", right / frameScale, top / frameScale
        else
            return "TOP", (x - uiWidth / 2) / frameScale, top / frameScale
        end
    else
        if x < uiWidth * 1 / 3 then
            return "LEFT", left / frameScale, (y - uiHeight / 2) / frameScale
        elseif x > uiWidth * 2 / 3 then
            return "RIGHT", right / frameScale, (y - uiHeight / 2) / frameScale
        else
            return "CENTER", (x - uiWidth / 2) / frameScale, (y - uiHeight / 2) / frameScale
        end
    end
end

local Anchor = {}

Anchor.Create = function(self, frame, name, vkey)
    local anchor = CreateFrame("Button", nil, UIParent)

    for method, func in next, Anchor do
        if method ~= "Create" then anchor[method] = func end
    end

    anchor:Hide()
    anchor:Enable()
    anchor:SetFrameStrata("HIGH")
    anchor:SetFrameLevel(1000)
    anchor:SetAllPoints(frame)
    anchor:SetMovable(true)
    anchor:SetHitRectInsets(-20, -20, -20, -20)
    anchor:RegisterForDrag("LeftButton")
    anchor:RegisterForClicks("AnyUp")
    anchor:SetScript("OnDragStart", self.OnDragStart)
    anchor:SetScript("OnDragStop", self.OnDragStop)
    anchor:SetScript("OnClick", self.OnClick)
    anchor:SetScript("OnShow", self.OnShow)
    anchor:SetScript("OnHide", self.OnHide)
    anchor:SetScript("OnEnter", self.OnEnter)
    anchor:SetScript("OnLeave", self.OnLeave)

    local overlay = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
    overlay:SetAllPoints()
    overlay:SetBackdrop({
        bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
        tile = true,
        tileSize = 16,
        edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
        edgeSize = 16,
        insets = { left = 5, right = 3, top = 3, bottom = 5 },
    })
    overlay:SetBackdropColor(0.5, 1, 0.5, 0.75)
    overlay:SetBackdropBorderColor(0.5, 1, 0.5, 1)
    anchor.overlay = overlay

    anchor.name = overlay:CreateFontText(13, "")
    anchor.name:SetTextColor(unpack(Colors.highlight))
    anchor.name:SetIgnoreParentScale(true)
    anchor.name:SetIgnoreParentAlpha(true)
    anchor.name:SetJustifyV("MIDDLE")
    anchor.name:SetJustifyH("CENTER")
    anchor.name:SetText(name)

    anchor.hint = overlay:CreateFontText(13, "")
    anchor.hint:SetTextColor(unpack(Colors.highlight))
    anchor.hint:SetIgnoreParentScale(true)
    anchor.hint:SetIgnoreParentAlpha(true)
    anchor.hint:SetPoint("TOP", overlay, "BOTTOM", -20)
    anchor.hint:SetText("")

    anchor.vkey = vkey
    anchor.position = { getPosition(anchor) }
    anchor.frame = frame

    return anchor
end

Anchor.Enable = function(self) self.enabled = true end

Anchor.Disable = function(self) self.enabled = false end

Anchor.IsEnabled = function(self) return self.enabled end

Anchor.SetEnabled = function(self, enable) self.enabled = enable and true or false end

Anchor.UpdateHint = function(self)
    local msg = string_format(E:RGBToHex(Colors.highlight) .. "%s, %.0f, %.0f|r", unpack(self.position))
    msg = msg .. E:RGBToHex(Colors.green) .. "\n<Left-Click and drag to move>|r"
    msg = msg .. E:RGBToHex(Colors.green) .. "\n<Right-Click to undo change>|r"

    self.hint:SetText(msg)
    self.hint:Show()
end

Anchor.OnDragStart = function(self, button)
    self:StartMoving()
    self:SetUserPlaced(false)
    self.elapsed = 0
    self:SetScript("OnUpdate", self.OnUpdate)
end

Anchor.OnDragStop = function(self)
    self:StopMovingOrSizing()
    self:SetScript("OnUpdate", nil)
    self.frame:ClearAllPoints()
    self.frame:SetPoint(unpack(self.position))
end

Anchor.OnClick = function(self, button)
    if button == "RightButton" then
        self.frame:ClearAllPoints()
        self.frame:SetPoint(unpack(getVariable(C, self.vkey)))
    end
end

Anchor.OnShow = function(self)
    self:SetFrameLevel(50)
    self:SetAlpha(0.75)
end

Anchor.OnHide = function(self)
    self:SetScript("OnUpdate", nil)
    self.elapsed = 0
end

Anchor.OnEnter = function(self)
    self:UpdateHint()
    self:SetAlpha(1)
end

Anchor.OnLeave = function(self)
    self:UpdateHint()
    self:SetAlpha(0.75)
end

Anchor.OnUpdate = function(self, elapsed)
    self.elapsed = self.elapsed + elapsed
    if self.elapsed < 0.02 then return end
    self.elapsed = 0

    self.position = { getPosition(self) }

    self:UpdateHint()
end

E.Anchor = Anchor
