local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Release
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoRelease")

local cfg = C.automation

local BG_MAPS = {
    [123] = true, -- Wintergrasp
    [244] = true, -- Tol Barad
    [588] = true, -- Ashran
    [622] = true, -- Stormshield
    [624] = true, -- Warspear
}

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.auto_release then return end

    self:RegisterEvent("PLAYER_DEAD", function()
        local selfRes = C_DeathInfo.GetSelfResurrectOptions()
        if selfRes and #selfRes > 0 then return end

        local inBattlefield = false
        for i = 1, GetMaxBattlefieldID() do
            if GetBattlefieldStatus(i) == "active" then
                inBattlefield = true
                break
            end
        end

        local areaID = C_Map.GetBestMapForUnit("player") or 0
        if BG_MAPS[areaID] or inBattlefield then
            RepopMe()
        end
    end)
end
