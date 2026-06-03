----------------------------------------------------------------------------------------
-- DarkUI Engine
----------------------------------------------------------------------------------------

local addonName, ns = ...

ns[1] = {} -- E, Engine
ns[2] = {} -- C, Config
ns[3] = {} -- L, Locale

local E = ns[1]

E.screenWidth, E.screenHeight = GetPhysicalScreenSize()
E.locale = GetLocale()
E.realm = GetRealmName()
E.version = C_AddOns.GetAddOnMetadata(addonName, "Version")
E.addonName = addonName

E.myClass = select(2, UnitClass("player"))
E.myRace = select(2, UnitRace("player"))
E.myName = UnitName("player")
E.myLevel = UnitLevel("player")
E.myGuid = UnitGUID("player")
E.myColor = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[E.myClass]
E.myColorString = format("|cff%02x%02x%02x", E.myColor.r * 255, E.myColor.g * 255, E.myColor.b * 255)

function ns:unpack()
    return self[1], self[2], self[3]
end

_G[addonName] = ns

----------------------------------------------------------------------------------------
-- Bootstrap
----------------------------------------------------------------------------------------

local bootstrap = CreateFrame("Frame")
bootstrap:RegisterEvent("ADDON_LOADED")
bootstrap:RegisterEvent("PLAYER_LOGIN")
bootstrap:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        E.db:Initialize()
        E:InitializeModules()
        bootstrap:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        E:UIScale()
        E:EnableModules()
        bootstrap:UnregisterEvent("PLAYER_LOGIN")
    end
end)
