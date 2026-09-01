---
name: phasify
description: >-
  Phasify — execute phase(s) of an existing plannified plan. Run a named
  phase (`/phasify 0`, `/phasify p0`, "run phase p0"), the next incomplete
  phase (`/phasify next`, "run next phase"), or the next N phases
  sequentially (`/phasify 3`, "run next 3 phases"). When phase(s) complete,
  reprint the user's original ify request (plannify / runnify / etc.) in a
  single-line border immediately above the phased plan with updated
  statuses — not plannify's interpreted or projected text. Use when the user runs /phasify,
  "phasify 0", "phasify next", "phasify 3", "run phase p0", "run next
  phase", or "run next n phases". Recognizes Nimages / N images / N-images
  (also Nimage / N image / N-image; e.g. 1image, 3images) as a pointer to
  the newest N images in the workspace scratch/ folder.
---

# Phasify (= execute plannified phase(s))

You are running **Phasify** (`/phasify`) — **execute** one or more phases of
an existing **plannify** plan. This is not a new planning pass and not a
full-plan `/runnify`. Implement only the selected phase(s).

Follow `~/.cursor/skills/promptify/SKILL.md` Hard rules (workspace is source
of truth; never invent files/APIs/tools/DBs) and its **Scratch images**
section. Follow `~/.cursor/skills/plannify/SKILL.md` for how a **Phased
plan** table is shaped (Phase | Description | Status).

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
executing the phase(s). If several image-N tokens appear, use the
**largest** N.

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
2. **Original ify text** (what you reprint in the box) — the user's **raw
   request** that kicked off plannify, runnify, promptify, askify,
   debugify, or whatever ify produced this plan. That is the text they
   typed after the slash command (or the free-text they asked to ify).
   It is **not** Intent Analysis, not the Kickoff/Optimized Prompt, not
   `## Plan`, and not any interpreted, projected, or updated text the
   ify created.

If the raw request is not in this conversation, recover it from the ify
invocation that created the plan. If it cannot be recovered, say so in
the box (`(original ify text not found)`) — do not substitute the plan.

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

1. Validate the selected phase(s) against the real workspace (read/search).
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
box **before** starting the next phase (and before the final recap).
Make it unmistakable:

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

For a single-phase run (`0` / `pN` / `next`), still print this banner,
then the closing recap.

---

## Closing recap (mandatory when the run's phase(s) complete)

After the banner(s), **before rewriting / reprinting the phased plan**,
print **exactly this pair**, in this order. The original-text box sits
**immediately above** the status table. The **Phased plan** table is the
last section (promptify trailing-table rule).

### 1. Original ify text — single-line border (immediately above the table)

This is only a reminder of **what the user is executing**. Print the
**verbatim original user text** of the plannify, runnify, or whatever
ify started this work, inside a **single-line** box (`┌─┐│└─┘`, not
double `╔═╗`).

**Do not include** any interpreted, projected, or updated text created
by plannify (or any other ify): no `## Plan`, no kickoff prompt, no
intent rewrite, no scores, no “optimized” wording. **Just the original
text.**

Do not rewrite, summarize, or “improve” that text. Wrap long lines
inside the box.

```text
┌─ Original ify text ──────────────────────────────────────────┐
│ <verbatim user request that they typed to plannify/runnify/…>│
│ …                                                            │
└──────────────────────────────────────────────────────────────┘
```

If the original is too long for a tidy box, keep the single-line border
and wrap; do not drop the border or replace the text with a summary or
with the generated plan.

### 2. Phased plan — up-to-date statuses

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| P0 — Spec | … | Done |
| P1 — API | … | Done |
| P2 — SPA | … | Left |
```

When `Nimages` and/or `Npass` is present, the **first row is Flags**:
`Caught and correctly interpreted <tokens>. On pass k of N.` Status
`Understood`. Then the work phases.

Statuses: `Done` · `In progress` · `Left` · `Blocked` · `Deferred` ·
`Not started`. Mark from this run + prior **verified** work only.

Nothing after the table except an optional one-line next-step
(e.g. `/phasify next`).

---

## Response shape

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, if marker present

## Phase P0 — Spec
(short: what you implemented)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P0 — Spec   COMPLETED                              │
└──────────────────────────────────────────────────────────────┘

## Phase P1 — API
(only if Next-N included it; after P0 fully finished)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P1 — API   COMPLETED                               │
└──────────────────────────────────────────────────────────────┘

┌─ Original ify text ──────────────────────────────────────────┐
│ …verbatim original user request (not the generated plan)…    │
└──────────────────────────────────────────────────────────────┘

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| … | … | Done / Left / … |
```

---

## Hard rules

- Execute only the selected phase(s). Do not re-plan the whole project.
- Next-N is **synchronous**: x finishes, then x+1 begins.
- Never invent a plan, phases, or workspace resources.
- Do not mark `Done` unless the work landed.
- Last printed section is the **Phased plan** table. Immediately above it,
  a single-line box with the **original ify text only** (user request) —
  never plannify's interpreted, projected, or updated plan text.
- Image markers are not phase selectors; acknowledge them first when present.
