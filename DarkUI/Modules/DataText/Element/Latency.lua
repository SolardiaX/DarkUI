local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.Latency.enable then return end

----------------------------------------------------------------------------------------
--	Latency of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------

local GetNetStats = GetNetStats
local format, gsub, max = format, gsub, math.max
local MAINMENUBAR_LATENCY_LABEL = MAINMENUBAR_LATENCY_LABEL
local GameTooltip = GameTooltip

local cfg = C.stats.config.Latency
local module = E.datatext

module:Inject("Latency", {
    text    = {
        string = function()
            local _, _, latencyHome, latencyWorld = GetNetStats()
            local lat = max(latencyHome, latencyWorld)
            return format(gsub(cfg.fmt, "%[color%]", (module:Gradient(1 - lat / 750))), lat)
        end
    },
    OnEnter = function(self)
        local _, _, latencyHome, latencyWorld = GetNetStats()
        local latency = format(MAINMENUBAR_LATENCY_LABEL, latencyHome, latencyWorld)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:ClearAllPoints()
        GameTooltip:SetPoint(cfg.tip_anchor, cfg.tip_frame, cfg.tip_x, cfg.tip_y)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(latency, module.tthead.r, module.tthead.g, module.tthead.b)
        GameTooltip:Show()
    end,
})