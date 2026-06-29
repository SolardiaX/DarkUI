# Skins Porting Guide (AuroraClassic → DarkUI)

DarkUI's `Skins/Frames/*.lua` are **near-verbatim ports** of AuroraClassic's
`AddOns/*.lua` and `FrameXML/*.lua`. This file is the recipe for porting a panel
and for re-syncing one when upstream AuroraClassic changes.

We keep **DarkUI's own engine and look** (textured backdrop + qb quality border),
not Aurora's flat fill. Divergence from upstream is therefore a fixed set of
mechanical transforms: keep ports byte-close to Aurora *except* for these, so a
re-sync is "diff upstream → re-apply transforms".

## How a port fits

- `Skins/Core.lua` — the `S` module: the per-addon dispatcher
  (`AddCallback`/`AddCallbackForAddon`/`OnEnable`, pcall-isolated) **plus** the
  `S:Reskin*` engine (Aurora's `B:Reskin*` set) and the `S.DB` constant map.
  `S:Reskin*` routes to DarkUI's own `E:Reskin*`/`E:Style*` primitives + the qb
  quality-border system, so the visual stays DarkUI.
- `Skins/Frames/<Name>.lua` — one Aurora skin file, ported.
- `Skins/_load_.xml` order: `Core.lua` → each `Frames/*.lua`.

## Port file boilerplate

```lua
local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local DB = S.DB                       -- Aurora DB.* constants
local cr, cg, cb = DB.r, DB.g, DB.b   -- only if the port uses them

function S:SomePanel()
    if not (C.skins.enable and C.skins.<key>) then return end
    -- … Aurora body, transformed …
end
S:AddCallbackForAddon("Blizzard_SomePanel", "SomePanel")  -- on-demand addon
-- or, for FrameXML (always-loaded) panels: S:AddCallback("SomePanel")
```

## Deterministic transforms (apply on every port / re-sync)

| Aurora source | DarkUI port |
|---|---|
| `local _, ns = ...` + `local B, C, L, DB = unpack(ns)` | `local E, C, L = select(2, ...):unpack()` + `local S = E:GetModule("Skins")` + `local DB = S.DB` |
| `C.themes["Blizzard_X"] = function() … end` | `function S:X() <config gate> … end` + `S:AddCallbackForAddon("Blizzard_X", "X")` |
| `tinsert(C.defaultThemes, function() … end)` (FrameXML, immediate) | `function S:X() … end` + `S:AddCallback("X")` |
| `B.ReskinX(frame, …)` | `S:ReskinX(frame, …)` |
| `B.StripTextures(f)` / `B.CreateBDFrame(f)` / `B.CreateSD(f)` / `B.SetBD(f)` | `f:StripTextures()` / `f:CreateBackdrop()` / `f:CreateShadow()` / `S:SetBD(f)` |
| `B.HideObject(f)` / `B.Reskin(f)` | `f:Kill()` / `S:Reskin(f)` |
| `f.styled` guard | `f.__styled` |
| `DB.bdTex` / `DB.QualityColors` / `C.mult` | `DB.bdTex` (via `S.DB`) / `DB.QualityColors` / `E.mult` |
| (Aurora has no per-panel switch) | first line: `if not (C.skins.enable and C.skins.<key>) then return end` |

## S:Reskin* methods (Aurora B: → DarkUI S:)

Routing facades to the DarkUI engine: `Reskin`, `ReskinTab`, `ReskinScroll`,
`ReskinTrimScroll`, `ReskinDropDown`, `ReskinEditBox`/`ReskinInput`, `ReskinSlider`,
`ReskinStatusBar`, `ReskinCheck`, `ReskinClose`, `ReskinPortraitFrame`, `ReskinNavBar`,
`SetBD`.

DarkUI-engine equivalents with the qb look: `ReskinIcon` (→ bg), `ReskinIconBorder`
(qb quality frame), `ReskinItemButton` (full item slot — DarkUI extra),
`ReskinArrow`/`ReskinNextPrevButton`, `ReskinFilterButton`, `ReskinFilterReset`,
`ReskinMenuButton`, `ReskinColorSwatch`, `ReskinRadio`, `ReskinStepperSlider`,
`ReskinCollapse`, `ReskinMinMax`, `ReskinRotateButton`, `ReskinGarrisonPortrait`,
`ReskinRole`/`ReskinSmallRole`, `StyleSearchButton`, `AffixesSetup`,
`ClassIconTexCoord`, `CreateAndUpdateBarTicks`, `SetupArrow`, `ReskinIconSelectionFrame`,
`ReskinModelSceneControlButtons`, `OverlayButton`, `SkinReadyDialog`,
`ReskinBlizzardRegions`.

Metatable atoms (Core/API.lua) ports call directly: `:CreateBackdrop`, `:CreateShadow`,
`:StripTextures`, `:StripTexts`, `:Kill`, `:SetInside`, `:SetOutside`, `:SetTemplate`,
`:Point`, `:Size`, `:Width`, `:Height`, `:SetTexCoords`, `:FontTemplate`, `:StyleButton`,
`:OffsetFrameLevel`.

## S.DB constant map (Aurora DB.* → DarkUI)

`bdTex`/`bgTex`/`normTex`/`glowTex` → `C.media.texture.blank`; `closeTex` → `.close`;
`ArrowUp` → `.arrow`; `sparkTex` → `.spark`; `TexCoord` → `C.media.texCoord`;
`QualityColors` → `C.media.qualityColors`; `r`/`g`/`b` → `E.myColor`.

## Manual-judgment items (not mechanical)

- **Config keys:** add/confirm a real `C.skins.<key>` in `Config/Settings.lua` for
  each panel; gate every `S:X()` on it.
- **Frames DarkUI already owns — do NOT port** (would double-skin / conflict):
  Bags, Tooltip, WorldMap, ObjectiveTracker, Alerts, TalkingHead, MirrorTimers,
  CooldownManager, Loot, Chat, Quest. These live under `Modules/`.
- **Aurora media DarkUI lacks** (e.g. its noise `CreateTex` overlay): drop it —
  DarkUI's backdrop already carries the texture; note the drop in the port header.
- **Quality borders:** Aurora `ReskinIconBorder` flat-colors a bg edge; our
  `S:ReskinIconBorder` drives the qb textured frame instead. Use `S:ReskinIcon` +
  `S:ReskinIconBorder` for slots, or `S:ReskinItemButton` for full item slots.

## Re-sync workflow

1. Record the AuroraClassic version + month in the port header.
2. Diff new-upstream vs the forked revision; identify real logic changes.
3. Re-apply the transforms above; `.tools/stylua DarkUI/Skins/Frames/<Name>.lua`.
4. `/reload` and verify in-game.
