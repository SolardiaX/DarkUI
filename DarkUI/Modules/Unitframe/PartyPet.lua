local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- PartyPet Frame of DarkUI
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("PartyPet")

local oUF = select(2, ...).oUF or oUF

local cfg = C.unitframe

local media

local function createTexture(self)
    -- background
    self.FrameBG = CreateFrame("Frame", nil, self)
    self.FrameBG:SetFrameStrata("BACKGROUND")
    self.FrameBG:SetFrameLevel(1)
    self.FrameBG:SetSize(256, 64)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, "BACKGROUND")
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)
    self.FrameBG.texture:SetTexCoord(1, 0, 0, 1)
end

local function createBar(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(90, 18)
    self.Health:SetPoint("CENTER", self.FrameBG, 0, 2)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.bg = self.Health:CreateTexture(nil, "BORDER")
    self.Health.bg:SetTexture(media.hpTex)
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg.multiplier = 0.3

    self.Health.colorSmooth = true
    self.Health.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Health.colorClass = true
    self.Health.colorClassNPC = true
    self.Health.colorClassPet = true

    --Incoming heal
    local healingAll = CreateFrame("StatusBar", nil, self.Health)
    healingAll:SetPoint("TOP")
    healingAll:SetPoint("BOTTOM")
    healingAll:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
    healingAll:SetWidth(90)
    healingAll:SetStatusBarTexture(media.incoming_barTex)
    healingAll:SetStatusBarColor(0, 1, 0.5, 0.2)

    local damageAbsorb = CreateFrame("StatusBar", nil, self.Health)
    damageAbsorb:SetPoint("TOP")
    damageAbsorb:SetPoint("BOTTOM")
    damageAbsorb:SetPoint("LEFT", healingAll:GetStatusBarTexture(), "RIGHT")
    damageAbsorb:SetWidth(90)
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
    healAbsorb:SetWidth(90)
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

local function createTag(self)
    self.Tags = {}

    self.Tags.smarthp = self:CreateTag(self.Health, "[dd:smarthp]")
        :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
        :SetPoint("CENTER", self.Health, 0, 0)
        :SetJustifyH("CENTER")
        :done()
end

local function createStyle(self)
    self.colors = C.oUF_colors
    self.cUnit = "partypet"

    --self:SetSize(85, 85)

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createTag(self)

    self.RaidTargetIndicator = core:CreateIcon(self, "ARTWORK", 18, 1, self, "CENTER", "BOTTOM", 0, -18)
    self.RaidTargetIndicator:SetTexCoord(0, 0.5, 0, 0.421875)

    core:SetFader(self, cfg.party.fader)
end

function module:OnInit()
    if not C.unitframe.partypet.enable then return end

    local mediaPath = cfg.mediaPath
    media = {
        background = mediaPath .. C.general.style .. "\\" .. "uf_miniframe",

        hpTex = mediaPath .. "uf_bartex_normal",

        incoming_barTex = mediaPath .. "uf_bartex_normal",
    }

    oUF:Factory(function()
        oUF:RegisterStyle("DarkUI:partypet", createStyle)
        oUF:SetActiveStyle("DarkUI:partypet")

        local showPlayer = cfg.party.showPlayer
        local unitsPerColumn = cfg.party.unitsPerColumn
        local xOffset = 50
        local yOffset = 120
        local columnAnchorPoint = "BOTTOM"

        local partypet = oUF:SpawnHeader(
            "DarkUIPartyPetHeader",
            nil,
            "point",
            "LEFT",
            "columnAnchorPoint",
            columnAnchorPoint,
            "unitsPerColumn",
            unitsPerColumn,
            "showSolo",
            cfg.party.showSolo,
            "showPlayer",
            showPlayer,
            "showParty",
            true,
            "showRaid",
            false,
            "maxColumns",
            5,
            "columnSpacing",
            60,
            "xOffset",
            xOffset,
            "yOffset",
            yOffset,
            "oUF-initialConfigFunction",
            ([[
                    self:SetAttribute("useOwnerUnit", "true")
                    self:SetAttribute("unitsuffix", "pet")
                    self:SetWidth(%d)
                    self:SetHeight(%d)
                    self:SetScale(%f)
                ]]):format(100, 64, cfg.scale)
        )
        partypet:SetVisibility("custom [group:party,nogroup:raid][@player,exists,nogroup:party] show;hide")

        partypet:SetPoint(unpack(cfg.partypet.position))
        E:RegisterMover(partypet, L.UF_MOVER_PARTYPET, "unitframe.partypet.position", 200, 70)
    end)
end
