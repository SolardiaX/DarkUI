local E, C, L = select(2, ...):unpack()

if not C.stats.enable or not C.stats.config.FPS.enable then return end

----------------------------------------------------------------------------------------
--    FPS of DataText (modified from ShestakUI)
----------------------------------------------------------------------------------------
local module = E:Module("DataText")

local format = format
local floor = floor
local GetFramerate = GetFramerate

local cfg = C.stats.config.FPS

module:Inject("FPS", {
    text = {
        string = function()
            return format(cfg.fmt, floor(GetFramerate()))
        end
    },
})
