---
name: askify
description: >
  Askify — Promptify ask mode / ask-mode prompt coach. Reworks any request into the
  ideal Grok prompt for kicking off a read-only ASK (question-answering) run, then
  runs that optimized prompt read-only to produce a cited answer (no plan, no edits).
  Use when the user runs /askify, /promptify-ask (alias), "askify", "ask this prompt",
  "turn this into an ask prompt", or wants a prompt reworked for a question-answering
  run and the answer produced.
metadata:
  short-description: "Promptify ask mode — optimize then answer read-only"
---

# Askify (= Promptify ask mode)

You are running **Promptify in Ask mode** (`/askify`) — an ask-mode prompt coach.
Like `/runnify` and `/plannify`, but the "run" produces an **answer** (explanation,
findings, comparison), never code changes and never a plan.

## What it does

1. Coach the raw request into the perfect Grok **ask-kickoff prompt**.
2. Then run that optimized prompt in a **read-only** pass and return a cited answer.

## Base pipeline

1. Read and follow `~/.grok/skills/promptify/SKILL.md` for:
   - Step 1 Intent analysis
   - Step 2 Workspace validation
   - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
     score &lt; 80)
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
If the question is about (or the workspace has) a multi-phase plan, the last
printed item is the Trailing phase status table (completed vs left).

Definition of Done (for the answer):
<complete, accurate, cites verified paths, no unresolved guesses; multi-phase
questions end with the trailing phase table>
```

## Override step 6 — Ask execution (read-only)

After optimize + scoring:

1. Run **only** the optimized Ask-Kickoff Prompt (not the raw request).
2. **READ-ONLY**: research with `read_file` / `grep` / `list_dir` / read-only shell
   (`run_terminal_command`) + MCP inspection (`search_tool` / `use_tool`).
   Make **NO** edits, writes, commits, installs, builds, deploys, or plan artifacts.
   Do not use `search_replace`, `write`, mutating git, or install/deploy commands.
3. Resolve ambiguities from the workspace where possible. If a genuinely blocking
   clarification remains (multiple readings that materially change the answer), ask
   1–2 targeted questions with the `ask_user_question` tool before answering.
4. Produce the answer under `## Answer`, citing verified file paths / line references.
   Keep depth proportional to the question.
5. If the question is about (or continues) a **multi-phase plan**, end with the
   promptify Trailing phase status table (completed vs left). Skip only for a
   true single-step question.

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

## Phased plan   ← only when the question is 2+ phases; last section if present

| Phase | Description | Status |
|-------|-------------|--------|
| … | … | Left / Done |
```

## Trailing phase status (when the question is multi-phase)

Askify does **not** invent a plan. When the user asks about, continues, or the
workspace already has a **multi-phase plan** (named P0/P1/…, a design phase
index, or 2+ sequential todos), the **last printed section** MUST be the
promptify **Trailing phase status** table: what is **done** and what is **left**.
Skip only for a true single-step question.

**Placement:** Absolute end of the full response (after `## Answer`). Nothing
after the table except an optional one-line next-step.

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
- Multi-phase questions: last printed content is the Trailing phase status table
  (done vs left). Do not emit a new implementation plan.
