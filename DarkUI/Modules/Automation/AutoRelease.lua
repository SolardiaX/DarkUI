local E, C, L = select(2, ...):unpack()

if not C.automation.auto_release then return end

----------------------------------------------------------------------------------------
--	Auto release the spirit in battlegrounds
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("AutoRelease")

local GetMaxBattlefieldID, GetBattlefieldStatus = GetMaxBattlefieldID, GetBattlefieldStatus
local C_DeathInfo_GetSelfResurrectOptions = C_DeathInfo.GetSelfResurrectOptions
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local RepopMe = RepopMe

module:RegisterEvent("PLAYER_DEAD", function()
    local inBattlefield = false
    for i = 1, GetMaxBattlefieldID() do
        local status = GetBattlefieldStatus(i)
        if status == "active" then inBattlefield = true end
    end
    if C_DeathInfo_GetSelfResurrectOptions() and #C_DeathInfo_GetSelfResurrectOptions() > 0 then return end
    local areaID = C_Map_GetBestMapForUnit("player") or 0
    if areaID == 123 or areaID == 244 or areaID == 588 or areaID == 622 or areaID == 624 or inBattlefield == true then
        RepopMe()
    end
end)