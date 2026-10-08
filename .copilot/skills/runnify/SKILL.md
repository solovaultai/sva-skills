---
name: runnify
description: >-
  Runnify — Promptify execution mode: optimize the prompt, then execute
  it and return Results. Use when the user runs /runnify, /runify, /promptify-run,
  or "runnify". /runnify help (also --help, /?) prints the reference;
  tldr and pass help are short pages. Recognizes Nimages and Npass.
argument-hint: "[<prompt>]"
user-invocable: true
disable-model-invocation: true
---

# Runnify (= Promptify execution mode)

You are running **Promptify in Execution mode** (`/runnify`).

1. Read and follow **all** instructions in:
   `~/.copilot/skills/promptify/SKILL.md`
2. Force mode = **Execution** (`/runnify`), even if the user only said "runnify".
3. Do **not** stop after Optimized Prompt + Scores — **execute** the optimized
   prompt, then append **Results**.
4. Treat `/runify` and `/promptify-run` as aliases of this skill.
5. If the work is (or continues) a **multi-phase plan**, the **last printed
   item** after Results is the Trailing phase status table (completed vs
   left-to-do) defined in promptify. Nothing after that table except an
   optional one-line next-step.
6. If the request contains **`Nimages`**, **`N images`**, or **`N-images`**
   (e.g. `1images`, `1 images`, `1-images`), follow promptify **Scratch
   images** and **Flag parse order**: use only the first numbered instance
   left to right (skip unnumbered "image" so a later `1image` counts; the first typed token exactly `image` counts as `1image`).
   Follow promptify **Scratch images**: if `scratch.env` exists, run
   `scripts/cli.sh scratch ls N` (or `cli.ps1`) and **read those paths**;
   else workspace `scratch/`. Do not treat the marker as part of the task
   wording.
   **First printed content** must be the acknowledgment so the user sees the
   marker was **caught and correctly interpreted**. Name the source
   (`local …` or `remote conn:dir` or workspace `scratch/`):

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` name
specific files. Every token counts. Strip them with the other
flags. The solution uses each resolved image. Read it before
executing. Ack first, after the scratch ack when both are present.

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` / `img` first (promptify Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**.
- Remaining body exactly `tldr` (case-insensitive):
  **read and print** `references/TLDR.md` (this skill folder) and
  **stop**. Extra tokens after `tldr` stay a **task**. There is
  no `tldr help` alias.
- Remaining body exactly `pass` or `pass help` (case-insensitive):
  print the **Pass (`Npass`)** section of that file and **stop**.
  There is no `/pass` skill.

Do not execute. Empty `/runnify` is the short usage, not Help.
`help me …` is a **task**, not Help.

If the user message has no task body after `/runnify`, explain:

```text
/runnify <prompt>     — analyze, validate, enrich, rewrite, then execute
/runnify help         — full reference (also --help, /?)
/runnify tldr         — short form (stop)
/runnify pass help    — Pass (Npass) subsection (also `pass`)
/promptify <prompt>   — analyze only (no execute)
```

Response format and pipeline: same as Promptify `/runnify` section in
`~/.copilot/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results · **Phased plan last** when the work is multi-phase).

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite `docs/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `RUN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.

