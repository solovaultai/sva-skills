---
name: plannify
description: >-
  Plannify — Promptify planning mode / planning-prompt coach. Reworks any request
  into the ideal Cursor prompt for kicking off a PLANNING agent run, then runs that
  optimized prompt read-only to produce a structured plan. Use when the user runs
  /plannify, /promptify-plan (alias), /plannify fromhere (alias planify
  fromhere), "plannify", "plan this prompt", "turn this into a planning
  prompt", or wants a prompt reworked for a planning/design run and
  the plan produced. `/plannify fromhere` replans from current phase
  statuses (Keep new plan vs Continue original). Trailing tables may use
  Status `Deferred` and an optional reason note. Recognizes Nimages /
  N images / N-images as a pointer to the newest N images in the
  workspace scratch/ folder. Recognizes Npass / N-pass / N pass as a
  request to take N passes (pass 1 is a documented pre-plan when N > 1)
  before producing the plan. Print a complete reference with
  `/plannify help` or `/plannify --help` (also `/?`).
---

# Plannify (= Promptify planning mode)

You are running **Promptify in Planning mode** (`/plannify`) — a planning-prompt
coach. Like `/runnify`, but the "run" produces a **plan**, never code changes.

## What it does

1. Coach the raw request into the perfect Cursor **planning-kickoff prompt**.
2. Then run that optimized prompt in a **read-only** planning pass and emit a
   structured plan.

## Base pipeline

1. Read and follow `~/.cursor/skills/promptify/SKILL.md` for:
   - Step 1 Intent analysis
   - Step 2 Workspace validation
   - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
     score < 80)
   - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
2. Force mode = **Planning** (`/plannify`), even if the user only said "plannify".
3. Treat `/promptify-plan` as an alias of this skill.
4. Treat `/plannify fromhere` and `planify fromhere` as **fromhere**
   (see **`/plannify fromhere`**). Not a greenfield plan.

Override Promptify's **step 3** (optimized prompt) and **step 6** (mode branch)
with the two sections below.

## Scratch images (`Nimages`)

When the user text includes **`Nimages`**, **`N images`**, or **`N-images`**
(case-insensitive; also `Nimage` / `N image` / `N-image`; examples: `1images`,
`1 images`, `1-images`), that token is an **attachment marker**, not part of
the task wording.

The **N most recent image files** in workspace **`scratch/`** (`*.png`,
`*.jpg`, `*.jpeg`, `*.webp`, `*.gif`, `*.bmp`; newest mtime first) provide
extra visual detail for the issue under review. Resolve `scratch/` at the
repo root (or the project's existing `scratch` dir — do not create one),
**read** those N images (or all if fewer), list them in Validated Assets
(or Missing Assets), and carry what they show into the Planning-Kickoff
Prompt and the plan. Parse image/pass flags per promptify **Flag parse
order** (first numbered instance left to right; skip unnumbered
`image`/`pass` so a later `1image` / `2pass` can count).

**Tell the user (mandatory, first printed content):** Print this so it is
obvious the token was **caught and correctly interpreted**. Do not skip or
bury it:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on the issue under review.
```

## Multi-pass (`Npass`)

When the user text includes **`Npass`**, **`N-pass`**, or **`N pass`**
(case-insensitive; examples: `2pass`, `2-pass`, `2 pass`), follow
promptify **Multi-pass**. Take **N passes** before producing the plan.

If **N > 1**: pass 1 is a **documented pre-plan** only (`## Pre-plan
(pass 1)` — inventories, existing capabilities, external tools, approach,
gaps, light planning). Do **not** emit the final plan on pass 1.
Passes 2–N use that base; the **last pass** produces the Planning-Kickoff
Prompt and the **Plan**. Acknowledge the marker (after scratch ack if
both are present).

```markdown
**Npass — caught and correctly interpreted.**
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan;
passes 2–N use that base for the final plan.
```

## `/plannify fromhere` (alias `planify fromhere`)

Read-only replan from the **current** plan's statuses. Not a greenfield
plan. If the task body is `fromhere` (or the user said `planify
fromhere`), use this path — do not treat it as an empty `/plannify`.
If no current plan exists, tell the user to `/plannify` first.

1. Recover Task row text (original ify wording) and Flags (`Nimages` /
   `Npass` or none). Same outcome as that Task; same flags.
2. List phases already `Done` (landed) and `Deferred` (skip + reason).
   Do not treat them as greenfield.
3. Run the normal plannify pipeline (including Npass if the Flags row
   has it; read scratch images if Nimages is set).
4. Emit a **candidate** plan that keeps Done/Deferred constraints and
   aims at the same Task.

Then **AskQuestion**: Keep new plan vs Continue original. If it fits,
show the two phased tables **side by side** (or stacked labeled Original /
Candidate if width fails). The chosen plan becomes the current plan for
later `/phasify`. Use the AskQuestion tool for that Keep / Continue choice.

## Override step 3 — Planning-Kickoff Prompt

Instead of Promptify's execution-oriented Optimized Prompt, produce the ideal prompt
to **start a planning agent run**. It must instruct the planner to PLAN, not
implement. Required sections:

```text
Objective:
Produce a plan/design for <X>. Plan only — do NOT implement, edit, or modify anything.

Workspace Context:
<verified files / systems / paths relevant to planning>

Research Scope:
<what the planning agent should investigate before planning, and where to look>

Key Decisions & Trade-offs:
<the choices to weigh, with options where known>

Open Questions:
<clarifications to resolve from the workspace or surface to the user — never silently assume>

Constraints:
<hard limits: compatibility, security, scope, style>

Deliverable:
A phased, actionable plan — ordered steps/todos, cited file paths, and explicit
out-of-scope. Proportional to complexity. The plan body may detail phases inline,
but the response MUST end with a single summary table of all phases (see
Trailing phase table).

Definition of Done (for the plan):
<what makes the plan complete, reviewable, and ready to execute; includes the
trailing phase table as the last printed content>
```

## Trailing phase table (mandatory)

Every plannify response that produces a plan MUST end with a **phase summary
table as the last printed item** (after all other Plan content). Users scroll to
the bottom to see completed vs left-to-do — never bury the only phase list mid-doc.

**Placement:** Absolute end of the full response (after `## Plan` and any design
detail). Nothing after the table except optional one-line next-step if needed;
prefer **table is last**.

**Format:** Same table as promptify **Trailing phase status**. GitHub markdown.
Required columns:

| Column | Content |
|--------|---------|
| **Phase** | Short id + title (e.g. `P0 — Spec`, `Phase 1 — API list/detail`) |
| **Description** | One-line what ships / exit criteria (keep scannable) |
| **Status** | `Not started` for new plans; or `Done` / `In progress` / `Left` / `Blocked` / `Deferred` when known. Status `Deferred` is allowed on new plans for future-consideration slices. |
| **Reason** | Optional. If a deferral (or future-consideration slice) has a reason, add a Reason note on that row so it matches phasify deferrals. |

Example (last thing in the response):

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `2pass`. On pass 2 of 2. | Understood |
| P0 — Spec | Freeze decisions + write design note | Not started |
| P1 — API | List/detail endpoints + tests | Not started |
| P2 — SPA | Page shell + core UI | Not started |
```

Rules:

- When `Nimages` and/or `Npass` is present, **first row is Flags** (see
  promptify Trailing phase status): caught-and-understood tokens +
  **On pass k of N**. Not a work phase.
- After the optional Flags row, one row per phase/todo the plan expects an executor to run.
- Status defaults to **Not started** on a fresh plan unless the workspace already
  shows partial delivery (then mark accurately; remaining work is **Left**).
  Status may be **`Deferred`** with an optional reason note so new plans can
  mark future-consideration slices the same way.
- Do not omit the table when the plan body already has a long phase section —
  the trailing table is the scannable index; the body may elaborate above it.
- If the plan has no phases (rare: single-step), still emit a one-row table.

## Override step 6 — Planning execution (read-only)

After optimize + scoring:

1. Run **only** the optimized Planning-Kickoff Prompt (not the raw request).
2. **READ-ONLY**: research with read/search/list/read-only shell + MCP inspection.
   Make **NO** edits, writes, commits, installs, builds, deploys, or any other
   mutating action.
3. Resolve open questions from the workspace where possible. If a genuinely blocking
   decision remains (multiple valid paths that materially change the plan), ask 1-2
   targeted questions with the AskQuestion tool before finalizing.
4. Produce the plan:
   - In an agent that has a plan tool (Cursor Plan mode `CreatePlan`), register the
     plan with it.
   - Otherwise, output a structured markdown plan under `## Plan`.
5. Keep the plan proportional to complexity; cite real, verified paths.
6. **Always end the response** with the Trailing phase table (`## Phased plan` +
   markdown table: Phase | Description | Status). No substantive content after it.

## Help (`help` / `--help` / `/?`)

Strip `Nimages` / `Npass` first (Flag parse order). If the **remaining
body is exactly** `help`, `--help`, or `/?` (case-insensitive), **read
and print** `references/HELP.md` (this skill folder) and **stop**. Do
not plan or replan. Empty `/plannify` is the short usage below, not
Help. `fromhere` is a task body, not Help. `help me …` is a **task**,
not Help.

## No task body

`fromhere` / `planify fromhere` is a task body — follow **`/plannify
fromhere`**, do not print Help.

If there is no task after the command, explain:

```text
/plannify <prompt>    — coach into a planning-kickoff prompt, then produce the plan
/plannify fromhere    — replan from current statuses (Keep new vs Continue original)
/plannify help        — full reference (also --help, /?)
/promptify <prompt>   — analyze/optimize only (no run)
/runnify <prompt>     — optimize then EXECUTE the work (mutating)
```

The prompt to plan is everything after the command, or the free-text request when
they said "plannify this" / "plan this prompt" / "turn this into a planning prompt".

## Response format

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<token>` as an attachment marker. Looking at the N most recent image(s) in `scratch/` for extra detail on the issue under review.

**Npass — caught and correctly interpreted.**   ← when an Npass marker is present
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan; passes 2–N use that base for the final plan.

## Intent Analysis
…

## Workspace Assessment

### Validated Assets
…

### Recommended Assets
…

### Missing Assets
…

### Coverage Assessment
Low | Medium | High

### Execution Readiness
Low | Medium | High

## Pre-plan (pass 1)   ← only when Npass > 1
…

## Planning-Kickoff Prompt
…
(full structured prompt from step 3 — copy-pasteable as a standalone planning instruction)

## Scores
Execution Readiness: XX
Coverage: XX
Confidence: XX

## Plan
…
(the produced plan — via CreatePlan when available, else markdown)

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| … | … | Not started |

(the trailing phase table is **mandatory** and must be the last section —
see Trailing phase table)
```

## Hard rules

- Never invent workspace resources; verify with read/search before citing them.
- The planning pass MUST NOT modify the system (no edits/commits/builds/deploys).
- The Planning-Kickoff Prompt must be copy-pasteable as a standalone planning
  instruction and must clearly say "plan, do not implement."
- Keep the plan proportional to complexity; prefer verified repo-relative paths.
- If Execution Readiness is Low or critical assets are Missing, say so and either
  resolve it via questions or make the plan's first phase close those gaps.
- **Trailing phase table is mandatory:** end every plan with
  `## Phased plan` as a markdown table (Phase | Description | Status) so the
  user can read completed vs left-to-do without scrolling up. Default Status:
  `Not started`. Status `Deferred` and an optional reason note are allowed
  so new plans can mark future-consideration slices the same way.
- `/plannify fromhere` (alias `planify fromhere`): read-only replan from
  current statuses. Same Task and Flags. Keep Done/Deferred constraints.
  Then **AskQuestion**: Keep new plan vs Continue original. Side by side
  (or stacked labeled Original / Candidate if width fails). The chosen
  plan becomes current for later `/phasify`.
- `Nimages` / `N images` / `N-images`: read the N newest images in `scratch/`
  and treat them as extra detail for the issue under review (see **Scratch
  images**). Lead the response with the **caught and correctly interpreted**
  acknowledgment so the user can see the marker was recognized.
- `Npass` / `N-pass` / `N pass`: take N passes (see **Multi-pass**). When
  N > 1, pass 1 documents a pre-plan only; later passes use that base;
  the last pass emits the plan. Acknowledge the marker.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Empty `/plannify` is short usage, not
  Help. `fromhere` is not Help. `help me …` is a task.
