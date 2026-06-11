local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Raid Frame of DarkUI
------------------------------------------------------------------------
local core = E:Module("Unitframe")
local module = core:Sub("Raid")

local oUF = select(2, ...).oUF or oUF

local cfg = C.unitframe

local mediaPath = cfg.mediaPath

local media = {
    foreground        = mediaPath .. "uf_raid_foreground",

    debuffHighlight   = mediaPath .. "uf_raid_debuffHigtlight",

    hpTex             = mediaPath .. "uf_bartex_raid_main",
    mpTex             = mediaPath .. "uf_bartex_raid_slight",

    barTex_background = mediaPath .. "uf_bartex_raid_slight",

    incoming_barTex   = mediaPath .. "uf_bartex_raid_main",
}

local backdrop = {
    bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
    insets = { top = -1, left = -1, bottom = -1, right = -1 },
}

local function postUpdateHealth(bar, unit, min, max)
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

local function createTexture(self)
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
    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)

    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false
end

local function createBar(self)
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
    self.Health.smoothing = Enum.StatusBarInterpolation.ExponentialEaseOut
    self.Health.colorSmooth = true
    self.Health.colorClass = cfg.raid.colorHealth

    --power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetFrameStrata("LOW")
    self.Power:SetFrameLevel(4)
    self.Power:SetHeight(4)
    self.Power:SetPoint("LEFT", self.Health, 6, 0)
    self.Power:SetPoint("RIGHT", self.Health, -6, 0)
    self.Power:SetPoint("BOTTOM", self.Health, 0, 6)
    self.Power:SetStatusBarTexture(media.mpTex)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg.multiplier = .3
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
    healingAll:SetWidth(self.Health:GetWidth() or 40)
    healingAll:SetStatusBarTexture(media.incoming_barTex)
    healingAll:SetStatusBarColor(0, 1, 0.5, 0.2)

    local damageAbsorb = CreateFrame("StatusBar", nil, self.Health)
    damageAbsorb:SetPoint("TOP")
    damageAbsorb:SetPoint("BOTTOM")
    damageAbsorb:SetPoint("LEFT", healingAll:GetStatusBarTexture(), "RIGHT")
    damageAbsorb:SetWidth(self.Health:GetWidth() or 40)
    damageAbsorb:SetStatusBarTexture(media.incoming_barTex)
    damageAbsorb:SetStatusBarColor(1, 1, 0, 0.2)

    local overDamageAbsorbIndicator = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    overDamageAbsorbIndicator:SetWidth(15)
    overDamageAbsorbIndicator:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
    overDamageAbsorbIndicator:SetBlendMode("ADD")
    overDamageAbsorbIndicator:SetAlpha(.7)
    overDamageAbsorbIndicator:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -7, 2)
    overDamageAbsorbIndicator:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -7, -2)

    local healAbsorb = CreateFrame("StatusBar", nil, self.Health)
    healAbsorb:SetPoint("TOP")
    healAbsorb:SetPoint("BOTTOM")
    healAbsorb:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
    healAbsorb:SetWidth(self.Health:GetWidth() or 40)
    healAbsorb:SetReverseFill(true)
    healAbsorb:SetStatusBarTexture(media.incoming_barTex)
    healAbsorb:SetStatusBarColor(0, .5, .8, .5)
    healAbsorb:SetFrameLevel(self.Health:GetFrameLevel())

    local overHealAbsorbIndicator = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
    overHealAbsorbIndicator:SetWidth(15)
    overHealAbsorbIndicator:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
    overHealAbsorbIndicator:SetBlendMode("ADD")
    overHealAbsorbIndicator:SetAlpha(.5)
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

local function createRaidDebuffs(self)
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
    frame.ShowBossDebuff = true
    frame.BossDebuffPriority = 9999999
    frame.EnableTooltip = cfg.raid.raidDebuffs.enableTooltip
    frame.ShowDebuffBorder = cfg.raid.raidDebuffs.showDebuffBorder
    frame.FilterDispellableDebuff = cfg.raid.raidDebuffs.filterDispellableDebuff
    frame.Debuffs = C.aura.raidDebuffs

    self.RaidDebuffs = frame
end

local function createStyle(self)
    self.colors = C.oUF_colors
    self.cUnit = "raid"

    self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    createTexture(self)
    createBar(self)
    createTag(self)
    createRaidDebuffs(self)

    self.RaidTargetIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 18, 1, self, "CENTER", "CENTER", 0, 6)
    self.ReadyCheckIndicator = core:CreateIcon(self, "OVERLAY", 14, -1, self, "TOPRIGHT", "TOPRIGHT", -10, -12)
    self.LeaderIndicator = core:CreateIcon(self, "OVERLAY", 14, -1, self, "TOPLEFT", "TOPLEFT", 12, -12)
    self.AssistantIndicator = core:CreateIcon(self, "OVERLAY", 14, -1, self, "TOPLEFT", "TOPLEFT", 12, -12)
    self.GroupRoleIndicator = core:CreateIcon(self.FrameFG, "OVERLAY", 18, -1, self, "TOP", "TOP", 0, -2)
    self.GroupRoleIndicator:SetDesaturated(1)

    self.ResurrectIndicator = core:CreateIcon(self, "OVERLAY", 16, -1, self, "CENTER", "CENTER", 0, 0)
    self.SummonIndicator = core:CreateIcon(self, "OVERLAY", 20, -1, self, "CENTER", "CENTER", 0, 0)

    -- TargetBorder + ThreatBorder (via FrameFG vertex color)
    local defaultFGColor = { 0.47, 0.4, 0.4 }
    local targetColor = { 0.8, 0.7, 0.3 }
    local threatColors = {
        [1] = { 0.7, 0.7, 0.3 },
        [2] = { 0.7, 0.4, 0 },
        [3] = { 0.7, 0.1, 0.1 },
    }

    local function updateBorderColor(frame)
        if UnitIsUnit("target", frame.unit) then
            frame.FrameFG.texture:SetVertexColor(unpack(targetColor))
            return
        end

        local status = UnitThreatSituation(frame.unit)
        if status and status > 0 and threatColors[status] then
            frame.FrameFG.texture:SetVertexColor(unpack(threatColors[status]))
        else
            frame.FrameFG.texture:SetVertexColor(unpack(defaultFGColor))
        end
    end

    self:RegisterEvent("PLAYER_TARGET_CHANGED", updateBorderColor, true)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", updateBorderColor, true)
    self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", function(frame, _, unit)
        if unit == frame.unit then updateBorderColor(frame) end
    end)
    self:RegisterEvent("UNIT_THREAT_LIST_UPDATE", function(frame, _, unit)
        if unit == frame.unit then updateBorderColor(frame) end
    end)
    tinsert(self.__elements, updateBorderColor)

    -- PrivateAuras
    local pa = CreateFrame("Frame", nil, self)
    pa:SetPoint("CENTER", self.Health, 0, 0)
    pa:SetSize(20, 20)
    pa.size = 20
    pa.spacing = 0
    pa.initialAnchor = "CENTER"
    pa.growthX = "RIGHT"
    pa.growthY = "UP"
    pa.num = 1
    pa.borderScale = 0
    pa.disableCooldown = false
    pa.disableCooldownText = true
    self.PrivateAuras = pa

    core:SetFader(self, cfg.raid.fader)
end

function module:OnInit()
    if not C.unitframe.raid.enable then return end

    oUF:Factory(function()
        if cfg.party.enable and not cfg.party.standalone then
            oUF:RegisterStyle("DarkUI:party", createStyle)
            oUF:SetActiveStyle("DarkUI:party")

            local party = oUF:SpawnHeader(
                    "DarkUIPartyHeader",
                    nil,
                    "showSolo", cfg.party.showSolo,
                    "showPlayer", cfg.party.showPlayer,
                    "showParty", true,
                    "showRaid", false,
                    "point", 'LEFT',
                    "xOffset", -6,
                    "yOffset", -10,
                    "columnAnchorPoint", "TOPLEFT",
                    "unitsPerColumn", cfg.party.unitsPerColumn,
                    "maxColumns", 5,
                    -- "columnSpacing", 60,
                    "oUF-initialConfigFunction", ([[
                        self:SetWidth(%d)
                        self:SetHeight(%d)
                        self:SetScale(%f)
                    ]]):format(cfg.raid.size, cfg.raid.size, cfg.scale)
            )
            party:SetVisibility("custom [group:raid][@player,exists,nogroup:party] show;hide")
            party:SetPoint(unpack(cfg.raid.position))

            if CompactPartyFrame then
                CompactPartyFrame:UnregisterAllEvents()
            end
        else
            oUF:RegisterStyle("DarkUI:raid", createStyle)
            oUF:SetActiveStyle("DarkUI:raid")

            local groups, group = {}, nil

            for i = 1, NUM_RAID_GROUPS do
                local name = "DarkUIRaidGroup" .. i

                group = oUF:SpawnHeader(
                        name,
                        nil,
                        "showPlayer", true,
                        "showSolo", cfg.raid.showSolo,
                        "showParty", cfg.party.raidMode,
                        "showRaid", true,
                        "point", "LEFT",
                        "yOffset", -6,
                        "xoffset", -10,
                        "groupFilter", tostring(i),
                        'groupBy', 'GROUP',
                        "groupingOrder", "TANK,HEALER,DAMAGER,NONE",
                        -- "maxColumns", 5,
                        "unitsPerColumn", 5,
                        --"columnSpacing", 0,
                        "columnAnchorPoint", "TOPLEFT",
                        "oUF-initialConfigFunction", ([[
                            self:SetWidth(%d)
                            self:SetHeight(%d)
                        ]]):format(cfg.raid.size, cfg.raid.size)
                )
                group:SetVisibility("custom [group:raid] show; hide")

                group:SetScale(cfg.scale)
                groups[i] = group

                if i == 1 then
                    group:SetPoint(unpack(cfg.raid.position))
                else
                    group:SetPoint("TOPLEFT", groups[i - 1], "BOTTOMLEFT", 0, 6)
                end
            end

            -- Hide Default Frames
            if CompactPartyFrame then
                CompactPartyFrame:UnregisterAllEvents()
            end
            if CompactRaidFrameManager_SetSetting then
                CompactRaidFrameManager_SetSetting("IsShown", "0")
                UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
                CompactRaidFrameManager:UnregisterAllEvents()
                CompactRaidFrameManager:SetParent(E.FrameHider)
            end
            if _G.CompactRaidFrameContainer then
                _G.CompactRaidFrameContainer:UnregisterAllEvents()
            end
        end
    end)
end