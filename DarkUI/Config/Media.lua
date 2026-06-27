local E, C, L = select(2, ...):unpack()

----------------------------------------------------------------------------------------
-- Media
----------------------------------------------------------------------------------------

local path = "Interface\\Addons\\" .. E.addonName .. "\\Media\\"

local config = {
    path = path,

    text_color = { 0.9, 0.7, 0.15, 1 },
    border_color = { 0, 0, 0, 1 },
    backdrop_color = { 0.08, 0.08, 0.1, 0.92 }, --{ 0, 0, 0, 0.75 },
    overlay_color = { 0, 0, 0, 0.45 },
    highlight_color = { 1, 1, 1, 0.35 },
    shadow_color = { 0, 0, 0, 0.88 },
    gradient_color = { 0.8, 0.8, 0.8, 0.15 },
    gradient_color_light = { 0.8, 0.8, 0.8, 0.28 },
    button_border_color = { 0.12, 0.12, 0.15, 1 },
    vertex_color = { 140 / 255, 118 / 255, 110 / 255 },

    texCoord = { 0.08, 0.92, 0.08, 0.92 },

    standard_font = { STANDARD_TEXT_FONT, 14, "THINOUTLINE" },

    button = {
        border = path .. "btn_border",
        glow = path .. "btn_glow",
        normal = path .. "btn_normal",
        hover = path .. "btn_hover",
        flash = path .. "btn_flash",
        pushed = path .. "btn_pushed",
        checked = path .. "btn_checked",
        equipped = path .. "btn_gloss_grey",
        buttonback = path .. "btn_background",
        buttonbackflat = path .. "btn_background_flat",
        outer_shadow = path .. "btn_outer_shadow",
        vehicle_exit = path .. "btn_vehicleexit",
    },

    texture = {
        overlay = path .. "tex_overlay",
        border_thin = path .. "tex_border_thin",
        border_thin_white = path .. "tex_border_thin_white",
        border_line = path .. "tex_border_line",
        border_line_white = path .. "tex_border_line_white",
        border_regular = path .. "tex_border_regular",
        border_bold = path .. "tex_border_bold",
        border_bolder = path .. "tex_border_bolder",
        border_round = path .. "tex_border_round",
        border_round_white = path .. "tex_border_round_white",
        status = path .. "tex_status",
        status_f = path .. "tex_status_f",
        status_s = path .. "tex_status_s",
        status_b = path .. "tex_status_b",
        status_bg = path .. "tex_status_bg",
        blank = path .. "tex_blank",
        empty = path .. "tex_empty",
        close = path .. "tex_close",
        gray = path .. "tex_gray",
        gradient = path .. "tex_gradient",
        gradient_rev = path .. "tex_gradient_rev",
        shadow = path .. "tex_shadow",
        class_spec = path .. "tex_class_spec",
        arrow = path .. "tex_arrow",
        plus = path .. "tex_plus",
        minus = path .. "tex_minus",
        spark = path .. "tex_spark",
        play = path .. "tex_play",
        pause = path .. "tex_pause",
        reset = path .. "tex_reset",
    },
}

config.qualityColors = {}
local qualityColors = BAG_ITEM_QUALITY_COLORS
for index, value in pairs(qualityColors) do
    config.qualityColors[index] = { r = value.r, g = value.g, b = value.b }
end
config.qualityColors[-1] = { r = 0, g = 0, b = 0 }
config.qualityColors[Enum.ItemQuality.Poor] = { r = COMMON_GRAY_COLOR.r, g = COMMON_GRAY_COLOR.g, b = COMMON_GRAY_COLOR.b }
config.qualityColors[Enum.ItemQuality.Common] = { r = 0, g = 0, b = 0 }
config.qualityColors[99] = { r = 1, g = 0, b = 0 }

-- ElvUI-compat aliases (for near-verbatim Skins/Frames ports)
config.normTex = config.texture.blank
config.bordercolor = config.border_color

-- ElvUI-compat: DarkUI always runs pixel mode, so PixelMode ternaries in ports
-- (`E.PixelMode and X or Y`) resolve to the pixel branch with no per-file edit.
E.PixelMode = true

-- ElvUI-compat E.Media.Textures table: ports reference E.Media.Textures.<Name>.
-- Mapped to our own media so the perl transform stays mechanical. Names ElvUI
-- ships that have no DarkUI equivalent (Dashboard/Catalog/PetBroom/…) are left
-- unmapped on purpose — those ports handle them per-file (see SYNC.md).
E.Media = E.Media or {}
E.Media.Textures = {
    Invisible = config.texture.empty,
    White8x8 = config.texture.blank,
    NormTex = config.texture.blank,
    ArrowUp = config.texture.arrow,
    Melli = config.texture.close,
    PlusButton = config.texture.plus,
    MinusButton = config.texture.minus,
    Play = config.texture.play,
    Pause = config.texture.pause,
    Reset = config.texture.reset,
}

C.media = config
E.media = config
