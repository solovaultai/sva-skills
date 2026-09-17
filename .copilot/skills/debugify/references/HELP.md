# Debugify — user reference

Print this file as the response when the user runs `/debugify help`,
`/debugify --help`, or `/debugify /?`. Do not instrument, fix, or
start the loop. `/debugify tldr` prints the short page
(`references/TLDR.md`), not this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/debugify` is the short usage cheat, not this page.
`help me debug …` (or any longer body) is a **task**, not Help.

---

## What it does

**Copilot Debug Mode — full loop** (default). Runtime evidence loop, not
a speculative-fix loop: hypothesize → instrument → repro → analyze →
fix → verify → clean. Alias: `/debug`.

This tree has no `/debug-kickoff`. For a brief only, say so; the
agent stops after Investigate + Hypothesize (no instrument/fix).

---

## How to invoke

```text
/debugify <bug report>      — full loop (default)
/debugify help              — this reference (also --help / /?)
/debugify tldr              — short form; stop
/debugify pass              — Pass (Npass) subsection only (also pass help)
/debug <bug report>         — alias of /debugify
```

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me debug the login` is a task.

---

## Flags (`Nimages` / `Npass`)

Promptify Flag parse order: first numbered instance left to right;
skip unnumbered `image` / `pass`. Strip before Help vs task. Cite
promptify — do not fork.

**`Nimages`:** N newest images from the scratch source (`scratch ls N`) or workspace `scratch/` as existing evidence during
Phase 0. Lead with the caught-and-interpreted ack.

**`Npass`:** see **Pass (`Npass`)** below.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this subsection** and stops.
Cite promptify **Flag parse order** — do not fork. Full reference:
`/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right. Default **1**. Extra pass(es) deepen investigation /
hypothesis quality (pre-plan when N > 1); last pass runs this
invocation’s loop work. Acknowledge after the scratch ack when both
appear.

```text
/debugify pass
/debugify pass help
/debugify 2pass <bug>
/promptify pass help
```

---

## Loop (mandatory order)

| Phase | Name | What happens |
|-------|------|----------------|
| 0 | Investigate | Symptom, expected vs actual, repro, suspects |
| 1 | Hypotheses | 2–5 falsifiable claims before instrumenting |
| 2 | Instrument | Temporary probes only — **no product fix** |
| 3 | Reproduce | Agent-repro first; else pause for the user |
| 4 | Analyze | Confirm / reject / inconclusive + root cause |
| 5 | Fix | Only after evidence; minimal diff |
| 6 | Verify + clean | Repro gone; **remove all probes** |

**Hard gate:** do not change production logic until step 6 has
runtime (or equivalent hard) evidence. Code reading alone is not
enough. Stack traces, reproducing failing tests, and deterministic
agent repro count.

**Exception:** if the session already has hard evidence, you may skip
new instrumentation (Investigate → Hypothesize → Analyze existing →
Fix → Verify). State that skip; mark Phase 2 `Deferred`.

---

## Instrument rules

- Tag probes (`copilot-debug`) so cleanup is trivial.
- Log only what tests a hypothesis. Never log secrets / PII / huge
  payloads.
- Do not refactor or apply the suspected product fix while probing.

---

## Reproduce

Agent-repro first (test / CLI / curl). User-repro when UI / private
env / hardware is required: stop mutating, give a numbered protocol,
wait. Do not invent log lines.

---

## Trailing phase table (mandatory)

Always end with `## Phased plan` (Phase | Description | Status).
Default rows: Investigate → Hypotheses → Instrument → Reproduce →
Analyze → Fix → Verify + clean. Mark accurately; remaining work is
`Left`. Flags first row if `Nimages` / `Npass` is present.

When paused for user repro, say **Waiting for reproduction** (optional
one-line after the table). Do not proceed to fix.

---

## Hard rules (short)

- Evidence before product fixes — no speculative fixes.
- Instrument before fixing unless evidence is already sufficient.
- Always clean up temporary probes after verify.
- Never invent workspace resources. Redact secrets/PII.
- Prefer minimal diffs; no unrelated refactors.
- Brief-only request: stop after Investigate + Hypothesize (no
  `/debug-kickoff` in this tree).
- Trailing phase table is mandatory and last.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  do not start the loop. Exact `tldr`: print `references/TLDR.md`
  (not this file). Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only.

---

## Related

`/addify <text>` — append `<text>` to the last ify and restart/continue
that skill.
