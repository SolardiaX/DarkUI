local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable or not C.unitframe.raid.enable then return end

----------------------------------------------------------------------------------------
-- Raid Frame of DarkUI
----------------------------------------------------------------------------------------
local core = E:Module("UFCore")

local oUF = ns.oUF or oUF

local CreateFrame = CreateFrame
local UnitFrame_OnEnter, UnitFrame_OnLeave = UnitFrame_OnEnter, UnitFrame_OnLeave
local UnitIsPlayer = UnitIsPlayer
local UnitIsDeadOrGhost, UnitIsConnected = UnitIsDeadOrGhost, UnitIsConnected
local select, unpack, pairs, tostring = select, unpack, pairs, tostring
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT

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
    self.DebuffHighlight:SetPoint("TOPLEFT", self.FrameFG, "TOPLEFT", -5, 5)
    self.DebuffHighlight:SetPoint("BOTTOMRIGHT", self.FrameFG, "BOTTOMRIGHT", 5, -5)

    self.DebuffHighlightAlpha = 0.9
    self.DebuffHighlightFilter = false
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

    self.RaidTargetIndicator = core:CreateIcon(self.FrameFG, "ARTWORK", 18, 1, self, "CENTER", "CENTER", 0, 6)
    self.ReadyCheckIndicator = core:CreateIcon(self, "OVERLAY", 14, -1, self, "TOPRIGHT", "TOPRIGHT", -10, -12)
    self.LeaderIndicator = core:CreateIcon(self, "OVERLAY", 14, -1, self, "TOPLEFT", "TOPLEFT", 12, -12)
    self.AssistantIndicator = core:CreateIcon(self, "OVERLAY", 14, -1, self, "TOPLEFT", "TOPLEFT", 12, -12)
    self.GroupRoleIndicator = core:CreateIcon(self.FrameFG, "OVERLAY", 18, -1, self, "TOP", "TOP", 0, -2)
    self.GroupRoleIndicator:SetDesaturated(1)

    core:SetFader(self, cfg.raid.fader)
end

---------------------------------------------
-- SPAWN RAID UNIT
---------------------------------------------
oUF:Factory(function()
    if cfg.party.raidMode then
        oUF:RegisterStyle("DarkUI:party", createStyle)
        oUF:SetActiveStyle("DarkUI:party")
        
        local party = oUF:SpawnHeader(
                "DarkUIPartyHeader",
                nil,
                "custom [group:raid][@player,exists,nogroup:party] show;hide",
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
        ):SetPoint(unpack(cfg.raid.position))

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
                    "custom [group:raid] show; hide",
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

            group:SetScale(cfg.scale)
            groups[i] = group

            if i == 1 then
                group:SetPoint(unpack(cfg.raid.position))
            else
                group:SetPoint("TOPLEFT", groups[i - 1], "BOTTOMLEFT", 0, 6)
            end
        end

        -- Hide Default Frames
        if CompactRaidFrameManager_SetSetting then
            CompactRaidFrameManager_SetSetting("IsShown", "0")
            UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
            CompactRaidFrameManager:UnregisterAllEvents()
            CompactRaidFrameManager:SetParent(E.FrameHider)
        end

        if _G.CompactRaidFrameContainer then
            _G.CompactRaidFrameContainer:UnregisterAllEvents()
        end

        if CompactRaidFrameManager_SetSetting then
            CompactRaidFrameManager_SetSetting('IsShown', '0')
        end

        if _G.CompactRaidFrameManager then
            _G.CompactRaidFrameManager:UnregisterAllEvents()
            _G.CompactRaidFrameManager:SetParent(E.FrameHider)
        end
    end
end)