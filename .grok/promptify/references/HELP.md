# Promptify — user reference

Print this file as the response when the user runs `/promptify help`,
`/promptify --help`, or `/promptify /?`. Do not run the pipeline.
`/promptify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/promptify` is the short usage cheat, not this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Prompt QA against the **real workspace**: analyze intent, validate
assets, enrich with verified facts only, score readiness, and return
an optimized execution-ready prompt.

`/promptify` does **not** execute the work. `/runnify` does.

Workspace is source of truth. Never invent files, APIs, tools, DBs,
or datasets.

---

## How to invoke

```text
/promptify <prompt>    — analyze / validate / enrich / rewrite (no execute)
/promptify help        — this reference (also --help / /?)
/promptify tldr        — short form; stop
/promptify pass        — Pass (Npass) subsection only (also pass help)
/runnify <prompt>      — same pipeline, then EXECUTE the optimized prompt
/promptify-run <prompt>— alias of /runnify
```

The prompt is everything after the command, or the free-text request
when they said “promptify this” / “optimize this prompt”.

---

## Modes

| Invocation | Mode | Execute? |
|------------|------|----------|
| `/promptify <prompt>` | **Analysis** | **No** — rewrite only |
| `/runnify <prompt>` | **Execution** | **Yes** — after optimize, run the optimized prompt only |
| `/promptify-run <prompt>` | **Execution (alias)** | Same as `/runnify` |
| `/promptify` *(empty)* | Short usage | No pipeline |
| `/promptify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/promptify tldr` | **tldr** | Print the short page; stop |
| `/promptify pass` / `pass help` | **Pass help** | Print the Pass section; stop |

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me write a login form` is a
task. Unnumbered `pass` in a longer body is not this Help.

---

## Flag parse order (`Nimages` / `Npass`)

Read left to right. Each family independently. **First numbered
instance** counts.

| Rule | Example |
|------|---------|
| Numbered instance counts | `1image`, `1 image`, `1-image`, `3images`, `2pass`, `2-pass` |
| Unnumbered word does **not** count | `image`, `images`, `pass`, `passes` — keep scanning |
| Later numbered wins over earlier unnumbered | `create an image of the run. 1image` → `1image` |
| Several numbered → first only | Do **not** take the largest N |
| No numbered instance → flag absent | Ordinary English “image” / “pass” is not a marker |

Strip these tokens before deciding Help vs task. They are not part
of the task wording.

---

## Scratch images (`Nimages`)

`Nimages` / `N images` / `N-images` (also singular `Nimage` / `N image`
/ `N-image`). Attachment marker.

**Meaning:** the N most recent images from the configured scratch
source (or workspace `scratch/` if unset). If `scratch.env` exists,
run `scripts/cli.sh scratch ls N` (or `scripts\cli.ps1 scratch ls N`)
and read those paths. Else workspace `scratch/` (`*.png` `*.jpg`
`*.jpeg` `*.webp` `*.gif` `*.bmp`; newest mtime first). Do not create
`scratch/`. List paths in Validated or Missing Assets; carry facts
into the optimized prompt. Ack names the source (`local …` or
`remote conn:dir` or workspace `scratch/`).

**First printed content** when present:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

If the source or enough images are missing, still print this, then
say what was missing.

---

## Pass (`Npass`)

There is **no** `/pass` skill. `Npass` is a shared flag. After flag
strip, remaining body exactly `pass` or `pass help` prints **this
section** and stops. Full reference: `/promptify help`.

**Tokens:** `Npass` / `N-pass` / `N pass` (e.g. `2pass`, `2-pass`,
`2 pass`). Parse per **Flag parse order** above — first numbered
instance left to right; skip unnumbered `pass` / `passes`. Default
**1** if absent.

**Meaning:** take N pipeline passes **before** the final optimized
prompt (promptify), plan (plannify), answer (askify), or this
mode’s deliverable (runnify / phasify / debugify). Not task
wording. Not a phase selector.

Acknowledge after the scratch ack when both appear.

```markdown
**Npass — caught and correctly interpreted.**
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan;
passes 2–N use that base for the final deliverable.
```

| N | Behavior |
|---|----------|
| **1** | Normal pipeline once. No pre-plan section. |
| **> 1** | Pass 1 = documented `## Pre-plan (pass 1)` only (inventories, capabilities, external tools, approach, gaps, light planning). **Do not** emit the final prompt / plan / answer on pass 1. Passes 2–N use that base. **Last pass** emits the deliverable. |

Independent of `Nimages` — both may appear.

```text
/promptify pass
/promptify pass help
/promptify 2pass <task>
/runnify pass help
/phasify pass help
```

---

## Pipeline

1. **Intent analysis** (no workspace yet) — goal, outcome, deliverable,
   entities, constraints, assumptions, ambiguities, missing info,
   success criteria.
2. **Workspace validation** — read/search/list the real environment.
   Produce Validated / Recommended / Missing Assets, Coverage,
   Execution Readiness, improvement recommendations.
3. **Optimized prompt** — rewrite for this workspace (Objective,
   Workspace Context, Validated Resources, Instructions, Output
   Format, Success Criteria, Assumptions). Copy-pasteable.
4. **Scores** (0–100): Execution Readiness · Coverage · Confidence.
   If any **< 80**, revise the prompt once and re-score.
5. **Self-critique** (silent) — then respond.
6. **Mode branch:** `/promptify` returns the sections and **stops**.
   `/runnify` then **executes only the optimized prompt** and appends
   **Results**.

---

## Response shape

Lead with scratch ack (if any), then Npass ack (if any), then:

Intent Analysis → Workspace Assessment → Pre-plan (only if Npass > 1)
→ Optimized Prompt → Scores → (runnify: Results) → **Phased plan**
when required.

---

## Trailing phase table

**Last printed section** when the work is (or produces) a multi-phase
plan, **or** when `Nimages` / `Npass` is present.

Skip only for a true single-step ask **and** no image/pass marker.

GitHub markdown:

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `2images`, `3pass`. On pass 2 of 3. | Understood |
| P0 — Spec | Freeze decisions | Done |
| P1 — API | Endpoints + tests | Left |
```

| Column | Content |
|--------|---------|
| **Phase** | Short id + title (`P0 — Spec`) |
| **Description** | One-line exit criteria |
| **Status** | `Done` · `In progress` · `Left` · `Blocked` · `Unblocked` · `Deferred` · `Def-Blocked` (fresh plans may use `Not started`). Canonical definitions + transitions: phasify HELP **Concepts**. Aligned recap spelling of in-progress is `Progress` (never `In progress` in the 12-wide table). Do not invent statuses. |

**Flags row** (first row when either marker is present): Phase =
`Flags`. Description = `Caught and correctly interpreted` + exact
token(s) + `On pass k of N` (N defaults to 1; after the last pass
`On pass N of N`). Status = `Understood`. Not a work phase. Omit
only when neither marker appeared.

Mark `Done` only if the work landed. Use `Left` for remaining phases
after a partial run. Nothing after the table except an optional
one-line next-step.

---

## Execution rules (`/runnify` only)

1. Finish optimize + scoring first (including revision if score < 80).
2. If Execution Readiness is Low or critical assets are Missing, say
   so; execute only what is safe; list blockers.
3. Prefer paths verified in Workspace Assessment.
4. Do not expand past the optimized prompt.
5. Multi-phase work ends with the trailing table.

---

## Hard rules (short)

- Never invent workspace resources or claim files/DBs/APIs exist
  without checking.
- Optimized prompt must be better than the original for **this**
  environment and copy-pasteable.
- Analysis mode must not run builds, deploys, or mutating work.
- Multi-phase (or any Nimages/Npass): last content is the phase table;
  Flags is the first row when markers are present.
- `Nimages`: read N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`; lead with the ack (name the source).
- `Npass`: N passes; pass 1 is pre-plan only when N > 1.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not run the pipeline. Exact `tldr`: print `references/TLDR.md`
  (not this file). Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only. There is no `/pass` skill.

---

## Related

| Command | Role |
|---------|------|
| `/runnify <prompt>` | Optimize then execute |
| `/askify <prompt>` | Optimize then answer (read-only) |
| `/plannify <prompt>` | Optimize then plan (read-only) |
| `/phasify` | Execute the next plan phase |
| `/debugify <bug>` | Full Debug Mode loop |
| `/debug-kickoff <bug>` | Read-only debug brief |
| `/addify <text>` | Append `<text>` to the last ify and restart/continue that skill |
