---
name: runnify
description: >-
  Runnify — Promptify execution mode. Analyze user intent, validate against the
  real Cursor workspace, enrich and rewrite the prompt, score readiness, then
  execute only the optimized prompt and return Results. Use when the user runs
  /runnify, /runify, /promptify-run, "runnify", or wants prompt QA plus immediate
  execution.   Print a complete reference with `/runnify help` or
  `/runnify --help` (also `/?`). `/runnify tldr` prints the short
  page. `/runnify pass help` prints the Pass
  (`Npass`) subsection. Recognizes Nimages / N images / N-images as the union of every numbered image directive: positive N is the N newest from the configured scratch source (or workspace scratch/); negative -K is one file |K| back; newest mtime first.
  Recognizes Npass / N-pass / N pass as N pipeline passes (promptify Flag
  parse order).
---

# Runnify (= Promptify execution mode)

You are running **Promptify in Execution mode** (`/runnify`).

1. Read `~/.cursor/skills/promptify/SKILL.md`:
   - **Optify on** (default): only these headings — **Flag parse order**, **Scratch images**, **Named images**, **Multi-pass**, **Hard rules**. Do not read the rest of that file.
   - **Optify off** (`enabled=off`): read and follow **all** instructions in that file.
   Cite the optify skill's `references/optify_contract.md`. Optify is on unless `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env` contains `enabled=off`. A missing file or a missing `enabled` key is on. Only `enabled=off` is off. Reading that env file is enough to decide. `./scripts/cli.sh optify show` is the supported way to change the switch.
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
   images**. Every numbered image directive counts. Positive N is the N newest files, newest mtime first. Negative `-K` is exactly one file, `|K|` steps back from the newest (`-1` is the second newest). Union the paths, each once, newest mtime first. Do not pass a negative to `scratch ls`. List once with positive `M` = the largest of the positive counts and of `|negative| + 1`, then slice (`1image -3image` calls `scratch ls 4` and keeps index 0 and index 3). An offset past the end adds no file. Do not invent a path. `0image`, `0images`, `image0`, `images0`, and `-0image` are an error before any read: `Error: image count starts at 1`. `image -3` stays blank n (N = 1); the `-3` is not part of that directive. `Npass` stays the first numbered instance only. The ack names every image token. If `scratch.env` exists, run
   `scripts/cli.sh scratch ls M` (or `cli.ps1`) and **read the sliced paths**;
   else workspace `scratch/`. Do not treat the marker as part of the task
   wording.
   **First printed content** must be the acknowledgment so the user sees the
   markers were **caught and correctly interpreted**. Name every image token, not only the first. Name the source
   (`local …` or `remote conn:dir` or workspace `scratch/`):

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected
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
`~/.cursor/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results · **Phased plan last** when the work is multi-phase). When optify is off, that section is inside the whole-file read above. When optify is on, do not open promptify headings other than **Flag parse order**, **Scratch images**, **Named images**, **Multi-pass**, and **Hard rules**.

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `RUN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.

