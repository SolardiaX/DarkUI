local E, C, L = select(2, ...):unpack()

if C.tooltip.enable ~= true or C.tooltip.spell_id ~= true then return end

----------------------------------------------------------------------------------------
--	Spell/Item IDs(idTip by Silverwind)
----------------------------------------------------------------------------------------

local _G = _G
local UnitAura = UnitAura
local IsModifierKeyDown = IsModifierKeyDown
local hooksecurefunc = hooksecurefunc
local GameTooltip = GameTooltip
local ItemRefTooltip = ItemRefTooltip
local ItemRefShoppingTooltip1, ItemRefShoppingTooltip2 = ItemRefShoppingTooltip1, ItemRefShoppingTooltip2
local ShoppingTooltip1, ShoppingTooltip2 = ShoppingTooltip1, ShoppingTooltip2

local function addLine(self, id, isItem)
    for i = 1, self:NumLines() do
        local line = _G[self:GetName().."TextLeft"..i]
        if not line then break end
        local text = line:GetText()
        if text and (text:match(L.TOOLTIP_ITEM_ID) or text:match(L.TOOLTIP_SPELL_ID)) then return end
    end
    if isItem then
        self:AddLine("|cffffffff"..L.TOOLTIP_ITEM_ID.." "..id)
    else
        self:AddLine("|cffffffff"..L.TOOLTIP_SPELL_ID.." "..id)
    end
    self:Show()
end

local function OnTooltipSetSpell(self)
    local _, id = self:GetSpell()
    if id then addLine(self, id) end
end

hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
    local id = select(10, UnitAura(...))
    if id then addLine(self, id) end
    if id and IsModifierKeyDown() then print(UnitAura(...)..": "..id) end
end)

local function attachByAuraInstanceID(self, ...)
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
    local id = aura and aura.spellId
    if id then addLine(self, id) end
    if debuginfo == true and id and IsModifierKeyDown() then print(UnitAura(...)..": "..id) end
end
hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", attachByAuraInstanceID)
hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", attachByAuraInstanceID)
hooksecurefunc("SetItemRef", function(link)
    local id = tonumber(link:match("spell:(%d+)"))
    if id then addLine(ItemRefTooltip, id) end
end)

local function attachItemTooltip(self)
    local _, link = self:GetItem()
    if not link then return end
    local id = link:match("item:(%d+):")
    if id then addLine(self, id, true) end
end

if E.newPatch then
    local function attachItemTooltip(self)
        local _, link = TooltipUtil.GetDisplayedItem(self)
        if not link then return end
        local id = link:match("item:(%d+):")
        if id then addLine(self, id, true) end
    end
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, attachItemTooltip)
else
    GameTooltip:HookScript("OnTooltipSetSpell", OnTooltipSetSpell)
    GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
    ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
    ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
    ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
    ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
    ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
end
