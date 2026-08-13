---
name: plannify
description: >
  Plannify — Promptify planning mode / planning-prompt coach. Reworks any request
  into the ideal Grok prompt for kicking off a PLANNING agent run, then runs that
  optimized prompt read-only to produce a structured plan. Use when the user runs
  /plannify, /promptify-plan (alias), "plannify", "plan this prompt", "turn this
  into a planning prompt", or wants a prompt reworked for a planning/design run and
  the plan produced.
metadata:
  short-description: "Promptify planning mode — optimize then plan read-only"
---

# Plannify (= Promptify planning mode)

You are running **Promptify in Planning mode** (`/plannify`) — a planning-prompt
coach. Like `/runnify`, but the "run" produces a **plan**, never code changes.

## What it does

1. Coach the raw request into the perfect Grok **planning-kickoff prompt**.
2. Then run that optimized prompt in a **read-only** planning pass and emit a
   structured plan.

## Base pipeline

1. Read and follow `~/.grok/skills/promptify/SKILL.md` for:
   - Step 1 Intent analysis
   - Step 2 Workspace validation
   - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
     score &lt; 80)
   - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
2. Force mode = **Planning** (`/plannify`), even if the user only said "plannify".
3. Treat `/promptify-plan` as an alias of this skill.

Override Promptify's **step 3** (optimized prompt) and **step 6** (mode branch)
with the two sections below.

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
| **Status** | `Not started` for new plans; or `Done` / `In progress` / `Left` / `Blocked` / `Deferred` when known |

Example (last thing in the response):

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| P0 — Spec | Freeze decisions + write design note | Not started |
| P1 — API | List/detail endpoints + tests | Not started |
| P2 — SPA | Page shell + core UI | Not started |
```

Rules:

- One row per phase/todo the plan expects an executor to run.
- Status defaults to **Not started** on a fresh plan unless the workspace already
  shows partial delivery (then mark accurately; remaining work is **Left**).
- Do not omit the table when the plan body already has a long phase section —
  the trailing table is the scannable index; the body may elaborate above it.
- If the plan has no phases (rare: single-step), still emit a one-row table.

## Override step 6 — Planning execution (read-only)

After optimize + scoring:

1. Run **only** the optimized Planning-Kickoff Prompt (not the raw request).
2. **READ-ONLY**: research with `read_file` / `grep` / `list_dir` / read-only shell
   (`run_terminal_command`) + MCP inspection (`search_tool` / `use_tool`).
   Make **NO** edits, writes, commits, installs, builds, deploys, or any other
   mutating action. Do not use `search_replace`, `write`, mutating git, or
   install/deploy commands.
3. Resolve open questions from the workspace where possible. If a genuinely blocking
   decision remains (multiple valid paths that materially change the plan), ask 1–2
   targeted questions with the `ask_user_question` tool before finalizing.
4. Produce the plan:
   - When a formal plan-mode handoff is warranted (ambiguous approach, user wants a
     design review), use `enter_plan_mode`, write the plan, then `exit_plan_mode`.
   - Otherwise, output a structured markdown plan under `## Plan`.
5. Keep the plan proportional to complexity; cite real, verified paths.
6. **Always end the response** with the Trailing phase table (`## Phased plan` +
   markdown table: Phase | Description | Status). No substantive content after it.

## No task body

If there is no task after the command, explain:

```text
/plannify <prompt>    — coach into a planning-kickoff prompt, then produce the plan
/askify <prompt>      — coach then answer (read-only)
/promptify <prompt>   — analyze/optimize only (no run)
/runnify <prompt>     — optimize then EXECUTE the work (mutating)
```

The prompt to plan is everything after the command, or the free-text request when
they said "plannify this" / "plan this prompt" / "turn this into a planning prompt".

## Response format

```markdown
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

## Planning-Kickoff Prompt
…
(full structured prompt from step 3 — copy-pasteable as a standalone planning instruction)

## Scores
Execution Readiness: XX
Coverage: XX
Confidence: XX

## Plan
…
(the produced plan — via enter_plan_mode when used, else markdown)

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
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
  `Not started`.
