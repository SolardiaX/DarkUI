local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Aura Caster Tooltip
----------------------------------------------------------------------------------------
local module = E:Module("Aura"):Sub("Caster")

local format, pcall = format, pcall

local function getSourceColor(srcUnit)
    if UnitIsPlayer(srcUnit) then
        local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass(srcUnit))]
        if color then return format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) end
    else
        local color = FACTION_BAR_COLORS[UnitReaction(srcUnit, "player")]
        if color then return format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255) end
    end
    return "|cffffffff"
end

local function addCasterLine(tooltip, data)
    if not data or not data.sourceUnit then return end

    local caster = data.sourceUnit
    if issecretvalue(caster) then
        local ok, name = pcall(UnitName, caster)
        if ok and name then
            tooltip:AddDoubleLine(L.AURA_CAST_BY or "Cast by:", name)
            tooltip:Show()
        end
    else
        local name = GetUnitName(caster, true)
        if name then
            local hexColor = getSourceColor(caster)
            tooltip:AddDoubleLine(L.AURA_CAST_BY or "Cast by:", hexColor .. name .. "|r")
            tooltip:Show()
        end
    end
end

function module:OnInit()
    if not C.aura or not C.aura.enable or not C.aura.show_caster then return end

    hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
        if self:IsForbidden() then return end
        local data = C_UnitAuras.GetAuraDataByIndex(...)
        addCasterLine(self, data)
    end)

    hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", function(self, ...)
        if self:IsForbidden() then return end
        local data = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
        addCasterLine(self, data)
    end)

    hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", function(self, ...)
        if self:IsForbidden() then return end
        local data = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
        addCasterLine(self, data)
    end)

    hooksecurefunc(GameTooltip, "SetUnitAuraByAuraInstanceID", function(self, ...)
        if self:IsForbidden() then return end
        local data = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
        addCasterLine(self, data)
    end)
end
