# Debugify — user reference

Print this file as the response when the user runs `/debugify help`,
`/debugify --help`, or `/debugify /?`. Do not analyze or emit a
kickoff. `/debugify tldr` prints the short page
(`references/TLDR.md`), not this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/debugify` is the short usage cheat, not this page.
`help me debug …` (or any longer body) is a **task**, not Help.

---

## What it does

Promptify in **Debug** mode — a **kickoff coach** for Cursor Debug Mode.
Analyze the bug + related code (read-only) and emit a copy-pasteable
Debug-Kickoff Prompt. This skill does **not** instrument, fix, or
mutate code. Aliases: `/dbgify`, `/debify`, `/promptify-debug`.

Paste the kickoff into Cursor **Debug** mode to run the loop
(hypotheses → instrument → repro → analyze → targeted fix → verify →
clean).

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see `the docify skill's references/docify_contract.md`). Help, tldr, and pass do not write.

Window title prefix is `DBG:` (see `docs/window_title.md`).
Help, tldr, and pass do not retitle.

---

## How to invoke

```text
/debugify <bug report>  — code analysis + Debug Mode kickoff prompt
/debugify help          — this reference (also --help / /?)
/debugify tldr          — short form; stop
/debugify pass          — Pass (Npass) subsection only (also pass help)
/dbgify <bug>            — alias of /debugify
/promptify-debug <bug>  — alias of /debugify
/debify <bug>            — alias of /debugify
```

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me debug the login` is a task.

---

## Flags (`Nimages` / `Npass`)

Promptify Flag parse order: first numbered instance left to right;
skip unnumbered `image` / `pass` (first typed token `image` counts as `1image`). Strip before Help vs task. Cite
promptify — do not fork.

**`Nimages`:** N newest images from the scratch source (`scratch ls N`) or workspace `scratch/` as existing evidence. Lead
with the caught-and-interpreted ack. Carry what they show into the
kickoff.

**`Npass`:** see **Pass (`Npass`)** below.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
Strip them with the other flags. Read each image before hypotheses.
It is evidence for what the problem is. Carry the paths into the
Debug-Kickoff Prompt under Existing Evidence.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this subsection** and stops.
Cite promptify **Flag parse order** — do not fork. Full reference:
`/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**. Extra pass(es) deepen the kickoff /
code analysis (pre-plan when N > 1); last pass emits the
Debug-Kickoff Prompt. Acknowledge after the scratch ack when both
appear.

```text
/debugify pass
/debugify pass help
/debugify 2pass <bug>
/promptify pass help
```

---

## Bug intent fields

Always extract (or mark **unknown**): Symptom · Expected vs Actual ·
Reproduction · Frequency · Environment · Recent changes · Existing
evidence · Blast radius.

---

## Code analysis (read-only)

Locate entry points, trace call/data flow, note logging/tests near
suspects, identify state boundaries. Produce Suspect Code Paths,
Evidence Already Present, Repro Feasibility, and 2–5 falsifiable
Preliminary Hypotheses. Never invent files or APIs.

---

## Debug-Kickoff Prompt (required sections)

Copy-pasteable. Must say: hypotheses + instrument first; **no
speculative fix**.

- Objective — Debug Mode loop, not a guess-fix
- Bug Report — symptom / expected / actual / frequency / env / changes
- Reproduction Protocol — steps, success signal, how to confirm the fix
- Workspace Context · Suspect Code Paths · Existing Evidence
- Hypotheses to Test (prioritized, falsifiable: confirm / reject)
- Instrumentation Intent — what / where / what not to log; temporary
- Constraints — minimal diff; no fix until evidence
- Deliverable — hypotheses + probes → root cause → targeted fix →
  remove probes
- Definition of Done — bug gone; probes cleaned; tests when appropriate

Unknowns: write `unknown — ask user`. Do not guess.

---

## Response shape

Scratch ack (if any) → Intent Analysis → Workspace Assessment
(including suspects / evidence / repro / hypotheses) → Code Analysis
Brief → Debug-Kickoff Prompt → Scores → Next step (switch to Debug
mode, paste, follow instructions) → **Phased plan** (last).

---

## Trailing phase table (mandatory)

Always end with `## Phased plan`. Default: Phase 0 Kickoff is `Done`
when this skill finished; remaining Debug Mode steps are `Left`.
Flags first row if `Nimages` / `Npass` is present. Do not mark later
phases `Done` unless the workspace already shows that work landed.

---

## Hard rules (short)

- Never invent workspace resources.
- Must **not** instrument, edit, commit, build, deploy, or apply fixes.
- Kickoff is copy-pasteable and forbids speculative fixes.
- Hypotheses must be falsifiable and linked to observations.
- Trailing phase table is mandatory and last.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not emit a kickoff. Exact `tldr`: print `references/TLDR.md`
  (not this file). Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only.

---

## Related

`/addify <text>` — append `<text>` to the last ify and restart/continue
that skill.
