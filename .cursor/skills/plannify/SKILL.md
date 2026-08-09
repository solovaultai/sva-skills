---
name: plannify
description: >-
  Plannify — Promptify planning mode / planning-prompt coach. Reworks any request
  into the ideal Cursor prompt for kicking off a PLANNING agent run, then runs that
  optimized prompt read-only to produce a structured plan. Use when the user runs
  /plannify, /promptify-plan (alias), "plannify", "plan this prompt", "turn this
  into a planning prompt", or wants a prompt reworked for a planning/design run and
  the plan produced.
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
out-of-scope. Proportional to complexity.

Definition of Done (for the plan):
<what makes the plan complete, reviewable, and ready to execute>
```

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

## No task body

If there is no task after the command, explain:

```text
/plannify <prompt>    — coach into a planning-kickoff prompt, then produce the plan
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
(the produced plan — via CreatePlan when available, else markdown)
```

## Hard rules

- Never invent workspace resources; verify with read/search before citing them.
- The planning pass MUST NOT modify the system (no edits/commits/builds/deploys).
- The Planning-Kickoff Prompt must be copy-pasteable as a standalone planning
  instruction and must clearly say "plan, do not implement."
- Keep the plan proportional to complexity; prefer verified repo-relative paths.
- If Execution Readiness is Low or critical assets are Missing, say so and either
  resolve it via questions or make the plan's first phase close those gaps.
