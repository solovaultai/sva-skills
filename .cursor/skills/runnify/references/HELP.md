# Runnify — user reference

Print this file as the response when the user runs `/runnify help`,
`/runnify --help`, or `/runnify /?`. Do not execute.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/runnify` is the short usage cheat, not this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Promptify in **Execution** mode. Analyze, validate, enrich, score, then
**execute only the optimized prompt** and append **Results**. Alias:
`/promptify-run`.

`/promptify` stops after the optimized prompt. `/runnify` does not.

---

## How to invoke

```text
/runnify <prompt>      — optimize, then EXECUTE
/runnify help          — this reference (also --help / /?)
/runnify pass          — Pass (Npass) subsection only (also pass help)
/promptify-run <prompt>— alias of /runnify
/promptify <prompt>    — analyze only (no execute)
```

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `pass`, or `pass help`. `help me write a login form` is a
task.

---

## Flags (`Nimages` / `Npass`)

Follow promptify **Flag parse order**: first numbered instance left to
right; skip unnumbered `image` / `pass`. Strip before deciding Help vs
task. Not part of the task wording.

**`Nimages`:** N newest images from the scratch source (`scratch ls N`)
or workspace `scratch/`. Read them; use what they show. **First printed
content** when present (name the source):

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

**`Npass`:** see **Pass (`Npass`)** below.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this subsection** and stops.
Cite promptify **Flag parse order** and **Pass (`Npass`)** — do not
fork. Full reference: `/promptify pass help`.

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
the first row when either marker is present. Nothing after the table
except an optional one-line next-step.

---

## Hard rules (short)

- Execute only the optimized prompt, after scoring (revise once if any
  score < 80).
- Never invent workspace resources.
- Multi-phase / flag runs end with the phase table.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not execute. Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only. Empty `/runnify` is short usage, not Help.

---

## Related

`/addify <text>` — append `<text>` to the last ify and restart/continue
that skill.
