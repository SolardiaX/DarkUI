# DarkUI Libs — Local Patches

Records local modifications applied on top of vendored libraries.

**IMPORTANT**: When re-syncing a library from upstream (NDui / ElvUI / GitHub), these
patches are overwritten and MUST be re-applied. Check this file after every lib update.

## oUF

| File | Change | Reason | Reference |
|------|--------|--------|-----------|
| `oUF/private.lua` | `Private.unitIsUnit` rewritten to guard with `C_Secrets.CanCompareUnitTokens` and reject `issecretvalue` results, always returning a plain boolean | 12.0: `UnitIsUnit` returns a *secret boolean* for protected units. `pcall` does not error on it, so the secret value leaked to callers; `portrait.lua:46` then did `not unitIsUnit(...)` → "boolean test on a secret boolean value" taint. Upstream still has a `-- TODO: use C_Secrets.CanCompareUnitTokens` here. | ElvUI `ElvUI_Libraries/Game/Shared/oUF/init.lua` `oUF:UnitIsUnit` |

Affected callers (all fixed by the single helper change): `portrait`, `power`,
`additionalpower`, `alternativepower`, `classpower`, `stagger`, `runes`,
`restingindicator`.
