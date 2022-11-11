----------------------------------------------------------------------------------------
--  Configuration of Media
----------------------------------------------------------------------------------------
local E, C, L = select(2, ...):unpack()

local path = "Interface\\Addons\\" .. E.addonName .. "\\Media\\"

local config = {
    path            = path,

    text_color      = { 255 / 255, 234 / 255, 137 / 255 },
    vertex_color    = { 140 / 255, 118 / 255, 110 / 255 },
    border_color    = { 0, 0, 0, 1 },
    backdrop_color  = { 0, 0, 0, 0.75 },
    overlay_color   = { 0, 0, 0, 0.7 },
    highlight_color = { 1, 1, 1, 0.35 },
    shadow_color    = { 0, 0, 0, 0.88 },

    texCoord        = { 0.08, 0.92, 0.08, 0.92 },

    standard_font   = { STANDARD_TEXT_FONT, 12, "THINOUTLINE" },

    nameplate       = {
        arrow = path .. "uf_nameplate_arrow",
    },

    button          = {
        normal         = path .. "btn_gloss",
        flash          = path .. "btn_flash",
        hover          = path .. "btn_hover",
        pushed         = path .. "btn_pushed",
        checked        = path .. "btn_checked",
        equipped       = path .. "btn_gloss_grey",
        buttonback     = path .. "btn_background",
        buttonbackflat = path .. "btn_background_flat",
        outer_shadow   = path .. "btn_outer_shadow",
        vehicle_exit   = path .. "btn_vehicleexit",
    },

    texture         = {
        border            = path .. "tex_border",
        border_w          = path .. "tex_border_w",
        outer_border      = path .. "tex_outer_border",
        status            = path .. "tex_status",
        status_f          = path .. "tex_status_f",
        status_s          = path .. "tex_status_s",
        status_b          = path .. "tex_status_b",
        status_bg         = path .. "tex_status_bg",
        blank             = path .. "tex_blank",
        empty             = path .. "tex_empty",
        gray              = path .. "tex_gray",
        gradient          = path .. "tex_gradient",
        shadow            = path .. "tex_shadow",
        shadow_background = path .. "tex_shadow_background",
        shadow_lite       = path .. "tex_shadow_lite",
    },
}


config.qualityColors = {}
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
	config.qualityColors[index] = {r = value.r, g = value.g, b = value.b}
end
config.qualityColors[-1] = {r = 0, g = 0, b = 0}
config.qualityColors[Enum.ItemQuality.Poor] = {r = COMMON_GRAY_COLOR.r, g = COMMON_GRAY_COLOR.g, b = COMMON_GRAY_COLOR.b}
config.qualityColors[Enum.ItemQuality.Common] = {r = 0, g = 0, b = 0}
config.qualityColors[99] = {r = 1, g = 0, b = 0}

C.media = config
