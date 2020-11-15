local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Pet Frame of DarkUI
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

local mediaPath = cfg.mediaPath

local media = {
    portrait_overlay       = mediaPath .. "uf_portrait_overlay",

    foreground             = mediaPath .. C.general.style .. "\\" .. "uf_pet_foreground",
    foreground_hightthreat = mediaPath .. C.general.style .. "\\" .. "uf_pet_foreground_highthreat",
    foreground_lowthreat   = mediaPath .. C.general.style .. "\\" .. "uf_pet_foreground_lowthreat",
    background             = mediaPath .. C.general.style .. "\\" .. "uf_pet_background",

    hpTex                  = mediaPath .. "uf_bartex_normal",
    mpTex                  = mediaPath .. "uf_bartex_normal",

    Incoming_barTex        = mediaPath .. "uf_bartex_normal",
}

local createTexture = function(self)
    -- foreground
    self.FrameFG = CreateFrame('Frame', nil, self)
    self.FrameFG:SetFrameStrata("LOW")
    self.FrameFG:SetFrameLevel(5)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, 'BORDER')
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetAllPoints(self.FrameFG)

    self.FrameFG:SetSize(256, 128)
    self.FrameFG:SetPoint('CENTER', self, 0, 0)

    -- background
    self.FrameBG = CreateFrame('Frame', nil, self)
    self.FrameBG:SetFrameStrata('BACKGROUND')
    self.FrameBG:SetFrameLevel(1)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, 'BACKGROUND')
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)

    self.FrameBG:SetSize(256, 128)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)
end

local createBar = function(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(3)
    self.Health:SetSize(80, 16)
    self.Health:SetPoint('CENTER', self, -25, 4)

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
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.Power:SetPoint('TOP', self.Health, 'BOTTOM', 0, 0)
    self.Power:SetSize(80, 4)

    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .45
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)
    self.Power.bg:SetAlpha(0.1)

    --Incoming heal
    local mhpb = self.Health:CreateTexture(nil, "ARTWORK")
    mhpb:SetTexture(media.Incoming_barTex)
    mhpb:SetVertexColor(0, 1, 0.5, 0.2)

    local ohpb = self.Health:CreateTexture(nil, "ARTWORK")
    ohpb:SetTexture(media.Incoming_barTex)
    ohpb:SetVertexColor(0, 1, 0, 0.2)

    local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
    ahpb:SetTexture(media.Incoming_barTex)
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
        self.Portrait:SetSize(42, 42)

        overlayFrame = CreateFrame('Frame', nil, self.FrameBG)
    else
        self.Portrait = CreateFrame('PlayerModel', nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(38, 38)

        overlayFrame = CreateFrame('Frame', nil, self.Portrait)
    end

    self.Portrait:SetPoint('CENTER', self, 'RIGHT', -2, 0)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, 'BACKGROUND', nil, -7)
    overlay:SetTexture(media.portrait_overlay)
    overlay:SetPoint("TOPLEFT", overlayFrame, -2, 2)
    overlay:SetPoint("BOTTOMRIGHT", overlayFrame, 2, -2)
    overlay:SetAlpha(1)

    self.Portrait.overlay = overlay
end

local createTag = function(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.FrameFG, '[raidcolor][dd:realname]')
                         :SetFont(STANDARD_TEXT_FONT, 14, 'THICKOUTLINE')
                         :SetPoint('TOPRIGHT', self, 'CENTER', 5, -18)
                         :done()

    self.Tags.level = self:CreateTag(self.FrameFG, '[dd:difficulty][level]')
                          :SetFont(STANDARD_TEXT_FONT, 14, 'OUTLINE')
                          :SetPoint('CENTER', self, 25, -16)
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
    tinsert(self.__elements, event_handler)
end

local createStyle = function(self)
    self.colors = C.oUF_colors
    self.cUnit = "pet"

    self:SetSize(100, 33)
    self:SetPoint(unpack(cfg.pet.position))
    self:SetScale(cfg.scale)

    self:RegisterForClicks("AnyDown")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createPortrait(self)
    createTag(self)
    createThreatType(self)

    self.RaidTargetIndicator = DUF.CreateIcon(self, "BACKGROUND", 18, -1, self, "CENTER", "CENTER", -20, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    DUF.SetFader(self, cfg.pet.fader)
end

---------------------------------------------
-- SPAWN PET UNIT
---------------------------------------------
oUF:RegisterStyle("DarkUI:pet", createStyle)
oUF:SetActiveStyle("DarkUI:pet")
oUF:Spawn("pet", "DarkUIPetFrame")
