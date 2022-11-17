local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.unit_role ~= true then return end

----------------------------------------------------------------------------------------
--	Displays a players LFD/LFR role(gTooltipRoles by g0st)
----------------------------------------------------------------------------------------

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local IsInInstance = IsInInstance
local UnitIsPlayer, UnitInParty, UnitInRaid = UnitIsPlayer, UnitInParty, UnitInRaid
local GetNumGroupMembers = GetNumGroupMembers
local NO_ROLE, TANK, HEALER, DAMAGER, ROLE = NO_ROLE, TANK, HEALER, DAMAGER, ROLE
local GameTooltip = GameTooltip

local function GetLFDRole(unit)
    local role = UnitGroupRolesAssigned(unit)

    if role == "NONE" then
        return "|cFFB5B5B5"..NO_ROLE.."|r"
    elseif role == "TANK" then
        return "|cFF0070DE"..TANK.."|r"
    elseif role == "HEALER" then
        return "|cFF00CC12"..HEALER.."|r"
    else
        return "|cFFFF3030"..DAMAGER.."|r"
    end
end

local function OnTooltipSetUnit()
    local _, instanceType = IsInInstance()
    if instanceType == "scenario" then return end
    local _, unit = GameTooltip:GetUnit()
    if unit and UnitIsPlayer(unit) and ((UnitInParty(unit) or UnitInRaid(unit)) and GetNumGroupMembers() > 0) then
        local leaderText = UnitIsGroupLeader(unit) and "|cfFFFFFFF - "..LEADER.."|r" or ""
        GameTooltip:AddLine(ROLE..": "..GetLFDRole(unit)..leaderText)
    end
end

if E.newPatch then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
else
    GameTooltip:HookScript("OnTooltipSetUnit", OnTooltipSetUnit)
end