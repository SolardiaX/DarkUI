----------------------------------------------------------------------------------------
--	Configuration of DataTexts
----------------------------------------------------------------------------------------
local E, C, L = select(2, ...):unpack()

local function class(string)
    local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass('player'))]
    return format("|cff%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, string or "")
end

local stats = {
    ["enable"]               = true,
    ["latency"]              = true, -- Latency
    ["memory"]               = true, -- Memory
    ["fps"]                  = true, -- FPS
    ["friend"]               = true, -- Friends
    ["guild"]                = true, -- Guild

    ["location"]             = true, -- Location
    ["coords"]               = true, -- Coords

    ["stats"]                = true, -- Stats
    ["talents"]              = true, -- Talents
    ["loot"]                 = true, -- Loot
    ["nameplates"]           = true, -- Nameplates

    ["gold"]                 = true, -- gold
    ["bags"]                 = true, -- bags
    ["durability"]           = true, -- Durability

    ["currency_archaeology"] = false, -- Show Archaeology Fragments under currency tab
    ["currency_cooking"]     = true, -- Show Cooking Awards under currency tab
    ["currency_professions"] = true, -- Show Profession Tokens under currency tab
    ["currency_raid"]        = true, -- Show Seals under currency tab
    ["currency_pvp"]         = true, -- Show PvP Currency under currency tab
    ["currency_misc"]        = true, -- Show Miscellaneous Currency under currency tab
}

C.stats = stats

C.stats.font = {
    font    = STANDARD_TEXT_FONT, -- Path to your font
    color   = { 1, 1, 1 }, -- {red, green, blue} or "CLASS"
    size    = 12, -- Point font size
    alpha   = 1, -- Alpha transparency
    outline = 3, -- Thin outline. 0 = no outline.
    shadow  = { alpha = 1, x = 1, y = -1 }, -- Font shadow = 1
}

C.stats.icon_size = 12                        -- Icon sizes in info tips

C.stats.config = {
    -- Bottomleft block
    Latency    = {
        enable       = stats.latency,
        fmt          = "[color]%d|r" .. class "ms", -- "77ms", [color] inserts latency color code
        anchor_frame = "UIParent", anchor_to = "bottomleft", anchor_from = "bottomleft",
        x_off        = 10, y_off = 10, tip_frame = "UIParent", tip_anchor = "BOTTOMLEFT", tip_x = 21, tip_y = 20
    },
    Memory     = {
        enable       = stats.memory,
        fmt_mb       = "%.1f" .. class "mb", -- "12.5mb"
        fmt_kb       = "%.0f" .. class "kb", -- "256kb"
        max_addons   = nil, -- Holding Alt reveals hidden addons
        anchor_frame = stats.latency and "Latency" or "UIParent",
        anchor_to    = stats.latency and "left" or "bottomleft",
        anchor_from  = stats.latency and "right" or "bottomleft",
        x_off        = 10,
        y_off        = stats.latency and 0 or 10,
        tip_frame    = "UIParent", tip_anchor = "BOTTOMLEFT", tip_x = 21, tip_y = 20
    },
    FPS        = {
        enable       = stats.fps,
        fmt          = "%d" .. class "fps", -- "42fps"
        anchor_frame = stats.memory and "Memory" or (stats.latency and "Latency" or "UIParent"),
        anchor_to    = "bottomleft",
        anchor_from  = (stats.memory or stats.latency) and "bottomright" or "bottomleft",
        x_off        = 10,
        y_off        = (stats.memory or stats.latency) and 0 or 10,
    },
    Friends    = {
        enable       = stats.friend,
        fmt          = class "" .. L.DATATEXT_FRIEND .. "%d/%d", -- "F: 3/40"
        maxfriends   = nil, -- Set max friends listed, nil means no limit
        anchor_frame = stats.fps and "FPS" or stats.Memory and "Memory" or stats.latency and "Latency" or "UIParent",
        anchor_to    = "bottomleft",
        anchor_from  = (stats.fps or stats.memory or stats.latency) and "bottomright" or "bottomleft",
        x_off        = 10,
        y_off        = (stats.fps or stats.memory or stats.latency) and 0 or 10,
        tip_frame    = "UIParent", tip_anchor = "BOTTOMLEFT", tip_x = 21, tip_y = 20
    },
    Guild      = {
        enable       = stats.guild,
        fmt          = class "" .. L.DATATEXT_GUILD .. "%d/%d", -- "G: 5/114"
        maxguild     = nil, -- Set max members listed, nil means no limit. Alt-key reveals hidden members
        threshold    = 1, -- Minimum level displayed (1-90)
        show_xp      = true, -- Show guild experience
        sorting      = "class", -- Default roster sorting: name, level, class, zone, rank, note
        anchor_frame = stats.friend and "Friends" or stats.fps and "FPS" or stats.Memory and "Memory" or stats.latency and "Latency" or "UIParent",
        anchor_to    = "bottomleft",
        anchor_from  = (stats.friend or stats.fps or stats.memory or stats.latency) and "bottomright" or "bottomleft",
        x_off        = 10,
        y_off        = (stats.friend or stats.fps or stats.memory or stats.latency) and 0 or 10,
        tip_frame    = "UIParent", tip_anchor = "BOTTOMLEFT", tip_x = 21, tip_y = 20
    },

    -- MiniMap block
    Location   = {
        enable       = stats.location,
        subzone      = true, -- Set to false to display the main zone's name instead of the subzone
        truncate     = 0, -- Max number of letters for location text, set to 0 to disable
        anchor_frame = "Minimap", anchor_to = "top", anchor_from = "bottom",
        x_off        = 2, y_off = -24, tip_frame = "UIParent", tip_anchor = "CURSOR", tip_x = -21, tip_y = 20
    },
    Coords     = {
        enable       = stats.coords,
        fmt          = "%d, %d",
        anchor_frame = stats.location and "Location" or "Minimap", anchor_to = "top", anchor_from = "bottom",
        x_off        = 2,
        y_off        = stats.location and -4 or -24
    },

    -- Bottomright block
    Durability = {
        enable           = stats.durability,
        fmt              = L.DATATEXT_DURABILITY .. "[color]%d|r%%", -- "54%D", [color] inserts durability color code
        man              = true, -- Hide bliz durability man
        ignore_inventory = false, -- Ignore inventory gear when auto-repairing
        gear_icons       = false, -- Show your gear icons in the tooltip
        anchor_frame     = "UIParent", anchor_to = "bottomright", anchor_from = "bottomright",
        x_off            = -10, y_off = 10, tip_frame = "UIParent", tip_anchor = "BOTTOMRIGHT", tip_x = 21, tip_y = 20
    },
    Bags       = {
        enable       = stats.bags,
        fmt          = class "" .. L.DATATEXT_BAG .. "%d/%d",
        anchor_frame = stats.durability and "Durability" or "UIParent",
        anchor_to    = "bottomright",
        anchor_from  = stats.durability and "bottomleft" or "bottomright",
        x_off        = -10,
        y_off        = stats.durability and 0 or -10,
    },
    Gold       = {
        enable       = stats.gold,
        style        = 1, -- Display styles: [1] 55g 21s 11c [2] 8829.4g [3] 823.55.94
        anchor_frame = stats.bags and "Bags" or stats.durability and "Durability" or "UIParent",
        anchor_to    = "bottomright",
        anchor_from  = (stats.bags or stats.durability) and "bottomleft" or "bottomright",
        x_off        = -10,
        y_off        = (stats.bags or stats.durability) and 0 or -10,
        tip_frame    = "UIParent", tip_anchor = "BOTTOMRIGHT", tip_x = -21, tip_y = 20
    },
}

LPSTAT_PROFILES = {
    -- Main stats like agil, str > power. Stamina and bonus armor not listed even if higher pri then other stats. This is not a guide, just a pointer!
    DEMONHUNTER = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Mastery: " .. "[mastery]%" .. class "  Vers: " .. "[versatility]%",
            spec2fmt = class "Armor: " .. "[armor]" .. class " Mastery: " .. "[mastery]%" .. class "  Vers: " .. "[versatility]%",
        }
    },
    DEATHKNIGHT = {
        Stats = {
            spec1fmt = class "Armor: " .. "[armor]" .. class " Mastery: " .. "[mastery]%" .. class "  Vers: " .. "[versatility]%", --Blood 				-> Stamina > Bonus Armor = Armor > Strength > Versatility >= Multistrike >= Haste > Mastery > Crit
            spec2fmt = class "Power: " .. "[power]" .. class " Mastery: " .. "[mastery]%" .. class "  Vers: " .. "[versatility]%", -- Frost 				-> Strength > Mastery > Haste > Multistrike > Versatility > Crit
            spec3fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class " Mastery: " .. "[mastery]%", --Unholy 				-> Strength > Multistrike > Mastery > Crit >= Haste > Versatility
        }
    },
    DRUID       = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Mastery: " .. "[mastery]%" .. class "  Vers: " .. "[versatility]%", --Balance 			-> Intellect > Mastery >= Multistrike >= Crit >= Haste > Versatility
            spec2fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class "  Haste: " .. "[haste]%", -- Feral 					-> Agility > Crit >= Haste >= Multistrike > Versatility > Mastery
            spec3fmt = class "Armor: " .. "[armor]" .. class " Vers: " .. "[versatility]%" .. class " Mastery: " .. "[mastery]%", --Guardian 			-> Armor > Stamina > Multistrike > Bonus Armor > Mastery > Versatility >= Agility = Haste > Crit
            spec4fmt = class "Power: " .. "[power]" .. class " Haste: " .. "[haste]%" .. class " Mastery: " .. "[mastery]%", --Restoration 			-> Intellect > Haste > Mastery > Multistrike > Crit > Versatility > Spirit
        }
    },
    HUNTER      = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Mastery: " .. "[mastery]%" .. class "  Haste: " .. "[haste]%", --Beast Mastery		-> Agility > Haste = Mastery > Multistrike >= Crit > Versatility
            spec2fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class "  Crit: " .. "[crit]%", -- Marksmanship				-> Agility > Crit = Multistrike > Mastery >= Versatility >= Haste
            spec3fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class "  Crit: " .. "[crit]%", --Survival					-> Agility > Multistrike > Crit >= Versatility > Mastery > Haste
        }
    },
    MAGE        = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Mastery: " .. "[mastery]%" .. class " Haste: " .. "[haste]%", --Arcane				-> Intellect > Mastery >= Haste > Multistrike >= Crit > Versatility
            spec2fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class " Mastery: " .. "[mastery]%", -- Fire					-> Intellect > Crit > Mastery >= Haste > Multistrike > Versatility
            spec3fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class " Crit: " .. "[crit]%", --Frost						-> Intellect > Multistrike > Crit > Versatility > Haste > Mastery
        }
    },
    MONK        = {
        Stats = {
            spec1fmt = class "Armor: " .. "[armor]" .. class " Mastery: " .. "[mastery]%" .. class " Vers: " .. "[versatility]%", --Brewmaster		-> Stamina > Armor > Bonus Armor > Mastery > Versatility >= Agility > Crit >= Multistrike > Haste
            spec2fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class " Crit: " .. "[crit]%", -- Mistweaver				-> Intellect > Multistrike > Crit > Versatility > Haste > Mastery > Spirit
            spec3fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class " Vers: " .. "[versatility]%", --Windwalker					-> Agility > Crit = Multistrike > Versatility >= Haste > Mastery
        }
    },
    PALADIN     = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class " Vers: " .. "[versatility]%", -- Holy						-> Intellect > Crit > Multistrike > Mastery > Versatility > Haste > Spirit
            spec2fmt = class "Armor: " .. "[armor]" .. class " Haste: " .. "[haste]%" .. class " Vers: " .. "[versatility]%", -- Protection			-> Stamina > Bonus Armor > Armor > Haste >= Versatility >= Strength >= Mastery > Crit = Multistrike
            spec3fmt = class "Power: " .. "[power]" .. class " Mastery: " .. "[mastery]%" .. class " Vers: " .. "[versatility]%", -- Retribution			-> Strength > Mastery >= Multistrike > Crit >= Versatility > Haste
        }
    },
    PRIEST      = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class " Mastery: " .. "[mastery]%", -- Discipline				-> Intellect > Crit > Mastery > Multistrike > Versatility > Haste > Spirit
            spec2fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class " Mastery: " .. "[mastery]%", -- Holy				-> Intellect > Multistrike > Mastery > Crit > Versatility > Haste > Spirit
            spec3fmt = class "Power: " .. "[power]" .. class " Haste: " .. "[haste]%" .. class " Mastery: " .. "[mastery]%", -- Shadow				-> Intellect > Haste >= Mastery > Crit = Multistrike > Versatility
        }
    },
    ROGUE       = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class " Vers: " .. "[versatility]%", -- Assassination				-> Agility > Crit >= Multistrike > Mastery >= Haste = Versatility
            spec2fmt = class "Power: " .. "[power]" .. class " Haste: " .. "[haste]%" .. class " Vers: " .. "[versatility]%", -- Combat					-> Agility > Haste > Multistrike > Crit >= Mastery >= Versatility
            spec3fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class " Mastery: " .. "[mastery]%", -- Subtlety			-> Agility > Multistrike > Mastery > Versatility = Crit >= Haste
        }
    },
    SHAMAN      = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class " Vers: " .. "[versatility]%" .. class " Haste: " .. "[haste]%", -- Elemental				-> Intellect > Multistrike >= Haste > Crit > Versatility > Mastery
            spec2fmt = class "Power: " .. "[power]" .. class " Haste: " .. "[haste]%" .. class " Vers: " .. "[versatility]%", -- Enhancement				-> Agility > Haste > Multistrike >= Mastery > Versatility = Crit
            spec3fmt = class "Power: " .. "[power]" .. class " Crit: " .. "[crit]%" .. class " Mastery: " .. "[mastery]%", -- Restoration			-> Intellect > Crit > Mastery > Multistrike > Versatility > Haste > Spirit
        }
    },
    WARLOCK     = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class "  Haste: " .. "[haste]%" .. class "  Mastery: " .. "[mastery]%", -- Affliction			-> Intellect > Haste > Mastery > Multistrike > Crit > Versatility
            spec2fmt = class "Power: " .. "[power]" .. class "  Haste: " .. "[haste]%" .. class "  Mastery: " .. "[mastery]%", -- Demonology			-> Intellect > Haste > Mastery > Multistrike > Crit > Versatility
            spec3fmt = class "Power: " .. "[power]" .. class "  Crit: " .. "[crit]%" .. class "  Vers: " .. "[versatility]%", -- Destruction				-> Intellect > Crit > Multistrike >= Haste > Mastery >= Versatility
        }
    },
    WARRIOR     = {
        Stats = {
            spec1fmt = class "Power: " .. "[power]" .. class "  Crit: " .. "[crit]%" .. class "  Vers: " .. "[versatility]%", -- Arms					-> Strength > Crit > Multistrike > Haste > Versatility >= Mastery
            spec2fmt = class "Power: " .. "[power]" .. class "  Crit: " .. "[crit]%" .. class "  Haste: " .. "[haste]%", -- Fury						-> Strength > Crit > Haste > Mastery >= Multistrike > Versatility
            spec3fmt = class "Armor: " .. "[armor]" .. class "  Vers: " .. "[versatility]%" .. class "  Crit: " .. "[crit]%", -- Protection			-> Stamina > Bonus Armor >= Armor > Versatility > Strength > Crit >= Mastery > Multistrike > Haste
        }
    },
}
