--[[
    ~AddOn Engine~
    To load the AddOn engine add this to the top of your file:
        local E, C, L = unpack(select(2, ...)); --Import: Engine, Config, Locale

    To load the AddOn engine inside another addon add this to the top of your file:
        local E, C, L = unpack(DarkUI); --Import: Engine, Config, Locale
]]

local addonName, ns = ...

ns[1] = {}            -- E, Engine
ns[2] = {}            -- C, Config
ns[3] = {}            -- L, Locale

ns[1].screenWidth, ns[1].screenHeight = GetPhysicalScreenSize()
ns[1].locale = GetLocale()
ns[1].realm = GetRealmName()
ns[1].version = C_AddOns.GetAddOnMetadata(addonName, "Version")
ns[1].addonName = addonName

ns[1].myClass = select(2, UnitClass('player'))
ns[1].myRace = select(2, UnitRace("player"))
ns[1].myName = UnitName("player")
ns[1].myLevel = UnitLevel("player")
ns[1].myGuid = UnitGUID('player')
ns[1].myColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[ns[1].myClass]
ns[1].myColorString = format('|cff%02x%02x%02x', ns[1].myColor.r * 255, ns[1].myColor.g * 255, ns[1].myColor.b * 255)

function ns:unpack()
    return self[1], self[2], self[3]
end

-- Allow other addons to use
_G[addonName] = ns


-- Global constants
CURRENT_EXPANSION = EXPANSION_NAME9