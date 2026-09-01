# Promptify response templates

Quick copy of output shapes. Source of truth for behavior is `SKILL.md`.

## Analysis mode (`/promptify`)

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<token>` as an attachment marker. Looking at the N most recent image(s) in `scratch/` for extra detail on the issue under review.

**Npass — caught and correctly interpreted.**   ← when an Npass marker is present
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan; passes 2–N use that base for the final deliverable.

## Intent Analysis
<summary of actual objective>

## Workspace Assessment

### Validated Assets
- …

### Recommended Assets
- …

### Missing Assets
- …

### Coverage Assessment
Low | Medium | High

### Execution Readiness
Low | Medium | High

## Pre-plan (pass 1)   ← only when Npass > 1
- Inventories / capabilities / external tools / approach / gaps

## Optimized Prompt

Objective:
…

Workspace Context:
…

Validated Resources:
…

Instructions:
…

Output Format:
…

Success Criteria:
…

Assumptions:
…

## Scores
Execution Readiness: 0-100
Coverage: 0-100
Confidence: 0-100

## Phased plan   ← last section when 2+ phases, or when Nimages/Npass is present

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| P0 — … | … | Left / Done |
```

## Execution mode (`/runnify`)

Same as analysis, plus:

```markdown
## Results
<summary of actions taken while executing the optimized prompt>
```

If the work is (or continues) a **multi-phase plan**, append this as the
**last printed item** (after Results):

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| P0 — Spec | Freeze decisions | Done |
| P1 — API | Endpoints + tests | Left |
```

Statuses: `Done` · `In progress` · `Left` · `Blocked` · `Deferred` (`Not started` on a fresh plan). Use **Left** for remaining work after a partial run.

Legacy alias: `/promptify-run` behaves the same as `/runnify`.

## Score revision rule

If any score < 80: revise optimized prompt once, re-score, return improved version.
