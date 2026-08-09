---
name: askify
description: >-
  Askify — Promptify ask mode / ask-mode prompt coach. Reworks any request into the
  ideal Cursor prompt for kicking off a read-only ASK (question-answering) run, then
  runs that optimized prompt read-only to produce a cited answer (no plan, no edits).
  Use when the user runs /askify, /promptify-ask (alias), "askify", "ask this prompt",
  "turn this into an ask prompt", or wants a prompt reworked for a question-answering
  run and the answer produced.
---

# Askify (= Promptify ask mode)

You are running **Promptify in Ask mode** (`/askify`) — an ask-mode prompt coach.
Like `/runnify` and `/plannify`, but the "run" produces an **answer** (explanation,
findings, comparison), never code changes and never a plan.

## What it does

1. Coach the raw request into the perfect Cursor **ask-kickoff prompt**.
2. Then run that optimized prompt in a **read-only** pass and return a cited answer.

## Base pipeline

1. Read and follow `~/.cursor/skills/promptify/SKILL.md` for:
   - Step 1 Intent analysis
   - Step 2 Workspace validation
   - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
     score < 80)
   - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
2. Force mode = **Ask** (`/askify`), even if the user only said "askify".
3. Treat `/promptify-ask` as an alias of this skill.

Override Promptify's **step 3** (optimized prompt) and **step 6** (mode branch) with
the two sections below.

## Override step 3 — Ask-Kickoff Prompt

Instead of Promptify's execution-oriented Optimized Prompt, produce the ideal prompt
to **start an Ask-mode run**. It must instruct the agent to ANSWER, not implement or
plan. Required sections:

```text
Objective:
Answer/explain <X> using the workspace. Answer only — do NOT implement, edit, or plan.

Workspace Context:
<verified files / systems / paths relevant to the question>

Research Scope:
<what to read/search to answer accurately, and where to look>

Questions to Answer:
<the specific sub-questions the answer must cover>

Constraints:
<hard limits: depth, scope, what not to assume>

Deliverable:
A clear, cited answer (explanation, comparison, or findings) proportional to the question.

Definition of Done (for the answer):
<complete, accurate, cites verified paths, no unresolved guesses>
```

## Override step 6 — Ask execution (read-only)

After optimize + scoring:

1. Run **only** the optimized Ask-Kickoff Prompt (not the raw request).
2. **READ-ONLY**: research with read/search/list/read-only shell + MCP inspection.
   Make **NO** edits, writes, commits, installs, builds, deploys, or plan artifacts.
3. Resolve ambiguities from the workspace where possible. If a genuinely blocking
   clarification remains (multiple readings that materially change the answer), ask
   1-2 targeted questions with the AskQuestion tool before answering.
4. Produce the answer under `## Answer`, citing verified file paths / line references.
   Keep depth proportional to the question.

## No task body

If there is no task after the command, explain:

```text
/askify <prompt>      — coach into an ask-kickoff prompt, then answer (read-only)
/plannify <prompt>    — coach then produce a plan
/runnify <prompt>     — optimize then EXECUTE the work (mutating)
/promptify <prompt>   — analyze/optimize only (no run)
```

The prompt to answer is everything after the command, or the free-text request when
they said "askify this" / "ask this prompt" / "turn this into an ask prompt".

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

## Ask-Kickoff Prompt
…
(full structured prompt from step 3 — copy-pasteable as a standalone ask instruction)

## Scores
Execution Readiness: XX
Coverage: XX
Confidence: XX

## Answer
…
(the produced answer — read-only, cited)
```

## Hard rules

- Never invent workspace resources; verify with read/search before citing them.
- The ask pass MUST NOT modify the system or emit a plan (no edits/commits/builds/
  deploys/plan artifacts).
- The Ask-Kickoff Prompt must be copy-pasteable as a standalone ask instruction and
  must clearly say "answer, do not implement or plan."
- Cite verified repo-relative paths; keep the answer proportional to the question.
- If Execution Readiness is Low or critical assets are Missing, say so and either
  resolve it via questions or answer only the parts the workspace supports, listing
  what could not be determined.
