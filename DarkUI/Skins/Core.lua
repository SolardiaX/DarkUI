local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Skins Module — AuroraClassic-style per-frame skin engine
--
-- Ports under Skins/Frames/ are near-verbatim translations of AuroraClassic
-- (AddOns/*.lua + FrameXML/*.lua). They call this module's S:Reskin* methods
-- (Aurora's B:Reskin* set, self=S + explicit target frame) and the metatable
-- atoms from Core/API.lua (frame:CreateBackdrop / :StripTextures / :SetInside …).
-- The Aurora B:Reskin* primitives route to DarkUI's own engine (E:Reskin*/
-- E:Style*) + the qb quality-border system, so the look stays DarkUI (textured
-- backdrop + qb), not Aurora's flat fill. See Skins/SYNC.md for the recipe.
------------------------------------------------------------------------

local _G = _G
local pairs, ipairs, type, next, select = pairs, ipairs, type, next, select
local tinsert, wipe, strfind = tinsert, wipe, strfind
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local unpack = unpack
local rad = math.rad
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
-- S.DB — AuroraClassic constant map (Aurora DB.* names → DarkUI values)
-- Ports keep `local DB = S.DB` and reference DB.x with no per-symbol rewrite.
------------------------------------------------------------------------

S.DB = {
    bdTex = C.media.texture.blank,
    bgTex = C.media.texture.blank,
    normTex = C.media.texture.blank,
    glowTex = C.media.texture.blank,
    closeTex = C.media.texture.close,
    ArrowUp = C.media.texture.arrow,
    sparkTex = C.media.texture.spark,
    pushedTex = C.media.button and C.media.button.glow,
    TexCoord = C.media.texCoord,
    QualityColors = C.media.qualityColors,
    r = r,
    g = g,
    b = b,
}
local DB = S.DB

------------------------------------------------------------------------
-- Dispatch (per-addon callbacks fired on ADDON_LOADED; pcall-isolated)
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
-- Shared helpers
------------------------------------------------------------------------

-- hover handlers: recolor a control's backdrop border to theme gold on enter,
-- resting color on leave (ports hook these; Aurora's Texture_OnEnter/Leave).
function S.SetModifiedBackdrop(self)
    if self.IsEnabled and not self:IsEnabled() then return end
    local bd = self.backdrop or self
    if bd.SetBackdropBorderColor then bd:SetBackdropBorderColor(r, g, b) end
end

function S.SetOriginalBackdrop(self)
    local bd = self.backdrop or self
    if bd.SetBackdropBorderColor then bd:SetBackdropBorderColor(unpack(C.media.border_color)) end
end

-- texture's arrow points up by default; rotate per direction (Aurora SetupArrow)
local ARROW_DEGREE = { up = 0, down = 180, left = 90, right = -90 }
function S:SetupArrow(tex, direction)
    if not tex then return end
    tex:SetTexture(C.media.texture.arrow)
    tex:SetRotation(rad(ARROW_DEGREE[direction] or 0))
end

-- named Blizzard art regions, hidden in bulk (Aurora blizzRegions sweep)
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

function S:ReskinBlizzardRegions(frame, name, kill, zero)
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
-- Backdrop shorthand (Aurora SetBD/CreateBDFrame)
------------------------------------------------------------------------

-- Aurora SetBD: a textured backdrop frame (+ shadow) on a frame, with optional
-- inset points. Routes to our CreateBackdrop atom (textured) + CreateShadow.
function S:SetBD(frame, _, x, y, x2, y2)
    local bg = frame:CreateBackdrop()
    if x then
        bg:ClearAllPoints()
        bg:SetPoint("TOPLEFT", frame, x, y)
        bg:SetPoint("BOTTOMRIGHT", frame, x2, y2)
    end
    bg:CreateShadow()
    return bg
end

------------------------------------------------------------------------
-- Buttons (Aurora Reskin / ReskinFilterButton / ReskinMenuButton / ReskinClose)
------------------------------------------------------------------------

function S:Reskin(button, noHighlight, override)
    if not button then return end

    E:ReskinUIPanelButton(button, override)
    -- sweep leftover Blizzard art regions ReskinUIPanelButton's own list misses
    if button.__styled then S:ReskinBlizzardRegions(button) end

    if not noHighlight and button.HookScript then
        button:HookScript("OnEnter", S.SetModifiedBackdrop)
        button:HookScript("OnLeave", S.SetOriginalBackdrop)
    end

    -- Aurora compat: B.Reskin created a button-sized child frame at self.__bg; DarkUI
    -- templates the button in place, so the button itself is the backdrop anchor.
    button.__bg = button
end

function S:ReskinClose(button, parent, xOffset, yOffset) return E:StyleCloseButton(button, parent or (button.GetParent and button:GetParent())) end

function S:ReskinMenuButton(button)
    if not button then return end
    button:StripTextures()
    button.bg = button:CreateBackdrop()
    button:HookScript("OnEnter", S.SetModifiedBackdrop)
    button:HookScript("OnLeave", S.SetOriginalBackdrop)
end

-- Aurora ReskinFilterReset: small red X on the reset sub-button
function S:ReskinFilterReset(button)
    if not button then return end
    button:StripTextures()
    button:ClearAllPoints()
    button:SetPoint("TOPRIGHT", -5, 10)

    local tex = button:CreateTexture(nil, "ARTWORK")
    tex:SetInside(nil, 2, 2)
    tex:SetTexture(C.media.texture.close)
    tex:SetVertexColor(1, 0, 0)
end

-- Aurora ReskinFilterButton: filter dropdown styled as a button + right arrow
function S:ReskinFilterButton(button)
    if not button then return end
    button:StripTextures()
    S:Reskin(button)

    if button.Text then button.Text:SetPoint("CENTER") end
    if button.Icon then
        S:SetupArrow(button.Icon, "right")
        button.Icon:SetPoint("RIGHT")
        button.Icon:Size(14)
    end
    if button.ResetButton then S:ReskinFilterReset(button.ResetButton) end

    if not button.__filterArrow then
        local tex = button:CreateTexture(nil, "ARTWORK")
        S:SetupArrow(tex, "right")
        tex:Size(16)
        tex:Point("RIGHT", -2, 0)
        button.__filterArrow = tex
    end
end

------------------------------------------------------------------------
-- Routing facades (Aurora names → DarkUI engine)
------------------------------------------------------------------------

function S:ReskinTab(tab)
    E:ReskinTab(tab)
    if tab then tab.bg = tab.backdrop end -- Aurora ports reference tab.bg for active-tab tinting
    return tab and tab.backdrop
end
function S:ReskinScroll(frame) return E:ReskinScrollBar(frame) end
function S:ReskinTrimScroll(frame) return E:ReskinTrimScrollBar(frame) end
function S:ReskinStatusBar(bar) return E:ReskinStatusBar(bar) end
function S:ReskinSlider(frame) return E:ReskinSlider(frame) end
function S:ReskinCheck(frame)
    E:StyleCheckBox(frame)
    if frame then frame.bg = frame.backdrop end -- Aurora ports reference check.bg
    return frame and frame.backdrop
end
function S:ReskinNavBar(navBar) return E:ReskinNavBar(navBar) end
function S:ReskinDropDown(frame, width, template) return E:ReskinDropDown(frame, width or 155, template) end

function S:ReskinEditBox(frame)
    E:ReskinEditBox(frame)
    -- Aurora ports reposition the backdrop via editbox.__bg; DarkUI stores it at .backdrop
    if frame then frame.__bg = frame.backdrop end
    return frame and frame.backdrop
end
S.ReskinInput = S.ReskinEditBox -- Aurora alias

-- ElvUI-parity inset pieces hidden by portrait/frame skins
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

function S:ReskinInsetFrame(frame)
    if not frame then return end
    for _, piece in ipairs(INSET_PIECES) do
        if frame[piece] then frame[piece]:Hide() end
    end
end

local function handleFrameExtras(frame)
    local name = frame.GetName and frame:GetName()
    local inset = frame.Inset or (name and _G[name .. "Inset"])
    if inset then S:ReskinInsetFrame(inset) end

    if frame.CloseButton then E:StyleCloseButton(frame.CloseButton) end
end

function S:ReskinPortraitFrame(frame)
    if not frame then return end
    E:ReskinPortrait(frame)
    handleFrameExtras(frame)
    return frame.backdrop
end

function S:ReskinFrame(frame)
    if not frame then return end
    E:ReskinPanel(frame)
    handleFrameExtras(frame)
    return frame.backdrop
end

------------------------------------------------------------------------
-- Checkbox region iterator / inline-icon string rescale (port hooks)
------------------------------------------------------------------------

function S:ForEachCheckboxTextureRegion(checkbox, func)
    for _, region in next, { checkbox:GetRegions() } do
        if region:IsObjectType("Texture") then func(checkbox, region) end
    end
end

function S:ReplaceIconString(fontString)
    if not fontString then return end
    local text = fontString:GetText()
    if not text or text == "" then return end
    local newText, count = text:gsub("|T([^:]-):[%d+:]+|t", "|T%1:14:14:0:0:64:64:5:59:5:59|t")
    if count > 0 then fontString:SetFormattedText("%s", newText) end
end

------------------------------------------------------------------------
-- Icons (Aurora ReskinIcon / ClassIconTexCoord / CreateAndUpdateBarTicks)
------------------------------------------------------------------------

function S:ReskinIcon(icon, shadow)
    if not icon then return end
    return E:StyleIcon(icon, shadow)
end

local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
function S:ClassIconTexCoord(tex, class)
    local c = CLASS_ICON_TCOORDS[class]
    if c then tex:SetTexCoord(c[1] + 0.022, c[2] - 0.025, c[3] + 0.022, c[4] - 0.025) end
end

function S:CreateAndUpdateBarTicks(bar, ticks, numTicks)
    for i = 1, #ticks do
        ticks[i]:Hide()
    end

    if numTicks and numTicks > 0 then
        local width, height = bar:GetSize()
        local delta = width / numTicks
        for i = 1, numTicks - 1 do
            if not ticks[i] then
                ticks[i] = bar:CreateTexture(nil, "OVERLAY")
                ticks[i]:SetTexture(C.media.texture.blank)
                ticks[i]:SetVertexColor(0, 0, 0, 0.7)
                ticks[i]:SetWidth(E.mult)
                ticks[i]:SetHeight(height)
            end
            ticks[i]:ClearAllPoints()
            ticks[i]:SetPoint("RIGHT", bar, "LEFT", delta * i, 0)
            ticks[i]:Show()
        end
    end
end

------------------------------------------------------------------------
-- ReskinItemButton — item slot button (icon + backdrop + qb quality border)
-- DarkUI enhancement (no direct Aurora equivalent; Aurora uses ReskinIcon +
-- ReskinIconBorder per slot). Use for full item slots that carry IconBorder.
------------------------------------------------------------------------

function S:ReskinItemButton(b, setInside, ignoreParent)
    if not b or b.__styled then return end
    if b:IsForbidden() then return end

    local name = b:GetName()
    local icon = b.icon or b.Icon or b.IconTexture or b.iconTexture or (name and (_G[name .. "IconTexture"] or _G[name .. "Icon"]))

    if b.SlotBackground then b.SlotBackground:Hide() end
    if b.IconMask then b.IconMask:Hide() end
    if b.NewActionTexture then b.NewActionTexture:SetTexture("") end

    -- backdrop: grey gloss base only (frameLevel -1, behind); qb covers the edge
    b:CreateBackdrop("Button", 1)

    if icon then
        icon:SetTexCoords()
        if setInside then
            icon:SetInside(b)
        else
            -- wrap the backdrop around the icon at native size (don't balloon it)
            b.backdrop:SetOutside(icon, 1, 1)
        end
        if not ignoreParent then icon:SetParent(b) end
    end

    if b.SetNormalTexture then
        b:SetNormalTexture(C.media.button.normal)
        local nt = b:GetNormalTexture()
        if nt then
            nt:SetVertexColor(0.5, 0.5, 0.5, 0.6)
            nt:SetAllPoints(b)
        end
    end

    if b.SetPushedTexture and not b.pushed then
        b:SetPushedTexture(C.media.button.glow)
        local pt = b:GetPushedTexture()
        if pt then
            pt:SetOutside(b, 2, 2)
            b.pushed = pt
        end
    end

    if b.SetHighlightTexture and not b.hover then
        b:SetHighlightTexture(C.media.texture.blank)
        local hl = b:GetHighlightTexture()
        if hl then
            hl:SetColorTexture(1, 1, 1, 0.25)
            hl:SetAllPoints(b)
            b.hover = hl
        end
    end

    if b.SetCheckedTexture and not b.checked then
        b:SetCheckedTexture(C.media.texture.blank)
        local ct = b:GetCheckedTexture()
        if ct then
            ct:SetColorTexture(1, 0.8, 0, 0.35)
            ct:SetAllPoints(b)
            b.checked = ct
        end
    end

    if b.IconBorder then S:ReskinIconBorder(b.IconBorder) end

    b.__styled = true
end

------------------------------------------------------------------------
-- ReskinIconBorder — item-quality color onto a textured qb border frame drawn
-- above the icon. Pass needInit to color from the current atlas/vertex now.
-- (secret-safe: GetAtlas/GetVertexColor may return secrets on protected buttons)
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

    local function atlasQuality(atlas)
        if not atlas or (issecretvalue and issecretvalue(atlas)) then return nil end
        return iconColors[atlas]
    end

    local function colorAtlas(border, atlas)
        local quality = atlasQuality(atlas)
        if not quality then return end

        local backdrop = border.customBackdrop
        if not backdrop then return end

        local q = C.media.qualityColors[quality]
        if q then backdrop:SetBackdropBorderColor(q.r, q.g, q.b, 1) end
    end

    local function colorVertex(border, r, g, b)
        if atlasQuality(border.GetAtlas and border:GetAtlas()) then return end

        local backdrop = border.customBackdrop
        if not backdrop then return end

        backdrop:SetBackdropBorderColor(r, g, b)
    end

    local function borderHide(border, value)
        if value == 0 then return end

        local backdrop = border.customBackdrop
        if not backdrop then return end

        backdrop:SetBackdropBorderColor(unpack(C.media.border_color))
    end

    local function borderShow(border) border:Hide(0) end

    local function borderShown(border, show)
        if show then
            border:Hide(0)
        else
            borderHide(border)
        end
    end

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

    -- Aurora signature: ReskinIconBorder(border, needInit, useAtlas). needInit
    -- forces an initial color now; useAtlas/backdrop kept for call-site parity.
    function S:ReskinIconBorder(border, needInit, backdrop)
        if not border or border:IsForbidden() then return end

        local qb = qualityBorder(border)
        if type(backdrop) == "table" and backdrop.SetBackdropBorderColor then qb:SetOutside(backdrop, 0, 0) end
        border.customBackdrop = qb

        local quality = atlasQuality(border.GetAtlas and border:GetAtlas())
        local q = quality and C.media.qualityColors[quality]
        if q then
            qb:SetBackdropBorderColor(q.r, q.g, q.b, 1)
        else
            local cr, cg, cb, ca = border:GetVertexColor()
            if cr ~= nil and not (issecretvalue and issecretvalue(cr)) then
                qb:SetBackdropBorderColor(cr, cg, cb, ca)
            else
                qb:SetBackdropBorderColor(unpack(C.media.border_color))
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

        return qb
    end
end

------------------------------------------------------------------------
-- ReskinArrow / ReskinNextPrevButton — arrow paging button
-- (secret-safe: GetDebugName may return a secret on protected buttons)
------------------------------------------------------------------------

function S:ReskinNextPrevButton(btn, arrowDir, color, noBackdrop, stripTexts)
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

-- Aurora ReskinArrow(button, direction): paging/scroll arrow with explicit dir
function S:ReskinArrow(button, direction) return S:ReskinNextPrevButton(button, direction) end

------------------------------------------------------------------------
-- ReskinColorSwatch (Aurora)
------------------------------------------------------------------------

function S:ReskinColorSwatch(button)
    if not button then return end
    local name = button.GetName and button:GetName()
    local swatchBg = name and _G[name .. "SwatchBg"]
    if swatchBg then
        swatchBg:SetColorTexture(0, 0, 0)
        swatchBg:SetInside(nil, 2, 2)
    end

    button:SetNormalTexture(C.media.texture.blank)
    button:GetNormalTexture():SetInside(button, 3, 3)
end

------------------------------------------------------------------------
-- ReskinSmallRole / ReskinRole (Aurora group-role icons)
------------------------------------------------------------------------

local GroupRoleTex = {
    TANK = "groupfinder-icon-role-micro-tank",
    HEALER = "groupfinder-icon-role-micro-heal",
    DAMAGER = "groupfinder-icon-role-micro-dps",
    DPS = "groupfinder-icon-role-micro-dps",
}

function S:ReskinSmallRole(tex, role)
    tex:SetTexCoord(0, 1, 0, 1)
    tex:SetAtlas(GroupRoleTex[role])
end

function S:ReskinRole(frame)
    if frame.background then frame.background:SetTexture("") end

    local cover = frame.cover or frame.Cover
    if cover then cover:SetTexture("") end

    local checkButton = frame.checkButton or frame.CheckButton or frame.CheckBox or frame.Checkbox
    if checkButton then
        checkButton:SetFrameLevel(frame:GetFrameLevel() + 2)
        checkButton:SetPoint("BOTTOMLEFT", -2, -2)
        S:ReskinCheck(checkButton)
    end
end

------------------------------------------------------------------------
-- StyleSearchButton / AffixesSetup (Aurora)
------------------------------------------------------------------------

function S:StyleSearchButton(button)
    if not button then return end
    button:StripTextures()
    local bg = button:CreateBackdrop()
    bg:SetInside()

    local icon = button.icon or button.Icon
    if icon then S:ReskinIcon(icon) end

    button:SetHighlightTexture(C.media.texture.blank)
    local hl = button:GetHighlightTexture()
    hl:SetVertexColor(r, g, b, 0.25)
    hl:SetInside(bg)
end

function S:AffixesSetup(frame)
    local list = (frame.AffixesContainer and frame.AffixesContainer.Affixes) or frame.Affixes
    if not list then return end

    for _, f in ipairs(list) do
        f.Border:SetTexture(nil)
        f.Portrait:SetTexture(nil)
        if not f.bg then f.bg = S:ReskinIcon(f.Portrait) end

        if f.info then
            f.Portrait:SetTexture(CHALLENGE_MODE_EXTRA_AFFIX_INFO[f.info.key].texture)
        elseif f.affixID then
            local _, _, filedataid = C_ChallengeMode.GetAffixInfo(f.affixID)
            f.Portrait:SetTexture(filedataid)
        end
    end
end

------------------------------------------------------------------------
-- HandleIconSelectionFrame — icon picker popup (icon grid + controls)
------------------------------------------------------------------------

local function skinIconSelectorButton(button, i, buttonNameTemplate)
    local icon = button.Icon or (buttonNameTemplate and i and _G[buttonNameTemplate .. i .. "Icon"])
    local texture
    if icon then
        icon:SetTexCoords()
        icon:SetInside(button)
        texture = icon:GetTexture()
    end

    button:StripTextures()
    button:SetTemplate()
    button:StyleButton(nil, true)

    if texture then icon:SetTexture(texture) end
end

local function selectionOffset(frame)
    local point, anchor, relativePoint, xOffset = frame:GetPoint()
    if not point or xOffset > 0 then return end

    local x = frame.BorderBox and 8 or 40
    local y = frame.BorderBox and 4 or -10
    frame:ClearAllPoints()
    frame:Point(point, (frame == _G.MacroPopupFrame and _G.MacroFrame) or anchor, relativePoint, strfind(point, "LEFT") and x or -x, y)
end

function S:ReskinIconSelectionFrame(frame, _, _, nameOverride, dontOffset)
    if not frame or frame.__styled then return end

    if not dontOffset then
        frame:HookScript("OnShow", selectionOffset)
        frame:Height(frame:GetHeight() + 10)
        if frame:IsShown() then selectionOffset(frame) end
    end

    local borderBox = frame.BorderBox or _G.BorderBox
    local frameName = nameOverride or frame:GetName()
    local editBox = (borderBox and borderBox.IconSelectorEditBox) or frame.EditBox or (frameName and _G[frameName .. "EditBox"])
    local cancel = frame.CancelButton or (borderBox and borderBox.CancelButton) or (frameName and _G[frameName .. "Cancel"])
    local okay = frame.OkayButton or (borderBox and borderBox.OkayButton) or (frameName and _G[frameName .. "Okay"])

    frame:StripTextures()
    E:ReskinPanel(frame)

    if borderBox then
        borderBox:StripTextures()

        local dropdown = borderBox.IconTypeDropdown
        if dropdown then S:ReskinDropDown(dropdown) end

        local button = borderBox.SelectedIconArea and borderBox.SelectedIconArea.SelectedIconButton
        if button then
            button:DisableDrawLayer("BACKGROUND")
            skinIconSelectorButton(button)
        end
    end

    if cancel then
        cancel:ClearAllPoints()
        cancel:SetPoint("BOTTOMRIGHT", frame, -4, 4)
        S:Reskin(cancel)
    end
    if okay then
        okay:ClearAllPoints()
        okay:SetPoint("RIGHT", cancel or okay, "LEFT", -10, 0)
        S:Reskin(okay)
    end
    if editBox then
        editBox:DisableDrawLayer("BACKGROUND")
        S:ReskinEditBox(editBox)
    end

    local iconSelector = frame.IconSelector
    if iconSelector then
        if iconSelector.ScrollBar then S:ReskinTrimScroll(iconSelector.ScrollBar) end
        -- Skin grid buttons as the ScrollBox lays them out. A one-shot ForEachFrame
        -- at load would crash on an un-populated box (ScrollBox has no view yet) and
        -- also miss buttons realized later, so hook Update like Aurora does.
        if iconSelector.ScrollBox then
            hooksecurefunc(iconSelector.ScrollBox, "Update", function(box)
                local target = box.ScrollTarget
                if not target then return end
                for i = 1, target:GetNumChildren() do
                    local child = select(i, target:GetChildren())
                    if child and child.Icon and not child.__styled then
                        child:DisableDrawLayer("BACKGROUND")
                        skinIconSelectorButton(child)
                        child.__styled = true
                    end
                end
            end)
        end
    end

    frame.__styled = true
end

------------------------------------------------------------------------
-- OverlayButton — floating templated overlay over an un-templatable button
------------------------------------------------------------------------

do
    local overlays = {}

    local function overlayHide(button)
        local overlay = overlays[button]
        if overlay then overlay:Hide() end
    end

    local function overlayShow(button)
        local overlay = overlays[button]
        if not overlay then return end
        overlay:ClearAllPoints()
        overlay:SetPoint(button:GetPoint())
        overlay:Show()
    end

    local function overlayOnEnter(button)
        local overlay = overlays[button]
        if not overlay then return end
        overlay.text:SetTextColor(1, 1, 1)
        overlay:SetBackdropBorderColor(r, g, b)
    end

    local function overlayOnLeave(button)
        local overlay = overlays[button]
        if not overlay then return end
        overlay.text:SetTextColor(1, 0.81, 0)
        overlay:SetBackdropBorderColor(unpack(C.media.border_color))
    end

    function S:OverlayButton(button, name, width, height, text, textLayer, level, strata)
        if overlays[button] then return end

        local overlay = CreateFrame("Frame", "DarkUI_OverlayButton_" .. name, _G.UIParent)
        overlay:Size(width or 120, height or 22)
        overlay:SetTemplate()
        overlay:SetPoint(button:GetPoint())
        overlay:SetFrameLevel(level or 10)
        overlay:SetFrameStrata(strata or "MEDIUM")
        overlay:Hide()

        local txt = overlay:CreateFontString(nil, textLayer or "OVERLAY")
        if txt then
            txt:FontTemplate()
            txt:SetPoint("CENTER")
            txt:SetTextColor(1, 0.81, 0)
            txt:SetText(text)
            overlay.text = txt

            button:HookScript("OnEnter", overlayOnEnter)
            button:HookScript("OnLeave", overlayOnLeave)
        end

        button:HookScript("OnHide", overlayHide)
        button:HookScript("OnShow", overlayShow)

        overlays[button] = overlay
    end
end

------------------------------------------------------------------------
-- SkinReadyDialog — LFG / PVP ready-check dialog
------------------------------------------------------------------------

function S:SkinReadyDialog(dialog, bottom)
    local background = dialog.background
    if background then
        background:ClearAllPoints()
        background:Point("TOPLEFT", E.mult, -E.mult)
        background:Point("BOTTOMRIGHT", -E.mult, bottom or 50)

        dialog:CreateBackdrop("Transparent")
        dialog.backdrop:SetOutside(background)
    end

    if dialog.bottomArt then dialog.bottomArt:SetAlpha(0) end

    if dialog.Border then
        dialog.Border:StripTextures()
        dialog.Border:CreateBackdrop("Transparent")
        dialog.Border.backdrop:SetAllPoints()
    end

    local instance = dialog.instanceInfo
    if instance and instance.underline then instance.underline:SetAlpha(0) end

    if dialog.enterButton then
        S:Reskin(dialog.enterButton)
        dialog.enterButton:ClearAllPoints()
        dialog.enterButton:Point("BOTTOMRIGHT", dialog, "BOTTOM", -10, 15)
    end

    if dialog.leaveButton then
        S:Reskin(dialog.leaveButton)
        dialog.leaveButton:ClearAllPoints()
        dialog.leaveButton:Point("BOTTOMLEFT", dialog, "BOTTOM", 10, 15)
    end
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
-- ReskinRotateButton — model rotate buttons (atlas arrows)
------------------------------------------------------------------------

function S:ReskinRotateButton(button, width, height, noSize)
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
-- ReskinMinMax — maximize / minimize buttons (rotated arrows)
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

    function S:ReskinMinMax(frame)
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
-- ReskinRadio — masked radio dot
------------------------------------------------------------------------

do
    local maskBackground = [[Interface\Minimap\UI-Minimap-Background]]

    function S:ReskinRadio(button)
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
-- ReskinStepperSlider — stepped slider (e.g. quality / quantity)
------------------------------------------------------------------------

function S:ReskinStepperSlider(frame, minimal)
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
-- ReskinCollapse — +/- collapse header buttons (Aurora ReskinCollapse(isAtlas))
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

    local function updateCollapseAtlas(button, atlas, skip)
        if skip or not atlas then return end
        if issecretvalue and issecretvalue(atlas) then return end
        if strfind(atlas, "Plus") or strfind(atlas, "[cC]losed") or strfind(atlas, "[eE]xpand") then
            button:SetNormalTexture(C.media.texture.plus, true)
        elseif strfind(atlas, "Minus") or strfind(atlas, "[oO]pen") or strfind(atlas, "[cC]ollapse") then
            button:SetNormalTexture(C.media.texture.minus, true)
        end
    end

    local function syncPushTexture(button, _, skip)
        if skip then return end

        local normal = button:GetNormalTexture()
        local tex = normal and normal:GetTexture()
        if tex and not (issecretvalue and issecretvalue(tex)) then button:SetPushedTexture(tex, true) end
    end

    function S:ReskinCollapse(button, isAtlas, syncPushed, ignorePushed)
        if not button or button.collapsedSkinned then return end
        if button:IsForbidden() then return end
        button.collapsedSkinned = true

        if syncPushed then
            hooksecurefunc(button, "SetPushedTexture", syncPushTexture)
            syncPushTexture(button)
        elseif not ignorePushed then
            button:SetPushedTexture(E.ClearTexture)
        end

        if isAtlas then
            hooksecurefunc(button, "SetNormalAtlas", updateCollapseAtlas)
            local normal = button:GetNormalTexture()
            updateCollapseAtlas(button, normal and normal:GetAtlas())
        else
            hooksecurefunc(button, "SetNormalTexture", updateCollapseTexture)
            local normal = button:GetNormalTexture()
            updateCollapseTexture(button, normal and normal:GetTexture())
        end
    end
end

------------------------------------------------------------------------
-- ReskinModelControl — hide a ModelScene ControlFrame's button textures
------------------------------------------------------------------------

function S:ReskinModelControl(modelScene)
    if not modelScene or not modelScene.ControlFrame then return end
    for i = 1, 5 do
        local button = select(i, modelScene.ControlFrame:GetChildren())
        if button and button.NormalTexture then
            button.NormalTexture:SetAlpha(0)
            button.PushedTexture:SetAlpha(0)
        end
    end
end

------------------------------------------------------------------------
-- ReskinModelSceneControlButtons — zoom/rotate/reset row (DarkUI extra)
------------------------------------------------------------------------

do
    local layoutKeys = { "zoomInButton", "zoomOutButton", "rotateLeftButton", "rotateRightButton", "resetButton" }

    local function updateLayout(frame)
        local last
        for _, name in next, layoutKeys do
            local button = frame[name]
            if button then
                if not button.__styled then
                    S:Reskin(button)
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

    function S:ReskinModelSceneControlButtons(frame)
        if not frame or frame.__styled then return end
        if frame:IsForbidden() then return end
        frame.__styled = true

        hooksecurefunc(frame, "UpdateLayout", updateLayout)
    end
end

------------------------------------------------------------------------
-- ReskinGarrisonPortrait — follower / troop portrait puck
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

    function S:ReskinGarrisonPortrait(portrait, updateAtlas)
        if not portrait or portrait:IsForbidden() then return end

        local main = portrait.Portrait
        if not main then return end

        if not main.backdrop then main:CreateBackdrop("Transparent") end

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
            portrait.PortraitRingCover:SetAllPoints(main.backdrop)
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
            roleIcon:Point("CENTER", main.backdrop, "TOPRIGHT")

            if updateAtlas then
                handleFollowerRole(roleIcon, roleIcon:GetAtlas())
            else
                hooksecurefunc(roleIcon, "SetAtlas", handleFollowerRole)
            end

            local background = portrait.HealthBar.Background
            background:SetAlpha(0)
            background:SetInside(main.backdrop, 2, 1)
            background:Point("TOPLEFT", main.backdrop, "BOTTOMLEFT", 2, 7)
            portrait.HealthBar.Health:SetTexture(C.media.texture.blank)
        end
    end
end
