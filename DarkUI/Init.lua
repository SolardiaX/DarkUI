--[[
	~AddOn Engine~
	To load the AddOn engine add this to the top of your file:
		local E, C, L, M = unpack(select(2, ...)); --Import: Engine, Config, Locale, Module

	To load the AddOn engine inside another addon add this to the top of your file:
		local E, C, L, M = unpack(DarkUI); --Import: Engine, Config, Locale, Module
]]

local addonName, ns = ...

ns[1] = {}            -- E, Engine
ns[2] = {}            -- C, Config
ns[3] = {}            -- L, Locale
-- ns[4] = {}            -- M, Module

ns[1].screenWidth, ns[1].screenHeight = GetPhysicalScreenSize()
ns[1].client = GetLocale()
ns[1].realm = GetRealmName()
ns[1].version = GetAddOnMetadata(addonName, "Version")
ns[1].addonName = addonName
ns[1].isNewPatch = select(4, GetBuildInfo()) >= 100000 -- 10.0
ns[1].class = select(2, UnitClass('player'))
ns[1].name = UnitName("player")
ns[1].race = select(2, UnitRace("player"))
ns[1].level = UnitLevel("player")
ns[1].color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[ns[1].class]
ns[1].colorString = format('|cff%02x%02x%02x', ns[1].color.r * 255, ns[1].color.g * 255, ns[1].color.b * 255)

function ns:unpack()
    return self[1], self[2], self[3], self[4]
end

-- Allow other addons to use
_G[addonName] = ns
