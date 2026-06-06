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
| `Modules/Aura/AuraWatch.lua` | BetterCooldownManager, CooldownManagerCentered | Spell tracking framework |

## Core

| File | Reference | Notes |
|------|-----------|-------|
| `Core/API.lua` | NDui `Core/Functions.lua` | SetTemplate, CreateShadow, pixel snap |
