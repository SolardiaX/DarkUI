local E, C, L = select(2, ...):unpack()

if not C.aura.enable then return end

----------------------------------------------------------------------------------------
--	Aura styles (modified from NDui)
----------------------------------------------------------------------------------------
local module = E:Module("Aura"):Sub("Auras")

local cfg = C.aura
local oUF = select(2, ...).oUF

local _G = _G
local GetTime = GetTime
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local GameTooltip, GameTooltip_Hide = GameTooltip, GameTooltip_Hide
local GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo = GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo
local RegisterAttributeDriver = RegisterAttributeDriver
local RegisterStateDriver = RegisterStateDriver
local SecureHandlerSetFrameRef = SecureHandlerSetFrameRef
local CreateFrame = CreateFrame
local format, floor, strmatch, select, unpack, tonumber = format, floor, strmatch, select, unpack, tonumber

local function startOrStopFlash(animation, timeleft)
    if(timeleft < cfg.flash_timer) then
        if(not animation:IsPlaying()) then
            animation:Play()
        end
    elseif(animation:IsPlaying()) then
        animation:Stop()
    end
end

local day, hour, minute = 86400, 3600, 60
local function formatAuraTime(s)
	if s >= day then
		return E:FormatTime(s, true), s%day
	elseif s >= 2*hour then
		return E:FormatTime(s, true), s%hour
	elseif s >= 10*minute then
		return E:FormatTime(s, true), s%minute
	elseif s >= minute then
		return E:FormatTime(s, true), s - floor(s)
	elseif s > 10 then
		return E:FormatTime(s, true), s - floor(s)
	elseif s > 5 then
		return E:FormatTime(s, true), s - format("%.1f", s)
	else
		return E:FormatTime(s, true), s - format("%.1f", s)
	end
end

local function getSpellStat(arg16, arg17, arg18)
    return (arg16 > 0 and L.AURA_VERSA) or (arg17 > 0 and L.AURA_MASTERY) or (arg18 > 0 and L.AURA_HASTE) or L.AURA_CRIT
end

local Button_SetTooltip = function(button)
    if button:GetAttribute("index") then
        GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
    elseif button:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", button:GetID())
    end
end

local Button_UpdateTimer = function(button, elapsed)
    local onTooltip = GameTooltip:IsOwned(button)

    if not (button.timeLeft or button.expiration or onTooltip) then
        button:SetScript("OnUpdate", nil)
        return
    end

    if button.expiration then
        button.timeLeft = button.expiration / 1e3
    elseif button.timeLeft then
        button.timeLeft = button.timeLeft - elapsed
    end

    if button.nextUpdate > 0 then
        button.nextUpdate = button.nextUpdate - elapsed
        return
    end

    if button.timeLeft and button.timeLeft >= 0 then
        local timer, nextUpdate = formatAuraTime(button.timeLeft)
        button.nextUpdate = nextUpdate
        button.timer:SetText(timer)
    end

    if onTooltip then Button_SetTooltip(button) end
end

local Button_OnAttributeChanged = function(button, attribute, value)
    if attribute == "index" then
        module:UpdateAuras(button, value)
    elseif attribute == "target-slot" then
        module:UpdateTempEnchant(button, value)
    end
end

local Button_OnEnter = function(button)
    GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT", -5, -5)
    -- Update tooltip
    button.nextUpdate = -1
    button:SetScript("OnUpdate", Button_UpdateTimer)
end

module.BuildBuffFrame = function(self)
    self.BuffFrame = self:CreateAuraHeader("HELPFUL")
    self.BuffFrame:ClearAllPoints()
    self.BuffFrame:SetPoint(unpack(cfg.buff_pos))

    self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
    self.DebuffFrame:ClearAllPoints()
    self.DebuffFrame:SetPoint(unpack(cfg.debuff_pos))
end

module.UpdateAuras = function(self, button, index)
    local unit, filter = button.header:GetAttribute("unit"), button.filter
    local auraData = C_UnitAuras_GetAuraDataByIndex(unit, index, filter)

    if not auraData then return end

    if auraData.duration > 0 and auraData.expirationTime then
        local timeLeft = auraData.expirationTime - GetTime()
        if not button.timeLeft then
            button.nextUpdate = -1
            button.timeLeft = timeLeft
            button:SetScript("OnUpdate", Button_UpdateTimer)
        else
            button.timeLeft = timeLeft
        end
        button.nextUpdate = -1
        Button_UpdateTimer(button, 0)

        if cfg.enable_flash and timeLeft then
            startOrStopFlash(button.animation, timeLeft)
        end

        if timeLeft and (auraData.duration == ceil(timeLeft)) and (cfg.enable_animation and button.auraGrowth) then
            button.auraGrowth:Play()
        end
    else
        button.timeLeft = nil
        button.timer:SetText("")

        if cfg.enable_flash then
            button.animation:Stop()
        end
    end

    if auraData.count and auraData.count > 1 then
        button.count:SetText(auraData.count)
    else
        button.count:SetText("")
    end

    if filter == "HARMFUL" then
        local color = oUF.colors.debuff[auraData.dispelName or "none"]
        button:SetBackdropBorderColor(color[1], color[2], color[3])
    else
        button:SetBackdropBorderColor(0, 0, 0)
    end

    -- Show spell stat for 'Soleahs Secret Technique'
    if auraData.spellID == 368512 then
        button.count:SetText(getSpellStat(unpack(auraData.points)))
    end

    button.spellID = auraData.spellID
    button.icon:SetTexture(auraData.icon)
    button.expiration = nil
end

module.UpdateTempEnchant = function(self, button, index)
    local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
    if expirationTime then
        local quality = GetInventoryItemQuality("player", index)
        local color = C.media.qualityColors[quality or 1]
        button:SetBackdropBorderColor(color.r, color.g, color.b)
        button.icon:SetTexture(GetInventoryItemTexture("player", index))

        button.expiration = expirationTime
        button:SetScript("OnUpdate", Button_UpdateTimer)
        button.nextUpdate = -1
        
        Button_UpdateTimer(button, 0)
    else
        button.expiration = nil
        button.timeLeft = nil
        button.timer:SetText("")
    end
end

module.UpdateHeader = function(_, header)
    local size = cfg.debuff_size

    if header.filter == "HELPFUL" then
        size = cfg.buff_size
        header:SetAttribute("consolidateTo", 0)
        header:SetAttribute("weaponTemplate", format("DarkUIAuraTemplate%d", size))
    end

    header:SetAttribute("separateOwn", 1)
    header:SetAttribute("sortMethod", "TIME")
    header:SetAttribute("sortDirection", "+")
    header:SetAttribute("wrapAfter", cfg.row_num)
    header:SetAttribute("maxWraps", header.filter == "HELPFUL" and 3 or 1)
    header:SetAttribute("point", "TOPRIGHT")
    header:SetAttribute("minWidth", (size  + cfg.spacing + cfg.icon_padding + E.mult)*cfg.row_num)
    header:SetAttribute("minHeight", (size + cfg.spacing + cfg.icon_padding)*(header.filter == "HELPFUL" and 3 or 1))
    header:SetAttribute("xOffset", -(size + cfg.spacing + cfg.icon_padding + E.mult))
    header:SetAttribute("yOffset", 0)
    header:SetAttribute("wrapXOffset", 0)
    header:SetAttribute("wrapYOffset", -(size + cfg.spacing + cfg.icon_padding))
    header:SetAttribute("template", format("DarkUIAuraTemplate%d", size))

    local index = 1
    local child = select(index, header:GetChildren())
    while child do
        if (floor(child:GetWidth() * 100 + .5) / 100) ~= size then
            child:SetSize(size, size)
        end

        --Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
        if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
            child:Hide()
        end

        index = index + 1
        child = select(index, header:GetChildren())
    end
end

module.CreateAuraHeader = function(self, filter)
    local name = "DarkUIPlayerDebuffs"
    if filter == "HELPFUL" then name = "DarkUIPlayerBuffs" end

    local header = CreateFrame("Frame", name, _G.UIParent, "SecureAuraHeaderTemplate")
    header:SetClampedToScreen(true)
    header:UnregisterEvent("UNIT_AURA") -- we only need to watch player and vehicle
    header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    header.filter = filter
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

    header.visibility = CreateFrame("Frame", nil, _G.UIParent, "SecureHandlerStateTemplate")
    SecureHandlerSetFrameRef(header.visibility, "AuraHeader", header)
    RegisterStateDriver(header.visibility, "customVisibility", "[petbattle] 0;1")
    header.visibility:SetAttribute("_onstate-customVisibility", [[
        local header = self:GetFrameRef("AuraHeader")
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]]) -- use custom script that will only call hide when it needs to, this prevents spam to `SecureAuraHeader_Update`

    if filter == "HELPFUL" then
        header:SetAttribute("consolidateDuration", -1)
        header:SetAttribute("includeWeapons", 1)
    end

    self:UpdateHeader(header)
    header:Show()

    return header
end

local indexToOffset = {2, 6, 10}

module.CreateAuraIcon = function(self, button)
    local enchantIndex = tonumber(strmatch(button:GetName(), "TempEnchant(%d)$"))
    button.enchantOffset = indexToOffset[enchantIndex]

    button.header = button:GetParent()
    button.filter = button.header.filter
    button.name = button:GetName()

    button.icon = button:CreateTexture(nil, "BORDER")
    button.icon:SetPoint("TOPLEFT", button, cfg.icon_padding, -cfg.icon_padding)
    button.icon:SetPoint("BOTTOMRIGHT", button, -cfg.icon_padding, cfg.icon_padding)
    button.icon:SetDrawLayer("BACKGROUND", -8)
    button.icon:SetTexCoord(unpack(C.media.texCoord))

    button.count = button:CreateFontString(nil, "OVERLAY")
    button.count:SetPoint(unpack(cfg.count_pos))
    button.count:SetFont(unpack(cfg.count_font_style))

    button.timer = button:CreateFontString(nil, "OVERLAY")
    button.timer:SetPoint(unpack(cfg.dur_pos))
    button.timer:SetFont(unpack(cfg.dur_font_style))

    E:StyleButton(button)

    button:CreateShadow()
    
    button:RegisterForClicks("RightButtonUp", "RightButtonDown")
    button:SetScript("OnAttributeChanged", Button_OnAttributeChanged)
    button:SetScript("OnEnter", Button_OnEnter)
    button:SetScript("OnLeave", GameTooltip_Hide)

    if cfg.enable_flash then
        local animation = button:CreateAnimationGroup()
        animation:SetLooping("BOUNCE")

        local fadeOut = animation:CreateAnimation("Alpha")
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0.5)
        fadeOut:SetDuration(0.6)
        fadeOut:SetSmoothing("IN_OUT")

        button.animation = animation
    end

    if (cfg.enable_animation and not button.auraGrowth) then
        local auraGrowth = button:CreateAnimationGroup()

        local grow = auraGrowth:CreateAnimation("Scale")
        grow:SetOrder(1)
        grow:SetDuration(0.2)
        grow:SetScale(1.25, 1.25)

        local shrink = auraGrowth:CreateAnimation("Scale")
        shrink:SetOrder(2)
        shrink:SetDuration(0.2)
        shrink:SetScale(0.75, 0.75)

        button.auraGrowth = auraGrowth
    end
end

function module:OnLogin()
    _G.BuffFrame.numHideableBuffs = 0
    _G.BuffFrame:Kill()
    _G.DebuffFrame:Kill()

    module:BuildBuffFrame()
end