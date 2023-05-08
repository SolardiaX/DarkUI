local E, C, L, M = unpack(select(2, ...))

if not C.blizzard.custom_position then return end

----------------------------------------------------------------------------------------
--	UIWidget position
----------------------------------------------------------------------------------------
local top, below, power = _G["UIWidgetTopCenterContainerFrame"], _G["UIWidgetBelowMinimapContainerFrame"], _G["UIWidgetPowerBarContainerFrame"]

-- Top Widget
local topAnchor = CreateFrame("Frame", "UIWidgetTopAnchor", UIParent)
topAnchor:SetSize(200, 30)
topAnchor:SetPoint(unpack(C.blizzard.uiwidget_top_pos))

top:ClearAllPoints()
top:SetPoint("TOP", topAnchor)

-- Below Widget
local belowAnchor = CreateFrame("Frame", "UIWidgetBelowAnchor", UIParent)
belowAnchor:SetSize(150, 30)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        if not belowAnchor:IsUserPlaced() then
            belowAnchor:ClearAllPoints()
            belowAnchor:SetPoint(unpack(C.blizzard.uiwidget_below_pos))
        end
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

hooksecurefunc(below, "SetPoint", function(self, _, anchor)
    if anchor and anchor ~= belowAnchor then
        self:ClearAllPoints()
        self:SetPoint("TOP", belowAnchor)
    end
end)

-- Power Bar Widget
local powerAnchor = CreateFrame("Frame", "UIWidgetPowerBarAnchor", UIParent)
powerAnchor:SetSize(210, 30)
powerAnchor:SetPoint(unpack(C.blizzard.uiwidget_below_pos))

hooksecurefunc(power, "SetPoint", function(self, _, anchor)
    if anchor and anchor ~= powerAnchor then
        self:ClearAllPoints()
        self:SetPoint("TOP", powerAnchor)
    end
end)

-- Mover for all widgets
for _, frame in pairs({top, below, maw}) do
    local anchor = frame == top and topAnchor or frame == below and belowAnchor or mawAnchor
    anchor:SetMovable(true)
    anchor:SetClampedToScreen(true)
    frame:SetClampedToScreen(true)
    frame:SetScript("OnMouseDown", function(_, button)
        if IsAltKeyDown() or IsShiftKeyDown() then
            anchor:ClearAllPoints()
            anchor:StartMoving()
        elseif IsControlKeyDown() and button == "RightButton" then
            anchor:ClearAllPoints()
            if frame == top then
                anchor:SetPoint(unpack(C.blizzard.uiwidget_top_pos))
            elseif frame == below then
                anchor:SetPoint(unpack(C.blizzard.uiwidget_below_pos))
            else
                anchor:SetPoint("TOPRIGHT", BuffsAnchor, "BOTTOMRIGHT", 0, -3)
            end
            anchor:SetUserPlaced(false)
        end
    end)
    frame:SetScript("OnMouseUp", function()
        anchor:StopMovingOrSizing()
    end)
end

----------------------------------------------------------------------------------------
--	UIWidget skin
----------------------------------------------------------------------------------------
local atlasColors = {
    ["UI-Frame-Bar-Fill-Blue"] = {0.2, 0.6, 1},
    ["UI-Frame-Bar-Fill-Red"] = {0.9, 0.2, 0.2},
    ["UI-Frame-Bar-Fill-Yellow"] = {1, 0.6, 0},
    ["objectivewidget-bar-fill-left"] = {0.2, 0.6, 1},
    ["objectivewidget-bar-fill-right"] = {0.9, 0.2, 0.2}
}

local function SkinStatusBar(widget)
    local bar = widget.Bar

    if widget:IsForbidden() then
        if bar and bar.tooltip then
            bar.tooltip = nil
        end
        return
    end

    local atlas = bar:GetStatusBarTexture()
    if atlasColors[atlas] then
        bar:SetStatusBarTexture(C.media.texture.status)
        bar:SetStatusBarColor(unpack(atlasColors[atlas]))
    end

    if widget:GetParent() == power then
        -- Don't skin Cosmic Energy bar
        if widget.widgetID == 3463 then
            bar.styled = true
        end
    end

    if not bar.styled then
        bar.BGLeft:SetAlpha(0)
        bar.BGRight:SetAlpha(0)
        bar.BGCenter:SetAlpha(0)
        bar.BorderLeft:SetAlpha(0)
        bar.BorderRight:SetAlpha(0)
        bar.BorderCenter:SetAlpha(0)
        bar.Spark:SetAlpha(0)
        local parent = widget:GetParent():GetParent()
        if parent.castBar or parent.UnitFrame then -- nameplate
            Mixin(bar, BackdropTemplateMixin)
            bar:SetBackdrop({
                bgFile = C.media.texture.blank,
                insets = {left = 0, right = 0, top = 0, bottom = 0}
            })
            bar:SetBackdropColor(0.1, 0.1, 0.1, 1)
        else
            bar:CreateBackdrop("Overlay")
        end
        bar.styled = true
    end
end

local function SkinDoubleStatusBar(widget)
    for _, bar in pairs({widget.LeftBar, widget.RightBar}) do
        local atlas = bar:GetStatusBarTexture()
        if atlasColors[atlas] then
            bar:SetStatusBarTexture(C.media.texture.status)
            bar:SetStatusBarColor(unpack(atlasColors[atlas]))
        end
        if not bar.styled then
            bar.BG:SetAlpha(0)
            bar.BorderLeft:SetAlpha(0)
            bar.BorderRight:SetAlpha(0)
            bar.BorderCenter:SetAlpha(0)
            bar.Spark:SetAlpha(0)
            bar.SparkGlow:SetAlpha(0)
            bar:CreateBackdrop("Overlay")
            bar.styled = true
        end
    end
end

local function SkinCaptureBar(previous, widget)
    widget:ClearAllPoints()
    if previous == nil then
        widget:SetPoint(unpack(C.blizzard.capturebar_pos))
    else
        widget:SetPoint("TOPLEFT", previous, "BOTTOMLEFT", 0, -7)
    end

    if not widget.skinned then
        widget.LeftLine:SetAlpha(0)
        widget.RightLine:SetAlpha(0)
        widget.BarBackground:SetAlpha(0)
        widget.Glow1:SetAlpha(0)
        widget.Glow2:SetAlpha(0)
        widget.Glow3:SetAlpha(0)

        widget.LeftBar:SetTexture(C.media.texture.status)
        widget.NeutralBar:SetTexture(C.media.texture.status)
        widget.RightBar:SetTexture(C.media.texture.status)

        widget.LeftBar:SetVertexColor(0.2, 0.6, 1)
        widget.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)
        widget.RightBar:SetVertexColor(0.9, 0.2, 0.2)

        if not widget.backdrop then
            widget:CreateBackdrop("Default")
            widget.backdrop:SetPoint("TOPLEFT", widget.LeftBar, -2, 2)
            widget.backdrop:SetPoint("BOTTOMRIGHT", widget.RightBar, 2, -2)
        end

        widget.border = widget:CreateTexture(nil, "BORDER")
        widget.border:SetTexture(C.media.path .. C.general.style .. "\\" .. "tex_bar_border")
        widget.border:SetPoint("CENTER")
        widget.border:SetSize(256 * widget:GetWidth() / 198, 64 * widget:GetHeight() / 12)
        
        widget.skinned = true
    end
end

local VigorBar = CreateFrame("Frame", "VigorBar", UIParent)
VigorBar:CreateBackdrop("Default")
VigorBar:SetPoint("TOP", powerAnchor, "TOP", 0, -2)
VigorBar:SetSize(250, 12)
VigorBar:Hide()
VigorBar.border = VigorBar:CreateTexture(nil, "BORDER")
VigorBar.border:SetTexture(C.media.path .. C.general.style .. "\\" .. "tex_bar_border")
VigorBar.border:SetPoint("CENTER")
VigorBar.border:SetSize(256 * VigorBar:GetWidth() / 198, 64 * VigorBar:GetHeight() / 12)

for i = 1, 6 do
	VigorBar[i] = CreateFrame("StatusBar", "Vigor"..i, VigorBar)
	VigorBar[i]:SetSize((250 - 5) / 6, 12)

	if i == 1 then
		VigorBar[i]:SetPoint("TOPLEFT", VigorBar, "TOPLEFT", 0, 0)
	else
		VigorBar[i]:SetPoint("TOPLEFT", VigorBar[i-1], "TOPRIGHT", 1, 0)
	end
	VigorBar[i]:SetStatusBarTexture(C.media.texture.status)
	VigorBar[i]:SetMinMaxValues(0, 100)
	VigorBar[i]:SetStatusBarColor(0.2, 0.58, 0.8)

	VigorBar[i].bg = VigorBar[i]:CreateTexture(nil, "BORDER")
	VigorBar[i].bg:SetAllPoints()
	VigorBar[i].bg:SetTexture(C.media.texture.status)
	VigorBar[i].bg:SetVertexColor(0.2, 0.58, 0.8, 0.2)

	VigorBar[i]:SetValue(0)
end

local function SkinVigorBar(widget)
	local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460)
	if not widgetInfo then return end
	if not widget:IsShown() then return end -- Hide our bar if Blizzard's not shown

	VigorBar:Show()
	local total = widgetInfo.numTotalFrames
	for i = 1, total do
		local value = 0

		if widgetInfo.numFullFrames >= i then
			value = widgetInfo.fillMax
		elseif widgetInfo.numFullFrames + 1 == i then
			value = widgetInfo.fillValue
		else
			value = widgetInfo.fillMin
		end
		VigorBar[i]:SetValue(value)
	end

	if total < 6 and IsPlayerSpell(377922) then total = 6 end -- sometimes it return 5

	if total < 6 then
		for i = total + 1, 6 do
			VigorBar[i]:Hide()
			VigorBar[i]:SetValue(0)
		end

		local spacing = select(4, VigorBar[6]:GetPoint())
		local w = VigorBar:GetWidth()
		local s = 0

		for i = 1, total do
			VigorBar[i]:Show()
			if i ~= total then
				VigorBar[i]:SetWidth(w / total - spacing)
				s = s + (w / total)
			else
				VigorBar[i]:SetWidth(w - s)
			end
		end
	end

	widget:SetAlpha(0)

	if not widget.hook then
		hooksecurefunc(widget, "Hide", function(self)
			VigorBar:Hide()
		end)
		widget.hook = true
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("UPDATE_UI_WIDGET")
frame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    for _, widget in pairs(UIWidgetTopCenterContainerFrame.widgetFrames) do
        if widget.widgetType == _G.Enum.UIWidgetVisualizationType.StatusBar then
            SkinStatusBar(widget)
        elseif widget.widgetType == _G.Enum.UIWidgetVisualizationType.DoubleStatusBar then
            SkinDoubleStatusBar(widget)
        end
    end

    for _, widget in pairs(UIWidgetBelowMinimapContainerFrame.widgetFrames) do
        if widget.widgetType == Enum.UIWidgetVisualizationType.CaptureBar then
			SkinCaptureBar(widget)
		end
	end
	for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
		if widget.widgetID == 4460 then
			SkinVigorBar(widget)
        end
    end
end)

hooksecurefunc(UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin, "Setup", function(widgetInfo)
    widgetInfo.Frame:SetAlpha(0)
    for frame in widgetInfo.currencyPool:EnumerateActive() do
        frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    end
end)

hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", function(widget)
    SkinStatusBar(widget)
end)
