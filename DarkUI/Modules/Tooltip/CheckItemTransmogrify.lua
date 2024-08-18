local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.item_transmogrify ~= true then return end

----------------------------------------------------------------------------------------
--    Displays items can not be transmogrified(Will It Mog by Nathanyel)
----------------------------------------------------------------------------------------

local GetItemInfo = GetItemInfo
local C_Transmog_GetItemInfo = C_Transmog.GetItemInfo
local gsub = gsub
local ERR_TRANSMOGRIFY_INVALID_ITEM_TYPE = ERR_TRANSMOGRIFY_INVALID_ITEM_TYPE
local ERR_TRANSMOGRIFY_INVALID_SOURCE = ERR_TRANSMOGRIFY_INVALID_SOURCE
local ERR_TRANSMOGRIFY_MISMATCH = ERR_TRANSMOGRIFY_MISMATCH
local LE_ITEM_CLASS_WEAPON = LE_ITEM_CLASS_WEAPON
local LE_ITEM_CLASS_ARMOR = LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_MISCELLANEOUS = LE_ITEM_CLASS_MISCELLANEOUS
local GameTooltip = GameTooltip
local ItemRefTooltip = ItemRefTooltip

-- Slots
local locs = {
    ["INVTYPE_HEAD"]           = 1,
    ["INVTYPE_SHOULDER"]       = 1,
    ["INVTYPE_CHEST"]          = 1,
    ["INVTYPE_ROBE"]           = 1,
    ["INVTYPE_WAIST"]          = 1,
    ["INVTYPE_LEGS"]           = 1,
    ["INVTYPE_FEET"]           = 1,
    ["INVTYPE_WRIST"]          = 1,
    ["INVTYPE_HAND"]           = 1,
    ["INVTYPE_CLOAK"]          = 1,
    ["INVTYPE_WEAPON"]         = 1,
    ["INVTYPE_SHIELD"]         = 1,
    ["INVTYPE_2HWEAPON"]       = 1,
    ["INVTYPE_HOLDABLE"]       = 1,
    ["INVTYPE_WEAPONMAINHAND"] = 1,
    ["INVTYPE_WEAPONOFFHAND"]  = 1,
    ["INVTYPE_RANGED"]         = 1,
    ["INVTYPE_THROWN"]         = 1,
    ["INVTYPE_RANGEDRIGHT"]    = 1,
}

local WIMtooltip = function(self, _)
    local slot = self.slot
    if not slot then return end

    local _, link = self:GetItem()
    if not link then return end
    local itemID = link:match("item:(%d+)")
    if not itemID then return end

    local rndench = link:match("item:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:[^:]+:([^:]+):")
    GetItemInfo(itemID)
    local _, _, quality, _, _, _, _, _, slot, _, _, class, subClass = GetItemInfo(itemID)
    -- No weapon or armor, or misc 'weapon', or invalid slot
    if not class or not (class == LE_ITEM_CLASS_WEAPON or class == LE_ITEM_CLASS_ARMOR) or (subClass == LE_ITEM_CLASS_MISCELLANEOUS and (class == LE_ITEM_CLASS_WEAPON or slot == "INVTYPE_CLOAK")) or not locs[slot] then return end
    local canBeChanged, noChangeReason, canBeSource, noSourceReason = C_Transmog_GetItemInfo(itemID)

    if rndench and rndench ~= "0" and noSourceReason == "NO_STATS" then
        canBeChanged = true
        canBeSource = true
    end

    if (quality < 2 or subClass == LE_ITEM_CLASS_MISCELLANEOUS) and not (canBeChanged or canBeSource) then return end

    if noChangeReason or noSourceReason then
        self:AddLine(" ")
    end

    if subClass == LE_ITEM_CLASS_MISCELLANEOUS and class ~= "INVTYPE_HOLDABLE" then
        self:AddLine("|cffff0000" .. ERR_TRANSMOGRIFY_INVALID_ITEM_TYPE .. "|r", nil, nil, nil, true)
    end

    if noChangeReason then
        self:AddLine(gsub("|cffff0000" .. (_G["ERR_TRANSMOGRIFY_" .. noChangeReason] or ERR_TRANSMOGRIFY_INVALID_SOURCE), "%%s", ""), nil, nil, nil, true)
    end

    if noSourceReason and noSourceReason ~= noChangeReason then
        self:AddLine(gsub("|cffff0000" .. (_G["ERR_TRANSMOGRIFY_" .. noSourceReason] or ERR_TRANSMOGRIFY_MISMATCH), "%%s", ""), nil, nil, nil, true)
    end
end

-- GameTooltip:HookScript("OnTooltipSetItem", WIMtooltip)
-- ItemRefTooltip:HookScript("OnTooltipSetItem", WIMtooltip)

TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, WIMtooltip)