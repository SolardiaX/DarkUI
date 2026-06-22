local E, C, L = select(2, ...):unpack()

if not C.map.minimap.enable then
    return
end

------------------------------------------------------------------------
-- MiniMap Styles
------------------------------------------------------------------------
local module = E:Module("Map"):Sub("MiniMap")

local unpack, ipairs = unpack, ipairs
local C_Timer_After = C_Timer.After

local cfg = C.map.minimap

local ICON_SIZE = 20
local ICON_POS = {
    mail = { "TOPRIGHT", "Minimap", "BOTTOMRIGHT", -30, -8 },
    garrison = { "CENTER", "Minimap", "CENTER", 90, 130 },
    queue = { "TOPLEFT", "Minimap", "TOPRIGHT", -56, 12 },
    instance = { "TOPRIGHT", "Minimap", "TOPRIGHT", 20, 20 },
    time = { "BOTTOM", "Minimap", "BOTTOM", 1, 1 },
    clock = { "TOP", "Minimap", "BOTTOM", -2, -10 },
}

local media
local FRAMES_TO_ROTATE

------------------------------------------------------------------------
-- Disable Blizzard Elements
------------------------------------------------------------------------

local function hideObject(obj)
    if not obj then
        return
    end
    obj:SetAlpha(0)
    obj:Hide()
    if obj.UnregisterAllEvents then
        obj:UnregisterAllEvents()
    end
    if obj.Show then
        obj.Show = E.Dummy
    end
end

local function disableBlizzard()
    MinimapCluster:EnableMouse(false)

    hideObject(MinimapCompassTexture)

    if MinimapCluster.BorderTop then
        MinimapCluster.BorderTop:Hide()
    end

    if Minimap.ZoomIn then
        Minimap.ZoomIn:SetAlpha(0)
        Minimap.ZoomIn:Hide()
    end
    if Minimap.ZoomOut then
        Minimap.ZoomOut:SetAlpha(0)
        Minimap.ZoomOut:Hide()
    end

    Minimap:SetArchBlobRingScalar(0)
    Minimap:SetQuestBlobRingScalar(0)

    if MinimapCluster.ZoneTextButton then
        MinimapCluster.ZoneTextButton:Hide()
    end

    Minimap:SetSize(Minimap:GetWidth() * 0.88, Minimap:GetHeight() * 0.88)
    Minimap:ClearAllPoints()
    Minimap:SetPoint(unpack(cfg.position))

    -- Reparent Housing overlay before hiding MinimapBackdrop
    if MinimapBackdrop then
        if MinimapBackdrop.StaticOverlayTexture then
            MinimapBackdrop.StaticOverlayTexture:SetParent(Minimap)
            MinimapBackdrop.StaticOverlayTexture:SetInside(Minimap)
            MinimapBackdrop.StaticOverlayTexture:SetTexCoord(0.2, 0.8, 0.2, 0.8)
        end
        MinimapBackdrop:Hide()
    end
end

------------------------------------------------------------------------
-- Icon Repositioning
------------------------------------------------------------------------

local function resetIcons()
    -- Difficulty
    local instDiff = MinimapCluster.InstanceDifficulty
    if instDiff then
        instDiff:SetParent(Minimap)
        instDiff:ClearAllPoints()
        instDiff:SetPoint(unpack(ICON_POS.instance))

        local isSettingDiffPoint
        hooksecurefunc(instDiff, "SetPoint", function(self)
            if isSettingDiffPoint then
                return
            end
            isSettingDiffPoint = true
            self:ClearAllPoints()
            self:SetPoint(unpack(ICON_POS.instance))
            isSettingDiffPoint = false
        end)

        if instDiff.Default then
            if instDiff.Default.Border then
                instDiff.Default.Border:Hide()
            end
            instDiff.Default.Background:SetSize(28, 36)
            instDiff.Default.Background:SetVertexColor(0.6, 0.3, 0)
            if instDiff.Default.HeroicTexture then
                instDiff.Default.HeroicTexture:ClearAllPoints()
                instDiff.Default.HeroicTexture:SetPoint("CENTER", -1, 7)
                instDiff.Default.HeroicTexture.SetPoint = E.Dummy
            end
            if instDiff.Default.MythicTexture then
                instDiff.Default.MythicTexture:ClearAllPoints()
                instDiff.Default.MythicTexture:SetPoint("CENTER", -1, 7)
                instDiff.Default.MythicTexture.SetPoint = E.Dummy
            end
        end

        if instDiff.Guild then
            if instDiff.Guild.Border then
                instDiff.Guild.Border:Hide()
            end
            instDiff.Guild.Background:SetSize(28, 36)
            instDiff.Guild.Background:SetVertexColor(0.6, 0.3, 0)
        end

        if instDiff.ChallengeMode then
            if instDiff.ChallengeMode.Border then
                instDiff.ChallengeMode.Border:Hide()
            end
            instDiff.ChallengeMode.Background:SetSize(28, 36)
            instDiff.ChallengeMode.Background:SetVertexColor(0.6, 0.3, 0)
        end
    end

    -- Queue Status (use flag to prevent recursion)
    if QueueStatusButton then
        QueueStatusButton:SetParent(Minimap)
        QueueStatusButton:ClearAllPoints()
        QueueStatusButton:SetPoint(unpack(ICON_POS.queue))
        QueueStatusButton:SetScale(0.52)
        QueueStatusButtonIcon:SetScale(0.52)
        QueueStatusFrame:ClearAllPoints()
        QueueStatusFrame:SetPoint("TOPRIGHT", QueueStatusButton, "TOPLEFT")

        local isSettingQueuePoint
        hooksecurefunc(QueueStatusButton, "SetPoint", function(self)
            if isSettingQueuePoint then
                return
            end
            isSettingQueuePoint = true
            self:ClearAllPoints()
            self:SetPoint(unpack(ICON_POS.queue))
            isSettingQueuePoint = false
        end)
    end

    -- GameTime & Clock (handled by DataText Time module)
    if GameTimeFrame then
        GameTimeFrame:SetSize(26, 26)
        GameTimeFrame:ClearAllPoints()
        GameTimeFrame:SetPoint(unpack(ICON_POS.time))
        GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
    end

    if TimeManagerClockButton then
        TimeManagerClockButton:ClearAllPoints()
        TimeManagerClockButton:SetPoint(unpack(ICON_POS.clock))
        if TimeManagerClockTicker then
            TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
            TimeManagerClockTicker:SetTextColor(195/255, 186/255, 140/255)
        end
        if TimeManagerAlarmFiredTexture and TimeManagerClockTicker then
            TimeManagerAlarmFiredTexture:ClearAllPoints()
            TimeManagerAlarmFiredTexture:SetPoint("TOPLEFT", TimeManagerClockTicker, "TOPLEFT", -18, 10)
            TimeManagerAlarmFiredTexture:SetPoint("BOTTOMRIGHT", TimeManagerClockTicker, "BOTTOMRIGHT", 15, -13)
        end
    end

    -- Mail
    local indicatorFrame = MinimapCluster.IndicatorFrame
    if indicatorFrame and indicatorFrame.MailFrame then
        local mailFrame = indicatorFrame.MailFrame
        mailFrame:SetSize(ICON_SIZE, ICON_SIZE)
        mailFrame:ClearAllPoints()
        mailFrame:SetPoint(unpack(ICON_POS.mail))

        local isSettingMailPoint
        hooksecurefunc(mailFrame, "SetPoint", function(self)
            if isSettingMailPoint then
                return
            end
            isSettingMailPoint = true
            self:ClearAllPoints()
            self:SetPoint(unpack(ICON_POS.mail))
            isSettingMailPoint = false
        end)
    end

    -- Expansion Landing Page Button
    local garrButton = ExpansionLandingPageMinimapButton
    if garrButton then
        local function updateGarrisonButton(self)
            self:SetParent(Minimap)
            self:ClearAllPoints()
            self:SetPoint(unpack(ICON_POS.garrison))
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
                showGarrisonMenu(self)
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
    local tracking = MinimapCluster.Tracking
    if tracking then
        tracking:SetParent(Minimap)
        tracking:SetSize(28, 28)
        tracking:ClearAllPoints()
        tracking:SetPoint("LEFT", Minimap, "RIGHT", -12, 2)
        if tracking.Background then
            tracking.Background:Hide()
        end
        if tracking.Button then
            tracking.Button:SetSize(28, 28)
        end
    end

    -- AddonCompartment
    if AddonCompartmentFrame then
        AddonCompartmentFrame:ClearAllPoints()
        AddonCompartmentFrame:SetPoint("BOTTOMLEFT", Minimap, -22, 2)
        AddonCompartmentFrame:SetAlpha(0)
        AddonCompartmentFrame:Kill()
    end
end

------------------------------------------------------------------------
-- Garrison Menu (12.0: MenuUtil replaces EasyMenu)
------------------------------------------------------------------------

local function showGarrisonMenu(anchor)
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

------------------------------------------------------------------------
-- Decorative Textures
------------------------------------------------------------------------

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

------------------------------------------------------------------------
-- Auto Zoom Out
------------------------------------------------------------------------

local function enableAutoZoomOut()
    if not cfg.autoZoom then
        return
    end

    local isResetting
    local function resetZoom()
        Minimap:SetZoom(0)
        isResetting = false
    end

    hooksecurefunc(Minimap, "SetZoom", function()
        if not isResetting then
            isResetting = true
            C_Timer_After(10, resetZoom)
        end
    end)
end

------------------------------------------------------------------------
-- RecycleBin — Collect addon minimap buttons
------------------------------------------------------------------------

local blackList = {
    ["GameTimeFrame"] = true,
    ["MinimapBackdrop"] = true,
    ["TimeManagerClockButton"] = true,
    ["QueueStatusButton"] = true,
    ["QueueStatusMinimapButton"] = true,
    ["GarrisonLandingPageMinimapButton"] = true,
    ["ExpansionLandingPageMinimapButton"] = true,
    ["MinimapZoneTextButton"] = true,
    ["RecycleBinFrame"] = true,
    ["RecycleBinToggleButton"] = true,
}

local ignoredButtons = {
    ["GatherMatePin"] = true,
    ["HandyNotes.-Pin"] = true,
    ["TTMinimapButton"] = true,
}

local function isButtonIgnored(name)
    for pattern in pairs(ignoredButtons) do
        if name:match(pattern) then
            return true
        end
    end
end

local removedTextures = {
    [136430] = true,
    [136467] = true,
}

local function setupRecycleBin()
    local buttons = {}
    local numMinimapChildren = 0
    local ICONS_PER_ROW = 10
    local BUTTON_SIZE = 32
    local SPACING = 3

    -- Toggle button
    local toggleBtn = CreateFrame("Button", "RecycleBinToggleButton", Minimap)
    toggleBtn:SetSize(36, 36)
    toggleBtn:SetPoint("BOTTOMLEFT", -4, -6)
    toggleBtn:SetFrameLevel(999)
    toggleBtn:RegisterForClicks("LeftButtonUp")

    local toggleIcon = toggleBtn:CreateTexture(nil, "ARTWORK", nil, 1)
    toggleIcon:SetAllPoints()
    toggleIcon:SetTexture("Interface\\HelpFrame\\ReportLagIcon-Loot")

    local hl = toggleBtn:CreateTexture(nil, "HIGHLIGHT")
    hl:SetAllPoints()
    hl:SetTexture("Interface\\HelpFrame\\ReportLagIcon-Loot")
    hl:SetAlpha(0.3)

    -- Bin container
    local binWidth, binHeight, binAlpha = 220, 40, 0.85
    local bin = CreateFrame("Frame", "RecycleBinFrame", UIParent)
    bin:SetPoint("BOTTOMRIGHT", toggleBtn, "BOTTOMLEFT", -3, 0)
    bin:SetSize(binWidth, binHeight)
    bin:SetFrameStrata("BACKGROUND")
    bin:SetFrameLevel(9)
    -- bin:CreateShadow()
    bin:Hide()

    -- Gradient background
    local bgTex = bin:CreateTexture(nil, "BACKGROUND")
    bgTex:SetAllPoints()
    bgTex:SetTexture(C.media.texture.blank)
    bgTex:SetGradient("HORIZONTAL", CreateColor(0, 0, 0, 0), CreateColor(0, 0, 0, binAlpha))

    -- Border lines (class-colored gradient)
    local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b

    local topLine = bin:CreateTexture(nil, "BORDER")
    topLine:SetHeight(E.mult)
    topLine:SetPoint("BOTTOMLEFT", bin, "TOPLEFT")
    topLine:SetPoint("BOTTOMRIGHT", bin, "TOPRIGHT")
    topLine:SetTexture(C.media.texture.blank)
    topLine:SetGradient("HORIZONTAL", CreateColor(cr, cg, cb, 0), CreateColor(cr, cg, cb, binAlpha))

    local bottomLine = bin:CreateTexture(nil, "BORDER")
    bottomLine:SetHeight(E.mult)
    bottomLine:SetPoint("TOPLEFT", bin, "BOTTOMLEFT")
    bottomLine:SetPoint("TOPRIGHT", bin, "BOTTOMRIGHT")
    bottomLine:SetTexture(C.media.texture.blank)
    bottomLine:SetGradient("HORIZONTAL", CreateColor(cr, cg, cb, 0), CreateColor(cr, cg, cb, binAlpha))

    local rightLine = bin:CreateTexture(nil, "BORDER")
    rightLine:SetWidth(E.mult)
    rightLine:SetPoint("TOPLEFT", bin, "TOPRIGHT", 0, E.mult)
    rightLine:SetPoint("BOTTOMLEFT", bin, "BOTTOMRIGHT", 0, -E.mult)
    rightLine:SetTexture(C.media.texture.blank)
    rightLine:SetGradient("VERTICAL", CreateColor(cr, cg, cb, binAlpha), CreateColor(cr, cg, cb, binAlpha))

    -- Fade animations
    local fadeIn = bin:CreateAnimationGroup()
    fadeIn.alpha = fadeIn:CreateAnimation("Alpha")
    fadeIn.alpha:SetFromAlpha(0)
    fadeIn.alpha:SetToAlpha(1)
    fadeIn.alpha:SetDuration(0.3)
    fadeIn:SetScript("OnPlay", function()
        bin:Show()
    end)

    local fadeOut = bin:CreateAnimationGroup()
    fadeOut.alpha = fadeOut:CreateAnimation("Alpha")
    fadeOut.alpha:SetFromAlpha(1)
    fadeOut.alpha:SetToAlpha(0)
    fadeOut.alpha:SetDuration(0.3)
    fadeOut:SetScript("OnFinished", function()
        bin:Hide()
    end)

    local function hideBin()
        if bin:IsShown() then
            fadeOut:Play()
        end
    end

    -- Reskin a collected button
    local function reskinButton(child)
        local name = child:GetName() or ""

        for i = 1, child:GetNumRegions() do
            local region = select(i, child:GetRegions())
            if region:IsObjectType("Texture") then
                local texture = region:GetTexture() or ""
                if
                    removedTextures[texture]
                    or (type(texture) == "string" and (texture:find("Interface\\CharacterFrame") or texture:find("Interface\\Minimap")))
                then
                    region:SetTexture(nil)
                    region:Hide()
                elseif not region.__ignored then
                    region:ClearAllPoints()
                    region:SetAllPoints()
                end
            end
        end

        child:SetSize(BUTTON_SIZE, BUTTON_SIZE)
        child:SetTemplate("Transparent")

        buttons[#buttons + 1] = child
    end

    -- Move collected buttons into bin
    local function setupButtons()
        local binLevel = bin:GetFrameLevel()

        for _, child in ipairs(buttons) do
            if not child.__binStyled then
                child:SetParent(bin)
                child:SetFrameLevel(binLevel + 5)
                if child:HasScript("OnDragStop") then
                    child:SetScript("OnDragStop", nil)
                end
                if child:HasScript("OnDragStart") then
                    child:SetScript("OnDragStart", nil)
                end
                if child:HasScript("OnClick") then
                    child:HookScript("OnClick", hideBin)
                end

                if child:IsObjectType("Button") then
                    child:SetHighlightTexture(C.media.texture.blank)
                    child:GetHighlightTexture():SetColorTexture(1, 1, 1, 0.25)
                end

                child.__binStyled = true
            end
        end
    end

    -- Arrange buttons in grid
    local function sortButtons()
        if #buttons == 0 then
            return
        end

        local shownButtons = {}
        for _, btn in ipairs(buttons) do
            if btn:IsShown() then
                shownButtons[#shownButtons + 1] = btn
            end
        end

        local numShown = #shownButtons
        if numShown == 0 then
            return
        end

        local rows = math.ceil(numShown / ICONS_PER_ROW)
        local newHeight = rows * (BUTTON_SIZE + SPACING) + SPACING
        bin:SetHeight(newHeight)

        for i, btn in ipairs(shownButtons) do
            btn:ClearAllPoints()
            local col = (i - 1) % ICONS_PER_ROW
            local row = math.floor((i - 1) / ICONS_PER_ROW)
            btn:SetPoint("BOTTOMRIGHT", bin, "BOTTOMRIGHT", -(col * (BUTTON_SIZE + SPACING) + SPACING), row * (BUTTON_SIZE + SPACING) + SPACING)
        end
    end

    -- Scan for new addon buttons
    local scanCount = 0
    local function collectButtons()
        local numChildren = Minimap:GetNumChildren()
        if numChildren ~= numMinimapChildren then
            for i = 1, numChildren do
                local child = select(i, Minimap:GetChildren())
                local name = child and child.GetName and child:GetName()
                if name and not child.__binExamed and not blackList[name] then
                    if (child:IsObjectType("Button") or name:upper():find("BUTTON")) and not isButtonIgnored(name) then
                        reskinButton(child)
                    end
                    child.__binExamed = true
                end
            end
            numMinimapChildren = numChildren
        end

        setupButtons()

        scanCount = scanCount + 1
        if scanCount < 12 then
            C_Timer_After(5, collectButtons)
        end
    end

    -- Toggle button click
    toggleBtn:SetScript("OnClick", function()
        if bin:IsShown() then
            hideBin()
        else
            sortButtons()
            fadeIn:Play()
        end
    end)

    toggleBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:SetText("RecycleBin", 1, 1, 1)
        GameTooltip:AddLine("Click to toggle addon buttons", nil, nil, nil, true)
        GameTooltip:Show()
    end)
    toggleBtn:SetScript("OnLeave", GameTooltip_Hide)

    -- Start scanning (immediate + event-driven for fast collection)
    collectButtons()

    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    eventFrame:SetScript("OnEvent", function(self)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        C_Timer_After(0.5, collectButtons)
    end)
end

------------------------------------------------------------------------
-- HybridMinimap (dungeon square minimap)
------------------------------------------------------------------------

local function setupHybridMinimap()
    if HybridMinimap and HybridMinimap.CircleMask then
        HybridMinimap.CircleMask:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    end
end

------------------------------------------------------------------------
-- Module Init
------------------------------------------------------------------------

function module:OnInit()
    C_CVar.SetCVar("minimapTrackingShowAll", 1)

    media = {
        map_gloss = C.media.path .. "map_gloss",
        map_overlay = C.media.path .. C.general.style .. "\\" .. "map_overlay",
    }

    FRAMES_TO_ROTATE = {
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

    if not C_AddOns.IsAddOnLoaded("Blizzard_TimeManager") then
        C_AddOns.LoadAddOn("Blizzard_TimeManager")
    end

    disableBlizzard()
    resetIcons()
    addTextures()
    enableAutoZoomOut()

    if cfg.recycleBin then
        setupRecycleBin()
    end

    -- Mouse wheel zoom
    Minimap:EnableMouseWheel(true)
    Minimap:SetScript("OnMouseWheel", function(_, direction)
        if direction > 0 then
            Minimap.ZoomIn:Click()
        else
            Minimap.ZoomOut:Click()
        end
    end)

    -- HybridMinimap
    if HybridMinimap then
        setupHybridMinimap()
    else
        EventUtil.ContinueOnAddOnLoaded("Blizzard_HybridMinimap", setupHybridMinimap)
    end
end
