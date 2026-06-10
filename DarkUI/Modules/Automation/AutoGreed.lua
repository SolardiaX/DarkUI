local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Auto Greed
------------------------------------------------------------------------

local module = E:Module("Automation"):Sub("AutoGreed")

local cfg = C.automation

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.auto_greed then return end
    if IsPlayerAtEffectiveMaxLevel() then return end

    self:RegisterEvent("START_LOOT_ROLL", function(_, _, id)
        if not id then return end
        local _, _, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(id)
        if quality == 2 and not BoP then
            if canDisenchant then
                RollOnLoot(id, 3)
            else
                RollOnLoot(id, 2)
            end
        end
    end)
end
