local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Tags
------------------------------------------------------------------------
local oUF = select(2, ...).oUF or oUF

local issecretvalue = issecretvalue
local UnitHealthPercent = UnitHealthPercent
local UnitPowerPercent = UnitPowerPercent
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetPVPTimer = GetPVPTimer
local IsPVPTimerRunning = IsPVPTimerRunning
local UnitHealth, UnitHealthMax = UnitHealth, UnitHealthMax
local UnitIsPlayer, UnitIsUnit = UnitIsPlayer, UnitIsUnit
local UnitIsConnected, UnitIsAFK, UnitIsDND = UnitIsConnected, UnitIsAFK, UnitIsDND
local UnitIsDead, UnitIsDeadOrGhost = UnitIsDead, UnitIsDeadOrGhost
local UnitIsGhost, UnitIsFeignDeath = UnitIsGhost, UnitIsFeignDeath
local UnitName, UnitClass, UnitLevel, UnitReaction = UnitName, UnitClass, UnitLevel, UnitReaction
local UnitPowerType, UnitPower = UnitPowerType, UnitPower
local TruncateWhenZero = C_StringUtil.TruncateWhenZero
local format, len, gsub, floor = string.format, string.len, string.gsub, math.floor

local function isSecretValue(value)
    return issecretvalue and issecretvalue(value)
end

local function colorToRGB(color)
    if type(color) == "table" then
        if color.GetRGB then
            return color:GetRGB()
        end
        return color[1] or 0, color[2] or 0, color[3] or 0
    end
    return 0, 0, 0
end

local function hexColor(color)
    local r, g, b = colorToRGB(color)
    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function colorGradient(perc, max, r1, g1, b1, r2, g2, b2, r3, g3, b3)
    local segment, relperc = math.modf((perc / max) * 2)
    if segment >= 2 then return r3, g3, b3 end
    if segment <= 0 then return r1, g1, b1 end
    if segment == 1 then
        return r2 + (r3 - r2) * relperc, g2 + (g3 - g2) * relperc, b2 + (b3 - b2) * relperc
    end
    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

------------------------------------------------------------------------
-- Nameplate tags
------------------------------------------------------------------------

oUF.Tags.Methods["dd:nameplateNameColor"] = function(unit)
    local reaction = UnitReaction(unit, "player")
    if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (reaction and reaction >= 5) then
        return hexColor(C.oUF_colors.power["MANA"])
    elseif UnitIsPlayer(unit) then
        return _TAGS["raidcolor"](unit)
    elseif reaction then
        return hexColor(C.oUF_colors.reaction[reaction])
    else
        return format("|cff%02x%02x%02x", 0.33 * 255, 0.59 * 255, 0.33 * 255)
    end
end
oUF.Tags.Events["dd:nameplateNameColor"] = "UNIT_POWER_UPDATE UNIT_FLAGS"

oUF.Tags.Methods["dd:nameplateHealth"] = function(unit)
    local per = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
    if isSecretValue(per) then return "" end

    local hp = UnitHealth(unit)
    if isSecretValue(hp) then
        return format("%d%%", per)
    else
        return format("%s - %d%%", E:AbbreviateNumber(hp), per)
    end
end
oUF.Tags.Events["dd:nameplateHealth"] = "UNIT_HEALTH UNIT_MAXHEALTH NAME_PLATE_UNIT_ADDED"

------------------------------------------------------------------------
-- Name tags
------------------------------------------------------------------------

oUF.Tags.Methods["dd:nameLong"] = function(unit)
    local name = UnitName(unit)
    if isSecretValue(name) then return "" end
    return E:UTF(name, 18, true)
end
oUF.Tags.Events["dd:nameLong"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["dd:nameLongAbbrev"] = function(unit)
    local name = UnitName(unit)
    if isSecretValue(name) then return "" end
    local newname = (len(name) > 18) and gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
    return E:UTF(newname, 18, false)
end
oUF.Tags.Events["dd:nameLongAbbrev"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods['dd:difficulty'] = function(u)
    local l = UnitLevel(u)
    local c = GetQuestDifficultyColor((l > 0) and l or 99)
    return format("|cff%02x%02x%02x", c.r * 255, c.g * 255, c.b * 255)
end

------------------------------------------------------------------------
-- Health / Power tags
------------------------------------------------------------------------

local hpCalculator = CreateUnitHealPredictionCalculator()
local hpColorCurve = C_CurveUtil.CreateColorCurve()
hpColorCurve:AddPoint(0, CreateColor(245 / 255, 68 / 255, 68 / 255, 1))
hpColorCurve:AddPoint(0.5, CreateColor(245 / 255, 186 / 255, 69 / 255, 1))
hpColorCurve:AddPoint(1, CreateColor(105 / 255, 201 / 255, 105 / 255, 1))

oUF.Tags.Methods['dd:smarthp'] = function(u, _, arg1)
    if not UnitIsConnected(u) then
        return L.UNITFRAME_OFFLINE
    elseif UnitIsGhost(u) then
        return L.UNITFRAME_GHOST
    elseif UnitIsFeignDeath(u) then
        return '|cffff3333FD|r'
    elseif UnitIsDead(u) then
        return L.UNITFRAME_DEAD
    end

    UnitGetDetailedHealPrediction(u, "player", hpCalculator)
    local color = hpCalculator:EvaluateCurrentHealthPercent(hpColorCurve)

    local rawPer = format(UnitHealthPercent(u, true, CurveConstants.ScaleTo100))
    local per = not isSecretValue(rawPer) and format("%d%%", rawPer) or ""
    local cur = E:AbbreviateNumber(UnitHealth(u))
    local max = E:AbbreviateNumber(UnitHealthMax(u))

    local text
    if arg1 == "currentmax" then
        text = cur .. " | " .. max
    elseif arg1 == "current" then
        text = cur
    elseif arg1 == "percent" then
        text = per
    elseif arg1 == "loss" then
        text = E:AbbreviateNumber(UnitHealthMissing(u))
    else
        text = per ~= "" and (cur .. " | " .. per) or cur
    end

    if color then
        return color:WrapTextInColorCode(text)
    end

    return text
end
oUF.Tags.Events['dd:smarthp'] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION PLAYER_FLAGS_CHANGED PARTY_MEMBER_ENABLE PARTY_MEMBER_DISABLE"

oUF.Tags.Methods['dd:pp'] = function(u)
    local color = C.oUF_colors.power[select(2, UnitPowerType(u))]
    if color == nil then
        color = C.oUF_colors.power[select(1, UnitPowerType(u))]
    end

    local power = UnitPower(u)
    if isSecretValue(power) then return "" end

    local text = E:AbbreviateNumber(power or 0)
    if color and color.WrapTextInColorCode then
        return color:WrapTextInColorCode(text)
    end
    return text
end
oUF.Tags.Events['dd:pp'] = 'UNIT_POWER_UPDATE'

oUF.Tags.Methods['dd:realname'] = function(u, r)
    local name, realm = UnitName(r or u)
    if isSecretValue(name) then return "" end
    if realm then
        name = name .. '-*'
    end

    if UnitIsAFK(r or u) then name = L.UNITFRAME_AFK .. name end
    if UnitIsDND(r or u) then name = L.UNITFRAME_DND .. name end

    return name
end
oUF.Tags.Events["dd:realname"] = "UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["dd:raidname"] = function(unit, rolf)
    local color = { r = 1, g = 1, b = 1 }
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        color = { r = 0.5, g = 0.5, b = 0.5 }
    else
        color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
    end

    local colorstr = color and E:RGBToHex(color.r, color.g, color.b, true) or "ffffff"
    local name = UnitName(rolf or unit)
    if isSecretValue(name) then return "" end

    return "|cff" .. colorstr .. (E:UTF(name, 4, true) or "") .. "|r"
end
oUF.Tags.Events["dd:raidname"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["dd:misshp"] = function(unit)
    local color = { r = 1, g = 1, b = 1 }
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        color = { r = 0.5, g = 0.5, b = 0.5 }
    end
    local colorstr = color and E:RGBToHex(color.r, color.g, color.b, true) or "ffffff"

    local hpval
    if UnitIsDeadOrGhost(unit) then
        hpval = L.UNITFRAME_DEAD
    elseif not UnitIsConnected(unit) then
        hpval = L.UNITFRAME_OFFLINE
    else
        local per = UnitHealthPercent(unit, true, CurveConstants.ScaleTo100)
        if not isSecretValue(per) and per < 100 then
            local max = UnitHealthMax(unit)
            local cur = UnitHealth(unit)
            if not isSecretValue(max) and not isSecretValue(cur) and max - cur > 0 then
                hpval = "-" .. E:AbbreviateNumber(max - cur)
            end
        end
    end
    return "|cff" .. colorstr .. (hpval or "100%") .. "|r"
end
oUF.Tags.Events["dd:misshp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods['dd:pvptimer'] = function(unit)
    if not IsPVPTimerRunning() and GetPVPTimer() >= 0 then
        return ''
    end
    return E:FormatTime(floor(GetPVPTimer() / 1000))
end

oUF.Tags.Methods["dd:altpower"] = function(unit)
    local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
    if isSecretValue(cur) then return end
    return cur > 0 and cur
end
oUF.Tags.Events["dd:altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

------------------------------------------------------------------------
-- Tag creation helper (fluent API)
------------------------------------------------------------------------

local instance, func, proxyfunc, proxy

proxyfunc = function(self, ...)
    func(instance, ...)
    return proxy
end

proxy = setmetatable({
    done = function()
        return instance
    end,
}, {
    __index = function(self, key)
        func = instance[key]
        return proxyfunc
    end,
})

local function CreateTag(self, region, tagstr, frequentUpdates)
    if type(region) == 'string' then
        region, tagstr = self, region
    end

    local fs = region:CreateFontText(12, "")
    fs:ClearAllPoints()

    if frequentUpdates then
        if type(frequentUpdates) == 'number' then
            fs.frequentUpdates = frequentUpdates
        else
            fs.frequentUpdates = .5
        end
    end

    self:Tag(fs, tagstr)

    instance = fs

    return proxy
end

oUF:RegisterMetaFunction('CreateTag', CreateTag)
