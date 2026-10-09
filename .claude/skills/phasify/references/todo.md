# Todo

### Todo

Read-only / advisory (like Show). **No implementation.** **Do not**
change Status. Do **not** execute the phase and do **not** start
later phases. This is a detailed actionable list of what that phase
requires — far more than a one-liner.

Parse after stripping `Nimages` / `Npass`. Match `todo` /
`Ntodo` as this mode — do **not** treat them as `todone`,
`toend`, or `unblock`. Do not collapse a shared `to` / `todo`
prefix with `todone` or `toend`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.
**`todo N` / `todo 3` means named P3** (not next 3).
**`todone N` / `todone 3` means next N eligible** (like `block N`).

| Text | Effect |
|------|--------|
| `todo` | Detail the **next not-done, not-deferred** phase in plan order (first Status that is not `Done`, not `Deferred`, and not `Def-Blocked`). Include `Left`, `Blocked`, `Unblocked`, `Progress` / in-progress, `Planned`, `Not started`, etc. Skip `Done`, `Deferred`, and `Def-Blocked` (treat `Def-Blocked` as deferred). If none (all `Done`, or only `Deferred` / `Def-Blocked` left), say so and print the current table (show-style). Do not invent a target. |
| `Ntodo` / `pN todo` / `todo N` / `todo pN` | Detail that **table id** (`0`/`p0` = P0) **no matter the Status except `Done`**. Named todo may todo a `Def-Blocked` phase (not `Done`). |

If that phase is already `Done`: **do not change it**. Print a clear
**Error:** line (same red/bold style as invalid defer): cannot todo a
completed phase.

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not invent a target**. Print the same **Error:** style as invalid
defer.

If `Nimages` is present: acknowledge first (promptify scratch ack),
then Todo. **Read** those images when they may explain the work; use
only what they show (never invent APIs/files). If `Npass` > 1: extra
pass(es) improve briefing quality (see **Flags**) — not a whole-table
replan.

**Todo report** (required when a target exists). Be incredibly
detailed and practical. Numbered tasks; mark each **manual / human**
vs **agent**. Cite files, APIs, and commands **only** when known from
this conversation and verified workspace facts — never invent. For
`Blocked` / `Def-Blocked` phases, include **both** the remaining
phase work **and** the blocker / manual-human tasks.

```text
## Todo — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status>
**Description:** <phase description from the plan>

### Why this phase
<why this is next (first not-Done, not-Deferred, not-Def-Blocked) / why named>

### Tasks
1. <manual | agent> — <implementation step; files/APIs/commands when known>
2. …

### Done looks like
<exit criteria the human or later /phasify can verify>

### Do not
- Do not execute this phase from this command
- Do not change Status
- Do not invent files, APIs, or commands

/phasify pN
```

The last line is an optional one-line next-step (`/phasify pN` or
`/phasify next`). Do not print it as if the work already ran.


## Phase boundary

Todo does not optimize. It is read-only (no Status change, no execute). Do not clear `before` or `after` from this mode. Do not write the handoff from this mode.
