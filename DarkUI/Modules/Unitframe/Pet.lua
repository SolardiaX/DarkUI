local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Pet Frame of DarkUI
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("Pet")

local oUF = select(2, ...).oUF or oUF

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

    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("BACKGROUND")
    self.FrameBG:SetFrameLevel(1)
    self.FrameBG:SetSize(256, 128)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)
end

local function createBar(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(80, 16)
    self.Health:SetPoint("CENTER", self, -25, 4)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.colorSmooth = true
    self.Health.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Health.colorClass = true
    self.Health.colorClassNPC = true
    self.Health.colorClassPet = true

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetPoint("CENTER")
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.Power:SetPoint("TOP", self.Health, "BOTTOM", 0, 0)
    self.Power:SetSize(80, 4)
    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = 0.45
    self.Power.bg:SetAllPoints(self.Power)
    self.Power.bg:SetTexture(media.mpTex)
    self.Power.bg:SetAlpha(0.1)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Power.PostUpdateColor = core.PostUpdatePowerColor

    --Incoming heal
    local healingAll = CreateFrame("StatusBar", nil, self.Health)
    healingAll:SetPoint("TOP")
    healingAll:SetPoint("BOTTOM")
    healingAll:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    healingAll:SetWidth(80)
    healingAll:SetStatusBarTexture(media.incoming_barTex)
    healingAll:SetStatusBarColor(0, 1, 0.5, 0.2)

    local damageAbsorb = CreateFrame("StatusBar", nil, self.Health)
    damageAbsorb:SetPoint("TOP")
    damageAbsorb:SetPoint("BOTTOM")
    damageAbsorb:SetPoint("LEFT", healingAll:GetStatusBarTexture(), "RIGHT")
    damageAbsorb:SetWidth(80)
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
    healAbsorb:SetWidth(80)
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
        self.Portrait:SetSize(42, 42)

        overlayFrame = CreateFrame("Frame", nil, self.FrameBG)
    else
        self.Portrait = CreateFrame("PlayerModel", nil, self.FrameBG)
        self.Portrait:SetFrameLevel(3)
        self.Portrait:SetSize(38, 38)

        overlayFrame = CreateFrame("Frame", nil, self.Portrait)
    end

    self.Portrait:SetPoint("CENTER", self, "RIGHT", -2, 0)

    overlayFrame:SetFrameLevel(4)
    overlayFrame:SetAllPoints(self.Portrait)

    local overlay = overlayFrame:CreateTexture(nil, "BACKGROUND", nil, -7)
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
        :SetPoint("TOPRIGHT", self, "CENTER", 5, -18)
        :done()

    self.Tags.level = self:CreateTag(self.FrameFG, "[dd:difficulty][level]"):SetFont(STANDARD_TEXT_FONT, 14, "OUTLINE"):SetPoint("CENTER", self, 25, -16):done()

    self.Tags.smarthp = self:CreateTag(self.FrameFG, "[dd:smarthp]")
        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        :SetPoint("CENTER", self.Health, 0, -2)
        :SetJustifyH("CENTER")
        :done()
end

local function createThreatType(self)
    local fg_files = {
        media.foreground,
        media.foreground_lowthreat,
        media.foreground_hightthreat,
    }

    local default_status = 1
    local threat_status_file

    local function event_handler(self, _, unit)
        if unit and unit ~= self.unit then return end

        local status = UnitCanAttack(self.unit, "target") and UnitThreatSituation(self.unit, "target") or (UnitThreatSituation(self.unit))
        local file = status and fg_files[status] or fg_files[default_status]

        if threat_status_file ~= file then
            threat_status_file = file
            self.FrameFG.texture:SetTexture(threat_status_file)
        end
    end

    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", event_handler)
    self:RegisterEvent("UNIT_TARGET", event_handler)

    table.insert(self.__elements, event_handler)
end

local function createStyle(self)
    self.colors = C.oUF_colors
    self.cUnit = "pet"

    self:SetSize(100, 33)
    self:SetPoint(unpack(cfg.pet.position))
    self:SetScale(cfg.scale)

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createPortrait(self)
    createTag(self)
    createThreatType(self)

    self.RaidTargetIndicator = core:CreateIcon(self, "BACKGROUND", 18, -1, self, "CENTER", "CENTER", -20, 0)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    core:SetFader(self, cfg.pet.fader)
end

function module:OnInit()
    local mediaPath = cfg.mediaPath
    media = {
        portrait_overlay = mediaPath .. "uf_portrait_overlay",

        foreground = mediaPath .. C.general.style .. "\\" .. "uf_pet_foreground",
        foreground_hightthreat = mediaPath .. C.general.style .. "\\" .. "uf_pet_foreground_highthreat",
        foreground_lowthreat = mediaPath .. C.general.style .. "\\" .. "uf_pet_foreground_lowthreat",
        background = mediaPath .. C.general.style .. "\\" .. "uf_pet_background",

        hpTex = mediaPath .. "uf_bartex_normal",
        mpTex = mediaPath .. "uf_bartex_normal",

        incoming_barTex = mediaPath .. "uf_bartex_normal",
    }

    oUF:RegisterStyle("DarkUI:pet", createStyle)
    oUF:SetActiveStyle("DarkUI:pet")
    local frame = oUF:Spawn("pet", "DarkUIPetFrame")
    E:RegisterMover(frame, L.UF_MOVER_PET, "unitframe.pet.position")
end
