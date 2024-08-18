local E, C, L = select(2, ...):unpack()

if not C.automation.auto_greed or IsPlayerAtEffectiveMaxLevel() then return end

----------------------------------------------------------------------------------------
--    Auto greed/disenchant on green items(by Tekkub)
----------------------------------------------------------------------------------------
local module = E:Module("Automation"):Sub("AutoGreed")

local GetLootRollItemInfo = GetLootRollItemInfo
local GetLootRollItemLink = GetLootRollItemLink
local GetItemInfo = GetItemInfo
local RollOnLoot = RollOnLoot

module:RegisterEvent("START_LOOT_ROLL", function(_, _, id)
    local _, _, _, quality, BoP, _, _, canDisenchant = GetLootRollItemInfo(id)
    if id and quality == 2 and not BoP then
        local link = GetLootRollItemLink(id)
        local _, _, _, ilevel = GetItemInfo(link)
        if canDisenchant and ilevel > 270 then
            RollOnLoot(id, 3)
        else
            RollOnLoot(id, 2)
        end
    end
end)
