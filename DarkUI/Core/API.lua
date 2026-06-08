local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Core API
------------------------------------------------------------------------

------------------------------------------------------------------------
-- UI Scale
------------------------------------------------------------------------

E.UIScale = function()
	if C.general.autoScale then
		C.general.uiScale = min(2, max(0.20, 768 / E.screenHeight))
		C.general.uiScale = tonumber(string.sub(C.general.uiScale, 0, 5))
		if C.general.uiScale < 0.64 then
			C.general.uiScale = 0.64
		end
	end
end
E.UIScale()

local pixel = 1
local ratio = 768 / E.screenHeight
E.mult = (pixel / C.general.uiScale) - ((pixel - ratio) / C.general.uiScale)
E.noscalemult = E.mult * C.general.uiScale

local Mult = E.mult

------------------------------------------------------------------------
-- Backdrop Constants
------------------------------------------------------------------------

local BACKDROP = {
	default = { bgFile = C.media.texture.blank, edgeFile = C.media.texture.blank },
	shadow = { edgeFile = C.media.texture.shadow },
	border = { bgFile = C.media.texture.blank, edgeFile = C.media.texture.border },
	blur = { bgFile = C.media.texture.blank, edgeFile = C.media.texture.shadow },
}

------------------------------------------------------------------------
-- Utilities
------------------------------------------------------------------------

E.Dummy = function()
	return
end

E.FrameHider = CreateFrame("Frame")
E.FrameHider:Hide()

E.PetBattleFrameHider = CreateFrame("Frame", "DarkUI_PetBattleFrameHider", UIParent, "SecureHandlerStateTemplate")
E.PetBattleFrameHider:SetAllPoints()
E.PetBattleFrameHider:SetFrameStrata("LOW")
RegisterStateDriver(E.PetBattleFrameHider, "visibility", "[petbattle] hide; show")

------------------------------------------------------------------------
-- Kill
------------------------------------------------------------------------

local function kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(E.FrameHider)
	else
		object.Show = object.Hide
	end
	object:Hide()
end

------------------------------------------------------------------------
-- StripTextures
------------------------------------------------------------------------

local stripTexturesBlizzFrames = {
	"Inset",
	"inset",
	"InsetFrame",
	"LeftInset",
	"RightInset",
	"NineSlice",
	"BG",
	"Bg",
	"border",
	"Border",
	"Background",
	"BorderFrame",
	"bottomInset",
	"BottomInset",
	"bgLeft",
	"bgRight",
	"FilligreeOverlay",
	"PortraitOverlay",
	"ArtOverlayFrame",
	"Portrait",
	"portrait",
	"ScrollFrameBorder",
	"ScrollUpBorder",
	"ScrollDownBorder",
}

local function stripTextures(object, killFlag)
	if object.GetNumRegions then
		for i = 1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				if killFlag and type(killFlag) == "boolean" then
					kill(region)
				elseif tonumber(killFlag) then
					if killFlag == 0 then
						region:SetAlpha(0)
					elseif i ~= killFlag then
						region:SetTexture("")
						region:SetAtlas("")
					end
				else
					region:SetTexture("")
					region:SetAtlas("")
				end
			end
		end
	end

	local frameName = object.GetName and object:GetName()
	for _, blizzard in pairs(stripTexturesBlizzFrames) do
		local blizzFrame = object[blizzard] or (frameName and _G[frameName .. blizzard])
		if blizzFrame and blizzFrame.StripTextures then
			blizzFrame:StripTextures(killFlag)
		end
	end
end

------------------------------------------------------------------------
-- Pixel Snap
------------------------------------------------------------------------

local issecrettable = issecrettable

local function watchPixelSnap(frame, snap)
	if issecrettable and issecrettable(frame) then
		return
	end
	if (frame and not frame:IsForbidden()) and frame.__pixelSnapOff and snap then
		frame.__pixelSnapOff = nil
	end
end

local function disablePixelSnap(frame)
	if issecrettable and issecrettable(frame) then
		return
	end
	if (frame and not frame:IsForbidden()) and not frame.__pixelSnapOff then
		if frame.SetSnapToPixelGrid then
			frame:SetSnapToPixelGrid(false)
			frame:SetTexelSnappingBias(0)
		elseif frame.GetStatusBarTexture then
			local texture = frame:GetStatusBarTexture()
			if type(texture) == "table" and texture.SetSnapToPixelGrid then
				texture:SetSnapToPixelGrid(false)
				texture:SetTexelSnappingBias(0)
			end
		end

		frame.__pixelSnapOff = true
	end
end

------------------------------------------------------------------------
-- SetOutside / SetInside
------------------------------------------------------------------------

local function setOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or Mult
	yOffset = yOffset or Mult
	anchor = anchor or obj:GetParent()

	disablePixelSnap(obj)

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function setInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or Mult
	yOffset = yOffset or Mult
	anchor = anchor or obj:GetParent()

	disablePixelSnap(obj)

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

------------------------------------------------------------------------
-- SetTemplate
------------------------------------------------------------------------

local function setTemplate(f, t, edge, insets)
	Mixin(f, BackdropTemplateMixin)
	if not t then
		t = "Default"
	end

	local backdropr, backdropg, backdropb, backdropa = unpack(C.media.backdrop_color)
	local borderr, borderg, borderb, bordera = unpack(C.media.border_color)
	local overlay_color = C.media.overlay_color

	if t == "Shadow" then
		if not edge then
			edge = 6
		end
		if not insets then
			insets = Mult
		end
		f:SetBackdrop({
			bgFile = nil,
			edgeFile = C.media.texture.shadow,
			tile = false,
			tileSize = 32,
			edgeSize = edge,
			insets = { left = insets, right = insets, top = insets, bottom = insets },
		})

		borderr, borderg, borderb, bordera = unpack(C.media.shadow_color)
	elseif t == "Border" then
		if not edge then
			edge = 12
		end
		if not insets then
			insets = Mult
		end
		f:SetBackdrop({
			bgFile = C.media.texture.blank,
			edgeFile = C.media.texture.border,
			tile = false,
			tileSize = 32,
			edgeSize = edge,
			insets = { left = insets, right = insets, top = insets, bottom = insets },
		})
		backdropa = 0
	elseif t == "Blur" then
		if not edge then
			edge = Mult
		end
		if not insets then
			insets = Mult
		end
		f:SetBackdrop({
			bgFile = C.media.texture.blank,
			edgeFile = C.media.texture.shadow,
			tile = false,
			tileEdge = true,
			tileSize = 16,
			edgeSize = edge,
			insets = { left = insets, right = insets, top = insets, bottom = insets },
		})
	else
		if not edge then
			edge = Mult
		end
		if not insets then
			insets = Mult
		end
		f:SetBackdrop({
			bgFile = C.media.texture.blank,
			edgeFile = C.media.texture.blank,
			edgeSize = edge,
			insets = { left = insets, right = insets, top = insets, bottom = insets },
		})
	end

	if t == "Transparent" then
		backdropa = overlay_color[4]
	elseif t == "Overlay" then
		backdropa = 1
	elseif t == "Invisible" then
		backdropa = 0
		bordera = 0
	end

	f:SetBackdropBorderColor(borderr, borderg, borderb, bordera)

	if t ~= "Shadow" then
		f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	end
end

------------------------------------------------------------------------
-- CreateTemplate — create a child frame with SetTemplate style
------------------------------------------------------------------------

local function createTemplate(f, t, margin)
	t = t or "Default"
	local key = "__" .. t:lower()
	if f[key] then
		return f[key]
	end

	local frame = f
	if f:IsObjectType("Texture") then
		frame = f:GetParent()
	end

	margin = margin or Mult
	local lvl = frame:GetFrameLevel()

	local child = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	child:SetOutside(f, margin, margin)

	if t == "Shadow" then
		child:SetFrameLevel(0)
	elseif t == "Border" then
		child:SetFrameLevel(lvl + 1)
	else
		child:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	end

	setTemplate(child, t)

	f[key] = child
	return child
end

-- Convenience aliases
local function createBG(f, margin)
	return createTemplate(f, "Default", margin)
end

local function createShadow(f, margin)
	return createTemplate(f, "Shadow", margin or 4)
end

local function createBorder(f, margin)
	return createTemplate(f, "Border", margin)
end

------------------------------------------------------------------------
-- CreateOverlay — overlay texture (tex_overlay)
------------------------------------------------------------------------

local function createOverlay(f, margin)
	if f.__overlay then
		return f.__overlay
	end

	margin = margin or 2

	local overlay = f:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture(C.media.texture.overlay)
	overlay:ClearAllPoints()
	overlay:SetPoint("TOPRIGHT", f, margin, margin)
	overlay:SetPoint("BOTTOMLEFT", f, -margin, -margin)

	f.__overlay = overlay
	return overlay
end

------------------------------------------------------------------------
-- CreateGradient
------------------------------------------------------------------------

local function createGradient(f)
	if f.__gradient then
		return f.__gradient
	end

	local gradient = f:CreateTexture(nil, "BORDER")
	gradient:SetInside(f)
	gradient:SetTexture(C.media.texture.gradient)
	gradient:SetVertexColor(unpack(C.media.gradient_color))

	f.__gradient = gradient
	return gradient
end

------------------------------------------------------------------------
-- CreateFontText
------------------------------------------------------------------------

local function createFontText(f, size, text, classcolor, anchor, x, y)
	local fs = f:CreateFontString(nil, "OVERLAY", nil, 1)
	fs:SetFont(C.media.standard_font[1], size, C.media.standard_font[3])
	fs:SetText(text)
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(0.85, -0.85)

	if classcolor then
		fs:SetTextColor(E.myColor.r, E.myColor.g, E.myColor.b)
	else
		fs:SetTextColor(unpack(C.media.text_color))
	end

	if anchor and x and y then
		fs:SetPoint(anchor, x, y)
	else
		fs:SetPoint("CENTER", 1, 0)
	end

	return fs
end

local function fadeIn(f)
	E:UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end

local function fadeOut(f)
	E:UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end

------------------------------------------------------------------------
-- Metatable Injection
------------------------------------------------------------------------

local function addapi(object)
	local mt = getmetatable(object).__index
	if mt.__darkui then
		return
	end

	mt.SetOutside = setOutside
	mt.SetInside = setInside
	mt.Kill = kill
	mt.StripTextures = stripTextures
	mt.SetTemplate = setTemplate
	mt.CreateTemplate = createTemplate
	mt.CreateBG = createBG
	mt.CreateShadow = createShadow
	mt.CreateBorder = createBorder
	mt.CreateOverlay = createOverlay
	mt.CreateGradient = createGradient
	mt.CreateFontText = createFontText
	mt.FadeIn = fadeIn
	mt.FadeOut = fadeOut

	if mt.SetTexture then
		hooksecurefunc(mt, "SetTexture", disablePixelSnap)
	end
	if mt.SetTexCoord then
		hooksecurefunc(mt, "SetTexCoord", disablePixelSnap)
	end
	if mt.CreateTexture then
		hooksecurefunc(mt, "CreateTexture", disablePixelSnap)
	end
	if mt.SetVertexColor then
		hooksecurefunc(mt, "SetVertexColor", disablePixelSnap)
	end
	if mt.SetColorTexture then
		hooksecurefunc(mt, "SetColorTexture", disablePixelSnap)
	end
	if mt.SetSnapToPixelGrid then
		hooksecurefunc(mt, "SetSnapToPixelGrid", watchPixelSnap)
	end
	if mt.SetStatusBarTexture then
		hooksecurefunc(mt, "SetStatusBarTexture", disablePixelSnap)
	end

	mt.__darkui = true
end

------------------------------------------------------------------------
-- Inject into all frame types via EnumerateFrames
------------------------------------------------------------------------

local handled = { ["Frame"] = true }
local baseFrame = CreateFrame("Frame")
addapi(baseFrame)
addapi(baseFrame:CreateTexture())
addapi(baseFrame:CreateFontString())
addapi(baseFrame:CreateMaskTexture())

local object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end
	object = EnumerateFrames(object)
end
