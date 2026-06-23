local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Skin Engine
------------------------------------------------------------------------

local _G = _G
local pairs, type, select = pairs, type, select
local hooksecurefunc = hooksecurefunc
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
    frame:SetTemplate("Default")
    frame:CreateShadow()

    frame.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinButton — button skin (strips + fill + hover)
------------------------------------------------------------------------

function E:ReskinButton(button)
    if not button or button.__styled then return end
    if button:IsForbidden() then return end

    button:StripTextures()

    if button.SetNormalTexture then button:SetNormalTexture("") end
    if button.SetHighlightTexture then button:SetHighlightTexture("") end
    if button.SetPushedTexture then button:SetPushedTexture("") end
    if button.SetDisabledTexture then button:SetDisabledTexture("") end

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
    button:HookScript("OnEnter", onEnterHighlight)
    button:HookScript("OnLeave", onLeaveHighlight)

    button.__styled = true
end

------------------------------------------------------------------------
-- E:ReskinTab — tab button
------------------------------------------------------------------------

function E:ReskinTab(tab)
    if not tab or tab.__styled then return end
    if tab:IsForbidden() then return end

    tab:StripTextures()

    local bg = CreateFrame("Frame", nil, tab, "BackdropTemplate")
    bg:SetInside(tab, 4, 4)
    bg:SetFrameLevel(tab:GetFrameLevel() - 1)
    bg:SetTemplate("Fill")
    tab.__bg = bg

    tab:HookScript("OnEnter", function(self) self.__bg:SetBackdropBorderColor(r, g, b) end)
    tab:HookScript("OnLeave", function(self) self.__bg:SetBackdropBorderColor(unpack(C.media.border_color)) end)

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

    local button = dropdown.Button or (dropdown.GetName and _G[dropdown:GetName() .. "Button"])
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
    frame:SetTemplate("Default")
    frame:CreateShadow()

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
        scrollBar.Thumb:SetFixedPanelTemplate(nil)
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
