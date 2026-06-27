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
        copy = path .. "tex_copy",
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
config.blankTex = config.texture.blank
config.glossTex = config.texture.blank -- ElvUI gloss statusbar tex; blank reads fine as a highlight
config.backdropfadecolor = { 0.06, 0.06, 0.06, 0.8 } -- ElvUI default faded-black backdrop
config.rgbvaluecolor = { E.myColor.r, E.myColor.g, E.myColor.b } -- theme/value color as {r,g,b}
config.normFont = STANDARD_TEXT_FONT -- ElvUI normFont path (FontTemplate(font, size, style))

-- ElvUI-compat: DarkUI always runs pixel mode, so PixelMode ternaries in ports
-- (`E.PixelMode and X or Y`) resolve to the pixel branch with no per-file edit.
E.PixelMode = true

-- ElvUI-compat no-op (ports assign it to neutralize a method, e.g. icon.SetTexCoord = E.noop)
E.noop = function() end

-- ElvUI-compat: minimal E.global so ports that branch on its options resolve.
-- disableTutorialButtons = false keeps DarkUI's existing behavior (hide the
-- tutorial-button Ring rather than Kill the whole button — see Binding.lua).
E.global = E.global or {}
E.global.general = E.global.general or {}
if E.global.general.disableTutorialButtons == nil then E.global.general.disableTutorialButtons = false end

-- ElvUI-compat: minimal E.private.skins for ports that branch on skin options.
-- checkBoxSkin = true so checkbox-texture branches take the skinned path.
E.private = E.private or {}
E.private.skins = E.private.skins or {}
if E.private.skins.checkBoxSkin == nil then E.private.skins.checkBoxSkin = true end

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
    Copy = config.texture.copy,
}

-- ElvUI-compat engine flags / tables referenced by Skins/Frames ports.
E.Retail = true
E.Border = 1 -- ElvUI pixel-mode border mult
E.Spacing = 0 -- ElvUI pixel-mode spacing
E.OtherAddons = E.OtherAddons or {} -- ports test E.OtherAddons.<name>; empty = none detected
E.Libs = E.Libs or {}
E.Libs.CustomGlow = E.Libs.CustomGlow or (LibStub and LibStub("LibCustomGlow-1.0", true))

-- ElvUI-compat: gem socket border colors (Socket.lua: E.GemTypeInfo[gemColor])
E.GemTypeInfo = {
    Yellow = { r = 0.97, g = 0.82, b = 0.29, a = 1 },
    Red = { r = 1.00, g = 0.47, b = 0.47, a = 1 },
    Blue = { r = 0.47, g = 0.67, b = 1.00, a = 1 },
    Hydraulic = { r = 1.00, g = 1.00, b = 1.00, a = 1 },
    Cogwheel = { r = 1.00, g = 1.00, b = 1.00, a = 1 },
    Meta = { r = 1.00, g = 1.00, b = 1.00, a = 1 },
    Prismatic = { r = 1.00, g = 1.00, b = 1.00, a = 1 },
    PunchcardRed = { r = 1.00, g = 0.47, b = 0.47, a = 1 },
    PunchcardYellow = { r = 0.97, g = 0.82, b = 0.29, a = 1 },
    PunchcardBlue = { r = 0.47, g = 0.67, b = 1.00, a = 1 },
    Domination = { r = 0.24, g = 0.50, b = 0.70, a = 1 },
    Cypher = { r = 1.00, g = 0.80, b = 0.00, a = 1 },
    Tinker = { r = 1.00, g = 0.47, b = 0.47, a = 1 },
    Primordial = { r = 1.00, g = 0.00, b = 1.00, a = 1 },
    Fragrance = { r = 1.00, g = 1.00, b = 1.00, a = 1 },
    SingingThunder = { r = 0.97, g = 0.82, b = 0.29, a = 1 },
    SingingSea = { r = 0.47, g = 0.67, b = 1.00, a = 1 },
    SingingWind = { r = 1.00, g = 0.47, b = 0.47, a = 1 },
    Fiber = { r = 0.90, g = 0.80, b = 0.50, a = 1 },
}

C.media = config
E.media = config
