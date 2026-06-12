local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Mirror Bar
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("MirrorBar")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then
        return
    end

    local bar_border = C.media.path .. C.general.style .. "\\" .. "tex_bar_border"

    local function setupTimer(container, timer)
        local bar = container:GetAvailableTimer(timer)
        if not bar then
            return
        end

        if not bar.styled then
            bar:SetSize(200, 16)
            bar:StripTextures()
            bar:ClearAllPoints()

            bar.StatusBar:ClearAllPoints()
            bar.StatusBar:SetSize(200, 16)
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

            -- bar:CreateBackdrop("Transparent")
            -- bar:CreateBorder()
            bar.border = bar:CreateTexture(nil, "BORDER")
            bar.border:SetTexture(bar_border)
            bar.border:SetPoint("CENTER")

            local timerKey = string.lower(timer)
            local timerCfg = cfg.mirrorbar[timerKey]
            if timerCfg and timerCfg.pos then
                bar:SetPoint(unpack(timerCfg.pos))
            end

            bar.styled = true
        end

        local timerKey = string.lower(timer)
        local timerCfg = cfg.mirrorbar[timerKey]
        local r, g, b = 0.31, 0.45, 0.63
        if timerCfg and timerCfg.color then
            r, g, b = unpack(timerCfg.color)
        end
        bar.StatusBar:SetStatusBarTexture(C.media.texture.status)
        bar.StatusBar:SetStatusBarColor(r, g, b)
        bar.bg:SetVertexColor(r * 0.3, g * 0.3, b * 0.3)
    end

    hooksecurefunc(_G.MirrorTimerContainer, "SetupTimer", setupTimer)
end
