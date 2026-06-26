local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Style — DarkUI public styling API
------------------------------------------------------------------------

local r, g, b = E.myColor.r, E.myColor.g, E.myColor.b
local unpack = unpack

------------------------------------------------------------------------
-- Hover Helpers (exported for Skin.lua)
------------------------------------------------------------------------

local function onEnterHighlight(self)
    if self:IsEnabled() then
        self:SetBackdropBorderColor(r, g, b)
        if self.__overlay then self.__overlay:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 1) end
    end
end

local function onLeaveHighlight(self)
    self:SetBackdropBorderColor(unpack(self.__borderColor or C.media.border_color))
    if self.__overlay then self.__overlay:SetVertexColor(0.1, 0.1, 0.1, 1) end
end

E.onEnterHighlight = onEnterHighlight
E.onLeaveHighlight = onLeaveHighlight

------------------------------------------------------------------------
-- E:StyleContainer — the canonical container look (bg + optional border/shadow/gradient)
-- Applies our standard decorated backdrop to ANY frame (chat/bags surfaces,
-- and via the container reskins E:ReskinPanel/Portrait/InsetFrame/NavBar, which
-- only strip the Blizzard art then call this for the appearance).
-- opts: { backdrop = template, margin, border = edge|false, shadow = false?, gradient = bool }
-- Default = backdrop's pixel square edge + drop shadow (no textured border).
------------------------------------------------------------------------

function E:StyleContainer(frame, opts)
    if not frame or frame:IsForbidden() then return end
    if frame.__styled then return end

    if type(opts) ~= "table" then opts = { gradient = opts } end

    local bg = frame:CreateBackdrop(opts.backdrop, opts.margin)
    if opts.gradient then bg:CreateGradient() end

    -- textured border is opt-in; otherwise the backdrop's pixel square edge stands
    if opts.border then bg:CreateBorder(opts.border) end

    -- drop shadow on by default: on the border frame if present, else the backdrop
    if opts.shadow ~= false then
        local shadowHost = bg.__border or bg
        shadowHost:CreateShadow()
    end

    frame.__styled = true
end

------------------------------------------------------------------------
-- E:StyleInput — the canonical input-control look (blur-edged backdrop)
-- ReskinEditBox/ReskinDropDown delegate here (strip art, then call this).
------------------------------------------------------------------------

function E:StyleInput(frame, template)
    local bg = frame:CreateBackdrop(template or "Default")
    bg:SetBackdropEdge("blur")
    return bg
end

------------------------------------------------------------------------
-- E:StyleIcon — texCoord + bg frame on existing icon texture
------------------------------------------------------------------------

function E:StyleIcon(icon, shadow, parent)
    parent = parent or icon:GetParent()

    icon:SetTexCoord(unpack(C.media.texCoord))

    local bg = parent:CreateBackdrop()
    bg:SetOutside(icon)

    if shadow then bg:CreateShadow() end

    return bg
end

------------------------------------------------------------------------
-- E:StyleCheckBox
------------------------------------------------------------------------

function E:StyleCheckBox(frame)
    if not frame or frame.__styled then return end

    local lvl = frame:GetFrameLevel()

    frame:SetNormalTexture("")
    frame:SetPushedTexture("")
    frame:SetHighlightTexture(C.media.texture.status)

    local bg = CreateFrame("Frame", nil, frame)
    bg:SetInside(frame, 4, 4)
    bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
    bg:SetTemplate("Default")
    bg:SetBackdropEdge("blur")
    frame.__bg = bg

    frame.hl = frame:GetHighlightTexture()
    frame.hl:SetInside(bg)
    frame.hl:SetVertexColor(r, g, b, 0.2)

    frame.ch = frame:GetCheckedTexture()
    frame.ch:SetAtlas("checkmark-minimal")
    frame.ch:SetDesaturated(true)
    frame.ch:SetTexCoord(0, 1, 0, 1)
    frame.ch:SetVertexColor(r, g, b)

    frame.__styled = true
end

------------------------------------------------------------------------
-- E:StyleIconButton — icon button look (square button with a swappable Icon):
-- overlay border + highlight/pushed/checked state textures + icon texCoord.
-- Distinct from E:ReskinUIPanelButton (text/push buttons). The ElvUI-compat
-- method form button:StyleButton() routes here (see Core/API.lua).
------------------------------------------------------------------------

function E:StyleIconButton(button, margin, skipOverlay)
    local margin = margin or 2

    if not skipOverlay then
        local overlay = button:CreateTexture(nil, "OVERLAY")
        overlay:SetOutside(button, margin, margin)
        overlay:SetTexture(C.media.texture.overlay)
        button.__overlay = overlay
    end

    local icon = button.Icon or button.icon
    if icon then
        icon:SetTexCoord(unpack(C.media.texCoord))
        icon:SetInside(button, margin, margin)
    end

    if button.NormalTexture then button.NormalTexture:SetAlpha(0) end

    if button.SetHighlightTexture and not button.highlight then
        local highlight = button:CreateTexture()
        highlight:SetTexture(C.media.button.hover)
        highlight:SetInside(button, margin, margin)
        button.highlight = highlight
        button:SetHighlightTexture(highlight)
    end

    if button.SetPushedTexture and not button.pushed then
        local pushed = button:CreateTexture()
        pushed:SetTexture(C.media.button.pushed)
        pushed:SetInside(button, margin, margin)
        button.pushed = pushed
        button:SetPushedTexture(pushed)
    end

    if button.SetCheckedTexture and not button.checked then
        local checked = button:CreateTexture()
        checked:SetTexture(C.media.button.checked)
        checked:SetInside(button, margin, margin)
        button.checked = checked
        button:SetCheckedTexture(checked)
    end

    local cooldown = button:GetName() and _G[button:GetName() .. "Cooldown"] or button.Cooldown
    if cooldown then cooldown:SetInside(button, margin, margin) end
end

------------------------------------------------------------------------
-- E:StyleCloseButton — close button (X)
------------------------------------------------------------------------

local function closeOnEnter(self)
    if self.__tex then self.__tex:SetVertexColor(r, g, b) end
end

local function closeOnLeave(self)
    if self.__tex then self.__tex:SetVertexColor(1, 1, 1) end
end

function E:StyleCloseButton(button, anchor)
    if not button or button.__styled then return end

    button:StripTextures()

    if button.SetNormalTexture then button:SetNormalTexture("") end
    if button.SetPushedTexture then button:SetPushedTexture("") end
    if button.SetDisabledTexture then button:SetDisabledTexture("") end
    if button.SetHighlightTexture then button:SetHighlightTexture("") end

    local tex = button:CreateTexture(nil, "OVERLAY")
    tex:SetPoint("CENTER")
    tex:SetTexture(C.media.texture.close)
    tex:SetSize(12, 12)
    tex:SetVertexColor(1, 1, 1)
    button.__tex = tex

    button:SetHitRectInsets(6, 6, 7, 7)
    button:HookScript("OnEnter", closeOnEnter)
    button:HookScript("OnLeave", closeOnLeave)

    if anchor then button:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -4, -4) end

    button.__styled = true
end
