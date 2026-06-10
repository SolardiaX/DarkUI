local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Set Role
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("SetRole")

local cfg = C.automation

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.auto_role then return end

    local prev = 0

    local function setRole()
        if E.myLevel >= 10 and not InCombatLockdown() and IsInGroup() and not IsPartyLFG() then
            local spec = C_SpecializationInfo.GetSpecialization()
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

    RolePollPopup:UnregisterEvent("ROLE_POLL_BEGIN")

    self:RegisterEvent("PLAYER_TALENT_UPDATE", setRole)
    self:RegisterEvent("GROUP_ROSTER_UPDATE", setRole)
end
