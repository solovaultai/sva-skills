# Block

### Block

Non-executing. Manually set phase(s) to `Blocked` (or `Def-Blocked`
if already `Deferred`). Status mutation + table reprint only — like
defer / undefer, **not** a briefing and **not** Unblock. Do **not**
execute the phase.

Parse after stripping `Nimages` / `Npass`. If `Nimages` is
present: acknowledge first, then Block. Strip flags **before**
taking the reason. Match `block` /
`Nblock` as this mode — do **not** treat them as `unblock` /
`Nunblock`. Do not collapse a shared `block` suffix or `un`
prefix. `unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

| Text | Effect |
|------|--------|
| `block` | Manually block the **next 1 eligible** phase (plan order). If none, say so and print the current table (show-style). Do not invent a target. |
| `block pN` / `pN block` / `Nblock` | Manually block that **table id** (`0`/`p0` = P0). `block 0` / `0block` is named P0 (you cannot block “next 0”). |
| `block N` (bare integer N ≥ 1, not `pN`) | Manually block the **next N eligible** open phases. |

**Parse collision (required):** `todo N` / `todo 3` means named P3.
`block 2` / `block N` means **next N**, not phase N. Named block is
only `pN` / `Nblock` / `pN block`. `2block` = named P2 (same family
as `Ntodo` / `Ntodone` / `Ndefer`). `unblock` ≠ `undefer` ≠
`todo` ≠ `todone` ≠ `block`. `block` is not `unblock`.

**Eligible** for bare `block` / `block N`: not `Done`, not already
`Blocked`, not already `Def-Blocked`. Include `Left`, `Unblocked`,
`Progress`, `Planned`, `Not started`, **`Deferred`** (→
`Def-Blocked`). Skip `Done`. Skip already-blocked so `block 2`
blocks two phases that are not yet blocked.

Named can target `Deferred` (→ `Def-Blocked`). Named already
`Blocked` / `Def-Blocked`: update Reason if a reason is given;
stay blocked; do not error.

Named `Done`: **do not change it**. Print a clear **Error:** line
(same red/bold style as invalid defer / todo-on-Done): cannot
block a completed phase.

Invalid id (not a number, negative, higher than last phase, unknown
id): **do not invent a target**. Print the same **Error:** style as
invalid defer.

Bare `block` / `block N` when fewer eligible than requested: block
all eligible, say how many were blocked vs requested, print the
table. None eligible: say so and print the current table.

Optional reason: remainder of the line after the block token
**and after flag strip** (`block waiting on legal` / `2block API freeze`
/ `block p3 creds`). `2pass` / `1image` are flags, never reason text.
Store on the phase (like defer). If no reason, still block; Reason
should state it was manually blocked (short).

**Status:**
- Not `Deferred` → **`Blocked`**
- `Deferred` → **`Def-Blocked`** in the table Status cell. Canonical
  name **Deferred-Blocked** / **Def-Blocked**. `Deferred-Blocked` is
  16 characters and does not fit the 12-wide Status inner width;
  `Def-Blocked` is 11 and fits (` Def-Blocked`).

Do not execute the phase.

