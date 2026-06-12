local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Focus Frame
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("Focus")

local oUF = select(2, ...).oUF or oUF

local UnitCanAttack = UnitCanAttack
local UnitThreatSituation = UnitThreatSituation

local cfg = C.unitframe

local media

local function createTexture(self)
    -- foreground
    self.FrameFG = CreateFrame("Frame", nil, self)
    self.FrameFG:SetFrameStrata("LOW")
    self.FrameFG:SetFrameLevel(5)
    self.FrameFG:SetSize(256, 128)
    self.FrameFG:SetPoint("CENTER", self, 0, 0)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, "BORDER")
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)
    self.FrameFG.texture:SetTexCoord(1, 0, 0, 1)

    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("BACKGROUND")
    self.FrameBG:SetFrameLevel(1)
    self.FrameBG:SetSize(256, 128)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)
    self.FrameBG.texture:SetTexCoord(1, 0, 0, 1)

    self.DebuffHighlight = self:CreateTexture(nil, "OVERLAY")
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlight:SetTexture(media.debuffHighlight)
    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)

    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false
end

local function createBar(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(94, 14)
    self.Health:SetPoint("BOTTOM", self.FrameBG, "BOTTOM", 0, 21)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetTexture(media.hpTex)
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg.multiplier = 0.3

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Health.colorClass = true
    self.Health.colorClassNPC = true
    self.Health.colorClassPet = true

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, 0)
    self.Power:SetSize(94, 4)
    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = 0.45
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorClass = true
    self.Power.colorReaction = true
    self.Power.colorTapping = true
    self.Power.colorDisconnected = true
    self.Power.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Power.PostUpdateColor = core.PostUpdatePowerColor

    --Incoming heal
    local healingAll = CreateFrame("StatusBar", nil, self.Health)
    healingAll:SetPoint("TOP")
    healingAll:SetPoint("BOTTOM")
    healingAll:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    healingAll:SetWidth(94)
    healingAll:SetStatusBarTexture(media.incoming_barTex)
    healingAll:SetStatusBarColor(0, 1, 0.5, 0.2)

    local damageAbsorb = CreateFrame("StatusBar", nil, self.Health)
    damageAbsorb:SetPoint("TOP")
    damageAbsorb:SetPoint("BOTTOM")
    damageAbsorb:SetPoint("LEFT", healingAll:GetStatusBarTexture(), "RIGHT")
    damageAbsorb:SetWidth(94)
    damageAbsorb:SetStatusBarTexture(media.incoming_barTex)
    damageAbsorb:SetStatusBarColor(1, 1, 0, 0.2)

    local overDamageAbsorbIndicator = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    overDamageAbsorbIndicator:SetWidth(15)
    overDamageAbsorbIndicator:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    overDamageAbsorbIndicator:SetBlendMode("ADD")
    overDamageAbsorbIndicator:SetAlpha(0.7)
    overDamageAbsorbIndicator:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -7, 2)
    overDamageAbsorbIndicator:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -7, -2)

    local healAbsorb = CreateFrame("StatusBar", nil, self.Health)
    healAbsorb:SetPoint("TOP")
    healAbsorb:SetPoint("BOTTOM")
    healAbsorb:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
    healAbsorb:SetWidth(94)
    healAbsorb:SetReverseFill(true)
    healAbsorb:SetStatusBarTexture(media.incoming_barTex)
    healAbsorb:SetStatusBarColor(0, 0.5, 0.8, 0.5)
    healAbsorb:SetFrameLevel(self.Health:GetFrameLevel())

    local overHealAbsorbIndicator = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    overHealAbsorbIndicator:SetWidth(15)
    overHealAbsorbIndicator:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
    overHealAbsorbIndicator:SetBlendMode("ADD")
    overHealAbsorbIndicator:SetAlpha(0.5)
    overHealAbsorbIndicator:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
    overHealAbsorbIndicator:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

    self.Health.HealingAll = healingAll
    self.Health.DamageAbsorb = damageAbsorb
    self.Health.OverDamageAbsorbIndicator = overDamageAbsorbIndicator
    self.Health.HealAbsorb = healAbsorb
    self.Health.OverHealAbsorbIndicator = overHealAbsorbIndicator
end

local function createPortrait(self)
    local overlayFrame

    if cfg.portrait3D == false then
        self.Portrait = self.FrameBG:CreateTexture(nil, "BACKGROUND", nil, 3)
        self.Portrait:SetSize(78, 78)

        overlayFrame = CreateFrame("Frame", nil, self.FrameBG)
    else
        self.Portrait = CreateFrame("PlayerModel", nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(58, 58)

        overlayFrame = CreateFrame("Frame", nil, self.Portrait)
    end

    self.Portrait:SetPoint("CENTER", self, 0, 16)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
    overlay:SetTexture(media.portrait_overlay)
    overlay:SetPoint("TOPLEFT", overlayFrame, -4, 4)
    overlay:SetPoint("BOTTOMRIGHT", overlayFrame, 4, -4)
    overlay:SetAlpha(1)

    self.Portrait.overlay = overlay
end

local function createTag(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.FrameFG, "[raidcolor][dd:realname]")
        :SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE")
        :SetPoint("TOP", self.FrameBG, "BOTTOM", 0, 2)
        :SetJustifyH("CENTER")
        :done()

    self.Tags.level = self:CreateTag(self.FrameFG, "[dd:difficulty][level]")
        :SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
        :SetPoint("CENTER", self, -26, -14)
        :SetJustifyH("CENTER")
        :done()

    self.Tags.smarthp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        :SetPoint("CENTER", self.Health, 0, -2)
        :SetJustifyH("CENTER")
        :done()
end

local function createThreatType(self)
    local fg_files = {
        [0] = media.foreground,
        [1] = media.foreground_lowthreat,
        [2] = media.foreground_lowthreat,
        [3] = media.foreground_highthreat,
    }

    local threat_status_file

    local event_handler = function(self, event, unit)
        if unit and unit ~= self.unit then
            return
        end

        local status = UnitCanAttack(self.unit, "target") and UnitThreatSituation(self.unit, "target") or (UnitThreatSituation(self.unit))
        local file = (status ~= nil) and fg_files[status] or fg_files[0]

        if threat_status_file ~= file then
            threat_status_file = file
            self.FrameFG.texture:SetTexture(threat_status_file)
        end
    end

    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", event_handler)
    self:RegisterEvent("UNIT_TARGET", event_handler)

    tinsert(self.__elements, event_handler)
end

local function createAuraIcon(self)
    local f = CreateFrame("Frame", nil, self)

    f.size = 28
    f.spacing = 4
    f.gap = true
    f.initialAnchor = "RIGHT"
    f.onlyShowPlayer = cfg.focus.aura.player_aura_only
    f.showStealableBuffs = cfg.focus.aura.show_stealable_buffs
    f["growth-x"] = "LEFT"
    f["growth-y"] = "DOWN"

    local w = (f.size + f.spacing) * 4
    local h = (f.size + f.spacing) * 4
    f:SetSize(w, h)
    f:SetPoint("RIGHT", self, "LEFT", -40, 0)

    f.reanchorIfVisibleChanged = true
    f.PostCreateButton = core.PostCreateButton
    f.PostUpdateButton = core.PostUpdateButton
    f.PostUpdateGapButton = core.PostUpdateGapButton
    f.FilterAura = core.FilterAuras

    self.Auras = f
end

local function createCastbar(self)
    local barBorder = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

    local cb = CreateFrame("StatusBar", nil, self)
    cb:SetFrameLevel(5)
    cb:SetStatusBarTexture(C.media.texture.status)
    cb:SetStatusBarColor(1, 0.8, 0)
    cb:SetPoint("TOP", self, "BOTTOM", 0, -16)
    cb:SetSize(94, 10)

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
    self.cUnit = "focus"

    self:SetPoint(unpack(cfg.focus.position))
    self:SetScale(cfg.scale)
    self:SetSize(85, 85)

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createPortrait(self)
    createTag(self)
    createThreatType(self)
    createAuraIcon(self)
    createCastbar(self)

    self.RaidTargetIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 18, 1, self, "CENTER", "BOTTOM", 0, 18)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.GroupRoleIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 28, -1, self, "BOTTOMRIGHT", "BOTTOMRIGHT", 4, 10)
    self.GroupRoleIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.LeaderIndicator = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOM", "TOP", 0, 10)
    self.LeaderIndicator:SetTexture(media.leader_Tex)

    self.AssistantIndicator = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMLEFT", "TOPLEFT", 0, 10)
    self.AssistantIndicator:SetTexture(media.assistant_Tex)

    self.ReadyCheckIndicator = core:CreateIcon(self.FrameFG, "OVERLAY", 24, -1, self, "TOPRIGHT", "TOPRIGHT", 0, 8)

    core:SetFader(self, cfg.focus.fader)
end

function module:OnInit()
    local mediaPath = cfg.mediaPath
    media = {
        portrait_overlay = mediaPath .. "uf_portrait_overlay",

        foreground = mediaPath .. C.general.style .. "\\" .. "uf_compact_foreground",
        foreground_highthreat = mediaPath .. C.general.style .. "\\" .. "uf_compact_foreground_highthreat",
        foreground_lowthreat = mediaPath .. C.general.style .. "\\" .. "uf_compact_foreground_lowthreat",
        background = mediaPath .. C.general.style .. "\\" .. "uf_compact_background",

        debuffHighlight = mediaPath .. "uf_compact_debuffHighlight",

        hpTex = mediaPath .. "uf_bartex_normal",
        mpTex = mediaPath .. "uf_bartex_normal",

        incoming_barTex = mediaPath .. "uf_bartex_normal",

        assistant_Tex = mediaPath .. "uf_icon_assistant",
        leader_Tex = mediaPath .. "uf_icon_leader",
    }

    oUF:RegisterStyle("DarkUI:focus", createStyle)
    oUF:SetActiveStyle("DarkUI:focus")
    oUF:Spawn("focus", "DarkUIFocusFrame")
end
