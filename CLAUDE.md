# DarkUI Addon Development

## Project Context
DarkUI is a personal WoW UI overhaul addon targeting retail (The War Within / Midnight).
Current game version: **12.0** (Interface `120001`).

## Critical API Rules for WoW 12.0

### Secret Values
- Always check `issecretvalue(value)` before arithmetic on UnitHealth/UnitPower returns
- Use `UnitHealthPercent()` / `UnitPowerPercent()` as safe alternatives
- `ColorCurve` and `Curve` APIs for secret-aware visual calculations

### Removed Globals → C_ActionBar
All bare action functions (`GetVehicleBarIndex`, `HasAction`, `IsActionInRange`, `GetActionCooldown`, etc.) moved to `C_ActionBar.*`

### CLEU Removed
`CombatLogGetCurrentEventInfo()` is gone. Use unit-based events (`UNIT_SPELLCAST_*`, `UNIT_HEALTH`, etc.)

### C_Spell.GetSpellInfo Returns Table
```lua
-- WRONG: local name, _, icon = GetSpellInfo(id)
-- RIGHT:
local info = C_Spell.GetSpellInfo(id)
if info then name = info.name; icon = info.iconID end
```

### UnitAura Deprecated
Use `C_UnitAuras.GetAuraDataByAuraInstanceID()` / `GetBuffDataByIndex()` / `GetDebuffDataByIndex()`

### Battlefield APIs Removed
`GetNumBattlefieldScores` / `GetBattlefieldScore` — use `C_PvP` namespace

### BackdropTemplate
Still valid. Frames must inherit `"BackdropTemplate"` or `Mixin(f, BackdropTemplateMixin)`.

## Code Style

### General
- Lua 5.1 (WoW embedded)
- Module pattern: `local E, C, L = select(2, ...):unpack()`
- Use `E:Module("Name")` system for module creation
- Formatting: StyLua (`.stylua.toml` in project root), run `.tools/stylua DarkUI/ DarkUI_Options/`

### File Structure
- File header: `--------` divider block wrapping a single `-- Title` line
- Use `--------` divider blocks to separate major functional sections within a file
- File-level declarations (after header): lib references, constants, config references, local state tables
- All executable code (Frame creation, event registration, hook, global assignment) must live inside lifecycle methods (`OnInit` / `OnEnable`), never at file top level

### Naming
- `local function` → **camelCase**: `createBar`, `updatePetBar`, `getTimeText`, `timerOnUpdate`
- `module:Method()` → **PascalCase**: `OnInit`, `OnEnable`, `StartButtonFlashing`, `UpdatePetActionButtonStates`
- Local variables → **camelCase**: `statusbar`, `buttonList`, `extraBar`
- Constants → **UPPER_SNAKE**: `ICON_SIZE`, `DAY`, `HOUR`

### Global Localization
Only localize when there is a **measurable benefit**:
- **Do** localize in OnUpdate / per-frame callbacks: `local GetTime = GetTime`, `local floor = math.floor`
- **Do** localize to shorten deep namespace paths used 3+ times: `local C_Spell_GetSpellInfo = C_Spell.GetSpellInfo`
- **Don't** localize for one-shot calls in OnInit/OnEnable or user-triggered handlers

### Module State
- Internal state (only used within the file) → file-level `local`: `local hideNumbers = {}`
- Shared state (accessed cross-file or needs lifecycle reset) → `module.xxx` or `self.xxx` in OnInit/OnEnable

### Config References

**Rule**: File top-level only holds table references to C sub-tables. Read primitive values at point of use, never cache them at file level — savedVariable overrides merge into C at ADDON_LOADED and table references will see updated values, but primitive copies are frozen.

**Do**:
```lua
-- file top: hold table reference
local cfg = C.unitframe

-- inside function: read value at point of use
function module:OnInit()
    self:SetScale(cfg.scale)
    local path = cfg.mediaPath .. "statusbar"
end
```

**Don't**:
```lua
-- WRONG: primitive copy at file level — frozen before overrides merge
local scale = C.unitframe.scale
local mediaPath = C.unitframe.mediaPath

function module:OnInit()
    self:SetScale(scale)           -- stale value
end
```

## Git Commit Convention
Format: `type: [Scope] description`

- **type**: `feat`, `fix`, `chore`, `refactor`, `docs`
- **Scope**: the primary module affected, e.g. `[Actionbar]`, `[Core]`, `[Unitframe]`, `[Options]`
- Use ONE scope (the most relevant), not multiple
- Description: concise, in English

Examples:
```
feat: [Actionbar] renown level
fix: [Unitframe] cooldown of nameplate
chore: bump to v11.1.5-b1.0.6
feat: [Options] adjust gui size
```

## References

`DarkUI/REFERENCES.md` records which external addons each module references.
When adding new modules or updating existing ones based on external code, update this file.
Use it to find original sources when iterating features or fixing bugs.
