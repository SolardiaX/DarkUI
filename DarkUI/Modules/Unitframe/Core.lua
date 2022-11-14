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

local CastbarCompleteColor = {.1, .8, 0}
local CastbarFailColor = {1, .1, 0}

local channelingTicks = {
	[740] = 4,		-- 宁静
	[755] = 5,		-- 生命通道
	[5143] = 4, 	-- 奥术飞弹
	[12051] = 6, 	-- 唤醒
	[15407] = 6,	-- 精神鞭笞
	[47757] = 3,	-- 苦修
	[47758] = 3,	-- 苦修
	[48045] = 6,	-- 精神灼烧
	[64843] = 4,	-- 神圣赞美诗
	[120360] = 15,	-- 弹幕射击
	[198013] = 10,	-- 眼棱
	[198590] = 5,	-- 吸取灵魂
	[205021] = 5,	-- 冰霜射线
	[205065] = 6,	-- 虚空洪流
	[206931] = 3,	-- 饮血者
	[212084] = 10,	-- 邪能毁灭
	[234153] = 5,	-- 吸取生命
	[257044] = 7,	-- 急速射击
	[291944] = 6,	-- 再生，赞达拉巨魔
	[314791] = 4,	-- 变易幻能
	[324631] = 8,	-- 血肉铸造，盟约
	[356995] = 3,	-- 裂解，龙希尔
}

if E.class == "PRIEST" then
	local function updateTicks()
		local numTicks = 3
		if IsPlayerSpell(193134) then numTicks = 4 end
		channelingTicks[47757] = numTicks
		channelingTicks[47758] = numTicks
	end
	E:RegisterEvent("PLAYER_LOGIN", updateTicks)
	E:RegisterEvent("PLAYER_TALENT_UPDATE", updateTicks)
end

local DUF = {}

------------------------------------------------------------------
--  Unitframes test mode                                        --
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
--  methods for element                                         --
------------------------------------------------------------------
function DUF.FlipTexture(texture)
    if (texture and texture.SetTexCoord) then
        return texture:SetTexCoord(1, 0, 0, 1)
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

------------------------------------------------------------------
--  Methods for castbar                                         --
------------------------------------------------------------------
local function setBarTicks(Castbar, ticks, numTicks)
	for _, v in pairs(ticks) do
		v:Hide()
	end
	if numTicks and numTicks > 0 then
		local delta = Castbar:GetWidth() / numTicks
		for i = 1, numTicks do
			if not ticks[i] then
                ticks[i] = Castbar:CreateTexture(nil, 'OVERLAY')
                ticks[i]:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
                ticks[i]:SetVertexColor(1, 1, 1, 1)
                ticks[i]:SetBlendMode('ADD')
                ticks[i]:SetWidth(E.mult)
                ticks[i]:SetHeight(Castbar:GetHeight() * 1.5)
				-- ticks[i] = Castbar:CreateTexture(nil, "OVERLAY")
				-- ticks[i]:SetTexture(C.media.texture.tex_border)
				-- ticks[i]:SetVertexColor(unpack(C.media.border_color))
				-- ticks[i]:SetWidth(E.mult)
				-- ticks[i]:SetHeight(Castbar:GetHeight())
				-- ticks[i]:SetDrawLayer("OVERLAY", 7)
			end
			ticks[i]:ClearAllPoints()
			ticks[i]:SetPoint("CENTER", Castbar, "RIGHT", -delta * i, 0)
			ticks[i]:Show()
		end
	end
end

local function updateCastbarColor(Castbar, unit)
    if not UnitIsUnit(unit, "player") and Castbar.notInterruptible then
        Castbar:SetStatusBarColor(0.5, 0.5, 0.5, 1)
        Castbar.Spark:SetVertexColor(0.8, 0.8, 0.8, 1)
    else
        Castbar:SetStatusBarColor(27 / 255, 147 / 255, 226 / 255)
        Castbar.Spark:SetVertexColor(0.8, 0.6, 0, 1)
    end
end

function DUF.PostCastStart(Castbar, unit, _, _)
    if (Castbar.SafeZone) then
        Castbar.SafeZone:SetDrawLayer("BORDER")
    end

    if unit == "player" then
        local numTicks = 0
		if Castbar.channeling then
			numTicks = channelingTicks[Castbar.spellID] or 0
		end
		setBarTicks(Castbar, Castbar.castTicks, numTicks)
    end

    updateCastbarColor(Castbar, unit)
end

function DUF.PostCastFail(Castbar, ...)
    Castbar:SetStatusBarColor(unpack(CastbarFailColor))
    Castbar:SetValue(Castbar.max)
	Castbar.fadeOut = true
	Castbar:Show()
end

function DUF.PostCastStop(Castbar, unit, spellname, _)
    Castbar:SetStatusBarColor(unpack(CastbarCompleteColor))
    Castbar:SetValue(Castbar.max)
	Castbar.fadeOut = true
	Castbar:Show()
end

function DUF.PostUpdateInterruptible(Castbar, unit)
	updateCastBarColor(Castbar, unit)
end

------------------------------------------------------------------
--  Methods for icon                                            --
------------------------------------------------------------------
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

function DUF.CreateAuraTimer(self, elapsed)
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

------------------------------------------------------------------
--  Methods for powerbar                                        --
------------------------------------------------------------------
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

------------------------------------------------------------------
--  Methods for fader                                           --
------------------------------------------------------------------
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


E.unitframe = DUF
