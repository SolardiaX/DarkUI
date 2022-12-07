local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Focus Frame of DarkUI
----------------------------------------------------------------------------------------

local oUF = ns.oUF or oUF

local CreateFrame = CreateFrame
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local UnitCanAttack = UnitCanAttack
local UnitThreatSituation = UnitThreatSituation
local unpack = unpack
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local cfg = C.unitframe
local DUF = E.unitframe

local mediaPath = cfg.mediaPath

local media = {
    portrait_overlay       = mediaPath .. "uf_portrait_overlay",

    foreground             = mediaPath .. C.general.style .. "\\" .. "uf_compact_foreground",
    foreground_hightthreat = mediaPath .. C.general.style .. "\\" .. "uf_compact_foreground_highthreat",
    foreground_lowthreat   = mediaPath .. C.general.style .. "\\" .. "uf_compact_foreground_lowthreat",
    background             = mediaPath .. C.general.style .. "\\" .. "uf_compact_background",

    debuffHighlight        = mediaPath .. "uf_compact_debuffHighlight",

    hpTex                  = mediaPath .. "uf_bartex_normal",
    mpTex                  = mediaPath .. "uf_bartex_normal",

    incoming_barTex        = mediaPath .. "uf_bartex_normal",

    assistant_Tex          = mediaPath .. "uf_icon_assistant",
    leader_Tex             = mediaPath .. "uf_icon_leader",
}

local createTexture = function(self)
    -- foreground
    self.FrameFG = CreateFrame('Frame', nil, self)
    self.FrameFG:SetFrameStrata("LOW")
    self.FrameFG:SetFrameLevel(5)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, 'BORDER')
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)
    self.FrameFG.texture:SetTexCoord(1, 0, 0, 1)

    self.FrameFG:SetSize(256, 128)
    self.FrameFG:SetPoint('CENTER', self, 0, 0)

    -- background
    self.FrameBG = CreateFrame('Frame', nil, self)
    self.FrameBG:SetFrameStrata('BACKGROUND')
    self.FrameBG:SetFrameLevel(1)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, 'BACKGROUND')
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)
    self.FrameBG.texture:SetTexCoord(1, 0, 0, 1)

    self.FrameBG:SetSize(256, 128)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)

    self.DebuffHighlight = self:CreateTexture(nil, "OVERLAY")
    self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
    self.DebuffHighlight:SetBlendMode("ADD")
    self.DebuffHighlight:SetTexture(media.debuffHighlight)
    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false

    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)
end

local createBar = function(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(94, 14)
    self.Health:SetPoint('BOTTOM', self, 'BOTTOM', 0, 0)

    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
    self.Health.bg:SetTexture(media.hpTex)
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg.multiplier = 0.3

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.Smooth = true
    self.Health.colorClass = true
    self.Health.colorClassNPC = true
    self.Health.colorClassPet = true

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetPoint("CENTER")
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, 0)
    self.Power:SetSize(94, 4)

    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .45
    self.Power.bg:SetAllPoints()
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
        self.Portrait:SetSize(78, 78)

        overlayFrame = CreateFrame('Frame', nil, self.FrameBG)
    else
        self.Portrait = CreateFrame('PlayerModel', nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(58, 58)

        overlayFrame = CreateFrame('Frame', nil, self.Portrait)
    end

    self.Portrait:SetPoint("CENTER", self, 0, 16)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, 'BACKGROUND', nil, -7)
    overlay:SetTexture(media.portrait_overlay)
    overlay:SetPoint("TOPLEFT", overlayFrame, -4, 4)
    overlay:SetPoint("BOTTOMRIGHT", overlayFrame, 4, -4)
    overlay:SetAlpha(1)

    self.Portrait.overlay = overlay
end

local createTag = function(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.FrameFG, '[raidcolor][dd:realname]')
                         :SetFont(STANDARD_TEXT_FONT, 14, 'THICKOUTLINE')
                         :SetPoint('TOP', self, 'BOTTOM', 0, -16)
                         :SetJustifyH('CENTER')
                         :done()

    self.Tags.level = self:CreateTag(self.FrameFG, '[dd:difficulty][level]')
                          :SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
                          :SetPoint('CENTER', self, -26, -14)
                          :SetJustifyH('CENTER')
                          :done()

    self.Tags.smarthp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
                            :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                            :SetPoint("CENTER", self.Health, 0, -2)
                            :SetJustifyH('CENTER')
                            :done()
end

local createThreatType = function(self)
    local fg_files = {
        media.foreground,
        media.foreground_lowthreat,
        media.foreground_hightthreat,
    }

    local default_status = 1
    local threat_status_file

    local event_handler = function(self, _, unit)
        if (unit and unit ~= self.unit) then
            return
        end

        local status = UnitCanAttack(self.unit, 'target') and UnitThreatSituation(self.unit, 'target') or (UnitThreatSituation(self.unit))
        local file = status and fg_files[status] or fg_files[default_status]
        if (threat_status_file ~= file) then
            threat_status_file = file
            self.FrameFG.texture:SetTexture(threat_status_file)
        end
    end

    self:RegisterEvent('UNIT_THREAT_SITUATION_UPDATE', event_handler)
    self:RegisterEvent('UNIT_TARGET', event_handler)
    table.insert(self.__elements, event_handler)
end

local createAuraIcon = function(self)
    local f = CreateFrame('Frame', nil, self)

    f.size = 28
    f.spacing = 4
    f.gap = true
    f.initialAnchor = 'RIGHT'
    f.onlyShowPlayer = cfg.focus.aura.player_aura_only
    f.showStealableBuffs = cfg.focus.aura.show_stealable_buffs
    f['growth-x'] = 'LEFT'
    f['growth-y'] = 'DOWN'

    local h = (f.size + f.spacing) * 6
    local w = (f.size + f.spacing) * 4
    f:SetSize(h, w)
    f:SetPoint('RIGHT', self, 'LEFT', -40, 0)

    f.PostCreateButton = DUF.PostCreateIcon
    f.PostUpdateButton = DUF.PostUpdateIcon
    f.FilterAura = DUF.FilterAuras

    self.Auras = f
end

local createStyle = function(self)
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

    self.RaidTargetIndicator = DUF.CreateIcon(self, "BACKGROUND", 18, -1, self, "CENTER", "BOTTOM", 0, 5)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.GroupRoleIndicator = DUF.CreateIcon(self, "BACKGROUND", 28, -1, self, "BOTTOMRIGHT", "BOTTOMRIGHT", 4, 14)
    self.GroupRoleIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    self.LeaderIndicator = DUF.CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "CENTER", "TOP", 0, 20)
    self.LeaderIndicator:SetTexture(media.leader_Tex)

    self.AssistantIndicator = DUF.CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "CENTER", "TOP", 0, 20)
    self.AssistantIndicator:SetTexture(media.assistant_Tex)
    
    self.MasterLooter = DUF.CreateIcon(self.FrameBG, "BACKGROUND", 24, -1, self, "CENTER", "BOTTOM", 0, 0)

    DUF.SetFader(self, cfg.focus.fader)
end

---------------------------------------------
-- SPAWN FOCUS UNIT
---------------------------------------------
oUF:RegisterStyle("DarkUI:focus", createStyle)
oUF:SetActiveStyle("DarkUI:focus")
oUF:Spawn("focus", "DarkUIFocusFrame")
