local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Skins Module — ElvUI-compatible per-frame skin dispatcher
------------------------------------------------------------------------

local _G = _G
local pairs, ipairs, type, select = pairs, ipairs, type, select
local tinsert, wipe, strfind = tinsert, wipe, strfind
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local unpack = unpack
local issecretvalue = issecretvalue
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local r, g, b = E.myColor.r, E.myColor.g, E.myColor.b

local S = E:Module("Skins")
S:SetConfigKey("skins")

S.addonsToLoad = {}
S.nonAddonsToLoad = {}
S.initialized = false

-- Arrow texture points up by default; rotate per direction (radians)
S.ArrowRotation = { up = 0, down = 3.14, left = 1.57, right = -1.57 }

------------------------------------------------------------------------
-- Notes
--
-- This S layer is Skins-only: the dispatcher (AddCallback*/OnEnable) and the
-- S:Handle* compat layer that Skins/Frames ports call. The global engine
-- (E:Reskin*/E:Style*) stays in Core/; ports reference this module via
-- `local S = E:GetModule("Skins")`.
--
-- Guard convention: S:Handle* use the same `frame.__styled` flag as the Core
-- engine (not ElvUI's IsSkinned) so both layers see each other's work. Distinct
-- one-shot sub-feature guards keep their own names (__iconBorderHooked,
-- collapsedSkinned) as they may coexist with __styled on the same object.
------------------------------------------------------------------------

------------------------------------------------------------------------
-- Dispatch (mirrors ElvUI AddCallback / AddCallbackForAddon / Initialize)
------------------------------------------------------------------------

local function runFunc(func)
    local ok, err = pcall(func, S)
    if not ok then geterrorhandler()(("DarkUI Skin: %s"):format(err)) end
end

function S:AddCallback(name, func)
    local load = (type(name) == "function" and name) or (not func and self[name]) or func
    if load then tinsert(self.nonAddonsToLoad, load) end
end

function S:AddCallbackForAddon(addon, name, func)
    local load = (type(name) == "function" and name) or (not func and (self[name] or self[addon])) or func
    if not load then return end

    local list = self.addonsToLoad[addon]
    if not list then
        list = {}
        self.addonsToLoad[addon] = list
    end
    tinsert(list, load)
end

function S:CallLoadedAddon(addon)
    local list = self.addonsToLoad[addon]
    if not list then return end

    for _, func in ipairs(list) do
        runFunc(func)
    end
    self.addonsToLoad[addon] = nil
end

function S:OnEnable()
    self.initialized = true

    for _, func in ipairs(self.nonAddonsToLoad) do
        runFunc(func)
    end
    wipe(self.nonAddonsToLoad)

    for addon in pairs(self.addonsToLoad) do
        if IsAddOnLoaded(addon) then self:CallLoadedAddon(addon) end
    end

    self:RegisterEvent("ADDON_LOADED", function(_, _, addon)
        if self.initialized and self.addonsToLoad[addon] then self:CallLoadedAddon(addon) end
    end)
end

------------------------------------------------------------------------
-- Routing compat layer (S:Handle* → existing E:Reskin*/E:Style*)
------------------------------------------------------------------------

function S:HandleButton(button, strip) return E:ReskinUIPanelButton(button, strip) end

function S:HandleCloseButton(button, anchor) return E:StyleCloseButton(button, anchor) end

function S:HandleTab(tab) return E:ReskinTab(tab) end

function S:HandleEditBox(frame) return E:ReskinEditBox(frame) end

function S:HandleScrollBar(frame) return E:ReskinScrollBar(frame) end

function S:HandleTrimScrollBar(frame) return E:ReskinTrimScrollBar(frame) end

function S:HandleStatusBar(bar) return E:ReskinStatusBar(bar) end

-- ElvUI parity: HandlePortraitFrame/HandleFrame also skin the inset + close button
local INSET_PIECES = {
    "InsetBorderTop",
    "InsetBorderTopLeft",
    "InsetBorderTopRight",
    "InsetBorderBottom",
    "InsetBorderBottomLeft",
    "InsetBorderBottomRight",
    "InsetBorderLeft",
    "InsetBorderRight",
    "Bg",
}

function S:HandleInsetFrame(frame)
    if not frame then return end
    for _, piece in ipairs(INSET_PIECES) do
        if frame[piece] then frame[piece]:Hide() end
    end
end

local function handleFrameExtras(frame)
    local name = frame.GetName and frame:GetName()
    local inset = frame.Inset or (name and _G[name .. "Inset"])
    if inset then S:HandleInsetFrame(inset) end

    if frame.CloseButton then E:StyleCloseButton(frame.CloseButton) end
end

function S:HandlePortraitFrame(frame)
    if not frame then return end
    E:ReskinPortrait(frame)
    handleFrameExtras(frame)
end

function S:HandleFrame(frame)
    if not frame then return end
    E:ReskinPanel(frame)
    handleFrameExtras(frame)
end

function S:HandleSliderFrame(frame) return E:ReskinSlider(frame) end

function S:HandleCheckBox(frame) return E:StyleCheckBox(frame) end

function S:HandleDropDownBox(frame, width, template) return E:ReskinDropDown(frame, width or 155, template) end

------------------------------------------------------------------------
-- HandleBlizzardRegions — hide named Blizzard art regions
------------------------------------------------------------------------

S.BlizzardRegions = {
    "Left",
    "Middle",
    "Right",
    "Mid",
    "LeftDisabled",
    "MiddleDisabled",
    "RightDisabled",
    "BorderBottom",
    "BorderBottomLeft",
    "BorderBottomRight",
    "BorderLeft",
    "BorderRight",
    "TopLeft",
    "TopRight",
    "BottomLeft",
    "BottomRight",
    "TopMiddle",
    "MiddleLeft",
    "MiddleRight",
    "BottomMiddle",
    "MiddleMiddle",
    "TabSpacer",
    "TabSpacer1",
    "TabSpacer2",
    "_RightSeparator",
    "_LeftSeparator",
    "Cover",
    "Border",
    "Background",
    "TopTex",
    "TopLeftTex",
    "TopRightTex",
    "LeftTex",
    "BottomTex",
    "BottomLeftTex",
    "BottomRightTex",
    "RightTex",
    "MiddleTex",
    "Center",
    "ArtOverlayFrame",
    "FilligreeOverlay",
    "PortraitOverlay",
    "ScrollFrameBorder",
    "ScrollUpBorder",
    "ScrollDownBorder",
}

function S:HandleBlizzardRegions(frame, name, kill, zero)
    if not name then name = frame.GetName and frame:GetName() end

    for _, area in ipairs(S.BlizzardRegions) do
        local object = (name and _G[name .. area]) or frame[area]
        if object then
            if kill then
                object:Kill()
            elseif zero then
                object:SetAlpha(0)
            else
                object:Hide()
            end
        end
    end
end

------------------------------------------------------------------------
-- HandleIcon — crop icon + optional backdrop
------------------------------------------------------------------------

function S:HandleIcon(icon, backdrop)
    if not icon then return end

    icon:SetTexCoords()
    if backdrop and not icon.backdrop then icon:CreateBackdrop() end
end

------------------------------------------------------------------------
-- HandleItemButton — item slot button (icon + backdrop + style)
------------------------------------------------------------------------

function S:HandleItemButton(b, setInside, ignoreParent)
    if not b or b.__styled then return end
    if b:IsForbidden() then return end

    local name = b:GetName()
    local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name .. "IconTexture"] or _G[name .. "Icon"]))

    -- clear Blizzard slot art (mirror the action button's individual clears)
    if b.SlotBackground then b.SlotBackground:Hide() end
    if b.IconMask then b.IconMask:Hide() end
    if b.NewActionTexture then b.NewActionTexture:SetTexture("") end

    -- backdrop: grey gloss base only (frameLevel -1, behind). The edge is
    -- covered by the higher/wider quality frame qb, so we skip it; the base
    -- still gives empty slots a solid fill.
    local bg = b:CreateBackdrop("Button", 1)
    b.__bg = bg

    -- icon
    if icon then
        icon:SetTexCoords()
        if setInside then
            icon:SetInside(b)
        else
            icon:SetInside(b, 1, 1)
        end
        if not ignoreParent then icon:SetParent(b) end
    end

    -- normal gloss
    if b.SetNormalTexture then
        b:SetNormalTexture(C.media.button.normal)
        local nt = b:GetNormalTexture()
        if nt then
            nt:SetVertexColor(0.5, 0.5, 0.5, 0.6)
            nt:SetAllPoints(b)
        end
    end

    -- pushed
    if b.SetPushedTexture then
        b:SetPushedTexture(C.media.button.glow)
        local pt = b:GetPushedTexture()
        if pt then pt:SetOutside(b, 2, 2) end
    end

    -- highlight (plain white fill, like the action button)
    if b.SetHighlightTexture then
        b:SetHighlightTexture(C.media.texture.blank)
        local hl = b:GetHighlightTexture()
        if hl then
            hl:SetColorTexture(1, 1, 1, 0.25)
            hl:SetAllPoints(b)
        end
    end

    -- checked (gold)
    if b.SetCheckedTexture then
        b:SetCheckedTexture(C.media.texture.blank)
        local ct = b:GetCheckedTexture()
        if ct then
            ct:SetColorTexture(1, 0.8, 0, 0.35)
            ct:SetAllPoints(b)
        end
    end

    -- item-quality color routed onto a dedicated high-layer border frame
    -- (HandleIconBorder builds __qualityBorder at frameLevel +1, covering bg's dark edge)
    if b.IconBorder then S:HandleIconBorder(b.IconBorder) end

    b.__styled = true
end

------------------------------------------------------------------------
-- HandleIconBorder — recolor item-quality border onto our backdrop
-- (secret-safe: GetAtlas/GetVertexColor may return secrets on protected
--  item buttons; fall back to the default border color in that case)
------------------------------------------------------------------------

do
    local ITEMQUALITY = Enum.ItemQuality
    local iconColors = {
        ["auctionhouse-itemicon-border-gray"] = ITEMQUALITY.Poor,
        ["auctionhouse-itemicon-border-white"] = ITEMQUALITY.Common,
        ["auctionhouse-itemicon-border-green"] = ITEMQUALITY.Uncommon,
        ["auctionhouse-itemicon-border-blue"] = ITEMQUALITY.Rare,
        ["auctionhouse-itemicon-border-purple"] = ITEMQUALITY.Epic,
        ["auctionhouse-itemicon-border-orange"] = ITEMQUALITY.Legendary,
        ["auctionhouse-itemicon-border-artifact"] = ITEMQUALITY.Artifact,
        ["auctionhouse-itemicon-border-account"] = ITEMQUALITY.Heirloom,
        ["Professions-Slot-Frame"] = ITEMQUALITY.Common,
        ["Professions-Slot-Frame-Green"] = ITEMQUALITY.Uncommon,
        ["Professions-Slot-Frame-Blue"] = ITEMQUALITY.Rare,
        ["Professions-Slot-Frame-Epic"] = ITEMQUALITY.Epic,
        ["Professions-Slot-Frame-Legendary"] = ITEMQUALITY.Legendary,
    }

    -- atlas → quality with secret guard (atlas may be a secret on protected
    -- item buttons; using a secret as a table key is forbidden)
    local function atlasQuality(atlas)
        if not atlas or (issecretvalue and issecretvalue(atlas)) then return nil end
        return iconColors[atlas]
    end

    -- hook on SetAtlas: atlas-keyed quality takes precedence over vertex color
    local function colorAtlas(border, atlas)
        local quality = atlasQuality(atlas)
        if not quality then return end

        local backdrop = border.customBackdrop
        if not backdrop then return end

        local q = C.media.qualityColors[quality]
        if q then backdrop:SetBackdropBorderColor(q.r, q.g, q.b, 1) end
    end

    -- hook on SetVertexColor: skip when an atlas already defines the quality;
    -- r/g/b may be secrets but SetBackdropBorderColor accepts secret aspects
    local function colorVertex(border, r, g, b)
        if atlasQuality(border.GetAtlas and border:GetAtlas()) then return end

        local backdrop = border.customBackdrop
        if not backdrop then return end

        backdrop:SetBackdropBorderColor(r, g, b)
    end

    -- hook on Hide: value == 0 is our own sentinel re-hide (no recolor);
    -- a real Blizzard Hide() means "no quality border" → restore default color
    local function borderHide(border, value)
        if value == 0 then return end

        local backdrop = border.customBackdrop
        if not backdrop then return end

        backdrop:SetBackdropBorderColor(unpack(C.media.border_color))
    end

    -- hook on Show: suppress Blizzard's own border, keep ours instead
    local function borderShow(border) border:Hide(0) end

    -- hook on SetShown: route through the same suppress / default-color paths
    local function borderShown(border, show)
        if show then
            border:Hide(0)
        else
            borderHide(border)
        end
    end

    -- quality-border frame, created once per button and drawn ABOVE the icon
    -- (frameLevel +1) so it covers the slot bg's dark edge; geometry matches
    -- the action-button item slot. highlight is left to the caller.
    local function qualityBorder(border)
        local parent = border:GetParent()
        local qb = parent.__qualityBorder
        if not qb then
            qb = CreateFrame("Frame", nil, parent, "BackdropTemplate")
            qb:SetOutside(parent, 2, 2)
            qb:SetFrameLevel(parent:GetFrameLevel() + 1)
            qb:SetBackdrop({ edgeFile = C.media.texture.border_thin_white, edgeSize = 8 })
            parent.__qualityBorder = qb
        end
        return qb
    end

    function S:HandleIconBorder(border, backdrop, customFunc)
        if not border or border:IsForbidden() then return end

        backdrop = backdrop or qualityBorder(border)
        border.customBackdrop = backdrop

        -- initial color from current atlas / vertex color
        local quality = atlasQuality(border.GetAtlas and border:GetAtlas())
        local q = quality and C.media.qualityColors[quality]
        if q then
            backdrop:SetBackdropBorderColor(q.r, q.g, q.b, 1)
        else
            local cr, cg, cb, ca = border:GetVertexColor()
            if cr ~= nil and not (issecretvalue and issecretvalue(cr)) then
                backdrop:SetBackdropBorderColor(cr, cg, cb, ca)
            else
                backdrop:SetBackdropBorderColor(unpack(C.media.border_color))
            end
        end

        if not border.__iconBorderHooked then
            border.__iconBorderHooked = true
            border:Hide()

            hooksecurefunc(border, "SetAtlas", colorAtlas)
            hooksecurefunc(border, "SetVertexColor", colorVertex)
            hooksecurefunc(border, "SetShown", borderShown)
            hooksecurefunc(border, "Show", borderShow)
            hooksecurefunc(border, "Hide", borderHide)
        end
    end
end

------------------------------------------------------------------------
-- HandleNextPrevButton — arrow paging button
-- (secret-safe: GetDebugName may return a secret on protected buttons)
------------------------------------------------------------------------

function S:HandleNextPrevButton(btn, arrowDir, color, noBackdrop, stripTexts)
    if not btn or btn.__styled then return end
    if btn:IsForbidden() then return end

    if not arrowDir then
        arrowDir = "down"

        local name = btn.GetDebugName and btn:GetDebugName()
        if name and not (issecretvalue and issecretvalue(name)) then
            name = name:lower()
            if strfind(name, "left") or strfind(name, "prev") or strfind(name, "decrement") or strfind(name, "back") then
                arrowDir = "left"
            elseif strfind(name, "right") or strfind(name, "next") or strfind(name, "increment") or strfind(name, "forward") then
                arrowDir = "right"
            elseif strfind(name, "scrollup") or strfind(name, "upbutton") or strfind(name, "top") or strfind(name, "asc") then
                arrowDir = "up"
            end
        end
    end

    btn:StripTextures()
    if btn.Texture then btn.Texture:SetAlpha(0) end

    if not noBackdrop then E:ReskinUIPanelButton(btn) end
    if stripTexts then btn:StripTexts() end

    local arrow = C.media.texture.arrow
    btn:SetNormalTexture(arrow)
    btn:SetPushedTexture(arrow)
    btn:SetDisabledTexture(arrow)

    local Normal, Disabled, Pushed = btn:GetNormalTexture(), btn:GetDisabledTexture(), btn:GetPushedTexture()

    btn:Size(noBackdrop and 20 or 18)

    if noBackdrop then
        Disabled:SetVertexColor(0.5, 0.5, 0.5)
        btn.Texture = Normal
    else
        Disabled:SetVertexColor(0.3, 0.3, 0.3)
    end

    Normal:SetInside()
    Pushed:SetInside()
    Disabled:SetInside()

    Normal:SetTexCoord(0, 1, 0, 1)
    Pushed:SetTexCoord(0, 1, 0, 1)
    Disabled:SetTexCoord(0, 1, 0, 1)

    local rotation = S.ArrowRotation[arrowDir]
    if rotation then
        Normal:SetRotation(rotation)
        Pushed:SetRotation(rotation)
        Disabled:SetRotation(rotation)
    end

    if color then
        Normal:SetVertexColor(color.r, color.g, color.b)
    else
        Normal:SetVertexColor(1, 1, 1)
    end

    btn.__styled = true
end

------------------------------------------------------------------------
-- HandleIconSelectionFrame — icon picker popup (icon grid + controls)
------------------------------------------------------------------------

-- Skin one icon-grid button (mirrors ElvUI Skins HandleButton). The icon lives
-- in a texture that StripTextures would wipe, so save it before the strip and
-- restore it after. StyleButton zeroes the NormalTexture so it can't cover the
-- icon — this is why HandleItemButton (gloss NormalTexture) blanked these.
local function skinIconSelectorButton(button, i, buttonNameTemplate)
    local icon = button.Icon or (buttonNameTemplate and i and _G[buttonNameTemplate .. i .. "Icon"])
    local texture
    if icon then
        icon:SetTexCoords()
        icon:SetInside(button)
        texture = icon:GetTexture() -- keep this before strip textures
    end

    button:StripTextures()
    button:SetTemplate()
    button:StyleButton(nil, true)

    if texture then icon:SetTexture(texture) end
end

-- On show, nudge the popup off to the side of its parent if it would otherwise
-- overlap (xOffset <= 0). MacroPopupFrame re-anchors to MacroFrame.
local function selectionOffset(frame)
    local point, anchor, relativePoint, xOffset = frame:GetPoint()
    if not point or xOffset > 0 then return end -- no anchor yet / already nudged aside

    local x = frame.BorderBox and 8 or 40
    local y = frame.BorderBox and 4 or -10
    frame:ClearAllPoints()
    frame:Point(point, (frame == _G.MacroPopupFrame and _G.MacroFrame) or anchor, relativePoint, strfind(point, "LEFT") and x or -x, y)
end

function S:HandleIconSelectionFrame(frame, _, _, nameOverride, dontOffset)
    if not frame or frame.__styled then return end

    if not dontOffset then -- place it off to the side of parent with correct offsets
        frame:HookScript("OnShow", selectionOffset)
        frame:Height(frame:GetHeight() + 10)
        -- We're called from the popup's own OnShow, so the hook above was added
        -- mid-dispatch and won't fire for this first show — apply it directly.
        if frame:IsShown() then selectionOffset(frame) end
    end

    local borderBox = frame.BorderBox or _G.BorderBox
    local frameName = nameOverride or frame:GetName()
    local editBox = (borderBox and borderBox.IconSelectorEditBox) or frame.EditBox or (frameName and _G[frameName .. "EditBox"])
    local cancel = frame.CancelButton or (borderBox and borderBox.CancelButton) or (frameName and _G[frameName .. "Cancel"])
    local okay = frame.OkayButton or (borderBox and borderBox.OkayButton) or (frameName and _G[frameName .. "Okay"])

    frame:StripTextures()
    -- frame:SetTemplate("default")
    E:ReskinPanel(frame)

    if borderBox then
        borderBox:StripTextures()

        local dropdown = borderBox.IconTypeDropdown
        if dropdown then S:HandleDropDownBox(dropdown) end

        -- the selected-icon preview is an icon button, not an item slot: use the
        -- blank-safe grid skin (strip + save/restore icon), not HandleItemButton
        -- whose gloss NormalTexture would cover the preview icon.
        local button = borderBox.SelectedIconArea and borderBox.SelectedIconArea.SelectedIconButton
        if button then
            button:DisableDrawLayer("BACKGROUND")
            skinIconSelectorButton(button)
        end
    end

    if cancel then
        cancel:ClearAllPoints()
        cancel:SetPoint("BOTTOMRIGHT", frame, -4, 4)
        S:HandleButton(cancel)
    end
    if okay then
        okay:ClearAllPoints()
        okay:SetPoint("RIGHT", cancel or okay, "LEFT", -10, 0)
        S:HandleButton(okay)
    end
    if editBox then
        editBox:DisableDrawLayer("BACKGROUND")
        S:HandleEditBox(editBox)
    end

    -- icon grid (retail IconSelector ScrollBox). The ScrollBox reuses a fixed
    -- frame pool — scrolling only swaps the icon textures, the frames persist —
    -- so a one-shot ForEachFrame covers every button (mirrors ElvUI).
    local iconSelector = frame.IconSelector
    if iconSelector then
        if iconSelector.ScrollBar then S:HandleTrimScrollBar(iconSelector.ScrollBar) end
        if iconSelector.ScrollBox then iconSelector.ScrollBox:ForEachFrame(skinIconSelectorButton) end
    end

    frame.__styled = true
end

------------------------------------------------------------------------
-- Texture clear helpers (defensive hooks against Blizzard re-skinning)
------------------------------------------------------------------------

function S:ClearNormalTexture(texture)
    if texture ~= E.ClearTexture then self:SetNormalTexture(E.ClearTexture) end
end

function S:ClearPushedTexture(texture)
    if texture ~= E.ClearTexture then self:SetPushedTexture(E.ClearTexture) end
end

function S:ClearDisabledTexture(texture)
    if texture ~= E.ClearTexture then self:SetDisabledTexture(E.ClearTexture) end
end

function S:ClearHighlightTexture(texture)
    if texture ~= E.ClearTexture then self:SetHighlightTexture(E.ClearTexture) end
end

------------------------------------------------------------------------
-- HandleRotateButton — model rotate buttons (atlas arrows)
------------------------------------------------------------------------

function S:HandleRotateButton(button, width, height, noSize)
    if not button or button.__styled then return end
    if button:IsForbidden() then return end

    if not noSize then button:Size(width or 24, height or 24) end
    button:SetTemplate("Fill")

    local left
    local name = button.GetDebugName and button:GetDebugName()
    if name and not (issecretvalue and issecretvalue(name)) then left = strfind(name, "Left") end
    local rotate = left and "common-icon-rotateleft" or "common-icon-rotateright"

    local normTex = button:GetNormalTexture()
    if normTex then
        normTex:SetInside()
        normTex:SetAtlas(rotate)
        normTex:SetTexCoord(0.05, 1.05, -0.05, 1)
    end

    local pushTex = button:GetPushedTexture()
    if pushTex then
        pushTex:SetAllPoints(normTex)
        pushTex:SetAtlas(rotate)
        pushTex:SetTexCoord(0, 1, -0.1, 0.95)
    end

    local highlightTex = button:GetHighlightTexture()
    if highlightTex then
        highlightTex:SetAllPoints(normTex)
        highlightTex:SetColorTexture(1, 1, 1, 0.3)
    end

    button.__styled = true
end

------------------------------------------------------------------------
-- HandleMaxMinFrame — maximize / minimize buttons (rotated arrows)
------------------------------------------------------------------------

do
    local maxMinButtons = { MaximizeButton = "up", MinimizeButton = "down" }

    local function maxMinOnEnter(btn)
        local nt, pt = btn:GetNormalTexture(), btn:GetPushedTexture()
        if nt then nt:SetVertexColor(r, g, b) end
        if pt then pt:SetVertexColor(r, g, b) end
    end

    local function maxMinOnLeave(btn)
        local nt, pt = btn:GetNormalTexture(), btn:GetPushedTexture()
        if nt then nt:SetVertexColor(1, 1, 1) end
        if pt then pt:SetVertexColor(1, 1, 1) end
    end

    function S:HandleMaxMinFrame(frame)
        if not frame or frame.__styled then return end
        if frame:IsForbidden() then return end

        frame:StripTextures(true)

        local arrow = C.media.texture.arrow
        for name, direction in pairs(maxMinButtons) do
            local button = frame[name]
            if button then
                button:SetHitRectInsets(1, 1, 1, 1)
                button:ClearAllPoints()
                button:Point("CENTER")
                button:Size(14)

                local highlight = button:GetHighlightTexture()
                if highlight then highlight:SetTexture("") end

                local rotation = S.ArrowRotation[direction]
                if button.SetNormalTexture then
                    button:SetNormalTexture(arrow)
                    local nt = button:GetNormalTexture()
                    if nt then nt:SetRotation(rotation) end

                    button:HookScript("OnEnter", maxMinOnEnter)
                    button:HookScript("OnLeave", maxMinOnLeave)
                end

                if button.SetPushedTexture then
                    button:SetPushedTexture(arrow)
                    local pt = button:GetPushedTexture()
                    if pt then pt:SetRotation(rotation) end
                end

                if button.SetDisabledTexture then
                    button:SetDisabledTexture(arrow)
                    local disabled = button:GetDisabledTexture()
                    if disabled then
                        disabled:SetRotation(rotation)
                        disabled:SetVertexColor(0.4, 0.4, 0.4)
                    end
                end
            end
        end

        frame.__styled = true
    end
end

------------------------------------------------------------------------
-- HandleRadioButton — masked radio dot
------------------------------------------------------------------------

do
    local maskBackground = [[Interface\Minimap\UI-Minimap-Background]]

    function S:HandleRadioButton(button)
        if not button or button.__styled then return end
        if button:IsForbidden() then return end

        local insideMask = button:CreateMaskTexture()
        insideMask:SetTexture(maskBackground, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        insideMask:Size(10)
        insideMask:Point("CENTER")
        button.InsideMask = insideMask

        local outsideMask = button:CreateMaskTexture()
        outsideMask:SetTexture(maskBackground, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        outsideMask:Size(13)
        outsideMask:Point("CENTER")
        button.OutsideMask = outsideMask

        local blank = C.media.texture.blank
        button:SetCheckedTexture(blank)
        button:SetNormalTexture(blank)
        button:SetHighlightTexture(blank)
        button:SetDisabledTexture(blank)

        local check = button:GetCheckedTexture()
        check:SetVertexColor(r, g, b)
        check:SetTexCoord(0, 1, 0, 1)
        check:SetInside()
        check:AddMaskTexture(insideMask)

        local highlight = button:GetHighlightTexture()
        highlight:SetTexCoord(0, 1, 0, 1)
        highlight:SetVertexColor(1, 1, 1)
        highlight:AddMaskTexture(insideMask)

        local normal = button:GetNormalTexture()
        normal:SetOutside()
        normal:SetTexCoord(0, 1, 0, 1)
        normal:SetVertexColor(unpack(C.media.border_color))
        normal:AddMaskTexture(outsideMask)

        local disabled = button:GetDisabledTexture()
        disabled:SetVertexColor(0.3, 0.3, 0.3)
        disabled:AddMaskTexture(outsideMask)

        hooksecurefunc(button, "SetNormalTexture", S.ClearNormalTexture)
        hooksecurefunc(button, "SetPushedTexture", S.ClearPushedTexture)
        hooksecurefunc(button, "SetDisabledTexture", S.ClearDisabledTexture)
        hooksecurefunc(button, "SetHighlightTexture", S.ClearHighlightTexture)

        button.__styled = true
    end
end

------------------------------------------------------------------------
-- HandleStepSlider — stepped slider (e.g. quality / quantity)
------------------------------------------------------------------------

function S:HandleStepSlider(frame, minimal)
    if not frame or frame:IsForbidden() then return end

    frame:StripTextures()

    local slider = frame.Slider
    if not slider then return end

    slider:DisableDrawLayer("ARTWORK")

    local thumb = slider.Thumb
    if thumb then
        thumb:SetTexture(C.media.texture.spark)
        thumb:SetBlendMode("ADD")
        thumb:SetSize(20, 30)
    end

    local offset = minimal and 10 or 13
    local bg = slider:CreateBackdrop()
    bg:ClearAllPoints()
    bg:SetPoint("TOPLEFT", slider, 10, -offset)
    bg:SetPoint("BOTTOMRIGHT", slider, -10, offset)

    if not slider.barStep then
        local step = CreateFrame("StatusBar", nil, bg)
        step:SetStatusBarTexture(C.media.texture.status)
        step:SetStatusBarColor(r, g, b, 0.5)
        step:SetPoint("TOPLEFT", bg, E.mult, -E.mult)
        step:SetPoint("BOTTOMLEFT", bg, E.mult, E.mult)
        step:SetPoint("RIGHT", thumb, "CENTER")
        slider.barStep = step
    end
end

------------------------------------------------------------------------
-- HandleCollapseTexture — +/- collapse header buttons
------------------------------------------------------------------------

do
    local function updateCollapseTexture(button, texture, skip)
        if skip or not texture then return end
        if issecretvalue and issecretvalue(texture) then return end

        if type(texture) == "number" then
            if texture == 130838 then -- UI-PlusButton-UP
                button:SetNormalTexture(C.media.texture.plus, true)
            elseif texture == 130821 then -- UI-MinusButton-UP
                button:SetNormalTexture(C.media.texture.minus, true)
            end
        elseif type(texture) == "string" then
            if strfind(texture, "Plus") or strfind(texture, "[cC]losed") then
                button:SetNormalTexture(C.media.texture.plus, true)
            elseif strfind(texture, "Minus") or strfind(texture, "[oO]pen") then
                button:SetNormalTexture(C.media.texture.minus, true)
            end
        end
    end

    local function syncPushTexture(button, _, skip)
        if skip then return end

        local normal = button:GetNormalTexture()
        local tex = normal and normal:GetTexture()
        if tex and not (issecretvalue and issecretvalue(tex)) then button:SetPushedTexture(tex, true) end
    end

    function S:HandleCollapseTexture(button, syncPushed, ignorePushed)
        if not button or button.collapsedSkinned then return end
        if button:IsForbidden() then return end
        button.collapsedSkinned = true

        if syncPushed then
            hooksecurefunc(button, "SetPushedTexture", syncPushTexture)
            syncPushTexture(button)
        elseif not ignorePushed then
            button:SetPushedTexture(E.ClearTexture)
        end

        hooksecurefunc(button, "SetNormalTexture", updateCollapseTexture)
        local normal = button:GetNormalTexture()
        updateCollapseTexture(button, normal and normal:GetTexture())
    end
end

------------------------------------------------------------------------
-- HandleModelSceneControlButtons — zoom/rotate/reset row
------------------------------------------------------------------------

do
    local layoutKeys = { "zoomInButton", "zoomOutButton", "rotateLeftButton", "rotateRightButton", "resetButton" }

    local function updateLayout(frame)
        local last
        for _, name in next, layoutKeys do
            local button = frame[name]
            if button then
                if not button.__styled then
                    S:HandleButton(button)
                    button:Size(22)
                    if button.Icon then button.Icon:SetInside(nil, 2, 2) end
                end

                if button:IsShown() then
                    button:ClearAllPoints()
                    if last then
                        button:Point("LEFT", last, "RIGHT", 1, 0)
                    else
                        button:Point("LEFT", 6, 0)
                    end
                    last = button
                end
            end
        end
    end

    function S:HandleModelSceneControlButtons(frame)
        if not frame or frame.__styled then return end
        if frame:IsForbidden() then return end
        frame.__styled = true

        hooksecurefunc(frame, "UpdateLayout", updateLayout)
    end
end

------------------------------------------------------------------------
-- HandleGarrisonPortrait — follower / troop portrait puck
------------------------------------------------------------------------

do
    local replacedRoleTex = {
        ["Adventures-Tank"] = "Soulbinds_Tree_Conduit_Icon_Protect",
        ["Adventures-Healer"] = "ui_adv_health",
        ["Adventures-DPS"] = "ui_adv_atk",
        ["Adventures-DPS-Ranged"] = "Soulbinds_Tree_Conduit_Icon_Utility",
    }

    local function handleFollowerRole(roleIcon, atlas)
        if issecretvalue and issecretvalue(atlas) then return end
        local newAtlas = replacedRoleTex[atlas]
        if newAtlas then roleIcon:SetAtlas(newAtlas) end
    end

    function S:HandleGarrisonPortrait(portrait, updateAtlas)
        if not portrait or portrait:IsForbidden() then return end

        local main = portrait.Portrait
        if not main then return end

        if not main.__backdrop then main:CreateBackdrop("Transparent") end

        local level = portrait.Level or portrait.LevelText
        if level then
            level:ClearAllPoints()
            level:Point("BOTTOM", portrait, 0, 15)
            level:FontTemplate(nil, 14, "OUTLINE")

            if portrait.LevelCircle then portrait.LevelCircle:Hide() end
            if portrait.LevelBorder then portrait.LevelBorder:SetScale(0.0001) end
        end

        if portrait.PortraitRing then
            portrait.PortraitRing:Hide()
            portrait.PortraitRingQuality:SetTexture(E.ClearTexture)
            portrait.PortraitRingCover:SetColorTexture(0, 0, 0)
            portrait.PortraitRingCover:SetAllPoints(main.__backdrop)
        end

        if portrait.Empty then
            portrait.Empty:SetColorTexture(0, 0, 0)
            portrait.Empty:SetAllPoints(main)
        end

        if portrait.Highlight then portrait.Highlight:Hide() end
        if portrait.PuckBorder then portrait.PuckBorder:SetAlpha(0) end
        if portrait.TroopStackBorder1 then portrait.TroopStackBorder1:SetAlpha(0) end
        if portrait.TroopStackBorder2 then portrait.TroopStackBorder2:SetAlpha(0) end

        if portrait.HealthBar then
            portrait.HealthBar.Border:Hide()

            local roleIcon = portrait.HealthBar.RoleIcon
            roleIcon:ClearAllPoints()
            roleIcon:Point("CENTER", main.__backdrop, "TOPRIGHT")

            if updateAtlas then
                handleFollowerRole(roleIcon, roleIcon:GetAtlas())
            else
                hooksecurefunc(roleIcon, "SetAtlas", handleFollowerRole)
            end

            local background = portrait.HealthBar.Background
            background:SetAlpha(0)
            background:SetInside(main.__backdrop, 2, 1)
            background:Point("TOPLEFT", main.__backdrop, "BOTTOMLEFT", 2, 7)
            portrait.HealthBar.Health:SetTexture(C.media.texture.blank)
        end
    end
end
