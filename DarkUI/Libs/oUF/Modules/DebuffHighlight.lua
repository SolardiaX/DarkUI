----------------------------------------------------------------------------------------
--    Based on oUF_DebuffHighlight(by Ammo)
----------------------------------------------------------------------------------------
local _, ns = ...
local oUF = ns.oUF

local class = select(2, UnitClass('player'))

local CanDispel = {
    DRUID = {Magic = false, Curse = true, Poison = true},
    EVOKER = {Magic = false, Curse = true, Poison = true, Disease = true},
    MAGE = {Curse = true},
    MONK = {Magic = false, Poison = true, Disease = true},
    PALADIN = {Magic = false, Poison = true, Disease = true},
    PRIEST = {Magic = false, Disease = true},
    SHAMAN = {Magic = false, Curse = true}
}

local dispellist = CanDispel[class] or {}
local origColors = {}
local origBorderColors = {}

local function GetDebuffType(unit, filter)
    if not UnitCanAssist("player", unit) then return nil end
    local i = 1
    while true do
        local auraData = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
        if not auraData then break end
        if not auraData.texture then break end
        if auraData.dispelName and not filter or (filter and dispellist[auraData.dispelName]) then
            return auraData.debufftype, auraData.texture
        end
        i = i + 1
    end
end

local function CheckSpec()
    local spec = GetSpecialization()

    if class == "DRUID" then
        if spec == 4 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    elseif class == "MONK" then
        if spec == 2 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    elseif class == "PALADIN" then
        if spec == 1 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    elseif class == "PRIEST" then
        if spec == 3 then
            dispellist.Magic = false
        else
            dispellist.Magic = true
        end
    elseif class == "SHAMAN" then
        if spec == 3 then
            dispellist.Magic = true
        else
            dispellist.Magic = false
        end
    end
end

local function Update(object, _, unit)
    if object.unit ~= unit then return end
    local debuffType, texture = GetDebuffType(unit, object.DebuffHighlightFilter)
    if debuffType then
        local color = DebuffTypeColor[debuffType]
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            if object.DebuffHighlightBackdrop then
                object:SetBackdropColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 1)
            end
            if object.DebuffHighlightBackdropBorder then
                object:SetBackdropBorderColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 1)
            end
        elseif object.DebuffHighlightUseTexture then
            object.DebuffHighlight:SetTexture(texture)
        else
            object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, object.DebuffHighlightAlpha or 0.5)
        end
    else
        if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
            local color
            if object.DebuffHighlightBackdrop then
                color = origColors[object]
                object:SetBackdropColor(color.r, color.g, color.b, color.a)
            end
            if object.DebuffHighlightBackdropBorder then
                color = origBorderColors[object]
                object:SetBackdropBorderColor(color.r, color.g, color.b, color.a)
            end
        elseif object.DebuffHighlightUseTexture then
            object.DebuffHighlight:SetTexture(nil)
        else
            local color = origColors[object]
            object.DebuffHighlight:SetVertexColor(color.r, color.g, color.b, color.a)
        end
    end
end

local function Enable(object)
    -- If we're not highlighting this unit return
    if not object.DebuffHighlightBackdrop and not object.DebuffHighlightBackdropBorder and not object.DebuffHighlight then
        return
    end
    -- If we're filtering highlights and we're not of the dispelling type, return
    if object.DebuffHighlightFilter and not CanDispel[class] then
        return
    end

    -- Make sure aura scanning is active for this object
    object:RegisterEvent("UNIT_AURA", Update)
    object:RegisterEvent("PLAYER_TALENT_UPDATE", CheckSpec, true)
    CheckSpec()

    if object.DebuffHighlightBackdrop or object.DebuffHighlightBackdropBorder then
        local r, g, b, a = object:GetBackdropColor()
        origColors[object] = {r = r, g = g, b = b, a = a}
        r, g, b, a = object:GetBackdropBorderColor()
        origBorderColors[object] = {r = r, g = g, b = b, a = a}
    elseif not object.DebuffHighlightUseTexture then
        local r, g, b, a = object.DebuffHighlight:GetVertexColor()
        origColors[object] = {r = r, g = g, b = b, a = a}
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
