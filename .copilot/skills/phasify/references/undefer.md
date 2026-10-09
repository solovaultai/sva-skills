# Undefer

### Undefer

Non-executing. Inverse of Defer. Clear `Deferred` so Next / Next-N /
done will pick the phase up again. Parse after stripping `Nimages` /
`Npass`. If `Nimages` is present: acknowledge first, then Undefer.
Match `undefer` / `Nundefer` as this mode — do **not** treat
them as `defer` / `Ndefer`.

| Text | Effect |
|------|--------|
| `undefer` | Undefer the **next Deferred** phase in plan order (first status `Deferred` or `Def-Blocked`). If none, say so — do not invent a target. |
| `Nundefer` / `pN undefer` / `undefer N` / `undefer pN` | Undefer that **table id** (`0`/`p0` = P0). |

If that phase is not `Deferred` and not `Def-Blocked`: **do not change
it**. Print a clear **Error:** line (same red/bold style as invalid
defer).

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not undefer**. Print the same **Error:** style as invalid defer.

After success:
- `Deferred` → Status `Left`. **Clear** the stored Reason so `show` no
  longer lists it as deferred-with-reason.
- `Def-Blocked` → Status `Blocked` (clear defer, keep the block). Keep
  the blocker Reason.

Print the updated table (show-style). Do not execute the phase.

