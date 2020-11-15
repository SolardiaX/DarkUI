local E, C, L = select(2, ...):unpack()

if not C.map.minimap.enable then return end

----------------------------------------------------------------------------------------
--	MiniMap Styles
----------------------------------------------------------------------------------------

local IsAddOnLoaded, LoadAddOn = IsAddOnLoaded, LoadAddOn
local Minimap_ZoomIn, Minimap_ZoomOut = Minimap_ZoomIn, Minimap_ZoomOut
local unpack, select, ipairs = unpack, select, ipairs
local STANDARD_TEXT_FONT = STANDARD_TEXT_FONT
local MinimapCluster, Minimap = MinimapCluster, Minimap
local MinimapBackdrop, MinimapBorder, MinimapBorderTop = MinimapBackdrop, MinimapBorder, MinimapBorderTop
local MinimapZoomIn, MinimapZoomOut = MinimapZoomIn, MinimapZoomOut
local MiniMapTracking, MiniMapTrackingBackground = MiniMapTracking, MiniMapTrackingBackground
local MiniMapTrackingButtonBorder, MiniMapTrackingIcon = MiniMapTrackingButtonBorder, MiniMapTrackingIcon
local MiniMapTrackingIconOverlay = MiniMapTrackingIconOverlay
local MiniMapWorldMapButton, MiniMapTrackingButton = MiniMapWorldMapButton, MiniMapTrackingButton
local MinimapZoneText, MinimapZoneTextButton = MinimapZoneText, MinimapZoneTextButton
local MiniMapMailFrame = MiniMapMailFrame
local GameTimeFrame = GameTimeFrame
local QueueStatusMinimapButton, QueueStatusMinimapButtonBorder = QueueStatusMinimapButton, QueueStatusMinimapButtonBorder
local GarrisonLandingPageMinimapButton = GarrisonLandingPageMinimapButton

local cfg = C.map.minimap

local media = {
    map_gloss   = C.media.path .. "map_gloss",
    map_overlay = C.media.path .. C.general.style .. "\\" .. "map_overlay"
}

local frames_to_rotate = {
    [1] = {
        texture     = C.media.path .. "map_rotating_1",
        width       = 190,
        height      = 190,
        color_red   = C.general.style == "cold" and 126 / 255 or 255 / 255,
        color_green = C.general.style == "cold" and 206 / 255 or 255 / 255,
        color_blue  = C.general.style == "cold" and 244 / 255 or 0 / 255,
        alpha       = 0.2,
        duration    = 60,
        direction   = 1
    },
    [2] = {
        texture     = C.media.path .. "map_rotating_2",
        width       = 175,
        height      = 175,
        color_red   = C.general.style == "cold" and 126 / 255 or 255 / 255,
        color_green = C.general.style == "cold" and 206 / 255 or 255 / 255,
        color_blue  = C.general.style == "cold" and 244 / 255 or 0 / 255,
        alpha       = 0.6,
        duration    = 60,
        direction   = 0
    }
}

if not IsAddOnLoaded("Blizzard_TimeManager") then
    LoadAddOn("Blizzard_TimeManager")
end

--hide regions
MinimapBackdrop:Hide()
MinimapBorder:Hide()
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
MinimapBorderTop:Hide()
MiniMapWorldMapButton:Hide()
MinimapZoneText:Hide()
MinimapZoneTextButton:Hide()

--scale minimap
MinimapCluster:SetScale(cfg.scale)
MinimapCluster:ClearAllPoints()
MinimapCluster:SetPoint(unpack(cfg.position))

--minimap position inside the cluster
Minimap:ClearAllPoints()
Minimap:SetPoint("TOP", 2, -2)

--create rotating cogwheel texture
for index, _ in ipairs(frames_to_rotate) do
    local ftr = frames_to_rotate[index]

    local t = MinimapCluster:CreateTexture(nil, "ARTWORK", nil, -6)
    t:SetTexture(ftr.texture)
    t:SetPoint("CENTER", Minimap, 0, 0)
    t:SetSize(ftr.width * cfg.scale, ftr.height * cfg.scale)
    t:SetVertexColor(ftr.color_red, ftr.color_green, ftr.color_blue, ftr.alpha)
    t:SetBlendMode("BLEND")

    t.ag = t:CreateAnimationGroup()
    t.ag.a1 = t.ag:CreateAnimation("Rotation")
    t.ag.a1:SetDegrees(ftr.direction == 1 and 360 or -360)
    t.ag.a1:SetDuration(ftr.duration)
    t.ag:SetLooping("REPEAT")
    t.ag:Play()
end

--minimap gloss
local gloss = Minimap:CreateTexture(nil, "ARTWORK", nil, -3)
gloss:SetTexture(media.map_gloss)
gloss:SetPoint("CENTER", 0, 0)
gloss:SetSize(Minimap:GetWidth() * 1.2, Minimap:GetHeight() * 1.2)
gloss:SetDesaturated(1)
gloss:SetVertexColor(0.3, 0.3, 0.3, 1)
gloss:SetBlendMode("BLEND")

--minimap border texture
local border = Minimap:CreateTexture(nil, "ARTWORK", nil, -2)
border:SetTexture(media.map_overlay)
border:SetPoint("CENTER", Minimap, "CENTER", -4, -6)
border:SetSize(512 * .72 * cfg.scale, 256 * .72 * cfg.scale)

--TRACKING ICON
MiniMapTracking:SetParent(Minimap)
MiniMapTracking:SetSize(28, 28)
MiniMapTracking:ClearAllPoints()
MiniMapTracking:SetPoint("LEFT", Minimap, "RIGHT", -12, -2)

MiniMapTrackingButton:SetHighlightTexture(nil)
MiniMapTrackingButton:SetPushedTexture(nil)
MiniMapTrackingButton:SetAllPoints(MiniMapTracking)

MiniMapTrackingBackground:Hide()
MiniMapTrackingButtonBorder:Hide()

MiniMapTrackingIcon:ClearAllPoints()
MiniMapTrackingIcon:SetPoint("TOPLEFT", MiniMapTracking, "TOPLEFT", 1, -1)
MiniMapTrackingIcon:SetPoint("BOTTOMRIGHT", MiniMapTracking, "BOTTOMRIGHT", -1, 1)
MiniMapTrackingIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
MiniMapTrackingIcon.SetPoint = E.dummy

MiniMapTrackingIconOverlay:SetTexture(nil)

--MAIL ICON
MiniMapMailFrame:SetSize(cfg.iconSize, cfg.iconSize)
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint(unpack(cfg.iconpos.mail))

--CALENDAR ICON
GameTimeFrame:SetSize(16, 16)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint("TOP", Minimap, "BOTTOM", -3, 12)
GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
GameTimeFrame:SetNormalTexture(nil)
GameTimeFrame:SetPushedTexture(nil)
GameTimeFrame:SetHighlightTexture(nil)

local GameTimeFrameBackground = GameTimeFrame:CreateTexture(nil, "BACKGROUND", nil, -6)
GameTimeFrameBackground:SetTexture(20 / 255, 15 / 255, 10 / 255, 1)
GameTimeFrameBackground:SetAlpha(1)
GameTimeFrameBackground:SetAllPoints(GameTimeFrame)

local GameTimeFrameText = select(5, GameTimeFrame:GetRegions())
GameTimeFrameText:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
GameTimeFrameText:SetPoint("CENTER", 1, 1)
GameTimeFrameText:SetTextColor(195 / 255, 186 / 255, 140 / 255)

--QUEUE STATUS ICON (LFG)
QueueStatusMinimapButton:SetParent(Minimap)
QueueStatusMinimapButton:SetSize(cfg.iconSize, cfg.iconSize)
QueueStatusMinimapButton:ClearAllPoints()
QueueStatusMinimapButton:SetPoint(unpack(cfg.iconpos.queue))

QueueStatusMinimapButtonBorder:Hide()

--Garrison Button
GarrisonLandingPageMinimapButton:SetParent(Minimap)
GarrisonLandingPageMinimapButton:ClearAllPoints()
GarrisonLandingPageMinimapButton:SetPoint("BOTTOMLEFT", Minimap, "TOPRIGHT", -68, -49)
GarrisonLandingPageMinimapButton:SetScale(0.6)

-- Time Manager Icon
local TimeManagerClockButton = TimeManagerClockButton
local TimeManagerClockTicker = TimeManagerClockTicker
if TimeManagerClockButton then
    local region = TimeManagerClockButton:GetRegions()
    region:Hide()
    TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint("TOP", Minimap, "BOTTOM", -4.2, -10)
end

--minimap mousewheel zoom
Minimap:EnableMouseWheel()
Minimap:SetScript("OnMouseWheel", function(_, direction)
    if (direction > 0) then
        Minimap_ZoomIn()
    else
        Minimap_ZoomOut()
    end
end)

-- Auto Zoom Out
if not cfg.autoZoom then return end

local started, current = 0, 0

local zoomOut = function()
    current = current + 1
    if started == current then
        for i = 1, Minimap:GetZoom() or 0 do
            Minimap_ZoomOutClick() -- Call it directly so we don't run our own hook
        end
        started, current = 0, 0
    end
end

local zoomBtnFunc = function()
    started = started + 1
    C_Timer.After(3, zoomOut)
end
zoomBtnFunc()
MinimapZoomIn:HookScript("OnClick", zoomBtnFunc)
MinimapZoomOut:HookScript("OnClick", zoomBtnFunc)