local E, C, L = select(2, ...):unpack()

if not C.stats.enable then return end

----------------------------------------------------------------------------------------
--    DataText Core (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local CreateFrame = CreateFrame
local CreateVector2D = CreateVector2D
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local IsAltKeyDown = IsAltKeyDown
local UnitPosition = UnitPosition
local hooksecurefunc = hooksecurefunc
local format, select, strsplit, tinsert = format, select, strsplit, tinsert
local pairs, ipairs = pairs, ipairs
local match = string.match
local mod, floor, modf = mod, math.floor, math.modf
local GOLD_AMOUNT_SYMBOL, GOLD_AMOUNT_TEXTURE = GOLD_AMOUNT_SYMBOL, GOLD_AMOUNT_TEXTURE
local SILVER_AMOUNT_SYMBOL, SILVER_AMOUNT_TEXTURE = SILVER_AMOUNT_SYMBOL, SILVER_AMOUNT_TEXTURE
local COPPER_AMOUNT_SYMBOL, COPPER_AMOUNT_TEXTURE = COPPER_AMOUNT_SYMBOL, COPPER_AMOUNT_TEXTURE
local GameTooltip = GameTooltip

local modules = C.stats.config
local font = C.stats.font

local pxpx = { height = 1, width = 1 }
local layout = {}
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)

-- Strata/Level for text objects
local strata, level = "BACKGROUND", 20

-- Tooltip text colors
module.tthead = { r = 0.40, g = 0.78, b = 1 } -- Headers
module.ttsubh = { r = 0.75, g = 0.90, b = 1 } -- Subheaders

module.menuFrame = CreateFrame("Frame", "ContactDropDownMenu", UIParent, "UIDropDownMenuTemplate")
module.menuList = {
    { text = OPTIONS_MENU, isTitle = true, notCheckable = true },
    { text = INVITE, hasArrow = true, notCheckable = true },
    { text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true }
}

local function GetPlayerMapPos(mapID)
    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then return end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
        local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
        if not pos1 or not pos2 then return end
        mapRect = {pos1, pos2}
        mapRect[2]:Subtract(mapRect[1])
        mapRects[mapID] = mapRect
    end
    tempVec2D:Subtract(mapRect[1])

    return (tempVec2D.y / mapRect[2].y), (tempVec2D.x / mapRect[2].x)
end

function module:HideTT(stat)
    GameTooltip:Hide()
    stat.hovered = false
end

function module:AltUpdate(stat)
    if not stat.hovered then return end

    if IsAltKeyDown() and not stat.altdown then
        stat.altdown = true
        stat:GetScript("OnEnter")(stat)
    elseif not IsAltKeyDown() and stat.altdown then
        stat.altdown = false
        stat:GetScript("OnEnter")(stat)
    end
end

local function comma_value(n)
    -- credit http://richard.warburton.it
    local left, num, right = match(n, "^([^%d]*%d)(%d*)(.-)$")
    return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

function module:FormatGold(style, amount)
    local gold, silver, copper = floor(amount * 0.0001), floor(mod(amount * 0.01, 100)), floor(mod(amount, 100))
    if style == 1 then
        return (gold > 0 and format("%s|cffffd700%s|r ", comma_value(gold), GOLD_AMOUNT_SYMBOL) or "")
                .. (silver > 0 and format("%s|cffc7c7cf%s|r ", silver, SILVER_AMOUNT_SYMBOL) or "")
                .. ((copper > 0 or (gold == 0 and silver == 0)) and format("%s|cffeda55f%s|r", copper, COPPER_AMOUNT_SYMBOL) or "")
    elseif style == 2 or not style then
        return format("%.1f|cffffd700%s|r", amount * 0.0001, GOLD_AMOUNT_SYMBOL)
    elseif style == 3 then
        return format("|cffffd700%s|r.|cffc7c7cf%s|r.|cffeda55f%s|r", gold, silver, copper)
    elseif style == 4 then
        return (gold > 0 and format(GOLD_AMOUNT_TEXTURE, gold, 12, 12) or "") 
                .. (silver > 0 and format(SILVER_AMOUNT_TEXTURE, silver, 12, 12) or "")
                .. ((copper > 0 or (gold == 0 and silver == 0)) and format(COPPER_AMOUNT_TEXTURE, copper, 12, 12) or "") .. " "
    elseif style == 5 then
        return (gold > 0 and format("%s|cffffd700%s|r ", comma_value(gold), GOLD_AMOUNT_SYMBOL) or "")
                .. (format("%.2d|cffc7c7cf%s|r ", silver, SILVER_AMOUNT_SYMBOL))
                .. (format("%.2d|cffeda55f%s|r", copper, COPPER_AMOUNT_SYMBOL))
    end
end

function module:Coords()
    return format(modules.Coords and modules.Coords.fmt or "%d, %d", self.coordX and self.coordX * 100, self.coordY and self.coordY * 100)
end

function module:RegEvents(f, l)
    for _, e in ipairs { strsplit(" ", l) } do f:RegisterEvent(e) end
end

function module:Gradient(perc)
    perc = perc > 1 and 1 or perc < 0 and 0 or perc -- Stay between 0-1

    local seg, relperc = modf(perc * 2)
    local r1, g1, b1, r2, g2, b2 = select(seg * 3 + 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0) -- R -> Y -> G
    local r, g, b = r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc

    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255), r, g, b
end

function module:Inject(name, stat)
    if not name then return end
    if not stat then stat = pxpx end

    local m = modules[name]
    for k, v in pairs {
        -- retrieving config variables from LPSTAT_CONFIG
        --name = name, anchor_frame = m.anchor_frame,
        name        = name,
        parent      = m.anchor_frame,
        anchor_to   = m.anchor_to,
        anchor_from = m.anchor_from,
        x_off       = m.x_off,
        y_off       = m.y_off,
        height      = m.height,
        width       = m.width,
        strata      = m.strata or strata,
        level       = level
    } do
        if not stat[k] then
            stat[k] = v
        end
    end
    if not stat.text then
        stat.text = {}
    end

    -- retrieve font variables and insert them into text table
    for k, v in pairs(font) do
        if not stat.text[k] then
            stat.text[k] = m[k] or v
        end
    end

    if stat.OnEnter then
        if stat.OnLeave then
            hooksecurefunc(stat, "OnLeave", self.HideTT)
        else
            stat.OnLeave = function(s) self:HideTT(s) end
        end
    end
    tinsert(layout, stat)
end

----------------------------------------------------------------------------------------
--    Applying modules
----------------------------------------------------------------------------------------
module:RegisterEvent("ADDON_LOADED", function(_, event, addon)
    if event == "ADDON_LOADED" and addon == E.addonName then
        if not SavedStats then SavedStats = {} end
        if not SavedStats[E.realm] then SavedStats[E.realm] = {} end
        if not SavedStats[E.realm][E.myName] then SavedStats[E.realm][E.myName] = {} end
        module.conf = SavedStats[E.realm][E.myName]

        local lpanels = lpanels

        CreateFrame("Frame", "LSMenus", UIParent, "UIDropDownMenuTemplate")
        lpanels:CreateLayout("LiteStats", layout)
        lpanels:ApplyLayout(nil, "LiteStats")
    end
end)

module:SetScript("OnUpdate", function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed >= 0.5 then
        local unitMap = C_Map_GetBestMapForUnit("player")

        if unitMap then
            module.coordX, module.coordY = GetPlayerMapPos(unitMap)
        end

        self.elapsed = 0
    end
end)
