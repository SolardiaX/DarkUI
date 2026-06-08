local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Core Methods of UnitFrame
------------------------------------------------------------------------
local module = E:Module("Unitframe")

local UnitIsFriend, UnitIsPlayer, UnitIsUnit = UnitIsFriend, UnitIsPlayer, UnitIsUnit
local UnitIsDeadOrGhost, UnitIsConnected = UnitIsDeadOrGhost, UnitIsConnected
local IsPlayerSpell = IsPlayerSpell
local IsInRaid = IsInRaid
local select, pairs, ipairs, unpack, tinsert = select, pairs, ipairs, unpack, table.insert

local CastbarCompleteColor = {.1, .8, 0}
local CastbarFailColor = {1, .1, 0}

local channelingTicks = {
    [740] = 4,        -- 宁静
    [755] = 5,        -- 生命通道
    [5143] = 4,       -- 奥术飞弹
    [12051] = 6,      -- 唤醒
    [15407] = 6,      -- 精神鞭笞
    [47757] = 3,      -- 苦修
    [47758] = 3,      -- 苦修
    [48045] = 6,      -- 精神灼烧
    [64843] = 4,      -- 神圣赞美诗
    [198013] = 10,    -- 眼棱
    [198590] = 5,     -- 吸取灵魂
    [205021] = 5,     -- 冰霜射线
    [205065] = 6,     -- 虚空洪流
    [206931] = 3,     -- 饮血者
    [212084] = 10,    -- 邪能毁灭
    [234153] = 5,     -- 吸取生命
    [257044] = 7,     -- 急速射击
    [291944] = 6,     -- 再生，赞达拉巨魔
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
            ticks[i]:SetPoint("RIGHT", Castbar, "LEFT", delta * i, 0)
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
    Castbar:SetValue(1)

    if Castbar.enableFader then
        Castbar:FadeOut()
    end
end

function module:PostCastStop(unit, spellname, _)
    local Castbar = self

    Castbar:SetStatusBarColor(unpack(CastbarCompleteColor))
    Castbar:SetValue(1)

    if Castbar.enableFader then
        Castbar:FadeOut()
    end
end

function module:PostCastInterruptible(unit)
    local Castbar = self

    updateCastbarColor(Castbar, unit)
end

------------------------------------------------------------------
--  Empower Pips (for Evoker and similar)                       --
------------------------------------------------------------------
local PipColors = {
    [1] = { .08, 1, 0, .5 },
    [2] = { 1, .1, .1, .5 },
    [3] = { 1, .5, 0, .5 },
    [4] = { .1, .7, .7, .5 },
    [5] = { 0, 1, 1, .5 },
    [6] = { 0, .5, 1, .5 },
}

function module:CreatePip(stage)
    local _, height = self:GetSize()
    local pip = CreateFrame("Frame", nil, self, "CastingBarFrameStagePipTemplate")
    pip.BasePip:SetTexture(C.media.texture.status)
    pip.BasePip:SetVertexColor(0, 0, 0)
    pip.BasePip:SetWidth(E.mult)
    pip.BasePip:SetHeight(height)
    pip.tex = pip:CreateTexture(nil, "ARTWORK", nil, 2)
    pip.tex:SetTexture(C.media.texture.status)
    pip.tex:SetVertexColor(unpack(PipColors[stage] or PipColors[1]))
    return pip
end

function module:PostUpdatePips(numStages)
    if not numStages then return end
    local pips = self.Pips
    local num = #numStages
    for stage = 1, num do
        local pip = pips[stage]
        if stage == num then
            local firstPip = pips[1]
            local anchor = pips[num]
            firstPip.tex:SetPoint("BOTTOMRIGHT", self)
            firstPip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
        end
        if stage ~= 1 then
            local anchor = pips[stage - 1]
            pip.tex:SetPoint("BOTTOMRIGHT", pip.BasePip, "BOTTOMLEFT")
            pip.tex:SetPoint("TOPLEFT", anchor.BasePip, "TOPRIGHT")
        end
    end
end

------------------------------------------------------------------
--  Methods for icon                                            --
------------------------------------------------------------------
function module.PostCreateButton(element, button)
    button:CreateOverlay()
    button:CreateShadow()

    button.Icon:SetTexCoord(unpack(C.media.texCoord))
    button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 2, -2)
    button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -2, 2)
    button.Icon:SetDrawLayer("BACKGROUND", -8)

    button.Overlay:SetTexture(nil)
    button.Stealable:SetAtlas("bags-newitem")
end

function module.PostUpdateGapButton(element, unit, button, position)
    if button.__overlay then button.__overlay:Hide() end
    if button.__shadow then button.__shadow:Hide() end
end

function module.PostUpdateButton(element, button, unit, data, position)
    if button.__overlay then button.__overlay:Show() end
    if button.__shadow then button.__shadow:Show() end

    button.__shadow:SetBackdropBorderColor(unpack(C.media.shadow_color))
    button.Icon:SetDesaturated(false)

    if data.isHarmfulAura then
        if not UnitIsFriend("player", unit) and not data.isPlayerAura then
            button.Icon:SetDesaturated(true)
        elseif element.dispelColorCurve then
            local color = C_UnitAuras.GetAuraDispelTypeColor(unit, data.auraInstanceID, element.dispelColorCurve)
            if color then
                button.__shadow:SetBackdropBorderColor(color:GetRGBA())
            end
        end
    else
        if type(data.dispelName) ~= "nil" and not UnitIsFriend("player", unit) then
            button.__shadow:SetBackdropBorderColor(1, 0.85, 0)
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
    local spellId = data.spellId

    if IsInRaid(LE_PARTY_CATEGORY_HOME) then
        local auraList = C.aura.raidbuffs[E.myClass]
        if (auraList and auraList[spellId] and data.isPlayerAura) or C.aura.raidbuffs["ALL"][spellId] then
            return true
        end
    elseif self.showStealableBuffs and type(data.dispelName) ~= "nil" and not UnitIsPlayer(unit) then
        return true
    elseif self.onlyShowPlayer and data.isPlayerAura then
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
