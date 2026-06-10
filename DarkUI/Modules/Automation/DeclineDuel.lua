local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Decline Duel
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("DeclineDuel")

local cfg = C.automation

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.decline_duel then return end

    self:RegisterEvent("DUEL_REQUESTED", function(_, _, name)
        CancelDuel()
        StaticPopup_Hide("DUEL_REQUESTED")
        print(format("|cffffff00" .. (L.INFO_DUEL or "Duel declined: ") .. (name or "") .. ".|r"))
    end)

    self:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED", function(_, _, name)
        C_PetBattles.CancelPVPDuel()
        StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
        print(format("|cffffff00" .. (L.INFO_PET_DUEL or "Pet duel declined: ") .. (name or "") .. ".|r"))
    end)
end
