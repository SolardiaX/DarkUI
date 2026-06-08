local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- PartyPet Frame of DarkUI
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("PartyPet")

local oUF = select(2, ...).oUF or oUF

local cfg = C.unitframe

local mediaPath = cfg.mediaPath

local media = {
    background             = mediaPath .. C.general.style .. "\\" .. "uf_miniframe",

    hpTex                  = mediaPath .. "uf_bartex_normal",

    incoming_barTex        = mediaPath .. "uf_bartex_normal",
}

local function createTexture(self)
    -- background
    self.FrameBG = CreateFrame('Frame', nil, self)
    self.FrameBG:SetFrameStrata('BACKGROUND')
    self.FrameBG:SetFrameLevel(1)
    self.FrameBG:SetSize(256, 64)
    self.FrameBG:SetPoint("CENTER", self, 0, 0)

    self.FrameBG.texture = self.FrameBG:CreateTexture(nil, 'BACKGROUND')
    self.FrameBG.texture:SetTexture(media.background)
    self.FrameBG.texture:SetAllPoints(self.FrameBG)
    self.FrameBG.texture:SetTexCoord(1, 0, 0, 1)
end

local function createBar(self)
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(4)
    self.Health:SetSize(90, 18)
    self.Health:SetPoint('CENTER', self.FrameBG, 0, 2)
    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetStatusBarColor(0.2, 0.2, 0.2)

    self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
    self.Health.bg:SetTexture(media.hpTex)
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg.multiplier = 0.3

    self.Health.frequentUpdates = true
    self.Health.colorSmooth = true
    self.Health.smoothing = Enum.StatusBarInterpolation.Continuous
    self.Health.colorClass = true
    self.Health.colorClassNPC = true
    self.Health.colorClassPet = true

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

local function createTag(self)
    self.Tags = {}

    self.Tags.smarthp = self:CreateTag(self.Health, "[dd:smarthp]")
                            :SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
                            :SetPoint("CENTER", self.Health, 0, 0)
                            :SetJustifyH('CENTER')
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

    oUF:Factory(function()
        oUF:RegisterStyle("DarkUI:partypet", createStyle)
        oUF:SetActiveStyle("DarkUI:partypet")

        local showPlayer = cfg.party.showPlayer
        local unitsPerColumn = cfg.party.unitsPerColumn
        local xOffset = 50
        local yOffset = 120
        local columnAnchorPoint = 'BOTTOM'

        local partypet = oUF:SpawnHeader(
                "DarkUIPartyPetHeader",
                nil,
                "point", 'LEFT',
                "columnAnchorPoint", columnAnchorPoint,
                "unitsPerColumn", unitsPerColumn,
                "showSolo", cfg.party.showSolo,
                "showPlayer", showPlayer,
                "showParty", true,
                "showRaid", false,
                "maxColumns", 5,
                "columnSpacing", 60,
                "xOffset", xOffset,
                "yOffset", yOffset,
                "oUF-initialConfigFunction", ([[
                    self:SetAttribute("useOwnerUnit", "true")
                    self:SetAttribute("unitsuffix", "pet")
                    self:SetWidth(%d)
                    self:SetHeight(%d)
                    self:SetScale(%f)
                ]]):format(100, 64, cfg.scale)
        )
        partypet:SetVisibility("custom [group:party,nogroup:raid][@player,exists,nogroup:party] show;hide")

        partypet:SetPoint(unpack(cfg.partypet.position))
    end)
end
