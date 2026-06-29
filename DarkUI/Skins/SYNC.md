# Skins Re-Sync Guide (ElvUI → DarkUI)

DarkUI's `Skins/Frames/*.lua` are **near-verbatim ports** of ElvUI's
`Game/Mainline/Skins/*.lua`. This file is the recipe for porting a new frame
and for re-syncing an existing one when upstream ElvUI changes.

We keep **our own naming conventions** (we do not adopt ElvUI's field names).
Divergence from upstream is therefore deterministic and scriptable — that is the
whole point of this guide: keep ports byte-close to ElvUI *except* for a fixed
set of mechanical transforms, so re-sync is "diff upstream → re-apply transforms".

## Tracked upstream version

- **ElvUI `v15.15`** (the copy under `AddOns/ElvUI/`).
- Each port header records the version + month it was synced from, e.g.
  `-- Ported from ElvUI Mainline/Skins/Macro.lua (v15.15, 2026-06)`.
- To re-sync: `git -C ElvUI` is not available (it is a dropped-in copy), so diff
  the **new** ElvUI source file against the version noted in the port header by
  keeping the old copy aside, or read the upstream changelog for that file.

## How a port fits

- `Skins/Core.lua` — the `S` module: dispatcher (`AddCallback*`/`OnEnable`) +
  the `S:Handle*` compat layer. Ports only ever call `S:Handle*` and the
  method-form atoms; they never touch `Core/` `E:Reskin*`/`E:Style*` directly.
  **This insulates ports from Core renames** — keep it that way.
- `Skins/Frames/<Name>.lua` — one ElvUI skin file, ported.
- `Skins/_load_.xml` order: `Core.lua` → each `Frames/*.lua`.

## Compat layer (lets ports stay close to ElvUI)

These ElvUI-shaped APIs already exist so ported code needs no edit for them:

- **Skin entry points:** `S:HandleButton`, `S:HandleCloseButton`, `S:HandleTab`,
  `S:HandleEditBox`, `S:HandleScrollBar`, `S:HandleTrimScrollBar`,
  `S:HandleStatusBar`, `S:HandleFrame`, `S:HandlePortraitFrame`,
  `S:HandleInsetFrame`, `S:HandleSliderFrame`, `S:HandleCheckBox`,
  `S:HandleDropDownBox`, `S:HandleBlizzardRegions`, `S:HandleIcon`,
  `S:HandleItemButton`, `S:HandleIconSelectionFrame`, `S:HandleNextPrevButton`,
  `S:HandleRotateButton`, `S:HandleMaxMinFrame`, `S:HandleRadioButton`,
  `S:HandleStepSlider`, `S:HandleCollapseTexture`, …
- **Method-form atoms** (Core/API.lua metatable injection): `:Point`, `:Size`,
  `:Width`, `:Height`, `:SetTexCoords`, `:StripTexts`, `:FontTemplate`,
  `:StyleButton` (→ `E:StyleIconButton`), `:OffsetFrameLevel`, `:NudgePoint`,
  `:Kill`, `:StripTextures`, `:SetTemplate`, `:SetInside`, `:SetOutside`,
  `:CreateBackdrop`, `:CreateShadow`, `:CreateBorder`, `:CreateGradient`.
- **Engine helpers** (Core/API.lua / Core/Skin.lua `E:` methods):
  `E:GetItemQualityColor(quality)` → r,g,b from `C.media.qualityColors`
  (issecretvalue-guarded); `E:RegisterStatusBar()` → **no-op** (DarkUI has no
  runtime media hot-swap — ports set the bar texture manually, the call just
  needs to exist).
- **ElvUI hover handlers** (Skins/Core.lua): `S.SetModifiedBackdrop` /
  `S.SetOriginalBackdrop` — recolor `self.backdrop or self`'s border to the theme
  gold on enter / resting color on leave. Ports hook them on OnEnter/OnLeave.
- **Field / texture aliases:** `frame.backdrop` (DarkUI's canonical public field
  for `CreateBackdrop`/`CreateShadow`/`CreateBorder`/`CreateOverlay`/`CreateGradient`
  products — bare `.backdrop`/`.shadow`/`.border`/`.overlay`/`.gradient`, each its
  own created-once guard; `__`-prefixed names are reserved for private state),
  `button.hover` (alias of our `button.highlight` set by `:StyleButton()`),
  `E.media`, `E.ClearTexture`, `config.normTex`, `config.bordercolor`,
  `E.PixelMode = true` (so PixelMode ternaries resolve to the pixel branch),
  and `E.Media.Textures.<Name>` (Config/Media.lua) mapping the common ElvUI
  texture keys to ours: Invisible→empty, White8x8/NormTex→blank, ArrowUp→arrow,
  Melli→close, PlusButton→plus, MinusButton→minus, Play/Pause/Reset→tex_play/
  pause/reset (copied from ElvUI Shared/Media). Keys ElvUI ships that we lack
  (Dashboard/Catalog/PetBroom/Copy/Backpack/BagQuestIcon) are unmapped — handle
  those per-file.

If an upstream file calls an ElvUI API we have **not** provided, add the shim to
`Skins/Core.lua` (a thin `S:HandleX` routing to `E:Reskin*`/`E:Style*`) or
`Core/API.lua` (a method atom) — **do not** fork the logic inside the port.

## Deterministic transforms (apply on every port / re-sync)

| # | ElvUI source | DarkUI port | Why |
|---|---|---|---|
| 1 | `local E, L, V, P, G = unpack(ElvUI)` | `local E, C, L = select(2, ...):unpack()` | module bootstrap |
| 2 | `E:GetModule('Skins')` | `E:GetModule("Skins")` | double quotes (stylua) |
| 3 | `E.private.skins.blizzard.enable` | `C.skins.enable` | config system |
| 4 | `E.private.skins.blizzard.<key>` | `C.skins.<key>` | config system |
| 5 | `…parchmentRemoverEnable` | `C.skins.parchment_remover` | config key rename |
| 6 | `.IsSkinned` | `.__styled` | **our** unified skin guard |
| 7 | `.template` (marker field reads) | `.__template` | **our** template marker field |
| 8 | `S.Blizzard.Regions` | `S.BlizzardRegions` | our flat table name |

Starting point (review the diff afterwards, then run stylua — a blanket pass can
over-match, e.g. comments):

```sh
perl -pi -e '
  s/local E, L, V, P, G = unpack\(ElvUI\)/local E, C, L = select(2, ...):unpack()/;
  s/E\.private\.skins\.blizzard\.parchmentRemoverEnable/C.skins.parchment_remover/g;
  s/E\.private\.skins\.blizzard\.(\w+)/C.skins.$1/g;
  s/\.IsSkinned\b/.__styled/g;
  s/\bS\.Blizzard\.Regions\b/S.BlizzardRegions/g;
  s/\.template\b/.__template/g;   # field reads only — NOT :SetTemplate (colon-cased)
' DarkUI/Skins/Frames/<Name>.lua
.tools/stylua DarkUI/Skins/Frames/<Name>.lua
```

## Naming conventions ports MUST follow (our standard, not ElvUI's)

- **Skin guard:** `frame.__styled` (never `IsSkinned`). Shared by `E:Reskin*`,
  `E:Style*`, and `S:Handle*` so all layers recognize each other's work.
- **Template marker:** `frame.__template` (set by `:SetTemplate`).
- **Region list:** `S.BlizzardRegions` (flat array).
- Distinct one-shot sub-feature guards keep their own names where they may
  coexist with `__styled`: `__iconBorderHooked`, `collapsedSkinned`.

## Manual-judgment items (not mechanical)

- **Config keys:** map each `E.private.skins.blizzard.<x>` to a real key under
  `C.skins` in `Config/Settings.lua`; add the key if missing.
- **Frames DarkUI already owns — do NOT port** (would double-skin / conflict):
  Bags, Tooltip, WorldMap, ObjectiveTracker, Alerts, TalkingHead, MirrorTimers,
  CooldownManager, Loot.
- **Cosmetic drops:** ElvUI tweaks that fight DarkUI's look may be dropped — note
  it in the port header (see Merchant.lua dropping the quest-icon texture swap).
- **EditBox:** our `E:ReskinEditBox` is simpler than ElvUI `HandleEditBox` (no
  per-type backdrop positioning for SendMail money fields). If a synced frame
  relies on that, special-case it in the port, not in Core.
- **Multi-arg `CreateBackdrop`:** ElvUI's signature is
  `CreateBackdrop(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUFE, isNP, noScale, allPoints, frameLevel)`;
  ours is `(frame, template, margin, tile, frameLevel)` — positions 3+ differ.
  Calls that only pass `template` map cleanly. **Danger:** a boolean in ElvUI
  position 4 (`forcePixelMode`) lands on our `frameLevel` → `SetFrameLevel(true)`
  **crashes**. Rewrite: drop the trailing booleans. For `allPoints=true`, use
  `:CreateBackdrop(template)` + `:backdrop:SetAllPoints()`. `glossTex` — drop it.
- **`backdrop.Center` / `X.Center` after SetTemplate — CRITICAL:** ElvUI's
  `SetTemplate`/`CreateBackdrop` build the backdrop from individual textures
  (`.Center`, `.bordertop`, …); DarkUI uses a `BackdropTemplate` (`SetBackdrop`)
  with **no sub-textures**. Any `frame.backdrop.Center:…` or (after `:SetTemplate()`)
  `frame.Center:…` dereferences nil and **crashes**. **Drop these lines** — the
  draw-layer reordering they did is moot (our bg sits at BACKGROUND already).
  Grep every port for `\.Center\b` before shipping.
- **`E.PixelMode` / `E.Border` / `E.Spacing`:** all compat globals now —
  `E.PixelMode = true`, `E.Border = 1`, `E.Spacing = 0` (pixel-mode values), so
  both ternaries and standalone arithmetic resolve with **no edit**.
- **`E:RegisterStatusBar` / `E:RegisterCooldown`:** both no-op compat shims — keep
  the call verbatim; the manual texture set still does the real work. DarkUI owns
  cooldown styling (CooldownManager) and has no runtime statusbar media swap.
- **Other compat globals/aliases** (Config/Media.lua) so ports stay mechanical:
  `E.noop`, `E.Retail = true`, `E.OtherAddons = {}`, `E.global.general.disableTutorialButtons = false`,
  `E.private.skins.checkBoxSkin = true`, `E.Libs.CustomGlow` (our bundled LibCustomGlow),
  `E.GemTypeInfo` (socket colors), `E.Media.Textures.*` (Copy added; copied
  Copy.tga alongside Play/Pause/Reset), and `E.media.{normFont,blankTex,glossTex,
  backdropfadecolor,rgbvaluecolor}`. `E.TimerunningID` is intentionally **not**
  provided — nil resolves the non-timerunning branch of its ternary.
- **Skins helpers added** (Skins/Core.lua, ElvUI parity): `S:ForEachCheckboxTextureRegion`,
  `S:SetupArrow`, `S:SkinReadyDialog`, `S:OverlayButton` (E.UIParent → _G.UIParent,
  border-color calls inlined; `.Center` reorder dropped).

## Re-sync workflow

1. Note the version in the port header; fetch the new ElvUI source file.
2. Diff new-upstream vs the upstream revision you forked from; identify real
   logic changes (ignore pure formatting).
3. Apply those changes to the DarkUI port, then re-run the transform recipe.
4. `.tools/stylua DarkUI/` and reload in-game to verify.
5. Bump the version anchor in the port header to the new ElvUI version.
