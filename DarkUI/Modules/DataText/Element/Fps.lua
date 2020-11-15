local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.FPS.enable then return end

----------------------------------------------------------------------------------------
--	FPS of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------

local format = format
local floor = floor
local GetFramerate = GetFramerate

local cfg = C.stats.config.FPS
local module = E.datatext

module:Inject("FPS", {
    text = {
        string = function()
            return format(cfg.fmt, floor(GetFramerate()))
        end
    },
})
