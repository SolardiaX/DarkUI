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
        width       = 250,
        height      = 250,
        color_red   = C.general.style == "cold" and 126 / 255 or 255 / 255,
        color_green = C.general.style == "cold" and 206 / 255 or 255 / 255,
        color_blue  = C.general.style == "cold" and 244 / 255 or 0 / 255,
        alpha       = 0.2,
        duration    = 60,
        direction   = 1
    },
    [2] = {
        texture     = C.media.path .. "map_rotating_2",
        width       = 250,
        height      = 250,
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

-- Disable Minimap Cluster
MinimapCluster:EnableMouse(false)
-- Hide Border
MinimapCompassTexture:Hide()
MinimapCluster.BorderTop:StripTextures()
MinimapBackdrop:Hide()
-- Hide Zoom Buttons
Minimap.ZoomIn:Kill()
Minimap.ZoomOut:Kill()
-- Hide Blob Ring
Minimap:SetArchBlobRingScalar(0)
Minimap:SetQuestBlobRingScalar(0)
-- Hide Zone Frame
MinimapCluster.ZoneTextButton:Hide()

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    --minimap position
    --Minimap:SetSize(152, 152)
    Minimap:ClearAllPoints()
    Minimap:SetPoint(unpack(cfg.position))

    MinimapBackdrop:Kill()

    -- Instance Difficulty icon
	MinimapCluster.InstanceDifficulty:SetParent(Minimap)
	MinimapCluster.InstanceDifficulty:ClearAllPoints()
	MinimapCluster.InstanceDifficulty:SetPoint(unpack(cfg.iconpos.instance))
	MinimapCluster.InstanceDifficulty.Instance.Border:Hide()
    MinimapCluster.InstanceDifficulty.Instance.Background:SetSize(28, 36)
	MinimapCluster.InstanceDifficulty.Instance.Background:SetVertexColor(0.6, 0.3, 0)
    -- MinimapCluster.InstanceDifficulty.Instance.HeroicTexture:ClearAllPoints()
    -- MinimapCluster.InstanceDifficulty.Instance.HeroicTexture:SetPoint("CENTER", 0, 7)
    -- MinimapCluster.InstanceDifficulty.Instance.MythicTexture:ClearAllPoints()
    -- MinimapCluster.InstanceDifficulty.Instance.MythicTexture:SetPoint("CENTER", 0, 7)

	-- Guild Instance Difficulty icon
	MinimapCluster.InstanceDifficulty.Guild.Border:Hide()
	MinimapCluster.InstanceDifficulty.Guild.Background:SetSize(28, 36)
	MinimapCluster.InstanceDifficulty.Guild.Background:ClearAllPoints()
	MinimapCluster.InstanceDifficulty.Guild.Background:SetPoint(unpack(cfg.iconpos.instance))

	-- Challenge Mode icon
	MinimapCluster.InstanceDifficulty.ChallengeMode.Border:Hide()
	MinimapCluster.InstanceDifficulty.ChallengeMode.Background:SetSize(28, 36)
	MinimapCluster.InstanceDifficulty.ChallengeMode.Background:SetVertexColor(0.8, 0.8, 0)
	MinimapCluster.InstanceDifficulty.ChallengeMode.Background:ClearAllPoints()
	MinimapCluster.InstanceDifficulty.ChallengeMode.Background:SetPoint(unpack(cfg.iconpos.instance))

    -- Move QueueStatus icon
	QueueStatusFrame:SetClampedToScreen(true)
	QueueStatusFrame:SetFrameStrata("TOOLTIP")
    QueueStatusButton:SetParent(Minimap)
	QueueStatusButton:ClearAllPoints()
	QueueStatusButton:SetPoint(unpack(cfg.iconpos.queue))
	QueueStatusButton:SetScale(0.48)

    -- Move GameTime icon
    GameTimeFrame:SetSize(26, 26)
    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint(unpack(cfg.iconpos.time))
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    GameTimeFrame:SetNormalTexture(0)
    GameTimeFrame:SetPushedTexture(0)
    GameTimeFrame:SetHighlightTexture(0)

    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint(unpack(cfg.iconpos.clock))
    TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
    TimeManagerClockTicker:SetTextColor(195 / 255, 186 / 255, 140 / 255)
    TimeManagerAlarmFiredTexture:ClearAllPoints()
    TimeManagerAlarmFiredTexture:SetPoint("TOPLEFT", TimeManagerClockTicker, "TOPLEFT", -18, 10)
    TimeManagerAlarmFiredTexture:SetPoint("BOTTOMRIGHT", TimeManagerClockTicker, "BOTTOMRIGHT", 15, -13)
    
    -- Move Mail icon
    MinimapCluster.MailFrame:SetSize(cfg.iconSize, cfg.iconSize)
    MinimapCluster.MailFrame:ClearAllPoints()
    MinimapCluster.MailFrame:SetPoint(unpack(cfg.iconpos.mail))

    -- Move Garrison icon
    hooksecurefunc(ExpansionLandingPageMinimapButton, "UpdateIconForGarrison", function()
        ExpansionLandingPageMinimapButton:SetParent(Minimap)
        ExpansionLandingPageMinimapButton:ClearAllPoints()
        ExpansionLandingPageMinimapButton:SetPoint(unpack(cfg.iconpos.garrison))
        ExpansionLandingPageMinimapButton:SetScale(0.6)
    end)
end)

--create rotating cogwheel texture
for index, _ in ipairs(frames_to_rotate) do
    local ftr = frames_to_rotate[index]

    local t = MinimapCluster:CreateTexture(nil, "ARTWORK", nil, -6)
    t:SetTexture(ftr.texture)
    t:SetPoint("CENTER", Minimap, 0, 0)
    t:SetSize(ftr.width, ftr.height)
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
gloss:SetSize(256 * .88, 256 * .88)
gloss:SetDesaturated(1)
gloss:SetVertexColor(0.3, 0.3, 0.3, 1)
gloss:SetBlendMode("BLEND")

--minimap border texture
local border = Minimap:CreateTexture(nil, "ARTWORK", nil, -2)
border:SetTexture(media.map_overlay)
border:SetPoint("CENTER", -4, -4)

--TRACKING ICON
MinimapCluster.Tracking:SetParent(Minimap)
MinimapCluster.Tracking:SetSize(28, 28)
MinimapCluster.Tracking:ClearAllPoints()
MinimapCluster.Tracking:SetPoint("LEFT", Minimap, "RIGHT", -12, 2)

MinimapCluster.Tracking.Background:Hide()
MinimapCluster.Tracking.Button:SetSize(28, 28)

--minimap mousewheel zoom
Minimap:EnableMouseWheel()
Minimap:SetScript("OnMouseWheel", function(_, direction)
    if (direction > 0) then
        Minimap.ZoomIn:Click()
    else
        Minimap.ZoomOut:Click()
    end
end)

-- -- Auto Zoom Out
if not cfg.autoZoom then return end

local isResetting
local function resetZoom()
    Minimap:SetZoom(0)

    Minimap.ZoomIn:Enable() -- Reset enabled state of buttons
    Minimap.ZoomOut:Disable()

    isResetting = false
end

local function setupZoomReset()
    if not isResetting then
        isResetting = true

        C_Timer.After(3, resetZoom)
    end
end

hooksecurefunc(Minimap, 'SetZoom', setupZoomReset)