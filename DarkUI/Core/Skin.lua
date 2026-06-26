local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Skin Engine — E:Reskin* Blizzard widget adapters
------------------------------------------------------------------------

local _G = _G

local r, g, b = E.myColor.r, E.myColor.g, E.myColor.b
local onEnterHighlight = E.onEnterHighlight
local onLeaveHighlight = E.onLeaveHighlight

-- EditBox native border pieces (InputBoxTemplate & kin). Hidden individually
-- instead of a blanket StripTextures, which would also blank the region the
-- blinking caret renders against and leave a focused box with no cursor.
local EDITBOX_BORDER_REGIONS = { "Left", "Middle", "Right", "Mid" }

------------------------------------------------------------------------
-- Guard Convention
--
-- Each E:Reskin* strips the native Blizzard art then delegates the look to an
-- E:Style* builder. `frame.__styled` is the single canonical "already skinned"
-- flag, shared by E:Reskin*/E:Style* and the Skins module's S:Handle* layer
-- (which routes here) so no widget is skinned twice. Distinct one-shot
-- sub-feature guards that may coexist with __styled keep their own names
-- (e.g. __iconBorderHooked, collapsedSkinned).
------------------------------------------------------------------------

------------------------------------------------------------------------
-- E:ReskinPanel — skin a Blizzard panel/window (strip native art + StyleContainer).
-- opts forwards to StyleContainer; the portrait/inset/navbar container reskins
-- specialize through this rather than re-stripping themselves.
------------------------------------------------------------------------

function E:ReskinPanel(frame, opts)
    if not frame or frame.__styled then return end
    if frame:IsForbidden() then return end

    frame:StripTextures()
    E:StyleContainer(frame, opts) -- default: backdrop + shadow (pixel square edge)
end

------------------------------------------------------------------------
-- E:ReskinUIPanelButton — text/push button (UIPanelButtonTemplate): strips + fill + hover
------------------------------------------------------------------------

function E:ReskinUIPanelButton(button, strip)
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

    -- Hide native border art WITHOUT a blanket StripTextures: that also blanks
    -- the region the caret renders against, so a focused box shows no cursor.
    -- Mirror ElvUI HandleEditBox — hide named border pieces + the NineSlice.
    local name = editbox.GetName and editbox:GetName()
    for _, area in ipairs(EDITBOX_BORDER_REGIONS) do
        local region = (name and _G[name .. area]) or editbox[area]
        if region then region:SetAlpha(0) end
    end
    if editbox.NineSlice then editbox.NineSlice:StripTextures() end

    local bg = E:StyleInput(editbox)

    -- modest left clearance so the border line doesn't sit on the caret's home
    -- position (editbox x=0); ElvUI/NDui extend the editbox backdrop the same way.
    bg:SetPoint("TOPLEFT", editbox, "TOPLEFT", -3, 0)
    bg:SetPoint("BOTTOMRIGHT", editbox, "BOTTOMRIGHT", 3, 0)

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
-- E:ReskinDropDown — dropdown menu (input control: blur edge + own arrow)
------------------------------------------------------------------------

function E:ReskinDropDown(dropdown, width, template)
    if not dropdown or dropdown:IsForbidden() then return end

    -- width re-applies every call; the chrome is built only once
    if width then dropdown:SetWidth(width) end

    if dropdown.__styled then return end
    dropdown.__styled = true

    dropdown:StripTextures(true)
    local bg = E:StyleInput(dropdown, template)
    dropdown:OffsetFrameLevel(2)

    -- modern WowStyle dropdowns expose Arrow; legacy ones a Button child
    if dropdown.Arrow then dropdown.Arrow:SetAlpha(0) end
    local name = dropdown.GetName and dropdown:GetName()
    local button = dropdown.Button or (name and _G[name .. "Button"])
    if button then button:SetAlpha(0) end

    bg:SetPoint("TOPLEFT", 0, -2)
    bg:SetPoint("BOTTOMRIGHT", 0, 2)

    -- our own dropdown arrow (tex_arrow points up → rotate to point down)
    local arrow = dropdown:CreateTexture(nil, "ARTWORK")
    arrow:SetTexture(C.media.texture.arrow)
    arrow:SetRotation(math.pi)
    arrow:SetPoint("RIGHT", bg, -3, 0)
    arrow:SetSize(14, 14)
    dropdown.__ddArrow = arrow
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

    -- = ReskinPanel + hidden portrait region
    E:ReskinPanel(frame, { border = "regular", margin = 4, gradient = true })
end

------------------------------------------------------------------------
-- E:ReskinNavBar — navigation breadcrumb bar
------------------------------------------------------------------------

function E:ReskinNavBar(navBar)
    if not navBar or navBar.__styled then return end

    E:ReskinPanel(navBar, { backdrop = "transparent", shadow = false })

    local overflowButton = navBar.overflow
    if overflowButton then E:ReskinUIPanelButton(overflowButton) end
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

function E:ReskinInsetFrame(frame) E:ReskinPanel(frame, { backdrop = "transparent", shadow = false }) end
