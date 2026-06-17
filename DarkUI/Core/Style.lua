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
		if self.__overlay then
			self.__overlay:SetVertexColor(r * 0.3, g * 0.3, b * 0.3, 1)
		end
	end
end

local function onLeaveHighlight(self)
	self:SetBackdropBorderColor(unpack(C.media.border_color))
	if self.__overlay then
		self.__overlay:SetVertexColor(0.1, 0.1, 0.1, 1)
	end
end

E.onEnterHighlight = onEnterHighlight
E.onLeaveHighlight = onLeaveHighlight

------------------------------------------------------------------------
-- E:StyleFrame — full styled panel (bg + shadow + optional gradient)
------------------------------------------------------------------------

function E:StyleFrame(frame, opts)
	if not frame or frame:IsForbidden() then return end
	if frame.__styled then return end

	if type(opts) ~= "table" then
		opts = { gradient = opts }
	end

	frame:CreateBackdrop(opts.backdrop)
	frame:CreateBorder(opts.border)
	if opts.shadow ~= false then
		frame.__border:CreateShadow()
	end
	if opts.gradient then
		frame:CreateGradient()
	end

	frame.__styled = true
end

------------------------------------------------------------------------
-- E:StyleIcon — texCoord + bg frame on existing icon texture
------------------------------------------------------------------------

function E:StyleIcon(icon, shadow, parent)
	parent = parent or icon:GetParent()

	icon:SetTexCoord(unpack(C.media.texCoord))

	local bg = parent:CreateBackdrop()
	bg:SetOutside(icon)

	if shadow then
		bg:CreateShadow()
	end

	return bg
end

------------------------------------------------------------------------
-- E:StyleCheckBox
------------------------------------------------------------------------

function E:StyleCheckBox(frame)
	if not frame or frame.__styled then
		return
	end

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
-- E:StyleButton — action button overlay/highlight/push textures
------------------------------------------------------------------------

function E:StyleButton(button, margin)
	local margin = margin or 2
	
	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetOutside(button, margin, margin)
	overlay:SetTexture(C.media.texture.overlay)
	button.__overlay = overlay

	local icon = button.Icon or button.icon
	if icon then
		icon:SetTexCoord(unpack(C.media.texCoord))
		icon:SetInside(button, margin, margin)
	end

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
-- E:StyleCloseButton — close button (X)
------------------------------------------------------------------------

function E:StyleCloseButton(button, anchor)
	if not button or button.__styled then
		return
	end

	button:StripTextures()
	button:SetSize(18, 18)

	button:SetTemplate("Fill")
	button:HookScript("OnEnter", onEnterHighlight)
	button:HookScript("OnLeave", onLeaveHighlight)

	if not button.text then
		button.text = button:CreateFontText(16, "x")
		button.text:SetPoint("CENTER", 0, 1)
	end

	if anchor then
		button:SetPoint("TOPRIGHT", anchor, "TOPRIGHT", -4, -4)
	else
		button:SetPoint("TOPRIGHT", -4, -4)
	end

	button:HookScript("OnEnter", function(self)
		if self:IsEnabled() then
			if self.__border then
				self.__border:SetBackdropBorderColor(r * 0.3, g * 0.3, b * 0.3, 1)
			end
		end
	end)
	button:HookScript("OnLeave", function(self)
		if self.__border then
			self.__border:SetBackdropBorderColor(0.1, 0.1, 0.1, 1)
		end
	end)

	button.__styled = true
end
