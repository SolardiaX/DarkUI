local E, C, L = select(2, ...):unpack()

local styles = {
    backdrop = { 
        bgFile = "Interface\\Collections\\CollectionsBackgroundTile",
        edgeFile = "Interface\\Tooltips\\ChatBubble-Backdrop",
        tile = 1,
        tileSize = 16, 
        edgeSize = 16,
        insets = { left = 2, right = 2, top = 2, bottom = 2 } 
    },

    backdropColor =  { 0.1, 0.1, 0.2, 1 },
    backdropBorderColor = { 0.3, 0.3, 0.4, 1 },

    -- backdrop = {
    --     bgFile   = C.media.texture.blank,
    --     edgeFile = C.media.texture.border,
    --     tile     = false,
    --     tileEdge = true,
    --     tileSize = 16,
    --     edgeSize = 12,
    --     insets   = { left = 2, right = 2, top = 2, bottom = 2 },
    -- },
    
    -- backdropColor =  C.media.backdrop_color, -- {0.08, 0.08, 0.1, 0.92}, -- { 0.1, 0.1, 0.2, .75 },
    -- backdropBorderColor = C.media.border_color, -- { 0, 0, 0, 1 }, -- { 0.3, 0.3, 0.4, .75 },

    gradientColor = C.media.gradient_color, -- { 0.8, 0.8, 0.8, 0.15 }
}

function E:ApplyBackdrop(frame, gradient)
    if frame.styled then return end

    if frame and not frame:IsForbidden() then
        frame:CreateBackdrop()

        frame.backdrop:SetBackdrop(styles.backdrop)
        frame.backdrop:SetBackdropColor(unpack(styles.backdropColor))
        frame.backdrop:SetBackdropBorderColor(unpack(styles.backdropBorderColor))
        frame.backdrop:CreateShadow()

        if gradient then
            frame.gradient = frame:CreateTexture()
            frame.gradient:SetTexture(C.media.texture.gradient)
            frame.gradient:SetVertexColor(unpack(styles.gradientColor))
        end
    end

    frame.styled = true
end

function E:SkinCheckBox(frame)
    local lvl = frame:GetFrameLevel()

    frame:SetNormalTexture("")
    frame:SetPushedTexture("")
    frame:SetHighlightTexture(C.media.texture.status)

    frame.bg = CreateFrame("Frame", nil, frame)
    frame.bg:SetInside(frame, 4, 4)
    frame.bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
    frame.bg:SetTemplate("Blur")

    frame.hl = frame:GetHighlightTexture()
    frame.hl:SetInside(frame.bg)
    frame.hl:SetVertexColor(E.myColor.r, E.myColor.g, E.myColor.b, .2)

    frame.ch = frame:GetCheckedTexture()
    frame.ch:SetAtlas("checkmark-minimal")
    frame.ch:SetDesaturated(true)
    frame.ch:SetTexCoord(0, 1, 0, 1)
    frame.ch:SetVertexColor(E.myColor.r, E.myColor.g, E.myColor.b)
end

function E:SkinCharButton(f, point, text)
    f:StripTextures()
    f:SetSize(18, 18)
    f:SetTemplate("Overlay")

    -- E:StyleIcon(f)
    E:StyleButton(f)

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

    f:HookScript("OnEnter", function(self)
        if self:IsEnabled() then
            self:SetBackdropBorderColor(E.myColor.r, E.myColor.g, E.myColor.b)
            self.border:SetVertexColor(E.myColor.r * 0.3, E.myColor.g * 0.3, E.myColor.b * 0.3, 1)
        end
    
    end)
    f:HookScript("OnLeave", function(self)
        self:SetBackdropBorderColor(unpack(C.media.border_color))
        self.border:SetVertexColor(0.1, 0.1, 0.1, 1)
    end)
end

function E:SkinCloseButton(f, point)
    if point then
        f:SetPoint("TOPRIGHT", point, "TOPRIGHT", -2, -2)
    end

    if f.SetDisabledTexture then
        f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Disabled")
    end

    if f.SetNormalTexture then
        f:SetNormalTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Up")
    end

    if f.SetPushedTexture then
        f:SetPushedTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Down")
    end

    if f.SetHighlightTexture then
        f:SetHighlightTexture("Interface\\Buttons\\UI-Panel-MinimizeButton-Highlight", "ADD")
    end
end

function E:ApplyOverlayBorder(f, margin)
    margin = margin or E.mult

    local border
    local fn = f:GetName()

    if fn ~= nil then
        border = _G[fn .. "Border"] or f:CreateTexture(fn .. "Border", "BACKGROUND", nil, -7)
    else
        border = f:CreateTexture(nil, "BACKGROUND", nil, -7)
    end

    border:SetTexture(C.media.texture.overlay)
    border:SetTexCoord(0, 1, 0, 1)
    border:SetDrawLayer("BACKGROUND", -7)
    border:ClearAllPoints()
    border:SetPoint("TOPRIGHT", f, margin, margin)
    border:SetPoint("BOTTOMLEFT", f, -margin, -margin)

    f.border = border

    f:CreateShadow()
end

----------------------------------------------------------------------------------------
--  Normal Button Style Methods
----------------------------------------------------------------------------------------
function E:StyleButton(button, margin)
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetOutside(button, margin, margin)
    overlay:SetTexture(C.media.texture.overlay)
    button.overlay = overlay

    if button.NormalTexture then
        button.NormalTexture:SetAlpha(0)
    end

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

	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:SetInside(button, margin, margin)
	end
end

----------------------------------------------------------------------------------------
--  ActionButton Style Methods
----------------------------------------------------------------------------------------
local hooksecurefunc = hooksecurefunc
local unpack, pairs, gsub = unpack, pairs, gsub
local RANGE_INDICATOR = RANGE_INDICATOR
local KEY_BUTTON3, KEY_BUTTON4, KEY_SPACE, KEY_NUMPAD1 = KEY_BUTTON3, KEY_BUTTON4, KEY_SPACE, KEY_NUMPAD1
local KEY_MOUSEWHEELUP, KEY_MOUSEWHEELDOWN = KEY_MOUSEWHEELUP, KEY_MOUSEWHEELDOWN

local style = {
    icon = {
        texCoord = { 0.1, 0.9, 0.1, 0.9 },
        points   = {
            { "TOPLEFT", 1, -1 },
            { "BOTTOMRIGHT", -1, 1 }
        }
    },
    border = {
        file   = C.media.button.border,
        points = {
            { "TOPLEFT", -2, 2 },
            { "BOTTOMRIGHT", 2, -2 }
        }
    },    
    flash = { 
        file = C.media.button.flash,
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    normalTexture = {
        file   = C.media.button.normal,
        color  = { 0.5, 0.5, 0.5, 0.6 },
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    pushedTexture = {
        file = C.media.button.glow,
        -- color = { 0.9, 0.8, 0.1, 0.3 },
        points = {
            { "TOPLEFT", -2, 2 },
            { "BOTTOMRIGHT", 2, -2 }
        }
    },
    checkedTexture = { 
        file = "",
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    highlightTexture = {
        file   = "",
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    hotkey = {
        font   = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
        points = {
            { "TOPRIGHT", 0, 0 },
            { "TOPLEFT", 0, 0 }
        }
    },
    count = {
        font   = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
        points = {
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    name = {
        font   = { STANDARD_TEXT_FONT, 10, "OUTLINE" },
        points = {
            { "BOTTOMLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    cooldown = {
        font   = { STANDARD_TEXT_FONT, 16, "OUTLINE" },
        points = {
            { "TOPLEFT", 0, 0 },
            { "BOTTOMRIGHT", 0, 0 }
        }
    },
    backdrop = {
        bgFile          = C.media.button.buttonback,
        edgeFile        = C.media.button.outer_shadow,
        tile            = false,
        tileSize        = 16,
        edgeSize        = 2,
        insets          = { left = 2, right = 2, top = 2, bottom = 2 },
        backgroundColor = C.media.backdrop_color,
        borderColor     = C.media.border_color,
        points          = {
            { "TOPLEFT", -2, 2 },
            { "BOTTOMRIGHT", 2, -2 }
        }
    }    
}

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
    {"("..keyButton..")", "M"},
    {"("..keyNumpad..")", "N"},
    {"(a%-)", "a"},
    {"(c%-)", "c"},
    {"(s%-)", "s"},
    {KEY_BUTTON3, "M3"},
    {KEY_MOUSEWHEELUP, "MU"},
    {KEY_MOUSEWHEELDOWN, "MD"},
    {KEY_SPACE, "Sp"},
    {"CAPSLOCK", "CL"},
    {"BUTTON", "M"},
    {"NUMPAD", "N"},
    {"(ALT%-)", "a"},
    {"(CTRL%-)", "c"},
    {"(SHIFT%-)", "s"},
    {"MOUSEWHEELUP", "MU"},
    {"MOUSEWHEELDOWN", "MD"},
    {"SPACE", "Sp"},
}

local function updateHotKey(hotkey)
    local text = hotkey:GetText()
    if not text then return end

    if text == RANGE_INDICATOR then
        text = ""
    else
        for _, value in pairs(replaces) do
            text = gsub(text, value[1], value[2])
        end
    end

    hotkey:SetFormattedText("%s", text)
end

local function CallButtonFunctionByName(button, func, ...)
    if button and func and button[func] then button[func](button, ...) end
end

local function ApplyPoints(self, points)
    if not points then return end

    self:ClearAllPoints()
    for _, point in next, points do self:SetPoint(unpack(point)) end
end

local function ApplyTexCoord(texture, texCoord)
    if texture.__lockdown or not texCoord then return end

    texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
    if not color then return end

    texture:SetVertexColor(unpack(color))
end

local function ApplyAlpha(region, alpha)
    if not alpha then return end

    region:SetAlpha(alpha)
end

local function ApplyFont(fontString, font)
    if not font then return end

    fontString:SetFont(unpack(font))
end

local function ApplyHorizontalAlign(fontString, align)
    if not align then return end
    fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
    if not align then return end
    fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
    if not file then return end

    texture:SetTexture(file)
end

local function ApplyNormalTexture(button, file)
    if not file then return end

    button:SetNormalTexture(file)
end

local function SetupTexture(texture, cfg, func, button)
    if not texture or not cfg then return end

    ApplyTexCoord(texture, cfg.texCoord)
    ApplyPoints(texture, cfg.points)
    ApplyVertexColor(texture, cfg.color)
    ApplyAlpha(texture, cfg.alpha)
    if func == "SetTexture" then
        ApplyTexture(texture, cfg.file)
    elseif func == "SetNormalTexture" then
        ApplyNormalTexture(button, cfg.file)
    elseif cfg.file then
        CallButtonFunctionByName(button, func, cfg.file)
    end
end

local function SetupFontString(fontString, cfg)
    if not fontString or not cfg then return end

    ApplyPoints(fontString, cfg.points)
    ApplyFont(fontString, cfg.font)
    ApplyAlpha(fontString, cfg.alpha)
    ApplyHorizontalAlign(fontString, cfg.halign)
    ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
    if not cooldown or not cfg then return end

    ApplyPoints(cooldown, cfg.points)
end

local function SetupBackdrop(button, backdrop)
    if not backdrop or button.backdrop then return end

    button:CreateBackdrop("Transparent")

    local bg = button.backdrop
    ApplyPoints(bg, backdrop.points)

    bg:SetFrameLevel(button:GetFrameLevel() - 1)
    bg:SetBackdrop(backdrop)
    
    if backdrop.backgroundColor then
        bg:SetBackdropColor(unpack(backdrop.backgroundColor))
    end
    if backdrop.borderColor then
        bg:SetBackdropBorderColor(unpack(backdrop.borderColor))
    end
end

function E:StyleActionButton(button, force)
    if not button then return end
    if button.__styled and not force then return end

    local buttonName = button:GetName()
    local icon = button.icon or _G[buttonName.."Icon"]
    local cooldown = button.cooldown or _G[buttonName.."Cooldown"]
    local hotkey = button.HotKey or _G[buttonName.."HotKey"]
    local count = button.Count or _G[buttonName.."Count"]
    local name = button.Name or _G[buttonName.."Name"]
    local flash = button.Flash or _G[buttonName.."Flash"]
    local border = button.Border or _G[buttonName.."Border"]
    local autoCastable = button.AutoCastable or _G[buttonName.."AutoCastable"]
    local cooldown = button.cooldown or _G[buttonName.."Cooldown"]
    local normal = button.NormalTexture or button:GetNormalTexture()
    local pushed = button.PushedTexture or button:GetPushedTexture()
    local checked = button.CheckedTexture or (button.GetCheckedTexture and button:GetCheckedTexture() or nil)
    local highlight = button.HighlightTexture or button:GetHighlightTexture()
    local newActionTexture = button.NewActionTexture
    local spellHighlight = button.SpellHighlightTexture
    local slotbg = button.SlotBackground
    local iconMask = button.IconMask
    local petShine = _G[buttonName.."Shine"]

    -- if normal then normal:SetAlpha(0) end
    if border then border:SetTexture("") end
    if flash then flash:SetTexture("") end
    if newActionTexture then newActionTexture:SetTexture("") end
    if slotbg then slotbg:Hide() end
    if iconMask then iconMask:Hide() end
    if petShine then petShine:SetInside() end
    if spellHighlight then spellHighlight:SetOutside() end
    if autoCastable then
        autoCastable:SetTexCoord(.217, .765, .217, .765)
        autoCastable:SetInside()
    end

    --backdrop
    SetupBackdrop(button, style.backdrop)

    --cooldown
    SetupCooldown(cooldown, style.cooldown)

    SetupTexture(icon, style.icon, "SetTexture", icon)
    SetupTexture(flash, style.flash, "SetTexture", flash)
    SetupTexture(border, style.border, "SetTexture", border)
    SetupTexture(normal, style.normalTexture, "SetNormalTexture", button)
    SetupTexture(pushed, style.pushedTexture, "SetPushedTexture", button)
    SetupTexture(highlight, style.highlightTexture, "SetHighlightTexture", button)
    SetupTexture(checked, style.checkedTexture, "SetCheckedTexture", button)
    
    if checked then
        checked:SetColorTexture(1, .8, 0, .35)
    end
    if highlight then
        highlight:SetColorTexture(1, 1, 1, .25)
    end
    if spellHighlight then
        spellHighlight:SetOutside()
    end

    --hotkey+count+name
    SetupFontString(hotkey, style.hotkey)
    SetupFontString(count, style.count)
    SetupFontString(name, style.name)

    if hotkey then
        updateHotKey(hotkey)
        hooksecurefunc(hotkey, "SetText", updateHotKey)
    end

    button.__styled = true
end
