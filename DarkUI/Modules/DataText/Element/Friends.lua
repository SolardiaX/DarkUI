local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Friends.enable then return end

----------------------------------------------------------------------------------------
--	Friends of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local BNGetNumFriends = BNGetNumFriends
local BNInviteFriend = BNInviteFriend
local C_BattleNet_GetFriendAccountInfo = C_BattleNet.GetFriendAccountInfo
local ChatFrame_SendBNetTell = ChatFrame_SendBNetTell
local EasyMenu = EasyMenu
local GetFriendInfo = GetFriendInfo
local C_FriendList_GetNumFriends = C_FriendList.GetNumFriends
local C_FriendList_GetNumOnlineFriends = C_FriendList.GetNumOnlineFriends
local C_FriendList_GetFriendInfo = C_FriendList.GetFriendInfo
local GetLocale = GetLocale
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetRealZoneText = GetRealZoneText
local GetRealmName = GetRealmName
local SetItemRef, InviteUnit = SetItemRef, InviteUnit
local C_FriendList_ShowFriends = C_FriendList.ShowFriends
local ToggleIgnorePanel, ToggleFriendsFrame = ToggleIgnorePanel, ToggleFriendsFrame
local UnitInParty, UnitInRaid, UnitFactionGroup = UnitInParty, UnitInRaid, UnitFactionGroup
local format, wipe, pairs, select = format, wipe, pairs, select
local LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE = LOCALIZED_CLASS_NAMES_MALE, LOCALIZED_CLASS_NAMES_FEMALE
local CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS
local BNET_CLIENT_WOW = BNET_CLIENT_WOW
local GUILD_ONLINE_LABEL = GUILD_ONLINE_LABEL
local FRIENDS_LIST = FRIENDS_LIST
local WOW_FRIEND, BATTLENET_FRIEND = WOW_FRIEND, BATTLENET_FRIEND
local GameTooltip = GameTooltip

local cfg = C.stats.config.Friends

local totalFriendsOnline = 0
local totalBattleNetOnline = 0
local BNTable = {}
local friendTable = {}
local BNTableEnter = {}

local function BuildFriendTable(total)
    totalFriendsOnline = 0
    wipe(friendTable)

    for i = 1, total do
        local name, level, class, area, connected, status, note = C_FriendList_GetFriendInfo(i)
        for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
        if GetLocale() ~= "enUS" then
            for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
        end
        friendTable[i] = { name, level, class, area, connected, status, note }
        if connected then
            totalFriendsOnline = totalFriendsOnline + 1
        end
    end

    table.sort(friendTable, function(a, b)
        if a[1] and b[1] then
            return a[1] < b[1]
        end
    end)
end
local function BuildBNTable(total)
    totalBattleNetOnline = 0
    wipe(BNTable)

    for i = 1, total do
        local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
        local class = accountInfo.gameAccountInfo.className
        for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
        if GetLocale() ~= "enUS" then
            for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
        end
        BNTable[i] = { accountInfo.bnetAccountID, accountInfo.accountName, accountInfo.battleTag, accountInfo.gameAccountInfo.characterName, accountInfo.gameAccountInfo.gameAccountID, accountInfo.gameAccountInfo.clientProgram, accountInfo.gameAccountInfo.isOnline, accountInfo.isAFK, accountInfo.isDND, accountInfo.note, accountInfo.gameAccountInfo.realmName, accountInfo.gameAccountInfo.factionName, accountInfo.gameAccountInfo.raceName, class, accountInfo.gameAccountInfo.areaName, accountInfo.gameAccountInfo.characterLevel }
        if accountInfo.gameAccountInfo.isOnline then
            totalBattleNetOnline = totalBattleNetOnline + 1
        end
    end
end

local clientTags = {
    ["WoW"] = "World of Warcraft",
	["S2"] = "StarCraft 2",
	["OSI"] = "Diablo II: Resurrected",
	["D3"] = "Diablo 3",
	["WTCG"] = "Hearthstone",
	["App"] = "Battle.net Desktop App",
	["BSAp"] = "Battle.net Mobile App",
	["Hero"] = "Heroes of the Storm",
	["Pro"] = "Overwatch",
	["CLNT"] = "Battle.net Desktop App",
	["S1"] = "StarCraft: Remastered",
	["DST2"] = "Destiny 2",
	["VIPR"] = "Call of Duty: Black Ops 4",
	["ODIN"] = "Call of Duty: Modern Warfare",
	["LAZR"] = "Call of Duty: Modern Warfare 2",
	["ZEUS"] = "Call of Duty: Black Ops Cold War",
	["W3"] = "Warcraft III: Reforged",
}

module:Inject("Friends", {
    OnLoad   = function(self) module:RegEvents(self, "PLAYER_LOGIN PLAYER_ENTERING_WORLD GROUP_ROSTER_UPDATE FRIENDLIST_UPDATE BN_FRIEND_LIST_SIZE_CHANGED BN_FRIEND_ACCOUNT_ONLINE BN_FRIEND_ACCOUNT_OFFLINE BN_FRIEND_INFO_CHANGED BN_FRIEND_ACCOUNT_ONLINE BN_FRIEND_ACCOUNT_OFFLINE BN_FRIEND_INFO_CHANGED") end,
    OnEvent  = function(self, event)
        if event ~= "GROUP_ROSTER_UPDATE" then
            local numBNetTotal, numBNetOnline = BNGetNumFriends()
            local numOnline, numTotal = C_FriendList_GetNumOnlineFriends(), C_FriendList_GetNumFriends()
            local online = numOnline + numBNetOnline
            local total = numTotal + numBNetTotal
            self.text:SetText(format(cfg.fmt, online, total))
        end
        if self.hovered then self:GetScript("OnEnter")(self) end
    end,
    -- OnUpdate = module.AltUpdate,
    OnClick  = function(self, b)
        if b == "MiddleButton" then
            ToggleIgnorePanel()
        elseif b == "LeftButton" then
            ToggleFriendsFrame(1)
        elseif b == "RightButton" then
            module:HideTT(self)

            local BNTotal = BNGetNumFriends()
            local total = C_FriendList_GetNumFriends()
            BuildBNTable(BNTotal)
            BuildFriendTable(total)

            local classc, levelc, grouped
            local menuCountWhispers = 0
            local menuCountInvites = 0

            module.menuList[2].menuList = {}
            module.menuList[3].menuList = {}

            if totalFriendsOnline > 0 then
                for i = 1, #friendTable do
                    if friendTable[i][5] then
                        if UnitInParty(friendTable[i][1]) or UnitInRaid(friendTable[i][1]) then
                            grouped = " |cffaaaaaa*|r"
                        else
                            grouped = ""
                        end

                        classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[friendTable[i][3]], GetQuestDifficultyColor(friendTable[i][2])
                        if classc == nil then
                            classc = GetQuestDifficultyColor(friendTable[i][2])
                        end

                        menuCountWhispers = menuCountWhispers + 1
                        module.menuList[3].menuList[menuCountWhispers] = {
                            text         = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, friendTable[i][2], classc.r * 255, classc.g * 255, classc.b * 255, friendTable[i][1], grouped),
                            arg1         = friendTable[i][1],
                            notCheckable = true,
                            func         = function(_, arg1)
                                module.menuFrame:Hide()
                                SetItemRef("player:" .. arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
                            end
                        }

                        if not (UnitInParty(friendTable[i][1]) or UnitInRaid(friendTable[i][1])) then
                            menuCountInvites = menuCountInvites + 1
                            module.menuList[2].menuList[menuCountInvites] = {
                                text         = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", levelc.r * 255, levelc.g * 255, levelc.b * 255, friendTable[i][2], classc.r * 255, classc.g * 255, classc.b * 255, friendTable[i][1]),
                                arg1         = friendTable[i][1],
                                notCheckable = true,
                                func         = function(_, arg1)
                                    module.menuFrame:Hide()
                                    InviteUnit(arg1)
                                end
                            }
                        end
                    end
                end
            end

            if totalBattleNetOnline > 0 then
                for i = 1, #BNTable do
                    if BNTable[i][7] then
                        if UnitInParty(BNTable[i][4]) or UnitInRaid(BNTable[i][4]) then
                            grouped = " |cffaaaaaa*|r"
                        else
                            grouped = ""
                        end

                        menuCountWhispers = menuCountWhispers + 1
                        module.menuList[3].menuList[menuCountWhispers] = {
                            text         = BNTable[i][2] .. grouped,
                            arg1         = BNTable[i][2],
                            notCheckable = true,
                            func         = function(_, arg1)
                                module.menuFrame:Hide()
                                ChatFrame_SendBNetTell(arg1)
                            end
                        }

                        if BNTable[i][6] == BNET_CLIENT_WOW and UnitFactionGroup("player") == BNTable[i][12] then
                            if not (UnitInParty(BNTable[i][4]) or UnitInRaid(BNTable[i][4])) then
                                classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[BNTable[i][14]], GetQuestDifficultyColor(BNTable[i][16])
                                if classc == nil then
                                    classc = GetQuestDifficultyColor(BNTable[i][16])
                                end
                                menuCountInvites = menuCountInvites + 1
                                module.menuList[2].menuList[menuCountInvites] = {
                                    text         = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r", levelc.r * 255, levelc.g * 255, levelc.b * 255, BNTable[i][16], classc.r * 255, classc.g * 255, classc.b * 255, BNTable[i][4]),
                                    arg1         = BNTable[i][5],
                                    notCheckable = true,
                                    func         = function(_, arg1)
                                        module.menuFrame:Hide()
                                        BNInviteFriend(arg1)
                                    end
                                }
                            end
                        end
                    end
                end
            end

            EasyMenu(module.menuList, module.menuFrame, self, 0, 0, "MENU")
        end
    end,
    OnEnter  = function(self)
        C_FriendList_ShowFriends()
        self.hovered = true
        local online, total = C_FriendList_GetNumOnlineFriends(), C_FriendList_GetNumFriends()
        local name, level, class, zone, connected, status, note, classc, levelc, zone_r, zone_g, zone_b, grouped, realm_r, realm_g, realm_b
        local BNonline, BNtotal = 0, BNGetNumFriends()
        wipe(BNTableEnter)
        if BNtotal > 0 then
            for i = 1, BNtotal do
                local accountInfo = C_BattleNet_GetFriendAccountInfo(i)
                BNTableEnter[i] = { accountInfo, accountInfo.gameAccountInfo.clientProgram }
                if accountInfo.gameAccountInfo.isOnline then
                    BNonline = BNonline + 1
                end
            end
        end
        local totalonline = online + BNonline
        local totalfriends = total + BNtotal
        if online > 0 or BNonline > 0 then
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint(cfg.tip_anchor, cfg.tip_frame, cfg.tip_x, cfg.tip_y)
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(FRIENDS_LIST, format("%s: %s/%s", GUILD_ONLINE_LABEL, totalonline, totalfriends), module.tthead.r, module.tthead.g, module.tthead.b, module.tthead.r, module.tthead.g, module.tthead.b)
            if online > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(WOW_FRIEND)
                for i = 1, total do
                    name, level, class, zone, connected, status, note = GetFriendInfo(i)
                    if not connected then break end
                    if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1.0, 0.3 else zone_r, zone_g, zone_b = 0.65, 0.65, 0.65 end
                    for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
                    if GetLocale() ~= "enUS" then
                        for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
                    end
                    classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
                    if not classc then
                        classc = { r = 1, g = 1, b = 1 }
                    end
                    grouped = (UnitInParty(name) or UnitInRaid(name)) and (GetRealZoneText() == zone and " |cff7fff00*|r" or " |cffff7f00*|r") or ""
                    GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%d|r %s%s%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, level, name, grouped, " " .. status), zone, classc.r, classc.g, classc.b, zone_r, zone_g, zone_b)
                    if self.altdown and note then GameTooltip:AddLine("  " .. note, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1) end
                end
            end
            if BNonline > 0 then
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(BATTLENET_FRIEND)
                for i = 1, #BNTableEnter do
                    local accountInfo = BNTableEnter[i][1]
                    local isOnline = accountInfo.gameAccountInfo.isOnline
                    local client = accountInfo.gameAccountInfo.clientProgram
                    if isOnline then
                        if client == BNET_CLIENT_WOW then
                            if accountInfo.isAFK then
                                status = "|cffE7E716" .. L.CHAT_AFK .. "|r"
                            else
                                if accountInfo.isDND then
                                    status = "|cffff0000" .. L.CHAT_DND .. "|r"
                                else
                                    status = ""
                                end
                            end

                            local characterName = accountInfo.gameAccountInfo.characterName
                            local realmName = accountInfo.gameAccountInfo.realmName
                            local areaName = accountInfo.gameAccountInfo.areaName
                            class = accountInfo.gameAccountInfo.className
                            level = accountInfo.gameAccountInfo.characterLevel

                            for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do if class == v then class = k end end
                            if GetLocale() ~= "enUS" then
                                for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do if class == v then class = k end end
                            end
                            classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
                            if not classc then
                                classc = { r = 1, g = 1, b = 1 }
                            end
                            if UnitInParty(characterName) or UnitInRaid(characterName) then grouped = " |cffaaaaaa*|r" else grouped = "" end
                            if accountInfo.gameAccountInfo.factionName ~= UnitFactionGroup("player") then
                                grouped = " |cffff0000*|r"
                            end
                            GameTooltip:AddDoubleLine(format("%s (|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r%s) |cff%02x%02x%02x%s|r", client, levelc.r * 255, levelc.g * 255, levelc.b * 255, level, classc.r * 255, classc.g * 255, classc.b * 255, characterName, grouped, 255, 0, 0, status), accountInfo.accountName, 238, 238, 238, 238, 238, 238)
                            if self.altdown then
                                if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1.0, 0.3 else zone_r, zone_g, zone_b = 0.65, 0.65, 0.65 end
                                if GetRealmName() == realmName then realm_r, realm_g, realm_b = 0.3, 1.0, 0.3 else realm_r, realm_g, realm_b = 0.65, 0.65, 0.65 end
                                GameTooltip:AddDoubleLine("  " .. areaName, realmName, zone_r, zone_g, zone_b, realm_r, realm_g, realm_b)
                            end
                        else
                            if client == "App" then
                                client = accountInfo.gameAccountInfo.richPresence
                            else
                                client = clientTags[client]
                            end
                            if accountInfo.gameAccountInfo.isGameAFK then
                                status = "|cffE7E716" .. L.CHAT_AFK .. "|r"
                            else
                                if accountInfo.gameAccountInfo.isGameBusy then
                                    status = "|cffff0000" .. L.CHAT_DND .. "|r"
                                else
                                    status = ""
                                end
                            end
                            GameTooltip:AddDoubleLine("|cffeeeeee" .. accountInfo.accountName .. "|r" .. " " .. status, "|cffeeeeee" .. client .. "|r")
                        end
                    end
                end
            end
            GameTooltip:Show()
        else
            module:HideTT(self)
        end
    end
})
