local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- Timer Tracker
------------------------------------------------------------------------

local module = E:Module("Blizzard"):Sub("TimerTracker")

local cfg = C.blizzard

------------------------------------------------------------------------
-- Skin
------------------------------------------------------------------------

local function skinBar(bar)
    if bar.skinned then return end

    for i = 1, bar:GetNumRegions() do
        local region = select(i, bar:GetRegions())
        if region:IsObjectType("Texture") then
            region:SetTexture(nil)
        elseif region:IsObjectType("FontString") then
            region:SetFont(STANDARD_TEXT_FONT, 13, "OUTLINE")
            region:SetShadowOffset(0, 0)
        end
    end

    bar:SetStatusBarTexture(C.media.texture.status)
    bar:SetStatusBarColor(0.7, 0, 0)
    bar:SetHeight(18)
    bar:CreateBackdrop("Transparent")
    bar:CreateBorder()

    bar.skinned = true
end

------------------------------------------------------------------------
-- Lifecycle
------------------------------------------------------------------------

function module:OnInit()
    if not cfg.custom_position then return end

    self:RegisterEvent("START_TIMER", function()
        for _, b in pairs(TimerTracker.timerList) do
            if b.bar and not b.bar.skinned then
                skinBar(b.bar)
            end
        end
    end)
end
