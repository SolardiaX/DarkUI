local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable or not C.unitframe.raid.enable then return end

----------------------------------------------------------------------------------------
-- Raid Frame of DarkUI
----------------------------------------------------------------------------------------

local oUF = ns.oUF or oUF

local CreateFrame = CreateFrame
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local UnitIsPlayer = UnitIsPlayer
local UnitIsDeadOrGhost, UnitIsConnected = UnitIsDeadOrGhost, UnitIsConnected
local select, unpack, pairs, tostring = select, unpack, pairs, tostring
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

local cfg = C.unitframe
local DUF = E.unitframe

local mediaPath = cfg.mediaPath

local media = {
    foreground        = mediaPath .. "uf_raid_foreground",

    debuffHighlight   = mediaPath .. "uf_raid_debuffHigtlight",

    hpTex             = mediaPath .. "uf_bartex_raid_main",
    mpTex             = mediaPath .. "uf_bartex_raid_slight",

    barTex_background = mediaPath .. "uf_bartex_raid_slight",

    Incoming_barTex   = mediaPath .. "uf_bartex_raid_main",
}

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = { top = -1, left = -1, bottom = -1, right = -1 },
}

local postUpdateHealth = function(bar, unit, min, max)
    local r, g, b, t

    if (UnitIsPlayer(unit)) then
        t = oUF.colors.class[select(2, UnitClass(unit))]
    else
        r, g, b = .1, .8, .3
    end

    if (t) then
        r, g, b = t[1], t[2], t[3]
    end

    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        bar.bg:SetVertexColor(.6, .6, .6)
        bar:SetStatusBarColor(.6, .6, .6)
    else
        bar.bg:SetVertexColor(r, g, b)

        if (cfg.raid.reverseColors) then
            bar:SetStatusBarColor(r, g, b)
        else
            bar:SetStatusBarColor(0, 0, 0)
        end
    end
end

local createTexture = function(self)
    -- foreground
    self.FrameFG = CreateFrame("Frame", nil, self)
    self.FrameFG:SetFrameStrata("LOW")
    self.FrameFG:SetFrameLevel(5)
    self.FrameFG:SetPoint("TOPLEFT", self, "TOPLEFT", 5, -5)
    self.FrameFG:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -5, 5)

    self.FrameFG.texture = self.FrameFG:CreateTexture(nil, "BACKGROUND")
    self.FrameFG.texture:SetAllPoints(self.FrameFG)
    self.FrameFG.texture:SetTexture(media.foreground)
    self.FrameFG.texture:SetVertexColor(0.47, 0.4, 0.4)

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
    self.Health = CreateFrame("StatusBar", nil, self, "BackdropTemplate")
    self.Health:SetFrameStrata("LOW")
    self.Health:SetFrameLevel(3)
    self.Health:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", 3, -3)
    self.Health:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", -3, 3)

    self.Health:SetStatusBarTexture(media.hpTex)
    self.Health:SetAlpha(1)

    self.Health:SetBackdrop(backdrop)
    self.Health:SetBackdropColor(0, 0, 0, .85)

    self.Health.bg = self.Health:CreateTexture(nil, 'BORDER')
    self.Health.bg:SetTexture(media.barTex_background)
    self.Health.bg:SetAllPoints(self.Health)
    self.Health.bg:SetAlpha(0.3)

    self.Health.frequentUpdates = true
    self.Health.Smooth = true
    self.Health.colorSmooth = true
    self.Health.colorClass = cfg.raid.colorHealth
    --self.Health.PostUpdate = postUpdateHealth

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.Power:SetHeight(4)
    self.Power:SetPoint("LEFT", self.Health, 6, 0)
    self.Power:SetPoint("RIGHT", self.Health, -6, 0)
    self.Power:SetPoint("BOTTOM", self.Health, 0, 6)

    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.Smooth = true

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .3
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(media.mpTex)

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

local createTag = function(self)
    self.Tags = {}

    self.Tags.name = self:CreateTag(self.Health, '[dd:raidname]')
                         :SetFont(STANDARD_TEXT_FONT, 10, 'THICKOUTLINE')
                         :SetPoint("CENTER", 0, 4)
                         :SetJustifyH("CENTER")
                         :SetShadowColor(0, 0, 0, 0)
                         :done()

    self.Tags.hpval = self:CreateTag(self.Health, '[dd:misshp]')
                          :SetFont(STANDARD_TEXT_FONT, 9, 'OUTLINE')
                          :SetPoint("BOTTOM", 0, 12)
                          :SetJustifyH("CENTER")
                          :SetShadowOffset(1.25, -1.25)
                          :done()
end

local createRaidDebuffs = function(self)
    if not cfg.raid.raidDebuffs.enable then return end

    local frame = CreateFrame("Frame", nil, self)
    frame:SetSize(18, 18)
    frame:SetPoint("RIGHT", -20, 0)
    frame:SetFrameLevel(self:GetFrameLevel() + 3)
    frame:CreateShadow()

    frame.icon = frame:CreateTexture(nil, "ARTWORK")
    frame.icon:SetAllPoints()
    frame.icon:SetTexCoord(unpack(C.media.texCoord))
    frame.count = frame:CreateFontText(12, "", false, "BOTTOMRIGHT", 6, -3)
    frame.time = frame:CreateFontText(12, "", false, "CENTER", 1, 0)

    frame.ShowDispellableDebuff = true
    frame.EnableTooltip = cfg.raid.raidDebuffs.enableTooltip
    frame.ShowDebuffBorder = cfg.raid.raidDebuffs.showDebuffBorder
    frame.FilterDispellableDebuff = cfg.raid.raidDebuffs.filterDispellableDebuff
    frame.Debuffs = C.aura.raidDebuffs

    self.RaidDebuffs = frame
end

local createStyle = function(self)
    self.colors = C.oUF_colors
    self.cUnit = "raid"

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createTag(self)
    createRaidDebuffs(self)

    self.RaidTargetIndicator = DUF.CreateIcon(self.FrameFG, "HIGH", 18, 1, self, "CENTER", "CENTER", 0, -2)
    self.ReadyCheckIndicator = DUF.CreateIcon(self, "OVERLAY", 14, -1, self, "TOPRIGHT", "TOPRIGHT", -10, -8)
    self.LeaderIndicator = DUF.CreateIcon(self, "OVERLAY", 14, -1, self, "TOPLEFT", "TOPLEFT", 12, -8)
    self.AssistantIndicator = DUF.CreateIcon(self, "OVERLAY", 14, -1, self, "TOPLEFT", "TOPLEFT", 12, -8)
    self.GroupRoleIndicator = DUF.CreateIcon(self.FrameFG, "OVERLAY", 18, -1, self, "TOP", "TOP", 0, -2)
    self.GroupRoleIndicator:SetDesaturated(1)

    DUF.SetFader(self, cfg.raid.fader)
end

---------------------------------------------
-- SPAWN RAID UNIT
---------------------------------------------
oUF:RegisterStyle("DarkUI:raid", createStyle)
oUF:SetActiveStyle("DarkUI:raid")

local groups, group = {}, nil

for i = 1, NUM_RAID_GROUPS do
    local name = "DarkUIRaidGroup" .. i

    group = oUF:SpawnHeader(
            name,
            nil,
            "custom [group:raid] show; hide",
            "showPlayer", true,
            "showSolo", cfg.raid.showSolo,
            "showParty", false,
            "showRaid", true,
            "point", "LEFT",
            "yOffset", 0,
            "xoffset", -10,
            "groupFilter", tostring(i),
            "maxColumns", 5,
            "unitsPerColumn", 5,
            --"columnSpacing", 0,
            "columnAnchorPoint", "TOPLEFT",
            "oUF-initialConfigFunction", ([[
                self:SetWidth(%d)
                self:SetHeight(%d)
            ]]):format(cfg.raid.size, cfg.raid.size)
    )

    group:SetScale(cfg.scale)
    groups[i] = group

    if i == 1 then
        group:SetPoint(unpack(cfg.raid.position))
    else
        group:SetPoint("TOPLEFT", groups[i - 1], "BOTTOMLEFT", 0, 6)
    end
end

-- for _, g in pairs(groups) do
--     if g then
--         g:SetScale(cfg.scale)
--     end
-- end
