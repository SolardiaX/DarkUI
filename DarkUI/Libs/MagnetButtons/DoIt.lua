local _, ns = ...
local addon = ns.MagnetButtons

local DoIt_Saved = {
    Debug = false
}

local version, build, _, _ = GetBuildInfo()
addon.system = { }
addon.system.version = version
addon.system.build = build
addon.system.isClassic = (string.sub(version, 1, 2) == "1.")
addon.system.expansion = GetAccountExpansionLevel()

function addon.Round(num) return floor(num + 0.5) end

function addon.Debug(message, isError)
    if (DoIt_Saved.Debug or isError) then
        if (isError) then
            message = "\124cffFF0000\124Hitem:19:0:0:0:0:0:0:0\124h" .. tostring(message) .. "\124h\124r"
        end
        DEFAULT_CHAT_FRAME:AddMessage(message, 0.25, 1.0, 1.0, 1)
    end
end

function addon.GetFullPlayerName()
    local name, realm = UnitName("player")
    if (not realm) then realm = GetRealmName() end
    return tostring(name) .. "-" .. tostring(realm)
end

function addon.DeepCopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end

    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    for k, v in pairs(obj) do res[self.deepCopy(k, s)] = self.deepCopy(v, s) end
    return res
end

function addon.PlayerHasAura(spellName)
    for i = 1, BUFF_MAX_DISPLAY do
        local name, _, _, _, _, _, _, _, _ = UnitAura("player", i)
        if (name) and (name == spellName) then
            return true
        end
    end
    return false
end

function addon.GetPlayerInfo(asTable)
    local isManaged = false
    local name, instanceType, _, _, _, _, _, _, _ = GetInstanceInfo()
    local isRestricted = (HasLFGRestrictions and HasLFGRestrictions())
    local area = GetRealZoneText()
    local zone = GetMinimapZoneText()
    local bindLocation = GetBindLocation()
    local facing = GetPlayerFacing() -- in radians, 0 = north, values increasing counterclockwise

    if (instanceType == nil or instanceType == "") then instanceType = "unknown"
    elseif (instanceType == "none") then instanceType = "world"
    elseif (instanceType == "party") then instanceType = "dungeon"
    elseif (instanceType == "pvp") then instanceType = "battleground" end

    if (instanceType == "arena" or instanceType == "battleground" or isRestricted) then isManaged = true end
    if (zone == nil or zone == "") then zone = "unknown" end
    if (area == nil or area == "") then area = "unknown" end

    if (asTable) then
        return {
            zone         = zone,
            area         = area,
            name         = name,
            type         = instanceType,
            isManaged    = isManaged,
            bindLocation = bindLocation,
            facing       = facing
        }
    end
    return zone, area, name, instanceType, isManaged, bindLocation, facing
end
