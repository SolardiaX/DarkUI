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
local GetSpecialization = GetSpecialization
local GetShapeshiftFormID = GetShapeshiftFormID
local MonkStaggerBar_OnLoad = MonkStaggerBar_OnLoad
local select, unpack, abs, min, max = select, unpack, math.abs, math.min, math.max
local hooksecurefunc = hooksecurefunc
local MOONKIN_FORM, BEAR_FORM, CAT_FORM = MOONKIN_FORM, BEAR_FORM, CAT_FORM
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local MAX_TOTEMS = MAX_TOTEMS
local TotemFrame = TotemFrame
local ComboPointPlayerFrame = ComboPointPlayerFrame
local RuneFrame = RuneFrame
local MageArcaneChargesFrame = MageArcaneChargesFrame
local MonkStaggerBar, MonkHarmonyBarFrame = MonkStaggerBar, MonkHarmonyBarFrame
local PaladinPowerBarFrame = PaladinPowerBarFrame
local PaladinPowerBarFrameBG = PaladinPowerBarFrameBG
local InsanityBarFrame = InsanityBarFrame
local WarlockPowerFrame = WarlockPowerFrame

local function toRgb(h, s, l)
    if (s <= 0) then
        return l, l, l
    end
    h, s, l = h * 6, s, l
    local c = (1 - abs(2 * l - 1)) * s
    local x = (1 - abs(h % 2 - 1)) * c
    local m, r, g, b = (l - .5 * c), 0, 0, 0
    if h < 1 then
        r, g, b = c, x, 0
    elseif h < 2 then
        r, g, b = x, c, 0
    elseif h < 3 then
        r, g, b = 0, c, x
    elseif h < 4 then
        r, g, b = 0, x, c
    elseif h < 5 then
        r, g, b = x, 0, c
    else
        r, g, b = c, 0, x
    end
    return (r + m), (g + m), (b + m)
end

local function toHsl(r, g, b)
    local min, max = min(r, g, b), max(r, g, b)
    local h, s, l = 0, 0, (max + min) / 2
    if max ~= min then
        local d = max - min
        s = l > 0.5 and d / (2 - max - min) or d / (max + min)
        if max == r then
            local mod = 6
            if g > b then mod = 0 end
            h = (g - b) / d + mod
        elseif max == g then
            h = (b - r) / d + 2
        else
            h = (r - g) / d + 4
        end
    end
    h = h / 6
    return h, s, l
end

local function LightenItUp(r, g, b, factor)
    local h, s, l = toHsl(r, g, b)
    l = l + (factor or 0.1)
    if l > 1 then
        l = 1
    elseif l < 0 then
        l = 0
    end
    return toRgb(h, s, l)
end

local function updateTotemPosition(self)
    local _, class = UnitClass("player")
    TotemFrame:ClearAllPoints()
    if (class == "PALADIN" or class == "DEATHKNIGHT") then
        --runes/holyower
        TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 22, 0)
    elseif (class == "DRUID") then
        local form = GetShapeshiftFormID();
        if (form == MOONKIN_FORM or not form) and (GetSpecialization() == 1) then
            TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 37, -5)
        elseif (form == BEAR_FORM or form == CAT_FORM) then
            TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 37, -5)
        else
            TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 57, 0)
        end
    elseif (class == "MAGE") then
        TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 30, -5)
    elseif (class == "MONK") then
		TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 22, 0)
    elseif (class == "WARLOCK") then
        TotemFrame:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 40, -20) --not sure where to put this
    elseif (class == "SHAMAN") and (GetSpecialization() == 1) then
        TotemFrame:SetPoint('TOP', self, 'BOTTOM', 6, -7)
    else
        TotemFrame:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 37, -5)
    end
end

local function PaintFrames(texture, factor)
    if texture:GetObjectType() == "Texture" then
        local r, g, b = unpack(C.media.border_color)
        if factor then
            r, g, b = LightenItUp(r, g, b, factor)
            texture.colorfactor = factor
        end
        texture:SetVertexColor(r, g, b)
    end
end

module.classModule = {}

-- Combo Points
module.classModule.UpdateComboPointsPosition = function(self, ...)
    ComboPointPlayerFrame:ClearAllPoints()
    ComboPointPlayerFrame:SetParent(self)
    ComboPointPlayerFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)
    ComboPointPlayerFrame.SetPoint = function() end

    PaintFrames(ComboPointPlayerFrame.Background, 0.1)
end

module.classModule.CreateAlternatePowerBar = function(self, _, media)
    self.DruidMana = CreateFrame("StatusBar", nil, self)
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.DruidMana:SetStatusBarTexture(media.druidManaTex)
    self.DruidMana:SetHeight(2)
    self.DruidMana:SetPoint('TOPLEFT', self.Power, 'BOTTOMLEFT', 3, 6)
    self.DruidMana:SetPoint('BOTTOMRIGHT', self.Power, 'BOTTOMRIGHT', -3, 0)

    self.DruidMana.background = self.DruidMana:CreateTexture(nil, 'BORDER')
    self.DruidMana.background:SetAllPoints(self.DruidMana)
    self.DruidMana.background:SetTexture(media.druidManaTex)
    self.DruidMana.background.multiplier = .3

    self.DruidMana.frequentUpdates = true
    self.DruidMana.colorPower = true
end

module.classModule.UpdateTotems = function(self, ...)
    TotemFrame:ClearAllPoints()
    TotemFrame:SetParent(self)
    TotemFrame:SetScale(self:GetScale())

    for i = 1, MAX_TOTEMS do
        local _, totemBorder = _G['TotemFrameTotem' .. i]:GetChildren()
        PaintFrames(totemBorder:GetRegions())

        _G['TotemFrameTotem' .. i]:SetFrameStrata('LOW')

        _G['TotemFrameTotem' .. i .. 'Duration']:SetParent(totemBorder)
        _G['TotemFrameTotem' .. i .. 'Duration']:SetDrawLayer('OVERLAY')
        _G['TotemFrameTotem' .. i .. 'Duration']:ClearAllPoints()
        _G['TotemFrameTotem' .. i .. 'Duration']:SetPoint('BOTTOM', _G['TotemFrameTotem' .. i], 0, 3)
        _G['TotemFrameTotem' .. i .. 'Duration']:SetFont(STANDARD_TEXT_FONT, 10, 'OUTLINE')
        _G['TotemFrameTotem' .. i .. 'Duration']:SetShadowOffset(0, 0)
    end

    _G.TotemFrame_AdjustPetFrame = function() end -- noop these else we'll get taint
    _G.PlayerFrame_AdjustAttachments = function() end

    hooksecurefunc("TotemFrame_Update", updateTotemPosition)
    updateTotemPosition()
end

module.classModule.DEATHKNIGHT = function(self, config, _)
    if (config.classModule.DEATHKNIGHT.showRunes) then
        RuneFrame:SetParent(self)
        RuneFrame:OnLoad()
        RuneFrame:ClearAllPoints()
        RuneFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)

        return RuneFrame
    end
end

module.classModule.MAGE = function(self, config, _)
    if (config.classModule.MAGE.showArcaneStacks) then
        MageArcaneChargesFrame:SetParent(self)
        MageArcaneChargesFrame:ClearAllPoints()
        MageArcaneChargesFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, -2)

        return MageArcaneChargesFrame
    end
end

module.classModule.MONK = function(self, config, _)
    if (config.classModule.MONK.showStagger) then
        -- Stagger Bar for tank monk
        MonkStaggerBar:SetParent(self)
        MonkStaggerBar_OnLoad(MonkStaggerBar)
        MonkStaggerBar:ClearAllPoints()
        MonkStaggerBar:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 122, 16)

        PaintFrames(MonkStaggerBar.MonkBorder, 0.3)

        MonkStaggerBar:SetFrameLevel(1)
    end

    if (config.classModule.MONK.showChi) then
        -- Monk combo points for Windwalker
        MonkHarmonyBarFrame:SetParent(self)
        MonkHarmonyBarFrame:ClearAllPoints()
        MonkHarmonyBarFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 122, 16)

        PaintFrames(select(2, MonkHarmonyBarFrame:GetRegions()), 0.1)

        return MonkHarmonyBarFrame
    end
end

module.classModule.PALADIN = function(self, config, _)
    if (config.classModule.PALADIN.showHolyPower) then
        PaladinPowerBarFrame:SetParent(self)
        PaladinPowerBarFrame:ClearAllPoints()
        PaladinPowerBarFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)

        PaintFrames(PaladinPowerBarFrameBG, 0.1)

        return PaladinPowerBarFrame
    end
end

module.classModule.PRIEST = function(self, config, _)
    if (config.classModule.PRIEST.showInsanity) then
        InsanityBarFrame:SetParent(self)
        InsanityBarFrame:ClearAllPoints()
        InsanityBarFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)

        return InsanityBarFrame
    end
end

module.classModule.WARLOCK = function(self, config, _)
    if (config.classModule.WARLOCK.showShards) then
        WarlockPowerFrame:SetParent(self)
        WarlockPowerFrame:ClearAllPoints()
        WarlockPowerFrame:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 60, 0)

        return WarlockPowerFrame
    end
end