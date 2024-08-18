local _, ns = ...
local E, C, L = ns:unpack()

if not C.unitframe.enable then return end

----------------------------------------------------------------------------------------
-- Tags of UnitFrame
----------------------------------------------------------------------------------------

local oUF = ns.oUF or oUF

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
local format, len, gsub = string.format, string.len, string.gsub

oUF.Tags.Methods["dd:nameplateNameColor"] = function(unit)
    local reaction = UnitReaction(unit, "player")
    if not UnitIsUnit("player", unit) and UnitIsPlayer(unit) and (reaction and reaction >= 5) then
        local c = C.oUF_colors.power["MANA"]
        return format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
    elseif UnitIsPlayer(unit) then
        return _TAGS["raidcolor"](unit)
    elseif reaction then
        local c = C.oUF_colors.reaction[reaction]
        return format("|cff%02x%02x%02x", c[1] * 255, c[2] * 255, c[3] * 255)
    else
        r, g, b = 0.33, 0.59, 0.33
        return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
    end
end
oUF.Tags.Events["dd:nameplateNameColor"] = "UNIT_POWER_UPDATE UNIT_FLAGS"

oUF.Tags.Methods["dd:nameplateHealth"] = function(unit)
    local hp = UnitHealth(unit)
    local maxhp = UnitHealthMax(unit)
    if maxhp == 0 then
        return 0
    else
        return ("%s - %d%%"):format(E:ShortValue(hp), hp / maxhp * 100 + 0.5)
    end
end
oUF.Tags.Events["dd:nameplateHealth"] = "UNIT_HEALTH UNIT_MAXHEALTH NAME_PLATE_UNIT_ADDED"

oUF.Tags.Methods["dd:nameLong"] = function(unit)
    local name = UnitName(unit)
    return E:UTF(name, 18, true)
end
oUF.Tags.Events["dd:nameLong"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods["dd:nameLongAbbrev"] = function(unit)
    local name = UnitName(unit)
    local newname = (len(name) > 18) and gsub(name, "%s?(.[\128-\191]*)%S+%s", "%1. ") or name
    return E:UTF(newname, 18, false)
end
oUF.Tags.Events["dd:nameLongAbbrev"] = "UNIT_NAME_UPDATE"

oUF.Tags.Methods['dd:difficulty'] = function(u)
    local l = UnitLevel(u)
    return Hex(GetQuestDifficultyColor((l > 0) and l or 99))
end

oUF.Tags.Methods['dd:smarthp'] = function(u, r)
    local cur, max = UnitHealth(u), UnitHealthMax(u)
    if (not max) then return end
    if (max == 0) then max = 1 end

    if (not UnitIsConnected(r or u)) then
        return L.UNITFRAME_OFFLINE
    elseif (UnitIsGhost(u)) then
        return L.UNITFRAME_GHOST
    elseif (UnitIsFeignDeath(u)) then
        return '|cffff3333FD|r'
    elseif (UnitIsDead(u)) then
        return L.UNITFRAME_DEAD
    else
        if (cur == max) then
            return '|cff98c290' .. E:ShortValue(max)
        else
            local r, g, b = ColorGradient(cur, max, 245 / 255, 68 / 255, 68 / 255, 245 / 255, 186 / 255, 69 / 255, 105 / 255, 201 / 255, 105 / 255)
            local color = Hex(r, g, b)
            return ('|cfffd5c69%s |cffdbf6db- %s%d%%|r'):format(E:ShortValue(cur), color, floor(cur / max * 100))
        end
    end
end
oUF.Tags.Events['dd:smarthp'] = oUF.Tags.Events['missinghp']

oUF.Tags.Methods['dd:pp'] = function(u, r)
    local color = C.oUF_colors.power[select(2, UnitPowerType(u))]

    if color == nil then
        color = C.oUF_colors.power[select(1, UnitPowerType(u))]
    end

    if color == nil then
        color = {0.6, 0.6, 0.6}
    end

    return Hex(color[1], color[2], color[3]) .. E:ShortValue(UnitPower(u) or 0)
end
oUF.Tags.Events['dd:pp'] = 'UNIT_POWER_UPDATE'

oUF.Tags.Methods['dd:realname'] = function(u, r)
    local name, realm = UnitName(r or u)
    if (realm) then
        name = name .. '-*'
    end

    if UnitIsAFK(r or u) then name = L.UNITFRAME_AFK .. name end
    if UnitIsDND(r or u) then name = L.UNITFRAME_DND .. name end

    return name
end
oUF.Tags.Events["dd:realname"] = "UNIT_NAME_UPDATE UNIT_CONNECTION PLAYER_FLAGS_CHANGED"

oUF.Tags.Methods["dd:raidname"] = function(unit, rolf)
    local color = { r = 1, g = 1, b = 1, }
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) then
        color = { r = 0.5, g = 0.5, b = 0.5 }
    else
        color = RAID_CLASS_COLORS[select(2, UnitClass(unit))]
    end

    local colorstr = color and E:RGBToHex(color.r, color.g, color.b, true) or "ffffff"
    local name = UnitName(rolf or unit)

    return "|cff" .. colorstr .. (E:UTF(name, 4, true) or "") .. "|r"
end
oUF.Tags.Events["dd:raidname"] = "UNIT_NAME_UPDATE UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods["dd:misshp"] = function(unit)
    local color = { r = 1, g = 1, b = 1, }
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
        local max, min = UnitHealthMax(unit), UnitHealth(unit)
        if max - min > 0 then
            hpval = "-" .. E:ShortValue(max - min)
        end
    end
    return "|cff" .. colorstr .. (hpval or "100%") .. "|r"
end
oUF.Tags.Events["dd:misshp"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

oUF.Tags.Methods['dd:pvptimer'] = function(unit)
    if (not IsPVPTimerRunning() and GetPVPTimer() >= 0) then
        return ''
    end

    return E:FormatTime(math.floor(GetPVPTimer() / 1000))
end

-- AltPower value tag
oUF.Tags.Methods["dd:altpower"] = function(unit)
    local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
    return cur > 0 and cur
end
oUF.Tags.Events["dd:altpower"] = "UNIT_POWER_UPDATE UNIT_MAXPOWER"

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
                     }
)

-- better tag api
local function CreateTag(self, region, tagstr, frequentUpdates)
    if (type(region) == 'string') then
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
