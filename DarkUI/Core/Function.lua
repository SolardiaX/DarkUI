local E, C, L, DB = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Core Functions
----------------------------------------------------------------------------------------

local format = string.format
local tonumber = tonumber
local modf = math.modf
function E:FormatTime(seconds, raw)
    local d, h, m, str = 86400, 3600, 60, ""
    if seconds >= d then
        -- str = format("%d" .. E.myColorString .. "d", seconds / d + .5)
        str = format("%dd", seconds / d + 0.5)
    elseif seconds >= h then
        -- str = format("%d" .. E.myColorString .. "h", seconds / h + .5)
        str = format("%dh", seconds / h + 0.5)
    elseif seconds >= m then
        -- str = format("%d" .. E.myColorString .. "m", seconds / m + .5)
        str = format("%dm", seconds / m + 0.5)
    else
        if seconds <= 5 then
            str = format("|cffff0000%.1f|r", seconds) -- red
        elseif seconds <= 10 then
            str = format(raw and "|cffffff00%.1f|r" or "|cffffff00%d|r", seconds) -- yellow
        else
            str = format("%d", seconds)
        end
    end
    return str
end

-- Color Gradient
function E:ColorGradient(a, b, ...)
    local Percent

    if b == 0 then
        Percent = 0
    else
        Percent = a / b
    end

    if Percent >= 1 then
        local R, G, B = select(select("#", ...) - 2, ...)

        return R, G, B
    elseif Percent <= 0 then
        local R, G, B = ...

        return R, G, B
    end

    local Num = (select("#", ...) / 3)
    local Segment, RelPercent = modf(Percent * (Num - 1))
    local R1, G1, B1, R2, G2, B2 = select((Segment * 3) + 1, ...)

    return R1 + (R2 - R1) * RelPercent, G1 + (G2 - G1) * RelPercent, B1 + (B2 - B1) * RelPercent
end

--  UTF functions
function E:UTF(string, i, dots)
    if not string then
        return
    end
    if not canaccessvalue(string) then
        return string
    end
    local bytes = string:len()
    if bytes <= i then
        return string
    else
        local len, pos = 0, 1
        while pos <= bytes do
            len = len + 1
            local c = string:byte(pos)
            if c > 0 and c <= 127 then
                pos = pos + 1
            elseif c >= 192 and c <= 223 then
                pos = pos + 2
            elseif c >= 224 and c <= 239 then
                pos = pos + 3
            elseif c >= 240 and c <= 247 then
                pos = pos + 4
            end
            if len == i then
                break
            end
        end
        if len == i and pos <= bytes then
            return string:sub(1, pos - 1) .. (dots and "..." or "")
        else
            return string
        end
    end
end

-- Number value function
function E:Round(number, decimals)
    if not decimals then
        decimals = 0
    end
    return (("%%.%df"):format(decimals)):format(number)
end

local defaultAbbrOptions = { config = CreateAbbreviateConfig({
    { breakpoint = 1e12, abbreviation = "t", significandDivisor = 1e10, fractionDivisor = 1e2, abbreviationIsGlobal = false },
    { breakpoint = 1e9, abbreviation = "b", significandDivisor = 1e7, fractionDivisor = 1e2, abbreviationIsGlobal = false },
    { breakpoint = 1e6, abbreviation = "m", significandDivisor = 1e4, fractionDivisor = 1e2, abbreviationIsGlobal = false },
    { breakpoint = 1e3, abbreviation = "k", significandDivisor = 1e2, fractionDivisor = 1e1, abbreviationIsGlobal = false },
})}

function E:AbbreviateNumber(value)
    local options = C.general.useLocalNumberFormat and L.AbbrOptions or defaultAbbrOptions
    return AbbreviateNumbers(value, options or defaultAbbrOptions)
end

-- RGB To Hex function
function E:RGBToHex(r, g, b, raw)
    if type(r) == "table" then
        if r.r then
            r, g, b = r.r, r.g, r.b
        else
            r, g, b = unpack(r)
        end
    end
    r = tonumber(r) <= 1 and tonumber(r) >= 0 and tonumber(r) or 0
    g = tonumber(g) <= tonumber(g) and tonumber(g) >= 0 and tonumber(g) or 0
    b = tonumber(b) <= 1 and tonumber(b) >= 0 and tonumber(b) or 0
    return format(raw and "%02x%02x%02x" or "|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

-- Chat channel check
function E:CheckChat(warning)
    if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        return "INSTANCE_CHAT"
    elseif IsInRaid(LE_PARTY_CATEGORY_HOME) then
        if warning and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") or IsEveryoneAssistant()) then
            return "RAID_WARNING"
        else
            return "RAID"
        end
    elseif IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return "PARTY"
    end
    return "SAY"
end

-- Global EasyMenu function
local function EasyMenu_Initialize(frame, level, menuList)
    for index = 1, #menuList do
        local value = menuList[index]
        if value.text then
            value.index = index
            UIDropDownMenu_AddButton(value, level)
        end
    end
end

function EasyMenu(menuList, menuFrame, anchor, x, y, displayMode, autoHideDelay)
    if displayMode == "MENU" then
        menuFrame.displayMode = displayMode
    end
    UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
    ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
end

-- Legacy polyfills removed: now handled by Core/Compat.lua
