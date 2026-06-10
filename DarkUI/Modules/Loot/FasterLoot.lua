local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- FasterLoot
------------------------------------------------------------------------
local module = E:Module("Loot"):Sub("FasterLoot")

local cfg = C.loot

local GetTime = GetTime
local GetNumLootItems = GetNumLootItems
local LootSlot = LootSlot

local LOOT_DELAY = 0.3
local lastLootTime = 0

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------
function module:OnInit()
    if not cfg.faster_loot then
        return
    end

    self:RegisterEvent("LOOT_READY", function()
        if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
            if (GetTime() - lastLootTime) >= LOOT_DELAY then
                for i = GetNumLootItems(), 1, -1 do
                    LootSlot(i)
                end
                lastLootTime = GetTime()
            end
        end
    end)
end
