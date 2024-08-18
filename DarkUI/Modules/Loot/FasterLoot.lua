local E, C, L = select(2, ...):unpack()

if not C.loot.faster_loot then return end

----------------------------------------------------------------------------------------
--    Faster auto looting
----------------------------------------------------------------------------------------
local module = E:Module("Loot"):Sub("FasterLoot")

local tDelay = 0
local LOOT_DELAY = 0.3

module:RegisterEvent("LOOT_READY", function ()
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        if (GetTime() - tDelay) >= LOOT_DELAY then
            for i = GetNumLootItems(), 1, -1 do
                LootSlot(i)
            end
            tDelay = GetTime()
        end
    end
end)