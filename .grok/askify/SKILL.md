---
name: askify
description: >
  Askify — Promptify ask mode / ask-mode prompt coach. Reworks any request into the
  ideal Grok prompt for kicking off a read-only ASK (question-answering) run, then
  runs that optimized prompt read-only to produce a cited answer (no plan, no edits).
  Use when the user runs /askify, /promptify-ask (alias), "askify", "ask this prompt",
  "turn this into an ask prompt", or wants a prompt reworked for a question-answering
  run and the answer produced. Recognizes Nimages / N images / N-images as
  the union of every numbered image directive: positive N is the N newest from the configured scratch source (or workspace scratch/); negative -K is one file |K| back; newest mtime first. Recognizes
  Npass / N-pass / N pass as a request to take N passes (pass 1 is a
  documented pre-plan when N > 1) before answering. `/askify dummy`
  is a non-technical tell (no commands, paths, or APIs), the same kind
  as phasify dummy. Print a complete
  reference with `/askify help` or `/askify --help` (also `/?`).
  `/askify tldr` prints the short page.
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

1. Read `~/.grok/skills/promptify/SKILL.md`:
   - **Optify on** (default): only these headings — **Flag parse order**, **Scratch images**, **Named images**, **Multi-pass**, **Hard rules**. Do not read the rest of that file.
   - **Optify off** (`enabled=off`): read the whole file, then follow:
     - Step 1 Intent analysis
     - Step 2 Workspace validation
     - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
       score &lt; 80)
     - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
   Cite the optify skill's `references/optify_contract.md`. Optify is on unless `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env` contains `enabled=off`. A missing file or a missing `enabled` key is on. Only `enabled=off` is off. Reading that env file is enough to decide. `./scripts/cli.sh optify show` is the supported way to change the switch.
2. Force mode = **Ask** (`/askify`), even if the user only said "askify".
3. Treat `/promptify-ask` as an alias of this skill.

Override Promptify's **step 3** (optimized prompt) and **step 6** (mode branch) with
the two sections below.

## Scratch images (`Nimages`)

When the user text includes **`Nimages`**, **`N images`**, or **`N-images`**
(case-insensitive; also `Nimage` / `N image` / `N-image`; examples: `1images`,
`1 images`, `1-images`), that token is an **attachment marker**, not part of
the task wording.

Follow promptify **Scratch images**. Every numbered image directive counts. Positive N is the N newest files, newest mtime first. Negative `-K` is exactly one file, `|K|` steps back from the newest (`-1` is the second newest). Union the paths, each once, newest mtime first. Do not pass a negative to `scratch ls`. List once with positive `M` = the largest of the positive counts and of `|negative| + 1`, then slice (`1image -3image` calls `scratch ls 4` and keeps index 0 and index 3). An offset past the end adds no file. Do not invent a path. `0image`, `0images`, `image0`, `images0`, and `-0image` are an error before any read: `Error: image count starts at 1`. `image -3` stays blank n (N = 1); the `-3` is not part of that directive. `Npass` stays the first numbered instance only. The ack names every image token. If `scratch.env` exists, run
`scripts/cli.sh scratch ls M` (or `scripts\cli.ps1 scratch ls M`) and
**read the sliced paths**. Else workspace `scratch/` (do not create). Carry what they show
into the Ask-Kickoff Prompt and the answer.

**Tell the user (mandatory, first printed content):** Print this so it is
obvious the markers were **caught and correctly interpreted**. Name every image token, not only the first. Name the
source (`local …` or `remote conn:dir` or workspace `scratch/`).

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected
image(s) from <source> for extra detail on the issue under review.
```

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` name
specific files. Every token counts. Strip them with the other
flags. The answer uses each resolved image as evidence.

## Multi-pass (`Npass`)

When the user text includes **`Npass`**, **`N-pass`**, or **`N pass`**
(case-insensitive; examples: `2pass`, `2-pass`, `2 pass`), follow
promptify **Multi-pass**. Take **N passes** before answering.

If **N > 1**: pass 1 is a **documented pre-plan** only (`## Pre-plan
(pass 1)` — inventories, existing capabilities, external tools, approach,
gaps, light planning). Do **not** emit the final answer on pass 1.
Passes 2–N use that base; the **last pass** produces the Ask-Kickoff
Prompt and the **Answer**. Acknowledge the marker (after scratch ack if
both are present).

```markdown
**Npass — caught and correctly interpreted.**
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan;
passes 2–N use that base for the final answer.
```

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
   Keep depth proportional to the question. **Dummy** replaces this item
   with the non-technical tell (see **Dummy**).
5. If the question is about (or continues) a **multi-phase plan**, end with the
   promptify Trailing phase status table (completed vs left). Skip only for a
   true single-step question.

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

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

Do not answer. Empty `/askify` is the short usage, not Help.
`help me …` is a **task**, not Help.

## Plan output (`plan`)

After flag strip and Help / `tldr` / `pass` checks, if the **first**
remaining token is `plan` (case-insensitive), that is **Plan** output.
`plan` is not `pass`, not `plannify`, and not Help. Strip `plan`; the
remainder is the task. Empty `plan`: short usage + “plan needs a
prompt.” Stop.

The pipeline still runs in full either way (coach, then answer).
**Default** (`/askify <prompt>`): do **not** print the plan — no
Intent Analysis, Workspace Assessment, Pre-plan, Ask-Kickoff Prompt,
or Scores. Print acks (if any), then `## Answer` (then the trailing
phase table when that section requires it).

**`/askify plan <prompt>`:** print the full Response format (the plan
plus the answer).

## Dummy (`dummy`)

Cite the phasify skill's `references/dummy.md` for the tell. Do not
fork a second plain-language dialect.

After flag strip and Help / `tldr` / `pass` checks, the whole token
`dummy` (case-insensitive) is this directive when it is the first
remaining token, or the token next to a leading `plan` (`dummy plan`
or `plan dummy`). Strip those mode tokens. The remainder is the
task. A later `dummy` inside the question stays question text.
`dummy` is not Help, not `pass`, and not phasify. `dummy N`,
`Ndummy`, `dummyN`, and `dummy pN` are **not** selectors here.
Empty after the strip: short usage + “dummy needs a prompt.” Stop.
That empty line does not retitle.

Read-only, same pipeline. Override step 6’s `## Answer` and the
trailing phase table: print the dummy tell instead. With `plan`,
print the plan sections first and set the kickoff Deliverable to
this tell.

**No commands, paths, or APIs.** If a fact is only expressible as
a command, path, or API, say what the person is trying to
accomplish and stop there. Do not implement. Do not invent facts.

A question about a phase of an existing plan uses that file’s
Dummy report for the phase the question names (Intent, then plain
language; What landed and To get past this only when that file
includes them). Do not execute. Do not change Status. Do not
rewrite or reprint the plan.

Any other question uses:

```text
## Dummy — <short title>

### Intent
Why this matters, in everyday language.

### In plain language
A simple description of the answer. No commands, paths, or APIs.

### Do not
- Do not implement or edit from this command
- Do not print commands, paths, or APIs
- Do not invent facts
```

Acks first when a flag is present. `Nimages`: only what the images
show, in non-technical language. `Npass` > 1: later passes improve
this tell; the last pass emits it.

```text
/askify dummy what is this for
/askify plan dummy what is this for
/askify dummy plan what is this for
```

## No task body

If there is no task after the command, explain:

```text
/askify <prompt>       — answer only (read-only; do not print the plan)
/askify plan <prompt>  — print the ask-kickoff plan, then answer
/askify dummy <prompt> — non-technical tell (no commands, paths, or APIs)
/askify help           — full reference (also --help, /?)
/askify tldr          — short form (stop)
/askify pass help     — Pass (Npass) subsection (also `pass`)
/plannify <prompt>    — coach then produce a plan
/runnify <prompt>     — optimize then EXECUTE the work (mutating)
/promptify <prompt>   — analyze/optimize only (no run)
```

The prompt to answer is everything after the command, or the free-text request when
they said "askify this" / "ask this prompt" / "turn this into an ask prompt".

## Response format

**Default** — answer only (no plan unless the user said `/askify plan`):

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected image(s) from <source> for extra detail on the issue under review.

**Npass — caught and correctly interpreted.**   ← when an Npass marker is present
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan; passes 2–N use that base for the final answer.

## Answer
…
(the produced answer — read-only, cited)

## Phased plan   ← last section when 2+ phases, or when Nimages/Npass is present
```

**`/askify plan`** — print the plan, then the answer:

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected image(s) from <source> for extra detail on the issue under review.

**Npass — caught and correctly interpreted.**   ← when an Npass marker is present
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan; passes 2–N use that base for the final answer.

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

## Pre-plan (pass 1)   ← only when Npass > 1
…

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

## Phased plan   ← last section when 2+ phases, or when Nimages/Npass is present

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| … | … | Left / Done |
```

**`/askify dummy`** — acks, then the Dummy report. Not `## Answer`.
No phased-plan table. `plan dummy` / `dummy plan` prints the plan
sections first; the kickoff Deliverable is that tell.

## Trailing phase status (when the question is multi-phase)

**Dummy** does not emit this table. The tell is the whole reply.

Askify does **not** invent a plan. When the user asks about, continues, or the
workspace already has a **multi-phase plan** (named P0/P1/…, a design phase
index, or 2+ sequential todos), the **last printed section** MUST be the
promptify **Trailing phase status** table: what is **done** and what is **left**.
Skip only for a true single-step question **and** no `Nimages` / `Npass`
marker. If either marker is present, emit the table with a **Flags** first
row (caught-and-understood tokens + **On pass k of N**).

**Placement:** Absolute end of the full response (after `## Answer`). Nothing
after the table except an optional one-line next-step.

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `ASK:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.
Empty `/askify dummy` is empty usage and does not retitle.

## Hard rules

- Never invent workspace resources; verify with read/search before citing them.
- The ask pass MUST NOT modify the system or emit a plan (no edits/commits/builds/
  deploys/plan artifacts).
- The Ask-Kickoff Prompt must be copy-pasteable as a standalone ask instruction and
  must clearly say "answer, do not implement or plan."
- Cite verified repo-relative paths; keep the answer proportional to the question.
  Dummy does not print paths (see **Dummy**).
- If Execution Readiness is Low or critical assets are Missing, say so and either
  resolve it via questions or answer only the parts the workspace supports, listing
  what could not be determined.
- Multi-phase questions: last printed content is the Trailing phase status table
  (done vs left). Do not emit a new implementation plan. Dummy skips that table.
- `Nimages` / `N images` / `N-images`, including a leading minus: every numbered image directive counts. Positive N is the N newest. Negative `-K` is one file, `|K|` steps back from the newest. Union, each path once, newest mtime first. List positive `M` then slice; do not pass a negative to `scratch ls`.
  and treat them as extra detail for the issue under review (see **Scratch
  images**). Lead the response with the **caught and correctly interpreted**
  acknowledgment so the user can see the marker was recognized.
- `Npass` / `N-pass` / `N pass`: take N passes (see **Multi-pass**). When
  N > 1, pass 1 documents a pre-plan only; later passes use that base;
  the last pass emits the answer. Acknowledge the marker.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `tldr` after flag strip:
  print `references/TLDR.md` and stop. Exact `pass` / `pass help`:
  print the **Pass (`Npass`)** section and stop. Empty `/askify` is
  short usage, not Help. `help me …` is a task.
- Do **not** print the plan (Intent, Workspace, Pre-plan, Ask-Kickoff
  Prompt, Scores) unless the user specified `/askify plan`. Default
  `/askify <prompt>` is answer-only. `plan` is not `pass` or
  `plannify`.
- `dummy` (first token, or beside a leading `plan`) is the non-technical
  tell. Cite the phasify skill's `references/dummy.md`. No commands,
  paths, or APIs. No `## Answer`. No trailing phase table. Empty
  `dummy` needs a prompt and does not retitle. Phase selectors stay
  on `/phasify`.
