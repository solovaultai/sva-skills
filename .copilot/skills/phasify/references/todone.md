# Todone

### Todone

Todo + close. **No implementation.** Print the same detailed
actionable list as **Todo**, then set that phase Status to
**`Done`**. Do **not** wait for user acknowledgement. Using
`todone` means the user already did (or is asserting) the work.
Do **not** execute the phase and do **not** start later phases.

Parse after stripping `Nimages` / `Npass`. Match `todone` /
`Ntodone` as this mode — do **not** treat them as `todo` /
`Ntodo`, `toend`, or `done`. Do not collapse a shared `to` /
`todo` prefix. `todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.
**`todo N` / `todo 3` means named P3.** **`todone N` /
`todone 3` means next N eligible** (like `block N`), not named
PN.

| Text | Effect |
|------|--------|
| `todone` | Todo+close the **next 1 eligible** phase (same selection as bare `todo`: first Status that is not `Done`, not `Deferred`, and not `Def-Blocked`). Include `Left`, `Blocked`, `Unblocked`, `Progress` / in-progress, `Planned`, `Not started`. Skip `Done`, `Deferred`, and `Def-Blocked`. If none, say so and print the current table (show-style). Do not invent a target. |
| `todone pN` / `pN todone` / `Ntodone` | Todo+close that **table id** (`0`/`p0` = P0) **no matter the Status except `Done`**. Named todone may todone a `Deferred` / `Def-Blocked` / `Blocked` / `Left` / etc. phase (not `Done`). |
| `todone N` (bare integer N ≥ 1, not `pN`) | Todo+close the **next N eligible** phases (same eligibility as bare `todone`). |
| `todone 0` / `0todone` | Named P0 (like `block 0` / `0block`). You cannot todone “next 0”. |

**Parse collision (required):** `todo N` / `todo 3` means named P3.
`todone 2` / `todone N` means **next N**, not phase N. Named todone
is only `pN` / `Ntodone` / `pN todone` (and `todone pN`).
`2todone` = named P2 (same family as `Ntodo` / `Ndefer` / `Nblock`).
`todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

If that phase is already `Done`: **do not change it**. Print a clear
**Error:** line (same red/bold style as invalid defer / todo-on-Done /
block-on-Done): cannot todone a completed phase.

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not invent a target**. Print the same **Error:** style as invalid
defer.

Bare `todone` / `todone N` when fewer eligible than requested: todone
all eligible, say how many were todone'd vs requested, print the
table. None eligible: say so and print the current table.

If `Nimages` is present: acknowledge first (promptify scratch ack),
then Todone. **Read** those images when they may explain the work; use
only what they show (never invent APIs/files). If `Npass` > 1: extra
pass(es) improve briefing quality (see **Flags**) — not a whole-table
replan.

**Report + close** (required when a target exists). For each phase
todone'd, in plan order:

1. Print the **Todo report** (same depth as **Todo**): heading,
   id + title + **status-before**, description, why this phase,
   numbered tasks (manual / agent), done-looks-like. Keep it
   detailed. For `Blocked` / `Def-Blocked` phases, include **both**
   the remaining phase work **and** the blocker / manual-human
   tasks. Cite files, APIs, and commands **only** when known from
   this conversation and verified workspace facts — never invent.
2. Then set Status **`Done`**. Clear or update Reason (e.g. closed
   by todone). Do **not** wait for acknowledgement.
3. After **all** targets: reprint the full phase table
   (last-of-run / show-style).

```text
## Todone — PN — <title>

**Phase:** PN — <title>
**Status:** <status-before>
**Description:** <phase description from the plan>

### Why this phase
<why this is next (first not-Done, not-Deferred, not-Def-Blocked) / why named>

### Tasks
1. <manual | agent> — <implementation step; files/APIs/commands when known>
2. …

### Done looks like
<exit criteria the human asserted or a later /phasify show can verify>

### Do not
- Do not execute this phase from this command
- Do not wait for acknowledgement
- Do not invent files, APIs, or commands
```

Then set Status `Done` (Reason: closed by todone, or clear). After
every target in this run, print the aligned table last.


## Phase boundary

Todone is a mutating run. Start-of-phase optimize is in the phasify router. If it stopped the turn, do not begin this file.

At the end, if `after=1`: print the phase COMPLETED banner and the phase table first, land the status update (`Done`), then optimize (router **Phase boundary** / **Host**), then stop. Banner format is **Phase COMPLETED banner** in `references/execute.md` — read that section when `after=1`. Clear the `after` key when that shot fires. Leave `enabled` and `before`. Do not flip `enabled`. If a start-of-phase optimize already stopped the turn, `after` waits.
