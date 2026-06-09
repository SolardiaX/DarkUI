local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Unit Role
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("UnitRole")
local cfg = C.tooltip

------------------------------------------------------------------------

local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsPlayer = UnitIsPlayer
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local GetNumGroupMembers = GetNumGroupMembers

local function getLFDRole(unit)
    local role = UnitGroupRolesAssigned(unit)

    if role == "NONE" then
        return "|cFFB5B5B5" .. NO_ROLE .. "|r"
    elseif role == "TANK" then
        return "|cFF0070DE" .. TANK .. "|r"
    elseif role == "HEALER" then
        return "|cFF00CC12" .. HEALER .. "|r"
    else
        return "|cFFFF3030" .. DAMAGER .. "|r"
    end
end

local function onTooltipSetUnit(self)
    if self ~= GameTooltip or self:IsForbidden() then return end
    local _, instanceType = IsInInstance()
    if instanceType == "scenario" then return end
    local _, unit = GameTooltip:GetUnit()
    if unit and UnitIsPlayer(unit) and ((UnitInParty(unit) or UnitInRaid(unit)) and GetNumGroupMembers() > 0) then
        local leaderText = UnitIsGroupLeader(unit) and "|cFFFFFFFF - " .. LEADER .. "|r" or ""
        GameTooltip:AddLine(ROLE .. ": " .. getLFDRole(unit) .. leaderText)
    end
end

------------------------------------------------------------------------

function module:OnInit()
    if not cfg.enable or not cfg.unit_role then return end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, onTooltipSetUnit)
end
