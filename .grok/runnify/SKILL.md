---
name: runnify
description: >
  Runnify — Promptify execution mode. Analyze user intent, validate against the
  real workspace, enrich and rewrite the prompt, score readiness, then execute
  only the optimized prompt and return Results. Use when the user runs /runnify,
  /runify, /promptify-run, "runnify", or wants prompt QA plus immediate execution.
  Print a complete reference with `/runnify help` or `/runnify --help`
  (also `/?`). `/runnify tldr` prints the short page. `/runnify pass
  help` prints the Pass (`Npass`) subsection.
  Recognizes Nimages / N images / N-images as the union of every numbered image directive: positive N is the N newest from the configured scratch source (or workspace scratch/); negative -K is one file |K| back; newest mtime first.
  Recognizes Npass / N-pass / N pass as N pipeline passes (promptify Flag
  parse order).
metadata:
  short-description: "Promptify + execute optimized prompt"
---

# Runnify (= Promptify execution mode)

You are running **Promptify in Execution mode** (`/runnify`).

1. Read `~/.grok/skills/promptify/SKILL.md`:
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

Do not execute. No instructional prompt is the eight-section interview, not Help and not the command list. Directives may be present. An instructional prompt is what blocks the interview. The walk asks one section at a time. An empty answer is valid for every section, including the goal. The word `add` is ordinary task text, not a directive.
`help me …` is a **task**, not Help.

## No prompt (one section at a time)

**No prompt** means there is no instructional prompt. It does not
mean the invocation has zero tokens. Directives may be present.
An instructional prompt is what blocks the interview.

Cite promptify **Flag parse order**. Do not invent a second flag
grammar. Image, pass, and `img` tokens are flags, not the
instructional prompt. `docify` / `docpathify` are directives, not
the instructional prompt. The word `add` is ordinary task text on
runnify, not a directive. Only plannify treats a first token `add`
as the add directive. `/plannify add` with no feature is an
interview on plannify. `/runnify add` and `/runnify build the login
page` are instructional prompts.

These start the walk. Keep every directive and apply it on the
later turn that runs the assembled answers:

- `/runnify` with no other tokens
- flags only: `/runnify 3pass`, `/runnify 1image`,
  `/runnify img=foo.png`, `/plannify 1image 3pass`
- only `docify` / `docpathify`, plus flags
- plannify only: `add` with no feature, including
  `/plannify add 1image` and `/plannify 3pass add`

These are not an interview:

- `/runnify build the login page` — instructional prompt.
- `/plannify add OAuth login` — on plannify, `add` is the
  directive and `OAuth login` is the instructional prompt.
- `/plannify 1image help`, `/runnify tldr`, `/plannify pass`,
  `/runnify pass help` — help, `--help`, `/?`, exact `tldr`, and
  exact `pass` / `pass help` still win after flag strip.
- `/plannify fromhere` and `/plannify 2pass fromhere` —
  `fromhere` stays the fromhere replan. It is a complete mode,
  not an empty prompt.
- `docify` / `docpathify` attached to real task text. Do not
  interview.
- `help me …` stays a task.

A `from=` / `from:` slot still splices first (cite
`docs/from_contract.md`). A spliced body is a prompt. Help, tldr,
pass, and an interview (no instructional prompt before the splice)
do not read files.

Ask exactly one section, then stop and wait. Do not ask the next
section in the same turn. Do not start the pipeline. Do not retitle
(cite `docs/window_title.md`). The walk does not read files and does
not write a docify file. Do not resolve images and do not take passes
on a walk turn.

Each question is a short chat question, not a multiple-choice form.
Print the number, the name, the hint, and one line that leaving it
empty is valid: `Leaving this empty is valid.`

On the first question only, if directives were present, name them in
one line above the question (flags, plannify `add` with no feature,
`docify` / `docpathify`). That line is not a question. Also on the
first question only, add these hint lines. They are not questions:

- Plannify: ask for phases, dependencies, risks, the first concrete step, and the riskiest assumption.
- Runnify: exact inputs and outputs, edge cases, the environment, how to test, and tests with the code.
- On a big job, plan first and build one piece at a time; specific feedback beats "try again."

An empty answer is valid for every section, including the goal. Do
not re-ask when an answer is empty. An empty reply, whitespace,
`skip`, or `none` records that section as empty and advances. Do
not reject it.

Order:

1. Goal and why. Hint: what is being built, and the problem it solves. "Design a hub that lets AI products call each other" is a task. Adding who benefits tells the agent what to optimize for.
2. Context the agent cannot guess. Hint: who it is for, what already exists (stack, code, data, prior decisions), scale, and for code the relevant files, errors, and versions. Missing context is the main cause of generic answers.
3. Constraints and non-negotiables. Hint: language, frameworks, budget, deadlines, compliance, and things to avoid.
4. What a good result looks like. Hint: success criteria that can be checked. For a plan, say whether you want a one-page overview or a step-by-step build plan.
5. Deliverable and format. Hint: exactly what to return (diagram, phased plan, spec, working code with tests, a comparison), how long, and whether it is a doc, a file, or a chat answer.
6. Preferences on approach. Hint: one recommendation, or several options with tradeoffs; ask questions first, or assume and flag assumptions; push back if the approach is wrong, or just build it.
7. Examples. Hint: a sample input, an output style, or a similar system. One example beats a paragraph.
8. Already tried or ruled out. Hint: what failed or is off the table, so the agent does not suggest it again.

First question when directives were present:

```text
Keeping directives for the later run: 1image, add.

1. Goal and why.
Hint: what is being built, and the problem it solves. "Design a hub that lets AI products call each other" is a task. Adding who benefits tells the agent what to optimize for.
Leaving this empty is valid.

Plannify: ask for phases, dependencies, risks, the first concrete step, and the riskiest assumption.
Runnify: exact inputs and outputs, edge cases, the environment, how to test, and tests with the code.
On a big job, plan first and build one piece at a time; specific feedback beats "try again."
```

Later questions omit the directive line and those three hint lines.

Do not add a session-rating question. Ignore a pasted footer
"How is Claude doing this session?" and any Anthropic disclaimer.
Those are not features. Do not fetch docs.claude.com.

### After each answer

If the previous turn asked one of these sections for this same verb,
the next user message is the answer to that section, not a new
invocation and not a new task. Record it. If a section remains, ask
the next one and stop. Do not repeat earlier questions.

After section 8 has an answer:

- Assemble one prompt from sections that have content. Map by number
  or by section name. Empty, whitespace, `skip`, and `none` omit
  that section. Do not invent user text for an omitted section.
- If Deliverable was empty, the assembled prompt states the verb
  default. Plannify: a phased plan that ends with the phase table.
  Runnify: the implementation in the workspace plus the Results
  section.
- If Preferences was empty, the assembled prompt states the default:
  one recommendation, assume and flag assumptions, and push back
  when the approach looks wrong.
- If every section is empty, stop. Do not start the pipeline. Say
  no sections were filled.
- Otherwise run the normal runnify pipeline on the assembled
  prompt. Keep every directive from the original invocation and
  apply it on this turn. Flags (`Nimages`, `Npass`, `img`) apply as
  on a normal run. If `docify` / `docpathify` was present, this turn
  also writes the deliverable per the docify contract. The word
  `add` is not a runnify directive. The walk turns do not resolve
  images and do not take passes. The turn after section 8 does.
  That turn sets `RUN:` per `docs/window_title.md`.

A user who wants the old short usage runs `help`.

Response format and pipeline: same as Promptify `/runnify` section in
`~/.grok/skills/promptify/SKILL.md` (Intent · Workspace · Optimized Prompt ·
Scores · Results · **Phased plan last** when the work is multi-phase). When optify is off, that section is inside the whole-file read above. When optify is on, do not open promptify headings other than **Flag parse order**, **Scratch images**, **Named images**, **Multi-pass**, and **Hard rules**.

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and an interview (no instructional prompt before the splice) do not read files. A from-slot still splices first. A spliced body is a prompt, not an interview.

## Docify

Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and the interview turn do not write. `docify` / `docpathify` are directives, not the instructional prompt. A line that is only those plus flags is an interview; the answer turn writes the deliverable. Attached to real task text, do not interview. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `RUN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and the empty-prompt interview do not retitle.

