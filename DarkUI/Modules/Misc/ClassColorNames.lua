﻿if C_AddOns.IsAddOnLoaded("yClassColor") then return end

----------------------------------------------------------------------------------------
--    Class color guild/friends/etc list(yClassColor by Yleaf)
----------------------------------------------------------------------------------------
local GUILD_INDEX_MAX = 12
local SMOOTH = {1, 0, 0, 1, 1, 0, 0, 1, 0}
local BC = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do
    BC[v] = k
end
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do
    BC[v] = k
end
local RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local WHITE_HEX = "|cffffffff"

local function Hex(r, g, b)
    if type(r) == "table" then
        if (r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
    end

    if not r or not g or not b then
        r, g, b = 1, 1, 1
    end

    return format("|cff%02x%02x%02x", r * 255, g * 255, b * 255)
end

local function ColorGradient(perc, ...)
    if perc >= 1 then
        local r, g, b = select(select("#", ...) - 2, ...)
        return r, g, b
    elseif perc <= 0 then
        local r, g, b = ...
        return r, g, b
    end

    local num = select("#", ...) / 3

    local segment, relperc = math.modf(perc * (num - 1))
    local r1, g1, b1, r2, g2, b2 = select((segment * 3) + 1, ...)

    return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end

local guildRankColor = setmetatable({}, {
    __index = function(t, i)
        if i then
            local c = Hex(ColorGradient(i / GUILD_INDEX_MAX, unpack(SMOOTH)))
            if c then
                t[i] = c
                return c
            else
                t[i] = t[0]
            end
        end
    end
})
guildRankColor[0] = WHITE_HEX

local diffColor = setmetatable({}, {
    __index = function(t, i)
        local c = i and GetQuestDifficultyColor(i)
        t[i] = c and Hex(c) or t[0]
        return t[i]
    end
})
diffColor[0] = WHITE_HEX

local classColor = setmetatable({}, {
    __index = function(t, i)
        local c = i and RAID_CLASS_COLORS[BC[i] or i]
        if c then
            t[i] = Hex(c)
            return t[i]
        else
            return WHITE_HEX
        end
    end
})

local WHITE = {1, 1, 1}
local classColorRaw = setmetatable({}, {
    __index = function(t, i)
        local c = i and RAID_CLASS_COLORS[BC[i] or i]
        if not c then return WHITE end
        t[i] = c
        return c
    end
})

if CUSTOM_CLASS_COLORS then
    CUSTOM_CLASS_COLORS:RegisterCallback(function()
        wipe(classColorRaw)
        wipe(classColor)
    end)
end

-- WhoList
local function whoFrame(self)
    local playerZone = GetRealZoneText()
    local playerGuild = GetGuildInfo("player")
    local playerRace = UnitRace("player")

     for i = 1, self.ScrollTarget:GetNumChildren() do
        local button = select(i, self.ScrollTarget:GetChildren())

        local nameText = button.Name
        local levelText = button.Level
        local variableText = button.Variable

        local info = C_FriendList.GetWhoInfo(button.index)
        if info then
            local guild, level, race, zone, class = info.fullGuildName, info.level, info.raceStr, info.area, info.filename
            if zone == playerZone then
                zone = "|cff00ff00"..zone
            end
            if guild == playerGuild then
                guild = "|cff00ff00"..guild
            end
            if race == playerRace then
                race = "|cff00ff00"..race
            end

            local columnTable = {zone, guild, race}

            local c = classColorRaw[class]
            nameText:SetTextColor(c.r, c.g, c.b)
            levelText:SetText(diffColor[level]..level)
            variableText:SetText(columnTable[UIDropDownMenu_GetSelectedID(_G.WhoFrameDropDown)])
        end
    end
end

hooksecurefunc(_G.WhoFrame.ScrollBox, "Update", whoFrame)

-- PVPMatchResults
hooksecurefunc(PVPCellNameMixin, "Populate", function(self, rowData)
    local name = rowData.name
    local className = rowData.className or ""
    local n, r = strsplit("-", name, 2)
    n = classColor[className]..n.."|r"

    if name == UnitName("player") then
        n = ">>> "..n.." <<<"
    end

    if r then
        local color
        local faction = rowData.faction
        local inArena = IsActiveBattlefieldArena()
        if inArena then
            if faction == 1 then
                color = "|cffffd100"
            else
                color = "|cff19ff19"
            end
        else
            if faction == 1 then
                color = "|cff00adf0"
            else
                color = "|cffff1919"
            end
        end
        r = color..r.."|r"
        n = n.."|cffffffff - |r"..r
    end

    local text = self.text
    text:SetText(n)
end)






-- CommunitiesFrame
local function RefreshList(self)
    local playerArea = GetRealZoneText()
    local memberInfo = self:GetMemberInfo()
    if memberInfo then
        if memberInfo.presence == Enum.ClubMemberPresence.Offline then return end
        if memberInfo.zone and memberInfo.zone == playerArea then
            self.Zone:SetText("|cff4cff4c"..memberInfo.zone)
        end

        if memberInfo.level then
            self.Level:SetText(diffColor[memberInfo.level]..memberInfo.level)
        end

        if memberInfo.guildRankOrder and memberInfo.guildRank then
            self.Rank:SetText(guildRankColor[memberInfo.guildRankOrder]..memberInfo.guildRank)
        end
    end
end

        hooksecurefunc(CommunitiesMemberListEntryMixin, "RefreshExpandedColumns", RefreshList)

-- FriendsList
local FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%%d", "%%s")
FRIENDS_LEVEL_TEMPLATE = FRIENDS_LEVEL_TEMPLATE:gsub("%$d", "%$s")
local function friendsFrame(self)
    local playerArea = GetRealZoneText()

    for i = 1, self.ScrollTarget:GetNumChildren() do
        local nameText, infoText
        local button = select(i, self.ScrollTarget:GetChildren())
        if button:IsShown() then
            if button.buttonType == FRIENDS_BUTTON_TYPE_WOW then
                local info = C_FriendList.GetFriendInfoByIndex(button.id)
                if info.connected then
                    nameText = classColor[info.className]..info.name.."|r, "..format(FRIENDS_LEVEL_TEMPLATE, diffColor[info.level]..info.level.."|r", info.className)
                    if info.area == playerArea then
                        infoText = format("|cff00ff00%s|r", info.area)
                    end
                end
            elseif button.buttonType == FRIENDS_BUTTON_TYPE_BNET then
                local accountInfo = C_BattleNet.GetFriendAccountInfo(button.id)
                if accountInfo.gameAccountInfo.isOnline and accountInfo.gameAccountInfo.clientProgram == BNET_CLIENT_WOW then
                    local accountName = accountInfo.accountName
                    local characterName = accountInfo.gameAccountInfo.characterName
                    local class = accountInfo.gameAccountInfo.className
                    local areaName = accountInfo.gameAccountInfo.areaName
                    if accountName and characterName and class then
                        nameText = format(BATTLENET_NAME_FORMAT, accountName, "").." "..FRIENDS_WOW_NAME_COLOR_CODE.."("..classColor[class]..classColor[class]..characterName..FRIENDS_WOW_NAME_COLOR_CODE..")"
                        if areaName == playerArea then
                            infoText = format("|cff00ff00%s|r", areaName)
                        end
                    end
                end
            end
        end

        if nameText then
            button.name:SetText(nameText)
        end
        if infoText then
            button.info:SetText(infoText)
        end
    end
end

hooksecurefunc(FriendsListFrame.ScrollBox, "Update", friendsFrame)