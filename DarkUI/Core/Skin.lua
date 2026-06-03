local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
--    Skin Engine
--    Provides unified methods to reskin Blizzard frames into dark style,
--    and a Theme registry to hook on-demand loaded addons.
--
--    All colors come from C.media — single source of truth.
--    All visual methods use Core/API.lua's injected frame methods.
----------------------------------------------------------------------------------------

local _G = _G
local pairs, type, select = pairs, type, select
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local unpack = unpack

local r, g, b = E.myColor.r, E.myColor.g, E.myColor.b

----------------------------------------------------------------------------------------
--    Theme Registry
----------------------------------------------------------------------------------------

local themes = {} -- ["Blizzard_AchievementUI"] = func
local skinQueue = {} -- skins waiting for ADDON_LOADED
local loaded = {} -- already loaded skins

function E:RegisterSkin(addonName, func)
    if loaded[addonName] then
        return
    end
    if C_AddOns.IsAddOnLoaded(addonName) then
        local ok, err = pcall(func)
        if not ok then
            geterrorhandler()(("DarkUI Skin [%s]: %s"):format(addonName, err))
        end
        loaded[addonName] = true
    else
        themes[addonName] = func
    end
end

-- Called on ADDON_LOADED to execute pending skins
local function onAddonLoaded(_, event, addonName)
    local func = themes[addonName]
    if func then
        local ok, err = pcall(func)
        if not ok then
            geterrorhandler()(("DarkUI Skin [%s]: %s"):format(addonName, err))
        end
        themes[addonName] = nil
        loaded[addonName] = true
    end
end

E.Event:Register("ADDON_LOADED", onAddonLoaded, E)

----------------------------------------------------------------------------------------
--    Skin Utilities (internal)
----------------------------------------------------------------------------------------

local function setModifiedBackdrop(self)
    if self:IsEnabled() then
        self:SetBackdropBorderColor(r, g, b)
    end
end

local function setOriginalBackdrop(self)
    self:SetBackdropBorderColor(unpack(C.media.border_color))
end

----------------------------------------------------------------------------------------
--    E:Skin(frame) — Generic frame skin
--    Strips textures, applies dark backdrop + shadow
----------------------------------------------------------------------------------------

function E:Skin(frame)
    if not frame or frame.__skinned then
        return
    end
    if frame:IsForbidden() then
        return
    end

    frame:StripTextures()
    frame:SetTemplate("Default")
    frame:CreateShadow()

    frame.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinButton(button) — Button skin
--    Strips textures, dark overlay backdrop, hover highlight with class color
----------------------------------------------------------------------------------------

function E:SkinButton(button)
    if not button or button.__skinned then
        return
    end
    if button:IsForbidden() then
        return
    end

    button:StripTextures()

    if button.SetNormalTexture then
        button:SetNormalTexture("")
    end
    if button.SetHighlightTexture then
        button:SetHighlightTexture("")
    end
    if button.SetPushedTexture then
        button:SetPushedTexture("")
    end
    if button.SetDisabledTexture then
        button:SetDisabledTexture("")
    end

    -- Clear atlas-based regions
    if button.Left then
        button.Left:SetAlpha(0)
    end
    if button.Right then
        button.Right:SetAlpha(0)
    end
    if button.Middle then
        button.Middle:SetAlpha(0)
    end

    button:SetTemplate("Overlay")
    button:HookScript("OnEnter", setModifiedBackdrop)
    button:HookScript("OnLeave", setOriginalBackdrop)

    button.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinCloseButton(button) — Close button (X)
----------------------------------------------------------------------------------------

function E:SkinCloseButton(button, anchor)
    if not button or button.__skinned then
        return
    end

    button:StripTextures()
    button:SetSize(18, 18)
    button:SetTemplate("Overlay")

    button.text = button:CreateFontString(nil, "OVERLAY")
    button.text:SetFont(C.media.standard_font[1], 16, C.media.standard_font[3])
    button.text:SetText("x")
    button.text:SetPoint("CENTER", 0, 1)
    button.text:SetTextColor(unpack(C.media.text_color))

    button:HookScript("OnEnter", setModifiedBackdrop)
    button:HookScript("OnLeave", setOriginalBackdrop)

    if anchor then
        button:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -4, -4)
    end

    button.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinTab(tab) — Tab button
----------------------------------------------------------------------------------------

function E:SkinTab(tab)
    if not tab or tab.__skinned then
        return
    end
    if tab:IsForbidden() then
        return
    end

    tab:StripTextures()

    local bg = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    bg:SetInside(tab, 4, 4)
    bg:SetFrameLevel(tab:GetFrameLevel() - 1)
    bg:SetTemplate("Overlay")
    tab.bg = bg

    tab:HookScript("OnEnter", function(self)
        self.bg:SetBackdropBorderColor(r, g, b)
    end)
    tab:HookScript("OnLeave", function(self)
        self.bg:SetBackdropBorderColor(unpack(C.media.border_color))
    end)

    tab.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinScrollBar(scrollBar) — Scrollbar
----------------------------------------------------------------------------------------

function E:SkinScrollBar(scrollBar)
    if not scrollBar or scrollBar.__skinned then
        return
    end
    if scrollBar:IsForbidden() then
        return
    end

    scrollBar:StripTextures()

    local thumb = scrollBar.GetThumbTexture and scrollBar:GetThumbTexture()
    if thumb then
        thumb:SetTexture(C.media.texture.blank)
        thumb:SetVertexColor(r, g, b, 0.6)
        thumb:SetSize(6, 40)
    end

    scrollBar.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinEditBox(editbox) — Input field
----------------------------------------------------------------------------------------

function E:SkinEditBox(editbox)
    if not editbox or editbox.__skinned then
        return
    end
    if editbox:IsForbidden() then
        return
    end

    editbox:StripTextures()
    editbox:SetTemplate("Blur")

    editbox.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinSlider(slider) — Slider control
----------------------------------------------------------------------------------------

function E:SkinSlider(slider)
    if not slider or slider.__skinned then
        return
    end
    if slider:IsForbidden() then
        return
    end

    slider:StripTextures()
    slider:SetTemplate("Overlay")

    local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
    if thumb then
        thumb:SetTexture(C.media.texture.blank)
        thumb:SetVertexColor(r, g, b)
        thumb:SetSize(12, 12)
    end

    slider.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinDropDown(dropdown) — Dropdown menu
----------------------------------------------------------------------------------------

function E:SkinDropDown(dropdown)
    if not dropdown or dropdown.__skinned then
        return
    end
    if dropdown:IsForbidden() then
        return
    end

    dropdown:StripTextures()
    dropdown:SetTemplate("Blur")

    local button = dropdown.Button or (dropdown.GetName and _G[dropdown:GetName() .. "Button"])
    if button then
        button:StripTextures()
        button:SetTemplate("Overlay")
        button:SetSize(20, 20)
        button:SetPoint("RIGHT", -2, 0)
    end

    dropdown.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinStatusBar(bar) — Status/progress bar
----------------------------------------------------------------------------------------

function E:SkinStatusBar(bar)
    if not bar or bar.__skinned then
        return
    end
    if bar:IsForbidden() then
        return
    end

    bar:StripTextures()
    bar:SetStatusBarTexture(C.media.texture.status)
    bar:CreateBackground()

    if bar.bg then
        bar.bg:SetTemplate("Overlay")
    end

    bar.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinPortrait(frame) — Portrait frame (character panel style)
--    Strips portrait decorations, applies standard frame skin
----------------------------------------------------------------------------------------

function E:SkinPortrait(frame)
    if not frame or frame.__skinned then
        return
    end
    if frame:IsForbidden() then
        return
    end

    -- Kill portrait-specific regions
    local portrait = frame.PortraitContainer or frame.portrait
    if portrait then
        portrait:SetAlpha(0)
    end
    if frame.PortraitFrame then
        frame.PortraitFrame:SetAlpha(0)
    end

    -- Apply standard frame skin
    frame:StripTextures()
    frame:SetTemplate("Default")
    frame:CreateShadow()

    frame.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinCheckBox(checkbox) — Already exists in Style.lua, re-export for consistency
--    (see Core/Style.lua E:SkinCheckBox)
----------------------------------------------------------------------------------------

-- E:SkinCheckBox is already defined in Style.lua, no need to redefine here

----------------------------------------------------------------------------------------
--    E:SkinNavBar(navBar) — Navigation breadcrumb bar
----------------------------------------------------------------------------------------

function E:SkinNavBar(navBar)
    if not navBar or navBar.__skinned then
        return
    end
    if navBar:IsForbidden() then
        return
    end

    navBar:StripTextures()
    navBar:SetTemplate("Transparent")

    local overflowButton = navBar.overflow
    if overflowButton then
        E:SkinButton(overflowButton)
    end

    navBar.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinTrimScrollBar(scrollBar) — New-style TrimScrollBar (12.0+)
----------------------------------------------------------------------------------------

function E:SkinTrimScrollBar(scrollBar)
    if not scrollBar or scrollBar.__skinned then
        return
    end
    if scrollBar:IsForbidden() then
        return
    end

    scrollBar:StripTextures()

    if scrollBar.Track then
        scrollBar.Track:StripTextures()
    end
    if scrollBar.Thumb then
        scrollBar.Thumb:StripTextures()
        scrollBar.Thumb:SetTemplate("Overlay")
        scrollBar.Thumb:SetFixedPanelTemplate(nil)
    end
    if scrollBar.Back then
        scrollBar.Back:StripTextures()
    end
    if scrollBar.Forward then
        scrollBar.Forward:StripTextures()
    end

    scrollBar.__skinned = true
end

----------------------------------------------------------------------------------------
--    E:SkinInsetFrame(frame) — Inset panels within larger frames
----------------------------------------------------------------------------------------

function E:SkinInsetFrame(frame)
    if not frame or frame.__skinned then
        return
    end
    if frame:IsForbidden() then
        return
    end

    frame:StripTextures()
    frame:SetTemplate("Transparent")

    frame.__skinned = true
end
