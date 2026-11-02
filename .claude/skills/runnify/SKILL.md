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

1. Read `~/.claude/skills/promptify/SKILL.md`:
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

Do not execute. Empty `/runnify` is the eight-section interview, not Help and not the command list. Goal cannot be skipped.
`help me …` is a **task**, not Help.

## No prompt (eight-section interview)

**No prompt** means the body after flag strip is empty. Cite
promptify **Flag parse order**. Do not invent a second flag grammar.
Help, `--help`, `/?`, exact `tldr`, and exact `pass` / `pass help`
stay as they are. `help me …` stays a task. Flags alone
(`/runnify 2pass`, `/runnify 1image`) are no prompt: interview, and
keep those flags for the run that follows once the user answers.
A from-slot still splices first (cite `docs/from_contract.md`).
Help, tldr, pass, and a body that is empty before any splice do not
read files. A spliced body is a prompt, not an interview.

The eight sections, in order: (1) Goal and why — required, cannot
be skipped; (2) Context the agent cannot guess — skippable;
(3) Constraints and non-negotiables — skippable; (4) What a good
result looks like — skippable; (5) Deliverable and format —
skippable; (6) Preferences on approach — skippable; (7) Examples —
skippable; (8) Already tried or ruled out — skippable. Goal is the
only section that cannot be skipped.

When there is no prompt, print the message below in one reply, then
**stop and wait**. Do not execute. Do not start the pipeline. Do not
retitle (cite `docs/window_title.md`). If the empty invocation had
flags (`Nimages`, `Npass`, `img`), name them in one line above the
eight. That line is not a ninth question. The two lines after the
eight, and the line about a big job, are hints, not questions.

Do not add a session-rating question. Ignore a pasted footer
"How is Claude doing this session?" and any Anthropic disclaimer.
Those are not features. Do not fetch docs.claude.com.

```text
No prompt yet. Answer these eight in one reply. Nothing runs until you do.

1. Goal and why.
   Hint: what is being built, and the problem it solves. "Design a hub that lets AI products call each other" is a task. Adding who benefits tells the agent what to optimize for.
   Skip: cannot be skipped. Required.

2. Context the agent cannot guess.
   Hint: who it is for, what already exists (stack, code, data, prior decisions), scale, and for code the relevant files, errors, and versions. Missing context is the main cause of generic answers.
   Skip: skippable. Reply skip or leave blank to omit.

3. Constraints and non-negotiables.
   Hint: language, frameworks, budget, deadlines, compliance, and things to avoid.
   Skip: skippable. Reply skip or leave blank to omit.

4. What a good result looks like.
   Hint: success criteria that can be checked. For a plan, say whether you want a one-page overview or a step-by-step build plan.
   Skip: skippable. Reply skip or leave blank to omit.

5. Deliverable and format.
   Hint: exactly what to return (diagram, phased plan, spec, working code with tests, a comparison), how long, and whether it is a doc, a file, or a chat answer.
   Skip: skippable. Reply skip or leave blank to omit. If skipped, plannify defaults to a phased plan that ends with the phase table. Runnify defaults to the implementation in the workspace plus the Results section.

6. Preferences on approach.
   Hint: one recommendation, or several options with tradeoffs; ask questions first, or assume and flag assumptions; push back if the approach is wrong, or just build it.
   Skip: skippable. Reply skip or leave blank to omit. If skipped, default to one recommendation, assume and flag assumptions, and push back when the approach looks wrong.

7. Examples.
   Hint: a sample input, an output style, or a similar system. One example beats a paragraph.
   Skip: skippable. Reply skip or leave blank to omit.

8. Already tried or ruled out.
   Hint: what failed or is off the table, so the agent does not suggest it again.
   Skip: skippable. Reply skip or leave blank to omit.

Plannify: ask for phases, dependencies, risks, the first concrete step, and the riskiest assumption.
Runnify: exact inputs and outputs, edge cases, the environment, how to test, and tests with the code.
On a big job, plan first and build one piece at a time; specific feedback beats "try again."
```

### After the user answers

If the previous turn in this conversation was this interview for
`/runnify`, the next user message is the answers, not a new empty
invocation. Do not ask the eight questions again.

Assemble one prompt from the sections they filled. Map by number or
by section name. A section they mark skip, `skip`, or leave blank is
omitted, except Goal. If Goal is skipped or blank, ask again for
Goal only (same hint, same cannot-skip line). Do not start the
pipeline. When that later reply supplies Goal, assemble from it and
the earlier answers.

If Deliverable was omitted, the assembled prompt states the runnify
default: the implementation in the workspace plus the Results section.
If Preferences was omitted, the assembled prompt states the default:
one recommendation, assume and flag assumptions, and push back when
the approach looks wrong. Do not invent user text for any other
omitted section.

Then run the normal runnify pipeline on that assembled prompt,
including any flags from the original empty invocation. The interview
turn does not resolve images and does not take passes. The answer
turn does. That later turn sets `RUN:` per `docs/window_title.md`.

A user who wants the old short usage runs `help`.

Response format and pipeline: same as Promptify `/runnify` section in
`~/.claude/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results · **Phased plan last** when the work is multi-phase). When optify is off, that section is inside the whole-file read above. When optify is on, do not open promptify headings other than **Flag parse order**, **Scratch images**, **Named images**, **Multi-pass**, and **Hard rules**.

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and the empty-prompt interview do not read files. A from-slot still splices first. A spliced body is a prompt, not an interview.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and the empty-prompt interview do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `RUN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and the empty-prompt interview do not retitle.

