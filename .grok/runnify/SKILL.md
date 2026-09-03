---
name: runnify
description: >
  Runnify — Promptify execution mode. Analyze user intent, validate against the
  real workspace, enrich and rewrite the prompt, score readiness, then execute
  only the optimized prompt and return Results. Use when the user runs /runnify,
  /promptify-run, "runnify", or wants prompt QA plus immediate execution.
  Print a complete reference with `/runnify help` or `/runnify --help`
  (also `/?`). Recognizes Nimages / N images / N-images as a pointer to the newest N
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
   images** and **Flag parse order**: use only the first numbered instance
   left to right (skip unnumbered "image" so a later `1image` counts).
   The N newest images in workspace `scratch/` are extra visual detail —
   find them, **read** them, and use what they show. Do not treat the
   marker as part of the task wording.
   **First printed content** must be the acknowledgment so the user sees the
   marker was **caught and correctly interpreted**:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on the issue under review.
```

## Help (`help` / `--help` / `/?`)

Strip `Nimages` / `Npass` first (promptify Flag parse order). If the
**remaining body is exactly** `help`, `--help`, or `/?` (case-insensitive),
print **User help** below and **stop**. Do not execute. Empty `/runnify`
is the short usage, not Help. `help me …` is a **task**, not Help.

If the user message has no task body after `/runnify`, explain:

```text
/runnify <prompt>     — analyze, validate, enrich, rewrite, then execute
/runnify help         — full reference (also --help, /?)
/promptify <prompt>   — analyze only (no execute)
```

Response format and pipeline: same as Promptify `/runnify` section in
`~/.grok/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results · **Phased plan last** when the work is multi-phase).

## User help

Print this section as the response on `help` / `--help` / `/?`.

### What it does

Promptify in **Execution** mode. Analyze, validate, enrich, score, then
**execute only the optimized prompt** and append **Results**. Alias:
`/promptify-run`.

`/promptify` stops after the optimized prompt. `/runnify` does not.

### How to invoke

```text
/runnify <prompt>      — optimize, then EXECUTE
/runnify help          — this reference (also --help / /?)
/promptify-run <prompt>— alias of /runnify
/promptify <prompt>    — analyze only (no execute)
```

Exact remaining body after flag strip must be `help`, `--help`, or `/?`.
`help me write a login form` is a task.

### Flags (`Nimages` / `Npass`)

Follow promptify **Flag parse order**: first numbered instance left to
right; skip unnumbered `image` / `pass`. Strip before deciding Help vs
task. Not part of the task wording.

**`Nimages`:** N newest images in workspace `scratch/`. Read them; use
what they show. **First printed content** when present:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on the issue under review.
```

**`Npass`:** inherited from promptify — N pipeline passes; pass 1 is a
documented pre-plan when N > 1. Acknowledge after the scratch ack when
both appear.

### Pipeline then execute

1. Follow **all** of `promptify/SKILL.md` (intent, workspace, scores).
2. Force mode = Execution even if the user only said "runnify".
3. Do **not** stop after Optimized Prompt + Scores — execute the
   optimized prompt (not the raw request), then append **Results**.
4. If Execution Readiness is Low or critical assets are Missing, say
   so; execute only what is safe; list blockers.
5. Prefer paths verified in Workspace Assessment. Do not expand past
   the optimized prompt.

### Trailing phase table

If the work is (or continues) a **multi-phase plan**, or `Nimages` /
`Npass` is present, the **last printed item** after Results is the
promptify Trailing phase status table (completed vs left). Flags is
the first row when either marker is present. Nothing after the table
except an optional one-line next-step.

### Hard rules (short)

- Execute only the optimized prompt, after scoring (revise once if any
  score < 80).
- Never invent workspace resources.
- Multi-phase / flag runs end with the phase table.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not execute. Empty `/runnify` is short usage, not Help.

