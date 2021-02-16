local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Location.enable then return end

----------------------------------------------------------------------------------------
--	Location of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------

local GetSubZoneText, GetZonePVPInfo, GetZoneText = GetSubZoneText, GetZonePVPInfo, GetZoneText
local IsInInstance = IsInInstance
local IsShiftKeyDown = IsShiftKeyDown
local SendChatMessage = SendChatMessage
local ToggleFrame = ToggleFrame
local format, unpack = format, unpack
local strtrim, strsub = strtrim, strsub
local SANCTUARY_TERRITORY = SANCTUARY_TERRITORY
local FREE_FOR_ALL_TERRITORY = FREE_FOR_ALL_TERRITORY
local FACTION_CONTROLLED_TERRITORY = FACTION_CONTROLLED_TERRITORY
local CONTESTED_TERRITORY = CONTESTED_TERRITORY
local COMBAT_ZONE = COMBAT_ZONE
local FACTION_STANDING_LABEL4 = FACTION_STANDING_LABEL4
local GameTooltip = GameTooltip
local WorldMapFrame = WorldMapFrame

local cfg = C.stats.config.Location
local font = C.stats.font
local module = E.datatext

module:Inject("Location", {
    OnLoad   = function(self)
        module:RegEvents(self, "ZONE_CHANGED ZONE_CHANGED_INDOORS ZONE_CHANGED_NEW_AREA PLAYER_ENTERING_WORLD")
        self.sanctuary = { SANCTUARY_TERRITORY, { 0.41, 0.8, 0.94 } }
        self.arena = { FREE_FOR_ALL_TERRITORY, { 1, 0.1, 0.1 } }
        self.friendly = { FACTION_CONTROLLED_TERRITORY, { 0.1, 1, 0.1 } }
        self.hostile = { FACTION_CONTROLLED_TERRITORY, { 1, 0.1, 0.1 } }
        self.contested = { CONTESTED_TERRITORY, { 1, 0.7, 0 } }
        self.combat = { COMBAT_ZONE, { 1, 0.1, 0.1 } }
        self.neutral = { format(FACTION_CONTROLLED_TERRITORY, FACTION_STANDING_LABEL4), { 1, 0.93, 0.76 } }
    end,
    OnEvent  = function(self)
        self.subzone, self.zone, self.pvp = GetSubZoneText(), GetZoneText(), { GetZonePVPInfo() }
        if not self.pvp[1] then self.pvp[1] = "neutral" end
        local label = (self.subzone ~= "" and cfg.subzone) and self.subzone or self.zone
        local r, g, b = unpack(self.pvp[1] and (self[self.pvp[1]][2] or self.other) or self.other)
        self.text:SetText(cfg.truncate == 0 and label or strtrim(strsub(label, 1, cfg.truncate)))
        self.text:SetTextColor(r, g, b, font.alpha)
    end,
    OnUpdate = function(self, u)
        if self.hovered then
            self.elapsed = self.elapsed + u
            if self.elapsed > 1 or self.init then
                GameTooltip:ClearLines()
                GameTooltip:AddLine(format("%s |cffffffff(%s)", self.zone, module:Coords()), module.tthead.r, module.tthead.g, module.tthead.b, 1, 1, 1)
                if self.pvp[1] and not IsInInstance() then
                    local r, g, b = unpack(self[self.pvp[1]][2])
                    if self.subzone and self.subzone ~= self.zone then GameTooltip:AddLine(self.subzone, r, g, b) end
                    GameTooltip:AddLine(format(self[self.pvp[1]][1], self.pvp[3] or ""), r, g, b)
                end
                GameTooltip:Show()
                self.elapsed, self.init = 0, false
            end
        end
    end,
    OnEnter  = function(self)
        self.hovered, self.init = true, true
        GameTooltip:SetOwner(self, "ANCHOR_CURSOR_TOP", 0, 10)
    end,
    OnClick  = function(self)
        if IsShiftKeyDown() then
            local mapID = C_Map.GetBestMapForUnit("player")
            if C_Map.CanSetUserWaypointOnMap(mapID) then
                local pos = C_Map.GetPlayerMapPosition(mapID, "player")
                local mapPoint = UiMapPoint.CreateFromVector2D(mapID, pos)
                C_Map.SetUserWaypoint(mapPoint)
            end
            local hyperlink = C_Map.GetUserWaypointHyperlink() or ""
            ChatEdit_ActivateChat(ChatEdit_ChooseBoxForSend())
            ChatEdit_ChooseBoxForSend():Insert(format(" (%s: %s) %s", self.zone, module:Coords(), hyperlink))
            C_Map.ClearUserWaypoint()
        else
            ToggleFrame(WorldMapFrame)
        end
    end
})
