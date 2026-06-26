local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auras
------------------------------------------------------------------------
local module = E:Module("Aura"):Sub("Auras")

local cfg = C.aura

local GetTime = GetTime
local floor, format, ceil = math.floor, string.format, math.ceil
local unpack, select, strmatch, tonumber = unpack, select, strmatch, tonumber
local GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo = GetInventoryItemQuality, GetInventoryItemTexture, GetWeaponEnchantInfo
local C_UnitAuras_GetAuraDataByIndex = C_UnitAuras.GetAuraDataByIndex
local GameTooltip, GameTooltip_Hide = GameTooltip, GameTooltip_Hide

local dispelColorCurve = C_CurveUtil.CreateColorCurve()

------------------------------------------------------------------------
-- Time Formatting
------------------------------------------------------------------------

local DAY, HOUR, MINUTE = 86400, 3600, 60

local function formatAuraTime(s)
    if s >= DAY then
        return format("%dd", s / DAY + 0.5), s % DAY
    elseif s >= 2 * HOUR then
        return format("%dh", s / HOUR + 0.5), s % HOUR
    elseif s >= 10 * MINUTE then
        return format("%dm", s / MINUTE + 0.5), s % MINUTE
    elseif s >= MINUTE then
        return format("%d:%02d", s / MINUTE, s % MINUTE), s - floor(s)
    elseif s > 10 then
        return format("%d", s), s - floor(s)
    elseif s > 5 then
        return format("|cffffff00%.1f|r", s), s - format("%.1f", s)
    else
        return format("|cffff0000%.1f|r", s), s - format("%.1f", s)
    end
end

local function startOrStopFlash(animation, timeleft)
    if timeleft < cfg.flash_timer then
        if not animation:IsPlaying() then animation:Play() end
    elseif animation:IsPlaying() then
        animation:Stop()
    end
end

------------------------------------------------------------------------
-- Button Scripts
------------------------------------------------------------------------

local updateAuras, updateTempEnchant

local function buttonSetTooltip(button)
    if button:GetAttribute("index") then
        GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
    elseif button:GetAttribute("target-slot") then
        GameTooltip:SetInventoryItem("player", button:GetID())
    end
end

local function buttonUpdateTimer(button, elapsed)
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

    if onTooltip then buttonSetTooltip(button) end
end

local function buttonOnAttributeChanged(button, attribute, value)
    if attribute == "index" then
        updateAuras(button, value)
    elseif attribute == "target-slot" then
        updateTempEnchant(button, value)
    end
end

local function buttonOnEnter(button)
    GameTooltip:SetOwner(button, "ANCHOR_BOTTOMLEFT", -5, -5)
    button.nextUpdate = -1
    button:SetScript("OnUpdate", buttonUpdateTimer)
end

------------------------------------------------------------------------
-- Aura Updates
------------------------------------------------------------------------

updateAuras = function(button, index)
    local unit, filter = button.header:GetAttribute("unit"), button.filter
    local auraData = C_UnitAuras_GetAuraDataByIndex(unit, index, filter)

    if not auraData then return end

    local duration = auraData.duration
    local hasDuration = not issecretvalue(duration) and duration > 0 and auraData.expirationTime

    if hasDuration then
        local timeLeft = auraData.expirationTime - GetTime()
        if not button.timeLeft then
            button.nextUpdate = -1
            button.timeLeft = timeLeft
            button:SetScript("OnUpdate", buttonUpdateTimer)
        else
            button.timeLeft = timeLeft
        end
        button.nextUpdate = -1
        buttonUpdateTimer(button, 0)

        if cfg.enable_flash and button.animation then startOrStopFlash(button.animation, timeLeft) end

        if cfg.enable_animation and button.auraGrowth then
            if timeLeft and auraData.duration == ceil(timeLeft) then button.auraGrowth:Play() end
        end
    else
        button.timeLeft = nil
        button.timer:SetText("")

        if cfg.enable_flash and button.animation then button.animation:Stop() end
    end

    local applications = auraData.applications
    if not issecretvalue(applications) and applications and applications > 1 then
        button.count:SetText(applications)
    else
        button.count:SetText("")
    end

    if filter == "HARMFUL" then
        local color = C_UnitAuras.GetAuraDispelTypeColor(unit, auraData.auraInstanceID, dispelColorCurve)
        if color then
            button:SetBackdropBorderColor(color:GetRGBA())
        else
            button:SetBackdropBorderColor(0.8, 0, 0)
        end
    else
        button:SetBackdropBorderColor(0, 0, 0)
    end

    button.spellID = auraData.spellId
    button.icon:SetTexture(auraData.icon)
    button.expiration = nil
end

updateTempEnchant = function(button, index)
    local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
    if expirationTime then
        local quality = GetInventoryItemQuality("player", index)
        local color = C.media.qualityColors[quality or 1]
        button:SetBackdropBorderColor(color.r, color.g, color.b)
        button.icon:SetTexture(GetInventoryItemTexture("player", index))

        button.expiration = expirationTime
        button:SetScript("OnUpdate", buttonUpdateTimer)
        button.nextUpdate = -1
        buttonUpdateTimer(button, 0)
    else
        button.expiration = nil
        button.timeLeft = nil
        button.timer:SetText("")
    end
end

------------------------------------------------------------------------
-- Header Setup
------------------------------------------------------------------------

local function updateHeader(header)
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
    header:SetAttribute("minWidth", (size + cfg.spacing + cfg.icon_padding + E.mult) * cfg.row_num)
    header:SetAttribute("minHeight", (size + cfg.spacing + cfg.icon_padding) * (header.filter == "HELPFUL" and 3 or 1))
    header:SetAttribute("xOffset", -(size + cfg.spacing + cfg.icon_padding + E.mult))
    header:SetAttribute("yOffset", 0)
    header:SetAttribute("wrapXOffset", 0)
    header:SetAttribute("wrapYOffset", -(size + cfg.spacing + cfg.icon_padding))
    header:SetAttribute("template", format("DarkUIAuraTemplate%d", size))
end

local function createAuraHeader(filter)
    local name = filter == "HELPFUL" and "DarkUIPlayerBuffs" or "DarkUIPlayerDebuffs"

    local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
    header:SetClampedToScreen(true)
    header:UnregisterEvent("UNIT_AURA")
    header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
    header:SetAttribute("unit", "player")
    header:SetAttribute("filter", filter)
    header.filter = filter
    RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

    -- Pet battle visibility
    header.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
    SecureHandlerSetFrameRef(header.visibility, "AuraHeader", header)
    RegisterStateDriver(header.visibility, "customVisibility", "[petbattle] 0;1")
    header.visibility:SetAttribute(
        "_onstate-customVisibility",
        [[
        local header = self:GetFrameRef("AuraHeader")
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]]
    )

    if filter == "HELPFUL" then
        header:SetAttribute("consolidateDuration", -1)
        header:SetAttribute("includeWeapons", 1)
    end

    updateHeader(header)
    header:Show()

    return header
end

------------------------------------------------------------------------
-- Icon Creation
------------------------------------------------------------------------

local indexToOffset = { 2, 6, 10 }

function module:CreateAuraIcon(button)
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

    E:StyleIconButton(button)
    button:CreateShadow()

    button:SetScript("OnAttributeChanged", buttonOnAttributeChanged)
    button:SetScript("OnEnter", buttonOnEnter)
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

    if cfg.enable_animation then
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

------------------------------------------------------------------------
-- Module Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then return end

    BuffFrame.numHideableBuffs = 0
    BuffFrame:Kill()
    DebuffFrame:Kill()

    self.BuffFrame = createAuraHeader("HELPFUL")
    self.BuffFrame:ClearAllPoints()
    self.BuffFrame:SetPoint(unpack(cfg.buff_pos))

    self.DebuffFrame = createAuraHeader("HARMFUL")
    self.DebuffFrame:ClearAllPoints()
    self.DebuffFrame:SetPoint(unpack(cfg.debuff_pos))

    -- PrivateAuras (Blizzard-rendered, top-center growing down)
    local paSize = cfg.private_aura_size
    local paSpacing = cfg.spacing
    local paNum = 5

    local pa = CreateFrame("Frame", "DarkUI_PrivateAuras", UIParent)
    pa:SetPoint(unpack(cfg.private_aura_pos))
    pa:SetSize(paSize * paNum + paSpacing * (paNum - 1), paSize)

    pa.auraIcons = {}
    for i = 1, paNum do
        local aura = CreateFrame("Frame", "DarkUI_PrivateAura" .. i, pa)
        aura:SetSize(paSize, paSize)
        aura:ClearAllPoints()
        if i == 1 then
            aura:SetPoint("TOP", pa)
        else
            aura:SetPoint("TOP", pa.auraIcons[i - 1], "BOTTOM", 0, -paSpacing)
        end

        aura.anchorID = C_UnitAuras.AddPrivateAuraAnchor({
            unitToken = "player",
            auraIndex = i,
            parent = aura,
            isContainer = false,
            showCountdownFrame = true,
            showCountdownNumbers = true,
            iconInfo = {
                iconWidth = paSize,
                iconHeight = paSize,
                iconAnchor = {
                    point = "CENTER",
                    relativeTo = aura,
                    relativePoint = "CENTER",
                    offsetX = 0,
                    offsetY = 0,
                },
            },
        })

        pa.auraIcons[i] = aura
    end

    self.PrivateAuras = pa
end
