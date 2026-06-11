local E, C, L, DB = select(2, ...):unpack()

------------------------------------------------------------------------
-- WorldMap
------------------------------------------------------------------------
local module = E:Module("Map"):Sub("WorldMap")

local cfg = C.map.worldmap

local format, select = string.format, select
local strmatch, gmatch = strmatch, gmatch
local wipe, tinsert, pairs, ceil, mod = wipe, tinsert, pairs, ceil, mod
local tonumber = tonumber
local CreateFrame = CreateFrame
local CreateVector2D = CreateVector2D
local UnitPosition = UnitPosition
local hooksecurefunc = hooksecurefunc
local WorldMapFrame = WorldMapFrame
local GameFontNormal = GameFontNormal
local C_Map_GetBestMapForUnit = C_Map.GetBestMapForUnit
local C_Map_GetWorldPosFromMapPos = C_Map.GetWorldPosFromMapPos
local C_Map_GetMapArtID = C_Map.GetMapArtID
local C_Map_GetMapArtLayers = C_Map.GetMapArtLayers
local C_MapExplorationInfo_GetExploredMapTextures = C_MapExplorationInfo.GetExploredMapTextures
local C_QuestLog_GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
local TexturePool_HideAndClearAnchors = TexturePool_HideAndClearAnchors

local mapRects = {}
local tempVec2D = CreateVector2D(0, 0)
local currentMapID, playerCoords, cursorCoords
local shownMapCache, exploredCache, fileDataIDs, storedTex = {}, {}, {}, {}

------------------------------------------------------------------------
-- Coordinates
------------------------------------------------------------------------

local function getPlayerMapPos(mapID)
    if not mapID then
        return
    end
    tempVec2D.x, tempVec2D.y = UnitPosition("player")
    if not tempVec2D.x then
        return
    end

    local mapRect = mapRects[mapID]
    if not mapRect then
        local pos1 = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(0, 0)))
        local pos2 = select(2, C_Map_GetWorldPosFromMapPos(mapID, CreateVector2D(1, 1)))
        if not pos1 or not pos2 then
            return
        end
        mapRect = { pos1, pos2 }
        mapRect[2]:Subtract(mapRect[1])
        mapRects[mapID] = mapRect
    end
    tempVec2D:Subtract(mapRect[1])

    return tempVec2D.y / mapRect[2].y, tempVec2D.x / mapRect[2].x
end

local function getCursorCoords()
    if not WorldMapFrame.ScrollContainer:IsMouseOver() then
        return
    end
    local cursorX, cursorY = WorldMapFrame.ScrollContainer:GetNormalizedCursorPosition()
    if cursorX < 0 or cursorX > 1 or cursorY < 0 or cursorY > 1 then
        return
    end
    return cursorX, cursorY
end

local function updateMapID(self)
    if self:GetMapID() == C_Map_GetBestMapForUnit("player") then
        currentMapID = self:GetMapID()
    else
        currentMapID = nil
    end
end

local function updateCoords(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < 0.1 then
        return
    end
    self.elapsed = 0

    local cursorX, cursorY = getCursorCoords()
    if cursorX and cursorY then
        cursorCoords:SetFormattedText("%s: %.1f, %.1f", L.MAP_MOUSEOVER, 100 * cursorX, 100 * cursorY)
        cursorCoords:Show()
    else
        cursorCoords:Hide()
    end

    if not currentMapID then
        playerCoords:SetFormattedText("%s: --, --", PLAYER)
    else
        local x, y = getPlayerMapPos(currentMapID)
        if not x or (x == 0 and y == 0) then
            playerCoords:SetFormattedText("%s: --, --", PLAYER)
        else
            playerCoords:SetFormattedText("%s: %.1f, %.1f", PLAYER, 100 * x, 100 * y)
        end
    end

    local _, numQuests = C_QuestLog_GetNumQuestLogEntries()
    local maxQuests = C_QuestLog.GetMaxNumQuestsCanAccept and C_QuestLog.GetMaxNumQuestsCanAccept() or 35
    WorldMapFrame.BorderFrame:SetTitle(format("%s [%d/%d]", MAP_AND_QUEST_LOG, numQuests, maxQuests))
end

------------------------------------------------------------------------
-- Map Reveal (Fog Removal)
------------------------------------------------------------------------

local function getStringFromInfo(info)
    return format("W%dH%dX%dY%d", info.textureWidth, info.textureHeight, info.offsetX, info.offsetY)
end

local function getShapesFromString(str)
    local w, h, x, y = strmatch(str, "W(%d*)H(%d*)X(%d*)Y(%d*)")
    return tonumber(w), tonumber(h), tonumber(x), tonumber(y)
end

local function refreshFileIDsByString(str)
    wipe(fileDataIDs)
    for fileID in gmatch(str, "%d+") do
        tinsert(fileDataIDs, fileID)
    end
end

local function mapDataRefreshOverlays(self, fullUpdate)
    wipe(shownMapCache)
    wipe(exploredCache)
    for _, tex in pairs(storedTex) do
        tex:SetVertexColor(1, 1, 1)
    end
    wipe(storedTex)

    local mapID = WorldMapFrame.mapID
    if not mapID then
        return
    end

    local mapArtID = C_Map_GetMapArtID(mapID)
    local rawMapData = E:Module("Map").RawMapData
    local mapData = mapArtID and rawMapData[mapArtID]
    if not mapData then
        return
    end

    local exploredMapTextures = C_MapExplorationInfo_GetExploredMapTextures(mapID)
    if exploredMapTextures then
        for _, exploredTextureInfo in pairs(exploredMapTextures) do
            exploredCache[getStringFromInfo(exploredTextureInfo)] = true
        end
    end

    if not self.layerIndex then
        self.layerIndex = WorldMapFrame.ScrollContainer:GetCurrentLayerIndex()
    end
    local layers = C_Map_GetMapArtLayers(mapID)
    local layerInfo = layers and layers[self.layerIndex]
    if not layerInfo then
        return
    end

    local TILE_SIZE_WIDTH = layerInfo.tileWidth
    local TILE_SIZE_HEIGHT = layerInfo.tileHeight

    for i, exploredInfoString in pairs(mapData) do
        if not exploredCache[i] then
            local width, height, offsetX, offsetY = getShapesFromString(i)
            refreshFileIDsByString(exploredInfoString)
            local numTexturesWide = ceil(width / TILE_SIZE_WIDTH)
            local numTexturesTall = ceil(height / TILE_SIZE_HEIGHT)
            local texturePixelWidth, textureFileWidth, texturePixelHeight, textureFileHeight

            for j = 1, numTexturesTall do
                if j < numTexturesTall then
                    texturePixelHeight = TILE_SIZE_HEIGHT
                    textureFileHeight = TILE_SIZE_HEIGHT
                else
                    texturePixelHeight = mod(height, TILE_SIZE_HEIGHT)
                    if texturePixelHeight == 0 then
                        texturePixelHeight = TILE_SIZE_HEIGHT
                    end
                    textureFileHeight = 16
                    while textureFileHeight < texturePixelHeight do
                        textureFileHeight = textureFileHeight * 2
                    end
                end
                for k = 1, numTexturesWide do
                    local texture = self.overlayTexturePool:Acquire()
                    tinsert(storedTex, texture)
                    if k < numTexturesWide then
                        texturePixelWidth = TILE_SIZE_WIDTH
                        textureFileWidth = TILE_SIZE_WIDTH
                    else
                        texturePixelWidth = width % TILE_SIZE_WIDTH
                        if texturePixelWidth == 0 then
                            texturePixelWidth = TILE_SIZE_WIDTH
                        end
                        textureFileWidth = 16
                        while textureFileWidth < texturePixelWidth do
                            textureFileWidth = textureFileWidth * 2
                        end
                    end
                    texture:SetWidth(texturePixelWidth)
                    texture:SetHeight(texturePixelHeight)
                    texture:SetTexCoord(0, texturePixelWidth / textureFileWidth, 0, texturePixelHeight / textureFileHeight)
                    texture:SetPoint("TOPLEFT", offsetX + (TILE_SIZE_WIDTH * (k - 1)), -(offsetY + (TILE_SIZE_HEIGHT * (j - 1))))
                    texture:SetTexture(fileDataIDs[((j - 1) * numTexturesWide) + k], nil, nil, "TRILINEAR")
                    texture:SetDrawLayer("ARTWORK", -1)

                    if cfg.revealGlow then
                        texture:SetVertexColor(0.7, 0.7, 0.7)
                    else
                        texture:SetVertexColor(1, 1, 1)
                    end

                    texture:SetShown(cfg.revealMap)

                    if fullUpdate then
                        self.textureLoadGroup:AddTexture(texture)
                    end
                    tinsert(shownMapCache, texture)
                end
            end
        end
    end
end

local function mapDataResetTexturePool(pool, texture)
    texture:SetVertexColor(1, 1, 1)
    texture:SetAlpha(1)
    return TexturePool_HideAndClearAnchors(pool, texture)
end

------------------------------------------------------------------------
-- Setup
------------------------------------------------------------------------

-- WorldMapFrame is a protected frame: SetScale/SetPoint on it are blocked in
-- combat lockdown, so bail out then to avoid an ADDON_ACTION_BLOCKED message.
local function applyMapLayout(self)
    if InCombatLockdown() then
        return
    end

    local scale = self.isMaximized and cfg.maxScale or cfg.scale
    if self:GetScale() ~= scale then
        self:SetScale(scale)
    end

    self:ClearAllPoints()
    self:SetPoint(unpack(cfg.position))
end

local function setupMapScale()
    -- Keep WorldMapFrame inside Blizzard's secure panel system (no UIPanelLayout
    -- detach, no movable/drag): tainting it would block protected calls such as
    -- QuestDataProvider's SetPassThroughButtons. Only scale and re-anchor it,
    -- always via secure hooks so the position follows cfg.position.
    WorldMapFrame:SetClampedToScreen(true)

    WorldMapFrame:ClearAllPoints()
    WorldMapFrame:SetPoint(unpack(cfg.position))

    WorldMapFrame.BlackoutFrame:SetAlpha(0)
    WorldMapFrame.BlackoutFrame:EnableMouse(false)

    hooksecurefunc(WorldMapFrame, "SynchronizeDisplayState", applyMapLayout)
    WorldMapFrame:HookScript("OnShow", applyMapLayout)
end

local function setupCoords()
    local textParent = CreateFrame("Frame", nil, WorldMapFrame)
    textParent:SetPoint("BOTTOMLEFT", WorldMapFrame.ScrollContainer)
    textParent:SetSize(1, 18)
    textParent:SetFrameLevel(5)

    local bgTex = textParent:CreateTexture(nil, "BACKGROUND")
    bgTex:SetTexture(C.media.texture.blank)
    bgTex:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0.5), CreateColor(0, 0, 0, 0))
    bgTex:SetPoint("LEFT")
    bgTex:SetSize(450, 18)

    playerCoords = textParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    playerCoords:SetPoint("LEFT", textParent, "LEFT", 5, 0)
    playerCoords:SetJustifyH("LEFT")

    cursorCoords = textParent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cursorCoords:SetPoint("LEFT", textParent, "LEFT", 180, 0)
    cursorCoords:SetJustifyH("LEFT")

    hooksecurefunc(WorldMapFrame, "OnFrameSizeChanged", updateMapID)
    hooksecurefunc(WorldMapFrame, "OnMapChanged", updateMapID)

    local coordsUpdater = CreateFrame("Frame", nil, WorldMapFrame.BorderFrame)
    coordsUpdater:SetScript("OnUpdate", updateCoords)
end

local explorationPin

local function setupRevealMap()
    local bu = CreateFrame("CheckButton", nil, WorldMapFrame.BorderFrame.TitleContainer, "OptionsBaseCheckButtonTemplate")
    bu:SetHitRectInsets(-5, -5, -5, -5)
    bu:SetPoint("BOTTOMLEFT", WorldMapFrameHomeButton, "TOPLEFT", 25, 2)
    bu:SetSize(26, 26)
    E:ReskinCheckBox(bu)
    bu:SetChecked(cfg.revealMap)

    bu.f = bu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bu.f:SetFont(GameFontNormal:GetFont(), 14, "")
    bu.f:SetPoint("LEFT", bu, "RIGHT", 5, 0)
    bu.f:SetText(L.MAP_REVEALMAP)

    for pin in WorldMapFrame:EnumeratePinsByTemplate("MapExplorationPinTemplate") do
        explorationPin = pin
        hooksecurefunc(pin, "RefreshOverlays", mapDataRefreshOverlays)
        pin.overlayTexturePool.resetterFunc = mapDataResetTexturePool
    end

    bu:SetScript("OnClick", function(self)
        local checked = self:GetChecked()
        cfg.revealMap = checked
        DB:Set("map.worldmap.revealMap", checked)
        if explorationPin then
            explorationPin:RefreshOverlays(true)
        end
    end)
end

------------------------------------------------------------------------
-- Module Init
------------------------------------------------------------------------

function module:OnInit()
    if not cfg or not cfg.enable then
        return
    end
    if C_AddOns.IsAddOnLoaded("Mapster") then
        return
    end

    setupMapScale()
    setupCoords()
    setupRevealMap()
end
