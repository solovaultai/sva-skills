# Phasify — user reference

Print this file as the response when the user runs `/phasify help`,
`/phasify --help`, or `/phasify /?`. Do not execute, defer, undefer, or show.

Empty `/phasify` is **Next**, not this page.

---

## What it does

Execute one or more phases of an existing **plannify** plan. Not a new
planning pass and not a full-plan `/runnify`. Implement only the selected
phase(s).

Need a new plan from current statuses? Use **`/plannify fromhere`**
(plannify skill) — not a phasify mode.

---

## How to invoke

```text
/phasify                 — Next (one incomplete phase). Not help.
/phasify next            — same as empty
/phasify 0               — named P0
/phasify p3              — named P3 (need p / phase prefix when N ≠ 0)
/phasify 3               — Next-N: next 3 incomplete phases
/phasify done            — Run-to-end (also finish / end / all / close)
/phasify -               — Stop-before-end (also -0 / -N)
/phasify defer [reason]  — Defer next open phase (also Ndefer / defer N)
/phasify undefer         — Undefer next Deferred phase (also Nundefer / undefer N)
/phasify show            — print the current table (also refresh)
/phasify help            — this reference (also --help / /?)
```

Parse **after** stripping `Nimages` / `Npass` (see Flags). `-2pass` is a
pass flag, not stop-before-end. Help is **not** a phase selector.

---

## Modes

| Text after `/phasify` | Mode | Runs work? |
|-----------------------|------|------------|
| *(empty)* | **Next** | Yes — next incomplete phase (count = 1) |
| `next`, `run next phase` | **Next** | Yes — same as empty |
| `0`, `p0`, `phase 0`, `run phase p0` | **Named** | Yes — that phase (P0) |
| `pN`, `phase N`, `phase pN`, `run phase pN` | **Named** | Yes — that phase (PN) |
| `3`, `next 3`, `run next 3 phases` | **Next-N** | Yes — next **N ≥ 1** incomplete phases |
| `done` / `finish` / `end` / `all` / `close` | **Run-to-end** | Yes — every remaining incomplete phase |
| `-` / `-0` / `-N` | **Stop-before-end** | Yes — through 1-based index `C − N` |
| `defer`, `Ndefer`, `defer N` [reason] | **Defer** | No — status only |
| `undefer`, `Nundefer`, `undefer N` | **Undefer** | No — status only (`Left`) |
| `show` / `refresh` | **Show** | No — print table only |
| `help` / `--help` / `/?` | **Help** | No — print this reference |
| `/plannify fromhere` | **fromhere** | Replan (plannify skill, not phasify) |

**Execute modes** (mutating): Named · Next · Next-N · Run-to-end ·
Stop-before-end. **Defer** and **Undefer** update status only. **Show**
and **Help** are read-only.

---

## Disambiguation

| Token | Means |
|-------|--------|
| Bare `0` | Named **P0** (you cannot run “next 0 phases”) |
| Bare integer `N ≥ 1` | **Next-N** (`/phasify 3` = next 3, **not** P3) |
| Specific phase other than P0 | Require `p` / `phase` (`/phasify p3`) |
| Empty (no selector) | **Next**, never help |
| `-` / `-0` / `-N` (N = 0–9) after flag strip | **Stop-before-end** |
| `-2pass` | Pass flag, **not** stop-before-end |
| `help` / `--help` / `/?` after flag strip | **Help**, do not execute |
| `done` / `finish` / `end` / `all` / `close` | Run-to-end (case-insensitive) |

New tokens are words (`done`, `defer`, `undefer`) or a **leading minus**
(`-2`), never something that collides with `2pass`. Match `undefer` /
`Nundefer` as **Undefer**, not Defer.

---

## Next and Next-N

**Next** = first phase whose Status is not `Done` or `Deferred`
(`Not started`, `Left`, `In progress` / `Progress`, `Blocked` are
eligible). If `Blocked`, try only if this run can unblock it; otherwise
skip and say so.

**Next-N:** run the next N incomplete phases, one after another. If
fewer than N remain, run the remainder and say the shortfall.

Skip `Done` and `Deferred` unless `--force` / explicit redo. Named `pN`
is an explicit request to run that phase (even if Deferred). Stop the
sequence on `Blocked`.

If the named phase does not exist, stop and list real phase ids. If it
is already `Done`, do not redo unless `redo` / `--force`; still print
the closing recap.

---

## Run-to-end

Aliases (case-insensitive): `done`, `finish`, `end`, `all`, `close`.

Run every remaining incomplete phase through the end of the plan.
Last executed phase of the plan gets the full recap.

```text
/phasify done
/phasify finish
```

---

## Stop-before-end (`-N`)

After stripping flags, `-`, `-0`, or `-N` (N = 0–9) is Stop-before-end.

Let `C` = work-phase count (not Task / Flags). 1-based index `i` maps
to `P(i−1)` (phase 1 = P0).

- Last **included** 1-based index = `C − N`
- Do not run 1-based phases `> C − N`
- **`N = 0` or bare `-`:** treat as **`N = 1`** (all but the last work phase)

Examples:

| Plan | Token | Runs | Leaves |
|------|-------|------|--------|
| P0–P2 (C = 3) | `-` / `-0` / `-1` | P0, P1 | P2 |
| P0–P5 (C = 6) | `-2` | through P3 (`C−N = 4`) | P4, P5 |

If every remaining incomplete phase is past the cutoff, print the table
and say there is nothing to run. Still skip Deferred/Done inside the
window.

```text
/phasify -
/phasify -2
```

---

## Defer

Non-executing. Marks a phase `Deferred` and keeps an optional reason
on that row.

| Text | Effect |
|------|--------|
| `defer` | Defer the **next open** phase. If none, say so — do not invent a target. |
| `Ndefer` / `pN defer` / `defer N` / `defer pN` | Defer that table id (`0` / `p0` = P0) |

Invalid id (not a number, negative, past last phase, unknown): **do not
defer**. Print **Error:** (red HTML `<span>` when the client renders it;
otherwise bold `Error:`).

Optional reason = remainder of the line after the defer token
(`defer API freeze`, `2defer waiting on legal`). Stored for this plan
and reprinted on every recap/show. Empty reason is allowed.

Future execute modes **skip** `Deferred` unless the user explicitly
runs that phase (`pN`, `redo`, `--force`).

```text
/phasify defer
/phasify defer API freeze
/phasify 2defer waiting on legal
/phasify defer p1
```

---

## Undefer

Non-executing. Inverse of Defer. Clears `Deferred` so Next / Next-N /
done will pick the phase up again. Parse after stripping `Nimages` /
`Npass`. Match `undefer` / `Nundefer` as this mode — not `defer` /
`Ndefer`.

| Text | Effect |
|------|--------|
| `undefer` | Undefer the **next Deferred** phase in plan order (first status `Deferred`). If none, say so — do not invent a target. |
| `Nundefer` / `pN undefer` / `undefer N` / `undefer pN` | Undefer that table id (`0` / `p0` = P0) |

If that phase is not `Deferred`: **do not change it**. Print **Error:**
(same red/bold style as invalid defer).

Invalid id (not a number, negative, past last phase, unknown): **do not
undefer**. Print the same **Error:** style as invalid defer.

After success: set Status to `Left`. **Clear** the stored Reason so
`show` no longer lists it as deferred-with-reason. Print the updated
table (show-style). Do not execute the phase.

```text
/phasify undefer
/phasify 2undefer
/phasify undefer p1
/phasify p1 undefer
```

---

## Show / refresh

Aliases: `show`, `refresh`. **Read-only.** No implementation.

Print the current aligned table (Task, Flags if present, all phase
statuses). Include Reason if any deferral has one. If no plan, tell
the user to `/plannify` first.

```text
/phasify show
/phasify refresh
```

---

## Flags (`Nimages` / `Npass`) — strip first

Not phase selectors and not Task wording. Strip them **before**
choosing a mode.

**Parse order** (each family independently, left to right):

- First **numbered** instance counts: `1image`, `1 image`, `1-image`,
  `3images`, `2pass`, `2-pass`, `2 pass`
- Unnumbered `image` / `images` / `pass` / `passes` does **not** count
- Several numbered tokens → first only (not the largest N)
- No numbered instance → that flag is absent
- `-2pass` is a **pass** flag, not stop-before-end

**`Nimages`:** read the N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`
(`*.png` `*.jpg` `*.jpeg` `*.webp` `*.gif` `*.bmp`). Do not create
`scratch/`. Acknowledge first when present.

**`Npass`:** pass-count flag for the Flags row. Default N = 1 if
absent. Acknowledge after the scratch ack when both appear.

Examples after strip:

| User text | Mode | Flags |
|-----------|------|--------|
| `/phasify` | Next | none |
| `/phasify 1image` | Next | 1 image |
| `/phasify 3 2images` | Next-3 | 2 images |
| `/phasify help 2images` | Help | (print this page; do not execute) |
| `/phasify -2pass` | Next (pass flag only) | `2pass` |
| `/phasify -2` | Stop-before-end N=2 | none |

---

## Task and Flags in the table

Three columns. No extra box. No spanning cell.

**Task Description** = verbatim original ify request (the words after
promptify / askify / runnify / plannify / debugify). Not Intent
Analysis, not the Kickoff/Optimized Prompt, not `## Plan`. Strip
image/pass tokens from Task (they belong in Flags). If the raw request
cannot be recovered: `(original ify text not found)` — do not
substitute the plan.

- Status `Planned` on the **first** Task line only
- Phase blank on first Task line; label `Task` on the next; blank after

**Flags row — both, one, or none:**

| User included | Flags row |
|---------------|-----------|
| Both `Nimages` and `Npass` | Two Description lines (image family, then pass family) |
| Only one of them | One Description line |
| Neither | **Omit** the Flags row |

Each present flag:

`Caught and correctly interpreted <token>. On pass k of N.`

- `<token>` = exact numbered token (`1image`, `2pass`, …)
- **N** = Npass value (default 1 if `Npass` is absent)
- **k** = pass just finished or in progress (`On pass N of N` after the last)
- Phase `Flags` and Status `Understood` on the first Flags line only

This row is not a work phase.

---

## Execute (mutating modes)

All multi-phase runs are **sequential, synchronous, in plan order**.
No parallel / fan-out / background batch.

1. Validate the selected phase(s) against the real workspace.
2. Execute only that phase’s exit criteria.
3. Finish phase x completely (landed or Blocked) **before** x+1.
4. `Done` only if the work **landed**; else `Progress` / `Blocked` /
   `Left`. Remaining unstarted work after a partial run is `Left`.
5. `Blocked` stops the sequence.

Between phases, re-read Task + Flags and confirm the next phase still
serves that goal; if not, stop and say why.

---

## Banners vs last-of-run table

After each finished phase (Done or Blocked), print a single-line
COMPLETED / BLOCKED banner.

| When | What to print |
|------|----------------|
| Mid-run (finished, but not the last phase of **this** run) | Banner **only** — no full table |
| Last phase of this run | Banner **+** full `phase_layout.txt` recap |
| Single-phase Next or named (`0` / `pN`) | Banner + table |

Applies to Next-N, Run-to-end, and Stop-before-end.

---

## Table layout (`phase_layout.txt`)

**Not** a markdown table. Print inside a fenced `text` block. Match
`docs/phase_layout.txt` / this skill’s `phase_layout.txt`.

Every 3-column line is **exactly 89** characters. `│` at columns
0 / 16 / 75 / 88. Status inner width **12** so `Understood` fits.
Spaces, never tabs. Single-line box: `┌┬┐ ├┼┤ └┴┘ │ ─`.

Wrap inside Description only (max 56 content characters after the
leading space).

**Row order:** titles → Task → Flags (if any) → work phases.

**Status words** (must fit in 12 with the leading space):
`Planned` · `Done` · `Left` · `Blocked` · `Deferred` · `Progress` ·
`Understood`. Do **not** write `In progress`.

**Reason column:** if any phase has a stored reason, add Reason on
`show` / recap so it is retrievable. Omit the column if no phase has
a reason. 3-column lines stay 89 characters; with Reason, keep every
line the same width.

Closing recap: after the last banner of this run, print only
`## Phased plan` plus the aligned table (last section). Optional
one-line next-step (e.g. `/phasify next`). `show` prints only the
table. `defer` and `undefer` print **Error:** on invalid id (or undefer
of a non-Deferred phase), otherwise the updated table.

---

## fromhere (not a phasify mode)

`/plannify fromhere` (alias `planify fromhere`) replans from current
statuses — **AskQuestion**: Keep new plan vs Continue original. That
is the **plannify** skill. Phasify does not replan.

---

## Hard rules (short)

- Execute only the selected phase(s). Replan with `/plannify fromhere`.
- Empty `/phasify` is Next. Never print this help for an empty invocation.
- `help` / `--help` / `/?` (after flag strip) prints this page and stops.
- Multi-phase runs are sequential and synchronous. Stop on `Blocked`.
- Skip `Done` / `Deferred` unless `--force` / redo / named `pN`.
- Mid-run: banner only. Last-of-run: banner + full table.
- `-` / `-0` / `-N` is Stop-before-end. `-2pass` is a pass flag.
- Invalid defer id: do not defer; print **Error:**.
- Invalid undefer id, or undefer of a non-Deferred phase: do not change
  it; print **Error:**. Bare `undefer` with no Deferred phase: say so.
  Success: Status `Left`, clear Reason, print the table; do not execute.
  Parse `undefer` / `Nundefer` as Undefer, not Defer.
- `show` / `refresh` are read-only.
- Never invent a plan, phases, or workspace resources.
- Do not mark `Done` unless the work landed.
- Task row = verbatim original ify text. Flags = both / one / none.
- Every 3-column line is 89 characters with `│` at 0, 16, 75, 88.
- Image and pass markers are not phase selectors.

---

## Related

| Command | Role |
|---------|------|
| `/plannify <prompt>` | Create the plan |
| `/plannify fromhere` | Replan from current statuses |
| `/plannify help` | Plannify reference |
| `/runnify <prompt>` | Execute a whole optimized task (not phase-scoped) |
