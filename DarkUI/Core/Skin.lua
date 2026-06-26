local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Skin Engine — global E:Reskin* skins + E:RegisterSkin dispatch.
-- The Skins module (S:Handle* compat layer + per-frame dispatcher) lives
-- in Skins/Core.lua, since it serves the Skins ports rather than the engine.
------------------------------------------------------------------------

local _G = _G
local CreateFrame = CreateFrame
local unpack = unpack

local r, g, b = E.myColor.r, E.myColor.g, E.myColor.b
local onEnterHighlight = E.onEnterHighlight
local onLeaveHighlight = E.onLeaveHighlight

------------------------------------------------------------------------
-- Skin Registration (ADDON_LOADED dispatch)
------------------------------------------------------------------------

local themes = {}
local loaded = {}

function E:RegisterSkin(addonName, func)
    if loaded[addonName] then return end
    if C_AddOns.IsAddOnLoaded(addonName) then
        local ok, err = pcall(func)
        if not ok then geterrorhandler()(("DarkUI Skin [%s]: %s"):format(addonName, err)) end
        loaded[addonName] = true
    else
        themes[addonName] = func
    end
end

local function onAddonLoaded(_, event, addonName)
    local func = themes[addonName]
    if func then
        local ok, err = pcall(func)
        if not ok then geterrorhandler()(("DarkUI Skin [%s]: %s"):format(addonName, err)) end
        themes[addonName] = nil
        loaded[addonName] = true
    end
end

E.Event:Register("ADDON_LOADED", onAddonLoaded, E)

------------------------------------------------------------------------
-- E:ReskinFrame — generic frame skin
------------------------------------------------------------------------

function E:ReskinFrame(frame)
    if not frame or frame.__styled then return end
    if frame:IsForbidden() then return end

    frame:StripTextures()
    frame:SetTemplate("default")
    frame:CreateShadow()

    frame.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinButton — button skin (strips + fill + hover)
------------------------------------------------------------------------

function E:ReskinButton(button, strip)
    if not button or button.__styled then return end
    if button:IsForbidden() then return end

    -- Clear the button's own art (named textures). Only StripTextures when
    -- explicitly asked: a blanket strip also wipes unnamed icon regions
    -- (e.g. MerchantSellAllJunkButton's coin icon). Mirrors ElvUI HandleButton.
    if button.SetNormalTexture then button:SetNormalTexture("") end
    if button.SetPushedTexture then button:SetPushedTexture("") end
    if button.SetDisabledTexture then button:SetDisabledTexture("") end

    if strip then button:StripTextures() end

    if button.Left then button.Left:SetAlpha(0) end
    if button.Right then button.Right:SetAlpha(0) end
    if button.Middle then button.Middle:SetAlpha(0) end
    if button.LeftSeparator then button.LeftSeparator:SetAlpha(0) end
    if button.RightSeparator then button.RightSeparator:SetAlpha(0) end
    if button.Flash then button.Flash:SetAlpha(0) end

    if button.TopLeft then button.TopLeft:Hide() end
    if button.TopRight then button.TopRight:Hide() end
    if button.BottomLeft then button.BottomLeft:Hide() end
    if button.BottomRight then button.BottomRight:Hide() end
    if button.TopMiddle then button.TopMiddle:Hide() end
    if button.MiddleLeft then button.MiddleLeft:Hide() end
    if button.MiddleRight then button.MiddleRight:Hide() end
    if button.BottomMiddle then button.BottomMiddle:Hide() end
    if button.MiddleMiddle then button.MiddleMiddle:Hide() end

    button:SetTemplate("Fill")
    button:CreateGradient(C.media.gradient_color_light)

    -- white edge tinted to the resting border color; hover recolors it to the theme gold.
    -- __borderColor is what onLeaveHighlight restores to after a hover.
    button.__borderColor = C.media.button_border_color
    button:SetBackdropEdge("round_white", C.media.button_border_color)

    -- mouseover highlight fill (ADD-blend glow, visible regardless of border color)
    if button.SetHighlightTexture then
        button:SetHighlightTexture(C.media.texture.blank)
        local hl = button:GetHighlightTexture()
        if hl then
            hl:SetBlendMode("ADD")
            hl:SetVertexColor(1, 1, 1, 0.12)
            hl:SetInside()
        end
    end

    button:HookScript("OnEnter", onEnterHighlight)
    button:HookScript("OnLeave", onLeaveHighlight)

    button.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinTab — tab button (intentional no-op)
------------------------------------------------------------------------

-- The Blizzard tab art (uiframe-tab / uiframe-activetab atlases) already reads
-- as a dark theme and carries its own selected-state highlight (the Active
-- textures). Stripping it and rebuilding a backdrop loses that built-in
-- selected indicator for no visual gain, so ReskinTab is kept as a no-op:
-- callers / S:HandleTab still route here, but the native art is left untouched.
function E:ReskinTab(tab)
    if not tab or tab.__styled then return end
    if tab:IsForbidden() then return end

    tab.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinScrollBar — classic scrollbar
------------------------------------------------------------------------

function E:ReskinScrollBar(scrollBar)
    if not scrollBar or scrollBar.__styled then return end
    if scrollBar:IsForbidden() then return end

    scrollBar:StripTextures()

    local thumb = scrollBar.GetThumbTexture and scrollBar:GetThumbTexture()
    if thumb then
        thumb:SetTexture(C.media.texture.blank)
        thumb:SetVertexColor(r, g, b, 0.6)
        thumb:SetSize(6, 40)
    end

    scrollBar.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinEditBox — input field
------------------------------------------------------------------------

function E:ReskinEditBox(editbox)
    if not editbox or editbox.__styled then return end
    if editbox:IsForbidden() then return end

    editbox:StripTextures()
    editbox:SetTemplate("Default")
    editbox:SetBackdropEdge("blur")

    editbox.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinSlider — slider control
------------------------------------------------------------------------

function E:ReskinSlider(slider)
    if not slider or slider.__styled then return end
    if slider:IsForbidden() then return end

    slider:StripTextures()
    slider:SetTemplate("Fill")

    local thumb = slider.GetThumbTexture and slider:GetThumbTexture()
    if thumb then
        thumb:SetTexture(C.media.texture.blank)
        thumb:SetVertexColor(r, g, b)
        thumb:SetSize(12, 12)
    end

    slider.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinDropDown — dropdown menu
------------------------------------------------------------------------

function E:ReskinDropDown(dropdown)
    if not dropdown or dropdown.__styled then return end
    if dropdown:IsForbidden() then return end

    dropdown:StripTextures()
    dropdown:SetTemplate("Default")
    dropdown:SetBackdropEdge("blur")

    local name = dropdown.GetName and dropdown:GetName()
    local button = dropdown.Button or (name and _G[name .. "Button"])
    if button then
        button:StripTextures()
        button:SetTemplate("Fill")
        button:SetSize(20, 20)
        button:SetPoint("RIGHT", -2, 0)
    end

    dropdown.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinStatusBar — status/progress bar
------------------------------------------------------------------------

function E:ReskinStatusBar(bar)
    if not bar or bar.__styled then return end
    if bar:IsForbidden() then return end

    bar:StripTextures()
    bar:SetStatusBarTexture(C.media.texture.status)

    local bg = bar:CreateBackdrop()
    bg:SetTemplate("Fill")

    bar.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinPortrait — portrait frame
------------------------------------------------------------------------

function E:ReskinPortrait(frame)
    if not frame or frame.__styled then return end
    if frame:IsForbidden() then return end

    local portrait = frame.PortraitContainer or frame.portrait
    if portrait then portrait:SetAlpha(0) end
    if frame.PortraitFrame then frame.PortraitFrame:SetAlpha(0) end

    frame:StripTextures()
    frame:CreateBackdrop("default", 4)
    frame.__backdrop:CreateGradient()
    frame.__backdrop:CreateBorder("regular")
    frame.__backdrop.__border:CreateShadow()
    -- frame.__backdrop:SetBackdropBorderColor(.5, .5, .5)

    frame.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinNavBar — navigation breadcrumb bar
------------------------------------------------------------------------

function E:ReskinNavBar(navBar)
    if not navBar or navBar.__styled then return end
    if navBar:IsForbidden() then return end

    navBar:StripTextures()
    navBar:SetTemplate("Transparent")

    local overflowButton = navBar.overflow
    if overflowButton then E:ReskinButton(overflowButton) end

    navBar.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinTrimScrollBar — new-style TrimScrollBar (12.0+)
------------------------------------------------------------------------

function E:ReskinTrimScrollBar(scrollBar)
    if not scrollBar or scrollBar.__styled then return end
    if scrollBar:IsForbidden() then return end

    scrollBar:StripTextures()

    if scrollBar.Track then scrollBar.Track:StripTextures() end
    if scrollBar.Thumb then
        scrollBar.Thumb:StripTextures()
        scrollBar.Thumb:SetTemplate("Fill")
    end
    if scrollBar.Back then scrollBar.Back:StripTextures() end
    if scrollBar.Forward then scrollBar.Forward:StripTextures() end

    scrollBar.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinInsetFrame — inset panels
------------------------------------------------------------------------

function E:ReskinInsetFrame(frame)
    if not frame or frame.__styled then return end
    if frame:IsForbidden() then return end

    frame:StripTextures()
    frame:SetTemplate("Transparent")

    frame.__styled = true
end
