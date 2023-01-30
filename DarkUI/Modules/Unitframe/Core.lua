local E, C, L = select(2, ...):unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Core Methods of UnitFrame
----------------------------------------------------------------------------------------
local module = E:Module("UFCore")

local _G = _G
local GetSpellInfo, GetCombatRatingBonus = GetSpellInfo, GetCombatRatingBonus
local UnitClass, UnitCastingInfo = UnitClass, UnitCastingInfo
local UnitAura = UnitAura
local UnitIsFriend, UnitIsPlayer, UnitIsUnit = UnitIsFriend, UnitIsPlayer, UnitIsUnit
local UnitIsDeadOrGhost, UnitIsConnected = UnitIsDeadOrGhost, UnitIsConnected
local IsSpellKnown, IsPlayerSpell = IsSpellKnown, IsPlayerSpell
local IsInRaid = IsInRaid
local SpellIsPriorityAura = SpellIsPriorityAura
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

module:RegisterEvent("PLAYER_LOGIN PLAYER_TALENT_UPDATE", function()
    if E.myClass == "PRIEST" then
        local numTicks = 3
        if IsPlayerSpell(193134) then numTicks = 4 end
        channelingTicks[47757] = numTicks
        channelingTicks[47758] = numTicks
    end
end)

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
function module:FlipTexture(texture)
    if (texture and texture.SetTexCoord) then
        return texture:SetTexCoord(1, 0, 0, 1)
    end
end

function module:CreateFont(parent, fontname, fontHeight, fontStyle)
    local fontStr = parent:CreateFontString(nil, 'OVERLAY')
    fontStr:SetFont(fontname or STANDARD_TEXT_FONT, fontHeight or 12, fontStyle)
    fontStr:SetJustifyH('LEFT')
    fontStr:SetShadowColor(0, 0, 0)
    fontStr:SetShadowOffset(0.85, -0.85)

    return fontStr
end

function module:CreateIcon(f, layer, size, sublevel, anchorframe, anchorpoint1, anchorpoint2, posx, posy)
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
                ticks[i] = Castbar:CreateTexture(nil, "OVERLAY")
                ticks[i]:SetTexture(C.media.path .. "uf_bartex_compact")
                ticks[i]:SetVertexColor(unpack(C.media.border_color))
                ticks[i]:SetWidth(E.mult)
                ticks[i]:SetHeight(Castbar:GetHeight())
                ticks[i]:SetDrawLayer("OVERLAY", 7)
            end
            ticks[i]:ClearAllPoints()
            ticks[i]:SetPoint("RIGHT", bar, "LEFT", delta * i, 0)
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

function module:PostCastStart(unit, _, _)
    local Castbar = self

    if Castbar.enableFader then
        Castbar:SetAlpha(1)
    end

    if Castbar.SafeZone then
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

function module:PostCastFail(...)
    local Castbar = self

    Castbar:SetStatusBarColor(unpack(CastbarFailColor))
    Castbar:SetValue(Castbar.max)

    if Castbar.enableFader then
        Castbar:FadeOut()
    end
end

function module:PostCastStop(unit, spellname, _)
    local Castbar = self

    Castbar:SetStatusBarColor(unpack(CastbarCompleteColor))
    Castbar:SetValue(Castbar.max)
    
    if Castbar.enableFader then
        Castbar:FadeOut()
    end
end

function module:PostCastInterruptible(unit)
    local Castbar = self

    updateCastbarColor(Castbar, unit)
end

------------------------------------------------------------------
--  Methods for icon                                            --
------------------------------------------------------------------
local playerUnits = {
    ["player"]  = true,
    ["pet"]     = true,
    ["vehicle"] = true,
}

function module:PostCreateIcon(button)
    E:ApplyOverlayBorder(button)

    button.Icon:SetTexCoord(unpack(C.media.texCoord))
    button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button.Icon:SetDrawLayer("BACKGROUND", -8)
    
    button.Overlay:SetTexture(nil)
	button.Stealable:SetAtlas("bags-newitem")
end

function module:PostUpdateGapIcon(unit, button, offset)
    button.border:Hide()
    button.shadow:Hide()
end

function module:PostUpdateIcon(button, unit, data)
    button.border:Show()
    button.shadow:Show()
    
    button.shadow:SetBackdropBorderColor(unpack(C.media.shadow_color))
    button.Icon:SetDesaturated(false)

    if data.isHarmful then
        if not UnitIsFriend("player", unit) and not playerUnits[data.sourceUnit] then
            button.Icon:SetDesaturated(true)
        else
            local color = DebuffTypeColor[data.dispelName] or DebuffTypeColor.none
            button.shadow:SetBackdropBorderColor(color.r * .82, color.g * .82, color.b * .82)
        end
    else
        if (data.isStealable or ((E.myClass == "MAGE" or E.myClass == "PRIEST" or E.myClass == "SHAMAN" or E.myClass == "HUNTER") and data.dispelName == "Magic")) and not UnitIsFriend("player", unit) then
            button.shadow:SetBackdropBorderColor(1, 0.85, 0)
        end
    end
end

function module.CreateAuraTimer(aura, elapsed)
    if aura.timeLeft then
        aura.elapsed = (aura.elapsed or 0) + elapsed
        if aura.elapsed >= 0.1 then
            if not aura.first then
                aura.timeLeft = aura.timeLeft - aura.elapsed
            else
                aura.timeLeft = aura.timeLeft - GetTime()
                aura.first = false
            end
            if aura.timeLeft > 0 then
                local time = E:FormatTime(aura.timeLeft)
                aura.remaining:SetText(time)

                if floor(aura.timeLeft + 0.5) > 5 then
                    aura.remaining:SetTextColor(1, 1, 1)
                else
                    aura.remaining:SetTextColor(1, 0.2, 0.2)
                end
            else
                aura.remaining:Hide()
                aura:SetScript("OnUpdate", nil)
            end
            aura.elapsed = 0
        end
    end
end

function module:FilterAuras(unit, data)
    local isInRaid = IsInRaid(LE_PARTY_CATEGORY_HOME)
    local isFromPlayer = playerUnits[data.sourceUnit]
    local spellID = data.spellId

    if isInRaid == "raid" then
        local auraList = C.aura.raidbuffs[E.myClass]
        if auraList and auraList[spellID] and data.isFromPlayerOrPlayerPet then
            return true
        elseif C.aura.raidbuffs["ALL"][spellID] then
            return true
        end
    elseif self.showStealableBuffs and data.isStealable and not UnitIsPlayer(unit) then
        return true
    elseif self.onlyShowPlayer and isFromPlayer then
        return true
    elseif data.isBossAura or SpellIsPriorityAura(spellID) then
        return true
    elseif not self.onlyShowPlayer and data.name then
        return true
    end

    return false
end

------------------------------------------------------------------
--  Methods for powerbar                                        --
------------------------------------------------------------------
function module:PostUpdatePower(Power, unit, _, max)
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
function module:SetFader(f, config)
    if config ~= nil then

        local index = 1
        for k, v in pairs(config) do
            if k == "NormalAlpha" then
                f.NormalAlpha = v
            elseif k == "Range" then
                f.Range = v
                f.outsideRangeAlphaPerc = .3
            else
                if not f.Fader then f.Fader = {} end

                f.Fader[index] = {}
                f.Fader[index][k] = v

                index = index + 1
            end
        end
    end
end
