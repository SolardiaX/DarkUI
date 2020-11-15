local E, C, L = select(2, ...):unpack()

if not C.aura.style or not C.aura.style.show_caster then return end

----------------------------------------------------------------------------------------
--	Tells you who cast a buff or debuff in its tooltip
----------------------------------------------------------------------------------------

local GetUnitName, UnitAura, UnitBuff, UnitDebuff = GetUnitName, UnitAura, UnitBuff, UnitDebuff
local UnitIsPlayer, UnitClass, UnitReaction = UnitIsPlayer, UnitClass, UnitReaction
local CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS
local FACTION_BAR_COLORS = FACTION_BAR_COLORS
local format, select = format, select
local hooksecurefunc = hooksecurefunc
local GameTooltip = GameTooltip

local funcs = {
    SetUnitAura   = UnitAura,
    SetUnitBuff   = UnitBuff,
    SetUnitDebuff = UnitDebuff
}

local function addAuraSource(self, func, unit, index, filter)
    local srcUnit = select(7, func(unit, index, filter))
    if srcUnit then
        local src = GetUnitName(srcUnit, true)
        if srcUnit == "pet" or srcUnit == "vehicle" then
            src = format("%s (|cff%02x%02x%02x%s|r)", src,
                         E.color.r * 255, E.color.g * 255, E.color.b * 255, GetUnitName("player", true))
        else
            local partypet = srcUnit:match("^partypet(%d+)$")
            local raidpet = srcUnit:match("^raidpet(%d+)$")
            if partypet then
                src = format("%s (%s)", src, GetUnitName("party" .. partypet, true))
            elseif raidpet then
                src = format("%s (%s)", src, GetUnitName("raid" .. raidpet, true))
            end
        end
        if UnitIsPlayer(srcUnit) then
            local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass(srcUnit))]
            if color then
                src = format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, src)
            end
        else
            local color = FACTION_BAR_COLORS[UnitReaction(srcUnit, "player")]
            if color then
                src = format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, src)
            end
        end
        self:AddLine(L.AURA_CAST_BY .. " " .. src)
        self:Show()
    end
end

for k, v in pairs(funcs) do
    hooksecurefunc(GameTooltip, k, function(self, unit, index, filter) addAuraSource(self, v, unit, index, filter) end)
end
