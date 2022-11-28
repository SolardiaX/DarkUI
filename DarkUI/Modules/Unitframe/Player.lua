local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Player Frame of DarkUI
----------------------------------------------------------------------------------------

local oUF = ns.oUF or oUF

local CreateFrame = CreateFrame
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local UnitCanAttack = UnitCanAttack
local UnitThreatSituation = UnitThreatSituation
local unpack, tinsert = unpack, table.insert
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local cfg = C.unitframe
local DUF = E.unitframe

local UNIT_CLASS = E.class
local mediaPath = cfg.mediaPath

local media = {
    portrait_overlay       = mediaPath .. "uf_portrait_overlay",
    foreground             = mediaPath .. C.general.style .. "\\" .. "uf_player_foreground",
    foreground_hightthreat = mediaPath .. C.general.style .. "\\" .. "uf_player_foreground_highthreat",
    foreground_lowthreat   = mediaPath .. C.general.style .. "\\" .. "uf_player_foreground_lowthreat",
    background             = mediaPath .. C.general.style .. "\\" .. "uf_player_background",
    debuffHighlight        = mediaPath .. "uf_main_debuffHighlight",

    hpTex                  = mediaPath .. "uf_bartex_main_hp",
    mpTex                  = mediaPath .. "uf_bartex_main_power",

    castbar_barTex         = mediaPath .. "uf_bartex_normal",
    castbar_foreground     = mediaPath .. C.general.style .. "\\" .. "uf_castbar_foreground",
    castbar_background     = mediaPath .. C.general.style .. "\\" .. "uf_castbar_background",

    incoming_barTex        = mediaPath .. "uf_bartex_normal",

    assistant_Tex          = mediaPath .. "uf_icon_assistant",
    leader_Tex             = mediaPath .. "uf_icon_leader",
}

local createTexture = function(self)
    -- foreground
    self.FrameFG = CreateFrame("Frame", nil, self)
    self.FrameFG:SetFrameStrata("LOW")
    self.FrameFG:SetFrameLevel(5)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, "BORDER")
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)

    self.FrameFG:SetSize(512, 128)
    self.FrameFG:SetPoint("CENTER", self, 0, 0)

    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("BACKGROUND")
    self.FrameBG:SetFrameLevel(1)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)

    self.FrameBG:SetPoint("CENTER", self, 0, 0)
    self.FrameBG:SetSize(512, 128)

    --debuff highlight
    self.DebuffHighlight = self:CreateTexture(nil, "OVERLAY")
    self.DebuffHighlight:SetTexture(media.debuffHighlight)
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false

    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)
end

local createBar = function(self)
    --health bar
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(212, 28)
    self.Health:SetPoint('CENTER', self, 40, -2)

    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.colorClass = cfg.player.colorHealth
    self.Health.Smooth = true

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetPoint("CENTER")
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(3)
    self.Power:SetPoint('CENTER', self, 40, -2)
    self.Power:SetSize(200, 40)

    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .45
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)

    --Incoming heal
    local mhpb = self.Health:CreateTexture(nil, "ARTWORK")
    mhpb:SetTexture(media.incoming_barTex)
    mhpb:SetVertexColor(0, 1, 0.5, 0.2)

    local ohpb = self.Health:CreateTexture(nil, "ARTWORK")
    ohpb:SetTexture(media.incoming_barTex)
    ohpb:SetVertexColor(0, 1, 0, 0.2)

    local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
    ahpb:SetTexture(media.incoming_barTex)
    ahpb:SetVertexColor(1, 1, 0, 0.2)

    self.HealPrediction = {
        myBar           = mhpb,
        otherBar        = ohpb,
        absorbBar       = ahpb,
        maxOverflow     = 1,
        frequentUpdates = true
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

    self.Portrait:SetPoint("CENTER", self, -108, 6)

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
                         :SetPoint("LEFT", self.Health, 2, 35)
                         :SetJustifyH('LEFT')
                         :done()

    self.Tags.level = self:CreateTag(self.FrameFG, "[dd:difficulty][level]")
                          :SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE")
                          :SetPoint("CENTER", self.Health, "LEFT", -80, 32)
                          :SetJustifyH('CENTER')
                          :done()

    self.Tags.hp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
                       :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                       :SetPoint("RIGHT", self.Health, -6, 0)
                       :SetJustifyH('RIGHT')
                       :done()

    self.Tags.pp = self:CreateTag(self.FrameFG, "[dd:pp]")
                       :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                       :SetPoint("LEFT", self.Health, 6, 0)
                       :SetJustifyH('LEFT')
                       :done()
end

local createCastbar = function(self)
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

    local text = DUF.CreateFont(castbar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    text:SetPoint("BOTTOMLEFT", castbar, "TOPLEFT", 0, 10)
    text:SetJustifyH('LEFT')
    castbar.Text = text

    local time = DUF.CreateFont(castbar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    time:SetPoint("RIGHT", castbar, "RIGHT", -4, 2)
    time:SetJustifyH("RIGHT")
    castbar.Time = time

    castbar.PostCastStart = DUF.PostCastStart
    castbar.PostCastFail = DUF.PostCastFail
    castbar.PostCastInterruptible = DUF.PostCastInterruptible
    castbar.PostCastStop = DUF.PostCastStop

    self.Castbar = castbar
end

local createThreatType = function(self)
    local event_handler = function(self, _, unit)
        if (unit and unit ~= self.unit) then
            return
        end

        local file = media.foreground
        local status = UnitCanAttack(self.unit, "target") and UnitThreatSituation(self.unit, "target") or UnitThreatSituation(self.unit)

        if status == 3 then
            file = media.foreground_hightthreat
        elseif status ~= nil then
            file = media.foreground_lowthreat
        end

        self.FrameFG.texture:SetTexture(file)
    end

    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", event_handler)
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", event_handler)
    tinsert(self.__elements, event_handler)
end

local createClassModule = function(self)
    local classModule = DUF.classModule

    if cfg.classModule.classpowerbar.diabolic then
        classModule.classpowerbar.CreateDiablolicBar(self)
    end

    if cfg.classModule.classpowerbar.blizzard then
        classModule.classpowerbar.ResetBlizzardBarPosition(self)
        
        if classModule.blizzard[UNIT_CLASS] then
            classModule.blizzard[UNIT_CLASS](self)
        end
    end
end

local createQuakeTimer = function(self)
    local bar = CreateFrame("StatusBar", nil, self)
    bar:SetSize(300, 20)
    bar:SetStatusBarTexture(C.media.texture.status_s)
    bar:SetStatusBarColor(0, 1, 0)
    bar:CreateShadow()
    bar:SetPoint("TOP", UIParent, "TOP", 0, -140)
    bar:Hide()

    bar.Background = bar:CreateTexture(nil, "BACKGROUND")
    bar.Background:SetAllPoints()
    bar.Background:SetTexture(C.media.texture.status_s)
    bar.Background:SetVertexColor(0, 0, 0, .5)

    bar.Tex = bar:CreateTexture(nil, "BACKGROUND", nil, 1)
    bar.Tex:SetAllPoints(bar.Background)
    bar.Tex:SetTexture(C.media.texture.status_bg, true, true)
    bar.Tex:SetHorizTile(true)
    bar.Tex:SetVertTile(true)
    bar.Tex:SetBlendMode("ADD")

    bar.Spark = bar:CreateTexture(nil, "OVERLAY")
    bar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    bar.Spark:SetBlendMode("ADD")
    bar.Spark:SetAlpha(.8)
    bar.Spark:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
    bar.Spark:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)

    bar.SpellName = DUF.CreateFont(bar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    bar.SpellName:SetPoint("LEFT", 2, 0)

    bar.Text = DUF.CreateFont(bar, STANDARD_TEXT_FONT, 12, "OUTLINE")
    bar.Text:SetPoint("RIGHT", -2, 0)

    bar.Icon = bar:CreateTexture(nil, "ARTWORK")
    bar.Icon:SetSize(bar:GetHeight(), bar:GetHeight())
    bar.Icon:SetPoint("RIGHT", bar, "LEFT", -5, 0)
    bar.Icon:SetTexCoord(unpack(C.media.texCoord))

    self.QuakeTimer = bar
end

local createStyle = function(self)
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
    createClassModule(self)
    createQuakeTimer(self)

    self.RestingIndicator = DUF.CreateIcon(self, "BACKGROUND", 28, -1, self, "RIGHT", "LEFT", -30, 0)
    self.RestingIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.PvPIndicator = DUF.CreateIcon(self, "BACKGROUND", 24, -1, self, "RIGHT", "LEFT", -30, 0)
    self.PvPTimer = self:CreateTag(self, "[dd:pvptimer]", .5)
                        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                        :SetPoint("TOP", self.PvPIndicator, 'BOTTOM', 2, -2)
                        :SetJustifyH('CENTER')
                        :done()

    self.CombatIndicator = DUF.CreateIcon(self, "BACKGROUND", 28, -1, self, "LEFT", "RIGHT", 25, 0)
    self.CombatIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.LeaderIndicator = DUF.CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMLEFT", "TOPLEFT", 12, 25)
    self.LeaderIndicator:SetTexture(media.leader_Tex)

    self.AssistantIndicator = DUF.CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "BOTTOMLEFT", "TOPLEFT", 12, 25)
    self.AssistantIndicator:SetTexture(media.assistant_Tex)

    self.MasterLooter = DUF.CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "TOPLEFT", "BOTTOMLEFT", 12, 0)

    self.RaidTargetIndicator = DUF.CreateIcon(self.FrameFG, "ARTWORK", 24, 4, self, "CENTER", "CENTER", 40, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.GroupRoleIndicator = DUF.CreateIcon(self.FrameFG, "ARTWORK", 28, -1, self, "TOPLEFT", "TOPLEFT", 45, 22)
    self.GroupRoleIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    DUF.SetFader(self, cfg.player.fader)
end

---------------------------------------------
-- SPAWN PLAYER UNIT
---------------------------------------------
oUF:RegisterStyle("DarkUI:player", createStyle)
oUF:SetActiveStyle("DarkUI:player")
oUF:Spawn("player", "DarkUIPlayerFrame")
