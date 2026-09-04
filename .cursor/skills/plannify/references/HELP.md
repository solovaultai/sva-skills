# Plannify — user reference

Print this file as the response when the user runs `/plannify help`,
`/plannify --help`, or `/plannify /?`. Do not plan or replan.

Empty `/plannify` is the short usage cheat, not this page.
`fromhere` is a task body (replan), not help.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Promptify in **Planning** mode. Coach the request into a
planning-kickoff prompt, then run that prompt **read-only** and emit
a structured plan. Never implements, edits, or mutates the workspace.

Alias: `/promptify-plan`.

---

## How to invoke

```text
/plannify <prompt>     — coach, then produce a plan (read-only)
/plannify fromhere     — replan from current statuses (also planify fromhere)
/plannify help         — this reference (also --help / /?)
/promptify-plan <prompt>— alias of /plannify
```

The prompt to plan is everything after the command, or the free-text
when they said “plannify this” / “plan this prompt”.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/plannify <prompt>` | **Plan** | Optimize + read-only planning pass |
| `/plannify fromhere` / `planify fromhere` | **fromhere** | Replan from current statuses |
| `/plannify` *(empty)* | Short usage | No plan. `fromhere` is **not** empty. |
| `/plannify help` / `--help` / `/?` | **Help** | Print this page; stop |

Exact remaining body after flag strip must be `help`, `--help`, or
`/?`. `fromhere` is never treated as help.

---

## `/plannify fromhere` (alias `planify fromhere`)

Read-only replan from the **current** plan’s statuses. Not a
greenfield plan. If no current plan exists, tell the user to
`/plannify` first.

1. Recover Task row text (original ify wording) and Flags
   (`Nimages` / `Npass` or none). Same outcome; same flags.
2. List phases already `Done` (landed) and `Deferred` (skip + reason).
   Do not treat them as greenfield.
3. Run the normal plannify pipeline (including Npass / scratch
   images if Flags has them).
4. Emit a **candidate** plan that keeps Done/Deferred constraints
   and aims at the same Task.

Then **AskQuestion**: Keep new plan vs Continue original. If it
fits, show the two phased tables **side by side** (or stacked
labeled Original / Candidate if width fails). The chosen plan
becomes current for later `/phasify`.

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify: first numbered instance left to
right; skip unnumbered `image` / `pass`. Strip **before** deciding
Help vs fromhere vs plan.

**`Nimages`:** N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`. Attachment marker,
not task wording. Lead with the caught-and-interpreted ack. Carry
what they show into the Planning-Kickoff Prompt and the plan.

**`Npass`:** take N passes before producing the plan. If **N > 1**,
pass 1 is a documented `## Pre-plan (pass 1)` only — inventories,
capabilities, external tools, approach, gaps, light planning. Do
**not** emit the final plan on pass 1. Passes 2–N use that base;
the **last pass** produces the Planning-Kickoff Prompt and the
**Plan**. Acknowledge after the scratch ack when both appear.

---

## Planning-Kickoff Prompt (required sections)

Copy-pasteable. Must say **plan, do not implement**.

- Objective — plan/design for X; do not implement
- Workspace Context — verified files / systems / paths
- Research Scope — what to investigate and where
- Key Decisions & Trade-offs
- Open Questions — never silently assume
- Constraints
- Deliverable — phased plan; body may detail phases; response
  **must** end with the trailing phase table
- Definition of Done — includes that trailing table

---

## Planning pass (read-only)

After optimize + scoring:

1. Run **only** the optimized Planning-Kickoff Prompt.
2. **READ-ONLY** — no edits, writes, commits, installs, builds,
   or deploys.
3. Resolve open questions from the workspace. If a blocking
   decision remains, ask 1–2 targeted questions before finalizing.
4. Produce the plan (`## Plan`, or the platform plan tool when
   available).
5. Keep the plan proportional; cite verified paths.
6. **Always end** with the Trailing phase table.

If Execution Readiness is Low or critical assets are Missing, say
so and either resolve via questions or make the plan’s first phase
close those gaps.

---

## Trailing phase table (mandatory)

Every plan ends with `## Phased plan` as the **last printed item**.
GitHub markdown. Users scroll to the bottom for completed vs left.

| Column | Content |
|--------|---------|
| **Phase** | Short id + title (`P0 — Spec`) |
| **Description** | One-line what ships / exit criteria |
| **Status** | `Not started` on new plans; or `Done` / `In progress` / `Left` / `Blocked` / `Deferred` when known |
| **Reason** | Optional. If a deferral (or future-consideration slice) has a reason, add it so it matches phasify deferrals |

**Flags row** first when `Nimages` and/or `Npass` is present:
`Caught and correctly interpreted <tokens>. On pass k of N.` Status
`Understood`. Not a work phase.

After Flags, one row per phase an executor should run. Status
`Deferred` + optional reason is allowed on new plans for
future-consideration slices. If the plan has no phases (rare
single-step), still emit a one-row table. Do not omit the table
when the body already has a long phase section.

---

## Response shape

Scratch ack (if any) → Npass ack (if any) → Intent Analysis →
Workspace Assessment → Pre-plan (only if Npass > 1) →
Planning-Kickoff Prompt → Scores → Plan → **Phased plan** (last).

---

## Hard rules (short)

- Never invent workspace resources.
- Planning pass must not modify the system.
- Kickoff prompt is copy-pasteable and says “plan, do not implement.”
- Trailing `## Phased plan` table is mandatory and last.
- Status `Deferred` + optional reason is allowed.
- `fromhere`: same Task and Flags; keep Done/Deferred; then
  AskQuestion Keep vs Continue.
- `Nimages` / `Npass`: strip first; acknowledge; N > 1 ⇒ pass 1
  is pre-plan only.
- Exact `help` / `--help` / `/?` after flag strip: print this
  page; do not plan. Empty is short usage, not help. `fromhere`
  is not help.

---

## Related

| Command | Role |
|---------|------|
| `/phasify` | Execute the next incomplete phase |
| `/phasify help` | Phasify reference |
| `/promptify <prompt>` | Analyze / optimize only |
| `/runnify <prompt>` | Optimize then execute |
| `/askify <prompt>` | Optimize then answer (read-only) |
| `/addify <text>` | Append `<text>` to the last ify and restart/continue that skill |
