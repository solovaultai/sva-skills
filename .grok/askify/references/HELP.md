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

---

## How to invoke

```text
/askify <prompt>       — coach, then answer (read-only)
/askify help           — this reference (also --help / /?)
/askify tldr           — short form; stop
/askify pass           — Pass (Npass) subsection only (also pass help)
/promptify-ask <prompt>— alias of /askify
```

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me understand X` is a task.

---

## Flags (`Nimages` / `Npass`)

Promptify Flag parse order: first numbered instance left to right;
skip unnumbered `image` / `pass`. Strip before Help vs task.

**`Nimages`:** N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`. Lead with the caught-and-
interpreted ack. Carry what they show into the Ask-Kickoff Prompt and
the answer.

**`Npass`:** see **Pass (`Npass`)** below.

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
end with `## Phased plan`. Flags is the first row when either marker
is present. Skip only for a true single-step question and no markers.

---

## Response shape

Scratch ack → Npass ack → Intent Analysis → Workspace Assessment →
Pre-plan (Npass > 1 only) → Ask-Kickoff Prompt → Scores → Answer →
Phased plan (when required).

---

## Hard rules (short)

- Never invent workspace resources.
- Must not modify the system or emit a plan.
- Kickoff prompt says “answer, do not implement or plan.”
- Cite verified paths; keep depth proportional.
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
