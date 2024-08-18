local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Guild.enable then return end

----------------------------------------------------------------------------------------
--    Guild of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local Ambiguate = Ambiguate
local C_GuildInfo_GuildRoster = C_GuildInfo.GuildRoster
local EasyMenu = EasyMenu
local IsInGuild = IsInGuild
local IsAltKeyDown, IsShiftKeyDown = IsAltKeyDown, IsShiftKeyDown
local C_PartyInfo_InviteUnit = C_PartyInfo.InviteUnit
local GetRealZoneText = GetRealZoneText
local GetQuestDifficultyColor = GetQuestDifficultyColor
local GetNumGuildMembers = GetNumGuildMembers
local GetGuildInfo = GetGuildInfo
local GetGuildRosterInfo, GetGuildRosterMOTD = GetGuildRosterInfo, GetGuildRosterMOTD
local SetItemRef = SetItemRef
local ToggleGuildFrame = ToggleGuildFrame
local UnitInParty, UnitInRaid = UnitInParty, UnitInRaid
local format, wipe, tsort = format, wipe, table.sort
local hooksecurefunc = hooksecurefunc
local ALT_KEY = ALT_KEY
local EPGP = EPGP
local LOOKINGFORGUILD = LOOKINGFORGUILD
local GUILD_ONLINE_LABEL = GUILD_ONLINE_LABEL
local GUILD_MOTD = GUILD_MOTD
local CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS
local REMOTE_CHAT = REMOTE_CHAT
local NOTE_COLON = NOTE_COLON
local GameTooltip = GameTooltip

local cfg = C.stats.config.Guild

local guildTable = {}

local function BuildGuildTable()
    wipe(guildTable)
    for i = 1, GetNumGuildMembers() do
        local name, rank, _, level, _, zone, note, officernote, connected, status, class, _, _, mobile = GetGuildRosterInfo(i)
        if not name then break end
        name = Ambiguate(name, "none")
        guildTable[i] = { name, rank, level, zone, note, officernote, connected, status, class, mobile }
    end
    tsort(guildTable, function(a, b)
        if (a and b) then
            return a[1] < b[1]
        end
    end)
end

hooksecurefunc("SortGuildRoster", function(type) CURRENT_GUILD_SORTING = type end)

local SortGuildRoster = SortGuildRoster

module:Inject("Guild", {
    text     = {
        string = function()
            if IsInGuild() then
                local total, _, online = GetNumGuildMembers()
                return format(cfg.fmt, online, total)
            else return LOOKINGFORGUILD end
        end, update = 5
    },
    OnLoad   = function(self)
        C_GuildInfo_GuildRoster()
        SortGuildRoster(cfg.sorting == "note" and "rank" or "note")
        SortGuildRoster(cfg.sorting)
        self:RegisterEvent("GROUP_ROSTER_UPDATE")
        self:RegisterEvent("GUILD_ROSTER_UPDATE")
    end,
    OnEvent  = function(self)
        if self.hovered then
            self:GetScript("OnEnter")(self)
        end
        if IsInGuild() then
            BuildGuildTable()
        end
    end,
    OnUpdate = function(self, u)
        if IsInGuild() then
            module:AltUpdate(self)
            if not self.gmotd then
                if self.elapsed > 1 then
                    C_GuildInfo_GuildRoster()
                    self.elapsed = 0
                end
                if GetGuildRosterMOTD() ~= "" then
                    self.gmotd = true
                    if self.hovered then self:GetScript("OnEnter")(self) end
                end
                self.elapsed = self.elapsed + u
            end
        end
    end,
    OnClick  = function(self, b)
        if b == "LeftButton" then
            ToggleGuildFrame()
        elseif b == "MiddleButton" and IsInGuild() then
            local s = CURRENT_GUILD_SORTING
            SortGuildRoster(IsShiftKeyDown() and s or (IsAltKeyDown() and (s == "rank" and "note" or "rank") or s == "class" and "name" or s == "name" and "level" or s == "level" and "zone" or "class"))
            self:GetScript("OnEnter")(self)
        elseif b == "RightButton" and IsInGuild() then
            module:HideTT(self)

            local grouped
            local menuCountWhispers = 0
            local menuCountInvites = 0

            module.menuList[2].menuList = {}
            module.menuList[3].menuList = {}

            for i = 1, #guildTable do
                if (guildTable[i][7] or guildTable[i][10]) and guildTable[i][1] ~= E.myName then
                    local classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[guildTable[i][9]], GetQuestDifficultyColor(guildTable[i][3])
                    if UnitInParty(guildTable[i][1]) or UnitInRaid(guildTable[i][1]) then
                        grouped = "|cffaaaaaa*|r"
                    else
                        grouped = ""
                        if not guildTable[i][10] then
                            menuCountInvites = menuCountInvites + 1
                            module.menuList[2].menuList[menuCountInvites] = {
                                text         = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s", levelc.r * 255, levelc.g * 255, levelc.b * 255, guildTable[i][3], classc.r * 255, classc.g * 255, classc.b * 255, Ambiguate(guildTable[i][1], "all"), ""),
                                arg1         = guildTable[i][1],
                                notCheckable = true,
                                func         = function(_, arg1)
                                    module.menuFrame:Hide()
                                    C_PartyInfo_InviteUnit(arg1)
                                end
                            }
                        end
                    end
                    menuCountWhispers = menuCountWhispers + 1
                    module.menuList[3].menuList[menuCountWhispers] = {
                        text         = format("|cff%02x%02x%02x%d|r |cff%02x%02x%02x%s|r %s", levelc.r * 255, levelc.g * 255, levelc.b * 255, guildTable[i][3], classc.r * 255, classc.g * 255, classc.b * 255, Ambiguate(guildTable[i][1], "all"), grouped),
                        arg1         = guildTable[i][1],
                        notCheckable = true,
                        func         = function(_, arg1)
                            module.menuFrame:Hide()
                            SetItemRef("player:" .. arg1, ("|Hplayer:%1$s|h[%1$s]|h"):format(arg1), "LeftButton")
                        end
                    }
                end
            end

            EasyMenu(module.menuList, module.menuFrame, self, 0, 0, "MENU")
        end
    end,
    OnEnter  = function(self)
        if IsInGuild() then
            self.hovered = true
            C_GuildInfo_GuildRoster()
            local name, rank, level, zone, note, officernote, connected, status, class, isMobile, zone_r, zone_g, zone_b, classc, levelc, grouped
            local total, _, online = GetNumGuildMembers()
            local gmotd = GetGuildRosterMOTD()

            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:ClearAllPoints()
            GameTooltip:SetPoint(cfg.tip_anchor, cfg.tip_frame, cfg.tip_x, cfg.tip_y)
            GameTooltip:ClearLines()
            GameTooltip:AddDoubleLine(GetGuildInfo("player"), format("%s: %d/%d", GUILD_ONLINE_LABEL, online, total), module.tthead.r, module.tthead.g, module.tthead.b, module.tthead.r, module.tthead.g, module.tthead.b)
            if gmotd ~= "" then GameTooltip:AddLine(format("%s |cffaaaaaa- |cffffffff%s", GUILD_MOTD, gmotd), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1) end
            if cfg.maxguild ~= 0 and online >= 1 then
                GameTooltip:AddLine(" ")
                for i = 1, total do
                    if cfg.maxguild and i > cfg.maxguild then
                        if online > 2 then GameTooltip:AddLine(format("%d %s (%s)", online - cfg.maxguild, L.DATATEXT_HIDDEN, ALT_KEY), module.ttsubh.r, module.ttsubh.g, module.ttsubh.b) end
                        break
                    end
                    name, rank, _, level, _, zone, note, officernote, connected, status, class, _, _, isMobile = GetGuildRosterInfo(i)
                    if (connected or isMobile) and level >= cfg.threshold then
                        name = Ambiguate(name, "all")
                        if GetRealZoneText() == zone then zone_r, zone_g, zone_b = 0.3, 1, 0.3 else zone_r, zone_g, zone_b = 1, 1, 1 end
                        if isMobile then zone = "|cffa5a5a5" .. REMOTE_CHAT .. "|r" end
                        classc, levelc = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class], GetQuestDifficultyColor(level)
                        grouped = (UnitInParty(name) or UnitInRaid(name)) and (GetRealZoneText() == zone and " |cff7fff00*|r" or " |cffff7f00*|r") or ""
                        if self.altdown then
                            GameTooltip:AddDoubleLine(format("%s%s |cff999999- |cffffffff%s", grouped, name, rank), zone, classc.r, classc.g, classc.b, zone_r, zone_g, zone_b)
                            if note ~= "" then GameTooltip:AddLine("   " .. NOTE_COLON .. " " .. note, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b, 1) end
                            if officernote ~= "" and EPGP then
                                local ep, gp = EPGP:GetEPGP(name)
                                if ep then
                                    officernote = "   EP: " .. ep .. "  GP: " .. gp .. "  PR: " .. format("%.3f", ep / gp)
                                else
                                    officernote = "   O." .. NOTE_COLON .. " " .. officernote
                                end
                            elseif officernote ~= "" then
                                officernote = "   O." .. NOTE_COLON .. " " .. officernote
                            end
                            if officernote ~= "" then GameTooltip:AddLine(officernote, 0.3, 1, 0.3, 1) end
                        else
                            if status == 1 then
                                status = " |cffE7E716" .. L.CHAT_AFK .. "|r"
                            elseif status == 2 then
                                status = " |cffff0000" .. L.CHAT_DND .. "|r"
                            else
                                status = ""
                            end
                            GameTooltip:AddDoubleLine(format("|cff%02x%02x%02x%d|r %s%s%s", levelc.r * 255, levelc.g * 255, levelc.b * 255, level, name, status, grouped), zone, classc.r, classc.g, classc.b, zone_r, zone_g, zone_b)
                        end
                    end
                end
                GameTooltip:AddLine(" ")
                GameTooltip:AddDoubleLine(" ", format("%s %s", L.DATATEXT_SORTING_BY, CURRENT_GUILD_SORTING), 1, 1, 1, module.ttsubh.r, module.ttsubh.g, module.ttsubh.b)
            end
            GameTooltip:Show()
        end
    end
})