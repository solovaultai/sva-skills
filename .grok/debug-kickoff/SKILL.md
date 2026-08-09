---
name: debug-kickoff
description: >
  Debug-kickoff — read-only Debug Mode prep. Analyzes a bug report against the
  real workspace, drafts falsifiable hypotheses and suspect paths, and returns a
  copy-pasteable Debug-Kickoff Prompt for /debugify — without instrumenting,
  fixing, or mutating code. Use when the user runs /debug-kickoff,
  /promptify-debug (alias), "prepare for debug", "debug kickoff", "debug brief
  only", or wants a debug prompt without running the full loop. For the full
  instrument → repro → fix loop, use /debugify (default).
metadata:
  short-description: "Debug Mode kickoff brief only (read-only)"
---

# Debug-kickoff (= Debug Mode prep, read-only)

You are running **Debug Mode kickoff** (`/debug-kickoff`) — a read-only coach that
prepares the best possible brief for **Grok Debug Mode** (`/debugify`). You do
**not** instrument, fix, or mutate the system.

Treat `/promptify-debug` as an alias of this skill.

If the user wants the full loop in one shot, they should use `/debugify` (or
`/debug`) instead — that is the default debug behavior.

## What it does

1. Analyze the bug report + related code (read-only).
2. Produce a **Code Analysis Brief** (suspects, repro feasibility, preliminary
   hypotheses).
3. Emit a copy-pasteable **Debug-Kickoff Prompt** ready for `/debugify`.

## Pipeline

1. Optionally reuse Promptify discipline from `~/.grok/skills/promptify/SKILL.md`
   when present: intent analysis, workspace validation, scores, hard rules
   (workspace is source of truth; never invent files/APIs/tools/DBs). If that
   skill is missing, still do intent + workspace validation yourself.
2. Force mode = **Debug-kickoff** (read-only prep).
3. Apply the bug fields, code-analysis pass, kickoff prompt, and response format
   below.

## Bug intent fields

Always extract (or mark **unknown**):

| Field | Question |
|-------|----------|
| Symptom | What fails, misbehaves, or confuses? |
| Expected vs Actual | Correct behavior vs observed |
| Reproduction | Exact steps, inputs, commands, URLs, fixtures |
| Frequency | Always / intermittent / env-specific |
| Environment | App, branch, OS, runtime, config, feature flags |
| Recent changes | Commits, deps, config that may correlate |
| Existing evidence | Stack traces, logs, screenshots, failing tests |
| Blast radius | Users, paths, data at risk if mis-fixed |

## Code analysis pass (read-only)

1. Locate entry points, handlers, routes, jobs, or UI flows named in the report.
2. Trace call paths and data flow across verified files (read/search/list only).
3. Note existing logging, metrics, tests, fixtures, and error-handling near suspects.
4. Identify state boundaries (DB, cache, queues, network, auth, config) that affect repro.
5. Collect **Suspect surfaces** — real paths + symbols.
6. Draft **candidate hypotheses** only when grounded in code or evidence; mark confidence.

Under Workspace Assessment include:

- **Suspect Code Paths** — verified files/symbols with one-line why
- **Evidence Already Present** — tests, logs, traces, configs found
- **Repro Feasibility** — can user/agent reproduce here? blockers?
- **Preliminary Hypotheses** — 2–5 falsifiable ideas (not a fix plan)

Never invent files or APIs. Prefer repo-relative paths.

## Debug-Kickoff Prompt (required product)

Produce the ideal prompt to **start `/debugify`**. It must instruct the full loop
(hypotheses → instrument → repro → analyze → targeted fix → verify → clean up),
**not** a speculative fix.

Required sections:

```text
Objective:
Debug <symptom> using Grok Debug Mode (/debugify). Form multiple hypotheses,
instrument to test them, wait for reproduction + runtime logs, then apply a
minimal evidence-backed fix. Do NOT speculative-fix before runtime evidence.

Bug Report:
Symptom: <…>
Expected: <…>
Actual: <…>
Frequency: <…>
Environment: <…>
Recent changes (if known): <…>

Reproduction Protocol:
1. <exact steps after instrumentation>
2. …
Success signal that the bug occurred: <…>
How to confirm the fix later: <…>

Workspace Context:
<verified systems, entry points, configs, related tests>

Suspect Code Paths:
- path/to/file.ext — <symbol/region> — why relevant

Existing Evidence:
- <stacks, failing tests, logs, metrics already in repo or report>

Hypotheses to Test (prioritized, falsifiable):
H1: <claim> — confirmed by <…> — disproved by <…>
H2: …
H3: …

Instrumentation Intent:
- What to observe (values, branches, timings, error codes)
- Where (file + function/region) — minimal, hypothesis-linked probes
- What NOT to log (secrets, PII, huge payloads)
- Tag probes for cleanup (e.g. grok-debug); remove after verify

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

Enrich every section with **verified** workspace facts. If unknown, write
`unknown — ask user` rather than guessing.

## Execution rules for this skill

1. The **Debug-Kickoff Prompt** is the product. Do **not** enter the full
   instrument/fix loop here.
2. **READ-ONLY**: research with `read_file` / `grep` / `list_dir` / read-only shell
   + MCP inspection. Make **NO** edits, writes, commits, installs, builds, deploys,
   or instrumentation. Do not use `search_replace` or `write` for code changes.
3. Resolve ambiguities from the workspace where possible. If a blocking detail
   remains, ask 1–2 targeted questions with `ask_user_question`, then finish the
   kickoff.
4. Emit the response format below.

## No task body

If there is no bug report after the command, explain:

```text
/debug-kickoff <bug report> — analyze code, emit a Debug-Kickoff Prompt (read-only)
/promptify-debug <bug report> — alias of /debug-kickoff
/debugify <bug report>      — full loop (default): instrument → repro → fix → clean
/debug <bug report>         — alias of /debugify
/askify <prompt>            — coach then answer (read-only)
/plannify <prompt>          — coach then produce a plan
/runnify <prompt>           — optimize then EXECUTE the work (mutating)
/promptify <prompt>         — analyze/optimize only (no run)
```

## Response format

```markdown
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
(short narrative: failing path, top suspects, what /debugify should prove/disprove)

## Debug-Kickoff Prompt
…
(full structured prompt — copy-pasteable into /debugify)

## Scores
Execution Readiness: XX
Coverage: XX
Confidence: XX

## Next step for you
1. Run `/debugify` (or paste the Debug-Kickoff Prompt into a new turn with /debugify)
2. Follow instrumentation + reproduction instructions
3. Provide repro logs when the agent pauses
```

## Hard rules

- Never invent workspace resources; verify with read/search before citing them.
- This skill MUST NOT instrument, edit, commit, build, deploy, or apply fixes.
- The Debug-Kickoff Prompt must be copy-pasteable and must say: hypotheses +
  instrument first; no speculative fix.
- Hypotheses must be falsifiable and linked to concrete observations.
- Prefer verified repo-relative paths; keep analysis proportional to the bug.
- If Execution Readiness is Low or critical assets/repro are Missing, say so and
  either resolve via questions or mark unknowns explicitly in the kickoff.
- If the user clearly wants the full loop now ("just debug it", "fix it with
  debug mode"), prefer `/debugify` behavior or tell them to re-run with `/debugify`
  — do not silently start mutating under this skill.
