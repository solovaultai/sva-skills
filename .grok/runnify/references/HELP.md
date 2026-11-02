# Runnify — user reference

Print this file as the response when the user runs `/runnify help`,
`/runnify --help`, or `/runnify /?`. Do not execute.
`/runnify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/runnify` is the eight-section interview, not this page
and not the command list. No prompt after flag strip, including
flags alone, asks the eight sections in one message and waits.
Goal and why cannot be skipped. The other seven are skippable:
Context the agent cannot guess; Constraints and non-negotiables;
What a good result looks like; Deliverable and format; Preferences
on approach; Examples; Already tried or ruled out. `help` is still
this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Promptify in **Execution** mode. Analyze, validate, enrich, score, then
**execute only the optimized prompt** and append **Results**. Aliases:
`/runify`, `/promptify-run`.

`/promptify` stops after the optimized prompt. `/runnify` does not.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`). A from-slot still splices first. A spliced body is a prompt, not an interview. The empty-prompt interview does not read files.

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see `the docify skill's references/docify_contract.md`). Help, tldr, pass, and the empty-prompt interview do not write.

Window title prefix is `RUN:` (see `docs/window_title.md`).
Help, tldr, pass, and the empty-prompt interview do not retitle.

---

## How to invoke

```text
/runnify <prompt>      — optimize, then EXECUTE
/runnify               — no prompt: eight-section interview (Goal required; stop and wait)
/runnify help          — this reference (also --help / /?)
/runnify tldr          — short form; stop
/runnify pass          — Pass (Npass) subsection only (also pass help)
/runify <prompt>       — alias of /runnify
/promptify-run <prompt>— alias of /runnify
/promptify <prompt>    — analyze only (no execute)
```

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me write a login form` is a
task.
A body that is empty after flag strip, including flags alone, is the eight-section interview. Goal cannot be skipped.

---

## Flags (`Nimages` / `Npass`)

Follow promptify **Flag parse order**. Image family: every numbered directive counts (union, each path once, newest mtime first). Positive N is the N newest. Negative `-K` is one file, `|K|` steps back from the newest. Do not pass a negative to `scratch ls`; list positive `M` = max(positive counts, `|negative|+1`), then slice. The ack names every image token. Pass family: first numbered instance left to right only.
Skip unnumbered `image` / `pass` (first typed token `image` counts as `1image`). Strip before deciding Help vs
task. Not part of the task wording.

**`Nimages`:** the image-directive union from the scratch source (positive `scratch ls M`, then slice)
or workspace `scratch/`. Read them; use what they show. **First printed
content** when present (name the source):

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<tokens>` as attachment markers (every image token, not only the first). Looking at the selected
image(s) from <source> for extra detail on the issue under review.
```

**`Npass`:** see **Pass (`Npass`)** below.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
Strip them with the other flags. The solution uses each resolved
image. Read it before executing. Ack first, after the scratch ack
when both are present. An `img` token is included on the Flags row.
With no `Nimages` and no `Npass`, that row is still printed.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this subsection** and stops.
Cite promptify **Flag parse order** and **Pass (`Npass`)** — do not
fork. Full reference: `/promptify pass help`.

No prompt after flag strip starts the eight-section interview, not
this section. Goal cannot be skipped. Help, exact tldr, and this
pass page stay as they are.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**. N pipeline passes of this execution
run. If N > 1, pass 1 is a documented pre-plan; the last pass
emits the optimized prompt, then execute + Results. Acknowledge
after the scratch ack when both appear.

```text
/runnify pass
/runnify pass help
/runnify 2pass <prompt>
/promptify pass help
```

---

## Pipeline then execute

1. Follow **all** of `promptify/SKILL.md` (intent, workspace, scores).
2. Force mode = Execution even if the user only said "runnify".
3. Do **not** stop after Optimized Prompt + Scores — execute the
   optimized prompt (not the raw request), then append **Results**.
4. If Execution Readiness is Low or critical assets are Missing, say
   so; execute only what is safe; list blockers.
5. Prefer paths verified in Workspace Assessment. Do not expand past
   the optimized prompt.

---

## Trailing phase table

If the work is (or continues) a **multi-phase plan**, or `Nimages` /
`Npass` is present, the **last printed item** after Results is the
promptify Trailing phase status table (completed vs left). Flags is
the first row when `Nimages`, `Npass`, or `img` is present. An `img`
token alone still gets the row. Cite promptify **Named images**.
Nothing after the table except an optional one-line next-step.

---

## Hard rules (short)

- Execute only the optimized prompt, after scoring (revise once if any
  score < 80).
- Never invent workspace resources.
- Multi-phase / flag runs end with the phase table.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not execute. Exact `tldr`: print `references/TLDR.md` (not this
  file). Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only. Empty `/runnify` is the eight-section interview, not Help and not the command list. Goal cannot be skipped.

---

## Related

`/addify <text>` — append `<text>` to the last ify and restart/continue
that skill.
