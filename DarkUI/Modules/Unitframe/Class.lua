local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Special Class Methods of UnitFrame
----------------------------------------------------------------------------------------

local module = E.unitframe

local _G = _G
local CreateFrame = CreateFrame
local UnitClass = UnitClass
local select, unpack, abs, min, max = select, unpack, math.abs, math.min, math.max
local hooksecurefunc = hooksecurefunc
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local cfg = C.unitframe
local LibSmoothBar = LibStub("LibSmoothBar-1.0")

module.classModule = {}
module.classModule.blizzard = {}
module.classModule.classpowerbar = {}

------------------------------------------------------------------------
-- Blizzard classbar
------------------------------------------------------------------------

-- override default blizzard event function for Druid
module.classModule.blizzard["DRUID"] = function(self, ...)
    ComboPointDruidPlayerFrame:Setup()
    ComboPointDruidPlayerFrame:SetParent(PlayerFrameBottomManagedFramesContainer)
end

module.classModule.classpowerbar.ResetBlizzardBarPosition = function(self, ...)
    PlayerFrameBottomManagedFramesContainer:ClearAllPoints()
    PlayerFrameBottomManagedFramesContainer:SetParent(self)
    PlayerFrameBottomManagedFramesContainer:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)
    PlayerFrameBottomManagedFramesContainer:Show()
    PlayerFrameBottomManagedFramesContainer:Layout()

    PlayerFrameBottomManagedFramesContainer.SetPoint = E.dummy
    PlayerFrameBottomManagedFramesContainer.unit = "player"
end

------------------------------------------------------------------------
-- New diablolic classbar
------------------------------------------------------------------------

local Runes_PostUpdate = function(element, runemap, hasVehicle, allReady)
    for i = 1, #element do
        local rune = element[i]
        if (rune:IsShown()) then
            local value = rune:GetValue()
            local min, max = rune:GetMinMaxValues()
            if (element.inCombat) then
                rune:SetAlpha(allReady and 1 or (value < max) and .5 or 1)
            else
                rune:SetAlpha(allReady and 0 or (value < max) and .5 or 1)
            end
        end
    end
end

local Runes_PostUpdateColor = function(element, r, g, b, color, rune)
    if (rune) then
        rune:SetStatusBarColor(r, g, b)
        rune.fg:SetVertexColor(r, g, b)
    else
        color = element.__owner.colors.power.RUNES
        r, g, b = color[1], color[2], color[3]
        for i = 1, #element do
            local rune = element[i]
            rune:SetStatusBarColor(r, g, b)
            rune.fg:SetVertexColor(r, g, b)
        end
    end
end

local ClassPower_OnDisplayValueChanged = function(point)
    local value = point:GetValue()
    local min, max = point:GetMinMaxValues()

    -- Base it all on the bar's current color
    if (point.fg) then
        local r, g, b = point:GetStatusBarColor()
        point.fg:SetVertexColor(r, g, b, .75)

        -- Adjust texcoords of the overlay glow to match the bars
        local c = point.fg.texCoords
        point.fg:SetTexCoord(c[1], c[2], c[4] - (c[4]-c[3]) * ((value-min)/(max-min)), c[4])
    end
end

local ClassPower_PostUpdate = function(element, cur, max, hasMaxChanged, powerType)
    -- Resize the holder frame to keep points centered
    if (hasMaxChanged) then
        element:SetWidth(max * element.pointWidth)
        element:SetPoint(unpack(cfg.classModule.classpowerbar.position))
    end
    for i = 1, #element do
        local point = element[i]
        if (point:IsShown()) then
            local value = point:GetValue()
            local min, max = point:GetMinMaxValues()
            if (element.inCombat) then
                point:SetAlpha((cur == max) and 1 or (value < max) and .5 or 1)
            else
                point:SetAlpha((cur == max) and 0 or (value < max) and .5 or 1)
            end
        end
    end
end

local ClassPower_PostUpdateColor = function(element, r, g, b)
    for i = 1, #element do
        local bar = element[i]
        bar:SetStatusBarColor(r, g, b)
        local fg = bar.fg
        if (fg) then
            local mu = fg.multiplier or 1
            fg:SetVertexColor(r, g, b)
        end
    end
end

local CreateClassPoint = function(self, i)
    local point = LibSmoothBar:CreateSmoothBar(nil, self)
    point:SetSize(42,42)
    point.pointWidth = 42
    point:SetStatusBarTexture(cfg.mediaPath .. "uf_class_point")
    point:GetStatusBarTexture():SetTexCoord((i-1)*128/1024, i*128/1024, 128/512, 256/512)
    point:SetSparkTexture(cfg.mediaPath .. "tex_empty")
    point:DisableSmoothing(true) -- Force disable smoothing, it's too inaccurate for this.
    point:SetOrientation("UP")
    point:SetMinMaxValues(0, 1)
    point:SetValue(1)
    point:SetScript("OnDisplayValueChanged", ClassPower_OnDisplayValueChanged)

    -- Empty slot texture
    local bg = point:CreateTexture()
    bg:SetDrawLayer("BACKGROUND", -1)
    bg:ClearAllPoints()
    bg:SetPoint("BOTTOM", 0, 0)
    bg:SetSize(42,42)
    bg:SetTexture(cfg.mediaPath .. "uf_class_point")
    bg:SetTexCoord((i-1)*128/1024, i*128/1024, 0/512, 128/512)
    bg.multiplier = .25
    point.bg = bg

    -- Overlay glow, aligned to the bar texture
    -- This needs post updates to adjust its texcoords based on bar value.
    local fg = point:CreateTexture()
    fg:SetDrawLayer("ARTWORK", 1)
    fg:SetPoint("TOP", point:GetStatusBarTexture(), "TOP", 0, 0)
    fg:SetPoint("BOTTOM", 0, 0)
    fg:SetPoint("LEFT", 0, 0)
    fg:SetPoint("RIGHT", 0, 0)
    fg:SetSize(42,42) -- this is overriden by the points above
    fg:SetBlendMode("ADD")
    fg:SetTexture(cfg.mediaPath .. "uf_class_point")
    fg:SetTexCoord((i-1)*128/1024, i*128/1024, 256/512, 384/512)
    fg:SetAlpha(.85)
    fg.texCoords = { (i-1)*128/1024, i*128/1024, 256/512, 384/512 }
    point.fg = fg

    return point
end

local UnitFrame_OnEvent = function(self, event)
    if (event == "PLAYER_REGEN_DISABLED") then
        local runes = self.Runes
        if (runes) and (not runes.inCombat) then
            runes.inCombat = true
            runes:ForceUpdate()
        end
        local stagger = self.Stagger
        if (stagger and not stagger.inCombat) then
            stagger.inCombat = true
            stagger:ForceUpdate()
        end
        local classpower = self.ClassPower
        if (classpower) and (not classpower.inCombat) then
            classpower.inCombat = true
            classpower:ForceUpdate()
        end
    elseif (event == "PLAYER_REGEN_ENABLED") then
        local runes = self.Runes
        if (runes) and (runes.inCombat) then
            runes.inCombat = false
            runes:ForceUpdate()
        end
        local stagger = self.Stagger
        if (stagger and stagger.inCombat) then
            stagger.inCombat = false
            stagger:ForceUpdate()
        end
        local classpower = self.ClassPower
        if (classpower) and (classpower.inCombat) then
            classpower.inCombat = false
            classpower:ForceUpdate()
        end
    end
end

module.classModule.classpowerbar.CreateDiablolicBar = function(self, ...)
    -- Classpowers
    --------------------------------------------
    -- 	Supported class powers:
    -- 	- All     - Combo Points
    -- 	- Mage    - Arcane Charges
    -- 	- Monk    - Chi Orbs
    -- 	- Paladin - Holy Power
    -- 	- Warlock - Soul Shards
    --------------------------------------------
    local classpower = CreateFrame("Frame", nil, self)
    classpower:SetSize(210,42)
    classpower:SetPoint(unpack(cfg.classModule.classpowerbar.position))
    classpower.pointWidth = 42
    classpower.PostUpdate = ClassPower_PostUpdate
    classpower.PostUpdateColor = ClassPower_PostUpdateColor

    local maxPoints = (E.class == "MONK" or E.class == "ROGUE") and 6 or 5
    classpower:SetWidth(maxPoints * classpower.pointWidth)

    for i = 1,maxPoints do
        local point = CreateClassPoint(self, i)
        point:SetParent(classpower)
        if (i == 1) then
            point:SetPoint("TOPLEFT", classpower, "TOPLEFT", 0, 0)
        else
            point:SetPoint("TOPLEFT", classpower[i-1], "TOPRIGHT", 0, 0)
        end
        classpower[i] = point
    end

    self.ClassPower = classpower

    -- Stagger (Monk)
    --------------------------------------------
    if E.class == "MONK" then
        local stagger = CreateFrame("Frame", nil, self)
        stagger:SetSize(126,42)
        stagger:SetPoint(unpack(cfg.classModule.classpowerbar.position))
        stagger.PostUpdate = ClassPower_PostUpdate

        for i = 1,3 do
            local point = CreateClassPoint(self, i)
            point:SetParent(stagger)
            if (i == 1) then
                point:SetPoint("TOPLEFT", stagger, "TOPLEFT", 0, 0)
            else
                point:SetPoint("TOPLEFT", stagger[i-1], "TOPRIGHT", 0, 0)
            end
            stagger[i] = point
        end

        self.Stagger = stagger
    end

    -- Runes (Death Knight)
    --------------------------------------------
    if E.class == "DEATHKNIGHT" then
        local runes = CreateFrame("Frame", nil, self)
        runes:SetSize(252,42)
        runes:SetPoint(unpack(cfg.classModule.classpowerbar.position))
        runes.sortOrder = "ASC"
        runes.PostUpdate = Runes_PostUpdate
        runes.PostUpdateColor = Runes_PostUpdateColor

        for i = 1,6 do
            local rune = CreateClassPoint(self, i)
            rune:SetParent(runes)
            if (i == 1) then
                rune:SetPoint("TOPLEFT", runes, "TOPLEFT", 0, 0)
            else
                rune:SetPoint("TOPLEFT", runes[i-1], "TOPRIGHT", 0, 0)
            end
            runes[i] = rune
        end

        self.Runes = runes
    end

    self:RegisterEvent("PLAYER_REGEN_ENABLED", UnitFrame_OnEvent, true)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", UnitFrame_OnEvent, true)
end
