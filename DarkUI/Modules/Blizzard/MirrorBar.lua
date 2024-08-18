local E, C, L = select(2, ...):unpack()

if not C.blizzard.custom_position then return end

----------------------------------------------------------------------------------------
--    Based on oMirrorBars(by Haste)
----------------------------------------------------------------------------------------
local module = E:Module("Blizzard"):Sub("MirrorBar")

local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"


local loadPosition = function(self, timer)
    local pos = C.blizzard.mirrorbar[string.lower(timer)].pos
    return self:SetPoint(unpack(pos))
end

local function SetupTimer(container, timer)
    local bar = container:GetAvailableTimer(timer)
    if not bar then return end

    if not bar.styled then
        bar:SetSize(198, 12)
        bar:StripTextures()
        bar:ClearAllPoints()

        -- bar.StatusBar:SetParent(bar.atlasHolder)
        bar.StatusBar:ClearAllPoints()
        bar.StatusBar:SetSize(198, 12)
        bar.StatusBar:SetPoint("CENTER")

        bar.Text:SetFont(STANDARD_TEXT_FONT, 10, "OUTLINE")
        bar.Text:SetShadowOffset(0, 0)
        bar.Text:SetJustifyH("CENTER")
        bar.Text:SetTextColor(1, 1, 1)
        bar.Text:ClearAllPoints()
        bar.Text:SetParent(bar.StatusBar)
        bar.Text:SetPoint("CENTER", bar.StatusBar, 0, 0)

        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(bar)
        bg:SetTexture(C.media.texture.status)
        bar.bg = bg

        local border = bar:CreateTexture(nil, "BORDER")
        border:SetPoint("CENTER")
        border:SetTexture(bar_border)
        border:SetSize(256 * bar:GetWidth() / 198, 64 * bar:GetHeight() / 12)
        bar.border = border

        loadPosition(bar, timer)

        bar.styled = true
    end

    local r, g, b = unpack(C.blizzard.mirrorbar[string.lower(timer)].color)
    bar.StatusBar:SetStatusBarTexture(C.media.texture.status)
    bar.StatusBar:SetStatusBarColor(r, g, b)
    bar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3)
end

hooksecurefunc(_G.MirrorTimerContainer, "SetupTimer", SetupTimer)
