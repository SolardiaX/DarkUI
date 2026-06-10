local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Durability
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("Durability")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.slot_durability then return end

    local SLOTIDS = {}
    for _, slot in pairs({ "Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand" }) do
        SLOTIDS[slot] = GetInventorySlotInfo(slot .. "Slot")
    end

    local frame = CreateFrame("Frame", nil, CharacterFrame)

    local fontstrings = setmetatable({}, {
        __index = function(t, i)
            local gslot = _G["Character" .. i .. "Slot"]
            if not gslot then return nil end
            local fstr = gslot:CreateFontString(nil, "OVERLAY", "SystemFont_Outline_Small")
            fstr:SetPoint("BOTTOM", gslot, "BOTTOM", 0, 1)
            t[i] = fstr
            return fstr
        end,
    })

    local function RYGColorGradient(perc)
        local relperc = perc * 2 % 1
        if perc <= 0 then
            return 1, 0, 0
        elseif perc < 0.5 then
            return 1, relperc, 0
        elseif perc == 0.5 then
            return 1, 1, 0
        elseif perc < 1.0 then
            return 1 - relperc, 1, 0
        else
            return 0, 1, 0
        end
    end

    local function updateDurability()
        for slot, id in pairs(SLOTIDS) do
            local v1, v2 = GetInventoryItemDurability(id)
            if v1 and v2 and v2 ~= 0 then
                local str = fontstrings[slot]
                if str then
                    str:SetTextColor(RYGColorGradient(v1 / v2))
                    if v1 < v2 then
                        str:SetText(string.format("%d%%", v1 / v2 * 100))
                    else
                        str:SetText(nil)
                    end
                end
            else
                local str = rawget(fontstrings, slot)
                if str then str:SetText(nil) end
            end
        end
    end

    frame:SetScript("OnEvent", updateDurability)
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
end
