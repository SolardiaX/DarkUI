local E, C, L, M = unpack(select(2, ...))

if not C.blizzard.custom_position then return end

----------------------------------------------------------------------------------------
--	UIWidget position
----------------------------------------------------------------------------------------
local top, below, power, maw = _G["UIWidgetTopCenterContainerFrame"], _G["UIWidgetBelowMinimapContainerFrame"], _G["UIWidgetPowerBarContainerFrame"], _G["MawBuffsBelowMinimapFrame"]

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

-- Maw Buff Widget
local mawAnchor = CreateFrame("Frame", "UIWidgetMawAnchor", UIParent)
mawAnchor:SetSize(210, 30)
mawAnchor:SetPoint("TOPRIGHT", BuffsAnchor, "BOTTOMRIGHT", 0, -3)

hooksecurefunc(maw, "SetPoint", function(self, _, anchor)
    if anchor and anchor ~= mawAnchor then
        self:ClearAllPoints()
        self:SetPoint("TOPRIGHT", mawAnchor)
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
        
        widget.skinned = true
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
        local previous = nil
        if widget.widgetType == Enum.UIWidgetVisualizationType.CaptureBar then
            SkinCaptureBar(previous, widget)
            if previous == nil then previous = widget end
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

-- Maw Buffs skin
maw:SetSize(210, 40)
maw.Container:SetSize(200, 30)
E:StyleButton(maw)

maw.Container.List:StripTextures()
maw.Container.List:SetTemplate("Overlay")
maw.Container.List:ClearAllPoints()
maw.Container.List:SetPoint("TOPRIGHT", maw.Container, "TOPLEFT", -15, 0)

maw.Container.List:HookScript("OnShow", function(self)
    self.button:SetPushedTexture(0)
    self.button:SetHighlightTexture(0)
    self.button:SetWidth(200)
    self.button:SetButtonState("NORMAL")
    self.button:SetPushedTextOffset(0, 0)
    self.button:SetButtonState("PUSHED", true)
end)

maw.Container.List:HookScript("OnHide", function(self)
    self.button:SetPushedTexture(0)
    self.button:SetHighlightTexture(0)
    self.button:SetWidth(200)
end)

-- Hide Maw Buffs
if C.blizzard.hide_maw_buffs then
    maw:SetAlpha(0)
    maw:SetScale(0.001)
end