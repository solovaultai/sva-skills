---
name: debugify
description: >-
  Debugify — Promptify debug mode / debug-kickoff coach. Reworks any bug report
  into the ideal Cursor Debug Mode prompt via code analysis and prompt enrichment
  (hypotheses, suspect paths, repro, instrumentation intent), then returns a
  copy-pasteable Debug-Kickoff Prompt. Use when the user runs /debugify,
  /promptify-debug (alias), "debugify", "debug this prompt", "prepare for debug
  mode", "turn this into a debug prompt", or wants a prompt set up for Cursor
  Debug Mode. Print a complete reference with `/debugify help` or
  `/debugify --help` (also `/?`). `/debugify tldr` prints the short
  page. Recognizes Nimages / N images / N-images as a pointer to the
  newest N images from the configured scratch source (or workspace scratch/).
---

# Debugify (= Promptify debug mode)

You are running **Promptify in Debug mode** (`/debugify`) — a debug-kickoff coach
for **Cursor Debug Mode**. Like `/askify` and `/plannify`, you enrich the request
against the real workspace. Unlike `/runnify`, you do **not** instrument, fix, or
mutate code — you produce the best possible prompt to paste into Cursor Debug Mode.

## What Cursor Debug Mode expects

Debug Mode is a runtime loop, not a speculative-fix loop:

1. Read the codebase and form **multiple hypotheses**
2. **Instrument** with targeted runtime logs
3. User **reproduces** the bug
4. Analyze **runtime evidence**
5. Propose a **targeted fix**
6. User **verifies**; instrumentation is removed

Your job is to make step 0 excellent: a kickoff prompt so rich that Debug Mode
starts with verified paths, crisp repro, and testable hypotheses — not a vague
"it's broken" report.

## What it does

1. Analyze the bug report + related code (read-only).
2. Coach the raw request into the perfect Cursor **debug-kickoff prompt**.
3. Return that prompt (and a short code-analysis brief) ready for Debug Mode.

## Base pipeline

1. Read and follow `~/.cursor/skills/promptify/SKILL.md` for:
   - Step 1 Intent analysis (extend with the bug fields below)
   - Step 2 Workspace validation (extend with the code-analysis pass below)
   - Step 4 Scores (Execution Readiness / Coverage / Confidence; revise once if any
     score < 80)
   - Its Hard rules (workspace is source of truth; never invent files/APIs/tools/DBs).
2. Force mode = **Debug** (`/debugify`), even if the user only said "debugify".
3. Treat `/promptify-debug` as an alias of this skill.

Override Promptify's **step 3** (optimized prompt) and **step 6** (mode branch)
with the sections below. Also apply the Step 1 / Step 2 extensions.

## Scratch images (`Nimages`)

When the user text includes **`Nimages`**, **`N images`**, or **`N-images`**
(case-insensitive; also `Nimage` / `N image` / `N-image`; examples: `1images`,
`1 images`, `1-images`), that token is an **attachment marker**, not part of
the task wording.

Follow promptify **Scratch images**: if `scratch.env` exists, run
`scripts/cli.sh scratch ls N` (or `scripts\cli.ps1 scratch ls N`) and
**read those paths**. Else workspace `scratch/` (do not create). Parse
image/pass flags per promptify **Flag parse order**. Carry what they show
into the Debug-Kickoff Prompt (Existing Evidence / Validated Assets).

**Tell the user (mandatory, first printed content):** Print this so it is
obvious the token was **caught and correctly interpreted**. Name the
source (`local …` or `remote conn:dir` or workspace `scratch/`).

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

## Extend step 1 — Bug intent fields

In addition to Promptify's intent table, always extract (or mark **unknown**):

| Field | Question |
|-------|----------|
| Symptom | What fails, misbehaves, or confuses? |
| Expected vs Actual | Correct behavior vs observed behavior |
| Reproduction | Exact steps, inputs, commands, URLs, fixtures |
| Frequency | Always / intermittent / env-specific |
| Environment | App, branch, OS, runtime, config, feature flags |
| Recent changes | Commits, deps, config that may correlate |
| Existing evidence | Stack traces, logs, screenshots, failing tests; scratch images when an `Nimages` marker is present |
| Blast radius | Users, paths, data at risk if mis-fixed |

## Extend step 2 — Code analysis pass (read-only)

After general workspace validation, **analyze code that could explain the bug**:

1. Locate entry points, handlers, routes, jobs, or UI flows named in the report.
2. Trace call paths and data flow across verified files (read/search/list only).
3. Note existing logging, metrics, tests, fixtures, and error-handling near suspects.
4. Identify state boundaries (DB, cache, queues, network, auth, config) that affect repro.
5. Collect **Suspect surfaces** — real paths + symbols (functions/classes/modules).
6. Draft **candidate hypotheses** only when grounded in code or evidence; mark confidence.

Produce under Workspace Assessment (in addition to Promptify's asset lists):

- **Suspect Code Paths** — verified files/symbols with one-line why
- **Evidence Already Present** — tests, logs, traces, configs found
- **Repro Feasibility** — can the user / agent reproduce here? blockers?
- **Preliminary Hypotheses** — 2–5 falsifiable ideas (not a fix plan)

Never invent files or APIs. Prefer repo-relative paths.

## Override step 3 — Debug-Kickoff Prompt

Instead of Promptify's execution-oriented Optimized Prompt, produce the ideal
prompt to **start Cursor Debug Mode**. It must instruct the agent to follow the
Debug Mode loop (hypotheses → instrument → repro → analyze → targeted fix →
verify → clean up), **not** to jump to an unvalidated fix.

Required sections:

```text
Objective:
Debug <symptom> using Cursor Debug Mode. Form multiple hypotheses, instrument to
test them, wait for reproduction + runtime logs, then apply a minimal evidence-
backed fix. Do NOT speculative-fix before runtime evidence.

Bug Report:
Symptom: <…>
Expected: <…>
Actual: <…>
Frequency: <…>
Environment: <…>
Recent changes (if known): <…>

Reproduction Protocol:
1. <exact steps the user will run after instrumentation>
2. …
Success signal that the bug occurred: <…>
How to confirm the fix later: <…>

Workspace Context:
<verified systems, entry points, configs, related tests>

Suspect Code Paths:
- path/to/file.ext — <symbol/region> — why relevant

Existing Evidence:
- <stack traces, failing tests, logs, metrics already in repo or report>

Hypotheses to Test (prioritized, falsifiable):
H1: <claim> — would be confirmed by <log/observation> — disproved by <…>
H2: …
H3: …

Instrumentation Intent:
- What to observe (values, branches, timings, error codes)
- Where (file + function/region) — prefer minimal, hypothesis-linked probes
- What NOT to log (secrets, PII, huge payloads)
- Keep instrumentation temporary and easy to remove after verify

Constraints:
- Prefer minimal diff; no drive-by refactors
- Do not "fix" until runtime evidence supports a root cause
- Preserve existing behavior outside the failing path
- <security, compatibility, performance limits>

Deliverable:
1) Hypotheses + instrumentation plan grounded in the suspects above
2) After repro logs: root-cause summary with cited evidence
3) Targeted fix + verification steps
4) Remove temporary instrumentation once verified

Definition of Done:
Bug no longer reproduces under the protocol; fix is minimal and evidenced;
instrumentation cleaned up; related tests pass or a regression test is added when
appropriate.
```

Enrich every section with **verified** workspace facts from the code-analysis pass.
If something is unknown, write `unknown — ask user` rather than guessing.

## Override step 6 — Debug enrichment (read-only; no Debug Mode run)

After optimize + scoring:

1. Treat the **Debug-Kickoff Prompt** as the product. Do **not** enter a full
   instrument/fix loop here (that belongs in Cursor Debug Mode after the user
   pastes the kickoff).
2. **READ-ONLY**: research with read/search/list/read-only shell + MCP inspection.
   Make **NO** edits, writes, commits, installs, builds, deploys, or instrumentation.
3. Resolve ambiguities from the workspace where possible. If a genuinely blocking
   detail remains (e.g. unreproducible without a secret step), ask 1–2 targeted
   questions with the AskQuestion tool, then finish the kickoff.
4. Emit the response format below. Under `## Code Analysis Brief`, summarize
   suspects + preliminary hypotheses so the user can sanity-check before Debug Mode.
5. Under `## Debug-Kickoff Prompt`, provide the full copy-pasteable prompt for
   Cursor Debug Mode (select **Debug** mode, paste, run).
6. **Always end the response** with the Trailing phase table (`## Phased plan`).
   No substantive content after it.

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

Do not analyze or emit a kickoff. Empty `/debugify` is the short
usage, not Help. `help me debug …` is a **task**, not Help.

## No task body

If there is no task after the command, explain:

```text
/debugify <bug report>  — analyze code, enrich, emit a Cursor Debug Mode kickoff prompt
/debugify help          — full reference (also --help, /?)
/debugify tldr          — short form (stop)
/debugify pass help     — Pass (Npass) subsection (also `pass`)
/askify <prompt>        — coach then answer (read-only)
/plannify <prompt>      — coach then produce a plan
/runnify <prompt>       — optimize then EXECUTE the work (mutating)
/promptify <prompt>     — analyze/optimize only (no run)
```

The bug report is everything after the command, or the free-text request when they
said "debugify this" / "debug this prompt" / "prepare for debug mode" /
"turn this into a debug prompt".

## Response format

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, when an Nimages marker is present
Recognized `<token>` as an attachment marker. Looking at the N most recent image(s) from <source> for extra detail on the issue under review.

## Intent Analysis
…

## Workspace Assessment

### Validated Assets
…

### Recommended Assets
…

### Missing Assets
…

### Suspect Code Paths
…

### Evidence Already Present
…

### Repro Feasibility
…

### Preliminary Hypotheses
…

### Coverage Assessment
Low | Medium | High

### Execution Readiness
Low | Medium | High

## Code Analysis Brief
…
(short narrative: how the failing path works, top suspects, what Debug Mode should prove/disprove)

## Debug-Kickoff Prompt
…
(full structured prompt from step 3 — copy-pasteable into Cursor Debug Mode)

## Scores
Execution Readiness: XX
Coverage: XX
Confidence: XX

## Next step for you
1. Switch Cursor to **Debug** mode
2. Paste the Debug-Kickoff Prompt
3. Follow the agent's instrumentation + reproduction instructions

## Phased plan

| Phase | Description | Status |
|-------|-------------|--------|
| Flags | Caught and correctly interpreted `<tokens>`. On pass k of N. | Understood |
| Phase 0 — Kickoff | Code analysis + Debug-Kickoff Prompt | Done |
| Phase 1 — Instrument | Temporary probes in Debug Mode | Left |
| Phase 2 — Reproduce | User repro after probes | Left |
| Phase 3 — Analyze | Verdict + root cause from logs | Left |
| Phase 4 — Fix | Minimal evidence-backed change | Left |
| Phase 5 — Verify + clean | Repro gone; probes removed | Left |

(the trailing phase table is **mandatory** and must be the last section —
see Trailing phase status)
```

The **Next step** list may sit above the table. Prefer **table is last**.

## Trailing phase status (mandatory)

Cursor `/debugify` is kickoff-only; the Debug Mode loop it prepares is
multi-phase. The **last printed section** MUST be the promptify **Trailing
phase status** table (`## Phased plan` — Phase | Description | Status).
Users scroll to the bottom for completed vs left.

Default rows: Phase 0 Kickoff is `Done` when this skill finished; remaining
Debug Mode steps are **Left** (`Not started` is fine if nothing has run).
Do not mark later phases `Done` unless the workspace already shows that
work landed.

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite `docs/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `DBG:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.

## Hard rules

- Never invent workspace resources; verify with read/search before citing them.
- This skill MUST NOT instrument, edit, commit, build, deploy, or apply fixes —
  only prepare the Debug Mode kickoff.
- The Debug-Kickoff Prompt must be copy-pasteable as a standalone Debug Mode
  instruction and must clearly say: hypotheses + instrument first; no speculative fix.
- Hypotheses must be falsifiable and linked to concrete observations.
- Prefer verified repo-relative paths; keep analysis proportional to the bug.
- If Execution Readiness is Low or critical assets/repro are Missing, say so and
  either resolve via questions or mark unknowns explicitly in the kickoff so Debug
  Mode does not invent them.
- **Trailing phase table is mandatory:** end every kickoff with `## Phased plan`
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
