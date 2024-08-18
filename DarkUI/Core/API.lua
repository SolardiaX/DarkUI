local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--  Core API Methods
----------------------------------------------------------------------------------------
E.UIScale = function()
    -- if C.general.autoScale then
    --     C.general.uiScale = min(2, max(0.20, 768 / E.screenHeight))
        
    --     if E.screenHeight >= 2400 then
    --         C.general.uiScale = C.general.uiScale * 3
    --     elseif E.screenHeight >= 1600 then
    --         C.general.uiScale = C.general.uiScale * 2
    --     end
    --     C.general.uiScale = tonumber(string.sub(C.general.uiScale, 0, 5)) -- 8.1 Fix scale bug
    -- end
    if C.general.autoScale then
        C.general.uiScale = min(2, max(0.20, 768 / E.screenHeight))
        C.general.uiScale = tonumber(string.sub(C.general.uiScale, 0, 5)) -- 8.1 Fix scale bug
        if C.general.uiScale < .64 then C.general.uiScale = .64 end
    end
end
E.UIScale()

E.mult = 768 / E.screenHeight / C.general.uiScale
E.noscalemult = E.mult * C.general.uiScale

if E.screenHeight > 1200 then
    E.mult = E.mult * math.floor(1 / E.mult + 0.5)
end

local Mult = E.mult

----------------------------------------------------------------------------------------
--  Dummy object
----------------------------------------------------------------------------------------
E.Dummy = function() return end

----------------------------------------------------------------------------------------
--    Frame Hider
----------------------------------------------------------------------------------------
E.FrameHider = CreateFrame("Frame")
E.FrameHider:Hide()

----------------------------------------------------------------------------------------
--    Pet Battle Hider
----------------------------------------------------------------------------------------
E.PetBattleFrameHider = CreateFrame("Frame", "DarkUI_PetBattleFrameHider", UIParent, "SecureHandlerStateTemplate")
E.PetBattleFrameHider:SetAllPoints()
E.PetBattleFrameHider:SetFrameStrata("LOW")
RegisterStateDriver(E.PetBattleFrameHider, "visibility", "[petbattle] hide; show")

----------------------------------------------------------------------------------------
--  Kill object function
----------------------------------------------------------------------------------------

local kill = function(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(E.FrameHider)
    else
        object.Show = object.Hide
    end
    object:Hide()
end

----------------------------------------------------------------------------------------
--  Core API function
----------------------------------------------------------------------------------------
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

local function stripTextures(object, kill)
    if object.GetNumRegions then
        for _, region in next, {object:GetRegions()} do
            if region and region.IsObjectType and region:IsObjectType("Texture") then
                if kill then
                    region:Kill()
                else
                    region:SetTexture("")
                    region:SetAtlas("")
                end
            end
        end
    end

    local frameName = object.GetName and object:GetName()
    for _, blizzard in pairs(stripTexturesBlizzFrames) do
        local blizzFrame = object[blizzard] or frameName and _G[frameName..blizzard]
        if blizzFrame then
            blizzFrame:StripTextures(kill)
        end
    end
end

local function watchPixelSnap(frame, snap)
    if (frame and not frame:IsForbidden()) and frame.pixelSnapDisabled and snap then
        frame.pixelSnapDisabled = nil
    end
end

local function disablePixelSnap(frame)
    if (frame and not frame:IsForbidden()) and not frame.pixelSnapDisabled then
        if frame.SetSnapToPixelGrid then
            frame:SetSnapToPixelGrid(false)
            frame:SetTexelSnappingBias(0)
        elseif frame.GetStatusBarTexture then
            local texture = frame:GetStatusBarTexture()
            if texture and texture.SetSnapToPixelGrid then
                texture:SetSnapToPixelGrid(false)
                texture:SetTexelSnappingBias(0)
            end
        end

        frame.pixelSnapDisabled = true
    end
end

local function setOutside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or Mult
    yOffset = yOffset or Mult
    anchor = anchor or obj:GetParent()

    disablePixelSnap(obj)

    if obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function setInside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or Mult
    yOffset = yOffset or Mult
    anchor = anchor or obj:GetParent()

    disablePixelSnap(obj)

    if obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function createBackground(f, offset)
    if f:GetObjectType() == "Texture" then
        f = f:GetParent()
    end
    offset = offset or Mult
    local lvl = f:GetFrameLevel()

    f.bg = CreateFrame("Frame", nil, f,  "BackdropTemplate")
    f.bg:SetPoint("TOPLEFT", f, -offset, offset)
    f.bg:SetPoint("BOTTOMRIGHT", f, offset, -offset)
    f.bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
end

local function createFontText(f, size, text, classcolor, anchor, x, y)
    local fs = f:CreateFontString(nil, "OVERLAY", nil, 1)
    fs:SetFont(C.media.standard_font[1], size, C.media.standard_font[3])
    fs:SetText(text)
    -- fs:SetWordWrap(false)
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

local function setTemplate(f, t, edge, insets)
    Mixin(f, BackdropTemplateMixin) -- 9.0 to set backdrop
    if not t then t = "Default" end

    local backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdrop_color)
    local borderr, borderg, borderb, bordera = unpack(C.media.border_color)
    local overlay_color = C.media.overlay_color

    if t == "Shadow" then
        if not edge then
            edge = 6
        end
        if not insets then
            insets = Mult
        end
        f:SetBackdrop(
            {
                bgFile = nil,
                edgeFile = C.media.texture.shadow,
                tile = false,
                tileSize = 32,
                edgeSize = edge,
                insets = {left = insets, right = insets, top = insets, bottom = insets}
            }
        )

        borderr, borderg, borderb, bordera = unpack(C.media.shadow_color)
    elseif t == "Border" then
        if not edge then
            edge = 12
        end
        if not insets then
            insets = Mult
        end
        f:SetBackdrop(
            {
                bgFile = C.media.texture.blank,
                edgeFile = C.media.texture.border,
                tile = false,
                tileSize = 32,
                edgeSize = edge,
                insets = {left = insets, right = insets, top = insets, bottom = insets}
            }
        )
        backdropa = 0
    elseif t == "Blur" then
        if not edge then
            edge = Mult
        end
        if not insets then
            insets = Mult
        end
        f:SetBackdrop(
            {
                bgFile = C.media.texture.blank,
                edgeFile = C.media.texture.shadow,
                tile = false,
                tileEdge = true,
                tileSize = 16,
                edgeSize = edge,
                insets = {left = insets, right = insets, top = insets, bottom = insets}
            }
        )
    else
        if not edge then
            edge = Mult
        end
        if not insets then
            insets = Mult
        end
        f:SetBackdrop(
            {
                bgFile = C.media.texture.blank,
                edgeFile = C.media.texture.blank,
                edgeSize = edge,
                insets = {left = insets, right = insets, top = insets, bottom = insets}
            }
        )
    end

    if t == "Transparent" then
        backdropa = overlay_color[4]
    elseif t == "Overlay" then
        backdropa = 1
        f:CreateOverlay()
    elseif t == "Invisible" then
        backdropa = 0
        bordera = 0
    end

    f:SetBackdropBorderColor(borderr, borderg, borderb, bordera)

    if t ~= "Shadow" then
        f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    end
end

local function createOverlay(f, margin)
    if f.overlay then return end

    margin = margin or Mult
    
    local overlay = f:CreateTexture("$parentOverlay", "BORDER")
    overlay:SetInside(f, margin, margin)
    overlay:SetTexture(C.media.texture.blank)
    overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
    
    f.overlay = overlay
end

local function createShadow(f, margin)
    margin = margin or 4

    local shadow = CreateFrame("Frame", nil, f)
    shadow:SetFrameLevel(f:GetFrameLevel() == 0 and 0 or f:GetFrameLevel() - 1)
    shadow:SetFrameStrata(f:GetFrameStrata())
    shadow:SetOutside(f, margin, margin)
    shadow:SetTemplate("Shadow")
    shadow:SetBackdropColor(0, 0, 0, 0)

    f.shadow = shadow
end

local function createBackdrop(f, template, margin)
    template = template or "Default"
    margin = margin or Mult

    local backdrop = CreateFrame("Frame", "$parentBackdrop", f)
    backdrop:SetInside(f, margin, margin)
    backdrop:SetTemplate(t)

    if f:GetFrameLevel() - 1 >= 0 then
        backdrop:SetFrameLevel(f:GetFrameLevel() - 1)
    else
        backdrop:SetFrameLevel(0)
    end

    f.backdrop = backdrop
end

local function createBorder(f, margin, shadow)
    if f.border then return end

    margin = margin or Mult

    f.border = CreateFrame("Frame", "$parentBorder", f, "BackdropTemplate")
    f.border:ClearAllPoints()
    f.border:SetPoint("TOPLEFT", f, "TOPLEFT", -margin, margin)
    f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", margin, -margin)
    f.border:SetFrameLevel(f:GetFrameLevel() + 1)
    f.border:SetTemplate("Border")

    if shadow then
        f.border:CreateShadow(shadow)
    end
end

local function createPanel(f, t, w, h, a1, p, a2, x, y)
    if not t then t = "Default" end

    f:SetWidth(w)
    f:SetHeight(h)
    f:SetFrameLevel(1)
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint(a1, p, a2, x, y)
    f:SetTemplate(t)
end

local function fadeIn(f)
    E:UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end

local function fadeOut(f)
    E:UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end

----------------------------------------------------------------------------------------
--  Apply api function
----------------------------------------------------------------------------------------
local function addapi(object)
    local mt = getmetatable(object).__index

    -- Core API
    if not object.SetOutside then
        mt.SetOutside = setOutside
    end
    if not object.SetInside then
        mt.SetInside = setInside
    end
    if not object.disabledPixelSnap then
        if mt.SetTexture then hooksecurefunc(mt, "SetTexture", disablePixelSnap) end
        if mt.SetTexCoord then hooksecurefunc(mt, "SetTexCoord", disablePixelSnap) end
        if mt.CreateTexture then hooksecurefunc(mt, "CreateTexture", disablePixelSnap) end
        if mt.SetVertexColor then hooksecurefunc(mt, "SetVertexColor", disablePixelSnap) end
        if mt.SetColorTexture then hooksecurefunc(mt, "SetColorTexture", disablePixelSnap) end
        if mt.SetSnapToPixelGrid then hooksecurefunc(mt, "SetSnapToPixelGrid", watchPixelSnap) end
        if mt.SetStatusBarTexture then hooksecurefunc(mt, "SetStatusBarTexture", disablePixelSnap) end
        mt.disabledPixelSnap = true
    end

    if not object.Kill then
        mt.Kill = kill
    end
    if not object.StripTextures then
        mt.StripTextures = stripTextures
    end
    if not object.CreateBackground then
        mt.CreateBackground = createBackground
    end
    if not object.SetTemplate then
        mt.SetTemplate = setTemplate
    end
    if not object.CreateOverlay then
        mt.CreateOverlay = createOverlay
    end
    if not object.CreateShadow then
        mt.CreateShadow = createShadow
    end
    if not object.CreateBackdrop then
        mt.CreateBackdrop = createBackdrop
    end
    if not object.CreateBorder then
        mt.CreateBorder = createBorder
    end
    if not object.CreateFontText then
        mt.CreateFontText = createFontText
    end
    if not object.CreatePanel then
        mt.CreatePanel = createPanel
    end
    if not object.FadeIn then
        mt.FadeIn = fadeIn
    end
    if not object.FadeOut then
        mt.FadeOut = fadeOut
    end
end

local handled = {["Frame"] = true}
local object = CreateFrame("Frame")

addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())

object = EnumerateFrames()
while object do
    if not object:IsForbidden() and not handled[object:GetObjectType()] then
        addapi(object)
        handled[object:GetObjectType()] = true
    end

    object = EnumerateFrames(object)
end

--[[ Only for test ]]--

-- local overlay = CreateFrame("Frame", nil, UIParent)
-- overlay:SetSize(64, 64)
-- overlay:SetPoint("CENTER", UIParent, -250, 200)
-- overlay:SetTemplate("Overlay")
-- overlay:CreateFontText(12, "Overlay", false, "TOP", 0, 15)

-- local default = CreateFrame("Frame", nil, UIParent)
-- default:SetSize(64, 64)
-- default:SetPoint("CENTER", UIParent, -150, 200)
-- default:SetTemplate("Default")
-- default:CreateFontText(12, "Default", false, "TOP", 0, 15)

-- local blur = CreateFrame("Frame", nil, UIParent)
-- blur:SetSize(64, 64)
-- blur:SetPoint("CENTER", UIParent, -50, 200)
-- blur:SetTemplate("Blur")
-- blur:CreateFontText(12, "Blur", false, "TOP", 0, 15)

-- local trans = CreateFrame("Frame", nil, UIParent)
-- trans:SetSize(64, 64)
-- trans:SetPoint("CENTER", UIParent, 50, 200)
-- trans:SetTemplate("Transparent")
-- trans:CreateFontText(12, "Transparent", false, "TOP", 0, 15)

-- local shadow = CreateFrame("Frame", nil, UIParent)
-- shadow:SetSize(64, 64)
-- shadow:SetPoint("CENTER", UIParent, 150, 200)
-- shadow:SetTemplate("Shadow")
-- shadow:CreateFontText(12, "Shadow", false, "TOP", 0, 15)

-- local border = CreateFrame("Frame", nil, UIParent)
-- border:SetSize(64, 64)
-- border:SetPoint("CENTER", UIParent, 250, 200)
-- border:SetTemplate("Border")
-- border:CreateFontText(12, "Border", false, "TOP", 0, 15)