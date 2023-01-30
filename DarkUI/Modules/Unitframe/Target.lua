local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Target Frame of DarkUI
----------------------------------------------------------------------------------------
local core = E:Module("UFCore")

local oUF = ns.oUF or oUF

local CreateFrame = CreateFrame
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local UnitLevel, UnitExists, UnitClassification = UnitLevel, UnitExists, UnitClassification
local unpack, tinsert = unpack, table.insert
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local cfg = C.unitframe

local mediaPath = cfg.mediaPath

local media = {
    portrait_overlay   = mediaPath .. "uf_portrait_overlay",
    foreground         = mediaPath .. C.general.style .. "\\" .. "uf_target_foreground",
    foreground_boss    = mediaPath .. C.general.style .. "\\" .. "uf_target_foreground_boss",
    foreground_elite   = mediaPath .. C.general.style .. "\\" .. "uf_target_foreground_elite",
    foreground_rare    = mediaPath .. C.general.style .. "\\" .. "uf_target_foreground_rare",
    background         = mediaPath .. C.general.style .. "\\" .. "uf_target_background",
    debuffHighlight    = mediaPath .. "uf_main_debuffHighlight",

    hpTex              = mediaPath .. "uf_bartex_main_hp",
    mpTex              = mediaPath .. "uf_bartex_main_power",

    castbar_barTex     = mediaPath .. "uf_bartex_normal",
    castbar_foreground = mediaPath .. C.general.style .. "\\" .. "uf_castbar_foreground",
    castbar_background = mediaPath .. C.general.style .. "\\" .. "uf_castbar_background",

    incoming_barTex    = mediaPath .. "uf_bartex_normal",

    assistant_Tex          = mediaPath .. "uf_icon_assistant",
    leader_Tex             = mediaPath .. "uf_icon_leader",
}

local createTexture = function(self)
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
    self.DebuffHighlight:SetTexCoord(1, 0, 0, 1)
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)

    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false
end

local createBar = function(self)
    --health bar
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(212, 28)
    self.Health:SetPoint('CENTER', self, -40, -2)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.colorClass = cfg.target.colorHealth
    self.Health.colorClassNPC = cfg.target.colorHealth
    self.Health.colorClassPet = cfg.target.colorHealth
    self.Health.Smooth = true

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetPoint("CENTER")
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(3)
    self.Power:SetPoint('CENTER', self, -40, -2)
    self.Power:SetSize(200, 40)
    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .45
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    --Incoming heal
    local mhpb = self.Health:CreateTexture(nil, "ARTWORK")
    mhpb:SetWidth(1)
    mhpb:SetTexture(media.incoming_barTex)
    mhpb:SetVertexColor(0, 1, 0.5, 0.2)

    local ohpb = self.Health:CreateTexture(nil, "ARTWORK")
    ohpb:SetWidth(1)
    ohpb:SetTexture(media.incoming_barTex)
    ohpb:SetVertexColor(0, 1, 0, 0.2)

    local abb = self.Health:CreateTexture(nil, "ARTWORK")
    abb:SetWidth(1)
    abb:SetTexture(media.incoming_barTex)
    abb:SetVertexColor(1, 1, 0, 0.2)

    local abbo = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    abbo:SetAllPoints(abb)
    abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
    abbo.tileSize = 32

    local oag = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    oag:SetWidth(15)
    oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    oag:SetBlendMode("ADD")
    oag:SetAlpha(.7)
    oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -7, 2)
    oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -7, -2)

    local hab = CreateFrame("StatusBar", nil, self.Health)
    hab:SetPoint("TOPLEFT", self.Health)
    hab:SetPoint("BOTTOMRIGHT", self.Health:GetStatusBarTexture())
    hab:SetReverseFill(true)
    hab:SetStatusBarTexture(media.incoming_barTex)
    hab:SetStatusBarColor(0, .5, .8, .5)
    hab:SetFrameLevel(self.Health:GetFrameLevel())

    local ohg = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    ohg:SetWidth(15)
    ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
    ohg:SetBlendMode("ADD")
    ohg:SetAlpha(.5)
    ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
    ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

    self.HealPredictionAndAbsorb = {
        myBar = mhpb,
        otherBar = ohpb,
        absorbBar = abb,
        absorbBarOverlay = abbo,
        overAbsorbGlow = oag,
        healAbsorbBar = hab,
        overHealAbsorbGlow = ohg,
        maxOverflow = 1,
    }   
end

local createPortrait = function(self)
    local overlayFrame

    if cfg.portrait3D == false then
        self.Portrait = self.FrameBG:CreateTexture(nil, 'BACKGROUND', nil, 3)
        self.Portrait:SetSize(64, 64)

        overlayFrame = CreateFrame('Frame', nil, self.FrameBG)
    else
        self.Portrait = CreateFrame('PlayerModel', nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(60, 60)

        overlayFrame = CreateFrame('Frame', nil, self.Portrait)
    end

    self.Portrait:SetPoint("CENTER", self, 110, 6)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, 'BACKGROUND', nil, -7)
    overlay:SetTexture(media.portrait_overlay)
    overlay:SetPoint("TOPLEFT", overlayFrame, -10, 10)
    overlay:SetPoint("BOTTOMRIGHT", overlayFrame, 10, -10)
    overlay:SetAlpha(1)

    self.Portrait.overlay = overlay
end

local createTag = function(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.FrameFG, "[raidcolor][dd:realname]")
                         :SetFont(STANDARD_TEXT_FONT, 14, "THICKOUTLINE")
                         :SetPoint("RIGHT", self.Health, -2, 35)
                         :SetJustifyH('RIGHT')
                         :done()

    self.Tags.level = self:CreateTag(self.FrameFG, "[dd:difficulty][level]")
                          :SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
                          :SetPoint("CENTER", self.Health, "RIGHT", 90, -20)
                          :SetJustifyH('CENTER')
                          :done()

    self.Tags.hp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
                       :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                       :SetPoint("LEFT", self.Health, 6, 0)
                       :SetJustifyH('LEFT')
                       :done()

    self.Tags.pp = self:CreateTag(self.FrameFG, "[dd:pp]")
                       :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                       :SetPoint("RIGHT", self.Health, -6, 0)
                       :SetJustifyH('RIGHT')
                       :done()
end

local createCastbar = function(self)
    local castbar = CreateFrame("StatusBar", nil, self)
    castbar:SetStatusBarTexture(media.castbar_barTex)
    castbar:SetStatusBarColor(27 / 255, 147 / 255, 226 / 255)
    castbar:SetFrameStrata("LOW")
    castbar:SetFrameLevel(3)
    castbar:SetSize(146, 16)
    castbar:SetPoint(unpack(cfg.target.castbar.position))

    local fg = CreateFrame("Frame", nil, castbar)
    fg:SetPoint("CENTER", -24, 0)
    fg:SetSize(256, 128)

    fg.Texture = fg:CreateTexture(nil, "ARTWORK")
    fg.Texture:SetTexture(media.castbar_foreground)
    fg.Texture:SetAllPoints(fg)
    fg.Texture:SetTexCoord(1, 0, 0, 1)

    local bg = CreateFrame("Frame", nil, castbar)
    bg:SetFrameStrata("BACKGROUND")
    bg:SetPoint("CENTER", fg)
    bg:SetSize(256, 128)

    bg.Texture = bg:CreateTexture(nil, "ARTWORK")
    bg.Texture:SetTexture(media.castbar_background)
    bg.Texture:SetAllPoints(bg)
    bg.Texture:SetTexCoord(1, 0, 0, 1)

    castbar.Foreground = fg
    castbar.Background = bg

    local icon = castbar:CreateTexture(nil, "ARTWORK")
    icon:SetSize(48, 48)
    icon:SetPoint("RIGHT", castbar, "LEFT", -2, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    castbar.Icon = icon

    local safe = castbar:CreateTexture(nil, "BORDER")
    safe:SetTexture(media.castbar_barTex)
    safe:SetVertexColor(231 / 255, 48 / 255, 78 / 255)
    safe:SetWidth(1)
    safe:SetPoint("TOPRIGHT")
    safe:SetPoint("BOTTOMRIGHT")
    castbar.SafeZone = safe

    local spark = castbar:CreateTexture(nil, "OVERLAY", nil, -7)
    spark:SetBlendMode("ADD")
    spark:SetVertexColor(0.8, 0.6, 0, 1)
    spark:SetSize(15, castbar:GetHeight() * 2)
    castbar.Spark = spark

    local text = core:CreateFont(castbar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    text:SetPoint("BOTTOMRIGHT", castbar, "TOPRIGHT", 0, 10)
    text:SetJustifyH('RIGHT')
    castbar.Text = text

    local time = core:CreateFont(castbar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    time:SetPoint("LEFT", castbar, "LEFT", 4, 2)
    time:SetJustifyH("LEFT")
    castbar.Time = time

    castbar.enableFader = cfg.target.castbar.enableFader
    castbar.timeToHold = .5
    castbar.PostCastStart = core.PostCastStart
    castbar.PostCastFail = core.PostCastFail
    castbar.PostCastInterruptible = core.PostCastInterruptible
    castbar.PostCastStop = core.PostCastStop

    self.Castbar = castbar
end

local createTargetType = function(self)
    local fg_files = {
        elite     = media.foreground_elite,
        rare      = media.foreground_rare,
        rareelite = media.foreground_elite,
        worldboss = media.foreground_boss,
    }

    local event_handler = function(self, _)
        local level = UnitLevel(self.unit)
        local classification = UnitExists(self.unit) and UnitClassification(self.unit)
        local file = level == -1 and fg_files.worldboss or (classification and fg_files[classification] or media.foreground)

        self.FrameFG.texture:SetTexture(file)
    end

    self:RegisterEvent("PLAYER_TARGET_CHANGED", event_handler)
    tinsert(self.__elements, event_handler)
end

local createAuraIcon = function(self)
    local f = CreateFrame('Frame', nil, self)

    f.size = 28
    f.spacing = 6
    f.gap = true
    f.initialAnchor = 'TOPLEFT'
    f.onlyShowPlayer = cfg.target.aura.player_aura_only
    f.showStealableBuffs = cfg.target.aura.show_stealable_buffs
    f['growth-x'] = 'RIGHT'
    f['growth-y'] = 'DOWN'

    local h = (f.size + f.spacing) * 6
    local w = (f.size + f.spacing) * 4
    f:SetSize(h, w)
    f:SetPoint('TOPLEFT', self, 'CENTER', 30, -60)

    f.reanchorIfVisibleChanged = true
    f.PostCreateButton = core.PostCreateIcon
    f.PostUpdateButton = core.PostUpdateIcon
    f.PostUpdateGapButton = core.PostUpdateGapIcon
    f.FilterAura = core.FilterAuras

    self.Auras = f
end

local createCombatFeed = function(self)
    local fcf = CreateFrame("Frame", nil, self)
    fcf:SetSize(32, 32)
    fcf:SetPoint("BOTTOM", self, "TOPRIGHT", 0, 120)

    for i = 1, 6 do
        fcf[i] = fcf:CreateFontString("$parentFCFText" .. i, "OVERLAY")
    end

    fcf.font = STANDARD_TEXT_FONT
    fcf.fontFlags = "THINOUTLINE"
    fcf.fontHeight = 16
    fcf.showPets = true
    fcf.showHots = true
    fcf.showAutoAttack = true
    fcf.showOverHealing = true
    fcf.abbreviateNumbers = true

    self.FloatingCombatFeedback = fcf
end

local createStyle = function(self)
    self.colors = C.oUF_colors
    self.cUnit = "target"

    self:SetPoint(unpack(cfg.target.position))
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
    createTargetType(self)
    createAuraIcon(self)
    --createCombatFeed(self)

    self.PvPClassificationIndicator = core:CreateIcon(self, "BACKGROUND", 24, -1, self, "LEFT", "RIGHT", -32, 0)
    self.PvPTimer = self:CreateTag(self, "[dd:pvptimer]", .5)
                        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                        :SetPoint("TOP", self.PvPClassificationIndicator, 'BOTTOM', 2, -2)
                        :SetJustifyH('CENTER')
                        :done()

    self.CombatIndicator = core:CreateIcon(self, "BACKGROUND", 28, -1, self, "RIGHT", "LEFT", -28, 0)
    self.CombatIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.LeaderIndicator = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMRIGHT", "TOPRIGHT", -12, 25)
    self.LeaderIndicator:SetTexture(media.leader_Tex)

    self.AssistantIndicator = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMRIGHT", "BOTTOMRIGHT", 12, 25)
    self.AssistantIndicator:SetTexture(media.assistant_Tex)

    self.MasterLooter = core:CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMRIGHT", "TOPRIGHT", -12, 25)

    self.RaidTargetIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 24, 1, self, "CENTER", "CENTER", -40, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.GroupRoleIndicator = core:CreateIcon(self, "BACKGROUND", 28, -1, self, "TOPRIGHT", "TOPRIGHT", -45, 22)
    self.GroupRoleIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.QuestIndicator = core:CreateIcon(self, "BACKGROUND", 28, -1, self, "LEFT", "RIGHT", 20, 0)

    core:SetFader(self, cfg.target.fader)
end

---------------------------------------------
-- SPAWN TARGET UNIT
---------------------------------------------
oUF:RegisterStyle("DarkUI:target", createStyle)
oUF:SetActiveStyle("DarkUI:target")
oUF:Spawn("target", "DarkUITargetFrame")
