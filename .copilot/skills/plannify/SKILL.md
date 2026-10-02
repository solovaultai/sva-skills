---
name: plannify
description: >-
  Plannify — Promptify planning mode: coach into a planning-kickoff
  prompt, then produce a structured plan (read-only). Use when the user
  runs /plannify, /promptify-plan, /plannify fromhere (alias planify
  fromhere), /plannify add, or "plan this prompt". fromhere replans
  from current statuses (Keep new vs Continue original in Copilot
  chat). add surgically adds a feature (last ify must be plannify or
  phasify). Tables may use Deferred + reason. /plannify help, tldr, or
  pass help for reference. Recognizes Nimages and Npass.
argument-hint: "[<prompt>]"
user-invocable: true
---

# Plannify (= Promptify planning mode)

You are running **Promptify in Planning mode** (`/plannify`) — a planning-prompt
coach. Like `/runnify`, but the "run" produces a **plan**, never code changes.

## What it does

1. Coach the raw request into the perfect Copilot **planning-kickoff prompt**.
2. Then run that optimized prompt in a **read-only** planning pass and emit a
   structured plan.

## Base pipeline

1. Read and follow `~/.copilot/skills/promptify/SKILL.md` for:
   - Step 1 Intent analysis
   - Step 2 Workspace validation
   - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
     score < 80)
   - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
2. Force mode = **Planning** (`/plannify`), even if the user only said "plannify".
3. Treat `/promptify-plan` as an alias of this skill.
4. Treat `/plannify fromhere` and `planify fromhere` as **fromhere**
   (see **`/plannify fromhere`**). Not a greenfield plan.
5. Treat `/plannify add <feature>` as **Add** (see **`/plannify
   add`**). Not a greenfield plan. First token `add` after flag
   strip is this mode.

Override Promptify's **step 3** (optimized prompt) and **step 6** (mode branch)
with the two sections below.

## Scratch images (`Nimages`)

When the user text includes **`Nimages`**, **`N images`**, or **`N-images`**
(case-insensitive; also `Nimage` / `N image` / `N-image`; examples: `1images`,
`1 images`, `1-images`), that token is an **attachment marker**, not part of
the task wording.

Follow promptify **Scratch images**: if `scratch.env` exists, run
`scripts/cli.sh scratch ls N` (or `scripts\cli.ps1 scratch ls N`) and
**read those paths**. Else workspace `scratch/` (do not create). Parse
image/pass flags per promptify **Flag parse order**. Carry what they show
into the Planning-Kickoff Prompt and the plan.

**Tell the user (mandatory, first printed content):** Print this so it is
obvious the token was **caught and correctly interpreted**. Name the
source (`local …` or `remote conn:dir` or workspace `scratch/`).

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
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
2. List phases already `Done` (landed) and `Deferred` / `Def-Blocked`
   (skip + reason). Do not treat them as greenfield.
3. Run the normal plannify pipeline (including Npass if the Flags row
   has it; read scratch images if Nimages is set).
4. Emit a **candidate** plan that keeps Done/Deferred/Def-Blocked
   constraints and aims at the same Task.

Then **Copilot chat confirm**: Keep new plan vs Continue original. If it fits,
show the two phased tables **side by side** (or stacked labeled Original /
Candidate if width fails). The chosen plan becomes the current plan for
later `/phasify`. Use a Copilot chat confirm for that Keep / Continue choice.

## `/plannify add`

Surgically add a **feature** to the plan that was just run. Not a
greenfield plan. Not fromhere (no Keep vs Continue). Not addify
(addify on plannify restarts from scratch and discards statuses).

After flag strip, **first token `add`** (case-insensitive) is this
mode. Remainder is the feature text (**verbatim**). `add` is
reserved — `/plannify add a login page` is Add, not a greenfield
prompt that happens to start with “add”.

### Gate (required)

Recover the last ify with addify **Recover last ify** (this tree;
newest-first; skip help / tldr / pass / empty-usage; do not skip
empty `/phasify`; if last is addify, walk to the non-addify
ancestor). Do **not** invent a last-ify store.

| Last ify (ancestor) | Effect |
|---------------------|--------|
| **plannify** or **phasify** | Continue. Need a recoverable current plan. |
| None, or any other ify (`runnify`, `askify`, `promptify`, `debugify`, `ify`, …) | **Error:** do not plan. |

```text
**Error:** `/plannify add` requires the previous ify to be
plannify or phasify.
```

Use the same red/bold **Error:** style as phasify invalid id.
Name the last ify if one exists (`Last ify was runnify.`). If
none: `No last ify in this conversation.` Stop. Do not invent a
plan.

No current plan (or plan unrecoverable): **Error:** `/plannify`
first. Do not invent phases.

Empty remainder (`/plannify add` with no feature): **Error:**
`add` needs a feature. Show the short `add` usage line. Stop.

### Surgical merge

Read-only. Recover Task, Flags, and the current phase table
(same locate-plan rules as fromhere / phasify).

Compare the feature text to the **current** plan (Task + phase
titles + descriptions). Classify: **no-op** · **add** ·
**remove** · **change** (more than one may apply).

**No-op** — the text does **not** add, remove, or change a
feature:

```text
**Add — no plan change.**
That text does not add, remove, or change a feature. Keeping
the current plan.
```

Reprint the current table last. Do **not** rewrite Task. Do not
Copilot chat confirm.

**Otherwise** — redo **only** what the feature requires:

1. Task = original Task + newline + add body (**verbatim**).
   Flags = existing plus add-line flags (add-line wins the same
   family). Strip `Nimages` / `Npass` from the add body after
   parse.
2. Unaffected phases: keep id, title, Description, Status, and
   Reason **as-is**.
3. Changed phases: rewrite only those rows. If Status was `Done`
   and the new exit criteria are no longer satisfied, set
   `Left`. If landed work still meets the new criteria, keep
   `Done`.
4. New feature: insert phase(s) in plan order; new rows
   `Not started` (or `Left` if the walk already started).
5. Removed feature (only if the add text clearly drops one):
   drop those work-phase rows. Never drop Task / Flags.
6. Compact-renumber only when insert/delete shifts later ids.
   Titles after `—` on kept rows stay.
7. Do **not** Copilot chat confirm. The user already asked to add.
8. Do **not** restart from scratch. Do not discard unrelated
   Done / Deferred / Def-Blocked / reasons.

Print `**Add — applied.**` (what was added / changed / removed)
then the updated **Phased plan** table last. Skip the full
greenfield Intent / Kickoff / Scores dump on a no-op. On apply,
a short **Add** section (feature + kept vs redone vs new) is
enough; research only what the changed/new phases need.
Npass > 1: pass 1 is a pre-plan of the merge; last pass applies
or reports no-op.

```text
/plannify add OAuth login
/plannify add Defer - Delete IP
```

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
| **Status** | `Not started` for new plans; or `Done` / `In progress` / `Left` / `Blocked` / `Unblocked` / `Deferred` / `Def-Blocked` when known. Status `Deferred` is allowed on new plans for future-consideration slices. `Unblocked` is like `Left` (ready to run, not complete). `Def-Blocked` is the table spelling of canonical Deferred-Blocked (fits the 12-wide Status column). |
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
   targeted questions with a Copilot chat confirm before finalizing.
4. Produce the plan:
   - Output a structured markdown plan under `## Plan`. Do not name
     Cursor-only plan tools.
5. Keep the plan proportional to complexity; cite real, verified paths.
6. **Always end the response** with the Trailing phase table (`## Phased plan` +
   markdown table: Phase | Description | Status). No substantive content after it.

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**.
- Remaining body exactly `tldr` (case-insensitive):
  **read and print** `references/TLDR.md` (this skill folder) and
  **stop**. Extra tokens after `tldr` stay a **task**. There is
  no `tldr help` alias.
- Remaining body exactly `pass` or `pass help` (case-insensitive):
  print the **Pass (`Npass`)** section of that file and **stop**.
  There is no `/pass` skill.

Do not plan or replan. Empty `/plannify` is the short usage below,
not Help. `fromhere` is a task body, not Help. First token `add`
is **Add**, not Help. `help me …` is a
**task**, not Help.

## No task body

`fromhere` / `planify fromhere` is a task body — follow **`/plannify
fromhere`**, do not print Help. First token `add` is **Add** —
follow **`/plannify add`**, do not print Help.

If there is no task after the command, explain:

```text
/plannify <prompt>    — coach into a planning-kickoff prompt, then produce the plan
/plannify fromhere    — replan from current statuses (Keep new vs Continue original)
/plannify add <feat>  — add a feature to the just-run plan (last ify: plannify or phasify)
/plannify help        — full reference (also --help, /?)
/plannify tldr        — short form (stop)
/plannify pass help   — Pass (Npass) subsection (also `pass`)
/promptify <prompt>   — analyze/optimize only (no run)
/runnify <prompt>     — optimize then EXECUTE the work (mutating)
```

The prompt to plan is everything after the command, or the free-text request when
they said "plannify this" / "plan this prompt" / "turn this into a planning prompt".

## Response format

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<token>` as an attachment marker. Looking at the N most recent image(s) from <source> for extra detail on the issue under review.

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
(the produced plan — structured markdown)

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| … | … | Not started |

(the trailing phase table is **mandatory** and must be the last section —
see Trailing phase table)
```

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `PLAN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.

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
  current statuses. Same Task and Flags. Keep Done/Deferred/Def-Blocked
  constraints.
  Then **Copilot chat confirm**: Keep new plan vs Continue original. Side by side
  (or stacked labeled Original / Candidate if width fails). The chosen
  plan becomes current for later `/phasify`.
- `/plannify add <feature>`: first token `add` after flag strip.
  Last ify must be **plannify** or **phasify** (addify Recover);
  else **Error:**. Empty add: **Error:** needs a feature. Surgical:
  if the text does not add, remove, or change a feature, keep the
  plan as-is. Else redo only affected phases; keep the rest
  (including Done / Deferred / reasons). Not fromhere. Not addify
  from-scratch. No Copilot chat confirm.
- `Nimages` / `N images` / `N-images`: read the N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`
  and treat them as extra detail for the issue under review (see **Scratch
  images**). Lead the response with the **caught and correctly interpreted**
  acknowledgment so the user can see the marker was recognized.
- `Npass` / `N-pass` / `N pass`: take N passes (see **Multi-pass**). When
  N > 1, pass 1 documents a pre-plan only; later passes use that base;
  the last pass emits the plan. Acknowledge the marker.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `tldr` after flag strip:
  print `references/TLDR.md` and stop. Exact `pass` / `pass help`:
  print the **Pass (`Npass`)** section and stop. Empty `/plannify`
  is short usage, not Help. `fromhere` is not Help. First token
  `add` is Add, not Help. `help me …` is
  a task.
