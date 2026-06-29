local E, C, L = select(2, ...):unpack()

if not C.nameplate.enable then return end

------------------------------------------------------------------------
-- Nameplates
------------------------------------------------------------------------
local module = E:Module("Unitframe"):Sub("Nameplate")
local core = E:Module("Unitframe")

local LCG = LibStub("LibCustomGlow-1.0", true)

local oUF = select(2, ...).oUF

local issecretvalue = issecretvalue
local SetCVar = C_CVar.SetCVar
local InCombatLockdown = InCombatLockdown
local UnitAffectingCombat, UnitThreatSituation = UnitAffectingCombat, UnitThreatSituation
local UnitIsTapDenied = UnitIsTapDenied
local UnitName, UnitIsUnit, UnitReaction, UnitIsPlayer, UnitClass = UnitName, UnitIsUnit, UnitReaction, UnitIsPlayer, UnitClass
local UnitExists = UnitExists
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSelectionColor = UnitSelectionColor
local UnitGUID = UnitGUID
local UnitNameplateShowsWidgetsOnly = UnitNameplateShowsWidgetsOnly
local UnitWidgetSet = UnitWidgetSet
local UnitIsOwnerOrControllerOfUnit = UnitIsOwnerOrControllerOfUnit
local IsInGroup, IsInRaid = IsInGroup, IsInRaid
local GetNumGroupMembers = GetNumGroupMembers

local cfg = C.nameplate

local bar_border
local arrow

local function createBorderFrame(frame, point)
    if point == nil then point = frame end
    if point.backdropTex then return end

    frame.backdropTex = frame:CreateTexture(nil, "BORDER")
    frame.backdropTex:SetDrawLayer("BORDER", -8)
    frame.backdropTex:SetPoint("TOPLEFT", point, "TOPLEFT", -E.noscalemult * 2, E.noscalemult * 2)
    frame.backdropTex:SetPoint("BOTTOMRIGHT", point, "BOTTOMRIGHT", E.noscalemult * 2, -E.noscalemult * 2)
    frame.backdropTex:SetColorTexture(unpack(C.media.backdrop_color))

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
        self:SetSize(cfg.width + cfg.ad_width, cfg.height + cfg.ad_height)
        self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8 - (cfg.height + cfg.ad_height))
        self.Castbar.Icon:SetSize((cfg.height + cfg.ad_height) * 2 + 8, (cfg.height + cfg.ad_height) * 2 + 8)
        if cfg.class_icons == true then self.Class.Icon:SetSize((cfg.height + cfg.ad_height) * 2 + 8, (cfg.height + cfg.ad_height) * 2 + 8) end

        self:SetAlpha(1)
        if self.arrow then self.arrow:Show() end
    else
        self:SetSize(cfg.width, cfg.height)
        self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8 - cfg.height)
        self.Castbar.Icon:SetSize(cfg.height * 2 + 8, cfg.height * 2 + 8)
        if cfg.class_icons == true then self.Class.Icon:SetSize(cfg.height * 2 + 8, cfg.height * 2 + 8) end
        if UnitExists("target") and not isMe then
            self:SetAlpha(0.5)
        else
            self:SetAlpha(1)
        end

        if self.arrow then self.arrow:Hide() end
    end

    self.Health.borderTex:SetSize(256 * self.Health:GetWidth() / 198, 64 * self.Health:GetHeight() / 12)
end

local function updateName(self)
    if cfg.class_icons == true then
        local reaction = UnitReaction(self.unit, "player")
        if UnitIsPlayer(self.unit) and (reaction and reaction <= 4) then
            local _, class = UnitClass(self.unit)
            local texcoord = CLASS_ICON_TCOORDS[class]
            self.Class.Icon:SetTexCoord(texcoord[1] + 0.015, texcoord[2] - 0.02, texcoord[3] + 0.018, texcoord[4] - 0.02)
            self.Class:Show()
        else
            self.Class.Icon:SetTexCoord(0, 0, 0, 0)
            self.Class:Hide()
        end
    end
end

-- Cast color
local function castColor(self)
    local spellID = self.spellID
    if not issecretvalue(spellID) and cfg.majorSpells[spellID] then
        if LCG then LCG.ShowOverlayGlow(self.Icon.glowFrame) end
    else
        if LCG then LCG.HideOverlayGlow(self.Icon.glowFrame) end
    end
end

-- Threat color
local function threatColor(self, forced)
    if self.plateType ~= "ENEMY_NPC" then return end
    local combat = UnitAffectingCombat("player")
    local threatStatus = UnitThreatSituation("player", self.unit)

    if cfg.enhance_threat ~= true then setColorBorder(self.Health, unpack(C.media.border_color)) end

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
                                if isTanking and UnitGroupRolesAssigned("raid" .. i) == "TANK" then self.Health:SetStatusBarColor(unpack(cfg.offtank_color)) end
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
local lowHealthCurve = C_CurveUtil.CreateColorCurve()
lowHealthCurve:SetType(Enum.LuaCurveType.Step)
lowHealthCurve:AddPoint(0, CreateColor(1, 0, 0, 1))
lowHealthCurve:AddPoint(0.2, CreateColor(1, 1, 0, 1))
lowHealthCurve:AddPoint(0.5, CreateColor(unpack(C.media.border_color)))

local function healthPostUpdate(self, unit)
    local main = self:GetParent()

    local r, g, b
    local mu = self.bg.multiplier
    local unitReaction = UnitReaction(unit, "player")
    if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (unitReaction and unitReaction >= 5) then
        local color = C.oUF_colors.power["MANA"]
        r, g, b = color:GetRGB()
        self:SetStatusBarColor(r, g, b)
        self.bg:SetVertexColor(r * mu, g * mu, b * mu)
    elseif not UnitIsTapDenied(unit) and not UnitIsPlayer(unit) then
        local reaction = C.oUF_colors.reaction[unitReaction]
        if reaction then
            r, g, b = reaction:GetRGB()
        else
            r, g, b = UnitSelectionColor(unit, true)
        end

        self:SetStatusBarColor(r, g, b)
        self.bg:SetVertexColor(r * mu, g * mu, b * mu)
    end

    if cfg.customUnits[main.npcID] then
        r, g, b = unpack(cfg.custom_color)
        self:SetStatusBarColor(r, g, b)
        self.bg:SetVertexColor(r * mu, g * mu, b * mu)
    end

    if UnitIsPlayer(unit) then
        local color = UnitHealthPercent(unit, true, lowHealthCurve)
        if color then
            setColorBorder(self, color:GetRGB())
        else
            setColorBorder(self, unpack(C.media.border_color))
        end
    elseif cfg.enhance_threat == true then
        local color = UnitHealthPercent(unit, true, lowHealthCurve)
        if color then
            setColorBorder(self, color:GetRGB())
        else
            setColorBorder(self, unpack(C.media.border_color))
        end
    end

    threatColor(main, true)
end

-- Auras functions
local function aurasFilter(element, unit, data)
    if element.alwaysShowStealable and not data.isHarmfulAura and type(data.dispelName) ~= "nil" and (not UnitIsPlayer(unit)) then return true end
    return (data.isPlayerAura and data.isNameplateOnlyAura) and not (data.isHarmfulAura and data.isCrowdControlAura)
end

local function ccFilter(element, unit, data) return data.isHarmfulAura and data.isCrowdControlAura end

local function aurasPostCreateIcon(element, button)
    core.PostCreateButton(element, button)

    local size = element.size or cfg.auras_size
    button:SetSize(size, size)
    button:EnableMouse(false)

    button.Cooldown.noCooldownCount = not cfg.show_timers
    if button.Cooldown.SetHideCountdownNumbers then button.Cooldown:SetHideCountdownNumbers(not cfg.show_timers) end

    button.Count:SetPoint("BOTTOM", button, "TOP", 0, -8)
    button.Count:SetJustifyH("CENTER")
    button.Count:SetFont(STANDARD_TEXT_FONT, 8, "THINOUTLINE")

    if cfg.show_spiral == true then
        element.disableCooldown = false
        button.Cooldown:SetReverse(true)
        button.parent = CreateFrame("Frame", nil, button)
        button.parent:SetFrameLevel(button.Cooldown:GetFrameLevel() + 1)
        button.Count:SetParent(button.parent)
    else
        element.disableCooldown = true
    end
end

local function aurasPostUpdateIcon(element, button, unit, data)
    core.PostUpdateButton(element, button, unit, data)

    if cfg.desaturate and data.isHarmfulAura and not data.isPlayerAura then
        button.Icon:SetDesaturated(true)
    else
        button.Icon:SetDesaturated(false)
    end

    if data.isHarmfulAura and element.showDebuffType and element.dispelColorCurve then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
        if color then
            button.Overlay:SetVertexColor(color:GetRGBA())
        else
            button.Overlay:SetVertexColor(0, 0, 0)
        end
    else
        button.Overlay:SetVertexColor(0, 0, 0)
    end
end

local function callback(self, event, unit)
    if not self then return end
    if unit then
        local unitGUID = UnitGUID(unit)
        if unitGUID and canaccessvalue(unitGUID) then
            self.npcID = tonumber((select(6, strsplit("-", unitGUID))))
        else
            self.npcID = nil
        end
        local unitName = UnitName(unit)
        self.unitName = unitName and canaccessvalue(unitName) and unitName or nil
        self.widgetsOnly = UnitNameplateShowsWidgetsOnly(unit)

        if UnitIsUnit(unit, "player") then
            self.plateType = "PLAYER"
        elseif (UnitReaction(unit, "player") or 0) > 4 then
            self.plateType = UnitIsPlayer(unit) and "FRIENDLY_PLAYER" or "FRIENDLY_NPC"
        else
            self.plateType = UnitIsPlayer(unit) and "ENEMY_PLAYER" or "ENEMY_NPC"
        end

        if self.plateType == "PLAYER" then
            self:EnableElement("Power")
            self.Power:Show()
            self.Name:Hide()
            self.Castbar:SetAlpha(0)
            self.RaidTargetIndicator:SetAlpha(0)
        else
            self:DisableElement("Power")
            self.Power:Hide()
            self.Name:Show()
            self.Castbar:SetAlpha(1)
            self.RaidTargetIndicator:SetAlpha(1)

            if self.widgetsOnly or UnitWidgetSet(unit) and UnitIsOwnerOrControllerOfUnit("player", unit) then
                self.Health:SetAlpha(0)
                self.Level:SetAlpha(0)
                self.Name:SetAlpha(0)
                self.Castbar:SetAlpha(0)
                self.ClassificationIndicator:SetAlpha(0)
            else
                self.Health:SetAlpha(1)
                self.Level:SetAlpha(1)
                self.Name:SetAlpha(1)
                self.Castbar:SetAlpha(1)
                self.ClassificationIndicator:SetAlpha(1)
            end

            local isFriendly = self.plateType == "FRIENDLY_PLAYER" or self.plateType == "FRIENDLY_NPC"
            if cfg.friendly.nameOnly and isFriendly and not self.widgetsOnly then
                self.Health:SetAlpha(0)
                self.Level:SetAlpha(0)
                self.Castbar:SetAlpha(0)
                self.ClassificationIndicator:SetAlpha(0)
                if self.Auras then self.Auras:Hide() end
                if self.Debuffs then self.Debuffs:Hide() end
                self.Name:ClearAllPoints()
                self.Name:SetPoint("CENTER", self, "CENTER", 0, 4)
                self.Name:SetJustifyH("CENTER")
                self.Highlight:ClearAllPoints()
                self.Highlight:SetPoint("CENTER", self, "CENTER", 0, 4)
                self.Highlight:SetSize(cfg.width, 20)
                self.Highlight.texture:SetTexture(C.media.texture.spark)
                self.Highlight.texture:SetVertexColor(1, 1, 1, 0.8)
                self.Highlight.texture:SetAlpha(0.5)
            else
                self.Name:ClearAllPoints()
                self.Name:SetPoint("LEFT", self.Level, "RIGHT", 2, 0)
                self.Name:SetJustifyH("LEFT")
                self.ClassificationIndicator:SetAlpha(1)
                if self.Auras then self.Auras:Show() end
                if self.Debuffs then self.Debuffs:Show() end
                self.Highlight:ClearAllPoints()
                self.Highlight:SetAllPoints(self.Health)
                self.Highlight.texture:SetColorTexture(1, 1, 1, 0.15)
                self.Highlight.texture:SetAlpha(1)
            end

            local blizzPlate = self:GetParent().UnitFrame
            self.widgetContainer = blizzPlate and blizzPlate.WidgetContainer
            if self.widgetContainer then self.widgetContainer:SetParent(self) end
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
    self.Health.colorTapping = true
    self.Health.colorDisconnected = true
    self.Health.colorClass = true
    self.Health.colorReaction = true
    self.Health.colorHealth = true
    createBorderFrame(self.Health)

    self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetAlpha(0.6)
    self.Health.bg:SetTexture(C.media.texture.status)
    self.Health.bg.multiplier = 0.2

    self.Health.borderTex = self.Health:CreateTexture(nil, "BORDER")
    self.Health.borderTex:SetTexture(bar_border)
    self.Health.borderTex:SetPoint("CENTER")

    -- Mouseover Highlight
    local highlight = CreateFrame("Frame", nil, self)
    highlight:SetAllPoints(self.Health)
    highlight:SetFrameLevel(self.Health:GetFrameLevel() + 5)
    highlight:EnableMouse(false)
    highlight:Hide()

    highlight.texture = highlight:CreateTexture(nil, "ARTWORK")
    highlight.texture:SetAllPoints(highlight)
    highlight.texture:SetColorTexture(1, 1, 1, 0.15)
    highlight.texture:SetBlendMode("ADD")

    highlight:SetScript("OnUpdate", function(hl, elapsed)
        hl.elapsed = (hl.elapsed or 0) + elapsed
        if hl.elapsed > 0.1 then
            if not UnitExists("mouseover") or not UnitIsUnit("mouseover", self.unit or "") then hl:Hide() end
            hl.elapsed = 0
        end
    end)

    self.Highlight = highlight

    local function highlightUpdate(frame)
        if UnitExists("mouseover") and UnitIsUnit("mouseover", frame.unit or "") then
            frame.Highlight:Show()
        else
            frame.Highlight:Hide()
        end
    end
    self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", highlightUpdate, true)

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
    self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -6 - cfg.height / 2)
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power:CreateShadow()
    createBorderFrame(self.Power)

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(C.media.texture.status)
    self.Power.bg.multiplier = 0.2
    self.Power.PostUpdateColor = core.PostUpdatePowerColor

    -- Level Text
    self.Level = self:CreateFontString(nil, "OVERLAY")
    self.Level:SetFont(unpack(C.media.standard_font))
    self.Level:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 6)
    self:Tag(self.Level, "[dd:difficulty][level]")

    -- Classification Indicator (elite/rare/boss)
    self.ClassificationIndicator = self:CreateTexture(nil, "OVERLAY")
    self.ClassificationIndicator:SetSize(cfg.height * 2, cfg.height * 2)
    self.ClassificationIndicator:SetPoint("RIGHT", self.Level, "LEFT", -1, 0)

    -- Name Text
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetFont(unpack(C.media.standard_font))
    self.Name:SetPoint("LEFT", self.Level, "RIGHT", 2, 0)
    self.Name:SetJustifyH("LEFT")
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
        self.arrow:SetPoint("BOTTOM", self, "TOP", 0, (cfg.show_auras and cfg.auras_size or 0) + 14)
        self.arrow:Hide()
    end

    -- Cast Bar
    self.Castbar = CreateFrame("StatusBar", nil, self)
    self.Castbar:SetFrameLevel(3)
    self.Castbar:SetStatusBarTexture(C.media.texture.status)
    self.Castbar:SetStatusBarColor(0.11, 0.58, 0.89)
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", -4, -8)
    self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 4, -8 - cfg.height)
    self.Castbar:CreateShadow()
    createBorderFrame(self.Castbar)

    self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetTexture(C.media.texture.status_bg)
    self.Castbar.bg:SetColorTexture(0.11, 0.58, 0.89, 0.2)

    self.Castbar.PostCastStart = function(cb, unit)
        castColor(cb)
        core.PostCastStart(cb, unit)
        local r, g, b = cb:GetStatusBarColor()
        cb.bg:SetColorTexture(r, g, b, 0.2)
    end
    self.Castbar.PostCastInterruptible = function(cb)
        core.PostCastInterruptible(cb)
        local r, g, b = cb:GetStatusBarColor()
        cb.bg:SetColorTexture(r, g, b, 0.2)
    end

    -- Create Cast Time Text
    self.Castbar.Time = self.Castbar:CreateFontString(nil, "ARTWORK")
    self.Castbar.Time:SetPoint("RIGHT", self.Castbar, "RIGHT", 0, 0)
    self.Castbar.Time:SetFont(unpack(C.media.standard_font))

    self.Castbar.CustomTimeText = function(self, duration) self.Time:SetFormattedText("%.1f", duration:GetRemainingDuration()) end

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
    self.Castbar.IconOverlay:SetSize(cfg.height * 2 + 8, cfg.height * 2 + 8)
    self.Castbar.IconOverlay:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 12, 0)

    self.Castbar.IconOverlay:CreateOverlay()

    self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
    self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Castbar.Icon:SetDrawLayer("ARTWORK")
    self.Castbar.Icon:SetAllPoints(self.Castbar.IconOverlay)

    self.Castbar.Icon.glowFrame = CreateFrame("Frame", nil, self)
    self.Castbar.Icon.glowFrame:SetPoint("CENTER", self.Castbar.Icon, "CENTER")
    self.Castbar.Icon.glowFrame:SetSize(self.Castbar.Icon:GetWidth() + 8, self.Castbar.Icon:GetHeight() + 8)

    -- Raid Icon
    self.RaidTargetIndicator = self.Health:CreateTexture(nil, "ARTWORK", nil, 7)
    self.RaidTargetIndicator:SetSize(cfg.height * 2, cfg.height * 2)
    self.RaidTargetIndicator:SetPoint("RIGHT", self.Health, "LEFT", -16, 0)

    -- Class Icon
    if cfg.class_icons == true then
        self.Class = CreateFrame("Frame", nil, self)
        self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
        self.Class.Icon:SetSize(cfg.height * 2 + 8, cfg.height * 2 + 8)
        self.Class.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -8, 0)
        self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
        self.Class.Icon:SetTexCoord(0, 0, 0, 0)
    end

    -- Quest Icons
    if cfg.quest then
        local size = cfg.height * 2
        local qi = CreateFrame("Frame", nil, self)
        qi:SetSize(size, size)
        qi:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 3, 6)
        qi:Hide()

        local types = { "Default", "Item", "Skull", "Chat" }
        for _, name in ipairs(types) do
            local icon = qi:CreateTexture(nil, "OVERLAY", nil, 1)
            icon:SetSize(size, size)
            icon.Text = qi:CreateFontString(nil, "OVERLAY")
            icon.Text:SetFont(unpack(C.media.standard_font))
            icon.Text:SetPoint("LEFT", icon, "RIGHT", -1, 0)
            icon:Hide()
            qi[name] = icon
        end

        qi.Default:SetAtlas("SmallQuestBang")
        qi.Skull:SetTexture([[Interface\TargetingFrame\UI-TargetingFrame-Skull]])
        qi.Chat:SetTexture([[Interface\WorldMap\ChatBubble_64.PNG]])
        qi.Chat:SetTexCoord(0, 0.5, 0.5, 1)
        qi.Item:SetTexCoord(0.1, 0.9, 0.1, 0.9)

        self.QuestIcons = qi
    end

    -- Aura tracking
    if cfg.show_auras then
        self.Auras = CreateFrame("Frame", nil, self)
        self.Auras:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 2, 20)
        self.Auras.initialAnchor = "BOTTOMLEFT"
        self.Auras.growthY = "UP"
        self.Auras.numTotal = cfg.max_auras
        self.Auras.maxCols = cfg.auras_per_row
        self.Auras:SetSize(20 + cfg.width, cfg.auras_size)
        self.Auras.spacing = cfg.icon_spacing
        self.Auras.size = cfg.auras_size
        self.Auras.showStealableBuffs = true
        self.Auras.alwaysShowStealable = cfg.show_dispel
        self.Auras.showDebuffType = true
        self.Auras.disableMouse = true

        self.Auras.FilterAura = aurasFilter
        self.Auras.PostCreateButton = aurasPostCreateIcon
        self.Auras.PostUpdateButton = aurasPostUpdateIcon
        self.Auras.PostProcessAuraData = core.PostProcessAuraData
    end

    -- CC Debuffs (right side of health bar)
    if cfg.show_cc then
        self.Debuffs = CreateFrame("Frame", nil, self)
        self.Debuffs:SetPoint("LEFT", self.Health, "RIGHT", 5, 0)
        self.Debuffs.initialAnchor = "LEFT"
        self.Debuffs.numDebuffs = cfg.num_cc
        self.Debuffs:SetSize(cfg.cc_size * cfg.num_cc + cfg.icon_spacing * (cfg.num_cc - 1), cfg.cc_size)
        self.Debuffs.size = cfg.cc_size
        self.Debuffs.spacing = cfg.icon_spacing
        self.Debuffs.showDebuffType = true
        self.Debuffs.disableMouse = true

        self.Debuffs.FilterAura = ccFilter
        self.Debuffs.PostCreateButton = aurasPostCreateIcon
        self.Debuffs.PostUpdateButton = aurasPostUpdateIcon
        self.Debuffs.PostProcessAuraData = core.PostProcessAuraData
    end

    -- Threat (oUF element handles UNIT_THREAT_SITUATION_UPDATE with unit filtering)
    self.ThreatIndicator = self:CreateTexture(nil, "OVERLAY")
    self.ThreatIndicator:Hide()
    self.ThreatIndicator.feedbackUnit = "player"
    self.ThreatIndicator.Override = function(frame, event, unit)
        if unit ~= frame.unit then return end
        threatColor(frame)
    end

    self.Health.PostUpdate = healthPostUpdate

    -- Absorb
    local ahpb = CreateFrame("StatusBar", nil, self.Health)
    ahpb:SetAllPoints()
    ahpb:SetStatusBarTexture(C.media.path .. "uf_bartex_normal")
    ahpb:SetStatusBarColor(1, 1, 0, 0.3)
    ahpb:SetFrameLevel(self.Health:GetFrameLevel())
    self.HealthPrediction = {
        damageAbsorb = ahpb,
    }

    -- Every event should be register with this
    table.insert(self.__elements, updateName)
    self:RegisterEvent("UNIT_NAME_UPDATE", updateName)

    table.insert(self.__elements, updateTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", updateTarget, true)

    -- Disable movement via /moveui
    self.disableMovement = true
end

local function updateAllThreat()
    for _, plate in pairs(C_NamePlate.GetNamePlates()) do
        local unitFrame = plate and plate.unitFrame
        if unitFrame and unitFrame.ThreatIndicator then unitFrame.ThreatIndicator:ForceUpdate() end
    end
end

function module:PLAYER_REGEN_ENABLED()
    if cfg.combat then SetCVar("nameplateShowEnemies", 0) end
    updateAllThreat()
end

function module:PLAYER_REGEN_DISABLED()
    if cfg.combat then SetCVar("nameplateShowEnemies", 1) end
    updateAllThreat()
end

function module:PLAYER_ENTERING_WORLD()
    if InCombatLockdown() then
        SetCVar("nameplateShowEnemies", 1)
    else
        SetCVar("nameplateShowEnemies", 0)
    end
end

function module:PLAYER_LOGIN()
    C_NamePlate.SetNamePlateEnemySize(cfg.width, cfg.height)
    C_NamePlate.SetNamePlateFriendlySize(cfg.width, cfg.height)

    SetCVar("ShowClassColorInNameplate", 1)
    SetCVar("nameplateShowSelf", 0)
    SetCVar("nameplateResourceOnTarget", 0)
    SetCVar("nameplateMotion", 1)
    SetCVar("nameplateShowOnlyNameForFriendlyPlayerUnitNames", 0)

    if cfg.enhance_threat == true then SetCVar("threatWarning", 3) end
    SetCVar("nameplateGlobalScale", 1)
    SetCVar("namePlateMinScale", 1)
    SetCVar("namePlateMaxScale", 1)
    SetCVar("nameplateLargerScale", 1)
    SetCVar("nameplateSelectedScale", 1)
    SetCVar("nameplateMinAlpha", 1)
    SetCVar("nameplateMaxAlpha", 1)
    SetCVar("nameplateSelectedAlpha", 1)
    SetCVar("nameplateNotSelectedAlpha", 1)
    SetCVar("nameplateSelfAlpha", 1)
    SetCVar("nameplateOtherAtBase", 0)
    SetCVar("nameplateMinScaleDistance", 0)
    SetCVar("nameplateMaxScaleDistance", 40)
    SetCVar("nameplateTargetBehindMaxDistance", 40)
    SetCVar("nameplatePlayerMaxDistance", 60)
    SetCVar("nameplateOverlapV", 1.1)
    SetCVar("nameplateLargeTopInset", 0.08)

    SetCVar("nameplateOtherTopInset", cfg.clamp and 0.08 or -1)
    SetCVar("nameplateOtherBottomInset", cfg.clamp and 0.1 or -1)

    if cfg.only_name then SetCVar("nameplateShowOnlyNames", 1) end

    local vis = cfg.visibility
    if vis then
        SetCVar("nameplateShowAll", vis.showAll and 1 or 0)

        local enemy = vis.enemy
        if enemy then
            SetCVar("nameplateShowEnemyTotems", enemy.totems and 1 or 0)
            SetCVar("nameplateShowEnemyMinions", enemy.minions and 1 or 0)
            SetCVar("nameplateShowEnemyGuardians", enemy.guardians and 1 or 0)
            SetCVar("nameplateShowEnemyPets", enemy.pets and 1 or 0)
            SetCVar("nameplateShowEnemyMinus", enemy.minus and 1 or 0)
        end

        local friendly = vis.friendly
        if friendly then
            SetCVar("nameplateShowFriendlyNPCs", friendly.npcs and 1 or 0)
            SetCVar("nameplateShowFriendlyPlayerTotems", friendly.totems and 1 or 0)
            SetCVar("nameplateShowFriendlyPlayerMinions", friendly.minions and 1 or 0)
            SetCVar("nameplateShowFriendlyPlayerGuardians", friendly.guardians and 1 or 0)
            SetCVar("nameplateShowFriendlyPlayerPets", friendly.pets and 1 or 0)
        end
    end

    local function changeFont(self)
        self:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
        self:SetShadowOffset(1, -1)
    end
    changeFont(SystemFont_NamePlateFixed)
end

function module:OnInit()
    bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"
    arrow = C.media.path .. "uf_nameplate_arrow"

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")

    if cfg.combat == true then self:RegisterEvent("PLAYER_ENTERING_WORLD") end

    hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(frame)
        if not frame or frame:IsForbidden() then return end
        if frame.classNamePlatePowerBar then
            frame.classNamePlatePowerBar:Hide()
            frame.classNamePlatePowerBar:UnregisterAllEvents()
        end
    end)

    oUF:RegisterStyle("DarkUI:Nameplates", style)
    oUF:SetActiveStyle("DarkUI:Nameplates")

    local driver = oUF:SpawnNamePlates("DarkUINameplates")
    driver:SetSize(cfg.width, cfg.height)
    driver:SetAddedCallback(callback)
end
