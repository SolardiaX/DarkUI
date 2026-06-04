local E, C, L = select(2, ...):unpack()

if not C.aura.auraWatch.enable then
    return
end

------------------------------------------------------------------------
-- AuraWatch — Blizzard Cooldown Manager Restyling
------------------------------------------------------------------------
local module = E:Module("Aura"):Sub("AuraWatch")

local cfg = C.aura.auraWatch
local unpack, ipairs, pairs = unpack, ipairs, pairs
local C_Timer_After = C_Timer.After

local VIEWERS = {
    "EssentialCooldownViewer",
    "UtilityCooldownViewer",
    "BuffIconCooldownViewer",
    "BuffBarCooldownViewer",
}

------------------------------------------------------------------------
-- Viewer Positioning
------------------------------------------------------------------------

local movers = {}
local moveMode = false

local function positionViewer(viewerName)
    local viewer = _G[viewerName]
    if not viewer then
        return
    end
    local vcfg = cfg.viewers[viewerName]
    if not vcfg or not vcfg.pos then
        return
    end
    viewer:ClearAllPoints()
    viewer:SetPoint(unpack(vcfg.pos))
end

local function positionAllViewers()
    for _, name in ipairs(VIEWERS) do
        positionViewer(name)
    end
end

------------------------------------------------------------------------
-- Icon Style (for Essential/Utility/BuffIcon viewers)
------------------------------------------------------------------------

local function styleIconFrame(frame)
    local regions = { frame:GetRegions() }
    local iconTex, maskTex, overlayTex = regions[1], regions[2], regions[3]

    if maskTex and maskTex:IsObjectType("MaskTexture") then
        if iconTex and iconTex.RemoveMaskTexture then
            pcall(iconTex.RemoveMaskTexture, iconTex, maskTex)
        end
        maskTex:Hide()
    end

    if overlayTex and overlayTex:IsObjectType("Texture") then
        overlayTex:Hide()
        overlayTex:SetAlpha(0)
    end

    if iconTex and iconTex.SetTexCoord then
        iconTex:SetTexCoord(unpack(C.media.texCoord))
        iconTex:ClearAllPoints()
        iconTex:SetPoint("TOPLEFT", frame, 2, -2)
        iconTex:SetPoint("BOTTOMRIGHT", frame, -2, 2)
    end

    if not frame.__styled then
        frame.__styled = true
        frame:CreateBorder(2)
    end

    if frame.Cooldown then
        frame.Cooldown:SetSwipeColor(0, 0, 0, cfg.style.swipeAlpha)
        frame.Cooldown:SetDrawEdge(false)

        if frame.Cooldown.GetCountdownFontString then
            local fs = frame.Cooldown:GetCountdownFontString()
            if fs then
                fs:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
            end
        end
    end
end

------------------------------------------------------------------------
-- Bar Style (for BuffBarCooldownViewer)
------------------------------------------------------------------------

local function styleBarFrame(frame)
    local vcfg = cfg.viewers.BuffBarCooldownViewer or {}
    local iconSize = vcfg.iconSize or 24
    local barWidth = vcfg.barWidth or 150
    local barHeight = vcfg.barHeight or 12

    frame:SetSize(iconSize + 5 + barWidth, iconSize)

    local iconFrame = frame.Icon
    if iconFrame then
        iconFrame:ClearAllPoints()
        iconFrame:SetSize(iconSize, iconSize)
        iconFrame:SetPoint("LEFT", frame, "LEFT", 0, 0)

        local regions = { iconFrame:GetRegions() }
        local iconTex, maskTex, overlayTex = regions[1], regions[2], regions[3]

        if maskTex and maskTex:IsObjectType("MaskTexture") then
            if iconTex and iconTex.RemoveMaskTexture then
                pcall(iconTex.RemoveMaskTexture, iconTex, maskTex)
            end
            maskTex:Hide()
        end

        if overlayTex and overlayTex:IsObjectType("Texture") then
            overlayTex:Hide()
            overlayTex:SetAlpha(0)
        end

        if iconTex and iconTex.SetTexCoord then
            iconTex:SetTexCoord(unpack(C.media.texCoord))
            iconTex:ClearAllPoints()
            iconTex:SetPoint("TOPLEFT", iconFrame, 2, -2)
            iconTex:SetPoint("BOTTOMRIGHT", iconFrame, -2, 2)
        end

        if not iconFrame.__styled then
            iconFrame.__styled = true
            iconFrame:CreateBorder(2)
        end
    end

    local bar = frame.Bar
    if bar then
        bar:StripTextures()

        bar:ClearAllPoints()
        bar:SetSize(barWidth, barHeight)
        bar:SetPoint("BOTTOMLEFT", iconFrame or frame, "BOTTOMRIGHT", 5, 0)

        bar:SetStatusBarTexture(C.media.texture.status)
        bar:SetStatusBarColor(E.myColor.r, E.myColor.g, E.myColor.b)

        bar.Spark = bar:CreateTexture(nil, "OVERLAY")
        bar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        bar.Spark:SetBlendMode("ADD")
        bar.Spark:SetAlpha(.8)
        bar.Spark:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT", -10, 10)
        bar.Spark:SetPoint("BOTTOMRIGHT", bar:GetStatusBarTexture(), "BOTTOMRIGHT", 10, -10)

        if not bar.__styled then
            bar.__styled = true
            bar:SetTemplate("Default")
            bar:CreateShadow()
        end

        if bar.Name then
            bar.Name:ClearAllPoints()
            bar.Name:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 2)
            bar.Name:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        end

        if bar.Duration and iconFrame then
            bar.Duration:SetParent(iconFrame)
            bar.Duration:ClearAllPoints()
            bar.Duration:SetPoint("CENTER", iconFrame, "CENTER", 0, 0)
            bar.Duration:SetFont(STANDARD_TEXT_FONT, 11, "OUTLINE")
        end
    end

    frame.__styled = true
end

------------------------------------------------------------------------
-- Layout: Centered Icons (continuous enforcement)
------------------------------------------------------------------------

local LAYOUT_THROTTLE = 0.03
local lastLayoutTime = 0

local function collectIconFrames(viewer)
    local frames = {}
    for _, child in ipairs({ viewer:GetChildren() }) do
        if child and child:IsShown() and child.Icon and child.layoutIndex then
            frames[#frames + 1] = child
        end
    end
    table.sort(frames, function(a, b)
        return (a.layoutIndex or 0) < (b.layoutIndex or 0)
    end)
    return frames
end

local function collectBarFrames(viewer)
    local frames = {}
    for _, child in ipairs({ viewer:GetChildren() }) do
        if child and child:IsShown() and child:IsVisible() and (child.Bar or child.Icon) then
            frames[#frames + 1] = child
        end
    end
    table.sort(frames, function(a, b)
        return (a.layoutIndex or 0) < (b.layoutIndex or 0)
    end)
    return frames
end

local function layoutIconViewer(viewer)
    local frames = collectIconFrames(viewer)
    local count = #frames
    if count == 0 then
        return
    end

    local isHorizontal = (viewer.isHorizontal ~= false)
    local spacing = cfg.spacing or 4
    local iconLimit = viewer.iconLimit or count

    local refFrame = frames[1]
    local iconW = refFrame:GetWidth()
    local iconH = refFrame:GetHeight()
    if iconW == 0 or iconH == 0 then
        return
    end

    local iconsPerRow = iconLimit
    local rowCount = math.ceil(count / iconsPerRow)
    local rowSpacing = spacing

    for rowIdx = 1, rowCount do
        local rowStart = (rowIdx - 1) * iconsPerRow + 1
        local rowEnd = math.min(rowStart + iconsPerRow - 1, count)
        local rowIcons = rowEnd - rowStart + 1

        for i = rowStart, rowEnd do
            local frame = frames[i]
            styleIconFrame(frame)

            local colIdx = i - rowStart
            local x = (colIdx - (rowIcons - 1) / 2) * (iconW + spacing)
            local y = -(rowIdx - 1) * (iconH + rowSpacing)

            frame:ClearAllPoints()
            if isHorizontal then
                frame:SetPoint("CENTER", viewer, "CENTER", x, y)
            else
                frame:SetPoint("CENTER", viewer, "CENTER", y, -x)
            end
        end
    end
end

local function layoutBarViewer(viewer)
    local frames = collectBarFrames(viewer)
    local count = #frames
    if count == 0 then
        return
    end

    local vcfg = cfg.viewers.BuffBarCooldownViewer or {}
    local iconSize = vcfg.iconSize or 18
    local spacing = cfg.barSpacing or 3

    for i, frame in ipairs(frames) do
        styleBarFrame(frame)

        frame:ClearAllPoints()
        frame:SetPoint("TOPRIGHT", viewer, "TOPRIGHT", 0, -(i - 1) * (iconSize + spacing))
    end
end

------------------------------------------------------------------------
-- Continuous Layout Enforcement
------------------------------------------------------------------------

local layoutFrame = CreateFrame("Frame")

local function doLayout()
    local now = GetTime()
    if now - lastLayoutTime < LAYOUT_THROTTLE then
        return
    end
    lastLayoutTime = now

    for _, viewerName in ipairs(VIEWERS) do
        local viewer = _G[viewerName]
        if viewer and viewer:IsShown() then
            if viewerName == "BuffBarCooldownViewer" then
                layoutBarViewer(viewer)
            else
                layoutIconViewer(viewer)
            end
        end
    end
end

layoutFrame:SetScript("OnUpdate", doLayout)

------------------------------------------------------------------------
-- Hook Viewers
------------------------------------------------------------------------

local function refreshCooldownFonts(viewerName)
    local viewer = _G[viewerName]
    if not viewer then
        return
    end
    for _, child in ipairs({ viewer:GetChildren() }) do
        if child.Cooldown and child.Cooldown.GetCountdownFontString then
            local fs = child.Cooldown:GetCountdownFontString()
            if fs then
                fs:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
            end
        end
    end
end

local function forceRefresh()
    positionAllViewers()
    lastLayoutTime = 0
    doLayout()
end

local function hookViewer(viewerName)
    local viewer = _G[viewerName]
    if not viewer then
        return
    end

    if viewer.RefreshLayout then
        hooksecurefunc(viewer, "RefreshLayout", function()
            positionViewer(viewerName)
            lastLayoutTime = 0
            doLayout()
            refreshCooldownFonts(viewerName)
        end)
    end
end

------------------------------------------------------------------------
-- Move Mode
------------------------------------------------------------------------

local function toggleMoveMode()
    moveMode = not moveMode
    for _, name in ipairs(VIEWERS) do
        local viewer = _G[name]
        if viewer then
            if not movers[name] then
                local vkey = "aura.auraWatch.viewers." .. name .. ".pos"
                movers[name] = E.Anchor:Create(viewer, name, vkey)
            end
            movers[name]:SetShown(moveMode)
        end
    end
    if moveMode then
        print("|cff00ff00DarkUI AuraWatch:|r Move mode ON. Drag viewers to reposition.")
    else
        print("|cff00ff00DarkUI AuraWatch:|r Move mode OFF.")
    end
end

------------------------------------------------------------------------
-- Init
------------------------------------------------------------------------

local function setup()
    positionAllViewers()

    for _, name in ipairs(VIEWERS) do
        hookViewer(name)
    end

    hooksecurefunc(getmetatable(CreateFrame("Cooldown", nil, nil, "CooldownFrameTemplate")).__index, "SetCooldown", function(cd)
        local parent = cd:GetParent()
        if not parent then
            return
        end
        local viewer = parent:GetParent()
        local viewerName = viewer and viewer.GetName and viewer:GetName()
        if not viewerName or not cfg.viewers[viewerName] then
            return
        end
        if cd.GetCountdownFontString then
            local fs = cd:GetCountdownFontString()
            if fs then
                fs:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
            end
        end
    end)

    if EditModeManagerFrame then
        hooksecurefunc(EditModeManagerFrame, "ExitEditMode", function()
            if InCombatLockdown() then
                return
            end
            if E:IsLEMOReady() then
                E.LEMO:LoadLayouts()
            end
            forceRefresh()
            C_Timer_After(0, forceRefresh)
        end)
    end

    if CooldownViewerSettings and CooldownViewerSettings.RefreshLayout then
        hooksecurefunc(CooldownViewerSettings, "RefreshLayout", function()
            if InCombatLockdown() then
                return
            end
            C_Timer_After(0, forceRefresh)
        end)
    end

    C_Timer_After(0.2, doLayout)
    C_Timer_After(1, function()
        if not InCombatLockdown() then
            E:ApplyEditModeChanges()
        end
    end)
end

function module:OnInit()
    if C_CVar.GetCVar("cooldownViewerEnabled") ~= "1" then
        layoutFrame:Hide()
        return
    end

    if _G.EssentialCooldownViewer then
        setup()
    else
        layoutFrame:Hide()
        EventUtil.ContinueOnAddOnLoaded("Blizzard_CooldownViewer", function()
            setup()
            layoutFrame:Show()
        end)
    end

    SlashCmdList.DARKUI_AURAWATCH = function(msg)
        msg = msg and msg:lower() or ""
        if msg == "move" or msg == "lock" then
            toggleMoveMode()
        end
    end
    SLASH_DARKUI_AURAWATCH1 = "/aurawatch"
end
