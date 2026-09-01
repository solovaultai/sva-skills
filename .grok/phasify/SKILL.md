---
name: phasify
description: >
  Phasify — execute phase(s) of an existing plannified plan. Run a named
  phase (`/phasify 0`, `/phasify p0`, "run phase p0"), the next incomplete
  phase (`/phasify next`, "run next phase"), or the next N phases
  sequentially (`/phasify 3`, "run next 3 phases"). When phase(s) complete,
  put the user's original ify request (promptify / askify / runnify /
  plannify / debugify) in the Task row of the aligned phased-plan table
  (docs/phase_layout.txt) — not a separate box, not a spanning cell, and
  not plannify's interpreted or projected text.
  Use when the user runs /phasify,
  "phasify 0", "phasify next", "phasify 3", "run phase p0", "run next
  phase", or "run next n phases". Recognizes Nimages / N images / N-images
  (also Nimage / N image / N-image; e.g. 1image, 3images) as a pointer to
  the newest N images in the workspace scratch/ folder.
metadata:
  short-description: "Execute named, next, or next-N plannify phases"
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

Do not skip or bury this. Strip image tokens **before** parsing the phasify
mode so `phasify 3 2images` means **next 3 phases** + 2 scratch images, not
phase 2.

---

## Invocation (parse after stripping image tokens)

| User text | Mode | What to run |
|-----------|------|-------------|
| `0`, `p0`, `phase 0`, `phase p0`, `run phase p0` | **Named** | That specific phase (P0) |
| `pN`, `phase N`, `phase pN`, `run phase pN` | **Named** | That specific phase (PN) |
| `next`, `run next phase` | **Next** | The next incomplete phase (count = 1) |
| `3`, `next 3`, `run next 3 phases` | **Next-N** | The next **N** incomplete phases, **N ≥ 1** |

**Disambiguation (required):**

- Bare **`0`** is **named P0** (you cannot run "next 0 phases").
- Bare integer **N ≥ 1** is **next N phases** (`phasify 3` = next 3, not P3).
- To run a specific phase that is not P0, require the **`p` / `phase` prefix**
  (`phasify p3`, `run phase 3`).

If there is no selector after `/phasify`, explain:

```text
/phasify 0              — run phase P0
/phasify p2             — run named phase P2
/phasify next           — run the next incomplete phase
/phasify 3              — run the next 3 phases, one after another (sync)
/phasify next 1image    — next phase + newest scratch image
/plannify <prompt>      — produce a plan (does not execute)
/runnify <prompt>       — execute a prompt (not phase-scoped)
```

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

**Next incomplete** = first phase whose Status is not `Done` or `Deferred`
(treat `Not started`, `Left`, `In progress`, `Blocked` as eligible; if
`Blocked`, try it only if this run can unblock it, otherwise skip and say
so).

If the named phase does not exist, stop and list the real phase ids.
If **Next-N** asks for more phases than remain, run the remainder and say
the shortfall.
If the named phase is already `Done`, do not redo it unless the user said
`redo` / `--force`; report that and still print the closing recap.

---

## Execute (mutating, phase-scoped)

1. Validate the selected phase(s) against the real workspace (`read_file` /
   `grep` / `list_dir`).
2. **Execute only** that phase's exit criteria — implement, edit, test as
   needed. Do not start later phases. Do not reopen earlier `Done` work
   except to fix a blocker this phase depends on.
3. **Synchronous Next-N (mandatory):** finish phase x **completely**
   (work landed or explicitly Blocked) **before** phase x+1 begins.
   Do **not** run phases in parallel, as background agents, or as a batch
   of simultaneous todos. No async fan-out.
4. Mark status accurately: `Done` only if the work **landed**; else
   `In progress`, `Blocked`, or leave as `Left`. Remaining unstarted work
   after a partial run is **`Left`**.
5. If a phase is **Blocked**, stop the Next-N sequence. Do not start x+1.

Use scratch images (when marked) as extra detail while implementing.

---

## Phase COMPLETED banner (obvious)

After each phase that **finishes** (Done or Blocked), print a single-line
box **before** starting the next phase (and before the progress table).
Pad so every banner line is the same width:

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

Then print the **aligned Phased plan table** (next section). That table
is the between-phase output on Next-N and the closing recap after the
last phase. For a single-phase run (`0` / `pN` / `next`), still print
the banner, then the table.

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

### Fixed widths (every line is **exactly 88** characters)

| Piece | Inner width | `│` column index |
|-------|-------------|------------------|
| Phase | **15** | left border = 0; after Phase = **16** |
| Description | **58** | after Description = **75** |
| Status | **11** | right border = **87** |

`0 + 15 + 1 + 58 + 1 + 11 + 1 = 88`. Count characters before sending.
If any line is not 88, or any `│` is not in columns 0 / 16 / 75 / 87,
rebuild the line. No trailing space after the right border.

### Characters

- Single-line box only: `┌┬┐ ├┼┤ └┴┘ │ ─` (not `╔═╗`, not markdown pipes).
- Pad with spaces — **never tabs**.
- Cell text: one leading space, then content, then spaces to the inner
  width. Example Phase ` P0 — Spec     ` (15), Status ` Done      ` (11).

### Wrap — keep the three columns on every line

Long text wraps **inside Description only** (max **56** characters of
content after the leading space). Word-wrap; never overflow a cell.

- **Task** (original ify text): Phase label `Task` on the **first** wrap
  line, blank Phase on continuations. Status `Planned` on the **first**
  Task line only; blank after.
- **Flags** (only if `Nimages` and/or `Npass`): Phase `Flags` on the
  first wrap line. Status `Understood` on the first line, blank after.
  Description: `Caught and correctly interpreted <tokens>. On pass k of N.`
- **Work phases:** Phase id (`P0 — Spec`) and Status on the **first**
  wrap line only; continuations have a blank Phase and a blank Status.

Row separators always keep three columns (`┼` / `┬` / `┴`). Never
collapse a separator across the full table width.

### Row order

1. Column titles: `Phase` / `Description` / `Status`
2. **Task** — verbatim original ify text (promptify / askify / runnify /
   plannify / debugify). No `## Plan`, kickoff prompt, intent rewrite,
   scores, or “optimized” wording. Do not rewrite or summarize it.
3. **Flags** — omit if neither marker is present
4. Work phases in order, current statuses

### Status words (must fit in 11 with the leading space)

Use exactly: `Planned` · `Done` · `Left` · `Blocked` · `Deferred` ·
`Progress` · `Understood`. Do **not** write `In progress` (too long).
Mark from this run + prior **verified** work only.

### Canonical example (copy these widths)

This example is already 88 characters per line:

```text
┌───────────────┬──────────────────────────────────────────────────────────┬───────────┐
│ Phase         │ Description                                              │ Status    │
├───────────────┼──────────────────────────────────────────────────────────┼───────────┤
│ Task          │ 2pass any page that has detail data that can potentially │ Planned   │
│               │ be edited in place needs an edit, undo, and save button  │           │
│               │ where the delete and refresh buttons are.                │           │
├───────────────┼──────────────────────────────────────────────────────────┼───────────┤
│ Flags         │ Caught and correctly interpreted 1image. On pass 1 of 1. │ Understood│
├───────────────┼──────────────────────────────────────────────────────────┼───────────┤
│ P0 — Spec     │ Freeze E1–E12 in DESIGN_FLUENT_INSTANCE_EDIT.md          │ Done      │
├───────────────┼──────────────────────────────────────────────────────────┼───────────┤
│ P1 — Chrome   │ Shared instanceEditChrome + Email Clear → Undo           │ Done      │
├───────────────┼──────────────────────────────────────────────────────────┼───────────┤
│ P2 — SPA      │ Campaign edit mode; lift blackouts Save                  │ Left      │
└───────────────┴──────────────────────────────────────────────────────────┴───────────┘
```

---

## Closing recap (mandatory when the run's phase(s) complete)

After the last banner, print **only** `## Phased plan` plus the aligned
table (last section; promptify trailing-table rule). Nothing after the
table except an optional one-line next-step (e.g. `/phasify next`).

---

## Response shape

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, if marker present

## Phase P0 — Spec
(short: what you implemented)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P0 — Spec   COMPLETED                              │
└──────────────────────────────────────────────────────────────┘

## Phased plan
(aligned 88-column table — between phases on Next-N)

## Phase P1 — API
(only if Next-N included it; after P0 fully finished)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P1 — API   COMPLETED                               │
└──────────────────────────────────────────────────────────────┘

## Phased plan
(same aligned table, updated statuses — last printed section)
```

---

## Hard rules

- Execute only the selected phase(s). Do not re-plan the whole project.
- Next-N is **synchronous**: x finishes, then x+1 begins.
- Never invent a plan, phases, or workspace resources.
- Do not mark `Done` unless the work landed.
- Last printed section is the **Phased plan** table in the
  `phase_layout.txt` layout. Original ify text is the **Task** row
  (three columns, wrapped) — never a separate box, never a spanning
  cell, never plannify's interpreted or projected plan text.
- Every table line is exactly 88 characters with `│` at 0, 16, 75, 87.
- Image markers are not phase selectors; acknowledge them first when present.
