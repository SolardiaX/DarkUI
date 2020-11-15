local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--  Core API Methods
----------------------------------------------------------------------------------------

E.UIScale = function()
    if C.general.autoScale then
        C.general.uiScale = min(2, max(0.20, 768 / E.screenHeight))
        C.general.uiScale = tonumber(string.sub(C.general.uiScale, 0, 5)) -- 8.1 Fix scale bug
    end
end
E.UIScale()

E.mult = 768 / E.screenHeight / C.general.uiScale
E.noscalemult = E.mult * C.general.uiScale

----------------------------------------------------------------------------------------
--  Dummy object
----------------------------------------------------------------------------------------

E.dummy = function()
    return
end

----------------------------------------------------------------------------------------
--	Position functions
----------------------------------------------------------------------------------------
local function setOutside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or 2
    yOffset = yOffset or 2
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function setInside(obj, anchor, xOffset, yOffset)
    xOffset = xOffset or 2
    yOffset = yOffset or 2
    anchor = anchor or obj:GetParent()

    if obj:GetPoint() then
        obj:ClearAllPoints()
    end

    obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
    obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

----------------------------------------------------------------------------------------
--	Pet Battle Hider
----------------------------------------------------------------------------------------
T_PetBattleFrameHider = CreateFrame("Frame", "DarkUI_PetBattleFrameHider", UIParent, "SecureHandlerStateTemplate")
T_PetBattleFrameHider:SetAllPoints()
T_PetBattleFrameHider:SetFrameStrata("LOW")
RegisterStateDriver(T_PetBattleFrameHider, "visibility", "[petbattle] hide; show")

----------------------------------------------------------------------------------------
--  Kill object function
----------------------------------------------------------------------------------------
local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()
local kill = function(object)
    if object.UnregisterAllEvents then
        object:UnregisterAllEvents()
        object:SetParent(hiddenFrame)
    else
        object.Show = E.dummy
    end
    object:Hide()
end

----------------------------------------------------------------------------------------
--  Core API function
----------------------------------------------------------------------------------------
local function fadeIn(f)
    E:UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end

local function fadeOut(f)
    E:UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end

local stripTexturesBlizzFrames = {
    "Inset",
    "inset",
    "InsetFrame",
    "LeftInset",
    "RightInset",
    "NineSlice",
    "BG",
    "border",
    "Border",
    "BorderFrame",
    "bottomInset",
    "BottomInset",
    "bgLeft",
    "bgRight",
    "FilligreeOverlay"
}

local function stripTextures(object, kill)
    if object.GetNumRegions then
        for i = 1, object:GetNumRegions() do
            local region = select(i, object:GetRegions())
            if region and region:GetObjectType() == "Texture" then
                if kill then
                    region:Kill()
                else
                    region:SetTexture(nil)
                end
            end
        end
    end

    local frameName = object.GetName and object:GetName()
    for _, blizzard in pairs(stripTexturesBlizzFrames) do
        local blizzFrame = object[blizzard] or frameName and _G[frameName .. blizzard]
        if blizzFrame then
            blizzFrame:StripTextures(kill)
        end
    end
end

-- Create Background
local function createBackground(f, offset)
    if f:GetObjectType() == "Texture" then
        f = f:GetParent()
    end
    offset = offset or E.mult
    local lvl = f:GetFrameLevel()

    f.bg = CreateFrame("Frame", nil, f,  "BackdropTemplate")
    f.bg:SetPoint("TOPLEFT", f, -offset, offset)
    f.bg:SetPoint("BOTTOMRIGHT", f, offset, -offset)
    f.bg:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
end

local function createTextureBorder(f, margin)
    margin = margin or 2
    local border
    local fn = f:GetName()

    if f.border then
        return
    end

    if fn ~= nil then
        border = _G[fn .. "Border"] or f:CreateTexture(fn .. "Border", "BACKGROUND", nil, -7)
    else
        border = f:CreateTexture(nil, "BACKGROUND", nil, -7)
    end

    border:SetTexture(C.media.texture.border)
    border:SetTexCoord(0, 1, 0, 1)
    border:SetDrawLayer("BACKGROUND", -7)
    border:ClearAllPoints()
    border:SetPoint("TOPRIGHT", f, margin, margin)
    border:SetPoint("BOTTOMLEFT", f, -margin, -margin)

    f.border = border
end

local function createFontText(f, size, text, classcolor, anchor, x, y)
    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetFont(C.media.standard_font[1], size, C.media.standard_font[3])
    fs:SetText(text)
    fs:SetWordWrap(false)

    if classcolor then
        fs:SetTextColor(E.color.r, E.color.g, E.color.b)
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
    if not t then
        t = "Default"
    end

    local backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdrop_color)
    local borderr, borderg, borderb, bordera = unpack(C.media.border_color)
    local overlay_color = C.media.overlay_color

    if t == "Shadow" then
        if not edge then
            edge = 6
        end
        if not insets then
            insets = 6
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
            edge = 6
        end
        if not insets then
            insets = 6
        end
        f:SetBackdrop(
            {
                bgFile = nil,
                edgeFile = C.media.texture.outer_border,
                tile = false,
                tileSize = 32,
                edgeSize = edge,
                insets = {left = insets, right = insets, top = insets, bottom = insets}
            }
        )
    elseif t == "Blur" then
        if not edge then
            edge = 2
        end
        if not insets then
            insets = 2
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
            edge = E.mult
        end
        if not insets then
            insets = E.mult
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
        f:CreateBorder()
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
    if f.overlay then
        return
    end
    margin = margin or 2

    local overlay = f:CreateTexture("$parentOverlay", "BORDER", f)
    overlay:SetPoint("TOPLEFT", margin, -margin)
    overlay:SetPoint("BOTTOMRIGHT", -margin, margin)
    overlay:SetTexture(C.media.texture.blank)
    overlay:SetVertexColor(0.1, 0.1, 0.1, 1)

    f.overlay = overlay
end

local function createShadow(f, margin)
    margin = margin or 4

    local shadow = CreateFrame("Frame", nil, f)
    shadow:SetFrameLevel(f:GetFrameLevel() == 0 and 0 or f:GetFrameLevel() - 1)
    shadow:SetFrameStrata(f:GetFrameStrata())
    shadow:SetPoint("TOPLEFT", -margin, margin)
    shadow:SetPoint("BOTTOMRIGHT", margin, -margin)
    shadow:SetTemplate("Shadow")
    shadow:SetBackdropColor(0, 0, 0, 0)

    f.shadow = shadow
end

local function createBackdrop(f, template, margin)
    template = template or "Default"
    margin = margin or 2

    local backdrop = CreateFrame("Frame", "$parentBackdrop", f)
    backdrop:SetPoint("TOPLEFT", -margin, margin)
    backdrop:SetPoint("BOTTOMRIGHT", margin, -margin)
    backdrop:SetFrameLevel(f:GetFrameLevel() == 0 and 0 or f:GetFrameLevel() - 1)
    backdrop:SetTemplate(template)

    f.backdrop = backdrop
end

local function createBorder(f, margin, shadow)
    if f.border then
        return
    end

    margin = margin or 1

    f.border = CreateFrame("Frame", "$parentInnerBorder", f, "BackdropTemplate")
    f.border:ClearAllPoints()
    f.border:SetPoint("TOPLEFT", f, "TOPLEFT", -margin, margin)
    f.border:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", margin, -margin)
    f.border:SetFrameLevel(f:GetFrameLevel() + 1)
    f.border:SetTemplate("Border")

    if shadow then
        f.border:CreateShadow(shadow)
    end
end

local function createShadowBorder(f)
    f:SetBackdrop(
        {
            bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
            edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
            edgeSize = 1,
            insets = {left = 0, right = 0, top = 0, bottom = 0}
        }
    )
    f:SetBackdropColor(0, 0, 0, 0.6)
    f:SetBackdropBorderColor(0, 0, 0, 0.6)

    local shadow = CreateFrame("Frame", "$parentInnerBorder", f, "BackdropTemplate")
    shadow:SetFrameLevel(1)
    shadow:SetFrameStrata(f:GetFrameStrata())
    shadow:SetPoint("TOPLEFT", -4, 4)
    shadow:SetPoint("BOTTOMRIGHT", 4, -4)
    shadow:SetBackdrop(
        {
            edgeFile = C.media.texture.shadow,
            edgeSize = 4,
            insets = {left = 3, right = 3, top = 3, bottom = 3}
        }
    )
    shadow:SetBackdropColor(0, 0, 0, 0)
    shadow:SetBackdropBorderColor(0, 0, 0, 1)

    f.shadow = shadow
end

local function createPanel(f, t, w, h, a1, p, a2, x, y)
    if not t then
        t = "Default"
    end

    f:SetWidth(w)
    f:SetHeight(h)
    f:SetFrameLevel(1)
    f:SetFrameStrata("BACKGROUND")
    f:SetPoint(a1, p, a2, x, y)
    f:SetTemplate(t)
end

local PixelBorders = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT", "TOP", "BOTTOM", "LEFT", "RIGHT"}
local function createPixelBorders(frame, noSecureHook)
    if frame and not frame.pixelBorders then
        local borders = {}

        for _, v in pairs(PixelBorders) do
            borders[v] = frame:CreateTexture("$parentPixelBorder" .. v, "BORDER", nil, 1)
            borders[v]:SetTexture(C.media.texture.blank)
        end

        borders.CENTER = frame:CreateTexture("$parentPixelBorderCENTER", "BACKGROUND", nil, -1)

        borders.TOPLEFT:Point("BOTTOMRIGHT", borders.CENTER, "TOPLEFT", 1, -1)
        borders.TOPRIGHT:Point("BOTTOMLEFT", borders.CENTER, "TOPRIGHT", -1, -1)
        borders.BOTTOMLEFT:Point("TOPRIGHT", borders.CENTER, "BOTTOMLEFT", 1, 1)
        borders.BOTTOMRIGHT:Point("TOPLEFT", borders.CENTER, "BOTTOMRIGHT", -1, 1)

        borders.TOP:Point("TOPLEFT", borders.TOPLEFT, "TOPRIGHT", 0, 0)
        borders.TOP:Point("TOPRIGHT", borders.TOPRIGHT, "TOPLEFT", 0, 0)

        borders.BOTTOM:Point("BOTTOMLEFT", borders.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
        borders.BOTTOM:Point("BOTTOMRIGHT", borders.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

        borders.LEFT:Point("TOPLEFT", borders.TOPLEFT, "BOTTOMLEFT", 0, 0)
        borders.LEFT:Point("BOTTOMLEFT", borders.BOTTOMLEFT, "TOPLEFT", 0, 0)

        borders.RIGHT:Point("TOPRIGHT", borders.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
        borders.RIGHT:Point("BOTTOMRIGHT", borders.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

        if not noSecureHook then
            hooksecurefunc(
                frame,
                "SetBackdropColor",
                function(f, r, g, b, a)
                    for _, v in pairs(PixelBorders) do
                        f.pixelBorders[v]:SetVertexColor(r or 0, g or 0, b or 0, a)
                    end
                end
            )
            hooksecurefunc(
                frame,
                "SetBackdropBorderColor",
                function(f, r, g, b, a)
                    f.pixelBorders.CENTER:SetVertexColor(r, g, b, a)
                end
            )
        end

        frame.pixelBorders = borders
    end
end

----------------------------------------------------------------------------------------
--  Core Style Methods
----------------------------------------------------------------------------------------
local setModifiedBackdrop = function(self)
    if self:IsEnabled() then
        self:SetBackdropBorderColor(E.color.r, E.color.g, E.color.b)
        if self.overlay then
            self.overlay:SetVertexColor(E.color.r * 0.3, E.color.g * 0.3, E.color.b * 0.3, 1)
        end
    end
end

local setOriginalBackdrop = function(self)
    self:SetBackdropBorderColor(unpack(C.media.border_color))
    if self.overlay then
        self.overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
    end
end

local function skinCheckBox(frame)
    local lvl = frame:GetFrameLevel()

    frame:SetNormalTexture("")
    frame:SetPushedTexture("")
    frame:SetHighlightTexture(C.media.texture.status)

    frame.hl = frame:GetHighlightTexture()
    frame.hl:SetPoint("TOPLEFT", 5, -5)
    frame.hl:SetPoint("BOTTOMRIGHT", -5, 5)
    frame.hl:SetVertexColor(E.color.r, E.color.g, E.color.b, .2)

    frame.bg = CreateFrame("Frame", nil, frame)
    frame.bg:SetPoint("TOPLEFT", 4, -4)
    frame.bg:SetPoint("BOTTOMRIGHT", -4, 4)
    frame.bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
    frame.bg:SetTemplate("Default")

    frame.ch = frame:GetCheckedTexture()
    frame.ch:SetDesaturated(true)
    frame.ch:SetVertexColor(E.color.r, E.color.g, E.color.b)

    if C.blizzard.style then
        frame.bg:SetBackdropBorderColor(255 / 255, 234 / 255, 100 / 255)
        frame.hl:SetVertexColor(255 / 255, 234 / 255, 100 / 255)
        frame.ch:SetVertexColor(255 / 255, 234 / 255, 100 / 255)
    end
end

local function skinCloseButton(f, point)
    if point then
        f:SetPoint("TOPRIGHT", point, "TOPRIGHT", -2, -2)
    end

    f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
    f:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    f:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    f:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
end

local function skinCharButton(f, point, text)
    f:StripTextures()
    f:SetTemplate("Overlay")
    f:CreateTextureBorder(1)
    f:SetSize(18, 18)

    if not text then
        text = "x"
    end
    if not f.text then
        f.text = f:CreateFontText(16, text)
        f.text:SetPoint("CENTER", 0, 1)
    end

    if point then
        f:SetPoint("TOPRIGHT", point, "TOPRIGHT", -4, -4)
    else
        f:SetPoint("TOPRIGHT", -4, -4)
    end

    f:HookScript("OnEnter", setModifiedBackdrop)
    f:HookScript("OnLeave", setOriginalBackdrop)
end

local function skinButton(f, strip)
    if strip then
        f:StripTextures()
    end

    if f.SetNormalTexture then
        f:SetNormalTexture("")
    end
    if f.SetHighlightTexture then
        f:SetHighlightTexture("")
    end
    if f.SetPushedTexture then
        f:SetPushedTexture("")
    end
    if f.SetDisabledTexture then
        f:SetDisabledTexture("")
    end

    if f.Left then
        f.Left:SetAlpha(0)
    end
    if f.Right then
        f.Right:SetAlpha(0)
    end
    if f.Middle then
        f.Middle:SetAlpha(0)
    end
    if f.LeftSeparator then
        f.LeftSeparator:SetAlpha(0)
    end
    if f.RightSeparator then
        f.RightSeparator:SetAlpha(0)
    end
    if f.Flash then
        f.Flash:SetAlpha(0)
    end

    if f.TopLeft then
        f.TopLeft:Hide()
    end
    if f.TopRight then
        f.TopRight:Hide()
    end
    if f.BottomLeft then
        f.BottomLeft:Hide()
    end
    if f.BottomRight then
        f.BottomRight:Hide()
    end
    if f.TopMiddle then
        f.TopMiddle:Hide()
    end
    if f.MiddleLeft then
        f.MiddleLeft:Hide()
    end
    if f.MiddleRight then
        f.MiddleRight:Hide()
    end
    if f.BottomMiddle then
        f.BottomMiddle:Hide()
    end
    if f.MiddleMiddle then
        f.MiddleMiddle:Hide()
    end

    f:SetTemplate("Overlay")
    f:HookScript("OnEnter", setModifiedBackdrop)
    f:HookScript("OnLeave", setOriginalBackdrop)
end

----------------------------------------------------------------------------------------
--  Apply api function
----------------------------------------------------------------------------------------
local function addapi(object)
    local mt = getmetatable(object).__index

    -- Core API
    if not object.SetOutside then
        mt.SetOutside = SetOutside
    end
    if not object.SetInside then
        mt.SetInside = SetInside
    end

    if not object.Kill then
        mt.Kill = kill
    end
    if not object.FadeIn then
        mt.FadeIn = fadeIn
    end
    if not object.FadeOut then
        mt.FadeOut = fadeOut
    end
    if not object.StripTextures then
        mt.StripTextures = stripTextures
    end
    if not object.CreateBackground then
        mt.CreateBackground = createBackground
    end
    if not object.CreateTextureBorder then
        mt.CreateTextureBorder = createTextureBorder
    end
    if not object.SetTemplate then
        mt.SetTemplate = setTemplate
    end
    if not object.CreateShadowBorder then
        mt.CreateShadowBorder = createShadowBorder
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
    if not object.CreatePixelBorders then
        mt.CreatePixelBorders = createPixelBorders
    end
    if not object.CreateFontText then
        mt.CreateFontText = createFontText
    end
    if not object.CreatePanel then
        mt.CreatePanel = createPanel
    end

    -- Style API

    if not object.SkinCheckBox then
        mt.SkinCheckBox = skinCheckBox
    end
    if not object.SkinCloseButton then
        mt.SkinCloseButton = skinCloseButton
    end
    if not object.SkinCharButton then
        mt.SkinCharButton = skinCharButton
    end
    if not object.SkinButton then
        mt.SkinButton = skinButton
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
