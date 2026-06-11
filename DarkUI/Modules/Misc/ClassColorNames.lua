local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Class Color Names
------------------------------------------------------------------------

local module = E:Module("Misc"):Sub("ClassColorNames")

if C_AddOns.IsAddOnLoaded("yClassColor") then return end

local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local SMOOTH = { 1, 0, 0, 1, 1, 0, 0, 1, 0 }
local GUILD_INDEX_MAX = 12

local BC = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do BC[v] = k end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do BC[v] = k end

local function hex(r, g, b)
    if type(r) == "table" then
        if r.r then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end
    if not r or not g or not b then r, g, b = 1, 1, 1 end
    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function colorGradient(perc, ...)
    if perc >= 1 then
        return select(select("#", ...) - 2, ...)
    elseif perc <= 0 then
        return ...
    end
    local num = select("#", ...) / 3
    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)
    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

local classColor = setmetatable({}, {
    __index = function(t, i)
        local c = i and RAID_CLASS_COLORS[BC[i] or i]
        if c then
            t[i] = hex(c)
            return t[i]
        end
        return "|cffffffff"
    end,
})

local classColorRaw = setmetatable({}, {
    __index = function(t, i)
        local c = i and RAID_CLASS_COLORS[BC[i] or i]
        if not c then return { r = 1, g = 1, b = 1 } end
        t[i] = c
        return c
    end,
})

local diffColor = setmetatable({}, {
    __index = function(t, i)
        local c = i and GetQuestDifficultyColor(i)
        t[i] = c and hex(c) or "|cffffffff"
        return t[i]
    end,
})

local guildRankColor = setmetatable({}, {
    __index = function(t, i)
        if i then
            local c = hex(colorGradient(i / GUILD_INDEX_MAX, unpack(SMOOTH)))
            t[i] = c or "|cffffffff"
            return t[i]
        end
        return "|cffffffff"
    end,
})

if CUSTOM_CLASS_COLORS then
    CUSTOM_CLASS_COLORS:RegisterCallback(function()
        wipe(classColorRaw)
        wipe(classColor)
    end)
end

------------------------------------------------------------------------
-- FriendsList
------------------------------------------------------------------------

local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s"):gsub("%$d", "%$s")

local function hookFriendsList(self)
    local playerArea = GetRealZoneText()

    for i = 1, self.ScrollTarget:GetNumChildren() do
        local button = select(i, self.ScrollTarget:GetChildren())
        if button and button:IsShown() then
            local nameText, infoText

            if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
                local info = C_FriendList.GetFriendInfoByIndex(button.id)
                if info and info.connected then
                    nameText = classColor[info.className] .. info.name .. "|r, " .. format(FRIENDS_LEVEL_TEMPLATE, diffColor[info.level] .. info.level .. "|r", info.className)
                    if info.area == playerArea then
                        infoText = "|cff00ff00" .. info.area .. "|r"
                    end
                end
            elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
                local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
                if accountInfo and accountInfo.gameAccountInfo and accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
                    local accountName = accountInfo.accountName
                    local charName = accountInfo.gameAccountInfo.characterName
                    local class = accountInfo.gameAccountInfo.className
                    local areaName = accountInfo.gameAccountInfo.areaName
                    if accountName and charName and class then
                        nameText = format(BATTLENET_NAME_FORMAT, accountName, "") .. " " .. FRIENDS_WOW_NAME_COLOR_CODE .. "(" .. classColor[class] .. charName .. FRIENDS_WOW_NAME_COLOR_CODE .. ")"
                        if areaName and areaName == playerArea then
                            infoText = "|cff00ff00" .. areaName .. "|r"
                        end
                    end
                end
            end

            if nameText and button.name then button.name:SetText(nameText) end
            if infoText and button.info then button.info:SetText(infoText) end
        end
    end
end

------------------------------------------------------------------------
-- CommunitiesFrame
------------------------------------------------------------------------

local function hookCommunities(self)
    local playerArea = GetRealZoneText()
    local memberInfo = self:GetMemberInfo()
    if not memberInfo then return end
    if memberInfo.presence == Enum.ClubMemberPresence.Offline then return end

    if memberInfo.zone and memberInfo.zone == playerArea then
        self.Zone:SetText("|cff4cff4c" .. memberInfo.zone)
    end

    if memberInfo.level then
        self.Level:SetText(diffColor[memberInfo.level] .. memberInfo.level)
    end

    if memberInfo.guildRankOrder and memberInfo.guildRank then
        self.Rank:SetText(guildRankColor[memberInfo.guildRankOrder] .. memberInfo.guildRank)
    end
end

------------------------------------------------------------------------
-- PVP Match Results
------------------------------------------------------------------------

local function hookPVPResults(self, rowData)
    if not rowData then return end
    local name = rowData.name
    local className = rowData.className or ""
    local n, r = strsplit("-", name, 2)
    n = classColor[className] .. n .. "|r"

    if name == UnitName("player") then
        n = ">>> " .. n .. " <<<"
    end

    if r then
        local faction = rowData.faction
        local inArena = IsActiveBattlefieldArena()
        local clr
        if inArena then
            clr = faction == 1 and "|cffffd100" or "|cff19ff19"
        else
            clr = faction == 1 and "|cff00adf0" or "|cffff1919"
        end
        n = n .. "|cffffffff - |r" .. clr .. r .. "|r"
    end

    self.text:SetText(n)
end

------------------------------------------------------------------------

function module:OnInit()
    if FriendsListFrame and FriendsListFrame.ScrollBox then
        hooksecurefunc(FriendsListFrame.ScrollBox, "Update", hookFriendsList)
    end
    if CommunitiesMemberListEntryMixin then
        hooksecurefunc(CommunitiesMemberListEntryMixin, "RefreshExpandedColumns", hookCommunities)
    end
    if PVPCellNameMixin then
        hooksecurefunc(PVPCellNameMixin, "Populate", hookPVPResults)
    end
end
