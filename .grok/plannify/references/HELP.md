# Plannify — user reference

Print this file as the response when the user runs `/plannify help`,
`/plannify --help`, or `/plannify /?`. Do not plan or replan.
`/plannify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/plannify` is the short usage cheat, not this page.
`fromhere` is a task body (replan), not help.
First token `add` is **Add**, not help.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Promptify in **Planning** mode. Coach the request into a
planning-kickoff prompt, then run that prompt **read-only** and emit
a structured plan. Never implements, edits, or mutates the workspace.

Aliases: `/planify`, `/plify`, `/promptify-plan`.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see `the docify skill's references/docify_contract.md`). Help, tldr, and pass do not write.

Window title prefix is `PLAN:` (see `docs/window_title.md`).
Help, tldr, and pass do not retitle.

---

## How to invoke

```text
/plannify <prompt>     — coach, then produce a plan (read-only)
/plannify fromhere     — replan from current statuses (also planify fromhere)
/plannify add <feat>   — add a feature to the just-run plan (last ify: plannify or phasify)
/plannify help         — this reference (also --help / /?)
/plannify tldr         — short form; stop
/plannify pass         — Pass (Npass) subsection only (also pass help)
/planify <prompt>        — alias of /plannify
/promptify-plan <prompt>— alias of /plannify
/plify <prompt>          — alias of /plannify
```

The prompt to plan is everything after the command, or the free-text
when they said “plannify this” / “plan this prompt”.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/plannify <prompt>` | **Plan** | Optimize + read-only planning pass |
| `/plannify fromhere` / `planify fromhere` | **fromhere** | Replan from current statuses |
| `/plannify add <feature>` | **Add** | Surgical feature add (last ify must be plannify or phasify) |
| `/plannify` *(empty)* | Short usage | No plan. `fromhere` / `add` are **not** empty. |
| `/plannify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/plannify tldr` | **tldr** | Print the short page; stop |
| `/plannify pass` / `pass help` | **Pass help** | Print the Pass section; stop |

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `fromhere` and first token
`add` are never treated as help.

---

## `/plannify fromhere` (alias `planify fromhere`)

Read-only replan from the **current** plan’s statuses. Not a
greenfield plan. If no current plan exists, tell the user to
`/plannify` first.

1. Recover Task row text (original ify wording) and Flags
   (`Nimages` / `Npass` or none). Same outcome; same flags.
2. List phases already `Done` (landed) and `Deferred` / `Def-Blocked`
   (skip + reason).
   Do not treat them as greenfield.
3. Run the normal plannify pipeline (including Npass / scratch
   images if Flags has them).
4. Emit a **candidate** plan that keeps Done/Deferred/Def-Blocked
   constraints
   and aims at the same Task.

Then **AskQuestion**: Keep new plan vs Continue original. If it
fits, show the two phased tables **side by side** (or stacked
labeled Original / Candidate if width fails). The chosen plan
becomes current for later `/phasify`.

---

## `/plannify add`

Surgically add a **feature** to the plan that was just run. Not a
greenfield plan. Not fromhere (no Keep vs Continue). Not
`/addify` (addify on plannify restarts from scratch and discards
statuses).

After flag strip, first token `add` is this mode. Remainder is
the feature text (verbatim). Reserved: a prompt that starts with
`add` is Add, not a new plan.

**Gate:** last ify must be **plannify** or **phasify** (same
recover walk as addify). Otherwise **Error:** — do not plan.
Name the last ify if one exists. No current plan: **Error:**
`/plannify` first. Empty `/plannify add`: **Error:** `add` needs
a feature.

**Surgical:** if the text does **not** add, remove, or change a
feature, keep the plan as-is and reprint the table. Else redo
only the affected phases; keep the rest (including Done /
Deferred / reasons). New work gets new phase row(s). Do not
AskQuestion.

```text
/plannify add OAuth login
/plannify add Defer - Delete IP
```

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify: first numbered instance left to
right; skip unnumbered `image` / `pass` (first typed token `image` counts as `1image`). Strip **before** deciding
Help vs fromhere vs add vs plan. Cite promptify **Flag parse order** —
do not fork.

**`Nimages`:** N newest images from the scratch source (`scratch ls N`) or workspace `scratch/`. Attachment marker,
not task wording. Lead with the caught-and-interpreted ack. Carry
what they show into the Planning-Kickoff Prompt and the plan.

**`Npass`:** see **Pass (`Npass`)** below.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
Strip them with the other flags. The plan includes each resolved
image: its path and what it shows. An `img` token is included on
the Flags row. With no `Nimages` and no `Npass`, that row is still
printed.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this section** and stops.
Full reference: `/promptify pass help` (canonical) or
`/plannify help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right (promptify Flag parse order). Default **1**.

**Meaning:** take N passes before producing the plan. If **N > 1**,
pass 1 is a documented `## Pre-plan (pass 1)` only — inventories,
capabilities, external tools, approach, gaps, light planning. Do
**not** emit the final plan on pass 1. Passes 2–N use that base;
the **last pass** produces the Planning-Kickoff Prompt and the
**Plan**. Acknowledge after the scratch ack when both appear.

```text
/plannify pass
/plannify pass help
/plannify 2pass <prompt>
/promptify pass help
```

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
| **Status** | `Not started` on new plans; or `Done` / `In progress` / `Left` / `Blocked` / `Unblocked` / `Deferred` / `Def-Blocked` when known. `Unblocked` is like `Left`. `Def-Blocked` = canonical Deferred-Blocked (12-wide Status fit). Canonical definitions + transitions: phasify HELP **Concepts**. Aligned recap spelling of in-progress is `Progress`. Do not invent statuses. |
| **Reason** | Optional. If a deferral (or future-consideration slice) has a reason, add it so it matches phasify deferrals |

**Flags row** first when `Nimages`, `Npass`, or `img` is present:
`Caught and correctly interpreted <tokens>. On pass k of N.` Status
`Understood`. Not a work phase. An `img` token alone still gets the row.
Cite promptify **Named images**.

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
- `fromhere`: same Task and Flags; keep Done/Deferred/Def-Blocked; then
  AskQuestion Keep vs Continue.
- `add <feature>`: last ify must be plannify or phasify, else
  **Error:**. No-op if the text does not add, remove, or change a
  feature; otherwise redo only affected phases. Not fromhere. Not
  addify from-scratch.
- `Nimages` / `Npass`: strip first; acknowledge; N > 1 ⇒ pass 1
  is pre-plan only.
- Exact `help` / `--help` / `/?` after flag strip: print this
  page; do not plan. Exact `tldr`: print `references/TLDR.md`
  (not this file). Exact `pass` / `pass help`: print **Pass
  (`Npass`)** only. There is no `/pass` skill. Empty is short
  usage, not help. `fromhere` is not help. First token `add` is
  Add, not help.

---

## Related

| Command | Role |
|---------|------|
| `/phasify` | Execute the next incomplete phase |
| `/phasify help` | Phasify reference |
| `/promptify pass help` | Canonical Pass (`Npass`) reference |
| `/promptify <prompt>` | Analyze / optimize only |
| `/runnify <prompt>` | Optimize then execute |
| `/askify <prompt>` | Optimize then answer (read-only) |
| `/plannify add <feature>` | Surgical feature add on the just-run plan (last ify: plannify or phasify) |
| `/addify <text>` | Append `<text>` to the last ify and restart/continue that skill |
