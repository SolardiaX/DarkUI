local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--	Core Function Methods
----------------------------------------------------------------------------------------

local format = string.format
local tonumber = tonumber

----------------------------------------------------------------------------------------
--  Time format functions
----------------------------------------------------------------------------------------
function E:FormatTime(seconds, raw)
    local d, h, m, str = 86400, 3600, 60
    if seconds >= d then
        str = format("%d" .. E.colorString .. "d", seconds / d)
    elseif seconds >= h then
        str = format("%d" .. E.colorString .. "h", seconds / h)
    elseif seconds >= m then
        str = format("%d" .. E.colorString .. "m", seconds / m)
    else
        if seconds <= 5 and raw then
            str = format("|cffff0000%.1f|r", seconds) -- red
        elseif seconds <= 10 and raw then
            str = format("|cffffff00%.1f|r", seconds) -- yellow
        else
            str = format("%d", seconds)
        end
    end
    return str
end

----------------------------------------------------------------------------------------
--  UTF functions
----------------------------------------------------------------------------------------
function E:UTF(string, i, dots)
    if not string then return end
    local bytes = string:len()
    if bytes <= i then
        return string
    else
        local len, pos = 0, 1
        while (pos <= bytes) do
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
            if len == i then break end
        end
        if len == i and pos <= bytes then
            return string:sub(1, pos - 1) .. (dots and "..." or "")
        else
            return string
        end
    end
end

----------------------------------------------------------------------------------------
--	Number value function
----------------------------------------------------------------------------------------
function E:Round(number, decimals)
    if not decimals then decimals = 0 end
    return (("%%.%df"):format(decimals)):format(number)
end

function E:ShortValue(value)
    if C.general.locale_valueformat and type(L.ValueFormat) == 'function' then
        return L.ValueFormat(value)
    end

    if value >= 1e11 then
        return ("%.0fb"):format(value / 1e9)
    elseif value >= 1e10 then
        return ("%.1fb"):format(value / 1e9):gsub("%.?0+([km])$", "%1")
    elseif value >= 1e9 then
        return ("%.2fb"):format(value / 1e9):gsub("%.?0+([km])$", "%1")
    elseif value >= 1e8 then
        return ("%.0fm"):format(value / 1e6)
    elseif value >= 1e7 then
        return ("%.1fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
    elseif value >= 1e6 then
        return ("%.2fm"):format(value / 1e6):gsub("%.?0+([km])$", "%1")
    elseif value >= 1e5 then
        return ("%.0fk"):format(value / 1e3)
    elseif value >= 1e3 then
        return ("%.1fk"):format(value / 1e3):gsub("%.?0+([km])$", "%1")
    else
        return format("%.0f", value)
    end
end

----------------------------------------------------------------------------------------
--	RGB To Hex function
----------------------------------------------------------------------------------------
function E:RGBToHex(r, g, b, raw)
    if type(r) == 'table' then
        if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    r = tonumber(r) <= 1 and tonumber(r) >= 0 and tonumber(r) or 0
    g = tonumber(g) <= tonumber(g) and tonumber(g) >= 0 and tonumber(g) or 0
    b = tonumber(b) <= 1 and tonumber(b) >= 0 and tonumber(b) or 0
    return format(raw and "%02x%02x%02x" or "|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

----------------------------------------------------------------------------------------
--	Chat channel check
----------------------------------------------------------------------------------------
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
