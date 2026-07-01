local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Core API
------------------------------------------------------------------------

------------------------------------------------------------------------
-- UI Scale
------------------------------------------------------------------------

E.UIScale = function()
    if C.general.autoScale then
        C.general.uiScale = min(2, max(0.20, 768 / E.screenHeight))
        C.general.uiScale = tonumber(string.sub(C.general.uiScale, 0, 5))
        if C.general.uiScale < 0.64 then C.general.uiScale = 0.64 end
    end
end
E.UIScale()

local pixel = 1
local ratio = 768 / E.screenHeight
E.mult = (pixel / C.general.uiScale) - ((pixel - ratio) / C.general.uiScale)
E.noscalemult = E.mult * C.general.uiScale

local Mult = E.mult

------------------------------------------------------------------------
-- Backdrop / Edge / Effect Presets
------------------------------------------------------------------------

local BACKDROP = {
    default = {
        bgFile = C.media.texture.blank,
        edgeFile = C.media.texture.blank,
        bgColor = C.media.backdrop_color,
        borderColor = C.media.border_color,
    },
    transparent = {
        bgFile = C.media.texture.blank,
        edgeFile = C.media.texture.blank,
        bgColor = { C.media.backdrop_color[1], C.media.backdrop_color[2], C.media.backdrop_color[3], C.media.overlay_color[4] },
        borderColor = C.media.border_color,
    },
    fill = {
        bgFile = C.media.texture.blank,
        edgeFile = C.media.texture.blank,
        bgColor = { C.media.backdrop_color[1], C.media.backdrop_color[2], C.media.backdrop_color[3], 1 },
        borderColor = C.media.border_color,
    },
    invisible = {
        bgFile = C.media.texture.blank,
        edgeFile = C.media.texture.blank,
        bgColor = false,
        borderColor = false,
    },
    button = {
        bgFile = C.media.button.buttonback,
        edgeFile = C.media.texture.blank,
        bgColor = C.media.backdrop_color,
        borderColor = C.media.border_color,
    },
}

local EDGE = {
    pixel = { edgeFile = C.media.texture.blank, edgeSize = 1, insets = 1 },
    blur = { edgeFile = C.media.texture.shadow, edgeSize = 1, insets = 1 },
    thin = { edgeFile = C.media.texture.border_thin, edgeSize = 16, insets = 4 },
    thin_white = { edgeFile = C.media.texture.border_thin_white, edgeSize = 16, insets = 4 },
    line = { edgeFile = C.media.texture.border_line, edgeSize = 8, insets = 2 },
    line_white = { edgeFile = C.media.texture.border_line_white, edgeSize = 8, insets = 2 },
    regular = { edgeFile = C.media.texture.border_regular, edgeSize = 12, insets = 2 },
    round = { edgeFile = C.media.texture.border_round, edgeSize = 16, insets = 2 },
    round_white = { edgeFile = C.media.texture.border_round_white, edgeSize = 16, insets = 2 },
    bold = { edgeFile = C.media.texture.border_bold, edgeSize = 16, insets = 8, borderColor = { 1, 1, 1, 1 } },
    bolder = { edgeFile = C.media.texture.border_bolder, edgeSize = 32, insets = { left = 8, right = 8, top = 16, bottom = 16 }, borderColor = { 1, 1, 1, 1 } },
}

local EFFECT = {
    pixel = { edgeFile = C.media.texture.blank, edgeSize = 1, insets = 1 },
    shadow = { edgeFile = C.media.texture.shadow, edgeSize = 6, margin = 4, borderColor = C.media.shadow_color },
    thin = { edgeFile = C.media.texture.border_thin, edgeSize = 16, margin = 4 },
    thin_white = { edgeFile = C.media.texture.border_thin_white, edgeSize = 16, margin = 4 },
    line = { edgeFile = C.media.texture.border_line, edgeSize = 8, margin = 2 },
    line_white = { edgeFile = C.media.texture.border_line_white, edgeSize = 8, margin = 2 },
    regular = { edgeFile = C.media.texture.border_regular, edgeSize = 12, margin = 1, borderColor = C.media.border_color },
    round = { edgeFile = C.media.texture.border_round, edgeSize = 16, margin = 2 },
    round_white = { edgeFile = C.media.texture.border_round_white, edgeSize = 16, margin = 2 },
    bold = { edgeFile = C.media.texture.border_bold, edgeSize = 16, margin = 8 },
    bolder = { edgeFile = C.media.texture.border_bolder, edgeSize = 32, margin = { left = 8, right = 8, top = 16, bottom = 16 } },
}

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

E.Dummy = function() return end

-- Transparent texture used to "clear" Normal/Pushed/Highlight textures
E.ClearTexture = C.media.texture.empty

E.FrameHider = CreateFrame("Frame")
E.FrameHider:Hide()

E.PetBattleFrameHider = CreateFrame("Frame", "DarkUI_PetBattleFrameHider", UIParent, "SecureHandlerStateTemplate")
E.PetBattleFrameHider:SetAllPoints()
E.PetBattleFrameHider:SetFrameStrata("LOW")
RegisterStateDriver(E.PetBattleFrameHider, "visibility", "[petbattle] hide; show")

------------------------------------------------------------------------
-- Kill
------------------------------------------------------------------------

local function kill(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(E.FrameHider)
    else
        object.Show = object.Hide
    end
    object:Hide()
end

------------------------------------------------------------------------
-- StripTextures
------------------------------------------------------------------------

local stripTexturesBlizzFrames = {
    "Inset",
    "inset",
    "InsetFrame",
    "LeftInset",
    "RightInset",
    "NineSlice",
    "BG",
    "Bg",
    "border",
    "Border",
    "Background",
    "BorderFrame",
    "bottomInset",
    "BottomInset",
    "bgLeft",
    "bgRight",
    "FilligreeOverlay",
    "PortraitOverlay",
    "ArtOverlayFrame",
    "Portrait",
    "portrait",
    "ScrollFrameBorder",
    "ScrollUpBorder",
    "ScrollDownBorder",
}

local function stripTextures(object, killFlag)
    if object.GetNumRegions then
        for i = 1, object:GetNumRegions() do
            local region = select(i, object:GetRegions())
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                if killFlag and type(killFlag) == "boolean" then
                    kill(region)
                elseif tonumber(killFlag) then
                    if killFlag == 0 then
                        region:SetAlpha(0)
                    elseif i ~= killFlag then
                        region:SetTexture("")
                        region:SetAtlas("")
                    end
                else
                    region:SetTexture("")
                    region:SetAtlas("")
                end
            end
        end
    end

    local frameName = object.GetName and object:GetName()
    for _, blizzard in pairs(stripTexturesBlizzFrames) do
        local blizzFrame = object[blizzard] or (frameName and _G[frameName .. blizzard])
        if blizzFrame and blizzFrame.StripTextures then blizzFrame:StripTextures(killFlag) end
    end
end

------------------------------------------------------------------------
-- Pixel Snap
------------------------------------------------------------------------

local issecrettable = issecrettable

local function watchPixelSnap(frame, snap)
    if issecrettable and issecrettable(frame) then return end
    if (frame and not frame:IsForbidden()) and frame.__pixelSnapOff and snap then frame.__pixelSnapOff = nil end
end

local function disablePixelSnap(frame)
    if issecrettable and issecrettable(frame) then return end
    if (frame and not frame:IsForbidden()) and not frame.__pixelSnapOff then
        if frame.SetSnapToPixelGrid then
            frame:SetSnapToPixelGrid(false)
            frame:SetTexelSnappingBias(0)
        elseif frame.GetStatusBarTexture then
            local texture = frame:GetStatusBarTexture()
            if type(texture) == "table" and texture.SetSnapToPixelGrid then
                texture:SetSnapToPixelGrid(false)
                texture:SetTexelSnappingBias(0)
            end
        end

        frame.__pixelSnapOff = true
    end
end

------------------------------------------------------------------------
-- SetOutside / SetInside
------------------------------------------------------------------------

local function setOutside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or 1
    yOffset = yOffset or 1
    anchor = anchor or obj:GetParent()

    disablePixelSnap(obj)

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function setInside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or 1
    yOffset = yOffset or 1
    anchor = anchor or obj:GetParent()

    disablePixelSnap(obj)

    if obj:GetPoint() then obj:ClearAllPoints() end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

-- Hide a Blizzard frame's own backdrop art (NineSlice + any SetBackdrop)
local function hideBackdrop(frame)
    if frame.NineSlice then frame.NineSlice:SetAlpha(0) end
    if frame.SetBackdrop then frame:SetBackdrop(nil) end
end

------------------------------------------------------------------------
-- SetTemplate / SetBackdropEdge
------------------------------------------------------------------------

local origSetupTextureCoordinates = BackdropTemplateMixin.SetupTextureCoordinates

local function safeSetupTextureCoordinates(self)
    local width, height = self:GetSize()
    if issecretvalue(width) or issecretvalue(height) then return end
    origSetupTextureCoordinates(self)
end

BackdropTemplateMixin.SetupTextureCoordinates = safeSetupTextureCoordinates
E.SafeSetupTextureCoordinates = safeSetupTextureCoordinates

local function setTemplate(f, t, tile)
    Mixin(f, BackdropTemplateMixin)
    f.SetupTextureCoordinates = safeSetupTextureCoordinates

    local cfg = BACKDROP[t and t:lower() or "default"] or BACKDROP.default
    local edge = EDGE.pixel

    local bd = {
        bgFile = cfg.bgFile,
        edgeFile = edge.edgeFile,
        edgeSize = edge.edgeSize,
        tile = tile or false,
        insets = { left = edge.insets, right = edge.insets, top = edge.insets, bottom = edge.insets },
    }

    f:SetBackdrop(bd)
    f.__template = bd

    if cfg.bgColor then
        f.__bgColor = cfg.bgColor
        f:SetBackdropColor(unpack(cfg.bgColor))
    else
        f.__bgColor = nil
        f:SetBackdropColor(0, 0, 0, 0)
    end

    if cfg.borderColor then
        f.__borderColor = cfg.borderColor
        f:SetBackdropBorderColor(unpack(cfg.borderColor))
    else
        f.__borderColor = nil
        f:SetBackdropBorderColor(0, 0, 0, 0)
    end
end

local function setBackdropEdge(f, t, color, size)
    local cfg = EDGE[t]
    if not cfg or not f.__template then return end

    local bd = {
        bgFile = f.__template.bgFile,
        edgeFile = cfg.edgeFile,
        edgeSize = size or cfg.edgeSize,
        tile = f.__template.tile,
        insets = type(cfg.insets) == "table" and cfg.insets or { left = cfg.insets, right = cfg.insets, top = cfg.insets, bottom = cfg.insets },
    }
    f:SetBackdrop(bd)
    f.__template = bd

    -- SetBackdrop() resets colors, restore them
    if f.__bgColor then
        f:SetBackdropColor(unpack(f.__bgColor))
    else
        f:SetBackdropColor(unpack(C.media.backdrop_color))
    end

    -- explicit color overrides the cfg/__borderColor fallback chain
    if color then
        f:SetBackdropBorderColor(unpack(color))
    elseif cfg.borderColor then
        f:SetBackdropBorderColor(unpack(cfg.borderColor))
    elseif f.__borderColor then
        f:SetBackdropBorderColor(unpack(f.__borderColor))
    else
        f:SetBackdropBorderColor(unpack(C.media.backdrop_color))
    end
end

------------------------------------------------------------------------
-- CreateBackdrop / CreateShadow / CreateBorder
------------------------------------------------------------------------

local function createBackdrop(f, t, margin, tile, frameLevel)
    if f.backdrop then return f.backdrop end

    t = t or "Default"
    margin = margin or 1

    local frame = f
    if f:IsObjectType("Texture") then frame = f:GetParent() end

    local lvl = frame:GetFrameLevel()

    local child = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    child:SetOutside(f, margin, margin)
    child:SetFrameLevel(frameLevel or (lvl == 0 and 0 or lvl - 1))

    setTemplate(child, t, tile)

    f.backdrop = child
    return child
end

local function createShadow(f, margin, color, size)
    if f.shadow then return f.shadow end

    local cfg = EFFECT.shadow
    margin = margin or cfg.margin

    local frame = f
    if f:IsObjectType("Texture") then frame = f:GetParent() end

    local child = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    child:SetOutside(f, margin, margin)
    child:SetFrameLevel(0)
    child:SetBackdrop({ edgeFile = cfg.edgeFile, edgeSize = size or cfg.edgeSize })

    local borderColor = color or cfg.borderColor
    if borderColor then child:SetBackdropBorderColor(unpack(borderColor)) end

    f.shadow = child
    return child
end

local function createBorder(f, t, margin, color)
    if f.border then return f.border end

    local cfg = EFFECT[t] or EFFECT.regular
    margin = margin or cfg.margin

    local frame = f
    if f:IsObjectType("Texture") then frame = f:GetParent() end

    local lvl = frame:GetFrameLevel()

    local child = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    if type(margin) == "table" then
        child:SetPoint("TOPLEFT", f, "TOPLEFT", -(margin.left or 0), margin.top or 0)
        child:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", margin.right or 0, -(margin.bottom or 0))
    else
        child:SetOutside(f, margin, margin)
    end
    child:SetFrameLevel(lvl + 1)
    child:SetBackdrop({ edgeFile = cfg.edgeFile, edgeSize = cfg.edgeSize })

    local borderColor = color or cfg.borderColor
    if borderColor then child:SetBackdropBorderColor(unpack(borderColor)) end

    f.border = child
    return child
end

------------------------------------------------------------------------
-- CreateOverlay — overlay texture (tex_overlay)
------------------------------------------------------------------------

local function createOverlay(f, margin)
    if f.overlay then return f.overlay end

    margin = margin or 2

    local overlay = f:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture(C.media.texture.overlay)
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPRIGHT", f, margin, margin)
    overlay:SetPoint("BOTTOMLEFT", f, -margin, -margin)

    f.overlay = overlay
    return overlay
end

------------------------------------------------------------------------
-- CreateGradient
------------------------------------------------------------------------

local function createGradient(f, color)
    if f.gradient then return f.gradient end

    local gradient = f:CreateTexture(nil, "BORDER")
    gradient:SetInside(f)
    gradient:SetTexture(C.media.texture.gradient)
    gradient:SetVertexColor(unpack(color or C.media.gradient_color))

    f.gradient = gradient
    return gradient
end

------------------------------------------------------------------------
-- CreateFontText
------------------------------------------------------------------------

local function createFontText(f, size, text, classcolor, anchor, x, y)
    local fs = f:CreateFontString(nil, "OVERLAY", nil, 1)
    fs:SetFont(C.media.standard_font[1], size, C.media.standard_font[3])
    fs:SetText(text)
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(0.85, -0.85)

    if classcolor then
        fs:SetTextColor(E.myColor.r, E.myColor.g, E.myColor.b)
    else
        fs:SetTextColor(unpack(C.media.text_color))
    end

    if anchor and x and y then
        fs:SetPoint(anchor, x, y)
    else
        fs:SetPoint("CENTER", 1, 0)
    end

    return fs
end

local function fadeIn(f) E:UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1) end

local function fadeOut(f) E:UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0) end

local function setGhost(f)
    f:SetAlpha(0)
    f:SetScale(0.0001)
end

------------------------------------------------------------------------
-- FontString / Texture utilities
------------------------------------------------------------------------

-- Crop a texture to DarkUI's standard texCoord (or explicit coords)
local function setTexCoords(tex, x1, x2, y1, y2)
    if issecretvalue and issecretvalue(tex:GetTexture()) then return end
    if x1 then
        tex:SetTexCoord(x1, x2, y1, y2)
    else
        tex:SetTexCoord(unpack(C.media.texCoord))
    end
end

-- Strip all FontString regions from a frame
local function stripTexts(object, killFlag)
    if not object.GetNumRegions then return end
    for i = 1, object:GetNumRegions() do
        local region = select(i, object:GetRegions())
        if region and region.IsObjectType and region:IsObjectType("FontString") then
            if killFlag then
                region:Kill()
            else
                region:SetText("")
            end
        end
    end
end

-- Apply DarkUI standard font to a FontString
local function fontTemplate(fs, font, fontSize, fontStyle)
    fs:SetFont(font or C.media.standard_font[1], fontSize or C.media.standard_font[2], fontStyle or C.media.standard_font[3])
    fs:SetShadowColor(0, 0, 0)
    fs:SetShadowOffset(0.85, -0.85)
end

------------------------------------------------------------------------
-- Metatable Injection
------------------------------------------------------------------------

local function addapi(object)
    local mt = getmetatable(object).__index
    if mt.__darkui then return end

    mt.SetOutside = setOutside
    mt.SetInside = setInside
    mt.HideBackdrop = hideBackdrop
    mt.Kill = kill
    mt.StripTextures = stripTextures
    mt.SetTemplate = setTemplate
    mt.SetBackdropEdge = setBackdropEdge
    mt.CreateBackdrop = createBackdrop
    mt.CreateShadow = createShadow
    mt.CreateBorder = createBorder
    mt.CreateOverlay = createOverlay
    mt.CreateGradient = createGradient
    mt.CreateFontText = createFontText

    -- FontString / texture utilities
    mt.SetTexCoords = setTexCoords
    mt.StripTexts = stripTexts
    mt.FontTemplate = fontTemplate

    if not mt.FadeIn then mt.FadeIn = fadeIn end
    if not mt.FadeOut then mt.FadeOut = fadeOut end
    if not mt.SetGhost then mt.SetGhost = setGhost end

    if mt.SetTexture then hooksecurefunc(mt, "SetTexture", disablePixelSnap) end
    if mt.SetTexCoord then hooksecurefunc(mt, "SetTexCoord", disablePixelSnap) end
    if mt.CreateTexture then hooksecurefunc(mt, "CreateTexture", disablePixelSnap) end
    if mt.SetVertexColor then hooksecurefunc(mt, "SetVertexColor", disablePixelSnap) end
    if mt.SetColorTexture then hooksecurefunc(mt, "SetColorTexture", disablePixelSnap) end
    if mt.SetSnapToPixelGrid then hooksecurefunc(mt, "SetSnapToPixelGrid", watchPixelSnap) end
    if mt.SetStatusBarTexture then hooksecurefunc(mt, "SetStatusBarTexture", disablePixelSnap) end

    mt.__darkui = true
end

------------------------------------------------------------------------
-- Inject into all frame types via EnumerateFrames
------------------------------------------------------------------------

local handled = { ["Frame"] = true }
local baseFrame = CreateFrame("Frame")
addapi(baseFrame)
addapi(baseFrame:CreateTexture())
addapi(baseFrame:CreateFontString())
addapi(baseFrame:CreateMaskTexture())
addapi(CreateFont("DarkUIAPIFont")) -- Font objects (e.g. InvoiceTextFontNormal) need FontTemplate too

-- Widget types that may have NO instance at login (Model/PlayerModel/… are only
-- created when a panel like Collections loads). Their shared metatable would miss
-- the atoms until first use, so seed one throwaway of each to inject it now.
for _, frameType in ipairs({
    "PlayerModel",
    "Model",
    "ModelScene",
    "CinematicModel",
    "DressUpModel",
    "StatusBar",
    "Slider",
    "Button",
    "CheckButton",
    "EditBox",
    "ScrollFrame",
    "Cooldown",
    "SimpleHTML",
    "MessageFrame",
    "ScrollingMessageFrame",
}) do
    local ok, widget = pcall(CreateFrame, frameType)
    if ok and widget then
        if not handled[widget:GetObjectType()] then
            addapi(widget)
            handled[widget:GetObjectType()] = true
        end
        -- Neutralize the throwaway: a freshly created EditBox auto-focuses on
        -- show and swallows ALL keyboard input (kills every keybind). Drop focus
        -- and hide every seeded widget so it never interacts with the UI.
        if widget.SetAutoFocus then widget:SetAutoFocus(false) end
        if widget.ClearFocus then widget:ClearFocus() end
        widget:Hide()
    end
end

local object = EnumerateFrames()
while object do
    if not object:IsForbidden() and not handled[object:GetObjectType()] then
        addapi(object)
        handled[object:GetObjectType()] = true
    end
    object = EnumerateFrames(object)
end
