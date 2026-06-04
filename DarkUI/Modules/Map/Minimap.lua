local E, C, L = select(2, ...):unpack()

if not C.map.minimap.enable then
    return
end

----------------------------------------------------------------------------------------
-- MiniMap Styles
----------------------------------------------------------------------------------------
local module = E:Module("Map"):Sub("MiniMap")

local unpack, ipairs = unpack, ipairs
local C_Timer_After = C_Timer.After

local cfg = C.map.minimap

local media = {
    map_gloss = C.media.path .. "map_gloss",
    map_overlay = C.media.path .. C.general.style .. "\\" .. "map_overlay",
}

local FRAMES_TO_ROTATE = {
    {
        texture = C.media.path .. "map_rotating_1",
        width = 250,
        height = 250,
        color_red = C.general.style == "cold" and 126 / 255 or 255 / 255,
        color_green = C.general.style == "cold" and 206 / 255 or 255 / 255,
        color_blue = C.general.style == "cold" and 244 / 255 or 0 / 255,
        alpha = 0.2,
        duration = 60,
        direction = 1,
    },
    {
        texture = C.media.path .. "map_rotating_2",
        width = 250,
        height = 250,
        color_red = C.general.style == "cold" and 126 / 255 or 255 / 255,
        color_green = C.general.style == "cold" and 206 / 255 or 255 / 255,
        color_blue = C.general.style == "cold" and 244 / 255 or 0 / 255,
        alpha = 0.6,
        duration = 60,
        direction = 0,
    },
}

----------------------------------------------------------------------------------------
-- Disable Blizzard Elements
----------------------------------------------------------------------------------------

local function disableBlizzard()
    MinimapCluster:EnableMouse(false)
    MinimapCompassTexture:Hide()
    MinimapCluster.BorderTop:StripTextures()

    Minimap.ZoomIn:Kill()
    Minimap.ZoomOut:Kill()

    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingScalar(0)

    MinimapCluster.ZoneTextButton:Hide()

    Minimap:SetSize(Minimap:GetWidth() * 0.88, Minimap:GetHeight() * 0.88)
    Minimap.SetSize = E.Dummy
    Minimap:ClearAllPoints()
    Minimap:SetPoint(unpack(cfg.position))

    MinimapBackdrop:Kill()
end

----------------------------------------------------------------------------------------
-- Icon Repositioning
----------------------------------------------------------------------------------------

local function resetIcons()
    -- Difficulty
    local instDiff = MinimapCluster.InstanceDifficulty
    instDiff:SetParent(Minimap)
    instDiff:ClearAllPoints()
    instDiff:SetPoint(unpack(cfg.iconpos.instance))

    instDiff.Default.Border:Hide()
    instDiff.Default.Background:SetSize(28, 36)
    instDiff.Default.Background:SetVertexColor(0.6, 0.3, 0)
    instDiff.Default.HeroicTexture:ClearAllPoints()
    instDiff.Default.HeroicTexture:SetPoint("CENTER", -1, 7)
    instDiff.Default.HeroicTexture.SetPoint = E.Dummy
    instDiff.Default.MythicTexture:ClearAllPoints()
    instDiff.Default.MythicTexture:SetPoint("CENTER", -1, 7)
    instDiff.Default.MythicTexture.SetPoint = E.Dummy

    instDiff.Guild.Border:Hide()
    instDiff.Guild.Background:SetSize(28, 36)
    instDiff.Guild.Background:SetVertexColor(0.6, 0.3, 0)

    instDiff.ChallengeMode.Border:Hide()
    instDiff.ChallengeMode.Background:SetSize(28, 36)
    instDiff.ChallengeMode.Background:SetVertexColor(0.6, 0.3, 0)

    -- Queue Status
    QueueStatusFrame:SetClampedToScreen(true)
    QueueStatusFrame:SetFrameStrata("TOOLTIP")
    QueueStatusButton:SetParent(Minimap)
    QueueStatusButton:ClearAllPoints()
    QueueStatusButton:SetPoint(unpack(cfg.iconpos.queue))
    QueueStatusButton:SetScale(0.48)
    hooksecurefunc(QueueStatusButton, "SetPoint", function(self, _, anchor)
        if anchor ~= Minimap then
            self:ClearAllPoints()
            self:SetPoint(unpack(cfg.iconpos.queue))
        end
    end)

    -- GameTime
    GameTimeFrame:SetSize(26, 26)
    GameTimeFrame:ClearAllPoints()
    GameTimeFrame:SetPoint(unpack(cfg.iconpos.time))
    GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)

    -- Clock
    TimeManagerClockButton:ClearAllPoints()
    TimeManagerClockButton:SetPoint(unpack(cfg.iconpos.clock))
    TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
    TimeManagerClockTicker:SetTextColor(195 / 255, 186 / 255, 140 / 255)
    TimeManagerAlarmFiredTexture:ClearAllPoints()
    TimeManagerAlarmFiredTexture:SetPoint("TOPLEFT", TimeManagerClockTicker, "TOPLEFT", -18, 10)
    TimeManagerAlarmFiredTexture:SetPoint("BOTTOMRIGHT", TimeManagerClockTicker, "BOTTOMRIGHT", 15, -13)

    -- Mail
    local mailFrame = MinimapCluster.IndicatorFrame.MailFrame
    mailFrame:SetSize(cfg.iconSize, cfg.iconSize)
    mailFrame:ClearAllPoints()
    mailFrame:SetPoint(unpack(cfg.iconpos.mail))
    mailFrame.SetPoint = E.Dummy

    -- Expansion Landing Page Button
    local garrButton = ExpansionLandingPageMinimapButton
    if garrButton then
        local function updateGarrisonButton(self)
            self:SetParent(Minimap)
            self:ClearAllPoints()
            self:SetPoint(unpack(cfg.iconpos.garrison))
            self:SetScale(0.6)
        end

        updateGarrisonButton(garrButton)
        garrButton:HookScript("OnShow", updateGarrisonButton)
        hooksecurefunc(garrButton, "UpdateIcon", updateGarrisonButton)

        garrButton:HookScript("OnMouseDown", function(self, btn)
            if btn == "RightButton" then
                if GarrisonLandingPage and GarrisonLandingPage:IsShown() then
                    HideUIPanel(GarrisonLandingPage)
                end
                if ExpansionLandingPage and ExpansionLandingPage:IsShown() then
                    HideUIPanel(ExpansionLandingPage)
                end
                module:ShowGarrisonMenu(self)
            end
        end)

        garrButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText(self.title, 1, 1, 1)
            GameTooltip:AddLine(self.description, nil, nil, nil, true)
            GameTooltip:AddLine(L.MINIMAP_SWITCHGARRISONTYPE, nil, nil, nil, true)
            GameTooltip:Show()
        end)
    end

    -- Tracking
    MinimapCluster.Tracking:SetParent(Minimap)
    MinimapCluster.Tracking:SetSize(28, 28)
    MinimapCluster.Tracking:ClearAllPoints()
    MinimapCluster.Tracking:SetPoint("LEFT", Minimap, "RIGHT", -12, 2)
    MinimapCluster.Tracking.Background:Hide()
    MinimapCluster.Tracking.Button:SetSize(28, 28)

    -- AddonCompartment
    if AddonCompartmentFrame then
        AddonCompartmentFrame:ClearAllPoints()
        AddonCompartmentFrame:SetPoint("BOTTOMRIGHT", Minimap, -26, 2)
    end
end

----------------------------------------------------------------------------------------
-- Garrison Menu (12.0: MenuUtil replaces EasyMenu)
----------------------------------------------------------------------------------------

function module:ShowGarrisonMenu(anchor)
    MenuUtil.CreateContextMenu(anchor, function(_, rootDescription)
        rootDescription:CreateButton(GARRISON_TYPE_9_0_LANDING_PAGE_TITLE, function()
            if not C_Garrison.HasGarrison(Enum.GarrisonType.Type_9_0_Garrison) then
                UIErrorsFrame:AddMessage(CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
                return
            end
            ShowGarrisonLandingPage(Enum.GarrisonType.Type_9_0_Garrison)
        end)
        rootDescription:CreateButton(WAR_CAMPAIGN, function()
            if not C_Garrison.HasGarrison(Enum.GarrisonType.Type_8_0_Garrison) then
                UIErrorsFrame:AddMessage(CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
                return
            end
            ShowGarrisonLandingPage(Enum.GarrisonType.Type_8_0_Garrison)
        end)
        rootDescription:CreateButton(ORDER_HALL_LANDING_PAGE_TITLE, function()
            if not C_Garrison.HasGarrison(Enum.GarrisonType.Type_7_0_Garrison) then
                UIErrorsFrame:AddMessage(CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
                return
            end
            ShowGarrisonLandingPage(Enum.GarrisonType.Type_7_0_Garrison)
        end)
        rootDescription:CreateButton(GARRISON_LANDING_PAGE_TITLE, function()
            if not C_Garrison.HasGarrison(Enum.GarrisonType.Type_6_0_Garrison) then
                UIErrorsFrame:AddMessage(CONTRIBUTION_TOOLTIP_UNLOCKED_WHEN_ACTIVE)
                return
            end
            ShowGarrisonLandingPage(Enum.GarrisonType.Type_6_0_Garrison)
        end)
    end)
end

----------------------------------------------------------------------------------------
-- Decorative Textures
----------------------------------------------------------------------------------------

local function addTextures()
    for _, ftr in ipairs(FRAMES_TO_ROTATE) do
        local t = MinimapCluster:CreateTexture(nil, "ARTWORK", nil, -6)
        t:SetTexture(ftr.texture)
        t:SetPoint("CENTER", Minimap, 0, 0)
        t:SetSize(ftr.width, ftr.height)
        t:SetVertexColor(ftr.color_red, ftr.color_green, ftr.color_blue, ftr.alpha)
        t:SetBlendMode("BLEND")
        t:SetScale(0.88)

        t.ag = t:CreateAnimationGroup()
        t.ag.a1 = t.ag:CreateAnimation("Rotation")
        t.ag.a1:SetDegrees(ftr.direction == 1 and 360 or -360)
        t.ag.a1:SetDuration(ftr.duration)
        t.ag:SetLooping("REPEAT")
        t.ag:Play()
    end

    local gloss = Minimap:CreateTexture(nil, "ARTWORK", nil, -3)
    gloss:SetTexture(media.map_gloss)
    gloss:SetPoint("CENTER", 0, 0)
    gloss:SetSize(256, 256)
    gloss:SetScale(0.88)
    gloss:SetAlpha(0.62)

    local border = Minimap:CreateTexture(nil, "ARTWORK", nil, -2)
    border:SetTexture(media.map_overlay)
    border:SetPoint("CENTER", -4, -4)
    border:SetScale(0.88)
end

----------------------------------------------------------------------------------------
-- Auto Zoom Out
----------------------------------------------------------------------------------------

local function enableAutoZoomOut()
    if not cfg.autoZoom then
        return
    end

    local isResetting
    local function resetZoom()
        Minimap:SetZoom(0)
        Minimap.ZoomIn:Enable()
        Minimap.ZoomOut:Disable()
        isResetting = false
    end

    hooksecurefunc(Minimap, "SetZoom", function()
        if not isResetting then
            isResetting = true
            C_Timer_After(10, resetZoom)
        end
    end)
end

----------------------------------------------------------------------------------------
-- Module Init
----------------------------------------------------------------------------------------

function module:OnInit()
    if not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then
        C_AddOns.LoadAddOn("Blizzard_TimeManager")
    end

    disableBlizzard()
    resetIcons()
    addTextures()
    enableAutoZoomOut()

    Minimap:EnableMouseWheel()
    Minimap:SetScript("OnMouseWheel", function(_, direction)
        if direction > 0 then
            Minimap.ZoomIn:Click()
        else
            Minimap.ZoomOut:Click()
        end
    end)
end
