local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Boss Frame of DarkUI
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("Boss")

local oUF = select(2, ...).oUF or oUF

local cfg = C.unitframe

local mediaPath = cfg.mediaPath

local media = {
    portrait_overlay = mediaPath .. "uf_portrait_overlay",
    foreground       = mediaPath .. C.general.style .. "\\" .. "uf_tot_foreground",
    background       = mediaPath .. C.general.style .. "\\" .. "uf_tot_background",
    hpTex            = mediaPath .. "uf_bartex_normal",
    mpTex            = mediaPath .. "uf_bartex_normal"
}

local function createTexture(self)
    -- foreground
    self.FrameFG = CreateFrame("Frame", nil, self)
    self.FrameFG:SetFrameStrata("HIGH")
    self.FrameFG:SetFrameLevel(7)
    self.FrameFG:SetSize(256, 128)
    self.FrameFG:SetPoint("CENTER", self, 0, 0)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, "BORDER")
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)

    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("MEDIUM")
    self.FrameBG:SetFrameLevel(4)
    self.FrameBG:SetSize(256, 128)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)
    
    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)
end

local function createBar(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("MEDIUM")
    self.Health:SetFrameLevel(5)
    self.Health:SetSize(80, 16)
    self.Health:SetPoint("CENTER", self, 25, 4)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.smoothing = Enum.StatusBarInterpolation.Continuous
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

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .45
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.smoothing = Enum.StatusBarInterpolation.Continuous
    self.Power.PostUpdateColor = core.PostUpdatePowerColor

    --alt power bar
    self.AlternativePower = CreateFrame("StatusBar", nil, self)
    self.AlternativePower:SetPoint("CENTER")
    self.AlternativePower:SetFrameStrata("LOW")
    self.AlternativePower:SetFrameLevel(4)
    self.AlternativePower:SetPoint('TOP', self.Health, 'TOP', 0, 0)
    self.AlternativePower:SetSize(94, 4)
    self.AlternativePower:SetStatusBarTexture(media.mpTex)

    self.AlternativePower.bg = self.AlternativePower:CreateTexture(nil, "BORDER")
    self.AlternativePower.bg.multiplier = .45
    self.AlternativePower.bg:SetAllPoints()
    self.AlternativePower.bg:SetTexture(media.mpTex)

    self.AlternativePower.colorPower = true
    self.AlternativePower.smoothing = Enum.StatusBarInterpolation.Continuous
    self.AlternativePower.PostUpdateColor = core.PostUpdatePowerColor
end

local function createPortrait(self)
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

local function createTag(self)
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

local function createAuraIcon(self)
    -- Buffs (above)
    local buffs = CreateFrame('Frame', nil, self)
    buffs:SetFrameStrata("HIGH")
    buffs:SetFrameLevel(1)
    buffs.size = 22
    buffs.spacing = 4
    buffs.initialAnchor = 'BOTTOMLEFT'
    buffs['growth-x'] = 'RIGHT'
    buffs['growth-y'] = 'UP'
    buffs.num = 6
    buffs.showStealableBuffs = cfg.boss.aura.show_Stealable_buffs
    buffs:SetSize((buffs.size + buffs.spacing) * buffs.num, buffs.size)
    buffs:SetPoint('BOTTOMLEFT', self, 'TOPLEFT', 0, 8)
    buffs.PostCreateButton = core.PostCreateButton
    buffs.PostUpdateButton = core.PostUpdateButton
    buffs.FilterAura = core.FilterAuras
    self.Buffs = buffs

    -- Debuffs (below)
    local debuffs = CreateFrame('Frame', nil, self)
    debuffs:SetFrameStrata("HIGH")
    debuffs:SetFrameLevel(1)
    debuffs.size = 22
    debuffs.spacing = 4
    debuffs.initialAnchor = 'TOPLEFT'
    debuffs['growth-x'] = 'RIGHT'
    debuffs['growth-y'] = 'DOWN'
    debuffs.num = 6
    debuffs.onlyShowPlayer = cfg.boss.aura.player_aura_only
    debuffs:SetSize((debuffs.size + debuffs.spacing) * debuffs.num, debuffs.size)
    debuffs:SetPoint('TOPLEFT', self, 'BOTTOMLEFT', 0, -8)
    debuffs.PostCreateButton = core.PostCreateButton
    debuffs.PostUpdateButton = core.PostUpdateButton
    debuffs.FilterAura = core.FilterAuras
    self.Debuffs = debuffs
end

local function createCastbar(self)
    local barBorder = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

    local cb = CreateFrame("StatusBar", nil, self)
    cb:SetFrameLevel(5)
    cb:SetStatusBarTexture(C.media.texture.status)
    cb:SetStatusBarColor(1, 0.8, 0)
    cb:SetPoint("LEFT", self, "RIGHT", 8, 0)
    cb:SetSize(100, 10)

    cb.bg = cb:CreateTexture(nil, "BACKGROUND")
    cb.bg:SetAllPoints()
    cb.bg:SetColorTexture(0.1, 0.1, 0.1, 0.8)

    local fg = CreateFrame("Frame", nil, cb)
    fg:SetAllPoints()
    fg:SetFrameLevel(cb:GetFrameLevel() + 2)

    fg.Texture = fg:CreateTexture(nil, "OVERLAY")
    fg.Texture:SetTexture(barBorder)
    fg.Texture:SetAllPoints(fg)
    cb.Foreground = fg

    local spark = cb:CreateTexture(nil, "OVERLAY", nil, 7)
    spark:SetBlendMode("ADD")
    spark:SetVertexColor(0.8, 0.6, 0, 1)
    spark:SetSize(15, cb:GetHeight() * 2)
    cb.Spark = spark

    local time = core:CreateFont(cb, STANDARD_TEXT_FONT, 11, "OUTLINE")
    time:SetPoint("RIGHT", cb, "RIGHT", -2, 0)
    time:SetJustifyH("RIGHT")
    cb.Time = time

    local text = core:CreateFont(cb, STANDARD_TEXT_FONT, 11, "OUTLINE")
    text:SetPoint("LEFT", cb, "LEFT", 2, 0)
    text:SetPoint("RIGHT", time, "LEFT", -4, 0)
    text:SetJustifyH("LEFT")
    cb.Text = text

    cb.timeToHold = 0.5
    cb.PostCastStart = core.PostCastStart
    cb.PostCastFail = core.PostCastFail
    cb.PostCastStop = core.PostCastStop
    cb.PostCastInterruptible = core.PostCastInterruptible

    self.Castbar = cb
end

local function createStyle(self)
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
    createCastbar(self)

    self.RaidTargetIndicator = core:CreateIcon(self, "BACKGROUND", 18, -1, self, "CENTER", "CENTER", 20, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    -- PrivateAuras (left side, grow left)
    local pa = CreateFrame("Frame", nil, UIParent)
    pa:SetPoint("RIGHT", self, "LEFT", -8, 0)
    pa:SetSize(130, 24)
    pa.size = 24
    pa.spacing = 4
    pa.initialAnchor = "RIGHT"
    pa.growthX = "LEFT"
    pa.growthY = "DOWN"
    pa.borderScale = 0
    pa.disableCooldown = false
    pa.disableCooldownText = false
    pa.PostCreateAura = function(_, aura)
        aura:CreateOverlay()
        aura:CreateShadow()
    end
    self.PrivateAuras = pa

    core:SetFader(self, cfg.boss.fader)
end

function module:OnInit()
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
end