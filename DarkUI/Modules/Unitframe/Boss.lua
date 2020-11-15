local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Boss Frame of DarkUI
----------------------------------------------------------------------------------------

local oUF = ns.oUF or oUF

local CreateFrame = CreateFrame
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local unpack = unpack
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES

local cfg = C.unitframe
local DUF = E.unitframe

local mediaPath = cfg.mediaPath

local media = {
    portrait_overlay = mediaPath .. "uf_portrait_overlay",
    foreground       = mediaPath .. C.general.style .. "\\" .. "uf_tot_foreground",
    background       = mediaPath .. C.general.style .. "\\" .. "uf_tot_background",
    hpTex            = mediaPath .. "uf_bartex_normal",
    mpTex            = mediaPath .. "uf_bartex_normal"
}

local createTexture = function(self)
    -- foreground
    self.FrameFG = CreateFrame("Frame", nil, self)
    self.FrameFG:SetFrameStrata("HIGH")
    self.FrameFG:SetFrameLevel(7)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, "BORDER")
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)

    self.FrameFG:SetSize(256, 128)
    self.FrameFG:SetPoint("CENTER", self, 0, 0)

    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("MEDIUM")
    self.FrameBG:SetFrameLevel(4)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)

    self.FrameBG:SetSize(256, 128)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)
end

local createBar = function(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("MEDIUM")
    self.Health:SetFrameLevel(5)
    self.Health:SetSize(80, 16)
    self.Health:SetPoint("CENTER", self, 25, 4)

    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.Smooth = true
    self.Health.colorClass = true
    self.Health.colorClassNPC = true
    self.Health.colorClassPet = true

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetPoint("CENTER")
    self.Power:SetFrameStrata("MEDIUM")
    self.Power:SetFrameLevel(6)
    self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, 0)
    self.Power:SetSize(80, 4)

    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .45
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)
end

local createPortrait = function(self)
    local overlayFrame

    if cfg.portrait3D == false then
        self.Portrait = self.FrameBG:CreateTexture(nil, "ARTWORK", nil, 3)
        self.Portrait:SetSize(42, 42)

        overlayFrame = CreateFrame("Frame", nil, self.FrameBG)
    else
        self.Portrait = CreateFrame("PlayerModel", nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(38, 38)

        overlayFrame = CreateFrame("Frame", nil, self.Portrait)
    end

    self.Portrait:SetPoint("CENTER", self, "LEFT", 2, 0)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, "OVERLAY", nil, 7)
    overlay:SetTexture(media.portrait_overlay)
    overlay:SetPoint("TOPLEFT", overlayFrame, -2, 2)
    overlay:SetPoint("BOTTOMRIGHT", overlayFrame, 2, -2)
    overlay:SetAlpha(1)

    self.Portrait.overlay = overlay
end

local createTag = function(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.FrameFG, "[raidcolor][dd:realname]")
                         :SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE")
                         :SetPoint("TOPLEFT", self, "CENTER", -5, -18)
                         :done()

    self.Tags.level = self:CreateTag(self.FrameFG, "[dd:difficulty][level]")
                          :SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
                          :SetPoint("CENTER", self, -20, -17)
                          :done()

    self.Tags.smarthp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
                            :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                            :SetPoint("CENTER", self.Health, 0, -2)
                            :SetJustifyH("CENTER")
                            :done()
end

local createAuraIcon = function(self)
    local f = CreateFrame('Frame', nil, self)

    f.size = 24
    f.spacing = 4
    f.gap = true
    f.initialAnchor = 'RIGHT'
    f.onlyShowPlayer = cfg.boss.aura.player_aura_only
    f.showStealableBuffs = cfg.boss.aura.show_Stealable_buffs
    f['growth-x'] = 'LEFT'
    f['growth-y'] = 'DOWN'

    local h = (f.size + f.spacing) * 6
    local w = (f.size + f.spacing) * 4
    f:SetSize(h, w)
    f:SetPoint('RIGHT', self, 'LEFT', -40, 0)

    f.PostCreateIcon = DUF.PostCreateIcon
    f.PostUpdateIcon = DUF.PostUpdateIcon
    f.CustomFilter = DUF.FilterAuras

    self.Auras = f
end

local createStyle = function(self)
    self.colors = C.oUF_colors
    self.cUnit = "boss"

    self:SetSize(100, 33)
    self:SetScale(cfg.scale)

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createPortrait(self)
    createTag(self)
    createAuraIcon(self)

    self.RaidTargetIndicator = DUF.CreateIcon(self, "BACKGROUND", 18, -1, self, "CENTER", "CENTER", 20, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    DUF.SetFader(self, cfg.boss.fader)
end

---------------------------------------------
-- SPAWN BOSS UNIT
---------------------------------------------

oUF:RegisterStyle("DarkUI:boss", createStyle)
oUF:SetActiveStyle("DarkUI:boss")

local boss = {}
for i = 1, MAX_BOSS_FRAMES do
    local name = "DarkUIBossFrame" .. i
    local unit = oUF:Spawn("boss" .. i, name)
    if i == 1 then
        unit:SetPoint(unpack(cfg.boss.position))
    else
        unit:SetPoint("TOP", boss[i - 1], "BOTTOM", 0, -cfg.boss.spacing)
    end

    boss[i] = unit
end

---------------------------------------------
-- SPAWN ARENA UNIT, use same place of BOSS
---------------------------------------------

oUF:RegisterStyle("DarkUI:arena", createStyle)
oUF:SetActiveStyle("DarkUI:arena")

local arena = {}
for i = 1, 5 do
    local name = "DarkUIArenaFrame" .. i
    local unit = oUF:Spawn("arena" .. i, name)
    if i == 1 then
        unit:SetPoint(unpack(cfg.boss.position))
    else
        unit:SetPoint("TOP", arena[i - 1], "BOTTOM", 0, -cfg.boss.spacing)
    end

    arena[i] = unit
end