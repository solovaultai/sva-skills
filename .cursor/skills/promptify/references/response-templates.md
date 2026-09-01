# Promptify response templates

Quick copy of output shapes. Source of truth for behavior is `SKILL.md`.

## Analysis mode (`/promptify`)

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<token>` as an attachment marker. Looking at the N most recent image(s) in `scratch/` for extra detail on the issue under review.

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

## Phased plan   ← last section when the work is 2+ phases

| Phase | Description | Status |
|-------|-------------|--------|
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
| P0 — Spec | Freeze decisions | Done |
| P1 — API | Endpoints + tests | Left |
```

Statuses: `Done` · `In progress` · `Left` · `Blocked` · `Deferred` (`Not started` on a fresh plan). Use **Left** for remaining work after a partial run.

Legacy alias: `/promptify-run` behaves the same as `/runnify`.

## Score revision rule

If any score < 80: revise optimized prompt once, re-score, return improved version.
