---
name: runnify
description: >-
  Runnify — Promptify execution mode. Analyze user intent, validate against the
  real Cursor workspace, enrich and rewrite the prompt, score readiness, then
  execute only the optimized prompt and return Results. Use when the user runs
  /runnify, /promptify-run, "runnify", or wants prompt QA plus immediate
  execution.
---

# Runnify (= Promptify execution mode)

You are running **Promptify in Execution mode** (`/runnify`).

1. Read and follow **all** instructions in:
   `~/.cursor/skills/promptify/SKILL.md`
2. Force mode = **Execution** (`/runnify`), even if the user only said "runnify".
3. Do **not** stop after Optimized Prompt + Scores — **execute** the optimized
   prompt, then append **Results**.
4. Treat `/promptify-run` as an alias of this skill.

If the user message has no task body after `/runnify`, explain:

```text
/runnify <prompt>     — analyze, validate, enrich, rewrite, then execute
/promptify <prompt>   — analyze only (no execute)
```

Response format and pipeline: same as Promptify `/runnify` section in
`~/.cursor/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results).
