---
name: debugify
description: >
  Debugify — Grok Debug Mode (full loop). Default debug skill: form falsifiable
  hypotheses, add temporary instrumentation, reproduce for runtime evidence, apply
  a minimal evidence-backed fix, verify, then remove probes. Use when the user runs
  /debugify, /debug (alias), "debug this", "debug this bug", "root-cause this",
  "why is this failing", "instrument and fix", or wants Cursor-style Debug Mode
  behavior inside Grok. Prefer this over /debug-kickoff unless they only want a
  kickoff brief. Print a complete reference with `/debugify help` or
  `/debugify --help` (also `/?`). `/debugify tldr` prints the short
  page. Recognizes Nimages / N images / N-images as a pointer to the
  newest N images from the configured scratch source (or workspace scratch/).
metadata:
  short-description: "Debug Mode full loop — instrument, repro, fix, clean"
---

# Debugify (= Grok Debug Mode, full loop)

You are running **Grok Debug Mode** (`/debugify`) — a **runtime evidence loop**, not
a speculative-fix loop. Default behavior is the **full loop** (hypothesize →
instrument → repro → analyze → fix → verify → clean). For a read-only kickoff brief
only, the user should run `/debug-kickoff`.

Treat `/debug` as an alias of this skill.

## Loop (mandatory order)

1. **Investigate** (read/search) — symptom, expected vs actual, repro, evidence
2. **Hypothesize** — 2–5 falsifiable claims grounded in verified code
3. **Instrument** — minimal temporary probes only; **no product fix yet**
4. **Reproduce** — agent-run when possible; otherwise pause for the user
5. **Analyze** — map logs/evidence to hypotheses (confirm / reject / inconclusive)
6. **Fix** — only after evidence supports a root cause; minimal diff
7. **Verify** — re-run repro; bug gone; related tests pass when feasible
8. **Clean up** — remove all temporary instrumentation

**Hard gate:** Do **not** change production logic (the real fix) until step 6 has
runtime (or equivalent hard) evidence. Stack traces, failing tests that reproduce
locally, and deterministic agent repro counts as evidence. Pure code reading does not.

**Exception — evidence already sufficient:** If the session already has hard evidence
(reproducing failing test, clear stack + confirmed bad path, deterministic CLI repro
you just ran), you may skip new instrumentation and go Investigate → Hypothesize →
Analyze existing evidence → Fix → Verify. State that skip explicitly.

## Phase 0 — Bug intent + code analysis

Extract (or mark **unknown**):

| Field | Question |
|-------|----------|
| Symptom | What fails, misbehaves, or confuses? |
| Expected vs Actual | Correct behavior vs observed |
| Reproduction | Exact steps, inputs, commands, URLs, fixtures |
| Frequency | Always / intermittent / env-specific |
| Environment | App, branch, OS, runtime, config, flags |
| Recent changes | Commits, deps, config that may correlate |
| Existing evidence | Stacks, logs, screenshots, failing tests; scratch images when an `Nimages` marker is present |
| Blast radius | Users, paths, data at risk if mis-fixed |

Then analyze code (verify paths before citing):

1. Locate entry points, handlers, routes, jobs, or UI flows named in the report.
2. Trace call/data flow across real files.
3. Note existing logging, metrics, tests, fixtures, error handling near suspects.
4. Note state boundaries (DB, cache, queue, network, auth, config).
5. Build **Suspect Code Paths** — path + symbol + one-line why.
6. Draft **preliminary hypotheses** only when grounded in code or evidence.

Prefer repo-relative paths. Never invent files or APIs.

## Scratch images (`Nimages`)

When the user text includes **`Nimages`**, **`N images`**, or **`N-images`**
(case-insensitive; also `Nimage` / `N image` / `N-image`; examples: `1images`,
`1 images`, `1-images`), that token is an **attachment marker**, not part of
the task wording.

Follow promptify **Scratch images**: if `scratch.env` exists, run
`scripts/cli.sh scratch ls N` (or `scripts\cli.ps1 scratch ls N`) and
**read those paths**. Else workspace `scratch/` (do not create). Parse
image/pass flags per promptify **Flag parse order**. Treat what they show
as existing evidence when forming hypotheses. Do this during Phase 0,
before instrumenting.

**Tell the user (mandatory, first printed content):** Print this so it is
obvious the token was **caught and correctly interpreted**. Name the
source (`local …` or `remote conn:dir` or workspace `scratch/`).

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

## Phase 1 — Hypotheses

Publish 2–5 hypotheses before instrumenting. Each must be falsifiable:

```text
H1: <claim>
  Confirm if: <log/observation>
  Reject if: <log/observation>
  Probe: <file + region>
```

Prioritize by likelihood × cheapness to test. Do not collapse to a single untested
"obvious" cause.

## Phase 2 — Instrument (no fix)

Add **temporary** probes only:

- Tag every probe so cleanup is trivial, e.g. `// grok-debug` / `# grok-debug` /
  `/* grok-debug */` or a single shared helper clearly named for debug.
- Log only what tests a hypothesis: branch taken, key values, error codes, timings.
- **Never** log secrets, tokens, passwords, PII, or huge payloads (truncate/redact).
- Prefer existing log frameworks; keep noise low.
- Do **not** refactor, rename, or "improve" unrelated code while instrumenting.
- Do **not** apply the suspected product fix in this phase.

Then state:

- Where probes were added (paths + symbols)
- How to run the app/tests so probes fire
- Where output goes (stderr, log file, browser console, test output)

## Phase 3 — Reproduce

**Agent-repro first** when feasible:

- Failing unit/integration test, CLI, curl script, or deterministic command
- Run it; capture full relevant output

**User-repro** when the bug needs interactive UI, private env, or hardware:

1. Stop mutating further.
2. Give a short **Reproduction Protocol** (numbered steps, success signal that the
   bug occurred, where to paste logs).
3. Wait for the user. Do not invent log lines.

If repro is blocked (missing env/secret), say so and ask 1–2 targeted questions
with `ask_user_question` — do not fake evidence.

## Phase 4 — Analyze evidence

For each hypothesis: **confirmed** / **rejected** / **inconclusive** with cited
evidence (log lines, test output, stack frames, file:line).

Write a short **Root cause** only when evidence supports it. If inconclusive,
add/adjust probes or refine repro — still no speculative product fix.

## Phase 5 — Targeted fix

Only after a supported root cause:

- Minimal diff on the failing path
- No drive-by refactors
- Preserve behavior outside the bug
- Prefer adding/adjusting a regression test when the harness makes that natural

## Phase 6 — Verify + clean up

1. Re-run the reproduction protocol (agent or user). Bug must not recur.
2. Run relevant tests/linters when the repo makes that practical.
3. **Remove all temporary instrumentation** (every `grok-debug` probe).
4. Confirm the working tree no longer carries debug-only noise.

If verification fails: return to analyze/instrument — do not pile speculative fixes.

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

Do not instrument, fix, or start the loop. Empty `/debugify` is the
short usage, not Help. `help me debug …` is a **task**, not Help.

## No task body

If there is no bug report after the command, explain:

```text
/debugify <bug report>     — full Debug Mode loop (default): instrument → repro → fix → clean
/debugify help             — full reference (also --help, /?)
/debugify tldr             — short form (stop)
/debugify pass help        — Pass (Npass) subsection (also `pass`)
/debug <bug report>        — alias of /debugify
/debug-kickoff <bug report>— read-only: hypotheses + kickoff brief only (no edits)
/askify <prompt>           — coach then answer (read-only)
/plannify <prompt>         — coach then produce a plan
/runnify <prompt>          — optimize then EXECUTE general work (mutating)
/promptify <prompt>        — analyze/optimize only (no run)
```

The bug report is everything after the command, or the free-text request when they
said "debug this", "debug this bug", "root-cause this", or similar.

## Response shape (adapt as phases complete)

Lead with progress; do not dump empty sections for phases not reached yet.

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<token>` as an attachment marker. Looking at the N most recent image(s) from <source> for extra detail on the issue under review.

## Bug Brief
Symptom / Expected / Actual / Repro / Environment / Existing evidence

## Suspect Code Paths
- path — symbol — why

## Hypotheses
H1…Hn (confirm / reject criteria)

## Instrumentation
What was added, where, how to trigger, where logs go

## Reproduction
Agent output **or** protocol waiting on user

## Evidence & Verdict
Per-hypothesis status + root cause (or why still blocked)

## Fix
Summary of minimal change (after evidence only)

## Verification
Repro result, tests, instrumentation removed (yes/no)

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| Phase 0 — Investigate | … | Done |
| … | … | Left |
```

When paused for user repro, say **Waiting for reproduction** and the exact
steps — do not proceed to fix. Still end with the Trailing phase table; the
waiting line may follow the table as the optional one-line next-step.

## Trailing phase status (mandatory)

Debugify is always multi-phase. The **last printed section** MUST be the
promptify **Trailing phase status** table (`## Phased plan` — Phase |
Description | Status). Users scroll to the bottom for completed vs left.

Default rows (mark accurately; remaining work is **Left**):

```markdown
## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| Phase 0 — Investigate | Symptom, repro, suspects | Done |
| Phase 1 — Hypotheses | 2–5 falsifiable claims | Done |
| Phase 2 — Instrument | Temporary probes | In progress |
| Phase 3 — Reproduce | Agent or user repro | Left |
| Phase 4 — Analyze | Verdict + root cause | Left |
| Phase 5 — Fix | Minimal evidence-backed change | Left |
| Phase 6 — Verify + clean | Repro gone; probes removed | Left |
```

Statuses: `Done` · `In progress` · `Left` · `Blocked` · `Unblocked` · `Deferred` · `Def-Blocked`. Do not
mark `Done` unless that phase landed. When evidence-already-sufficient skips
instrumentation, mark Phase 2 `Deferred` and say so above.

## Hard rules

- Runtime (or equivalent hard) evidence before product fixes — no speculative fixes.
- Instrument before fixing unless evidence is already sufficient (state the skip).
- Temporary probes only; always clean up after verify.
- Never invent workspace resources; verify with read/search before citing.
- Prefer minimal diffs; no unrelated refactors.
- Redact secrets/PII in logs and in chat.
- Intermittent bugs: demand frequency, env, and recent changes; design probes for
  the failing condition, not one lucky happy-path run.
- If `/debug-kickoff` was requested, do not run this full loop — use that skill.
- Optional after a successful fix: offer or run `/check-work` if the user wants
  independent verification; not required to finish Debugify.
- **Trailing phase table is mandatory:** end every run with `## Phased plan`
  (Phase | Description | Status) as the last printed content so completed vs
  left-to-do is visible without scrolling up.
- `Nimages` / `N images` / `N-images`: read the N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`
  and treat them as extra detail for the issue under review (see **Scratch
  images**). Lead the response with the **caught and correctly interpreted**
  acknowledgment so the user can see the marker was recognized.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `tldr` after flag strip:
  print `references/TLDR.md` and stop. Exact `pass` / `pass help`:
  print the **Pass (`Npass`)** section and stop. Empty `/debugify`
  is short usage, not Help. `help me debug …` is a task.
