local _, ns = ...
local E, C, L = ns:unpack()

if not C.nameplate.enable then return end

----------------------------------------------------------------------------------------
--  oUF nameplates
----------------------------------------------------------------------------------------

local oUF = ns.oUF or oUF
local _G = _G
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local IsInRaid, IsInGroup, IsInInstance = IsInRaid, IsInGroup, IsInInstance
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local GetSpecializationInfoByID = GetSpecializationInfoByID
local GetNumGroupMembers = GetNumGroupMembers
local GetTime = GetTime
local GetSpellInfo = GetSpellInfo
local GetArenaOpponentSpec = GetArenaOpponentSpec
local GetBattlefieldScore = GetBattlefieldScore
local GetNumBattlefieldScores = GetNumBattlefieldScores
local UnitExists = UnitExists
local UnitIsUnit = UnitIsUnit
local UnitIsPlayer = UnitIsPlayer
local UnitIsTapDenied = UnitIsTapDenied
local UnitName = UnitName
local UnitAffectingCombat = UnitAffectingCombat
local UnitClass = UnitClass
local UnitDetailedThreatSituation = UnitDetailedThreatSituation
local UnitFactionGroup = UnitFactionGroup
local UnitReaction = UnitReaction
local UnitSelectionColor = UnitSelectionColor
local SetCVar = SetCVar
local C_NamePlate_GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit
local pairs, unpack, format, tinsert, huge = pairs, unpack, format, table.insert, math.huge
local hooksecurefunc = hooksecurefunc
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local DebuffTypeColor = DebuffTypeColor

local cfg = C.nameplate
local DUF = E.unitframe
local frame = CreateFrame("Frame")

local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

local healList, exClass, healerSpecs = {}, {}, {}
local testing = false

frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
if cfg.combat == true then
    frame:RegisterEvent("PLAYER_REGEN_ENABLED")
    frame:RegisterEvent("PLAYER_REGEN_DISABLED")
    frame:RegisterEvent("PLAYER_ENTERING_WORLD")

    function frame:PLAYER_REGEN_ENABLED()
        SetCVar("nameplateShowEnemies", 0)
    end

    function frame:PLAYER_REGEN_DISABLED()
        SetCVar("nameplateShowEnemies", 1)
    end
    function frame:PLAYER_ENTERING_WORLD()
        if InCombatLockdown() then
            SetCVar("nameplateShowEnemies", 1)
        else
            SetCVar("nameplateShowEnemies", 0)
        end
    end
end

frame:RegisterEvent("PLAYER_LOGIN")
function frame:PLAYER_LOGIN()
    if cfg.enhance_threat == true then
        SetCVar("threatWarning", 3)
    end
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
    SetCVar("nameplateMaxDistance", cfg.distance or 40)
end

exClass.DEATHKNIGHT = true
exClass.MAGE = true
exClass.ROGUE = true
exClass.WARLOCK = true
exClass.WARRIOR = true

if cfg.healer_icon == true then
    local t = CreateFrame("Frame")
    t.factions = {
        ["Horde"]    = 1,
        ["Alliance"] = 0,
    }
    local healerSpecIDs = {
        105, -- Druid Restoration
        270, -- Monk Mistweaver
        65, -- Paladin Holy
        256, -- Priest Discipline
        257, -- Priest Holy
        264, -- Shaman Restoration
    }
    for _, specID in pairs(healerSpecIDs) do
        local _, name = GetSpecializationInfoByID(specID)
        if name and not healerSpecs[name] then
            healerSpecs[name] = true
        end
    end

    local lastCheck = 20
    local function CheckHealers(_, elapsed)
        lastCheck = lastCheck + elapsed
        if lastCheck > 25 then
            lastCheck = 0
            healList = {}
            for i = 1, GetNumBattlefieldScores() do
                local name, _, _, _, _, faction, _, _, _, _, _, _, _, _, _, talentSpec = GetBattlefieldScore(i)

                if name and healerSpecs[talentSpec] and t.factions[UnitFactionGroup("player")] == faction then
                    name = name:match("(.+)%-.+") or name
                    healList[name] = talentSpec
                end
            end
        end
    end

    local function CheckArenaHealers(_, elapsed)
        lastCheck = lastCheck + elapsed
        if lastCheck > 25 then
            lastCheck = 0
            healList = {}
            for i = 1, 5 do
                local specID = GetArenaOpponentSpec(i)
                if specID and specID > 0 then
                    local name = UnitName(format("arena%d", i))
                    local _, talentSpec = GetSpecializationInfoByID(specID)
                    if name and healerSpecs[talentSpec] then
                        healList[name] = talentSpec
                    end
                end
            end
        end
    end

    local function CheckLoc(_, event)
        if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_ENTERING_BATTLEGROUND" then
            local _, instanceType = IsInInstance()
            if instanceType == "pvp" then
                t:SetScript("OnUpdate", CheckHealers)
            elseif instanceType == "arena" then
                t:SetScript("OnUpdate", CheckArenaHealers)
            else
                healList = {}
                t:SetScript("OnUpdate", nil)
            end
        end
    end

    t:RegisterEvent("PLAYER_ENTERING_WORLD")
    t:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
    t:SetScript("OnEvent", CheckLoc)
end

local totemData = {
    [GetSpellInfo(192058)] = "Interface\\Icons\\spell_nature_brilliance", -- Capacitor Totem
    [GetSpellInfo(98008)]  = "Interface\\Icons\\spell_shaman_spiritlink", -- Spirit Link Totem
    [GetSpellInfo(192077)] = "Interface\\Icons\\ability_shaman_windwalktotem", -- Wind Rush Totem
    [GetSpellInfo(204331)] = "Interface\\Icons\\spell_nature_wrathofair_totem", -- Counterstrike Totem
    [GetSpellInfo(204332)] = "Interface\\Icons\\spell_nature_windfury", -- Windfury Totem
    [GetSpellInfo(204336)] = "Interface\\Icons\\spell_nature_groundingtotem", -- Grounding Totem
    -- Water
    [GetSpellInfo(157153)] = "Interface\\Icons\\ability_shaman_condensationtotem", -- Cloudburst Totem
    [GetSpellInfo(5394)]   = "Interface\\Icons\\INV_Spear_04", -- Healing Stream Totem
    [GetSpellInfo(108280)] = "Interface\\Icons\\ability_shaman_healingtide", -- Healing Tide Totem
    -- Earth
    [GetSpellInfo(207399)] = "Interface\\Icons\\spell_nature_reincarnation", -- Ancestral Protection Totem
    [GetSpellInfo(198838)] = "Interface\\Icons\\spell_nature_stoneskintotem", -- Earthen Wall Totem
    [GetSpellInfo(51485)]  = "Interface\\Icons\\spell_nature_stranglevines", -- Earthgrab Totem
    [GetSpellInfo(196932)] = "Interface\\Icons\\spell_totem_wardofdraining", -- Voodoo Totem
    -- Fire
    [GetSpellInfo(192222)] = "Interface\\Icons\\spell_shaman_spewlava", -- Liquid Magma Totem
    [GetSpellInfo(204330)] = "Interface\\Icons\\spell_fire_totemofwrath", -- Skyfury Totem
    -- Totem Mastery
    [GetSpellInfo(202188)] = "Interface\\Icons\\spell_nature_stoneskintotem", -- Resonance Totem
    [GetSpellInfo(210651)] = "Interface\\Icons\\spell_shaman_stormtotem", -- Storm Totem
    [GetSpellInfo(210657)] = "Interface\\Icons\\spell_fire_searingtotem", -- Ember Totem
    [GetSpellInfo(210660)] = "Interface\\Icons\\spell_nature_invisibilitytotem", -- Tailwind Totem
}

local function SetVirtualBorder(f, r, g, b)
    if not f.backdrop then return end

    f.bordertop:SetColorTexture(r, g, b)
    f.borderbottom:SetColorTexture(r, g, b)
    f.borderleft:SetColorTexture(r, g, b)
    f.borderright:SetColorTexture(r, g, b)
end

local CreateAuraTimer = function(self, elapsed)
    if self.timeLeft then
        self.elapsed = (self.elapsed or 0) + elapsed
        if self.elapsed >= 0.1 then
            if not self.first then
                self.timeLeft = self.timeLeft - self.elapsed
            else
                self.timeLeft = self.timeLeft - GetTime()
                self.first = false
            end
            if self.timeLeft > 0 then
                local time = E:FormatTime(self.timeLeft)
                self.remaining:SetText(time)
                self.remaining:SetTextColor(1, 1, 1)
            else
                self.remaining:Hide()
                self:SetScript("OnUpdate", nil)
            end
            self.elapsed = 0
        end
    end
end

local function threatColor(self, forced)
    if UnitIsPlayer(self.unit) then return end
    local combat = UnitAffectingCombat("player")
    local _, threatStatus = UnitDetailedThreatSituation("player", self.unit)

    if cfg.enhance_threat ~= true then
        SetVirtualBorder(self.Health, unpack(C.media.border_color))
    end
    if UnitIsTapDenied(self.unit) then
        self.Health:SetStatusBarColor(0.6, 0.6, 0.6)
    elseif combat then
        if threatStatus == 3 then
            -- securely tanking, highest threat
            if E.role == "Tank" then
                if cfg.enhance_threat == true then
                    self.Health:SetStatusBarColor(unpack(cfg.good_color))
                else
                    SetVirtualBorder(self.Health, unpack(cfg.bad_color))
                end
            else
                if cfg.enhance_threat == true then
                    self.Health:SetStatusBarColor(unpack(cfg.bad_color))
                else
                    SetVirtualBorder(self.Health, unpack(cfg.bad_color))
                end
            end
        elseif threatStatus == 2 then
            -- insecurely tanking, another unit have higher threat but not tanking
            if cfg.enhance_threat == true then
                self.Health:SetStatusBarColor(unpack(cfg.near_color))
            else
                SetVirtualBorder(self.Health, unpack(cfg.near_color))
            end
        elseif threatStatus == 1 then
            -- not tanking, higher threat than tank
            if cfg.enhance_threat == true then
                self.Health:SetStatusBarColor(unpack(cfg.near_color))
            else
                SetVirtualBorder(self.Health, unpack(cfg.near_color))
            end
        elseif threatStatus == 0 then
            -- not tanking, lower threat than tank
            if cfg.enhance_threat == true then
                if E.role == "Tank" then
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

local function UpdateTarget(self)
    if UnitIsUnit(self.unit, "target") and not UnitIsUnit(self.unit, "player") then
        self:SetSize((cfg.width + cfg.ad_width) * E.noscalemult, (cfg.height + cfg.ad_height) * E.noscalemult)
        self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8 - ((cfg.height + cfg.ad_height) * E.noscalemult))
        self.Castbar.Icon:SetSize(((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8, ((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8)
        if cfg.class_icons == true then
            self.Class.Icon:SetSize(((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8, ((cfg.height + cfg.ad_height) * 2 * E.noscalemult) + 8)
        end

        self:SetAlpha(1)
        self.arrow:Show()
    else
        self:SetSize(cfg.width * E.noscalemult, cfg.height * E.noscalemult)
        self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMLEFT", 0, -8 - (cfg.height * E.noscalemult))
        self.Castbar.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        if cfg.class_icons == true then
            self.Class.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        end
        if UnitExists("target") and not UnitIsUnit(self.unit, "player") then
            self:SetAlpha(0.5)
        else
            self:SetAlpha(1)
        end

        self.arrow:Hide()
    end

    self.Health.border:SetSize(256 * self.Health:GetWidth() / 198, 64 * self.Health:GetHeight() / 12)
end

local function UpdateName(self)
    if cfg.healer_icon == true then
        local name = UnitName(self.unit)
        if name then
            if testing then
                self.HPHeal:Show()
            else
                if healList[name] then
                    if exClass[healList[name]] then
                        self.HPHeal:Hide()
                    else
                        self.HPHeal:Show()
                    end
                else
                    self.HPHeal:Hide()
                end
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
            self.Level:SetPoint("RIGHT", self.Name, "LEFT", -8, 0)
        else
            self.Class.Icon:SetTexCoord(0, 0, 0, 0)
            self.Class:Hide()
            self.Level:SetPoint("RIGHT", self.Health, "LEFT", -8, 0)
        end
    end

    if cfg.totem_icons == true then
        local name = UnitName(self.unit)
        if name then
            if totemData[name] then
                self.Totem.Icon:SetTexture(totemData[name])
                self.Totem.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                self.Totem:Show()
            else
                self.Totem:Hide()
            end
        end
    end
end

-- Quest progress
local isInInstance
local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function frame:PLAYER_ENTERING_WORLD()
    CheckInstanceStatus()
end

local function questIconCheck()
    CheckInstanceStatus()
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
end

local isInGroup = IsInGroup()
local scanTip = CreateFrame("GameTooltip", "DarkUI_ScanTooltip", nil, "GameTooltipTemplate")
local function updateQuestUnit(self)
    if not cfg.quest then return end
    
	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = self.unit

	local isLootQuest, questProgress
	scanTip:SetOwner(UIParent, "ANCHOR_NONE")
    scanTip:SetUnit(unit)
	for i = 2, scanTip:NumLines() do
		local textLine = _G["DarkUI_ScanTooltipTextLeft"..i]
        local text = textLine:GetText()
		if textLine and text then
			local r, g, b = textLine:GetTextColor()
			if r > .99 and g > .82 and b == 0 then
				if isInGroup and text == E.name or not isInGroup then
					isLootQuest = true

					local questLine = _G["DarkUI_ScanTooltipTextLeft"..(i+1)]
					local questText = questLine:GetText()
					if questLine and questText then
						local current, goal = strmatch(questText, "(%d+)/(%d+)")
						local progress = strmatch(questText, "(%d+)%%")
						if current and goal then
							current = tonumber(current)
							goal = tonumber(goal)
							if current == goal then
								isLootQuest = nil
							elseif current < goal then
								questProgress = goal - current
								break
							end
						elseif progress then
							progress = tonumber(progress)
							if progress == 100 then
								isLootQuest = nil
							elseif progress < 100 then
								questProgress = progress.."%"
								--break -- lower priority on progress
							end
						end
					end
				end
			end
		end
	end

	if questProgress then
		self.questCount:SetText(questProgress)
		self.questIcon:SetAtlas("Warfronts-BaseMapIcons-Horde-Barracks-Minimap")
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas("adventureguide-microbutton-alert")
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

local function castColor(self, ...)
    if self.notInterruptible then
        self:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        self.bg:SetColorTexture(0.5, 0.5, 0.5, 0.2)
    else
        self:SetStatusBarColor(27 / 255, 147 / 255, 226 / 255)
        self.bg:SetColorTexture(27 / 255, 147 / 255, 226 / 255, 0.2)
    end
end

local function callback(self, _, unit)
    if not self then return end
    if unit then
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
        end

        updateQuestUnit(self)
    end
end

local function style(self, unit)
    local nameplate = C_NamePlate_GetNamePlateForUnit(unit)
    local main = self
    self.unit = unit

    self:SetSize(cfg.width, cfg.height)
    self:SetPoint("CENTER", nameplate, "CENTER")

    -- arrow
    self.arrow = self:CreateTexture("$parent_Arrow", "OVERLAY")
    self.arrow:SetSize(50, 50)
    self.arrow:SetTexture(C.media.nameplate.arrow)
    self.arrow:SetPoint("BOTTOM", self, "TOP", 0, ((cfg.track_auras or cfg.track_buffs) and cfg.auras_size or 0) + 14)
    self.arrow:Hide()

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

    self.Health.bg = self.Health:CreateTexture(nil, "BACKGROUND")
    self.Health.bg:SetAllPoints()
    self.Health.bg:SetAlpha(.6)
    self.Health.bg:SetTexture(C.media.texture.status)
    self.Health.bg.multiplier = 0.2

    self.Health.border = self.Health:CreateTexture(nil, "BORDER")
    self.Health.border:SetTexture(bar_border)
    self.Health.border:SetPoint("CENTER")

    -- Create Health Text
    if cfg.health_value == true then
        self.Health.value = self.Health:CreateFontString(nil, "OVERLAY")
        self.Health.value:SetFont(STANDARD_TEXT_FONT, 10, "THINOUTLINE")
        self.Health.value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
        self:Tag(self.Health.value, "[dd:nameplateHealth]")
    end

    -- Create Player Power bar
    self.Power = CreateFrame("StatusBar", nil, self)
    self.Power:SetStatusBarTexture(C.media.texture.status)
    self.Power:ClearAllPoints()
    self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
    self.Power:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -6 - (cfg.height * E.noscalemult / 2))
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.PostUpdate = DUF.PreUpdatePower
    self.Power:CreateShadow()

    self.Power.bg = self.Power:CreateTexture(nil, "BORDER")
    self.Power.bg:SetAllPoints()
    self.Power.bg:SetTexture(C.media.texture.status)
    self.Power.bg.multiplier = 0.2

    -- Hide Blizzard Power Bar and changed position for Class Bar
    hooksecurefunc(_G.NamePlateDriverFrame, "SetupClassNameplateBars", function(f)
        if f.classNamePlateMechanicFrame then
            local point, _, relativePoint, xOfs = f.classNamePlateMechanicFrame:GetPoint()
            if point then
                if point == "TOP" and C_NamePlate_GetNamePlateForUnit("player") then
                    f.classNamePlateMechanicFrame:SetPoint(point, C_NamePlate_GetNamePlateForUnit("player"), relativePoint, xOfs, 53)
                else
                    f.classNamePlateMechanicFrame:SetPoint(point, C_NamePlate_GetNamePlateForUnit("target"), relativePoint, xOfs, -5)
                end
            end
        end
        if f.classNamePlatePowerBar then
            f.classNamePlatePowerBar:Hide()
            f.classNamePlatePowerBar:UnregisterAllEvents()
        end
    end)

    -- Create Name Text
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetFont(unpack(C.media.standard_font))
    self.Name:SetPoint("BOTTOMLEFT", self, "TOPLEFT", -3, 4)
    self.Name:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 3, 4)

    if cfg.name_abbrev == true then
        self:Tag(self.Name, "[dd:nameplateNameColor][dd:nameLongAbbrev]")
    else
        self:Tag(self.Name, "[dd:nameplateNameColor][dd:nameLong]")
    end

    -- Create Level
    self.Level = self:CreateFontString(nil, "OVERLAY")
    self.Level:SetFont(unpack(C.media.standard_font))
    self.Level:SetPoint("RIGHT", self.Health, "LEFT", -8, 0)
    self:Tag(self.Level, "[dd:difficulty][level]")

    -- Create Cast Bar
    self.Castbar = CreateFrame("StatusBar", nil, self)
    self.Castbar:SetFrameLevel(3)
    self.Castbar:SetStatusBarTexture(C.media.texture.status)
    self.Castbar:SetStatusBarColor(1, 0.8, 0)
    self.Castbar:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -8)
    self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 0, -8 - (cfg.height * E.noscalemult))
    self.Castbar:CreateShadow()

    self.Castbar.bg = self.Castbar:CreateTexture(nil, "BORDER")
    self.Castbar.bg:SetAllPoints()
    self.Castbar.bg:SetTexture(C.media.texture.status_bg)
    self.Castbar.bg:SetColorTexture(1, 0.8, 0, 0.2)

    self.Castbar.PostCastStart = castColor
    self.Castbar.PostChannelStart = castColor
    self.Castbar.PostCastNotInterruptible = castColor
    self.Castbar.PostCastInterruptible = castColor

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
    self.Castbar.Icon = self.Castbar:CreateTexture(nil, "OVERLAY")
    self.Castbar.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    self.Castbar.Icon:SetDrawLayer("ARTWORK")
    self.Castbar.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
    self.Castbar.Icon:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 8, 0)

    self.Castbar.Icon.border = self.Castbar:CreateTexture(nil, "BORDER")
    self.Castbar.Icon.border:SetTexture(C.media.texture.border)
    self.Castbar.Icon.border:SetPoint("TOPLEFT", self.Castbar.Icon, "TOPLEFT", -6, 6)
    self.Castbar.Icon.border:SetPoint("BOTTOMRIGHT", self.Castbar.Icon, "BOTTOMRIGHT", 6, -6)

    -- Raid Icon
    self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY", nil, 7)
    self.RaidTargetIndicator:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
    self.RaidTargetIndicator:SetPoint("BOTTOM", self.Health, "TOP", 0, cfg.track_auras == true and 38 or 16)

    -- Create Class Icon
    if cfg.class_icons == true then
        self.Class = CreateFrame("Frame", nil, self)
        self.Class.Icon = self.Class:CreateTexture(nil, "OVERLAY")
        self.Class.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        self.Class.Icon:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", -8, 0)
        self.Class.Icon:SetTexture("Interface\\WorldStateFrame\\Icons-Classes")
        self.Class.Icon:SetTexCoord(0, 0, 0, 0)
    end

    -- Create Totem Icon
    if cfg.totem_icons == true then
        self.Totem = CreateFrame("Frame", nil, self)
        self.Totem.Icon = self.Totem:CreateTexture(nil, "OVERLAY")
        self.Totem.Icon:SetSize((cfg.height * 2 * E.noscalemult) + 8, (cfg.height * 2 * E.noscalemult) + 8)
        self.Totem.Icon:SetPoint("BOTTOM", self.Health, "TOP", 0, 16)
    end

    -- Create Healer Icon
    if cfg.healer_icon == true then
        self.HPHeal = self.Health:CreateFontString(nil, "OVERLAY")
        self.HPHeal:SetFont(C.media.standard_font[1], 32, C.media.standard_font[2])
        self.HPHeal:SetText("|cFFD53333+|r")
        self.HPHeal:SetPoint("BOTTOM", self.Name, "TOP", 0, cfg.track_auras == true and 13 or 0)
    end

    -- Aura tracking
    if cfg.track_debuffs == true or cfg.track_buffs == true then
        self.Auras = CreateFrame("Frame", nil, self)
        self.Auras:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 2 * E.noscalemult, 16)
        self.Auras.initialAnchor = "BOTTOMRIGHT"
        self.Auras["growth-y"] = "UP"
        self.Auras["growth-x"] = "LEFT"
        self.Auras.numDebuffs = cfg.track_debuffs and 6 or 0
        self.Auras.numBuffs = cfg.track_buffs and 4 or 0
        self.Auras:SetSize(20 + cfg.width, cfg.auras_size)
        self.Auras.spacing = 2
        self.Auras.size = cfg.auras_size
        self.Auras.onlyShowPlayer = cfg.player_aura_only
        self.Auras.showStealableBuffs = cfg.show_stealable_buffs

        self.Auras.CustomFilter = function(element, unit, icon, name, texture,
                                           count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID,
                                           canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)
            if cfg.blackList[spellID] then
                return false
            elseif cfg.whiteList[spellID] then
                return true
            else
                return DUF.FilterAuras(element, unit, icon, name, texture,
                                       count, debuffType, duration, expiration, caster, isStealable, nameplateShowSelf, spellID,
                                       canApply, isBossDebuff, casterIsPlayer, nameplateShowAll, timeMod, effect1, effect2, effect3)
            end
        end

        self.Auras.PostCreateIcon = function(element, button)
            button:SetSize(cfg.auras_size, cfg.auras_size)
            button:CreateTextureBorder(1)
            button:EnableMouse(false)

            button.remaining = button:CreateFontString(nil, 'OVERLAY')
            button.remaining:SetFont(unpack(C.media.standard_font))
            button.remaining:SetPoint("CENTER", button, "CENTER", 1, 1)
            button.remaining:SetJustifyH("CENTER")

            button.cd.noCooldownCount = true

            button.icon:ClearAllPoints()
            button.icon:SetPoint("TOPLEFT", button, cfg.icon_padding, -cfg.icon_padding)
            button.icon:SetPoint("BOTTOMRIGHT", button, -cfg.icon_padding, cfg.icon_padding)
            button.icon:SetTexCoord(unpack(C.media.texCoord))

            button.count:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, 0)
            button.count:SetJustifyH("RIGHT")
            button.count:SetFont(unpack(C.media.standard_font))

            button.overlay:SetTexture(C.media.texture.border)
            button.overlay:SetTexCoord(0, 1, 0, 1)

            if cfg.show_spiral == true then
                element.disableCooldown = false
                button.cd:SetReverse(true)
                button.parent = CreateFrame("Frame", nil, button)
                button.parent:SetFrameLevel(button.cd:GetFrameLevel() + 1)
                button.count:SetParent(button.parent)
                button.remaining:SetParent(button.parent)
            else
                element.disableCooldown = true
            end
        end

        self.Auras.PostUpdateIcon = function(_, _, icon, _, _, duration, expiration, debuffType)
            if duration and duration > 0 and cfg.show_timers then
                icon.remaining:Show()
                icon.timeLeft = expiration
                icon:SetScript("OnUpdate", CreateAuraTimer)
            else
                icon.remaining:Hide()
                icon.timeLeft = huge
                icon:SetScript("OnUpdate", nil)
            end

            local color = DebuffTypeColor[debuffType] or DebuffTypeColor.none
            if cfg.colorBorder then
                icon.overlay:SetVertexColor(color.r, color.g, color.b)
            else
                icon.overlay:SetVertexColor(0, 0, 0)
            end

            icon.first = true
        end
    end

    self.Health:RegisterEvent("PLAYER_REGEN_DISABLED")
    self.Health:RegisterEvent("PLAYER_REGEN_ENABLED")
    self.Health:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
    self.Health:RegisterEvent("UNIT_THREAT_LIST_UPDATE")

    self.Health:SetScript("OnEvent", function(_, _) threatColor(main) end)

    self.Health.PostUpdate = function(self, unit, min, max)
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

        if UnitIsPlayer(unit) then
            if perc <= 0.5 and perc >= 0.2 then
                SetVirtualBorder(self, 1, 1, 0)
            elseif perc < 0.2 then
                SetVirtualBorder(self, 1, 0, 0)
            else
                SetVirtualBorder(self, unpack(C.media.border_color))
            end
        elseif not UnitIsPlayer(unit) and cfg.enhance_threat == true then
            SetVirtualBorder(self, unpack(C.media.border_color))
        end

        threatColor(main, true)
    end

    self.NazjatarFollowerXP = CreateFrame("StatusBar", nil, self)
    self.NazjatarFollowerXP:SetSize(cfg.width * .75, cfg.height)
    self.NazjatarFollowerXP:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -5)
    self.NazjatarFollowerXP:SetStatusBarTexture(C.media.texture.status_s)
    self.NazjatarFollowerXP:SetStatusBarColor(0, .7, 1)
    self.NazjatarFollowerXP:CreateShadow(2)
    self.NazjatarFollowerXP.BG = self.NazjatarFollowerXP:CreateTexture(nil, "BACKGROUND")
    self.NazjatarFollowerXP.BG:SetAllPoints()
    self.NazjatarFollowerXP.BG:SetTexture(C.media.texture.status_s)
    self.NazjatarFollowerXP.BG:SetVertexColor(0, 0, 0, .5)
    self.NazjatarFollowerXP.progressText = DUF.CreateFont(self.NazjatarFollowerXP, STANDARD_TEXT_FONT, 9, "OUTLINE")

    if cfg.quest then 
        local qicon = self:CreateTexture(nil, "OVERLAY", nil, 2)
        qicon:SetPoint("LEFT", self.Name, "RIGHT", 5, 0)
        qicon:SetSize(28, 28)
        qicon:SetAtlas("Warfronts-BaseMapIcons-Horde-Barracks-Minimap")
        qicon:Hide()
        local count = self:CreateFontString(nil, "OVERLAY")
        count:SetFont(unpack(C.media.standard_font))
        count:SetPoint("LEFT", qicon, "RIGHT", -5, 0)
        count:SetTextColor(.6, .8, 1)

        self.questIcon = qicon
        self.questCount = count
        self:RegisterEvent("QUEST_LOG_UPDATE", updateQuestUnit, true)
    end

    -- Every event should be register with this
    tinsert(self.__elements, UpdateName)
    self:RegisterEvent("UNIT_NAME_UPDATE", UpdateName)

    tinsert(self.__elements, UpdateTarget)
    self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateTarget, true)
    -- Disable movement
    self.disableMovement = true
end

oUF:RegisterStyle("DarkUI:Nameplates", style)
oUF:SetActiveStyle("DarkUI:Nameplates")
oUF:SpawnNamePlates("DarkUI:Nameplates", callback)
