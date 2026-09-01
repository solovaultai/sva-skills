---
name: runnify
description: >
  Runnify — Promptify execution mode. Analyze user intent, validate against the
  real workspace, enrich and rewrite the prompt, score readiness, then execute
  only the optimized prompt and return Results. Use when the user runs /runnify,
  /promptify-run, "runnify", or wants prompt QA plus immediate execution.
  Recognizes Nimages / N images / N-images as a pointer to the newest N
  images in the workspace scratch/ folder.
metadata:
  short-description: "Promptify + execute optimized prompt"
---

# Runnify (= Promptify execution mode)

You are running **Promptify in Execution mode** (`/runnify`).

1. Read and follow **all** instructions in:
   `~/.grok/skills/promptify/SKILL.md`
2. Force mode = **Execution** (`/runnify`), even if the user only said "runnify".
3. Do **not** stop after Optimized Prompt + Scores — **execute** the optimized
   prompt, then append **Results**.
4. Treat `/promptify-run` as an alias of this skill.
5. If the work is (or continues) a **multi-phase plan**, the **last printed
   item** after Results is the Trailing phase status table (completed vs
   left-to-do) defined in promptify. Nothing after that table except an
   optional one-line next-step.
6. If the request contains **`Nimages`**, **`N images`**, or **`N-images`**
   (e.g. `1images`, `1 images`, `1-images`), follow promptify **Scratch
   images**: the N newest images in workspace `scratch/` are extra visual
   detail for the issue under review — find them, **read** them, and use
   what they show. Do not treat the marker as part of the task wording.
   **First printed content** must be the acknowledgment so the user sees the
   marker was **caught and correctly interpreted**:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on the issue under review.
```

If the user message has no task body after `/runnify`, explain:

```text
/runnify <prompt>     — analyze, validate, enrich, rewrite, then execute
/promptify <prompt>   — analyze only (no execute)
```

Response format and pipeline: same as Promptify `/runnify` section in
`~/.grok/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results · **Phased plan last** when the work is multi-phase).
