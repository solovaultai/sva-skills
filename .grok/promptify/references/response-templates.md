# Promptify response templates

Quick copy of output shapes. Source of truth for behavior is `SKILL.md`.

## Analysis mode (`/promptify`)

```markdown
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
```

## Execution mode (`/runnify`)

Same as analysis, plus:

```markdown
## Results
<summary of actions taken while executing the optimized prompt>
```

Legacy alias: `/promptify-run` behaves the same as `/runnify`.

## Score revision rule

If any score &lt; 80: revise optimized prompt once, re-score, return improved version.
