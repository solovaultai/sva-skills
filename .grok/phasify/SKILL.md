---
name: phasify
description: >
  Phasify — execute phase(s) of an existing plannified plan. Run a named
  phase (`/phasify 0`, `/phasify p0`, "run phase p0"), the next incomplete
  phase (`/phasify` with no selector, `/phasify next`, "run next phase"),
  the next N phases sequentially (`/phasify 3`, "run next 3 phases"),
  remaining phases to the end (`/phasify done`, finish, end, all, close),
  or stop before the last N work phases (`/phasify -`, `/phasify -0`,
  `/phasify -N`). Defer a phase (`/phasify defer`, `Ndefer`, `defer N`
  [reason]). Show the current table (`/phasify show`, `/phasify refresh`).
  Empty `/phasify` is Next (count = 1), not help. Print the full
  reference with `/phasify help` or `/phasify --help` (also `/?`).
  Replan from current
  statuses with `/plannify fromhere` (plannify skill). When phase(s)
  complete, put the user's original ify Task text
  (promptify / askify / runnify / plannify / debugify — verbatim user
  request, not generated plan text) in the Task row of the aligned
  phased-plan table (docs/phase_layout.txt). Capture Flags as specified:
  both Nimages and Npass, one of them, or no Flags row. Not a separate
  box, not a spanning cell, not plannify's interpreted or projected text.
  Use when the user runs /phasify (no selector = next incomplete phase),
  "phasify 0", "phasify next", "phasify 3", "phasify done", "phasify
  finish", "phasify end", "phasify all", "phasify close", "phasify -",
  "phasify -2", "phasify defer", "phasify show", "phasify refresh",
  "phasify help", "phasify --help", "run phase p0", "run next phase",
  or "run next n phases". Recognizes
  Nimages / N images / N-images (also Nimage / N image / N-image; e.g.
  1image, 3images) as a pointer to the newest N images in the workspace
  scratch/ folder. Recognizes Npass / N-pass / N pass as a pass-count
  flag to record (not a phase selector). `-2pass` is a pass flag, not
  stop-before-end.
metadata:
  short-description: "Execute named, next, next-N, run-to-end, stop-before-end, defer, show, or help"
---

# Phasify (= execute plannified phase(s))

You are running **Phasify** (`/phasify`) — **execute** one or more phases of
an existing **plannify** plan. This is not a new planning pass and not a
full-plan `/runnify`. Implement only the selected phase(s).

Follow `~/.grok/skills/promptify/SKILL.md` Hard rules (workspace is source
of truth; never invent files/APIs/tools/DBs) and its **Scratch images**
section. Follow `~/.grok/skills/plannify/SKILL.md` for phase ids.
Print the recap / between-phase table using **Table layout**
(`phase_layout.txt`) — not a markdown table.

---

## Scratch images (`Nimages` / `Nimage`)

When the user text includes **`Nimages`**, **`N images`**, **`N-images`**,
or singular **`Nimage`** / **`N image`** / **`N-image`** (case-insensitive;
examples: `1image`, `1 image`, `1-image`, `3images`), that token is an
**attachment marker**, not a phase count and not part of the task wording.

The **N most recent image files** in workspace **`scratch/`** (`*.png`,
`*.jpg`, `*.jpeg`, `*.webp`, `*.gif`, `*.bmp`; newest mtime first) provide
extra visual detail for the issue under review. Resolve `scratch/` at the
repo root (or the project's existing `scratch` dir — do not create one),
**read** those N images (or all if fewer), and use what they show while
executing the phase(s). Parse image/pass flags per promptify **Flag parse
order** (first numbered instance left to right; skip unnumbered
`image`/`pass` so a later `1image` / `2pass` can count).

**Tell the user (mandatory, first printed content when a marker is present):**

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on the issue under review.
```

Do not skip or bury this. Strip **image and pass** tokens **before**
parsing the phasify mode so `phasify 3 2images` means **next 3 phases** +
2 scratch images, not phase 2; `/phasify 1image` is **Next** + 1 image;
empty `/phasify` is **Next**; and `2pass` is never a phase count.

When **`Npass`** / **`N-pass`** / **`N pass`** is present (same Flag parse
order), it is a **pass-count flag** to record in the Flags row — not a
phase selector and not part of the Task wording. Default N = 1 if absent.
Print the promptify Npass acknowledgment after the scratch ack when both
appear. Capture whichever flags the user included (both, one, or none)
in the table — see **Capture Task and Flags**.

---

## Invocation (parse after stripping image and pass tokens)

Parse **after** stripping `Nimages` / `Npass` (existing Flag parse order).
`-2pass` is a pass flag, not stop-before-end. Bare `/phasify` stays **Next**.

| User text | Mode | What to run |
|-----------|------|-------------|
| (empty / no selector) | **Next** | The next incomplete phase (count = 1) |
| `0`, `p0`, `phase 0`, `phase p0`, `run phase p0` | **Named** | That specific phase (P0) |
| `pN`, `phase N`, `phase pN`, `run phase pN` | **Named** | That specific phase (PN) |
| `next`, `run next phase` | **Next** | The next incomplete phase (count = 1) |
| `3`, `next 3`, `run next 3 phases` | **Next-N** | The next **N** incomplete phases, **N ≥ 1** |
| `done` / `finish` / `end` / `all` / `close` | **Run-to-end** | Every remaining incomplete phase through the end of the plan |
| `-` / `-0` / `-N` | **Stop-before-end** | Run through 1-based index `C - N`; do not run phases `> C - N` |
| `defer`, `Ndefer`, `defer N` [reason] | **Defer** | Mark that phase Deferred (optional reason); do not execute |
| `show` / `refresh` | **Show** | Print the current table (read-only; no implementation) |
| `help` / `--help` / `/?` | **Help** | Print `references/HELP.md`; do not execute |
| `/plannify fromhere` | **fromhere** | Replan from current statuses (plannify skill) |

**Disambiguation (required):**

- Bare **`0`** is **named P0** (you cannot run "next 0 phases").
- Bare integer **N ≥ 1** is **next N phases** (`phasify 3` = next 3, not P3).
- To run a specific phase that is not P0, require the **`p` / `phase` prefix**
  (`phasify p3`, `run phase 3`).
- Empty `/phasify` (no selector) is **Next**, not help.
- After stripping flags, if the remaining selector is exactly `help`,
  `--help`, or `/?` (case-insensitive), that is **Help** — print
  `references/HELP.md` and **stop**. Extra tokens after a help trigger
  are ignored. Help is not a phase selector.
- After stripping flags, a token that is `-`, `-0`, or `-N` (N = 0–9) is
  **Stop-before-end**, not Next-N.
- `-2pass` is a pass flag, not stop-before-end.
- Bare `3` is still Next-3. New tokens must be words (`done`, `defer`) or a
  **leading minus** (`-2`), never collide with `2pass`.
- `done` / `finish` / `end` / `all` / `close` are case-insensitive
  **Run-to-end** aliases.

If there is no selector after `/phasify`, treat the empty invocation as
**Next** mode (count = 1) — same as `next` / `run next phase`. Do not
print a help/usage block. Strip image/pass tokens before this parse, so
`/phasify 1image` is still Next + 1 image, and `/phasify` with nothing
is Next.

### Help (`help` / `--help` / `/?`)

Strip image/pass tokens first. If the remaining selector is `help`,
`--help`, or `/?` (case-insensitive), **read and print**
`references/HELP.md` (this skill folder) and **stop**. Do not execute,
defer, or show. Do not invent extra modes. Help is not a phase
selector. Empty `/phasify` is **Next**, not Help.

**Mode dispatch:** Named / Next / Next-N / Run-to-end / Stop-before-end are
**execute** modes (mutating). **Defer** updates status only (no
implementation). **Show** and **Help** are read-only (no implementation).
Handle Defer, Show, and Help without entering Execute.

### Run-to-end

One mode. Aliases (case-insensitive): `done`, `finish`, `end`, `all`, `close`.

Run every remaining incomplete phase through the end of the plan. Last
executed phase of the plan gets the full recap.

### Stop-before-end (`-N`)

After stripping flags, a token that is `-`, `-0`, or `-N` (N = 0–9) is
**Stop-before-end**, not Next-N.

Let `C` = work-phase count (not Task/Flags). 1-based index `i` maps to
`P(i-1)` (so phase 1 = P0).

- Last **included** 1-based index = `C - N`
- Do not run 1-based phases `> C - N`
- **`N = 0` or bare `-`:** treat as **`N = 1`** (run all but the last phase)

Examples:

- 3 phases (P0–P2), `-` / `-0` / `-1`: run 1 and 2 (P0, P1); leave P2
- 6 phases (P0–P5), `-2`: `C - N = 4` → run through P3; do not run P4 or P5 (“up to but not including” 1-based phase 5)

If every remaining incomplete phase is past that cutoff, print the table
and say there is nothing to run. Still skip Deferred/Done inside the
allowed window.

### Defer

Non-executing. Update the current plan’s status and keep the reason on
that row.

| Text | Effect |
|------|--------|
| `defer` | Defer the **next open** phase (same “next incomplete” rule). If none, say so — do not invent a target. |
| `Ndefer` / `pN defer` / `defer N` / `defer pN` | Defer that **table id** (`0`/`p0` = P0). |

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not defer**. Print a clear **Error:** line (red via HTML
`<span style="color:red">` when the client will render it; otherwise
bold `Error:`).

Optional reason: remainder of the line after the defer token
(`defer API freeze` / `2defer waiting on legal`). Store on the phase
permanently for this plan (reprint on every recap/show). Empty reason
is allowed.

Future execute modes **skip** `Deferred` unless the user explicitly
says to run that phase (`pN`, `redo`, `--force`).

### Show / refresh

Aliases: `show`, `refresh`. **Read-only.** No implementation.

Print the current aligned table (Task, Flags if present, all phase
statuses). Include Reason if any deferral has one. If no plan, tell the
user to `/plannify` first.

---

## Locate the plan vs the original ify text

Keep two things separate:

1. **Phased plan table** (what you execute / update) — from the latest
   `/plannify` (or equivalent) `## Phased plan`, or a verified plan file.
   If no plan is found, stop and tell the user to `/plannify` first.
   Do not invent phases.
2. **Original ify text** (what you put in the **Task** row) — the user's
   **raw request** that kicked off promptify, askify, runnify, plannify,
   debugify, or whatever ify produced this plan. That is the text they
   typed after the slash command (or the free-text they asked to ify).
   It is **not** Intent Analysis, not the Kickoff/Optimized Prompt, not
   `## Plan`, and not any interpreted, projected, or updated text the
   ify created.

If the raw request is not in this conversation, recover it from the ify
invocation that created the plan. If it cannot be recovered, put
`(original ify text not found)` in the Task Description — do not
substitute the plan.

## Capture Task and Flags (mandatory)

Fill **Task** and **Flags** exactly as `docs/phase_layout.txt` (and this
skill's `phase_layout.txt`) show — three columns, no extra box, no
spanning cell.

### Task

**Description** = the verbatim original ify Task text (the words the
user typed for promptify / askify / runnify / plannify / debugify).
Not `## Plan`, not Intent Analysis, not the Kickoff/Optimized Prompt,
not scores, not any interpreted / projected / updated text an ify
generated. Do not rewrite or summarize.

Strip `Nimages` / `Npass` marker tokens from the Task text (they belong
in Flags). Leave the rest unchanged.

- Status **`Planned`** on the **first** Task line only; blank Status on
  wrap lines (as in the layout).
- Phase: blank on the first Task line (text + `Planned`); label
  **`Task`** on the next line; blank Phase on further wraps.

### Flags — both, one, or none

Parse `Nimages` and `Npass` independently per promptify **Flag parse
order**: first numbered instance left to right; skip unnumbered
`image` / `pass` so a later `1image` / `2pass` can count. No numbered
instance ⇒ that flag is absent.

| What the user included | Flags row |
|------------------------|-----------|
| Both `Nimages` and `Npass` | **Two** Description lines (image family, then pass family) |
| Only `Nimages` **or** only `Npass` | **One** Description line for that token |
| Neither | **Omit** the Flags row entirely |

Each present flag is its own Description line:

`Caught and correctly interpreted <token>. On pass k of N.`

- `<token>` is the exact numbered token (`1image`, `2pass`, …).
- **N** is the Npass value (default **1** if `Npass` is absent).
- **k** is the pass just finished or in progress (after the last pass:
  `On pass N of N`).
- Phase **`Flags`** on the first Flags line; blank Phase on a second
  line. Status **`Understood`** on the first Flags line only; blank after.

This row is not a work phase.

**Next incomplete** = first phase whose Status is not `Done` or `Deferred`
(treat `Not started`, `Left`, `In progress`, `Blocked` as eligible; if
`Blocked`, try it only if this run can unblock it, otherwise skip and say
so).

Skip `Done` and `Deferred` unless `--force` / explicit redo. Named `pN`
is an explicit request to run that phase (even if Deferred). Stop the
sequence on `Blocked`.

If the named phase does not exist, stop and list the real phase ids.
If **Next-N** asks for more phases than remain, run the remainder and say
the shortfall.
If the named phase is already `Done`, do not redo it unless the user said
`redo` / `--force`; report that and still print the closing recap.

---

## Execute (mutating, phase-scoped)

All multi-phase execute modes stay **sequential, synchronous, in plan
order**. No parallel/fan-out. Skip `Done` and `Deferred` unless
`--force` / explicit redo. Stop the sequence on `Blocked`. Between
phases, re-read Task + Flags and confirm the next phase still serves
that goal; if not, stop and say why.

1. Validate the selected phase(s) against the real workspace (`read_file` /
   `grep` / `list_dir`).
2. **Execute only** that phase's exit criteria — implement, edit, test as
   needed. Do not start later phases. Do not reopen earlier `Done` work
   except to fix a blocker this phase depends on.
3. **Synchronous multi-phase (mandatory):** finish phase x **completely**
   (work landed or explicitly Blocked) **before** phase x+1 begins.
   Do **not** run phases in parallel, as background agents, or as a batch
   of simultaneous todos. No async fan-out. Applies to Next-N,
   Run-to-end, and Stop-before-end.
4. Mark status accurately: `Done` only if the work **landed**; else
   `In progress`, `Blocked`, or leave as `Left`. Remaining unstarted work
   after a partial run is **`Left`**.
5. If a phase is **Blocked**, stop the sequence. Do not start x+1.

Use scratch images (when marked) as extra detail while implementing.

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

Apply this to Next-N, Run-to-end, and Stop-before-end. Single-phase Next
stays banner + table. Named single-phase (`0` / `pN`) also stays banner +
table.

---

## Table layout (mandatory — `phase_layout.txt`)

Misaligned borders make the table unreadable. Copy this layout exactly.
**Do not** use a markdown table. **Do not** merge or span cells. **Do not**
put the original ify text in its own box.

Print the table inside a fenced `text` code block so the chat cannot
reflow the lines.

If the workspace has `docs/phase_layout.txt`, or this skill folder has
`phase_layout.txt`, match that file's column widths. The copy next to
this skill is the installed source of truth.

### Fixed widths (every line is **exactly 89** characters)

Match `docs/phase_layout.txt`. Status is **12** so `Understood` fits.

| Piece | Inner width | `│` column index |
|-------|-------------|------------------|
| Phase | **15** | left border = 0; after Phase = **16** |
| Description | **58** | after Description = **75** |
| Status | **12** | right border = **88** |

`1 + 15 + 1 + 58 + 1 + 12 + 1 = 89`. Count characters before sending.
If any line is not 89, or any `│` is not in columns 0 / 16 / 75 / 88,
rebuild the line. No trailing space after the right border.

### Characters

- Single-line box only: `┌┬┐ ├┼┤ └┴┘ │ ─` (not `╔═╗`, not markdown pipes).
- Pad with spaces — **never tabs**.
- Cell text: one leading space, then content, then spaces to the inner
  width. Example Phase ` P0 — Spec     ` (15), Status ` Done       ` (12).
  Task / Flags use a two-space indent as in the layout (`  Task`,
  `  Flags`).

### Wrap — keep the three columns on every line

Long text wraps **inside Description only** (max **56** characters of
content after the leading space). Word-wrap; never overflow a cell.

- **Task** (verbatim original ify text): Status `Planned` on the **first**
  Task line only; blank after. First Task line has a blank Phase; label
  `Task` on the next line; further wraps blank Phase. See **Capture Task
  and Flags**.
- **Flags** (both / one / none — see **Capture Task and Flags**): one
  Description line per present flag (`Caught and correctly interpreted
  <token>. On pass k of N.`). Phase `Flags` and Status `Understood` on
  the first Flags line only; blank after. Omit the row if neither flag
  was included.
- **Work phases:** Phase id (`P0 — Spec`) and Status on the **first**
  wrap line only; continuations have a blank Phase and a blank Status.

Row separators always keep three columns (`┼` / `┬` / `┴`). Never
collapse a separator across the full table width.

### Reason column (`show` / recap)

If any phase has a stored reason, add a **Reason** column on
`show`/`refresh` only (keep the 3-column execute recap unless a reason
exists — then include Reason so it is retrievable quickly). Reprint the
stored reason on every recap/show. Omit the column entirely if no phase
has a reason. Align with box-drawing; not a markdown table. 3-column
lines stay exactly 89 characters (`phase_layout.txt`); when Reason is
present, keep every line the same width.

### Row order

1. Column titles: `Phase` / `Description` / `Status` (and **Reason** when
   any phase has a stored reason)
2. **Task** — verbatim original ify Task text (promptify / askify /
   runnify / plannify / debugify). No generated plan text. See **Capture
   Task and Flags**.
3. **Flags** — both flags, one flag, or omit the row (neither present)
4. Work phases in order, current statuses (Reason on that row when stored)

### Status words (must fit in 12 with the leading space)

Use exactly: `Planned` · `Done` · `Left` · `Blocked` · `Deferred` ·
`Progress` · `Understood`. Do **not** write `In progress` (too long).
Mark from this run + prior **verified** work only.

### Canonical example (copy these widths)

This is `docs/phase_layout.txt` — 89 characters per line. Both flags
present ⇒ two Flags Description lines. Copy this file next to the skill
when widths drift.

```text
┌───────────────┬──────────────────────────────────────────────────────────┬────────────┐
│ Phase         │ Description                                              │ Status     │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│               │ I want to add an icon  to campaigns that will be used    │ Planned    │
│  Task         │ wherever the campaign is used for quick identification.  │            │
│               │ If none is supplied the icon should be a badge           │            │
│               │ <text cut but will be shown by cursor and grok>          │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│  Flags        │ Caught and correctly interpreted 1image. On pass 1 of 2. │ Understood │
│               │ Caught and correctly interpreted 2pass. On pass 1 of 2.  │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P0 — Spec     │ Freeze I1–I8 in DESIGN_FLUENT_CAMPAIGN_ICON.md + PRODUCT │ Done       │
│               │ row; initials examples including EEFF2                   │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P1 — Mark     │ campaignInitials + CampaignMark; tests; initials on      │ Done       │
│               │ campaign lists with no API                               │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P2 — API      │ 081_campaign_icon.sql icon_url; PATCH/POST; series       │ Done       │
│               │ campaign_icon_url; Console tests                         │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P3 — Edit     │ Properties Identity + create dialog URL field on         │ Done       │
│               │ existing instance-edit snapshot                          │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P4 — Tables   │ Per-row nameIcon; campaign lists + run Campaign column,  │ Done       │
│               │ 20px                                                     │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P5 — Surfaces │ Blade title, picker, runner, Home campaign rows, run     │ Left       │
│               │ essentials campaign label                                │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P6 — Bake     │ PRODUCT greps, rebuild Fluent, Console tests green       │ Left       │
└───────────────┴──────────────────────────────────────────────────────────┴────────────┘
```

---

## Closing recap (mandatory when the run's phase(s) complete)

After the last banner of this run, print **only** `## Phased plan` plus
the aligned table (last section; promptify trailing-table rule). Nothing
after the table except an optional one-line next-step (e.g.
`/phasify next`). Mid-run phases get the banner only — not this recap.
Include Reason if any phase has a stored reason.

---

## Response shape

Empty `/phasify` and `next` use the single-phase path (one phase, then
the table). Next-N / Run-to-end / Stop-before-end add later phases after
each prior phase finishes. Mid-run: banner only. Last-of-run: banner +
full table.

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, if marker present

## Phase P0 — Spec
(short: what you implemented)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P0 — Spec   COMPLETED                              │
└──────────────────────────────────────────────────────────────┘
(banner only — not the last phase of this run)

## Phase P1 — API
(only if this run included it; after P0 fully finished)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P1 — API   COMPLETED                               │
└──────────────────────────────────────────────────────────────┘

## Phased plan
(aligned table — last phase of this run only; last printed section)
```

`show` / `refresh` print only the table (plus Reason if any deferral has
one). `defer` prints **Error:** on invalid id, otherwise the updated
table. `help` / `--help` / `/?` print `references/HELP.md` only.

---

## Hard rules

- Execute only the selected phase(s). Do not re-plan the whole project.
  Use `/plannify fromhere` (plannify skill) to replan from current
  statuses.
- Empty `/phasify` (no selector after stripping image/pass tokens) is
  **Next** (count = 1), same as `next`. Never print help/usage for an
  empty invocation. After flag strip, `help` / `--help` / `/?` prints
  `references/HELP.md` and stops — do not execute.
- All multi-phase execute modes are **sequential, synchronous, in plan
  order**. No parallel/fan-out. Next-N, Run-to-end, and Stop-before-end:
  x finishes, then x+1 begins.
- Skip `Done` and `Deferred` unless `--force` / explicit redo / named
  `pN`. Stop the sequence on `Blocked`.
- After every finished phase except the last of this run: banner only.
  After the last phase of this run: banner + full table. Single-phase
  Next stays banner + table.
- `-` / `-0` / `-N` is **Stop-before-end** (`C - N`). `-2pass` is a pass
  flag, not stop-before-end. Bare `3` is still Next-3.
- Invalid defer id: **do not defer**. Print a clear **Error:** line
  (red via HTML `<span style="color:red">` when the client will render
  it; otherwise bold `Error:`).
- `show` / `refresh` are read-only. No implementation.
- Never invent a plan, phases, or workspace resources.
- Do not mark `Done` unless the work landed.
- Last printed section is the **Phased plan** table in the
  `phase_layout.txt` layout (execute recap / show). Original ify Task
  text is the **Task** row (three columns, wrapped) — never a separate
  box, never a spanning cell, never generated plan text. Flags are
  both / one / none per **Capture Task and Flags**. Include **Reason**
  when any phase has a stored reason.
- Every 3-column table line is exactly 89 characters with `│` at 0, 16,
  75, 88.
- Image and pass markers are not phase selectors; acknowledge them first
  when present. Parse per promptify Flag parse order.
