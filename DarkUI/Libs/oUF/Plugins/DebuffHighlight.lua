------------------------------------------------------------------------
-- DebuffHighlight (based on ShestakUI DispelColor, adapted for DarkUI)
------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF

local class = select(2, UnitClass("player"))

local CanDispel = {
    DRUID = { Magic = false, Curse = true, Poison = true },
    EVOKER = { Magic = false, Curse = true, Poison = true, Disease = true },
    MAGE = { Curse = true },
    MONK = { Magic = false, Poison = true, Disease = true },
    PALADIN = { Magic = false, Poison = true, Disease = true },
    PRIEST = { Magic = false, Disease = true },
    SHAMAN = { Magic = false, Curse = true },
}

local dispellist = CanDispel[class] or {}

local color_magic = CreateColor(0, 0, 0, 0)
local color_curse = CreateColor(0, 0, 0, 0)
local color_disease = CreateColor(0, 0, 0, 0)
local color_poison = CreateColor(0, 0, 0, 0)
local color_bleed = CreateColor(0, 0, 0, 0)

local dispelColorCurve = C_CurveUtil.CreateColorCurve()
dispelColorCurve:SetType(Enum.LuaCurveType.Step)

local origColors = {}
local origBorderColors = {}

local function CheckSpec()
    local spec = C_SpecializationInfo.GetSpecialization()

    if class == "DRUID" then
        if spec == 4 then
            color_magic = CreateColor(0.2, 0.6, 1)
            dispellist.Magic = true
        else
            color_magic = CreateColor(0, 0, 0, 0)
            dispellist.Magic = false
        end
    elseif class == "EVOKER" then
        if spec == 2 then
            color_magic = CreateColor(0.2, 0.6, 1)
            dispellist.Magic = true
        else
            color_magic = CreateColor(0, 0, 0, 0)
            dispellist.Magic = false
        end
        if C_SpellBook.IsSpellKnown(374251) then
            color_bleed = CreateColor(1, 0, 0.5)
            color_curse = CreateColor(0.6, 0, 1)
            color_disease = CreateColor(0.6, 0.4, 0)
        else
            color_bleed = CreateColor(0, 0, 0, 0)
            color_curse = CreateColor(0.6, 0, 1)
            color_disease = CreateColor(0, 0, 0, 0)
        end
    elseif class == "MAGE" then
        color_curse = CreateColor(0.6, 0, 1)
    elseif class == "MONK" then
        if spec == 2 then
            color_magic = CreateColor(0.2, 0.6, 1)
            dispellist.Magic = true
        else
            color_magic = CreateColor(0, 0, 0, 0)
            dispellist.Magic = false
        end
        color_poison = CreateColor(0, 0.6, 0)
        color_disease = CreateColor(0.6, 0.4, 0)
    elseif class == "PALADIN" then
        if spec == 1 then
            color_magic = CreateColor(0.2, 0.6, 1)
            dispellist.Magic = true
        else
            color_magic = CreateColor(0, 0, 0, 0)
            dispellist.Magic = false
        end
        if C_SpellBook.IsSpellKnown(213644) then
            color_poison = CreateColor(0, 0.6, 0)
            color_disease = CreateColor(0.6, 0.4, 0)
        else
            color_poison = CreateColor(0, 0, 0, 0)
            color_disease = CreateColor(0, 0, 0, 0)
        end
    elseif class == "PRIEST" then
        if spec == 3 then
            color_magic = CreateColor(0, 0, 0, 0)
            dispellist.Magic = false
        else
            color_magic = CreateColor(0.2, 0.6, 1)
            dispellist.Magic = true
        end
        color_disease = CreateColor(0.6, 0.4, 0)
    elseif class == "SHAMAN" then
        if spec == 3 then
            color_magic = CreateColor(0.2, 0.6, 1)
            dispellist.Magic = true
        else
            color_magic = CreateColor(0, 0, 0, 0)
            dispellist.Magic = false
        end
        if C_SpellBook.IsSpellKnown(383013) then
            color_poison = CreateColor(0, 0.6, 0)
        else
            color_poison = CreateColor(0, 0, 0, 0)
        end
        color_curse = CreateColor(0.6, 0, 1)
    end

    dispelColorCurve:SetToDefaults()
    dispelColorCurve:ClearPoints()

    local dispelIndex = {
        [1] = color_magic,
        [2] = color_curse,
        [3] = color_disease,
        [4] = color_poison,
        [9] = CreateColor(0, 0, 0, 0),
        [11] = color_bleed,
    }

    for i, color in pairs(dispelIndex) do
        dispelColorCurve:AddPoint(i, color)
    end
end

local function Update(object, _, unit)
    if object.unit ~= unit then return end
    if not UnitCanAssist("player", unit) then
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            if object.DebuffHighlightBackdrop then
                local c = origColors[object]
                if c then object:SetBackdropColor(c.r, c.g, c.b, c.a) end
            end
            if object.DebuffHighlightBackdropBorder then
                local c = origBorderColors[object]
                if c then object:SetBackdropBorderColor(c.r, c.g, c.b, c.a) end
            end
        elseif object.DebuffHighlight then
            local c = origColors[object]
            if c then object.DebuffHighlight:SetVertexColor(c.r, c.g, c.b, c.a) end
        end
        return
    end

    local filter = object.DebuffHighlightFilter
    local aura, color

    if filter then
        aura = C_UnitAuras.GetAuraDataByIndex(unit, 1, "HARMFUL|RAID_PLAYER_DISPELLABLE")
    else
        aura = C_UnitAuras.GetAuraDataByIndex(unit, 1, "HARMFUL")
    end

    if aura and aura.auraInstanceID then
        color = C_UnitAuras.GetAuraDispelTypeColor(unit, aura.auraInstanceID, dispelColorCurve)
    end

    if color and color.a and (issecretvalue(color.a) or color.a > 0) then
        local r, g, b, a = color:GetRGBA()
        local alpha = object.DebuffHighlightAlpha or 0.5
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            if object.DebuffHighlightBackdrop then
                object:SetBackdropColor(r, g, b, alpha)
            end
            if object.DebuffHighlightBackdropBorder then
                object:SetBackdropBorderColor(r, g, b, alpha)
            end
        elseif object.DebuffHighlight then
            object.DebuffHighlight:SetVertexColor(r, g, b, alpha)
        end
    else
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            if object.DebuffHighlightBackdrop then
                local c = origColors[object]
                if c then object:SetBackdropColor(c.r, c.g, c.b, c.a) end
            end
            if object.DebuffHighlightBackdropBorder then
                local c = origBorderColors[object]
                if c then object:SetBackdropBorderColor(c.r, c.g, c.b, c.a) end
            end
        elseif object.DebuffHighlight then
            local c = origColors[object]
            if c then object.DebuffHighlight:SetVertexColor(c.r, c.g, c.b, c.a) end
        end
    end
end

local function Enable(object)
    if not object.DebuffHighlightBackdrop and not object.DebuffHighlightBackdropBorder and not object.DebuffHighlight then
        return
    end

    if object.DebuffHighlightFilter and not CanDispel[class] then
        return
    end

    object:RegisterEvent("UNIT_AURA", Update)
    object:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec, true)
    CheckSpec()

    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
        local r, g, b, a = object:GetBackdropColor()
        origColors[object] = { r = r, g = g, b = b, a = a }
        r, g, b, a = object:GetBackdropBorderColor()
        origBorderColors[object] = { r = r, g = g, b = b, a = a }
    elseif object.DebuffHighlight then
        local r, g, b, a = object.DebuffHighlight:GetVertexColor()
        origColors[object] = { r = r, g = g, b = b, a = a }
    end

    return true
end

local function Disable(object)
    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder or object.DebuffHighlight then
        object:UnregisterEvent("UNIT_AURA", Update)
        object:UnregisterEvent("PLAYER_TALENT_UPDATE", CheckSpec)
    end
end

oUF:AddElement("DebuffHighlight", Update, Enable, Disable)

for _, frame in ipairs(oUF.objects) do Enable(frame) end
