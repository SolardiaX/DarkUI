local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Shift Mark
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("ShiftMark")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.shift_mark then return end

    local markerIcons = {}
    for i = 1, 8 do
        markerIcons[i] = format("|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_%d:14|t", i)
    end

    WorldFrame:HookScript("OnMouseDown", function(_, button)
        if button == "LeftButton" and IsShiftKeyDown() and UnitExists("mouseover") then
            if (GetNumGroupMembers() > 0 and not UnitInRaid("player"))
                or UnitIsGroupLeader("player")
                or UnitIsGroupAssistant("player") then

                local current = GetRaidTargetIndex("mouseover") or 0
                local next = (current % 8) + 1
                SetRaidTarget("mouseover", next)
            end
        end
    end)
end
