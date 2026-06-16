local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Item Icons
------------------------------------------------------------------------

local module = E:Module("Tooltip"):Sub("ItemIcons")
local cfg = C.tooltip
local whiteTooltip = E:Module("Tooltip").whiteTooltips

local strfind, gsub = strfind, gsub
local ICON_COORDS = "0:0:64:64:5:59:5:59"

local function setTooltipIcon(self, icon)
    local title = icon and _G[self:GetName() .. "TextLeft1"]
    local titleText = title and title:GetText()
    if titleText and not issecretvalue(titleText) and not strfind(titleText, ":20:20:") then
        title:SetFormattedText("|T%s:20:20:" .. ICON_COORDS .. ":%d|t %s", icon, 20, titleText)
    end

    for i = 2, self:NumLines() do
        local line = _G[self:GetName() .. "TextLeft" .. i]
        if not line then break end
        local text = line:GetText()
        if text and not issecretvalue(text) and text ~= " " then
            local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:" .. ICON_COORDS .. "|t")
            if count > 0 then line:SetText(newText) end
        end
    end
end

local GetTextureByType = {
    [Enum.TooltipDataType.Item] = function(id)
        return C_Item.GetItemIconByID(id)
    end,
    [Enum.TooltipDataType.Toy] = function(id)
        return C_Item.GetItemIconByID(id)
    end,
    [Enum.TooltipDataType.Spell] = function(id)
        return C_Spell.GetSpellTexture(id)
    end,
}

function module:OnInit()
    if not cfg.enable or not cfg.item_icon then return end

    for tooltipType, getTex in next, GetTextureByType do
        TooltipDataProcessor.AddTooltipPostCall(tooltipType, function(self, data)
            if whiteTooltip[self] and not self:IsForbidden() then
                if data and data.id then
                    setTooltipIcon(self, getTex(data.id))
                end
            end
        end)
    end

    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Macro, function(self, data)
        if whiteTooltip[self] and not self:IsForbidden() then
            local lineData = data.lines and data.lines[1]
            local tooltipType = lineData and lineData.tooltipType
            if not tooltipType then return end

            if tooltipType == 0 then
                setTooltipIcon(self, C_Item.GetItemIconByID(lineData.tooltipID))
            elseif tooltipType == 1 then
                setTooltipIcon(self, C_Spell.GetSpellTexture(lineData.tooltipID))
            end
        end
    end)

    hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
        setTooltipIcon(self)
    end)
end
