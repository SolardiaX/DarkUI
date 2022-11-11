local E, C, L = select(2, ...):unpack()

if not C.aura.enable then return end

----------------------------------------------------------------------------------------
--	Aura styles (modified from ShestakUI)
----------------------------------------------------------------------------------------

local cfg = C.aura

local auras = CreateFrame("Frame")
C.aura.host = auras

local _G = _G
local format, floor, strmatch, select, unpack, tonumber = format, floor, strmatch, select, unpack, tonumber
local UnitAura, GetTime = UnitAura, GetTime
local GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo = GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo
local oUF = select(2, ...).oUF

auras:RegisterEvent("PLAYER_LOGIN")
auras:SetScript("OnEvent", function()
    auras:HideBlizBuff()
    auras:BuildBuffFrame()
end)

function auras:HideBlizBuff()
    _G.BuffFrame:Kill()
    _G.DebuffFrame:Kill()
end

function auras:StartOrStopFlash(animation, timeleft)
    if(timeleft < cfg.flash_timer) then
        if(not animation:IsPlaying()) then
            animation:Play()
        end
    elseif(animation:IsPlaying()) then
        animation:Stop()
    end
end

local day, hour, minute = 86400, 3600, 60
function auras:FormatAuraTime(s)
	if s >= day then
		return E:FormatTime(s), s%day
	elseif s >= 2*hour then
		return E:FormatTime(s), s%hour
	elseif s >= 10*minute then
		return E:FormatTime(s), s%minute
	elseif s >= minute then
		return E:FormatTime(s), s - floor(s)
	elseif s > 10 then
		return E:FormatTime(s), s - floor(s)
	elseif s > 5 then
		return E:FormatTime(s), s - format("%.1f", s)
	else
		return E:FormatTime(s), s - format("%.1f", s)
	end
end

function auras:BuildBuffFrame()
    -- Movers
    auras.BuffFrame = auras:CreateAuraHeader("HELPFUL")
    auras.BuffFrame:ClearAllPoints()
    auras.BuffFrame:SetPoint(unpack(cfg.buff_pos))

    auras.DebuffFrame = auras:CreateAuraHeader("HARMFUL")
    auras.DebuffFrame:ClearAllPoints()
    auras.DebuffFrame:SetPoint(unpack(cfg.debuff_pos))
end

function auras:UpdateTimer(elapsed)
    local onTooltip = GameTooltip:IsOwned(self)

    if not (self.timeLeft or self.expiration or onTooltip) then
        self:SetScript("OnUpdate", nil)
        return
    end

    if self.expiration then
        self.timeLeft = self.expiration / 1e3
    elseif self.timeLeft then
        self.timeLeft = self.timeLeft - elapsed
    end

    if self.nextUpdate > 0 then
        self.nextUpdate = self.nextUpdate - elapsed
        return
    end

    if self.timeLeft and self.timeLeft >= 0 then
        local timer, nextUpdate = auras:FormatAuraTime(self.timeLeft)
        self.nextUpdate = nextUpdate
        self.timer:SetText(timer)
    end

    if onTooltip then auras:Button_SetTooltip(self) end
end

function auras:GetSpellStat(arg16, arg17, arg18)
    return (arg16 > 0 and L.AURA_VERSA) or (arg17 > 0 and L.AURA_MASTERY) or (arg18 > 0 and L.AURA_HASTE) or L.AURA_CRIT
end

function auras:UpdateAuras(button, index)
    local unit, filter = button.header:GetAttribute("unit"), button.filter
    local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellID, _, _, _, _, _, arg16, arg17, arg18 = UnitAura(unit, index, filter)
    if not name then return end

    if duration > 0 and expirationTime then
        local timeLeft = expirationTime - GetTime()
        if not button.timeLeft then
            button.nextUpdate = -1
            button.timeLeft = timeLeft
            button:SetScript("OnUpdate", auras.UpdateTimer)
        else
            button.timeLeft = timeLeft
        end
        button.nextUpdate = -1
        auras.UpdateTimer(button, 0)

        if cfg.enable_flash and timeLeft then
            auras:StartOrStopFlash(button.animation, timeLeft)
        end

        if timeLeft and (duration == ceil(timeLeft)) and (cfg.enable_animation and button.auraGrowth) then
            button.auraGrowth:Play()
        end
    else
        button.timeLeft = 0
        button.timer:SetText("")

        if cfg.enable_flash then
            button.animation:Stop()
        end
    end

    if count and count > 1 then
        button.count:SetText(count)
    else
        button.count:SetText("")
    end

    if filter == "HARMFUL" then
        local color = oUF.colors.debuff[debuffType or "none"]
        button:SetBackdropBorderColor(color[1], color[2], color[3])
    else
        button:SetBackdropBorderColor(0, 0, 0)
    end

    -- Show spell stat for 'Soleahs Secret Technique'
    if spellID == 368512 then
        button.count:SetText(auras:GetSpellStat(arg16, arg17, arg18))
    end

    button.spellID = spellID
    button.icon:SetTexture(texture)
    button.expiration = nil
end

function auras:UpdateTempEnchant(button, index)
    local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
    if expirationTime then
        local quality = GetInventoryItemQuality("player", index)
        local color = C.media.qualityColors[quality or 1]
        button:SetBackdropBorderColor(color.r, color.g, color.b)
        button.icon:SetTexture(GetInventoryItemTexture("player", index))

        button.expiration = expirationTime
        button:SetScript("OnUpdate", auras.UpdateTimer)
        button.nextUpdate = -1
        auras.UpdateTimer(button, 0)
    else
        button.expiration = nil
        button.timeLeft = nil
        button.timer:SetText("")
    end
end

function auras:OnAttributeChanged(attribute, value)
    if attribute == "index" then
        auras:UpdateAuras(self, value)
    elseif attribute == "target-slot" then
        auras:UpdateTempEnchant(self, value)
    end
end

function auras:UpdateHeader(header)
    local size = cfg.debuff_size

    if header.filter == "HELPFUL" then
        size = cfg.buff_size
        header:SetAttribute("consolidateTo", 0)
        header:SetAttribute("weaponTemplate", format("DarkUIAuraTemplate%d", size))
    end

    header:SetAttribute("separateOwn", 1)
    header:SetAttribute("sortMethod", "INDEX")
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

function auras:CreateAuraHeader(filter)
    local name = "DarkUIPlayerDebuffs"
    if filter == "HELPFUL" then name = "DarkUIPlayerBuffs" end

    local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    header:SetClampedToScreen(true)
    header:UnregisterEvent("UNIT_AURA") -- we only need to watch player and vehicle
    header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    header.filter = filter
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

    header.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
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

    auras:UpdateHeader(header)
    header:Show()

    return header
end

function auras:Button_SetTooltip(button)
    if button:GetAttribute("index") then
        GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
    elseif button:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", button:GetID())
    end
end

function auras:Button_OnEnter()
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
    -- Update tooltip
    self.nextUpdate = -1
    self:SetScript("OnUpdate", auras.UpdateTimer)
end

local indexToOffset = {2, 6, 10}

function auras:CreateAuraIcon(button)
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

    button.count = button:CreateFontString(nil, "ARTWORK")
    button.count:SetPoint(unpack(cfg.count_pos))
    button.count:SetFont(unpack(cfg.count_font_style))

    button.timer = button:CreateFontString(nil, "ARTWORK")
    button.timer:SetPoint(unpack(cfg.dur_pos))
    button.timer:SetFont(unpack(cfg.dur_font_style))

    button.highlight = button:CreateTexture(nil, "HIGHLIGHT")
    button.highlight:SetColorTexture(1, 1, 1, .25)
    button.highlight:SetInside()

    button:CreateTextureBorder()
    button:CreateShadow()

    button:RegisterForClicks("RightButtonUp")
    button:SetScript("OnAttributeChanged", auras.OnAttributeChanged)
    button:SetScript("OnEnter", auras.Button_OnEnter)
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