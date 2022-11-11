local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end

----------------------------------------------------------------------------------------
--	Reposition Capture Bar
----------------------------------------------------------------------------------------
local _G = _G
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local unpack, select = unpack, select
local NUM_EXTENDED_UI_FRAMES = NUM_EXTENDED_UI_FRAMES

local function SkinCaptureBar(previous, widget)
    if widget and widget:IsVisible() then
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

            widget.LeftBar:SetTexture(C.media.texture.gradient)
            widget.NeutralBar:SetTexture(C.media.texture.gradient)
            widget.RightBar:SetTexture(C.media.texture.gradient)

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
end


local host = CreateFrame("Frame")
host:RegisterEvent("UPDATE_UI_WIDGET")
host:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
host:RegisterEvent("PLAYER_ENTERING_WORLD")
host:SetScript("OnEvent", function()
    for _, widget in pairs(UIWidgetBelowMinimapContainerFrame.widgetFrames) do
        local previous = nil
        if widget.widgetType == Enum.UIWidgetVisualizationType.CaptureBar then
            skinCaptureBar(previous, widget)
            if previous == nil then previous = widget end
        end
    end
end)