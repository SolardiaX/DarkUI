local E, C, L = select(2, ...):unpack()

if C.automation.auto_role ~= true then return end

----------------------------------------------------------------------------------------
--	Automatically sets your role(Auto role setter by iSpawnAtHome)
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("SetRole")

local InCombatLockdown = InCombatLockdown
local IsInGroup, IsPartyLFG = IsInGroup, IsPartyLFG
local GetSpecialization = GetSpecialization
local GetSpecializationRole = GetSpecializationRole
local GetTime = GetTime
local RolePollPopup = RolePollPopup
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitSetRole = UnitSetRole

local prev = 0
local function setRole()
    if E.myLevel >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG() then
        local spec = GetSpecialization()
        if spec then
            local role = GetSpecializationRole(spec)
            if UnitGroupRolesAssigned("player") ~= role then
                local t = GetTime()
                if t - prev > 2 then
                    prev = t
                    UnitSetRole("player", role)
                end
            end
        else
            UnitSetRole("player", "No Role")
        end
    end
end

module:RegisterEvent("PLAYER_LOGIN PLAYER_TALENT_UPDATE GROUP_ROSTER_UPDATE", function(_, event)
    if event == "PLAYER_LOGIN" then
        RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")
    else
        setRole()
    end
end)
