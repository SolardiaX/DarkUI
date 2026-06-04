local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Style — DarkUI component styling
------------------------------------------------------------------------

------------------------------------------------------------------------
-- ApplyBackdrop — full styled panel (bg + shadow + optional gradient)
------------------------------------------------------------------------

function E:ApplyBackdrop(frame, gradient)
	if frame.__styled then
		return
	end
	if not frame or frame:IsForbidden() then
		return
	end

	local bg = frame:CreateBG()
	bg:CreateShadow()

	if gradient then
		frame:CreateGradient()
	end

	frame.__styled = true
end

------------------------------------------------------------------------
-- ReskinIcon — texCoord + bg frame on existing icon texture
------------------------------------------------------------------------

function E:ReskinIcon(icon, shadow, parent)
	parent = parent or icon:GetParent()

	icon:SetTexCoord(unpack(C.media.texCoord))

	local bg = parent:CreateBG()
	bg:SetOutside(icon)

	if shadow then
		bg:CreateShadow()
	end

	return bg
end

------------------------------------------------------------------------
-- CropIcon — simple texcoord + inset
------------------------------------------------------------------------

function E:CropIcon(icon)
	icon:SetTexCoord(unpack(C.media.texCoord))
	icon:SetInside()
end

------------------------------------------------------------------------
-- StyleCheckBox
------------------------------------------------------------------------

function E:StyleCheckBox(frame)
	local lvl = frame:GetFrameLevel()

	frame:SetNormalTexture("")
	frame:SetPushedTexture("")
	frame:SetHighlightTexture(C.media.texture.status)

	local bg = CreateFrame("Frame", nil, frame)
	bg:SetInside(frame, 4, 4)
	bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)
	bg:SetTemplate("Blur")
	frame.__bg = bg

	frame.hl = frame:GetHighlightTexture()
	frame.hl:SetInside(bg)
	frame.hl:SetVertexColor(E.myColor.r, E.myColor.g, E.myColor.b, 0.2)

	frame.ch = frame:GetCheckedTexture()
	frame.ch:SetAtlas("checkmark-minimal")
	frame.ch:SetDesaturated(true)
	frame.ch:SetTexCoord(0, 1, 0, 1)
	frame.ch:SetVertexColor(E.myColor.r, E.myColor.g, E.myColor.b)
end

------------------------------------------------------------------------
-- StyleButton — action button overlay/highlight/push textures
------------------------------------------------------------------------

function E:StyleButton(button, margin)
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetOutside(button, margin, margin)
	overlay:SetTexture(C.media.texture.overlay)
	button.__overlay = overlay

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

	local cooldown = button:GetName() and _G[button:GetName() .. "Cooldown"] or button.Cooldown
	if cooldown then
		cooldown:SetInside(button, margin, margin)
	end
end

------------------------------------------------------------------------
-- StyleActionButton — full actionbar button restyling
------------------------------------------------------------------------

local hooksecurefunc = hooksecurefunc
local unpack, pairs, gsub = unpack, pairs, gsub
local RANGE_INDICATOR = RANGE_INDICATOR
local KEY_BUTTON3, KEY_BUTTON4, KEY_SPACE, KEY_NUMPAD1 = KEY_BUTTON3, KEY_BUTTON4, KEY_SPACE, KEY_NUMPAD1
local KEY_MOUSEWHEELUP, KEY_MOUSEWHEELDOWN = KEY_MOUSEWHEELUP, KEY_MOUSEWHEELDOWN

local actionStyle = {
	icon = {
		texCoord = { 0.1, 0.9, 0.1, 0.9 },
		points = {
			{ "TOPLEFT", 1, -1 },
			{ "BOTTOMRIGHT", -1, 1 },
		},
	},
	border = {
		file = C.media.button.border,
		points = {
			{ "TOPLEFT", -2, 2 },
			{ "BOTTOMRIGHT", 2, -2 },
		},
	},
	flash = {
		file = C.media.button.flash,
		points = {
			{ "TOPLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	normalTexture = {
		file = C.media.button.normal,
		color = { 0.5, 0.5, 0.5, 0.6 },
		points = {
			{ "TOPLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	pushedTexture = {
		file = C.media.button.glow,
		points = {
			{ "TOPLEFT", -2, 2 },
			{ "BOTTOMRIGHT", 2, -2 },
		},
	},
	checkedTexture = {
		file = "",
		points = {
			{ "TOPLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	highlightTexture = {
		file = "",
		points = {
			{ "TOPLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	hotkey = {
		font = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
		points = {
			{ "TOPRIGHT", 0, 0 },
			{ "TOPLEFT", 0, 0 },
		},
	},
	count = {
		font = { STANDARD_TEXT_FONT, 11, "OUTLINE" },
		points = {
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	name = {
		font = { STANDARD_TEXT_FONT, 10, "OUTLINE" },
		points = {
			{ "BOTTOMLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	cooldown = {
		font = { STANDARD_TEXT_FONT, 16, "OUTLINE" },
		points = {
			{ "TOPLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},
	backdrop = {
		bgFile = C.media.button.buttonback,
		edgeFile = C.media.button.outer_shadow,
		tile = false,
		tileSize = 16,
		edgeSize = 2,
		insets = { left = 2, right = 2, top = 2, bottom = 2 },
		backgroundColor = C.media.backdrop_color,
		borderColor = C.media.border_color,
		points = {
			{ "TOPLEFT", -2, 2 },
			{ "BOTTOMRIGHT", 2, -2 },
		},
	},
}

local keyButton = gsub(KEY_BUTTON4, "%d", "")
local keyNumpad = gsub(KEY_NUMPAD1, "%d", "")

local replaces = {
	{ "(" .. keyButton .. ")", "M" },
	{ "(" .. keyNumpad .. ")", "N" },
	{ "(a%-)", "a" },
	{ "(c%-)", "c" },
	{ "(s%-)", "s" },
	{ KEY_BUTTON3, "M3" },
	{ KEY_MOUSEWHEELUP, "MU" },
	{ KEY_MOUSEWHEELDOWN, "MD" },
	{ KEY_SPACE, "Sp" },
	{ "CAPSLOCK", "CL" },
	{ "BUTTON", "M" },
	{ "NUMPAD", "N" },
	{ "(ALT%-)", "a" },
	{ "(CTRL%-)", "c" },
	{ "(SHIFT%-)", "s" },
	{ "MOUSEWHEELUP", "MU" },
	{ "MOUSEWHEELDOWN", "MD" },
	{ "SPACE", "Sp" },
}

local function updateHotKey(hotkey)
	local text = hotkey:GetText()
	if not text then
		return
	end

	if text == RANGE_INDICATOR then
		text = ""
	else
		for _, value in pairs(replaces) do
			text = gsub(text, value[1], value[2])
		end
	end

	hotkey:SetFormattedText("%s", text)
end

local function ApplyPoints(self, points)
	if not points then
		return
	end

	self:ClearAllPoints()
	for _, point in next, points do
		self:SetPoint(unpack(point))
	end
end

local function ApplyTexCoord(texture, texCoord)
	if texture.__lockdown or not texCoord then
		return
	end
	texture:SetTexCoord(unpack(texCoord))
end

local function ApplyVertexColor(texture, color)
	if not color then
		return
	end
	texture:SetVertexColor(unpack(color))
end

local function ApplyAlpha(region, alpha)
	if not alpha then
		return
	end
	region:SetAlpha(alpha)
end

local function ApplyFont(fontString, font)
	if not font then
		return
	end
	fontString:SetFont(unpack(font))
end

local function ApplyHorizontalAlign(fontString, align)
	if not align then
		return
	end
	fontString:SetJustifyH(align)
end

local function ApplyVerticalAlign(fontString, align)
	if not align then
		return
	end
	fontString:SetJustifyV(align)
end

local function ApplyTexture(texture, file)
	if not file then
		return
	end
	texture:SetTexture(file)
end

local function ApplyNormalTexture(button, file)
	if not file then
		return
	end
	button:SetNormalTexture(file)
end

local function CallButtonFunctionByName(button, func, ...)
	if button and func and button[func] then
		button[func](button, ...)
	end
end

local function SetupTexture(texture, cfg, func, button)
	if not texture or not cfg then
		return
	end

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
	if not fontString or not cfg then
		return
	end

	ApplyPoints(fontString, cfg.points)
	ApplyFont(fontString, cfg.font)
	ApplyAlpha(fontString, cfg.alpha)
	ApplyHorizontalAlign(fontString, cfg.halign)
	ApplyVerticalAlign(fontString, cfg.valign)
end

local function SetupCooldown(cooldown, cfg)
	if not cooldown or not cfg then
		return
	end
	ApplyPoints(cooldown, cfg.points)
end

local function SetupBackdrop(button, bdCfg)
	if not bdCfg or button.__bg then
		return
	end

	Mixin(button, BackdropTemplateMixin)
	local bg = CreateFrame("Frame", nil, button, "BackdropTemplate")
	ApplyPoints(bg, bdCfg.points)
	bg:SetFrameLevel(button:GetFrameLevel() - 1)
	bg:SetBackdrop(bdCfg)

	if bdCfg.backgroundColor then
		bg:SetBackdropColor(unpack(bdCfg.backgroundColor))
	end
	if bdCfg.borderColor then
		bg:SetBackdropBorderColor(unpack(bdCfg.borderColor))
	end

	button.__bg = bg
end

function E:StyleActionButton(button, force)
	if not button then
		return
	end
	if button.__styled and not force then
		return
	end

	local buttonName = button:GetName()
	local icon = button.icon or _G[buttonName .. "Icon"]
	local hotkey = button.HotKey or _G[buttonName .. "HotKey"]
	local count = button.Count or _G[buttonName .. "Count"]
	local name = button.Name or _G[buttonName .. "Name"]
	local flash = button.Flash or _G[buttonName .. "Flash"]
	local border = button.Border or _G[buttonName .. "Border"]
	local autoCastable = button.AutoCastable or _G[buttonName .. "AutoCastable"]
	local cooldown = button.cooldown or _G[buttonName .. "Cooldown"] or button.Cooldown
	local normal = button.NormalTexture or button:GetNormalTexture()
	local pushed = button.PushedTexture or button:GetPushedTexture()
	local checked = button.CheckedTexture or (button.GetCheckedTexture and button:GetCheckedTexture() or nil)
	local highlight = button.HighlightTexture or button:GetHighlightTexture()
	local newActionTexture = button.NewActionTexture
	local spellHighlight = button.SpellHighlightTexture
	local slotbg = button.SlotBackground
	local iconMask = button.IconMask
	local petShine = _G[buttonName .. "Shine"]

	if border then
		border:SetTexture("")
	end
	if flash then
		flash:SetTexture("")
	end
	if newActionTexture then
		newActionTexture:SetTexture("")
	end
	if slotbg then
		slotbg:Hide()
	end
	if iconMask then
		iconMask:Hide()
	end
	if petShine then
		petShine:SetInside()
	end
	if spellHighlight then
		spellHighlight:SetOutside()
	end
	if autoCastable then
		autoCastable:SetTexCoord(0.217, 0.765, 0.217, 0.765)
		autoCastable:SetInside()
	end

	SetupBackdrop(button, actionStyle.backdrop)
	SetupCooldown(cooldown, actionStyle.cooldown)

	SetupTexture(icon, actionStyle.icon, "SetTexture", icon)
	SetupTexture(flash, actionStyle.flash, "SetTexture", flash)
	SetupTexture(border, actionStyle.border, "SetTexture", border)
	SetupTexture(normal, actionStyle.normalTexture, "SetNormalTexture", button)
	SetupTexture(pushed, actionStyle.pushedTexture, "SetPushedTexture", button)
	SetupTexture(highlight, actionStyle.highlightTexture, "SetHighlightTexture", button)
	SetupTexture(checked, actionStyle.checkedTexture, "SetCheckedTexture", button)

	if checked then
		checked:SetColorTexture(1, 0.8, 0, 0.35)
	end
	if highlight then
		highlight:SetColorTexture(1, 1, 1, 0.25)
	end
	if spellHighlight then
		spellHighlight:SetOutside()
	end

	SetupFontString(hotkey, actionStyle.hotkey)
	SetupFontString(count, actionStyle.count)
	SetupFontString(name, actionStyle.name)

	if hotkey then
		updateHotKey(hotkey)
		hooksecurefunc(hotkey, "SetText", updateHotKey)
	end

	button.__styled = true
end
