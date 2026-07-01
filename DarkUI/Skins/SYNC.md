# Skins Porting Guide (AuroraClassic → DarkUI)

DarkUI's `Skins/Frames/*.lua` originated as ports of AuroraClassic's
`AddOns/*.lua` and `FrameXML/*.lua`. This file is the recipe for porting a panel
and for re-syncing one when upstream AuroraClassic changes.

Ports call **DarkUI's own API** — the `S:Reskin*` facade and the `C.media`
constants — not Aurora's `B.*`/`DB.*`. Divergence from upstream is a fixed set of
mechanical transforms: keep the port's structure close to Aurora *except* for
these, so a re-sync is "diff upstream → re-apply transforms".

## How a port fits

- `Skins/Core.lua` — the `S` module: the per-addon dispatcher
  (`AddCallback`/`AddCallbackForAddon`/`OnEnable`, pcall-isolated) **plus** the
  `S:Reskin*` facade. The facade routes to DarkUI's own `E:Reskin*`/`E:Style*`
  engine + the quality-border system, so every panel gets the DarkUI look
  (textured backdrop + shadow + round_white quality edge).
- `Skins/Frames/<Name>.lua` — one Blizzard panel skin.
- `Skins/_load_.xml` order: `Core.lua` → each `Frames/*.lua`.

## Port file boilerplate

```lua
local E, C, L = select(2, ...):unpack()
local S = E:GetModule("Skins")
local cr, cg, cb = E.myColor.r, E.myColor.g, E.myColor.b  -- only if the port uses them

function S:SomePanel()
    if not C.general.skins then return end
    -- … panel body …
end
S:AddCallbackForAddon("Blizzard_SomePanel", "SomePanel")  -- on-demand addon
-- or, for FrameXML (always-loaded) panels: S:AddCallback("SomePanel")
```

## Deterministic transforms (apply on every port / re-sync)

| Aurora source | DarkUI port |
|---|---|
| `local _, ns = ...` + `local B, C, L, DB = unpack(ns)` | `local E, C, L = select(2, ...):unpack()` + `local S = E:GetModule("Skins")` |
| `C.themes["Blizzard_X"] = function() … end` | `function S:X() <config gate> … end` + `S:AddCallbackForAddon("Blizzard_X", "X")` |
| `tinsert(C.defaultThemes, function() … end)` (FrameXML, immediate) | `function S:X() … end` + `S:AddCallback("X")` |
| `B.Reskin(f)` | `S:ReskinButton(f)` |
| `B.SetBD(f)` | `S:CreateBackground(f)` |
| `B.ReskinScroll(f)` / `B.ReskinTrimScroll(f)` | `S:ReskinScrollBar(f)` / `S:ReskinTrimScrollBar(f)` |
| other `B.ReskinX(f, …)` | `S:ReskinX(f, …)` (same name) |
| `B.StripTextures(f)` / `B.CreateBDFrame(f)` / `B.CreateSD(f)` | `f:StripTextures()` / `f:CreateBackdrop()` / `f:CreateShadow()` |
| `B.HideObject(f)` | `f:Kill()` |
| `f.styled` guard | `f.__styled` |
| `DB.bdTex` / `DB.QualityColors` / `C.mult` | `C.media.texture.blank` / `C.media.qualityColors` / `E.mult` (see table below) |
| (Aurora has no per-panel switch) | first line: `if not C.general.skins then return end` |

## S:Reskin* facade methods

Routing facades to the DarkUI engine: `ReskinButton`, `ReskinTab`,
`ReskinScrollBar`, `ReskinTrimScrollBar`, `ReskinDropDown`,
`ReskinEditBox`/`ReskinInput`, `ReskinSlider`, `ReskinStatusBar`, `ReskinCheck`,
`ReskinClose`, `ReskinPortraitFrame`, `ReskinNavBar`, `CreateBackground`.

Quality-border / icon look: `ReskinIcon` (→ backdrop), `ReskinIconBorder` (tints
the backdrop edge by quality), `ReskinItemButton` (full item slot),
`ReskinArrow`/`ReskinNextPrevButton`, `ReskinFilterButton`, `ReskinFilterReset`,
`ReskinMenuButton`, `ReskinColorSwatch`, `ReskinRadio`, `ReskinStepperSlider`,
`ReskinCollapse`, `ReskinMinMax`, `ReskinRotateButton`, `ReskinGarrisonPortrait`,
`ReskinRole`/`ReskinSmallRole`, `StyleSearchButton`, `AffixesSetup`,
`ClassIconTexCoord`, `CreateAndUpdateBarTicks`, `SetupArrow`,
`ReskinIconSelectionFrame`, `ReskinModelSceneControlButtons`, `OverlayButton`,
`SkinReadyDialog`, `ReskinBlizzardRegions`.

Metatable atoms (Core/API.lua) ports call directly: `:CreateBackdrop`,
`:CreateShadow`, `:CreateBorder`, `:CreateGradient`, `:StripTextures`,
`:StripTexts`, `:Kill`, `:SetInside`, `:SetOutside`, `:SetTemplate`,
`:SetBackdropEdge`, `:SetTexCoords`, `:FontTemplate`. Geometry uses the native
WoW widget API (`:SetPoint`, `:SetSize`, …), not shorthands.

## Constants (Aurora DB.* → DarkUI, read directly at the call site)

`bdTex`/`bgTex`/`normTex`/`glowTex` → `C.media.texture.blank`; `closeTex` →
`C.media.texture.close`; `ArrowUp` → `C.media.texture.arrow`; `sparkTex` →
`C.media.texture.spark`; `TexCoord` → `C.media.texCoord`; `QualityColors` →
`C.media.qualityColors`; `r`/`g`/`b` → `E.myColor.r`/`.g`/`.b`.

## Manual-judgment items (not mechanical)

- **Gating:** every `S:X()` starts with `if not C.general.skins then return end` — one
  global skins switch, no per-panel keys.
- **Frames DarkUI already owns — do NOT port** (would double-skin / conflict):
  Bags, Tooltip, WorldMap, ObjectiveTracker, Alerts, TalkingHead, MirrorTimers,
  CooldownManager, Loot, Chat, Quest. These live under `Modules/`.
- **Aurora media DarkUI lacks** (e.g. its noise `CreateTex` overlay): drop it —
  DarkUI's backdrop already carries the texture; note the drop in the port header.
- **Quality borders:** `S:ReskinIconBorder` flat-colors the icon's backdrop edge
  (round_white) by quality — it hides the native border and hooks
  SetAtlas/SetVertexColor. Use `S:ReskinIcon` + `S:ReskinIconBorder` for slots, or
  `S:ReskinItemButton` for full item slots.
- **Fields:** the icon backdrop from `S:ReskinIcon` is stored at `frame.backdrop`;
  ports may keep a local handle (`x.bg = S:ReskinIcon(...)`). Do not reintroduce
  `.__bg` — use the frame itself as its own anchor, or `.backdrop`.

## Re-sync workflow

1. Record the AuroraClassic version + month in the port header.
2. Diff new-upstream vs the forked revision; identify real logic changes.
3. Re-apply the transforms above; `.tools/stylua DarkUI/ DarkUI_Options/`.
4. `/reload` and verify in-game.
