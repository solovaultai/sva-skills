# Execute

Next, Named, Next-N, Run-to-end, and Stop-before-end read this file. Rundefer and Runblock read it after their own mode file.

### Run-to-end

One mode. Aliases (case-insensitive): `done`, `finish`, `end`, `all`,
`close`, `toend`, `to-end`, `to end`. After flag strip, remaining body
exactly `toend`, `to-end`, or `to end` selects this mode (not empty
Next; `to-end` is not `-N`).

If `Nimages` is present: acknowledge first (see **Flags**), then run.
If `Npass` is present: extra pass(es) apply to this run's remaining
phases (not a whole-table replan).

Run every remaining incomplete phase through the end of the plan. Last
executed phase of the plan gets the full recap.

### Stop-before-end (`-N`)

After stripping flags, a token that is `-`, `-0`, or `-N` (N = 0–9) is
**Stop-before-end**, not Next-N. **`-2pass` is Npass**, not this
mode — `/phasify -2` stops before the last 2 work phases;
`/phasify -2pass` is Next + `2pass` (unless another selector remains).
If `Nimages` is present: acknowledge first, then run.

Let `C` = work-phase count (not Task/Flags). 1-based index `i` maps to
`P(i-1)` (so phase 1 = P0).

- Last **included** 1-based index = `C - N`
- Do not run 1-based phases `> C - N`
- **`N = 0` or bare `-`:** treat as **`N = 1`** (run all but the last phase)

Examples:

- 3 phases (P0–P2), `-` / `-0` / `-1`: run 1 and 2 (P0, P1); leave P2
- 6 phases (P0–P5), `-2`: `C - N = 4` → run through P3; do not run P4 or P5 (“up to but not including” 1-based phase 5)

If every remaining incomplete phase is past that cutoff, print the table
and say there is nothing to run. Still skip Deferred / Def-Blocked /
Done inside the allowed window.


## Execute (mutating, phase-scoped)

All multi-phase execute modes stay **sequential, synchronous, in plan
order**. No parallel/fan-out. Skip `Done`, `Deferred`, and
`Def-Blocked` unless `--force` / explicit redo. Stop the sequence on
`Blocked` (not on `Def-Blocked` — skip it). Between
phases, re-read Task + Flags and confirm the next phase still serves
that goal; if not, stop and say why.

1. Validate the selected phase(s) against the real workspace (read/search).
2. **Execute only** that phase's exit criteria — implement, edit, test as
   needed. Do not start later phases. Do not reopen earlier `Done` work
   except to fix a blocker this phase depends on.
3. **Synchronous multi-phase (mandatory):** finish phase x **completely**
   (work landed or explicitly Blocked) **before** phase x+1 begins.
   Do **not** run phases in parallel, as background agents, or as a batch
   of simultaneous todos. No async fan-out. Applies to Next-N,
   Run-to-end, Full, Stop-before-end, Rundefer, and Runblock.
4. Mark status accurately: `Done` only if the work **landed**; else
   `In progress`, `Blocked`, or leave as `Left`. Remaining unstarted work
   after a partial run is **`Left`**.
5. If a phase is **Blocked**, stop the sequence. Do not start x+1.

If `Nimages` is present: acknowledge first, then execute. Use scratch
images (when marked) as extra detail while implementing. If `Npass` >
1: extra pass(es) apply to **this phase's work** (see **Flags**), not
a whole-table replan.

---

## Phase COMPLETED banner (obvious)

After each phase that **finishes** (Done or Blocked), print a single-line
box **before** starting the next phase. Pad so every banner line is the
same width:

```text
┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P1 — API   COMPLETED                               │
└──────────────────────────────────────────────────────────────┘
```

Use `✓` and `COMPLETED` for Done. If Blocked:

```text
┌──────────────────────────────────────────────────────────────┐
│  ✗  PHASE P1 — API   BLOCKED                                 │
└──────────────────────────────────────────────────────────────┘
```

**Between-phase vs last-of-run:**

- After every finished phase **except the last phase of this run:**
  COMPLETED/BLOCKED banner only (no full table).
- After the **last phase of this run:** banner + full `phase_layout.txt`
  recap (Task, Flags if any, statuses).

Apply this to Next-N, Run-to-end, Full, Stop-before-end, Rundefer, and
Runblock. Single-phase Next stays banner + table. Named single-phase
(`0` / `pN`) also stays banner + table. Rundefer of one deferred
phase stays banner + table. Runblock of one blocked phase stays
banner + table (execute or mark-Done). A Def-Blocked rundefer target
that becomes `Blocked` uses the BLOCKED banner (execute stops; do
not pretend it became runnable). A just-runblocked phase that
becomes `Blocked` again stops the sequence (BLOCKED banner).

---


## Closing recap (mandatory when the run's phase(s) complete)

After the last banner of this run, print **only** `## Phased plan` plus
the aligned table (last section; promptify trailing-table rule). Nothing
after the table except an optional one-line next-step (e.g.
`/phasify next`). Mid-run phases get the banner only — not this recap.
Include Reason if any phase has a stored reason.

---


## Phase boundary

Start-of-phase optimize is in the phasify router (**Phase boundary**). If it stopped the turn, do not begin this file.

At the end of a phase, if `after=1`: print the phase COMPLETED banner and the phase table first, land the status update, then optimize (router **Phase boundary** / **Host**), then stop. Clear the `after` key when that shot fires. Leave `enabled` and `before`. Do not flip `enabled`. If a start-of-phase optimize already stopped the turn, `after` waits.
