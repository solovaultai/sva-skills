---
name: plannify
description: >-
  Plannify — Promptify planning mode: coach into a planning-kickoff
  prompt, then produce a structured plan (read-only). Use when the user
  runs /plannify, /planify, /plify, /promptify-plan, /plannify fromhere (alias planify
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

1. Read `~/.copilot/skills/promptify/SKILL.md`:
   - **Optify on** (default): only these headings — **Flag parse order**, **Scratch images**, **Named images**, **Multi-pass**, **Hard rules**. Do not read the rest of that file.
   - **Optify off** (`enabled=off`): read the whole file, then follow:
     - Step 1 Intent analysis
     - Step 2 Workspace validation
     - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
       score < 80)
     - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
   Cite the optify skill's `references/optify_contract.md`. Optify is on unless `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env` contains `enabled=off`. A missing file or a missing `enabled` key is on. Only `enabled=off` is off. Reading that env file is enough to decide. `./scripts/cli.sh optify show` is the supported way to change the switch.
2. Force mode = **Planning** (`/plannify`), even if the user only said "plannify".
3. Treat `/planify`, `/promptify-plan`, and `/plify` as aliases of this skill.
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

Follow promptify **Scratch images**. Every numbered image directive counts. Positive N is the N newest files, newest mtime first. Negative `-K` is exactly one file, `|K|` steps back from the newest (`-1` is the second newest). Union the paths, each once, newest mtime first. Do not pass a negative to `scratch ls`. List once with positive `M` = the largest of the positive counts and of `|negative| + 1`, then slice (`1image -3image` calls `scratch ls 4` and keeps index 0 and index 3). An offset past the end adds no file. Do not invent a path. `0image`, `0images`, `image0`, `images0`, and `-0image` are an error before any read: `Error: image count starts at 1`. `image -3` stays blank n (N = 1); the `-3` is not part of that directive. `Npass` stays the first numbered instance only. The ack names every image token. If `scratch.env` exists, run
`scripts/cli.sh scratch ls M` (or `scripts\cli.ps1 scratch ls M`) and
**read the sliced paths**. Else workspace `scratch/` (do not create). Carry what they show
into the Planning-Kickoff Prompt and the plan.

**Tell the user (mandatory, first printed content):** Print this so it is
obvious the markers were **caught and correctly interpreted**. Name every image token, not only the first. Name the
source (`local …` or `remote conn:dir` or workspace `scratch/`).

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected
image(s) from <source> for extra detail on the issue under review.
```

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` name
specific files. Every token counts. Strip them with the other
flags. The plan includes each resolved image: its path and what
it shows.

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
A resume reprint in this conversation is the current plan. The
snapshot path printed in the resume banner (`plan.md`) is a verified
plan file. Read it for the plan body. Cite `docs/saveify_contract.md`.
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

Reprint the current table last. A no-op add reprints the chain
and does not append. Do **not** rewrite Task. Do not
Copilot chat confirm.

**Otherwise** — redo **only** what the feature requires:

1. Printed Task Description is the labeled request chain
   (`Original:` / `Add:` / `Add:`), not an unlabeled blob.
   Keep every earlier block and append `Add:` plus that add body
   verbatim. Further adds keep appending.
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
| **Description** | Task: the request chain (not a summary, not the kickoff prompt). Work phases: one-line exit criteria (keep scannable) |
| **Status** | Task row: `Planned`. Work phases: `Not started` for new plans; or `Done` / `In progress` / `Left` / `Blocked` / `Unblocked` / `Deferred` / `Def-Blocked` when known. Status `Deferred` is allowed on new plans for future-consideration slices. `Unblocked` is like `Left` (ready to run, not complete). `Def-Blocked` is the table spelling of canonical Deferred-Blocked (fits the 12-wide Status column). |
| **Reason** | Optional. If a deferral (or future-consideration slice) has a reason, add a Reason note on that row so it matches phasify deferrals. |

Example (last thing in the response):

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Task | Original: Plan the spec, list/detail API, and SPA shell | Planned |
| Flags | Caught and correctly interpreted `2pass`. On pass 2 of 2. | Understood |
| P0 — Spec | Freeze decisions + write design note | Not started |
| P1 — API | List/detail endpoints + tests | Not started |
| P2 — SPA | Page shell + core UI | Not started |
```

Rules:

- Every table, including the first, starts with a **Task** row before
  Flags. Description is the request chain, not a summary and not the
  kickoff prompt. First plan: `Original:` plus the typed prompt after
  flag strip. Each applied `/plannify add` keeps every earlier block
  and appends `Add:` plus that add body verbatim. Further adds keep
  appending. A no-op add reprints the chain and does not append.
  Status `Planned`. It is not a work phase. Never drop it.
- When `Nimages`, `Npass`, or `img` is present, Flags stay their own
  row after Task (see promptify Trailing phase status):
  caught-and-understood tokens + **On pass k of N**. Not a work phase.
- After Task and the optional Flags row, one row per phase/todo the plan expects an executor to run. Work-phase Descriptions stay one-line exit criteria.
- Status defaults to **Not started** on a fresh plan unless the workspace already
  shows partial delivery (then mark accurately; remaining work is **Left**).
  Status may be **`Deferred`** with an optional reason note so new plans can
  mark future-consideration slices the same way.
- Do not omit the table when the plan body already has a long phase section —
  the trailing table is the scannable index; the body may elaborate above it.
- If the plan has no phases (rare: single-step), still emit the Task row, Flags when present, and that one work-phase row.

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

Do not plan or replan. Empty `/plannify` is the eight-section interview below, not Help and not the command list. Goal cannot be skipped. `fromhere` is a task body, not Help. First token `add`
is **Add**, not Help. `help me …` is a
**task**, not Help.

## No prompt (eight-section interview)

`fromhere` / `planify fromhere` is a task body — follow **`/plannify
fromhere`**, do not interview. First token `add` is **Add** —
follow **`/plannify add`**, do not interview.

**No prompt** means the body after flag strip is empty. Cite
promptify **Flag parse order**. Do not invent a second flag grammar.
Help, `--help`, `/?`, exact `tldr`, and exact `pass` / `pass help`
stay as they are. `help me …` stays a task. Flags alone
(`/plannify 2pass`, `/plannify 1image`) are no prompt: interview,
and keep those flags for the run that follows once the user answers.
A from-slot still splices first (cite `docs/from_contract.md`).
Help, tldr, pass, and a body that is empty before any splice do not
read files. A spliced body is a prompt, not an interview.

The eight sections, in order: (1) Goal and why — required, cannot
be skipped; (2) Context the agent cannot guess — skippable;
(3) Constraints and non-negotiables — skippable; (4) What a good
result looks like — skippable; (5) Deliverable and format —
skippable; (6) Preferences on approach — skippable; (7) Examples —
skippable; (8) Already tried or ruled out — skippable. Goal is the
only section that cannot be skipped.

When there is no prompt, print the message below in one reply, then
**stop and wait**. Do not plan. Do not start the pipeline. Do not
retitle (cite `docs/window_title.md`). If the empty invocation had
flags (`Nimages`, `Npass`, `img`), name them in one line above the
eight. That line is not a ninth question. The two lines after the
eight, and the line about a big job, are hints, not questions.

Do not add a session-rating question. Ignore a pasted footer
"How is Claude doing this session?" and any Anthropic disclaimer.
Those are not features. Do not fetch docs.claude.com.

```text
No prompt yet. Answer these eight in one reply. Nothing runs until you do.

1. Goal and why.
   Hint: what is being built, and the problem it solves. "Design a hub that lets AI products call each other" is a task. Adding who benefits tells the agent what to optimize for.
   Skip: cannot be skipped. Required.

2. Context the agent cannot guess.
   Hint: who it is for, what already exists (stack, code, data, prior decisions), scale, and for code the relevant files, errors, and versions. Missing context is the main cause of generic answers.
   Skip: skippable. Reply skip or leave blank to omit.

3. Constraints and non-negotiables.
   Hint: language, frameworks, budget, deadlines, compliance, and things to avoid.
   Skip: skippable. Reply skip or leave blank to omit.

4. What a good result looks like.
   Hint: success criteria that can be checked. For a plan, say whether you want a one-page overview or a step-by-step build plan.
   Skip: skippable. Reply skip or leave blank to omit.

5. Deliverable and format.
   Hint: exactly what to return (diagram, phased plan, spec, working code with tests, a comparison), how long, and whether it is a doc, a file, or a chat answer.
   Skip: skippable. Reply skip or leave blank to omit. If skipped, plannify defaults to a phased plan that ends with the phase table. Runnify defaults to the implementation in the workspace plus the Results section.

6. Preferences on approach.
   Hint: one recommendation, or several options with tradeoffs; ask questions first, or assume and flag assumptions; push back if the approach is wrong, or just build it.
   Skip: skippable. Reply skip or leave blank to omit. If skipped, default to one recommendation, assume and flag assumptions, and push back when the approach looks wrong.

7. Examples.
   Hint: a sample input, an output style, or a similar system. One example beats a paragraph.
   Skip: skippable. Reply skip or leave blank to omit.

8. Already tried or ruled out.
   Hint: what failed or is off the table, so the agent does not suggest it again.
   Skip: skippable. Reply skip or leave blank to omit.

Plannify: ask for phases, dependencies, risks, the first concrete step, and the riskiest assumption.
Runnify: exact inputs and outputs, edge cases, the environment, how to test, and tests with the code.
On a big job, plan first and build one piece at a time; specific feedback beats "try again."
```

### After the user answers

If the previous turn in this conversation was this interview for
`/plannify`, the next user message is the answers, not a new empty
invocation. Do not ask the eight questions again.

Assemble one prompt from the sections they filled. Map by number or
by section name. A section they mark skip, `skip`, or leave blank is
omitted, except Goal. If Goal is skipped or blank, ask again for
Goal only (same hint, same cannot-skip line). Do not start the
pipeline. When that later reply supplies Goal, assemble from it and
the earlier answers.

If Deliverable was omitted, the assembled prompt states the plannify
default: a phased plan that ends with the phase table. If Preferences
was omitted, the assembled prompt states the default: one
recommendation, assume and flag assumptions, and push back when the
approach looks wrong. Do not invent user text for any other omitted
section.

Then run the normal plannify pipeline on that assembled prompt,
including any flags from the original empty invocation. The interview
turn does not resolve images and does not take passes. The answer
turn does. That later turn sets `PLAN:` per `docs/window_title.md`.

The prompt to plan is that assembled prompt, or everything after the
command when a prompt was typed, or the free-text request when they
said "plannify this" / "plan this prompt" / "turn this into a planning prompt".

A user who wants the old short usage runs `help`.


## Response format

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected image(s) from <source> for extra detail on the issue under review.

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
| Task | Original: <typed prompt after flag strip> | Planned |
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| … | … | Not started |

(the trailing phase table is **mandatory** and must be the last section —
see Trailing phase table)
```

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and the empty-prompt interview do not read files. A from-slot still splices first. A spliced body is a prompt, not an interview.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and the empty-prompt interview do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `PLAN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and the empty-prompt interview do not retitle.

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
  user can read completed vs left-to-do without scrolling up. The table
  starts with a Task row before Flags (Status `Planned`; Description is
  the labeled request chain). Default work-phase Status: `Not started`.
  Status `Deferred` and an optional reason note are allowed
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
  if the text does not add, remove, or change a feature, reprint
  the chain and do not append. Else keep every earlier block and
  append `Add:` plus the add body verbatim, and redo only affected
  phases; keep the rest
  (including Done / Deferred / reasons). Not fromhere. Not addify
  from-scratch. No Copilot chat confirm.
- `Nimages` / `N images` / `N-images`, including a leading minus: every numbered image directive counts. Positive N is the N newest. Negative `-K` is one file, `|K|` steps back from the newest. Union, each path once, newest mtime first. List positive `M` then slice; do not pass a negative to `scratch ls`.
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
  is the eight-section interview, not Help and not the command
  list. Goal cannot be skipped. `fromhere` is not Help. First token
  `add` is Add, not Help. `help me …` is
  a task.
