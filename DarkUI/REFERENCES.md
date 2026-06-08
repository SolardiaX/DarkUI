# DarkUI References

Records which modules or files reference external addon implementations.
Used for finding original sources when iterating or fixing bugs.

## Map

| File | Reference | Notes |
|------|-----------|-------|
| `Modules/Map/WorldMap.lua` | NDui `Modules/Maps/WorldMap.lua` | Coords, scale, UIPanel removal, fog removal logic |
| `Modules/Map/WorldMapData.lua` | NDui `Modules/Maps/RawMapData.lua` | Fog removal zone texture data |
| `Modules/Map/WorldMapRewardIcon.lua` | BetterWorldQuests (provider/pin/poi/events) | World quest reward icons, POI/event providers |
| `Modules/Map/Minimap.lua` | NDui `Modules/Maps/Minimap.lua` | RecycleBin, icon layout patterns |

## Actionbar

| File | Reference | Notes |
|------|-----------|-------|
| `Modules/Actionbar/Bars.lua` | LibActionButton-1.0 (nevcairiel), ElvUI | Button creation; dynamic bar index pattern |
| `Modules/Actionbar/StyleRange.lua` | tullaCC | Out of range color check |
| `Modules/Actionbar/StyleCooldown.lua` | tullaCC | Cooldown count display |
| `Modules/Actionbar/BarLeaveVehicle.lua` | ShestakUI, NDui | Leave vehicle button, modern tooltip API |
| `Modules/Actionbar/BarMicroMenu.lua` | ShestakUI, NDui | Micro menu bar layout |
| `Modules/Actionbar/BarPet.lua` | ShestakUI, NDui, ElvUI | Pet action bar, highlight wrapper, AutoCast compat |
| `Modules/Actionbar/BarStance.lua` | ElvUI | Desaturation for unavailable forms |
| `Modules/Actionbar/Actionbar.lua` | ElvUI (Simpy) | `disableDefaultBarEvents` pattern |

## Aura

| File | Reference | Notes |
|------|-----------|-------|
| `Modules/Aura/CoolDownViewer.lua` | Blizzard `CooldownViewer` system | Restyle EssentialCooldownViewer, UtilityCooldownViewer, BuffIcon/BuffBar viewers |

## Unitframe

| File | Reference | Notes |
|------|-----------|-------|
| `Modules/Unitframe/Core.lua` | NDui `Modules/UFs/Functions.lua`, `Elements/Castbar.lua` | Empower pips, castbar ticks, kick CD color, SetVertexColorFromBoolean |
| `Modules/Unitframe/Class.lua` | Blizzard `Blizzard_UnitFrame/Mainline/ClassPowerBar.lua`, `PlayerFrame.lua` | Reparent PlayerFrameBottomManagedFramesContainer, UNIT_DISPLAYPOWER relay |
| `Modules/Unitframe/Tags.lua` | NDui `Modules/UFs/Tags.lua` | Secret value safe HP/PP tags |
| `Modules/Unitframe/Nameplate.lua` | NDui `Modules/UFs/Nameplates.lua`, ElvUI `Nameplates/Plugins/PVPRole.lua` | Totem data, kick CD, BG healer |
| `Modules/Unitframe/Boss.lua` | NDui `Modules/UFs/Functions.lua`, ShestakUI `Modules/UnitFrames/Layout.lua` | CastBar with tex_bar_border, Buffs/Debuffs split, PrivateAuras |
| `Modules/Unitframe/Focus.lua` | NDui `Modules/UFs/Functions.lua` | CastBar below frame with tex_bar_border |
| `Modules/Unitframe/Raid.lua` | NDui `Modules/UFs/Spawns.lua` | CompactRaidFrame hiding, PrivateAuras |
| `Modules/Unitframe/Player.lua` | ShestakUI, NDui `Modules/UFs/Functions.lua` | Texture-based frame style, AdditionalPower AbbreviateNumbers pattern, PrivateAuras |
| `Modules/Unitframe/Target.lua` | ShestakUI | Texture-based frame style |

## Core

| File | Reference | Notes |
|------|-----------|-------|
| `Core/API.lua` | NDui `Core/Functions.lua` | SetTemplate, CreateShadow, pixel snap |

## Libs

| File | Reference | Notes |
|------|-----------|-------|
| `Libs/oUF/Plugins/DebuffHighlight.lua` | ShestakUI `Libs/oUF/Modules/DispelColor.lua` | ColorCurve + GetAuraDispelTypeColor, talent-aware dispel detection |
