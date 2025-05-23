local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--    Core Function Methods
----------------------------------------------------------------------------------------

local format = string.format
local tonumber = tonumber
local modf = math.modf

----------------------------------------------------------------------------------------
--  Time format functions
----------------------------------------------------------------------------------------
function E:FormatTime(seconds, raw)
    local d, h, m, str = 86400, 3600, 60, ""
    if seconds >= d then
        -- str = format("%d" .. E.myColorString .. "d", seconds / d + .5)
        str = format("%dd", seconds / d + .5)
    elseif seconds >= h then
        -- str = format("%d" .. E.myColorString .. "h", seconds / h + .5)
        str = format("%dh", seconds / h + .5)
    elseif seconds >= m then
        -- str = format("%d" .. E.myColorString .. "m", seconds / m + .5)
        str = format("%dm", seconds / m + .5)
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

----------------------------------------------------------------------------------------
-- Color Gradient
----------------------------------------------------------------------------------------
function E:ColorGradient(a, b, ...)
    local Percent

    if(b == 0) then
        Percent = 0
    else
        Percent = a / b
    end

    if (Percent >= 1) then
        local R, G, B = select(select("#", ...) - 2, ...)

        return R, G, B
    elseif (Percent <= 0) then
        local R, G, B = ...

        return R, G, B
    end

    local Num = (select("#", ...) / 3)
    local Segment, RelPercent = modf(Percent * (Num - 1))
    local R1, G1, B1, R2, G2, B2 = select((Segment * 3) + 1, ...)

    return R1 + (R2 - R1) * RelPercent, G1 + (G2 - G1) * RelPercent, B1 + (B2 - B1) * RelPercent
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
--    Number value function
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
--    RGB To Hex function
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
--    Chat channel check
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

----------------------------------------------------------------------------------------
--    Set Variable in game
----------------------------------------------------------------------------------------
function E:SetVariable(group, key, value)
    if not C_AddOns.IsAddOnLoaded("DarkUI_Options") then return end
    
    local t = SavedOptions.global and SavedOptions or SavedOptionsPerChar
    
    if not t[group] then t[group] = {} end

    t = t[group]

    local deep = select(2, string.gsub(key, "([^.%s]+)", ""))
    local index = 1

    for k in gmatch(key, "([^.%s]+)") do
        if index < deep then
            if t[k] == nil then t[k] = {} end
            t = t[k]
        elseif index == deep then
            t[k] = value
        end

        index = index + 1
    end
end

----------------------------------------------------------------------------------------
--    Global EasyMenu function
----------------------------------------------------------------------------------------
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
	if displayMode == "MENU"  then
		menuFrame.displayMode = displayMode
	end
	UIDropDownMenu_Initialize(menuFrame, EasyMenu_Initialize, displayMode, nil, menuList)
	ToggleDropDownMenu(1, nil, menuFrame, anchor, x, y, menuList, nil, autoHideDelay)
end

----------------------------------------------------------------------------------------
--    Restore old function
----------------------------------------------------------------------------------------
GetContainerItemInfo = function(bagIndex, slotIndex)
	local info = C_Container.GetContainerItemInfo(bagIndex, slotIndex)
	if info then
		return info.iconFileID, info.stackCount, info.isLocked, info.quality, info.isReadable, info.hasLoot, info.hyperlink, info.isFiltered, info.hasNoValue, info.itemID, info.isBound
	end
end

UnitAura = function(unit, auraIndex, filter)
	return AuraUtil.UnpackAuraData(C_UnitAuras.GetAuraDataByIndex(unit, auraIndex, filter))
end

UnitBuff = function(unit, auraIndex, filter)
	return AuraUtil.UnpackAuraData(C_UnitAuras.GetBuffDataByIndex(unit, auraIndex, filter))
end

GetSpellInfo = function(data)
	local spellInfo = C_Spell.GetSpellInfo(data)
	if spellInfo then
		return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID, spellInfo.originalIconID
	end
end

GetSpellCooldown = function(data)
	local info = C_Spell.GetSpellCooldown(data)
	if info then
		return info.startTime, info.duration, info.isEnabled, info.modRate
	end
end
