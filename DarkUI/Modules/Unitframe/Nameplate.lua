local _, ns = ...
local E, C, L = ns:unpack()

if not C.nameplate.enable then return end

----------------------------------------------------------------------------------------
--    oUF nameplates
----------------------------------------------------------------------------------------
local module = E:Module("Nameplate")
local core = E:Module("UFCore")

local LBG = LibStub("LibButtonGlow-1.0", true)

local oUF = ns.oUF

local _G = _G
local CreateFrame = CreateFrame
local SetCVar = SetCVar
local GetSpellCooldown = GetSpellCooldown
local InCombatLockdown = InCombatLockdown
local GetSpecializationInfoByID, GetSpecialization = GetSpecializationInfoByID, GetSpecialization
local GetNumBattlefieldScores, GetBattlefieldScore = GetNumBattlefieldScores, GetBattlefieldScore
local UnitFactionGroup, UnitAffectingCombat, UnitThreatSituation = UnitFactionGroup, UnitAffectingCombat, UnitThreatSituation
local UnitIsTapDenied = UnitIsTapDenied
local GetArenaOpponentSpec = GetArenaOpponentSpec
local UnitName, UnitIsUnit, UnitReaction, UnitIsPlayer, UnitClass = UnitName, UnitIsUnit, UnitReaction, UnitIsPlayer, UnitClass
local UnitExists = UnitExists
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSelectionColor = UnitSelectionColor
local UnitGUID = UnitGUID
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitWidgetSet = UnitWidgetSet
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local IsInInstance, IsInGroup, IsInRaid = IsInInstance, IsInGroup, IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local GetSpellInfo = C_Spell.GetSpellInfo
local hooksecurefunc = hooksecurefunc
local unpack = unpack

local cfg = C.nameplate

local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"
local arrow = C.media.path .. "uf_nameplate_arrow"

local totemData = {
    [GetSpellInfo(192058)] = 136013,    -- Capacitor Totem
    [GetSpellInfo(98008)]  = 237586,    -- Spirit Link Totem
    [GetSpellInfo(192077)] = 538576,    -- Wind Rush Totem
    [GetSpellInfo(204331)] = 511726,    -- Counterstrike Totem
    [GetSpellInfo(204332)] = 136114,    -- Windfury Totem
    [GetSpellInfo(204336)] = 136039,    -- Grounding Totem
    [GetSpellInfo(157153)] = 971076,    -- Cloudburst Totem
    [GetSpellInfo(5394)]   = 135127,    -- Healing Stream Totem
    [GetSpellInfo(108280)] = 538569,    -- Healing Tide Totem
    [GetSpellInfo(207399)] = 136080,    -- Ancestral Protection Totem
    [GetSpellInfo(198838)] = 136098,    -- Earthen Wall Totem
    [GetSpellInfo(51485)]  = 136100,    -- Earthgrab Totem
    [GetSpellInfo(196932)] = 136232,    -- Voodoo Totem
    [GetSpellInfo(192222)] = 971079,    -- Liquid Magma Totem
    [GetSpellInfo(204330)] = 135829,    -- Skyfury Totem
}

local kickID = 0

local healList, exClass, healerSpecs = {}, {}, {}
local testing = false

exClass.DEATHKNIGHT = true
exClass.DEMONHUNTER = true
exClass.HUNTER = true
exClass.MAGE = true
exClass.ROGUE = true
exClass.WARLOCK = true
exClass.WARRIOR = true

local healerFactions = {
    ["Horde"] = 1,
    ["Alliance"] = 0,
}

local healerSpecIDs = {
    105,    -- Druid Restoration
    1468,   -- Evoker Preservation
    270,    -- Monk Mistweaver
    65,        -- Paladin Holy
    256,    -- Priest Discipline
    257,    -- Priest Holy
    264,    -- Shaman Restoration
}

local lastCheck = 20
local function checkBattleFieldHealers(_, elapsed)
    lastCheck = lastCheck + elapsed
    if lastCheck > 25 then
        lastCheck = 0
        healList = {}
        for i = 1, GetNumBattlefieldScores() do
            local name, _, _, _, _, faction, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)

            if name and healerSpecs[talentSpec] and healerFactions[UnitFactionGroup("player")] == faction then
                name = name:match("(.+)%-.+") or name
                healList[name] = talentSpec
            end
        end
    end
end

local function checkArenaHealers(_, elapsed)
    lastCheck = lastCheck + elapsed
    if lastCheck > 10 then
        lastCheck = 0
        healList = {}
        for i = 1, 5 do
            local specID = GetArenaOpponentSpec(i)
            if specID and specID > 0 then
                local name = UnitName(format("arena%d", i))
                local _, talentSpec = GetSpecializationInfoByID(specID)
                if name and healerSpecs[talentSpec] then
                    healList[name] = talentSpec
                    local nameplate = C_NamePlate.GetNamePlateForUnit(format("arena%d", i))
                    if nameplate then
                        nameplate.unitFrame:UpdateAllElements("UNIT_NAME_UPDATE")
                    end
                end
            end
        end
    end
end

local function checkHealers(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        local _, instanceType = IsInInstance()
        if instanceType == "pvp" then
            t:SetScript("OnUpdate", checkBattleFieldHealers)
        elseif instanceType == "arena" then
            t:SetScript("OnUpdate", checkArenaHealers)
        else
            healList = {}
            t:SetScript("OnUpdate", nil)
        end
    end
end

local function createBorderFrame(frame, point)
    if point == nil then point = frame end
    if point.backdrop then return end

    frame.backdrop = frame:CreateTexture(nil, "BORDER")
    frame.backdrop:SetDrawLayer("BORDER", -8)
    frame.backdrop:SetPoint("TOPLEFT", point, "TOPLEFT", -E.noscalemult * 2, E.noscalemult * 2)
    frame.backdrop:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", E.noscalemult * 2, -E.noscalemult * 2)
    frame.backdrop:SetColorTexture(unpack(C.media.backdrop_color))

    frame.bordertop = frame:CreateTexture(nil, "BORDER")
    frame.bordertop:SetPoint("TOPLEFT", point, "TOPLEFT", -E.noscalemult * 2, E.noscalemult * 2)
    frame.bordertop:SetPoint("TOPRIGHT", point, "TOPRIGHT", E.noscalemult * 2, E.noscalemult * 2)
    frame.bordertop:SetHeight(E.noscalemult)
    frame.bordertop:SetColorTexture(unpack(C.media.border_color))
    frame.bordertop:SetDrawLayer("BORDER", -7)

    frame.borderbottom = frame:CreateTexture(nil, "BORDER")
    frame.borderbottom:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", -E.noscalemult * 2, -E.noscalemult * 2)
    frame.borderbottom:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", E.noscalemult * 2, -E.noscalemult * 2)
    frame.borderbottom:SetHeight(E.noscalemult)
    frame.borderbottom:SetColorTexture(unpack(C.media.border_color))
    frame.borderbottom:SetDrawLayer("BORDER", -7)

    frame.borderleft = frame:CreateTexture(nil, "BORDER")
    frame.borderleft:SetPoint("TOPLEFT", point, "TOPLEFT", -E.noscalemult * 2, E.noscalemult * 2)
    frame.borderleft:SetPoint("BOTTOMLEFT", point, "BOTTOMLEFT", E.noscalemult * 2, -E.noscalemult * 2)
    frame.borderleft:SetWidth(E.noscalemult)
    frame.borderleft:SetColorTexture(unpack(C.media.border_color))
    frame.borderleft:SetDrawLayer("BORDER", -7)

    frame.borderright = frame:CreateTexture(nil, "BORDER")
    frame.borderright:SetPoint("TOPRIGHT", point, "TOPRIGHT", E.noscalemult * 2, E.noscalemult * 2)
    frame.borderright:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", -E.noscalemult * 2, -E.noscalemult * 2)
    frame.borderright:SetWidth(E.noscalemult)
    frame.borderright:SetColorTexture(unpack(C.media.border_color))
    frame.borderright:SetDrawLayer("BORDER", -7)
end

local function setColorBorder(frame, r, g, b)
    frame.bordertop:SetColorTexture(r, g, b)
    frame.borderbottom:SetColorTexture(r, g, b)
    frame.borderleft:SetColorTexture(r, g, b)
    frame.borderright:SetColorTexture(r, g, b)
end

local function updateTarget(self)
    local isTarget = UnitIsUnit(self.unit, "target")
    local isMe = UnitIsUnit(self.unit, "player")

    if isTarget and not isMe then
        self:SetSize((cfg.width + cfg.ad_width) * E.noscalemult, (cfg.height + cfg.ad_height) * E.noscalemult)
        self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8 - ((cfg.height + cfg.ad_height) * E.noscalemult))
        self.Castbar.Icon:SetSize(((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8, ((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8)
        if cfg.class_icons == true then
            self.Class.Icon:SetSize(((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8, ((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8)
        end

        self:SetAlpha(1)
        if self.arrow then self.arrow:Show() end
    else
        self:SetSize(cfg.width * E.noscalemult, cfg.height * E.noscalemult)
        self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8 - (cfg.height * E.noscalemult))
        self.Castbar.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        if cfg.class_icons == true then
            self.Class.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        end
        if UnitExists("target") and not isMe then
            self:SetAlpha(0.5)
        else
            self:SetAlpha(1)
        end

        if self.arrow then self.arrow:Hide() end
    end

    self.Health.border:SetSize(256 * self.Health:GetWidth() / 198, 64 * self.Health:GetHeight() / 12)
end

local function updateName(self)
    if cfg.healer_icon == true then
        local name = self.unitName
        if name then
            if healList[name] then
                if exClass[healList[name]] then
                    self.HealerIcon:Hide()
                else
                    self.HealerIcon:Show()
                end
            else
                self.HealerIcon:Hide()
            end
        end
    end

    if cfg.class_icons == true then
        local reaction = UnitReaction(self.unit, "player")
        if UnitIsPlayer(self.unit) and (reaction and reaction <= 4) then
            local _, class = UnitClass(self.unit)
            local texcoord = CLASS_ICON_TCOORDS[class]
            self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
            self.Class:Show()
            self.Level:SetPoint("RIGHT", self.Name, "LEFT", -12, 0)
        else
            self.Class.Icon:SetTexCoord(0, 0, 0, 0)
            self.Class:Hide()
            self.Level:SetPoint("RIGHT", self.Health, "LEFT", -12, 0)
        end
    end

    if cfg.totem_icons == true then
        local name = self.unitName
        if name then
            if totemData[name] then
                self.Totem.Icon:SetTexture(totemData[name])
                self.Totem:Show()
            else
                self.Totem:Hide()
            end
        end
    end
end

-- Cast color
local function castColor(self)
    if cfg.majorSpells[self.spellID] then
        LBG.ShowOverlayGlow(self.Icon.glowFrame)
    else
        LBG.HideOverlayGlow(self.Icon.glowFrame)
    end

    if self.notInterruptible then
        self:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        self.bg:SetColorTexture(0.5, 0.5, 0.5, 0.2)
    elseif cfg.kick_color then
        local start = GetSpellCooldown(kickID)
        if start ~= 0 then
            self:SetStatusBarColor(1, 0.5, 0)
            self.bg:SetColorTexture(1, 0.5, 0, 0.2)
        else
            self:SetStatusBarColor(1, 0.8, 0)
            self.bg:SetColorTexture(1, 0.8, 0, 0.2)
        end
    else
        self:SetStatusBarColor(27 / 255, 147 / 255, 226 / 255)
        self.bg:SetColorTexture(27 / 255, 147 / 255, 226 / 255, 0.2)
    end
end

-- Threat color
local function threatColor(self, forced)
    if UnitIsPlayer(self.unit) then return end
    local combat = UnitAffectingCombat("player")
    local threatStatus = UnitThreatSituation("player", self.unit)

    if cfg.enhance_threat ~= true then
        setColorBorder(self.Health, unpack(C.media.border_color))
    end

    if UnitIsTapDenied(self.unit) then
        self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
    elseif combat then
        if threatStatus == 3 then
            -- securely tanking, highest threat
            if E.myRole == "Tank" then
                if cfg.enhance_threat == true then
                    self.Health:SetStatusBarColor(unpack(cfg.good_color))
                else
                    setColorBorder(self.Health, unpack(cfg.bad_color))
                end
            else
                if cfg.enhance_threat == true then
                    self.Health:SetStatusBarColor(unpack(cfg.bad_color))
                else
                    setColorBorder(self.Health, unpack(cfg.bad_color))
                end
            end
        elseif threatStatus == 2 then
            -- insecurely tanking, another unit have higher threat but not tanking
            if cfg.enhance_threat == true then
                self.Health:SetStatusBarColor(unpack(cfg.near_color))
            else
                setColorBorder(self.Health, unpack(cfg.near_color))
            end
        elseif threatStatus == 1 then
            -- not tanking, higher threat than tank
            if cfg.enhance_threat == true then
                self.Health:SetStatusBarColor(unpack(cfg.near_color))
            else
                setColorBorder(self.Health, unpack(cfg.near_color))
            end
        elseif threatStatus == 0 then
            -- not tanking, lower threat than tank
            if cfg.enhance_threat == true then
                if E.myRole == "Tank" then
                    self.Health:SetStatusBarColor(unpack(cfg.bad_color))
                    if IsInGroup() or IsInRaid() then
                        for i = 1, GetNumGroupMembers() do
                            if UnitExists("raid" .. i) and not UnitIsUnit("raid" .. i, "player") then
                                local isTanking = UnitDetailedThreatSituation("raid" .. i, self.unit)
                                if isTanking and UnitGroupRolesAssigned("raid" .. i) == "TANK" then
                                    self.Health:SetStatusBarColor(unpack(cfg.offtank_color))
                                end
                            end
                        end
                    end
                else
                    self.Health:SetStatusBarColor(unpack(cfg.good_color))
                end
            end
        end
    elseif not forced then
        self.Health:ForceUpdate()
    end
end

--Healthbar color
local function healthPostUpdate(self, unit, min, max)
    local main = self:GetParent()

    local perc = 0
    if max and max > 0 then
        perc = min / max
    end

    local r, g, b
    local mu = self.bg.multiplier
    local unitReaction = UnitReaction(unit, "player")
    if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (unitReaction and unitReaction >= 5) then
        r, g, b = unpack(C.oUF_colors.power["MANA"])
        self:SetStatusBarColor(r, g, b)
        self.bg:SetVertexColor(r * mu, g * mu, b * mu)
    elseif not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) then
        local reaction = C.oUF_colors.reaction[unitReaction]
        if reaction then
            r, g, b = reaction[1], reaction[2], reaction[3]
        else
            r, g, b = UnitSelectionColor(unit, true)
        end

        self:SetStatusBarColor(r, g, b)
    end

    if cfg.customUnits[main.unitName] or cfg.customUnits[main.npcID] then
        self:SetStatusBarColor(unpack(cfg.custom_color))
    end

    if UnitIsPlayer(unit) then
        if perc <= 0.5 and perc >= 0.2 then
            setColorBorder(self, 1, 1, 0)
        elseif perc < 0.2 then
            setColorBorder(self, 1, 0, 0)
        else
            setColorBorder(self, unpack(C.media.border_color))
        end
    elseif not UnitIsPlayer(unit) and cfg.enhance_threat == true then
        setColorBorder(self, unpack(C.media.border_color))
    end

    threatColor(main, true)
end

-- Auras functions
local AurasCustomFilter = function(element, unit, data)
    if cfg.blackList[data.spellID] then
        return false
    elseif cfg.whiteList[data.spellID] and data.isFromPlayerOrPlayerPet then
        return true
    else
        return core:FilterAuras(unit, data, element)
    end
end

local AurasPostCreateIcon = function(element, button)
    core:PostCreateIcon(button)

    button:SetSize(cfg.auras_size, cfg.auras_size)
    button:EnableMouse(false)

    button.remaining = button:CreateFontString(nil, 'OVERLAY')
    button.remaining:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
    button.remaining:SetPoint("BOTTOM", button, "BOTTOM", 0, -4)
    button.remaining:SetJustifyH("CENTER")

    button.Cooldown.noCooldownCount = true

    button.Count:SetPoint("BOTTOMRIGHT", button, "TOPRIGHT", 0, -8)
    button.Count:SetJustifyH("RIGHT")
    button.Count:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")

    if cfg.show_spiral == true then
        element.disableCooldown = false
        button.Cooldown:SetReverse(true)
        button.parent = CreateFrame("Frame", nil, button)
        button.parent:SetFrameLevel(button.Cooldown:GetFrameLevel() + 1)
        button.Count:SetParent(button.parent)
        button.remaining:SetParent(button.parent)
    else
        element.disableCooldown = true
    end
end

local AurasPostUpdateIcon = function(element, button, unit, data)
    core:PostUpdateIcon(button, unit, data)

    if data.duration and data.duration > 0 and cfg.show_timers then
        button.remaining:Show()
        button.timeLeft = data.expirationTime
        button:SetScript("OnUpdate", core.CreateAuraTimer)
    else
        button.remaining:Hide()
        button.timeLeft = math.huge
        button:SetScript("OnUpdate", nil)
    end

    local color = DebuffTypeColor[data.dispelName] or DebuffTypeColor.none
    if cfg.colorBorder then
        button.Overlay:SetVertexColor(color.r, color.g, color.b)
    else
        button.Overlay:SetVertexColor(0, 0, 0)
    end
    button.first = true
end

local function callback(self, event, unit)
    if not self then return end
    if unit then
        local unitGUID = UnitGUID(unit)
        self.npcID = unitGUID and select(6, strsplit('-', unitGUID))
        self.unitName = UnitName(unit)
        self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

        if UnitIsUnit(unit, "player") then
            self.Power:Show()
            self.Name:Hide()
            self.Castbar:SetAlpha(0)
            self.RaidTargetIndicator:SetAlpha(0)
        else
            self.Power:Hide()
            self.Name:Show()
            self.Castbar:SetAlpha(1)
            self.RaidTargetIndicator:SetAlpha(1)

            if self.widgetsOnly or UnitWidgetSet(unit) and UnitIsOwnerOrControllerOfUnit("player", unit) then
                self.Health:SetAlpha(0)
                self.Level:SetAlpha(0)
                self.Name:SetAlpha(0)
                self.Castbar:SetAlpha(0)
            else
                self.Health:SetAlpha(1)
                self.Level:SetAlpha(1)
                self.Name:SetAlpha(1)
                self.Castbar:SetAlpha(1)
            end

            local blizzPlate = self:GetParent().UnitFrame
            self.widgetContainer = blizzPlate and blizzPlate.WidgetContainer
            if self.widgetContainer then
                self.widgetContainer:SetParent(self)
            end
        end
    end
end

local function style(self, unit)
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    local main = self
    self.unit = unit

    self:SetSize(cfg.width, cfg.height)
    self:SetPoint("CENTER", nameplate, "CENTER")

    -- Health Bar
    self.Health = CreateFrame("StatusBar", nil, self)
    self.Health:SetAllPoints(self)
    self.Health:SetStatusBarTexture(C.media.texture.status)
    self.Health.frequentUpdates = true
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.colorClass = true
    self.Health.colorReaction = true
    self.Health.colorHealth = true
    createBorderFrame(self.Health)

    self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetAlpha(.6)
    self.Health.bg:SetTexture(C.media.texture.status)
    self.Health.bg.multiplier = 0.2

    self.Health.border = self.Health:CreateTexture(nil, "BORDER")
    self.Health.border:SetTexture(bar_border)
    self.Health.border:SetPoint("CENTER")
    -- E:ApplyBarBorder(self.Health)

    -- Health Text
    if cfg.health_value == true then
        self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
        self.Health.value:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
        self:Tag(self.Health.value, "[dd:nameplateHealth]")
    end

    -- Player Power Bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetStatusBarTexture(C.media.texture.status)
    self.Power:ClearAllPoints()
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
    self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -6 - (cfg.height * E.noscalemult / 2))
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.PostUpdate = module.PreUpdatePower
    self.Power:CreateShadow()
    createBorderFrame(self.Power)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(C.media.texture.status)
    self.Power.bg.multiplier = 0.2

    -- Hide Blizzard Power Bar
    hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
        if not frame or frame:IsForbidden() then
            return
        end
        if frame.classNamePlatePowerBar then
            frame.classNamePlatePowerBar:Hide()
            frame.classNamePlatePowerBar:UnregisterAllEvents()
        end
    end)

    -- Name Text
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetFont(unpack(C.media.standard_font))
    self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 4)
    self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 3, 4)
    self.Name:SetWordWrap(false)

    if cfg.name_abbrev == true then
        self:Tag(self.Name, "[dd:nameplateNameColor][dd:nameLongAbbrev]")
    else
        self:Tag(self.Name, "[dd:nameplateNameColor][dd:nameLong]")
    end

    -- arrow
    if cfg.arrow then
        self.arrow = self:CreateTexture("$parent_Arrow", "OVERLAY")
        self.arrow:SetSize(50, 50)
        self.arrow:SetTexture(arrow)
        self.arrow:SetPoint("BOTTOM", self, "TOP", 0, ((cfg.track_auras or cfg.track_buffs) and cfg.auras_size or 0) + 14)
        self.arrow:Hide()
    end

    -- Level Text
    self.Level = self:CreateFontString(nil, "OVERLAY")
    self.Level:SetFont(unpack(C.media.standard_font))
    self.Level:SetPoint("RIGHT", self.Health, "LEFT", -12, 0)
    self:Tag(self.Level, "[dd:difficulty][level]")

    -- Cast Bar
    self.Castbar = CreateFrame("StatusBar", nil, self)
    self.Castbar:SetFrameLevel(3)
    self.Castbar:SetStatusBarTexture(C.media.texture.status)
    self.Castbar:SetStatusBarColor(1, 0.8, 0)
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", -4, -8)
    self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 4, -8 - (cfg.height * E.noscalemult))
    self.Castbar:CreateShadow()
    createBorderFrame(self.Castbar)

    self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetTexture(C.media.texture.status_bg)
    self.Castbar.bg:SetColorTexture(1, 0.8, 0, 0.2)

    self.Castbar.PostCastStart = castColor
    self.Castbar.PostCastFail = castColor
    self.Castbar.PostCastInterruptible = castColor
    self.Castbar.PostCastStop = castColor

    -- Create Cast Time Text
    self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
    self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", 0, 0)
    self.Castbar.Time:SetFont(unpack(C.media.standard_font))

    self.Castbar.CustomTimeText = function(self, duration)
        self.Time:SetText(("%.1f"):format(self.channeling and duration or self.max - duration))
    end

    -- Create Cast Name Text
    if cfg.show_castbar_name == true then
        self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
        self.Castbar.Text:SetPoint("LEFT", self.Castbar, "LEFT", 3, 0)
        self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -1, 0)
        self.Castbar.Text:SetFont(unpack(C.media.standard_font))
        self.Castbar.Text:SetJustifyH("LEFT")
    end

    -- Create CastBar Icon
    self.Castbar.IconOverlay = CreateFrame("Frame", nil, self.Castbar)
    self.Castbar.IconOverlay:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
    self.Castbar.IconOverlay:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 12, 0)

    E:ApplyOverlayBorder(self.Castbar.IconOverlay)

    self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
    self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Castbar.Icon:SetDrawLayer("ARTWORK")
    self.Castbar.Icon:SetAllPoints(self.Castbar.IconOverlay)

    self.Castbar.Icon.glowFrame = CreateFrame("Frame", nil, self)
    self.Castbar.Icon.glowFrame:SetPoint("CENTER", self.Castbar.Icon, "CENTER")
    self.Castbar.Icon.glowFrame:SetSize(self.Castbar.Icon:GetWidth()+8, self.Castbar.Icon:GetHeight()+8)

    -- Raid Icon
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RaidTargetIndicator:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
    self.RaidTargetIndicator:SetPoint("BOTTOM", self.Health, "TOP", 0, cfg.track_auras == true and 38 or 16)

    -- Class Icon
    if cfg.class_icons == true then
        self.Class = CreateFrame("Frame", nil, self)
        self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
        self.Class.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        self.Class.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -8, 0)
        self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
        self.Class.Icon:SetTexCoord(0, 0, 0, 0)
    end

    -- Totem Icon
    if cfg.totem_icons == true then
        self.Totem = CreateFrame("Frame", nil, self)
        self.Totem.Icon = self.Totem:CreateTexture(nil, "OVERLAY")
        self.Totem.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        self.Totem.Icon:SetPoint("BOTTOM", self.Health, "TOP", 0, 16)
        self.Totem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    -- Healer Icon
    if cfg.healer_icon == true then
        self.HealerIcon = self.Health:CreateTexture(nil, "OVERLAY")
        self.HealerIcon:SetSize(16, 16)
        self.HealerIcon:SetTexture(C.media.path .. "icon_healer")
        self.HealerIcon:SetPoint("BOTTOM", self.Name, "TOP", 0, cfg.track_auras == true and 13 or 0)
    end

    -- Quest Icon
    if cfg.quest then
        self.QuestIcon = self:CreateTexture(nil, "OVERLAY", nil, 7)
        self.QuestIcon:SetSize((cfg.height * 2 * E.noscalemult), (cfg.height * 2 * E.noscalemult))
        self.QuestIcon:SetPoint("LEFT", self.Name, "RIGHT", 5, 0)
        self.QuestIcon:Hide()

        self.QuestIcon.Text = self:CreateFontString(nil, "OVERLAY")
        self.QuestIcon.Text:SetPoint("RIGHT", self.QuestIcon, "LEFT", -1, 0)
        self.QuestIcon.Text:SetFont(unpack(C.media.standard_font))

        self.QuestIcon.Item = self:CreateTexture(nil, "OVERLAY")
        self.QuestIcon.Item:SetSize((cfg.height * 2 * E.noscalemult) - 2, (cfg.height * 2 * E.noscalemult) - 2)
        self.QuestIcon.Item:SetPoint("RIGHT", self.QuestIcon.Text, "LEFT", -2, 0)
        self.QuestIcon.Item:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end

    -- Aura tracking
    if cfg.track_debuffs == true or cfg.track_buffs == true then
        self.Auras = CreateFrame("Frame", nil, self)
        self.Auras:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 2 * E.noscalemult, 20)
        self.Auras.initialAnchor = "BOTTOMRIGHT"
        self.Auras["growth-y"] = "UP"
        self.Auras["growth-x"] = "LEFT"
        self.Auras.numDebuffs = cfg.track_debuffs and 6 or 0
        self.Auras.numBuffs = cfg.track_buffs and 4 or 0
        self.Auras.maxAuras = 5
        self.Auras:SetSize(20 + cfg.width, cfg.auras_size)
        self.Auras.spacing = cfg.icon_spacing
        self.Auras.size = cfg.auras_size
        self.Auras.onlyShowPlayer = cfg.player_aura_only
        self.Auras.showStealableBuffs = cfg.show_stealable_buffs
        self.Auras.disableMouse = true

        self.Auras.FilterAura = AurasCustomFilter
        self.Auras.PostCreateButton = AurasPostCreateIcon
        self.Auras.PostUpdateButton = AurasPostUpdateIcon
    end

    -- Health color
    self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

    self.Health:SetScript("OnEvent", function()
        threatColor(main)
    end)

    self.Health.PostUpdate = healthPostUpdate

    -- Absorb
    local ahpb = self.Health:CreateTexture(nil, "ARTWORK")
        ahpb:SetTexture(C.media.path .. "uf_bartex_normal")
        ahpb:SetVertexColor(1, 1, 0, 1)
        self.HealthPrediction = {
            absorbBar = ahpb
        }

    -- Every event should be register with this
    table.insert(self.__elements, updateName)
    self:RegisterEvent("UNIT_NAME_UPDATE", updateName)

    table.insert(self.__elements, updateTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", updateTarget, true)

    -- Disable movement via /moveui
    self.disableMovement = true
end

function module:PLAYER_REGEN_ENABLED()
    SetCVar("nameplateShowEnemies", 0)
end

function module:PLAYER_REGEN_DISABLED()
    SetCVar("nameplateShowEnemies", 1)
end

function module:PLAYER_ENTERING_WORLD()
    if InCombatLockdown() then
        SetCVar("nameplateShowEnemies", 1)
    else
        SetCVar("nameplateShowEnemies", 0)
    end

    if cfg.healer_icon == true then
        for _, specID in pairs(healerSpecIDs) do
            local _, name = GetSpecializationInfoByID(specID)
            if name and not healerSpecs[name] then
                healerSpecs[name] = true
            end
        end

        checkHealers()
    end
end

function module:PLAYER_LOGIN()
    if cfg.enhance_threat == true then
        SetCVar("threatWarning", 3)
    end
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("namePlateMinScale", 1)
    SetCVar("namePlateMaxScale", 1)
    SetCVar("nameplateLargerScale", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateMinAlpha", 1)
    SetCVar("nameplateMaxAlpha", 1)
    SetCVar("nameplateSelectedAlpha", 1)
    SetCVar("nameplateNotSelectedAlpha", 1)
    SetCVar("nameplateLargeTopInset", 0.08)

    SetCVar("nameplateOtherTopInset", cfg.clamp and 0.08 or -1)
    SetCVar("nameplateOtherBottomInset", cfg.clamp and 0.1 or -1)

    if cfg.only_name then
        SetCVar("nameplateShowOnlyNames", 1)
    end

    local function changeFont(self)
        self:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
        self:SetShadowOffset(1, -1)
    end
    changeFont(SystemFont_NamePlateFixed)
end

function module:OnInit()
    if cfg.kick_color then
        if E.myClass == "DEATHKNIGHT" then
            kickID = 47528
        elseif E.myClass == "DEMONHUNTER" then
            kickID = 183752
        elseif E.myClass == "DRUID" then
            kickID = 106839
        elseif E.myClass == "HUNTER" then
            kickID = GetSpecialization() == 3 and 187707 or 147362
        elseif E.myClass == "MAGE" then
            kickID = 2139
        elseif E.myClass == "MONK" then
            kickID = 116705
        elseif E.myClass == "PALADIN" then
            kickID = 96231
        elseif E.myClass == "PRIEST" then
            kickID = 15487
        elseif E.myClass == "ROGUE" then
            kickID = 1766
        elseif E.myClass == "SHAMAN" then
            kickID = 57994
        elseif E.myClass == "WARLOCK" then
            kickID = 119910
        elseif E.myClass == "WARRIOR" then
            kickID = 6552
        end
    end

    self:RegisterEvent("PLAYER_LOGIN")

    if cfg.combat == true then
        self:RegisterEvent("PLAYER_REGEN_ENABLED")
        self:RegisterEvent("PLAYER_REGEN_DISABLED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
    end
end

oUF:RegisterStyle("DarkUI:Nameplates", style)
oUF:SetActiveStyle("DarkUI:Nameplates")
oUF:SpawnNamePlates("DarkUINameplates", callback)