local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- SpellID
------------------------------------------------------------------------
local module = E:Module("Tooltip"):Sub("SpellID")

local cfg = C.tooltip
local parent = E:Module("Tooltip")
local whiteTooltip = parent.whiteTooltips
local InfoColor = parent.InfoColor

local strmatch = string.match
local UnitIsPlayer = UnitIsPlayer
local UnitTokenFromGUID = UnitTokenFromGUID
local UnitExists = UnitExists

local function addLine(self, id, linkType, noadd)
    if issecretvalue(id) then return end
    for i = 1, self:NumLines() do
        local line = _G[self:GetName() .. "TextLeft" .. i]
        if not line then break end
        local text = line:GetText()
        if not canaccessvalue(text) then break end
        if text and string.find(text, id) then return end
    end
    if not noadd then self:AddLine(" ") end
    self:AddDoubleLine(linkType, InfoColor .. id .. "|r")
    self:Show()
end

local function attachByAuraInstanceID(self, ...)
    local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(...)
    local id = aura and aura.spellId
    if id then addLine(self, id, L.TOOLTIP_SPELL_ID) end
end

function module:OnInit()
    if not cfg.enable or not cfg.spell_id then return end

    hooksecurefunc(GameTooltip, "SetUnitAura", function(self, ...)
        local unit, slot = ...
        if not unit and not slot then return end
        local aura = C_UnitAuras.GetAuraDataBySlot(unit, slot)
        local id = aura and aura.spellId
        if id then addLine(self, id, L.TOOLTIP_SPELL_ID) end
    end)

    hooksecurefunc(GameTooltip, "SetUnitBuffByAuraInstanceID", attachByAuraInstanceID)
    hooksecurefunc(GameTooltip, "SetUnitDebuffByAuraInstanceID", attachByAuraInstanceID)
    hooksecurefunc(GameTooltip, "SetUnitAuraByAuraInstanceID", attachByAuraInstanceID)

    hooksecurefunc("SetItemRef", function(link)
        local id = tonumber(link:match("spell:(%d+)"))
        if id then addLine(ItemRefTooltip, id, L.TOOLTIP_SPELL_ID) end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self, data)
        if self ~= GameTooltip or self:IsForbidden() then return end
        if data and data.id then
            addLine(self, data.id, L.TOOLTIP_SPELL_ID)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self, data)
        if whiteTooltip[self] and not self:IsForbidden() then
            if data and data.id then
                addLine(self, data.id, L.TOOLTIP_ITEM_ID)
            end
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(self, data)
        if self:IsForbidden() then return end
        local lineData = data.lines and data.lines[1]
        local tooltipType = lineData and lineData.tooltipType
        if not tooltipType then return end

        if tooltipType == 0 then
            addLine(self, lineData.tooltipID, L.TOOLTIP_ITEM_ID)
        elseif tooltipType == 1 then
            addLine(self, lineData.tooltipID, L.TOOLTIP_SPELL_ID)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Toy, function(self, data)
        if self ~= GameTooltip or self:IsForbidden() then return end
        if data and data.id then
            addLine(self, data.id, L.TOOLTIP_ITEM_ID)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Currency, function(self, data)
        if self:IsForbidden() then return end
        if data and data.id then
            addLine(self, data.id, L.TOOLTIP_SPELL_ID)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.PetAction, function(self, data)
        if self:IsForbidden() then return end
        local lineData = data.lines and data.lines[1]
        local tooltipType = lineData and lineData.tooltipType
        if not tooltipType then return end

        if tooltipType == 0 then
            addLine(self, lineData.tooltipID, L.TOOLTIP_ITEM_ID)
        elseif tooltipType == 1 then
            addLine(self, lineData.tooltipID, L.TOOLTIP_SPELL_ID)
        end
    end)

    hooksecurefunc("QuestMapLogTitleButton_OnEnter", function(self)
        if self.questID then
            addLine(GameTooltip, self.questID, L.TOOLTIP_SPELL_ID)
        end
    end)

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(self, data)
        if self ~= GameTooltip or self:IsForbidden() then return end
        if not IsShiftKeyDown() then return end

        local guid = data and data.guid
        if not guid or not canaccessvalue(guid) then return end

        local unit = UnitTokenFromGUID(guid) or (UnitExists("mouseover") and "mouseover")
        if not unit or UnitIsPlayer(unit) then return end

        local npcID = strmatch(guid, "%-(%d+)%-%x+$")
        if npcID then
            addLine(self, npcID, L.TOOLTIP_NPC_ID)
        end
    end)
end
