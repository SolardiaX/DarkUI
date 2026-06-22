local E, C, L, DB = select(2, ...):unpack()

------------------------------------------------------------------------
-- DataText Core
------------------------------------------------------------------------

local module = E:Module("DataText")
module:SetConfigKey("stats")
local cfg = C.datatext

local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local IsAltKeyDown = IsAltKeyDown
local UnitPosition = UnitPosition
local format, select, strsplit, tinsert = format, select, strsplit, tinsert
local pairs, ipairs, type = pairs, ipairs, type
local match = string.match
local strupper = strupper
local mod, floor, modf = mod, math.floor, math.modf
local GOLD_AMOUNT_SYMBOL = GOLD_AMOUNT_SYMBOL
local GOLD_AMOUNT_TEXTURE = GOLD_AMOUNT_TEXTURE
local SILVER_AMOUNT_SYMBOL = SILVER_AMOUNT_SYMBOL
local SILVER_AMOUNT_TEXTURE = SILVER_AMOUNT_TEXTURE
local COPPER_AMOUNT_SYMBOL = COPPER_AMOUNT_SYMBOL
local COPPER_AMOUNT_TEXTURE = COPPER_AMOUNT_TEXTURE
local GameTooltip = GameTooltip

local font = cfg.font
local layout = {}
local mapRects, tempVec2D = {}, CreateVector2D(0, 0)

------------------------------------------------------------------------
-- Tooltip Colors
------------------------------------------------------------------------

module.tthead = { r = 0.40, g = 0.78, b = 1 }
module.ttsubh = { r = 0.75, g = 0.90, b = 1 }

------------------------------------------------------------------------
-- Menu Helper (replaces EasyMenu with MenuUtil.CreateContextMenu)
------------------------------------------------------------------------

module.menuList = {
    { text = OPTIONS_MENU, isTitle = true, notCheckable = true },
    { text = INVITE, hasArrow = true, notCheckable = true },
    { text = CHAT_MSG_WHISPER_INFORM, hasArrow = true, notCheckable = true },
}

local function handleMenuList(root, menuList)
    for _, item in ipairs(menuList) do
        if item.isTitle then
            root:CreateTitle(item.text)
        elseif item.hasArrow and item.menuList then
            local submenu, _ = root:CreateButton(item.text)
            handleMenuList(submenu, item.menuList)
        else
            local func = item.func
            if func and item.arg1 then
                local a1 = item.arg1
                func = function()
                    item.func(nil, a1)
                end
            end
            root:CreateButton(item.text, func)
        end
    end
end

function module:ShowMenu(anchor, menuList)
    MenuUtil.CreateContextMenu(anchor, function(_, root)
        handleMenuList(root, menuList)
    end)
end

------------------------------------------------------------------------
-- Utility Functions
------------------------------------------------------------------------

local function getPlayerMapPos(mapID)
    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then
        return
    end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local _, pos1 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))
        local _, pos2 = C_Map.GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1))
        if not pos1 or not pos2 then
            return
        end
        mapRect = { pos1, pos2 }
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
    if not stat.hovered then
        return
    end

    if IsAltKeyDown() and not stat.altdown then
        stat.altdown = true
        stat:GetScript("OnEnter")(stat)
    elseif not IsAltKeyDown() and stat.altdown then
        stat.altdown = false
        stat:GetScript("OnEnter")(stat)
    end
end

local function commaValue(n)
    local left, num, right = match(n, "^([^%d]*%d)(%d*)(.-)$")
    return left .. (num:reverse():gsub("(%d%d%d)", "%1,"):reverse()) .. right
end

function module:FormatGold(style, amount)
    local gold = floor(amount * 0.0001)
    local silver = floor(mod(amount * 0.01, 100))
    local copper = floor(mod(amount, 100))
    if style == 1 then
        return (gold > 0 and format("%s|cffffd700%s|r ", commaValue(gold), GOLD_AMOUNT_SYMBOL) or "")
            .. (silver > 0 and format("%s|cffc7c7cf%s|r ", silver, SILVER_AMOUNT_SYMBOL) or "")
            .. ((copper > 0 or (gold == 0 and silver == 0)) and format("%s|cffeda55f%s|r", copper, COPPER_AMOUNT_SYMBOL) or "")
    elseif style == 2 or not style then
        return format("%.1f|cffffd700%s|r", amount * 0.0001, GOLD_AMOUNT_SYMBOL)
    elseif style == 3 then
        return format("|cffffd700%s|r.|cffc7c7cf%s|r.|cffeda55f%s|r", gold, silver, copper)
    elseif style == 4 then
        return (gold > 0 and format(GOLD_AMOUNT_TEXTURE, gold, 12, 12) or "")
            .. (silver > 0 and format(SILVER_AMOUNT_TEXTURE, silver, 12, 12) or "")
            .. ((copper > 0 or (gold == 0 and silver == 0)) and format(COPPER_AMOUNT_TEXTURE, copper, 12, 12) or "")
            .. " "
    elseif style == 5 then
        return (gold > 0 and format("%s|cffffd700%s|r ", commaValue(gold), GOLD_AMOUNT_SYMBOL) or "")
            .. (format("%.2d|cffc7c7cf%s|r ", silver, SILVER_AMOUNT_SYMBOL))
            .. (format("%.2d|cffeda55f%s|r", copper, COPPER_AMOUNT_SYMBOL))
    end
end

function module:Coords()
    return format(self.config.Coords and self.config.Coords.fmt or "%d, %d", self.coordX and self.coordX * 100, self.coordY and self.coordY * 100)
end

function module:RegEvents(f, l)
    for _, e in ipairs({ strsplit(" ", l) }) do
        f:RegisterEvent(e)
    end
end

function module:Gradient(perc)
    perc = perc > 1 and 1 or perc < 0 and 0 or perc
    local seg, relperc = modf(perc * 2)
    local r1, g1, b1, r2, g2, b2 = select(seg * 3 + 1, 1, 0, 0, 1, 1, 0, 0, 1, 0, 0, 0, 0)
    local r, g, b = r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255), r, g, b
end

------------------------------------------------------------------------
-- Inject API
------------------------------------------------------------------------

function module:Inject(name, stat)
    if not name then
        return
    end
    if not stat then
        stat = { height = 1, width = 1 }
    end

    local m = self.config[name]
    if not m or m.enable == false then
        return
    end

    for k, v in pairs({
        name = name,
        parent = m.anchor_frame,
        anchor_to = m.anchor_to,
        anchor_from = m.anchor_from,
        x_off = m.x_off,
        y_off = m.y_off,
        height = m.height,
        width = m.width,
        strata = m.strata or "BACKGROUND",
        level = 20,
    }) do
        if not stat[k] then
            stat[k] = v
        end
    end
    if not stat.text then
        stat.text = {}
    end

    for k, v in pairs(font) do
        if not stat.text[k] then
            stat.text[k] = m[k] or v
        end
    end

    if stat.OnEnter then
        if stat.OnLeave then
            hooksecurefunc(stat, "OnLeave", self.HideTT)
        else
            stat.OnLeave = function(s)
                self:HideTT(s)
            end
        end
    end
    tinsert(layout, stat)
end

------------------------------------------------------------------------
-- Config Builder (dynamic anchor chain)
------------------------------------------------------------------------

local function buildConfig()
    local stats = cfg

    local function class(str)
        return format(E.myColorString .. "%s|r", str or "")
    end

    local config = {
        Latency = {
            enable = stats.latency.enable,
            fmt = "[color]%d|r" .. class("ms"),
            anchor_frame = "UIParent",
            anchor_to = "bottomleft",
            anchor_from = "bottomleft",
            x_off = 10,
            y_off = 10,
            tip_frame = "UIParent",
            tip_anchor = "BOTTOMLEFT",
            tip_x = 21,
            tip_y = 20,
        },
        Memory = {
            enable = stats.memory.enable,
            fmt_mb = "%.1f" .. class("mb"),
            fmt_kb = "%.0f" .. class("kb"),
            max_addons = stats.memory.max_addons,
            anchor_frame = stats.latency.enable and "Latency" or "UIParent",
            anchor_to = stats.latency.enable and "left" or "bottomleft",
            anchor_from = stats.latency.enable and "right" or "bottomleft",
            x_off = 10,
            y_off = stats.latency.enable and 0 or 10,
            tip_frame = "UIParent",
            tip_anchor = "BOTTOMLEFT",
            tip_x = 21,
            tip_y = 20,
        },
        FPS = {
            enable = stats.fps.enable,
            fmt = "%d" .. class("fps"),
            anchor_frame = stats.memory.enable and "Memory" or (stats.latency.enable and "Latency" or "UIParent"),
            anchor_to = "bottomleft",
            anchor_from = (stats.memory.enable or stats.latency.enable) and "bottomright" or "bottomleft",
            x_off = 10,
            y_off = (stats.memory.enable or stats.latency.enable) and 0 or 10,
        },
        Friends = {
            enable = stats.friend.enable,
            fmt = class("") .. L.DATATEXT_FRIEND .. "%d/%d",
            anchor_frame = stats.fps.enable and "FPS" or stats.memory.enable and "Memory" or stats.latency.enable and "Latency" or "UIParent",
            anchor_to = "bottomleft",
            anchor_from = (stats.fps.enable or stats.memory.enable or stats.latency.enable) and "bottomright" or "bottomleft",
            x_off = 10,
            y_off = (stats.fps.enable or stats.memory.enable or stats.latency.enable) and 0 or 10,
            tip_frame = "UIParent",
            tip_anchor = "BOTTOMLEFT",
            tip_x = 21,
            tip_y = 20,
        },
        Guild = {
            enable = stats.guild.enable,
            fmt = class("") .. L.DATATEXT_GUILD .. "%d/%d",
            maxguild = stats.guild.maxguild,
            threshold = stats.guild.threshold,
            sorting = stats.guild.sorting,
            anchor_frame = stats.friend.enable and "Friends"
                or stats.fps.enable and "FPS"
                or stats.memory.enable and "Memory"
                or stats.latency.enable and "Latency"
                or "UIParent",
            anchor_to = "bottomleft",
            anchor_from = (stats.friend.enable or stats.fps.enable or stats.memory.enable or stats.latency.enable) and "bottomright" or "bottomleft",
            x_off = 10,
            y_off = (stats.friend.enable or stats.fps.enable or stats.memory.enable or stats.latency.enable) and 0 or 10,
            tip_frame = "UIParent",
            tip_anchor = "BOTTOMLEFT",
            tip_x = 21,
            tip_y = 20,
        },
        Location = {
            enable = stats.location.enable,
            subzone = stats.location.subzone,
            truncate = stats.location.truncate,
            anchor_frame = "Minimap",
            anchor_to = "top",
            anchor_from = "bottom",
            x_off = 2,
            y_off = -30,
            tip_frame = "UIParent",
            tip_anchor = "CURSOR",
            tip_x = -21,
            tip_y = 20,
        },
        Coords = {
            enable = stats.coords.enable,
            fmt = "%d, %d",
            anchor_frame = stats.location.enable and "Location" or "Minimap",
            anchor_to = "top",
            anchor_from = "bottom",
            x_off = 2,
            y_off = stats.location.enable and -4 or -24,
        },
        Durability = {
            enable = stats.durability.enable,
            fmt = L.DATATEXT_DURABILITY .. "[color]%d|r%%",
            man = stats.durability.man,
            gear_icons = stats.durability.gear_icons,
            anchor_frame = "UIParent",
            anchor_to = "bottomright",
            anchor_from = "bottomright",
            x_off = -10,
            y_off = 10,
            tip_frame = "UIParent",
            tip_anchor = "BOTTOMRIGHT",
            tip_x = 21,
            tip_y = 20,
        },
        Bags = {
            enable = stats.bags.enable,
            fmt = class("") .. L.DATATEXT_BAG .. "%d/%d",
            anchor_frame = stats.durability.enable and "Durability" or "UIParent",
            anchor_to = "bottomright",
            anchor_from = stats.durability.enable and "bottomleft" or "bottomright",
            x_off = -10,
            y_off = stats.durability.enable and 0 or 10,
        },
        Currencies = {
            enable = stats.currencies.enable,
            style = stats.currencies.style,
            anchor_frame = stats.bags.enable and "Bags" or stats.durability.enable and "Durability" or "UIParent",
            anchor_to = "bottomright",
            anchor_from = (stats.bags.enable or stats.durability.enable) and "bottomleft" or "bottomright",
            x_off = -10,
            y_off = (stats.bags.enable or stats.durability.enable) and 0 or 10,
            tip_frame = "UIParent",
            tip_anchor = "BOTTOMRIGHT",
            tip_x = -21,
            tip_y = 20,
        },
        Time = {
            enable = stats.time.enable,
            anchor_frame = "Minimap",
            anchor_to = "top",
            anchor_from = "bottom",
            x_off = 1,
            y_off = -12,
            tip_frame = "UIParent",
            tip_anchor = "CURSOR",
            tip_x = 0,
            tip_y = 0,
        },
    }

    module.config = config
    return config
end

buildConfig()

------------------------------------------------------------------------
-- Panel Creation (inlined from LitePanels)
------------------------------------------------------------------------

local function setColor(color)
    if color == "CLASS" then
        local cc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[E.myClass]
        return cc.r, cc.g, cc.b
    elseif type(color) == "string" then
        return match(color, "([%d%.]+)%s+([%d%.]+)%s+([%d%.]+)")
    else
        return unpack(color)
    end
end

local function makePanel(f)
    local parent = _G[f.parent] or UIParent
    local panel = CreateFrame("Frame", f.name and ("LP_" .. f.name) or nil, parent)

    panel:SetFrameStrata(f.strata or "BACKGROUND")
    if f.level then
        panel:SetFrameLevel(f.level)
    end

    local anchorFrame = _G[f.parent] or parent
    panel:SetPoint(strupper(f.anchor_to or "BOTTOMLEFT"), anchorFrame, strupper(f.anchor_from or f.anchor_to or "BOTTOMLEFT"), f.x_off or 0, f.y_off or 0)

    panel:SetWidth(f.width or 0)
    panel:SetHeight(f.height or 0)

    if f.text then
        local t = f.text
        panel.text = panel:CreateFontString(nil, "OVERLAY")
        local text = panel.text

        if (not f.width or f.width == 0) or (not f.height or f.height == 0) then
            hooksecurefunc(text, "SetText", function()
                panel:SetWidth(text:GetStringWidth())
                panel:SetHeight(text:GetStringHeight())
            end)
        end

        local flags = "THINOUTLINE"
        text:SetFont(t.font or STANDARD_TEXT_FONT, t.size or 12, flags)

        if not t.string then
            t.string = ""
        end
        text:SetText(type(t.string) == "function" and t.string(text) or t.string)

        local tx_r, tx_g, tx_b = setColor(t.color or { 1, 1, 1 })
        text:SetTextColor(tx_r, tx_g, tx_b, t.alpha or 1)

        if t.shadow then
            local sh = t.shadow
            if type(sh) == "number" then
                sh = { x = sh, y = -sh, alpha = 1 }
            end
            if type(sh) == "table" then
                text:SetShadowOffset(sh.x or 1, sh.y or -1)
                text:SetShadowColor(0, 0, 0, sh.alpha or 1)
            end
        end

        text:SetJustifyH("CENTER")
        text:SetJustifyV("MIDDLE")
        text:SetPoint("CENTER", panel, "CENTER", 0, 0)

        if type(t.string) == "function" and t.update ~= 0 then
            text.elapsed = 0
            local update = t.update or 1
            local stringFn = t.string
            local function textOnUpdate(_, u)
                text.elapsed = text.elapsed + u
                if text.elapsed > update then
                    text:SetText(stringFn(text))
                    text.elapsed = 0
                end
            end
            if not f.OnUpdate then
                f.OnUpdate = textOnUpdate
            else
                local origOnUpdate = f.OnUpdate
                f.OnUpdate = function(self, u)
                    textOnUpdate(self, u)
                    origOnUpdate(self, u)
                end
            end
        end
    end

    if f.OnLoad then
        f.OnLoad(panel)
    end

    if f.OnClick or f.OnEnter or f.OnLeave then
        panel:EnableMouse(true)
    end

    if f.OnEvent then
        panel:HookScript("OnEvent", f.OnEvent)
    end
    if f.OnUpdate then
        panel.elapsed = 0
        panel:HookScript("OnUpdate", f.OnUpdate)
    end
    if f.OnClick then
        panel:HookScript("OnMouseUp", f.OnClick)
    end
    if f.OnEnter then
        panel:HookScript("OnEnter", f.OnEnter)
    end
    if f.OnLeave then
        panel:HookScript("OnLeave", f.OnLeave)
    end

    return panel
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end

    if not DB:GetStats(E.realm) then
        DB:SetStats(E.realm, {})
    end
    if not DB:GetStats(E.realm .. "." .. E.myName) then
        DB:SetStats(E.realm .. "." .. E.myName, {})
    end
    self.conf = DB:GetStats(E.realm .. "." .. E.myName)

    -- panels referencing other panel names need LP_ prefix for _G lookup
    for _, f in ipairs(layout) do
        for _, other in ipairs(layout) do
            if f.name and f.name == other.parent then
                other.parent = "LP_" .. other.parent
            end
        end
    end

    for _, f in ipairs(layout) do
        makePanel(f)
    end

    local coordFrame = CreateFrame("Frame")
    coordFrame.elapsed = 0
    coordFrame:SetScript("OnUpdate", function(_, elapsed)
        coordFrame.elapsed = coordFrame.elapsed + elapsed
        if coordFrame.elapsed >= 0.5 then
            local unitMap = C_Map_GetBestMapForUnit("player")
            if unitMap then
                module.coordX, module.coordY = getPlayerMapPos(unitMap)
            end
            coordFrame.elapsed = 0
        end
    end)
end
