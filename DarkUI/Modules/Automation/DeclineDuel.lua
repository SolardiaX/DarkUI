local E, C, L = select(2, ...):unpack()

if not C.automation.decline_duel then return end

----------------------------------------------------------------------------------------
--	Auto decline duel
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("DeclineDuel")

local CancelDuel = CancelDuel
local RaidNotice_AddMessage = RaidNotice_AddMessage
local RaidWarningFrame = RaidWarningFrame
local StaticPopup_Hide = StaticPopup_Hide
local C_PetBattles_CancelPVPDuel = C_PetBattles.CancelPVPDuel
local print, format = print, format

module:RegisterEvent("DUEL_REQUESTED PET_BATTLE_PVP_DUEL_REQUESTED", function(_, event, name)
    if event == "DUEL_REQUESTED" then
        CancelDuel()
        RaidNotice_AddMessage(RaidWarningFrame, L.INFO_DUEL..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
        print(format("|cffffff00"..L.INFO_DUEL..name.."."))
        StaticPopup_Hide("DUEL_REQUESTED")
    elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
        C_PetBattles_CancelPVPDuel()
        RaidNotice_AddMessage(RaidWarningFrame, L.INFO_PET_DUEL..name, {r = 0.41, g = 0.8, b = 0.94}, 3)
        print(format("|cffffff00"..L.INFO_PET_DUEL..name.."."))
        StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
    end
end)
