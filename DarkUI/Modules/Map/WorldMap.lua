local E, C, L = select(2, ...):unpack()

if not C.map.worldmap.enable then return end

----------------------------------------------------------------------------------------
--	WorldMapFrame Styles
----------------------------------------------------------------------------------------
local module = E:Module("Map"):Sub("WorldMap")

local CreateFrame = CreateFrame
local GetNumQuestLogEntries = GetNumQuestLogEntries
local CreateVector2D = CreateVector2D
local C_QuestLog_GetMaxNumQuestsCanAccept = C_QuestLog.GetMaxNumQuestsCanAccept
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local UnitName, UnitPosition = UnitName, UnitPosition
local QuestMapFrame = QuestMapFrame
local MapQuestInfoRewardsFrame_XPFrame_Name = MapQuestInfoRewardsFrame.XPFrame.Name
local WorldMapFrame, CharacterFrame, SpellBookFrame = WorldMapFrame, CharacterFrame, SpellBookFrame
local PlayerTalentFrame, ChannelFrame, PVEFrame = PlayerTalentFrame, ChannelFrame, PVEFrame
local hooksecurefunc = hooksecurefunc
local unpack, select = unpack, select
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local MAP_AND_QUEST_LOG = MAP_AND_QUEST_LOG
local PLAYER = PLAYER

function module:OnInit()
    --	Font replacement
    MapQuestInfoRewardsFrame_XPFrame_Name:SetFont(STANDARD_TEXT_FONT, 12)

    --	Change position
    hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", function()
        if CharacterFrame:IsShown() or SpellBookFrame:IsShown() or
                (PlayerTalentFrame and PlayerTalentFrame:IsShown()) or
                (ChannelFrame and ChannelFrame:IsShown()) or
                PVEFrame:IsShown()
        then
            return
        end
        if not WorldMapFrame:IsMaximized() then
            WorldMapFrame:ClearAllPoints()
            WorldMapFrame:SetPoint(unpack(C.map.worldmap.position))
        end
    end)
    WorldMapFrame:SetClampedToScreen(true)

    --	Creating coordinate
    local coords = CreateFrame("Frame", "CoordsFrame", WorldMapFrame)
    coords:SetFrameLevel(WorldMapFrame.BorderFrame:GetFrameLevel() + 2)
    coords:SetFrameStrata(WorldMapFrame.BorderFrame:GetFrameStrata())

    coords.PlayerText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    coords.PlayerText:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer, "BOTTOM", -40, 20)
    coords.PlayerText:SetJustifyH("LEFT")
    coords.PlayerText:SetText(UnitName("player") .. ": 0,0")

    coords.MouseText = coords:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    coords.MouseText:SetJustifyH("LEFT")
    coords.MouseText:SetPoint("BOTTOMLEFT", coords.PlayerText, "TOPLEFT", 0, 5)
    coords.MouseText:SetText(L.MAP_MOUSEOVER .. ": 0,0")

    local mapRects, tempVec2D = {}, CreateVector2D(0, 0)
    local function GetPlayerMapPos(mapID)
        tempVec2D.x, tempVec2D.y = UnitPosition("player")
        if not tempVec2D.x then return end

        local mapRect = mapRects[mapID]
        if not mapRect then
            mapRect = {
                select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0))),
                select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
            }
            mapRect[2]:Subtract(mapRect[1])
            mapRects[mapID] = mapRect
        end
        tempVec2D:Subtract(mapRect[1])

        return (tempVec2D.y / mapRect[2].y), (tempVec2D.x / mapRect[2].x)
    end

    local int = 0
    WorldMapFrame:HookScript("OnUpdate", function()
        int = int + 1
        if int >= 3 then
            local unitMap = C_Map_GetBestMapForUnit("player")
            local x, y = 0, 0

            if unitMap then x, y = GetPlayerMapPos(unitMap) end

            if x and y and x >= 0 and y >= 0 then
                coords.PlayerText:SetFormattedText("%s: %.1f, %.1f", PLAYER, x * 100, y * 100)
            else
                coords.PlayerText:SetText(UnitName("player") .. ": " .. "|cffff0000" .. L.MAP_BOUNDS .. "|r")
            end

            if WorldMapFrame.ScrollContainer:IsMouseOver() then
                local mouseX, mouseY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
                if mouseX and mouseY and mouseX >= 0 and mouseY >= 0 then
                    coords.MouseText:SetFormattedText("%s: %.1f, %.1f", L.MAP_MOUSEOVER, mouseX * 100, mouseY * 100)
                else
                    coords.MouseText:SetText(L.MAP_MOUSEOVER .. "|cffff0000" .. L.MAP_BOUNDS .. "|r")
                end
            else
                coords.MouseText:SetText(L.MAP_MOUSEOVER .. "|cffff0000" .. L.MAP_BOUNDS .. "|r")
            end

            WorldMapFrame.BorderFrame:SetTitle(MAP_AND_QUEST_LOG .. " [" .. select(2, C_QuestLog_GetNumQuestLogEntries()) .. "/" .. C_QuestLog_GetMaxNumQuestsCanAccept() .. "]")
            int = 0
        end
    end)
end
