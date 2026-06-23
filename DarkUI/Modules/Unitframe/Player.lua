local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Player Frame
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("Player")

local oUF = select(2, ...).oUF or oUF

local UnitCanAttack = UnitCanAttack
local UnitThreatSituation, UnitAffectingCombat = UnitThreatSituation, UnitAffectingCombat

local cfg = C.unitframe

local media

local function createTexture(self)
    -- foreground
    self.FrameFG = CreateFrame("Frame", nil, self)
    self.FrameFG:SetFrameStrata("LOW")
    self.FrameFG:SetFrameLevel(5)
    self.FrameFG:SetSize(512, 128)
    self.FrameFG:SetPoint("CENTER", self, 0, 0)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, "BORDER")
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)

    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("BACKGROUND")
    self.FrameBG:SetFrameLevel(1)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)
    self.FrameBG:SetSize(512, 128)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)

    --debuff highlight
    self.DebuffHighlight = self:CreateTexture(nil, "OVERLAY")
    self.DebuffHighlight:SetTexture(media.debuffHighlight)
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)

    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false
end

local function createBar(self)
    --health bar
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(212, 28)
    self.Health:SetPoint("CENTER", self, 40, -2)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.colorSmooth = true
    self.Health.colorClass = cfg.player.colorHealth
    self.Health.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(3)
    self.Power:SetPoint("CENTER", self, 40, -2)
    self.Power:SetSize(200, 40)
    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)
    self.Power.bg.multiplier = 0.45

    self.Power.frequentUpdates = true
    self.Power.colorClass = true
    self.Power.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Power.PostUpdateColor = core.PostUpdatePowerColor

    --Incoming heal
    local healingAll = CreateFrame("StatusBar", nil, self.Health)
    healingAll:SetPoint("TOP")
    healingAll:SetPoint("BOTTOM")
    healingAll:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    healingAll:SetWidth(212)
    healingAll:SetStatusBarTexture(media.incoming_barTex)
    healingAll:SetStatusBarColor(0, 1, 0.5, 0.2)

    local damageAbsorb = CreateFrame("StatusBar", nil, self.Health)
    damageAbsorb:SetPoint("TOP")
    damageAbsorb:SetPoint("BOTTOM")
    damageAbsorb:SetPoint("LEFT", healingAll:GetStatusBarTexture(), "RIGHT")
    damageAbsorb:SetWidth(212)
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
    healAbsorb:SetWidth(212)
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

    -- AdditionalPower
    self.AdditionalPower = CreateFrame("StatusBar", nil, self)
    self.AdditionalPower:SetFrameLevel(5)
    self.AdditionalPower:SetStatusBarTexture(media.altPowerTex)
    self.AdditionalPower:SetHeight(2)
    self.AdditionalPower:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 3, 6)
    self.AdditionalPower:SetPoint("BOTTOMRIGHT", self.Power, "BOTTOMRIGHT", -3, 0)

    self.AdditionalPower.background = self.AdditionalPower:CreateTexture(nil, "BORDER")
    self.AdditionalPower.background:SetAllPoints(self.AdditionalPower)
    self.AdditionalPower.background:SetTexture(media.altPowerTex)
    self.AdditionalPower.background.multiplier = 0.3

    self.AdditionalPower.text = self.AdditionalPower:CreateFontText(12, "")
    self.AdditionalPower.text:SetPoint("CENTER")

    self.AdditionalPower.PostUpdate = function(element, cur, max)
        if not element.text then return end
        if max == 0 then
            element.text:SetText("")
            return
        end
        element.text:SetText(E:AbbreviateNumber(cur))
    end

    self.AdditionalPower.colorPower = true
    self.AdditionalPower.displayPairs = {
        ["DRUID"] = {
            [1] = true,
            [3] = true,
            [8] = true,
        },
        ["SHAMAN"] = {
            [11] = true,
        },
        ["PRIEST"] = {
            [13] = true,
        },
    }
end

local function createPortrait(self)
    local overlayFrame

    if cfg.portrait3D == false then
        self.Portrait = self.FrameBG:CreateTexture(nil, "BACKGROUND", nil, 3)
        self.Portrait:SetSize(64, 64)

        overlayFrame = CreateFrame("Frame", nil, self.FrameBG)
    else
        self.Portrait = CreateFrame("PlayerModel", nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(60, 60)

        overlayFrame = CreateFrame("Frame", nil, self.Portrait)
    end

    self.Portrait:SetPoint("CENTER", self, -108, 6)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
    overlay:SetTexture(media.portrait_overlay)
    overlay:SetPoint("TOPLEFT", overlayFrame, -10, 10)
    overlay:SetPoint("BOTTOMRIGHT", overlayFrame, 10, -10)
    overlay:SetAlpha(1)

    self.Portrait.overlay = overlay
end

local function createTag(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.FrameFG, "[raidcolor][dd:realname]")
        :SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE")
        :SetPoint("LEFT", self.Health, 2, 35)
        :SetJustifyH("LEFT")
        :done()

    self.Tags.level = self:CreateTag(self.FrameFG, "[dd:difficulty][level]")
        :SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
        :SetPoint("CENTER", self.Health, "LEFT", -80, 32)
        :SetJustifyH("CENTER")
        :done()

    self.Tags.hp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        :SetPoint("RIGHT", self.Health, -6, 0)
        :SetJustifyH("RIGHT")
        :done()

    self.Tags.pp =
        self:CreateTag(self.FrameFG, "[dd:pp]"):SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE"):SetPoint("LEFT", self.Health, 6, 0):SetJustifyH("LEFT"):done()
end

local function createCastbar(self)
    local castbar = CreateFrame("StatusBar", nil, self)
    castbar:SetStatusBarTexture(media.castbar_barTex)
    castbar:SetStatusBarColor(27 / 255, 147 / 255, 226 / 255)
    castbar:SetFrameStrata("LOW")
    castbar:SetFrameLevel(3)
    castbar:SetSize(146, 16)
    castbar:SetReverseFill(true)
    castbar:SetPoint(unpack(cfg.player.castbar.position))

    castbar.castTicks = {}

    local fg = CreateFrame("Frame", nil, castbar)
    fg:SetPoint("CENTER", 24, 0)
    fg:SetSize(256, 128)

    fg.Texture = fg:CreateTexture(nil, "ARTWORK")
    fg.Texture:SetTexture(media.castbar_foreground)
    fg.Texture:SetAllPoints(fg)

    local bg = CreateFrame("Frame", nil, castbar)
    bg:SetFrameStrata("BACKGROUND")
    bg:SetPoint("CENTER", fg)
    bg:SetSize(256, 128)

    bg.Texture = bg:CreateTexture(nil, "ARTWORK")
    bg.Texture:SetTexture(media.castbar_background)
    bg.Texture:SetAllPoints(bg)

    castbar.Foreground = fg
    castbar.Background = bg

    local icon = castbar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(48, 48)
    icon:SetPoint("LEFT", castbar, "RIGHT", 2, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    castbar.Icon = icon

    local safe = castbar:CreateTexture(nil, "BORDER", nil, 1)
    safe:SetTexture(media.castbar_barTex)
    safe:SetVertexColor(231 / 255, 48 / 255, 78 / 255)
    castbar.SafeZone = safe

    local spark = castbar:CreateTexture(nil, "OVERLAY", nil, 7)
    spark:SetBlendMode("ADD")
    spark:SetVertexColor(0.8, 0.6, 0, 1)
    spark:SetSize(15, castbar:GetHeight() * 2)
    castbar.Spark = spark

    local text = core:CreateFont(castbar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 0, 10)
    text:SetJustifyH("LEFT")
    castbar.Text = text

    local time = core:CreateFont(castbar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    time:SetPoint("RIGHT", castbar, "RIGHT", -4, 2)
    time:SetJustifyH("RIGHT")
    castbar.Time = time

    castbar.enableFader = cfg.player.castbar.enableFader
    castbar.timeToHold = 0.5
    castbar.PostCastStart = core.PostCastStart
    castbar.PostCastFail = core.PostCastFail
    castbar.PostCastInterruptible = core.PostCastInterruptible
    castbar.PostCastStop = core.PostCastStop
    castbar.CreatePip = core.CreatePip
    castbar.PostUpdatePips = core.PostUpdatePips

    self.Castbar = castbar
end

local function createThreatType(self)
    local event_handler = function(self, _, unit)
        unit = unit or self.unit

        local file = media.foreground
        local status = UnitCanAttack(self.unit, "target") and UnitThreatSituation(unit, "target") or UnitThreatSituation(unit)

        if status == 3 then
            file = media.foreground_highthreat
        elseif status ~= nil or UnitAffectingCombat("player") then
            file = media.foreground_lowthreat
        end

        self.FrameFG.texture:SetTexture(file)
    end

    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", event_handler)
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", event_handler)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", event_handler, true)
    self:RegisterEvent("PLAYER_REGEN_ENABLED", event_handler, true)
    tinsert(self.__elements, event_handler)
end

local function createStyle(self)
    self.colors = C.oUF_colors
    self.cUnit = "player"

    self:SetPoint(unpack(cfg.player.position))
    self:SetSize(270, 45)
    self:SetScale(cfg.scale)

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createPortrait(self)
    createTag(self)
    createCastbar(self)
    createThreatType(self)

    self.RestingIndicator = core:CreateIcon(self, "BACKGROUND", 28, -1, self, "RIGHT", "LEFT", -32, 0)
    self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.PvPClassificationIndicator = core:CreateIcon(self, "BACKGROUND", 24, -1, self, "RIGHT", "LEFT", -32, 0)
    self.PvPTimer = self:CreateTag(self, "[dd:pvptimer]", 0.5)
        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        :SetPoint("TOP", self.PvPClassificationIndicator, "BOTTOM", 2, -2)
        :SetJustifyH("CENTER")
        :done()

    self.CombatIndicator = core:CreateIcon(self, "BACKGROUND", 32, -1, self, "LEFT", "RIGHT", 28, 0)

    self.LeaderIndicator = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMLEFT", "TOPLEFT", 12, 25)
    self.LeaderIndicator:SetTexture(media.leader_Tex)

    self.AssistantIndicator = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMLEFT", "TOPLEFT", 12, 25)
    self.AssistantIndicator:SetTexture(media.assistant_Tex)

    self.RaidTargetIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 24, 4, self, "CENTER", "CENTER", 40, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.GroupRoleIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 28, -1, self, "TOPLEFT", "TOPLEFT", 45, 22)
    self.GroupRoleIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    core:SetFader(self, cfg.player.fader)
    core:SetupClassPower(self)
end

function module:OnInit()
    C_CVar.SetCVar("showPartyBackground", 0)

    local mediaPath = cfg.mediaPath
    media = {
        portrait_overlay = mediaPath .. "uf_portrait_overlay",
        foreground = mediaPath .. C.general.style .. "\\" .. "uf_player_foreground",
        foreground_highthreat = mediaPath .. C.general.style .. "\\" .. "uf_player_foreground_highthreat",
        foreground_lowthreat = mediaPath .. C.general.style .. "\\" .. "uf_player_foreground_lowthreat",
        background = mediaPath .. C.general.style .. "\\" .. "uf_player_background",
        debuffHighlight = mediaPath .. "uf_main_debuffHighlight",

        hpTex = mediaPath .. "uf_bartex_main_hp",
        mpTex = mediaPath .. "uf_bartex_main_power",
        altPowerTex = mediaPath .. "uf_bartex_altpower",

        castbar_barTex = mediaPath .. "uf_bartex_normal",
        castbar_foreground = mediaPath .. C.general.style .. "\\" .. "uf_castbar_foreground",
        castbar_background = mediaPath .. C.general.style .. "\\" .. "uf_castbar_background",

        incoming_barTex = mediaPath .. "uf_bartex_normal",

        assistant_Tex = mediaPath .. "uf_icon_assistant",
        leader_Tex = mediaPath .. "uf_icon_leader",
    }

    oUF:RegisterStyle("DarkUI:player", createStyle)
    oUF:SetActiveStyle("DarkUI:player")
    oUF:Spawn("player", "DarkUIPlayerFrame")
end
