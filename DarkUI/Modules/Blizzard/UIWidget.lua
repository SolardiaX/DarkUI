local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- UI Widget
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("UIWidget")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Widget Skin Helpers
------------------------------------------------------------------------

local atlasColors = {
    ["UI-Frame-Bar-Fill-Blue"] = { 0.2, 0.6, 1 },
    ["UI-Frame-Bar-Fill-Red"] = { 0.9, 0.2, 0.2 },
    ["UI-Frame-Bar-Fill-Yellow"] = { 1, 0.6, 0 },
    ["objectivewidget-bar-fill-left"] = { 0.2, 0.6, 1 },
    ["objectivewidget-bar-fill-right"] = { 0.9, 0.2, 0.2 },
}

local function skinStatusBar(widget)
    local bar = widget.Bar
    if widget:IsForbidden() then
        if bar and bar.tooltip then bar.tooltip = nil end
        return
    end

    local atlas = bar:GetStatusBarTexture()
    if atlasColors[atlas] then
        bar:SetStatusBarTexture(C.media.texture.status)
        bar:SetStatusBarColor(unpack(atlasColors[atlas]))
    end

    if not bar.styled then
        if bar.BGLeft then bar.BGLeft:SetAlpha(0) end
        if bar.BGRight then bar.BGRight:SetAlpha(0) end
        if bar.BGCenter then bar.BGCenter:SetAlpha(0) end
        if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
        if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
        if bar.BorderCenter then bar.BorderCenter:SetAlpha(0) end
        if bar.Spark then bar.Spark:SetAlpha(0) end

        local parent = widget:GetParent():GetParent()
        if parent and (parent.castBar or parent.UnitFrame) then
            Mixin(bar, BackdropTemplateMixin)
            bar.SetupTextureCoordinates = E.SafeSetupTextureCoordinates
            bar:SetBackdrop({ bgFile = C.media.texture.blank, insets = { left = 0, right = 0, top = 0, bottom = 0 } })
            bar:SetBackdropColor(0.1, 0.1, 0.1, 1)
            bar:SetStatusBarTexture(C.media.texture.status_f)
        else
            bar:SetStatusBarTexture(C.media.texture.status_f)
            bar:CreateBackdrop("Transparent")
            bar:CreateBorder()
        end
        bar.styled = true
    end
end

local function skinDoubleStatusBar(widget)
    for _, bar in pairs({ widget.LeftBar, widget.RightBar }) do
        local atlas = bar:GetStatusBarTexture()
        if atlasColors[atlas] then
            bar:SetStatusBarTexture(C.media.texture.status_f)
            bar:SetStatusBarColor(unpack(atlasColors[atlas]))
        end
        if not bar.styled then
            if bar.BG then bar.BG:SetAlpha(0) end
            if bar.BorderLeft then bar.BorderLeft:SetAlpha(0) end
            if bar.BorderRight then bar.BorderRight:SetAlpha(0) end
            if bar.BorderCenter then bar.BorderCenter:SetAlpha(0) end
            if bar.Spark then bar.Spark:SetAlpha(0) end
            if bar.SparkGlow then bar.SparkGlow:SetAlpha(0) end
            bar:SetStatusBarTexture(C.media.texture.status_f)
            bar:CreateBackdrop("Transparent")
            bar:CreateBorder()
            bar.styled = true
        end
    end
end

local function skinCaptureBar(_, widget)
    if not widget.skinned then
        if widget.LeftLine then widget.LeftLine:SetAlpha(0) end
        if widget.RightLine then widget.RightLine:SetAlpha(0) end
        if widget.BarBackground then widget.BarBackground:SetAlpha(0) end
        if widget.Glow1 then widget.Glow1:SetAlpha(0) end
        if widget.Glow2 then widget.Glow2:SetAlpha(0) end
        if widget.Glow3 then widget.Glow3:SetAlpha(0) end

        widget.LeftBar:SetTexture(C.media.texture.status)
        widget.NeutralBar:SetTexture(C.media.texture.status)
        widget.RightBar:SetTexture(C.media.texture.status)

        widget.LeftBar:SetVertexColor(0.2, 0.6, 1)
        widget.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)
        widget.RightBar:SetVertexColor(0.9, 0.2, 0.2)

        widget:CreateBackdrop("Default")
        widget.__backdrop:SetPoint("TOPLEFT", widget.LeftBar, -2, 2)
        widget.__backdrop:SetPoint("BOTTOMRIGHT", widget.RightBar, 2, -2)

        widget.skinned = true
    end
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    local top = _G["UIWidgetTopCenterContainerFrame"]
    local below = _G["UIWidgetBelowMinimapContainerFrame"]
    local power = _G["UIWidgetPowerBarContainerFrame"]

    -- Top Widget anchor
    local topAnchor = CreateFrame("Frame", "DarkUI_UIWidgetTopAnchor", UIParent)
    topAnchor:SetSize(200, 30)
    topAnchor:SetPoint(unpack(cfg.uiwidget_top_pos))
    top:ClearAllPoints()
    top:SetPoint("TOP", topAnchor)

    -- Below Widget anchor
    local belowAnchor = CreateFrame("Frame", "DarkUI_UIWidgetBelowAnchor", UIParent)
    belowAnchor:SetSize(150, 30)
    belowAnchor:SetPoint(unpack(cfg.uiwidget_below_pos))

    hooksecurefunc(below, "SetPoint", function(self, _, anchor)
        if anchor and anchor ~= belowAnchor then
            self:ClearAllPoints()
            self:SetPoint("TOP", belowAnchor)
        end
    end)

    -- Power Bar Widget anchor
    if power then
        local powerAnchor = CreateFrame("Frame", "DarkUI_UIWidgetPowerBarAnchor", UIParent)
        powerAnchor:SetSize(210, 30)
        powerAnchor:SetPoint(unpack(cfg.uiwidget_below_pos))

        hooksecurefunc(power, "SetPoint", function(self, _, anchor)
            if anchor and anchor ~= powerAnchor then
                self:ClearAllPoints()
                self:SetPoint("TOP", powerAnchor)
            end
        end)
    end

    -- Skin hooks
    local function updateWidgets()
        for _, widget in pairs(UIWidgetTopCenterContainerFrame.widgetFrames) do
            if widget.widgetType == Enum.UIWidgetVisualizationType.StatusBar then
                skinStatusBar(widget)
            elseif widget.widgetType == Enum.UIWidgetVisualizationType.DoubleStatusBar then
                skinDoubleStatusBar(widget)
            end
        end
        for _, widget in pairs(UIWidgetBelowMinimapContainerFrame.widgetFrames) do
            if widget.widgetType == Enum.UIWidgetVisualizationType.CaptureBar then skinCaptureBar(nil, widget) end
        end
    end

    local skinFrame = CreateFrame("Frame")
    skinFrame:RegisterEvent("UPDATE_UI_WIDGET")
    skinFrame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
    skinFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    skinFrame:SetScript("OnEvent", updateWidgets)

    hooksecurefunc(UIWidgetTemplateStatusBarMixin, "Setup", function(widget) skinStatusBar(widget) end)

    hooksecurefunc(UIWidgetTemplateScenarioHeaderCurrenciesAndBackgroundMixin, "Setup", function(widgetInfo)
        widgetInfo.Frame:SetAlpha(0)
        for frame in widgetInfo.currencyPool:EnumerateActive() do
            frame.Icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        end
    end)
end
