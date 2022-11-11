local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Core Methods of UnitFrame
----------------------------------------------------------------------------------------

local _G = _G
local GetSpellInfo, GetCombatRatingBonus = GetSpellInfo, GetCombatRatingBonus
local UnitClass, UnitCastingInfo = UnitClass, UnitCastingInfo
local UnitAura = UnitAura
local UnitIsFriend, UnitIsPlayer = UnitIsFriend, UnitIsPlayer
local UnitIsDeadOrGhost, UnitIsConnected = UnitIsDeadOrGhost, UnitIsConnected
local IsSpellKnown = IsSpellKnown
local IsInRaid = IsInRaid
local select, pairs, ipairs, unpack, tinsert = select, pairs, ipairs, unpack, table.insert
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local CR_HASTE_SPELL = CR_HASTE_SPELL
local FAILED = FAILED
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local DebuffTypeColor = DebuffTypeColor

local ignorePetSpells = {
    115746, -- Felbolt  (Green Imp)
    3110, -- firebolt (imp)
    31707, -- waterbolt (water elemental)
    85692, -- Doom Bolt
}

local DUF = {}

------------------------------------------------------------------
--  enter ui test mode       --
------------------------------------------------------------------
SlashCmdList["TESTUI"] = function()
    for _, frames in pairs({ "DarkUITargetFrame", "DarkUIToTFrame", "DarkUIPetFrame", "DarkUIFocusFrame", "DarkUIFocusTargetFrame" }) do
        _G[frames].oldunit = _G[frames].unit
        _G[frames]:SetAttribute("unit", "player")
    end

    for i = 1, MAX_BOSS_FRAMES do
        _G["DarkUIBossFrame" .. i].oldunit = _G["DarkUIBossFrame" .. i].unit
        _G["DarkUIBossFrame" .. i]:SetAttribute("unit", "player")
    end
end

SLASH_TESTUI1 = "/testui"

------------------------------------------------------------------
--  Channeling ticks, based on Castbars by Xbeeps       --
------------------------------------------------------------------
local CastingBarFrameTicksSet
do
    local _, class = UnitClass("player")

    -- Negative means not modified by haste
    local BaseTickDuration = { }
    if class == "WARLOCK" then
        BaseTickDuration[GetSpellInfo(689) or ""] = 1 -- Drain Life
        BaseTickDuration[GetSpellInfo(1120) or ""] = 2 -- Drain Soul
        BaseTickDuration[GetSpellInfo(755) or ""] = 1 -- Health Funnel
        BaseTickDuration[GetSpellInfo(5740) or ""] = 2 -- Rain of Fire
        BaseTickDuration[GetSpellInfo(1949) or ""] = 1 -- Hellfire
        BaseTickDuration[GetSpellInfo(103103) or ""] = 1 -- Malefic Grasp
        BaseTickDuration[GetSpellInfo(108371) or ""] = 1 -- Harvest Life
    elseif class == "DRUID" then
        BaseTickDuration[GetSpellInfo(740) or ""] = 2 -- Tranquility
        BaseTickDuration[GetSpellInfo(16914) or ""] = 1 -- Hurricane
        BaseTickDuration[GetSpellInfo(106996) or ""] = 1 -- Astral STORM
        BaseTickDuration[GetSpellInfo(127663) or ""] = -1 -- Astral Communion
    elseif class == "PRIEST" then
        local mind_flay_TickTime = 1
        if IsSpellKnown(157223) then
            --Enhanced Mind Flay
            mind_flay_TickTime = 2 / 3
        end
        BaseTickDuration[GetSpellInfo(47540) or ""] = 1 -- Penance
        BaseTickDuration[GetSpellInfo(15407) or ""] = mind_flay_TickTime -- Mind Flay
        BaseTickDuration[GetSpellInfo(129197) or ""] = mind_flay_TickTime -- Mind Flay (Insanity)
        BaseTickDuration[GetSpellInfo(48045) or ""] = 1 -- Mind Sear
        BaseTickDuration[GetSpellInfo(179337) or ""] = 1 -- Searing Insanity
        BaseTickDuration[GetSpellInfo(64843) or ""] = 2 -- Divine Hymn
        BaseTickDuration[GetSpellInfo(64901) or ""] = 2 -- Hymn of Hope
    elseif class == "MAGE" then
        BaseTickDuration[GetSpellInfo(10) or ""] = 1 -- Blizzard
        BaseTickDuration[GetSpellInfo(5143) or ""] = 0.4 -- Arcane Missiles
        BaseTickDuration[GetSpellInfo(12051) or ""] = 2 -- Evocation
    elseif class == "MONK" then
        BaseTickDuration[GetSpellInfo(117952) or ""] = 1 -- Crackling Jade Lightning
        BaseTickDuration[GetSpellInfo(115175) or ""] = 1 -- Soothing Mist
        BaseTickDuration[GetSpellInfo(113656) or ""] = 1 -- Fists of Fury
        BaseTickDuration[GetSpellInfo(115294) or ""] = -1 -- Mana Tea
    end

    function CastingBarFrameTicksSet(Castbar, _, name, stop)
        Castbar.ticks = Castbar.ticks or {}
        local function CreateATick()
            local spark = Castbar:CreateTexture(nil, 'OVERLAY', nil, 1)
            spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
            spark:SetVertexColor(1, 1, 1, 1)
            spark:SetBlendMode('ADD')
            spark:SetWidth(10)
            tinsert(Castbar.ticks, spark)
            return spark
        end
        for _, tick in ipairs(Castbar.ticks) do
            tick:Hide()
        end
        if (stop) then return end
        if (Castbar) then
            local baseTickDuration = BaseTickDuration[name]
            local tickDuration
            if (baseTickDuration) then
                if (baseTickDuration > 0) then
                    local castTime = select(7, GetSpellInfo(2060))
                    if (not castTime or (castTime == 0)) then
                        castTime = 2500 / (1 + (GetCombatRatingBonus(CR_HASTE_SPELL) or 0) / 100)
                    end
                    tickDuration = (castTime / 2500) * baseTickDuration
                else
                    tickDuration = -baseTickDuration
                end
            end
            if (tickDuration) then
                local width = Castbar:GetWidth()
                local delta = (tickDuration * width / Castbar.max)
                local i = 1
                while (delta * i) < width do
                    if i > #Castbar.ticks then CreateATick() end
                    local tick = Castbar.ticks[i]
                    tick:SetHeight(Castbar:GetHeight() * 1.5)
                    tick:SetPoint("CENTER", Castbar, "LEFT", delta * i, 0)
                    tick:Show()
                    i = i + 1
                end
            end
        end
    end
end

function DUF.FilterAuras(element, unit, icon, name, _, _, _, _, _, caster, isStealable, _, spellID, _, isBossDebuff, _, _)
    local isPlayer
    local isInRaid = IsInRaid(LE_PARTY_CATEGORY_HOME)

    if (caster == 'player' or caster == 'vehicle') then
        isPlayer = true
    end

    if isInRaid == "raid" then
        local auraList = C.aura.raidbuffs[E.class]
        if auraList and auraList[spellID] and icon.isPlayer then
            return true
        elseif C.aura.raidbuffs["ALL"][spellID] then
            return true
        end
    elseif element.showStealableBuffs and isStealable and not UnitIsPlayer(unit) then
        return true
    elseif (element.onlyShowPlayer and isPlayer) or (not element.onlyShowPlayer and name) or isBossDebuff then
        icon.isPlayer = isPlayer
        icon.owner = caster
        return true
    end

    return false
end

function DUF.PostCastStart(Castbar, unit, _, _)
    if (unit == 'pet') then
        Castbar:SetAlpha(1)
        for _, spellID in pairs(ignorePetSpells) do
            if (UnitCastingInfo('pet') == GetSpellInfo(spellID)) then
                Castbar:SetAlpha(0)
            end
        end
    end
    DUF.UpdateCastbarColor(Castbar, unit)
    if (Castbar.SafeZone) then
        Castbar.SafeZone:SetDrawLayer("BORDER")
    end
end

function DUF.PostCastFailed(Castbar, ...)
    if (Castbar.Text) then
        Castbar.Text:SetText(FAILED)
    end
    Castbar:SetStatusBarColor(1, 0, 0) -- Red
    if (Castbar.max) then
        Castbar:SetValue(Castbar.max)
    end
end

function DUF.PostCastInterrupted(Castbar, ...)
    --Castbar:SetStatusBarColor(1, 0, 0)
    if (Castbar.max) then
        -- Some spells got trough without castbar
        Castbar:SetValue(Castbar.max)
    end
end

function DUF.PostStop(Castbar, unit, spellname, _)
    --Castbar:SetValue(Castbar.max)
    if (Castbar.Ticks) then
        CastingBarFrameTicksSet(Castbar, unit, spellname, true)
    end
end

function DUF.PostChannelStart(Castbar, unit, name)
    if (unit == 'pet' and Castbar:GetAlpha() == 0) then
        Castbar:SetAlpha(1)
    end

    DUF.UpdateCastbarColor(Castbar, unit)
    if Castbar.SafeZone then
        Castbar.SafeZone:SetDrawLayer("BORDER", 1)
    end
    if (Castbar.Ticks) then
        CastingBarFrameTicksSet(Castbar, unit, name)
    end
end

function DUF.UpdateCastbarColor(Castbar, _)
    if Castbar.Shield:IsShown() then
        --show shield
        Castbar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        Castbar.Spark:SetVertexColor(0.8, 0.8, 0.8, 1)
    else
        --no shield
        Castbar:SetStatusBarColor(27 / 255, 147 / 255, 226 / 255)
        Castbar.Spark:SetVertexColor(0.8, 0.6, 0, 1)
    end
end

function DUF.CreateFont(parent, fontname, fontHeight, fontStyle)
    local fontStr = parent:CreateFontString(nil, 'OVERLAY')
    fontStr:SetFont(fontname or STANDARD_TEXT_FONT, fontHeight or 12, fontStyle)
    fontStr:SetJustifyH('LEFT')
    fontStr:SetShadowColor(0, 0, 0)
    fontStr:SetShadowOffset(0.85, -0.85)

    return fontStr
end

function DUF.CreateIcon(f, layer, size, sublevel, anchorframe, anchorpoint1, anchorpoint2, posx, posy)
    local icon = f:CreateTexture(nil, layer, nil, sublevel)
    icon:SetSize(size, size)
    icon:SetPoint(anchorpoint1, anchorframe, anchorpoint2, posx, posy)

    return icon
end

function DUF.FlipTexture(texture)
    if (texture and texture.SetTexCoord) then
        return texture:SetTexCoord(1, 0, 0, 1)
    end
end

function DUF.PostCreateIcon(_, button)
    button.icon:SetTexCoord(unpack(C.media.texCoord))
    button.icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    button.icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button.icon:SetDrawLayer("BACKGROUND", -8)
    
    button.overlay:SetTexture(C.media.texture.border)
    button.overlay:SetTexCoord(0, 1, 0, 1)
    button.overlay:SetDrawLayer("BACKGROUND", -7)
    button.overlay:ClearAllPoints()
    button.overlay:SetAllPoints(button)
    button.overlay:SetVertexColor(0.25, 0.25, 0.25)
    
    button:CreateTextureBorder()
    button:CreateShadow()

    button.overlay.Hide = E.dummy
end

function DUF.PostUpdateIcon(icons, unit, icon, index, ...)
    local _, _, _, _, dtype, _, _, _, isStealable = UnitAura(unit, index, icon.filter)

    local playerUnits = {
        player  = true,
        pet     = true,
        vehicle = true,
    }

    if icon.debuff then
        if not UnitIsFriend("player", unit) and not playerUnits[icon.owner] then
            if icons.onlyShowPlayer then
                icon:Hide()
            else
                icon.overlay:SetVertexColor(unpack(C.media.border_color))
                icon.icon:SetDesaturated(true)
            end
        else
            local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
            icon.overlay:SetVertexColor(color.r * .6, color.g * .6, color.b * .6)
            icon.icon:SetDesaturated(false)
        end
    else
        if (isStealable or ((E.class == "MAGE" or E.class == "PRIEST" or E.class == "SHAMAN" or E.class == "HUNTER") and dtype == "Magic")) and not UnitIsFriend("player", unit) then
            icon.overlay:SetVertexColor(1, 0.85, 0)
        else
            icon.overlay:SetVertexColor(unpack(C.media.border_color))
        end
        icon.icon:SetDesaturated(false)
    end

    icon.first = true
end

function DUF.PostUpdatePower(Power, unit, _, max)
    if (UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit)) or (max == 0) then
        Power:SetValue(0)
        if Power.Value then
            Power.Value:SetText('')
        end

        return
    end

    if not Power.Value then return end
end

function DUF.SetFader(self, config)
    if config ~= nil then

        local index = 1
        for k, v in pairs(config) do
            if k == "NormalAlpha" then
                self.NormalAlpha = v
            elseif k == "Range" then
                self.Range = v
                self.outsideRangeAlphaPerc = .3
            else
                if not self.Fader then self.Fader = {} end

                self.Fader[index] = {}
                self.Fader[index][k] = v

                index = index + 1
            end
        end
    end
end

local isInInstance
local function CheckInstanceStatus()
	isInInstance = IsInInstance()
end

function DUF.QuestIconCheck()
	CheckInstanceStatus()
	E:RegisterEvent("PLAYER_ENTERING_WORLD", CheckInstanceStatus)
end

local function isQuestTitle(textLine)
	local r, g, b = textLine:GetTextColor()
	if r > .99 and g > .8 and b == 0 then
		return true
	end
end

function DUF.UpdateQuestUnit(_, unit)
	if not cfg.quest then return end

	if isInInstance then
		self.questIcon:Hide()
		self.questCount:SetText("")
		return
	end

	unit = unit or self.unit

	local startLooking, isLootQuest, questProgress -- FIXME: isLootQuest in old expansion
	E.ScanTip:SetOwner(UIParent, "ANCHOR_NONE")
	E.ScanTip:SetUnit(unit)

	for i = 2, B.ScanTip:NumLines() do
		local textLine = _G["DarkUI_ScanTooltipTextLeft"..i]
		local text = textLine and textLine:GetText()
		if not text then break end

		if text ~= " " then
			if isInGroup and text == DB.MyName or (not isInGroup and isQuestTitle(textLine)) then
				startLooking = true
			elseif startLooking then
				local current, goal = strmatch(text, "(%d+)/(%d+)")
				local progress = strmatch(text, "(%d+)%%")
				if current and goal then
					local diff = floor(goal - current)
					if diff > 0 then
						questProgress = diff
						break
					end
				elseif progress and not strmatch(text, THREAT_TOOLTIP) then
					if floor(100 - progress) > 0 then
						questProgress = progress.."%" -- lower priority on progress, keep looking
					end
				else
					break
				end
			end
		end
	end

	if questProgress then
		self.QuestsCount:SetText(questProgress)
		self.questIcon:SetAtlas(DB.objectTex)
		self.questIcon:Show()
	else
		self.questCount:SetText("")
		if isLootQuest then
			self.questIcon:SetAtlas(DB.questTex)
			self.questIcon:Show()
		else
			self.questIcon:Hide()
		end
	end
end

E.CreateAuraTimer = function(self, elapsed)
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

                if floor(self.timeLeft + 0.5) > 5 then
                    self.remaining:SetTextColor(1, 1, 1)
                else
                    self.remaining:SetTextColor(1, 0.2, 0.2)
                end
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

E.unitframe = DUF
