# Askify — user reference

Print this file as the response when the user runs `/askify help`,
`/askify --help`, or `/askify /?`. Do not answer.
`/askify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/askify` is the short usage cheat, not this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Promptify in **Ask** mode. Coach the request into an ask-kickoff
prompt, then run it **read-only** and return a cited answer. Never
implements and never emits a plan. Alias: `/promptify-ask`.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see `the docify skill's references/docify_contract.md`). Help, tldr, and pass do not write.

Window title prefix is `ASK:` (see `docs/window_title.md`).
Help, tldr, and pass do not retitle.

---

## How to invoke

```text
/askify <prompt>       — answer only (read-only; do not print the plan)
/askify plan <prompt>  — print the ask-kickoff plan, then answer
/askify dummy <prompt> — non-technical tell (no commands, paths, or APIs)
/askify help           — this reference (also --help / /?)
/askify tldr           — short form; stop
/askify pass           — Pass (Npass) subsection only (also pass help)
/promptify-ask <prompt>— alias of /askify
```

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me understand X` is a task.

---

## Flags (`Nimages` / `Npass`)

Promptify Flag parse order. Image family: every numbered directive counts (union, each path once, newest mtime first). Positive N is the N newest. Negative `-K` is one file, `|K|` steps back from the newest. Do not pass a negative to `scratch ls`; list positive `M` = max(positive counts, `|negative|+1`), then slice. The ack names every image token. Pass family: first numbered instance left to right only.
Skip unnumbered `image` / `pass` (first typed token `image` counts as `1image`). Strip before Help vs task.

**`Nimages`:** the image-directive union from the scratch source (positive `scratch ls M`, then slice) or workspace `scratch/`. Lead with the caught-and-
interpreted ack. Carry what they show into the Ask-Kickoff Prompt and
the answer.

**`Npass`:** see **Pass (`Npass`)** below.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
Strip them with the other flags. The answer uses each resolved
image as evidence. An `img` token is included on the Flags row.
With no `Nimages` and no `Npass`, that row is still printed.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this subsection** and stops.
Cite promptify **Flag parse order** — do not fork. Full reference:
`/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**. N passes before answering. If N > 1,
pass 1 is `## Pre-plan (pass 1)` only — do **not** emit the final
answer on pass 1. Last pass produces the Ask-Kickoff Prompt and
the **Answer**. Acknowledge after the scratch ack when both appear.

```text
/askify pass
/askify pass help
/askify 2pass <prompt>
/promptify pass help
```

---

## Ask-Kickoff Prompt (required sections)

Copy-pasteable. Must say **answer, do not implement or plan**.

- Objective — answer/explain X using the workspace
- Workspace Context — verified paths
- Research Scope — what to read/search
- Questions to Answer
- Constraints
- Deliverable — cited answer; multi-phase questions end with the
  trailing phase table
- Definition of Done

---

## Ask pass (read-only)

1. Run only the optimized Ask-Kickoff Prompt.
2. **READ-ONLY** — no edits, commits, builds, deploys, or plan artifacts.
3. Resolve ambiguities from the workspace; ask 1–2 questions only if
   a blocking clarification remains.
4. Produce `## Answer` with cited file paths.
5. If the question is about (or continues) a multi-phase plan, end
   with the promptify Trailing phase status table.

---

## Trailing phase table

Askify does **not** invent a plan. When the question is about an
existing multi-phase plan, **or** `Nimages` / `Npass` is present,
end with `## Phased plan`. Flags is the first row when `Nimages`,
`Npass`, or `img` is present. An `img` token alone still gets the
row. Cite promptify **Named images**. Skip only for a true
single-step question and no markers.

---

## Response shape

**Default** (`/askify <prompt>`): Scratch ack → Npass ack → Answer →
Phased plan (when required). Do **not** print Intent, Workspace,
Pre-plan, Ask-Kickoff Prompt, or Scores.

**`/askify plan <prompt>`:** Scratch ack → Npass ack → Intent
Analysis → Workspace Assessment → Pre-plan (Npass > 1 only) →
Ask-Kickoff Prompt → Scores → Answer → Phased plan (when required).

`plan` is not `pass` and not `plannify`. Empty `/askify plan` is
usage + “plan needs a prompt.”

**`/askify dummy <prompt>`:** Scratch ack → Npass ack → Dummy report.
Not `## Answer`. No phased-plan table. `plan dummy` / `dummy plan`
prints the plan sections first, then the tell.

---

## Dummy (`dummy`)

Cite the phasify skill's `references/dummy.md`. Do not fork a second
plain-language dialect.

The whole token `dummy` (case-insensitive) is this directive when it
is the first remaining token after flag strip and Help / `tldr` /
`pass` checks, or the token next to a leading `plan` (`dummy plan`
or `plan dummy`). Strip those mode tokens. The remainder is the
task. A later `dummy` inside the question stays question text.
`dummy N`, `Ndummy`, `dummyN`, and `dummy pN` are **not** selectors
here. Those stay on `/phasify`. Empty after the strip: short usage
+ “dummy needs a prompt.” Stop. That empty line does not retitle.

The reply is a **non-technical tell**. **No commands, paths, or
APIs.** If a fact is only expressible as a command, path, or API,
say what the person is trying to accomplish and stop there. Do not
implement. Do not invent facts. Do not print `## Answer`. Do not
print the trailing phase table. The tell is the whole reply (acks
first when a flag is present; the ask-kickoff plan only when `plan`
was also set).

A question about a phase of an existing plan uses that file’s Dummy
report for the phase the question names. Do not execute. Do not
change Status. Do not rewrite or reprint the plan.

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

```text
/askify dummy what is this for
/askify plan dummy what is this for
/askify dummy plan what is this for
```

---

## Hard rules (short)

- Never invent workspace resources.
- Must not modify the system or emit a plan.
- Kickoff prompt says “answer, do not implement or plan.”
- Cite verified paths; keep depth proportional. Dummy does not print
  paths.
- `dummy` is the non-technical tell (see **Dummy**). No commands,
  paths, or APIs. No trailing phase table. Empty `dummy` needs a
  prompt and does not retitle.
- Low readiness / missing assets: say so; answer only what the
  workspace supports.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not answer. Exact `tldr`: print `references/TLDR.md` (not this
  file). Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only.

---

## Related

`/addify <text>` — append `<text>` to the last ify and restart/continue
that skill.
