------------------------------------------------------------------------
-- SpellsIndicator (corner buff colored dots on raid frames)
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF
local E, C = select(2, ...):unpack()

local GetTime = GetTime
local UnitIsConnected = UnitIsConnected

local anchors = { "TOPLEFT", "TOP", "TOPRIGHT", "LEFT", "RIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT" }
local anchorOffsets = {
    TOPLEFT     = { 2, -2 },
    TOP         = { 0, -2 },
    TOPRIGHT    = { -2, -2 },
    LEFT        = { 2, 0 },
    RIGHT       = { -2, 0 },
    BOTTOMLEFT  = { 2, 2 },
    BOTTOM      = { 0, 2 },
    BOTTOMRIGHT = { -2, 2 },
}

local function Update(self, _, unit)
    if self.unit ~= unit then return end

    local element = self.SpellsIndicator
    if not element then return end

    local cornerBuffs = element.CornerBuffs
    if not cornerBuffs then return end

    for _, dot in pairs(element.dots) do
        dot:Hide()
    end

    if not UnitIsConnected(unit) then return end

    local i = 0
    while true do
        i = i + 1
        local data = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
        if not data then break end

        local spellId = data.spellId
        if spellId then
            local info = cornerBuffs[spellId]
            if info then
                local anchor = info[1]
                local color = info[2]
                local dot = element.dots[anchor]
                if dot then
                    dot:SetVertexColor(color[1], color[2], color[3])
                    dot:Show()
                end
            end
        end
    end
end

local function Path(self, ...)
    return (self.SpellsIndicator.Override or Update)(self, ...)
end

local function ForceUpdate(element)
    return Path(element.__owner, "ForceUpdate", element.__owner.unit)
end

local function Enable(self)
    local element = self.SpellsIndicator
    if not element then return end

    element.__owner = self
    element.ForceUpdate = ForceUpdate

    local cornerBuffs = {}
    local class = select(2, UnitClass("player"))
    if C.aura.cornerBuffs then
        if C.aura.cornerBuffs["ALL"] then
            for spellId, info in pairs(C.aura.cornerBuffs["ALL"]) do
                cornerBuffs[spellId] = info
            end
        end
        if C.aura.cornerBuffs[class] then
            for spellId, info in pairs(C.aura.cornerBuffs[class]) do
                cornerBuffs[spellId] = info
            end
        end
    end
    element.CornerBuffs = cornerBuffs

    element.dots = {}
    local parent = element
    for _, anchor in ipairs(anchors) do
        local dot = parent:CreateTexture(nil, "OVERLAY")
        dot:SetSize(element.size or 5, element.size or 5)
        local offset = anchorOffsets[anchor]
        dot:SetPoint(anchor, parent, anchor, offset[1], offset[2])
        dot:SetTexture([[Interface\BUTTONS\WHITE8X8]])
        dot:Hide()
        element.dots[anchor] = dot
    end

    self:RegisterEvent("UNIT_AURA", Path)
    return true
end

local function Disable(self)
    local element = self.SpellsIndicator
    if not element then return end

    for _, dot in pairs(element.dots) do
        dot:Hide()
    end

    self:UnregisterEvent("UNIT_AURA", Path)
end

oUF:AddElement("SpellsIndicator", Path, Enable, Disable)
