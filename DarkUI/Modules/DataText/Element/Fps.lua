local E, C, L = select(2, ...):unpack()

------------------------------------------------------------------------
-- FPS
------------------------------------------------------------------------

local module = E:Module("DataText")

local format = format
local floor = floor
local GetFramerate = GetFramerate

local cfg = module.config.FPS

module:Inject("FPS", {
    text = {
        string = function()
            return format(cfg.fmt, floor(GetFramerate()))
        end,
    },
})
