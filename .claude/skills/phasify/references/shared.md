# Shared procedures

Locate the plan, capture Task and Flags, scratch images, named images, multi-pass, response shape, and hard rules. The phasify router says which modes read this file.

## Locate the plan vs the original ify text

Keep two things separate:

1. **Phased plan table** (what you execute / update) — from the latest
   `/plannify` (or equivalent) `## Phased plan`, or a verified plan file.
   A resumeify restore in this conversation is a current plan. The
   snapshot path printed in the resume banner (`plan.md`) is a verified
   plan file. Read it for the plan body. Cite `docs/saveify_contract.md`.
   If no plan is found, stop and tell the user to `/plannify` first.
   Do not invent phases.
2. **Original ify text** (what you put in the **Task** row) — the user's
   **raw request** that kicked off promptify, askify, runnify, plannify,
   debugify, addify, or whatever ify produced this plan. That is the
   text they typed after the slash command (or the free-text they asked
   to ify). When the plan came from `/addify`, use the **combined**
   text (ancestor body + addify bodies). When the plan is a resumeify
   restore, the Task is the reprinted Task. It is **not** Intent Analysis,
   not the Kickoff/Optimized Prompt, not `## Plan`, and not any
   interpreted, projected, or updated text the ify created.

If the raw request is not in this conversation, recover it from the ify
invocation that created the plan. If it cannot be recovered, put
`(original ify text not found)` in the Task Description — do not
substitute the plan.

## Capture Task and Flags (mandatory)

Fill **Task** and **Flags** exactly as `docs/phase_layout.txt` (and this
skill's `phase_layout.txt`) show — three columns, no extra box, no
spanning cell.

### Task

**Description** = the verbatim original ify Task text (the words the
user typed for promptify / askify / runnify / plannify / debugify /
addify). When the plan came from `/addify`, this is the **combined**
text (ancestor body + addify bodies). A later phasify table must
reprint a plannify Task Description that is a labeled chain
(`Original:` then each `Add:`) as stored. Do not collapse it and do
not drop the labels. When the plan is a resumeify
restore, the Task is the reprinted Task. Not `## Plan`, not Intent
Analysis, not the Kickoff/Optimized Prompt, not scores, not any
interpreted / projected / updated text an ify generated. Do not
rewrite or summarize.

Strip `Nimages` / `Npass` marker tokens from the Task text (they belong
in Flags). Leave the rest unchanged.

- Status **`Planned`** on the **first** Task line only; blank Status on
  wrap lines (as in the layout).
- Phase: blank on the first Task line (text + `Planned`); label
  **`Task`** on the next line; blank Phase on further wraps.

### Flags — both, one, or none

Parse `Nimages` and `Npass` independently per promptify **Flag parse
order**: first numbered instance left to right; skip unnumbered
`image` / `pass` so a later `1image` / `2pass` can count. Exception: the first typed token exactly `image` counts as `1image`. No numbered
instance ⇒ that flag is absent.

| What the user included | Flags row |
|------------------------|-----------|
| Both `Nimages` and `Npass` | **Two** Description lines (image family, then pass family) |
| Only `Nimages` **or** only `Npass` | **One** Description line for that token |
| Neither | **Omit** the Flags row entirely |

Each present flag is its own Description line:

`Caught and correctly interpreted <token>. On pass k of N.`

- `<token>` is the exact numbered token (`1image`, `2pass`, …).
- **N** is the Npass value (default **1** if `Npass` is absent).
- **k** is the pass just finished or in progress (after the last pass:
  `On pass N of N`).
- Phase **`Flags`** on the first Flags line; blank Phase on a second
  line. Status **`Understood`** on the first Flags line only; blank after.

This row is not a work phase.

**Next incomplete** = first phase whose Status is not `Done`, not
`Deferred`, and not `Def-Blocked` (treat `Not started`, `Left`,
`Unblocked`, `In progress` / `Progress`, `Planned`, `Blocked` as
eligible). `Unblocked` is like `Left` (ready to run, not complete).
If `Blocked`, try it only if this run can unblock it, otherwise skip
and say so. `Def-Blocked` is **skipped** (deferred) — not “run until
blocked.”

Skip `Done`, `Deferred`, and `Def-Blocked` unless `--force` / explicit
redo. Named `pN` is an explicit request to run that phase (even if
Deferred / Def-Blocked). Stop the sequence on `Blocked`. Do **not**
stop the sequence on `Def-Blocked` — skip it like `Deferred`.

If the named phase does not exist, stop and list the real phase ids.
If **Next-N** asks for more phases than remain, run the remainder and say
the shortfall.
If the named phase is already `Done`, do not redo it unless the user said
`redo` / `--force`; report that and still print the closing recap.

---


### Scratch images (`Nimages` / `Nimage`)

When the user text includes **`Nimages`**, **`N images`**, **`N-images`**,
or singular **`Nimage`** / **`N image`** / **`N-image`** (case-insensitive;
examples: `1image`, `1 image`, `1-image`, `3images`), that token is an
**attachment marker**, not a phase count and not part of the task wording.

Follow promptify **Scratch images**: if `scratch.env` exists, run
`scripts/cli.sh scratch ls N` (or `scripts\cli.ps1 scratch ls N`) and
**read those paths**. Else workspace `scratch/` (do not create). Use
what the images show (blocker evidence, UI state, phase
clarification). Do not treat the marker as phase-selection.

**Tell the user (mandatory, first printed content when a marker is present):**
Name the source (`local …` or `remote conn:dir` or workspace `scratch/`).
Then run the chosen phasify mode.

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

Do not skip or bury this. Strip **image and pass** tokens **before**
parsing the phasify mode so `phasify 3 2images` means **next 3 phases** +
2 scratch images, not phase 2; `/phasify 1image` is **Next** + 1 image;
empty `/phasify` is **Next**; and `2pass` is never a phase count.

### Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` name
specific files. Every token counts. Strip them before mode
dispatch. They are not a phase id. This phase's implementation
reads each resolved image and uses what it shows. When this
chat restored a snapshot, also read that snapshot's
`images.txt`. Ack first, after the scratch ack when both are
present.

### Multi-pass (`Npass`)

Inherited from promptify **Multi-pass**. When **`Npass`** /
**`N-pass`** / **`N pass`** is present (same Flag parse order), take
**N** pipeline passes on **this invocation's mode work**. Default
N = 1 if absent. Not a phase selector and not Task wording.

When **N > 1**, pass 1 is a documented pre-plan only (`## Pre-plan
(pass 1)` — inventories, approach, gaps for **this mode**). Passes
2–N use that base; the last pass produces the mode's deliverable
(execute, Rundefer undefer+execute, Runblock unblock+execute-or-Done,
Todo briefing, Explain briefing, Dummy tell, Tldr phase tell,
Tldr question, Dummy question, Ask answer, Guide file, Coach log, Howto steps, Unblock test,
Block/Defer reason, Remove target list + confirm, Show table, …).

**Npass on a single phase** is a multi-pass run of **that phase's
work** (definition, clarification, verification, or execute) — not
a re-plan of the whole table. Whole-table replan remains
`/plannify fromhere`. Extra pass(es) are especially for Todo
briefing quality, Explain briefing quality, Howto step quality, Unblock test design, Block/Defer reason quality,
or execute / Rundefer / Runblock of a complex / complete phase.
Extra pass(es) also improve a dummy tell, a tldr phase tell, a
tldr question, a dummy question, an ask answer, a
guide, or the coach step list (the coach still waits between steps).

Print the promptify Npass acknowledgment after the scratch ack
when both appear:

```markdown
**Npass — caught and correctly interpreted.**
Recognized `<token>`: taking N passes. Pass 1 is a documented pre-plan;
passes 2–N use that base for the final deliverable.
```

Capture whichever flags the user included (both, one, or none)
in the table — see **Capture Task and Flags**. If the work is
multi-phase **or** `Nimages` / `Npass` is present, Flags is the
**first row** of the trailing phase status table. Last printed
item is that table (plus optional one-line next-step).

## Response shape

Empty `/phasify` and `next` use the single-phase path (one phase, then
the table). Next-N / Run-to-end / Stop-before-end / Rundefer /
Runblock add later phases after each prior phase finishes. Mid-run:
banner only. Last-of-run: banner + full table.

```markdown
**Scratch images — caught and correctly interpreted.**   ← first, if marker present
**Npass — caught and correctly interpreted.**   ← after scratch ack, if marker present

## Phase P0 — Spec
(short: what you implemented)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P0 — Spec   COMPLETED                              │
└──────────────────────────────────────────────────────────────┘
(banner only — not the last phase of this run)

## Phase P1 — API
(only if this run included it; after P0 fully finished)

┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P1 — API   COMPLETED                               │
└──────────────────────────────────────────────────────────────┘

## Phased plan
(aligned table — last phase of this run only; last printed section)
```

`show` / `refresh` print only the table (plus Reason if any deferral has
one). `todo` prints the Todo report (or “nothing eligible” + table).
`explain` prints the Explain report for each target (or “nothing
eligible”). It does **not** rewrite or reprint the phased plan.
Named `pN` may be `Done`: report what landed. Count selectors
skip `Done`. Invalid explain id: **Error:** (same style as defer).
`explain 0` / `0explain` / `explain0`: **Error:** (use
`explain p0`). Bare `explain` / `explain N` with none not-Done:
say so. Fewer than N not-Done: explain all found and say the
shortfall. No phase table. No COMPLETED banners for Explain
itself (advisory). Each TL/DR is the explanation only.
`dummy` is the non-technical tell (same selectors as explain;
`dummy 0` is **Error:**, use `dummy p0`). Bare `dummy`, `dummy N`,
`dummy pN`, and `dummy guide` stay that tell. A remainder that
is not a selector and not `guide` is a plain-language question.
A tldr **phase tell**
(`tldr 1`, `tldr N`, `Ntldr`, `tldr pN`) is the explanation only.
Exact `tldr` with no other token still prints `references/TLDR.md`
and stops. Any other tldr remainder is a few direct sentences.
`guide` is a second word on those tells and writes a
file only when every target is blocked or partially blocked.
`coach` is one blocked phase, one step at a time, then a log.
`ask <question>` answers the current plan. Empty `ask` is
**Error:** `ask` needs a question. `ask p3` and `ask 3` are
questions, not Named and not Next.
Dummy, tldr-tell, explain, guide, and coach do not change Status
and do not reprint the plan. On a block they add an unblock list
at that depth. Other statuses get no unblock list. Ask does not
change Status and does not reprint the plan. Ask, a tldr
question, and a dummy question do not retitle.
Invalid todo id, or named todo of a `Done` phase: **Error:** (same style
as defer). `todone` prints the Todo-depth briefing for each target, sets
Status `Done` (no ack wait), then the full table. Invalid todone id, or
named todone of a `Done` phase: **Error:** (same style as defer /
todo-on-Done). Bare `todone` / `todone N` with none eligible: say so +
table. Fewer than N eligible: todone all eligible, say the shortfall,
print the table. `block` prints the updated table (or “none eligible” / shortfall
+ table). Named block of a `Done` phase: **Error:** cannot block a
completed phase. Invalid block id: **Error:** (same style as defer).
`unblock` prints verification + updated table on pass, or stays
`Blocked` / `Def-Blocked` with evidence + manual instructions on fail
(or “none blocked” + table). Invalid unblock id, or named unblock of a
phase that is neither `Blocked` nor `Def-Blocked`: **Error:** (same
style as defer). `defer` and `undefer` print **Error:** on invalid id
(or undefer of a phase that is neither `Deferred` nor `Def-Blocked`),
otherwise the updated table (undefer does **not** execute). `rundefer`
undefer then execute; none deferred: say so + table (do not execute
some other open phase). Named rundefer of a phase that is neither
`Deferred` nor `Def-Blocked`: **Error:**. Fewer than N: undefer+run
all found; say the shortfall. A `Def-Blocked` target becomes `Blocked`
and stops execute (BLOCKED banner + last-of-run table). `runblock`
unblock then execute-or-mark-Done; none blocked: say so + table (do
not execute some other open phase). Named runblock of a phase that
is neither `Blocked` nor `Def-Blocked`: **Error:** (same style as
invalid unblock). Fewer than N: unblock+run-or-mark all found; say
the shortfall. `Def-Blocked` → `Left` (clears both); `Blocked` →
`Unblocked` then run or mark `Done`. Stop if a just-runblocked
phase becomes `Blocked` again. `remove` / `delete` propose
work-phase row(s) then **wait for yes/no**; on yes drop those
rows and compact-renumber; on no print the unchanged table.
Invalid remove id, ambiguous title, or `remove 0` / `0remove`:
**Error:** (use `remove p0` for P0). Named may remove `Done`.
Bare / count skip `Done`. None not-Done: say so + table. Fewer
than N: propose all found, say the shortfall, still confirm.
`help` /
`--help` / `/?` print `references/HELP.md` only. `pass` / `pass help`
print the **Pass (`Npass`)** section only.

---


## Hard rules
- Cite `docs/window_title.md`. Name is `PHASE:P<n>/<total>:<PREFIX>: <summary>`. Set the tmux window name per that contract on a real task. Help, exact `tldr`, and pass do not retitle. Ask, a tldr question, and a dummy question do not retitle. Dummy, explain, a tldr phase tell, guide, and coach use the phase they are about. Empty `/phasify` is Next, so it does.

- Cite `docs/from_contract.md`. `from=` and `from:` splice local files into this prompt. Help, tldr, pass, and empty do not read files.

- Cite `the docify skill's references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, exact `tldr`, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file. Cite `docs/docify_contract.md` for guide and coach: stored path, format, and prefix, else `/home/ami/src/pytch/pytch-docs/agent/`, markdown, generated `CAPS` name (`GUIDE` / `COACH_LOG` if the title is empty). Missing pytch-docs checkout: **Error:**. Do not invent another folder. Do not commit.

- Execute only the selected phase(s). Do not re-plan the whole project.
  Use `/plannify fromhere` (plannify skill) to replan from current
  statuses.
- Empty `/phasify` (no selector after stripping image/pass tokens) is
  **Next** (count = 1), same as `next`. Never print help/usage for an
  empty invocation. After flag strip, first token `smart` is **Smart**
  (cite `docs/smart_contract.md` + `references/SMART.md`); not Next;
  not implicit NL. After flag strip, `help` / `--help` / `/?` prints
  `references/HELP.md` and stops — do not execute. After flag strip,
  exact `tldr` prints `references/TLDR.md` and stops. That print is
  the whole reply: do not narrate the process, add a followup, or
  add anything around the page. Do not rewrite or reprint the phased
  plan. A phase tell needs a selector (`tldr 1`, `tldr N`, `Ntldr`,
  `tldrN`, `tldr pN`). `tldr help` is not help. Any other remainder
  is a short direct answer: a few sentences, no headings, no
  process narration, no follow-up. Images on that line are
  evidence, then the short answer. Do not execute. Do not change
  Status. Do not rewrite or reprint the phased plan. Do not
  retitle. Exact `tldr` and a selector still win. Exact `tldr` is
  never a phase id. After flag strip,
  `pass` / `pass help` prints the **Pass (`Npass`)** section and
  stops.
- All multi-phase execute modes are **sequential, synchronous, in plan
  order**. No parallel/fan-out. Next-N, Run-to-end, Stop-before-end,
  Rundefer, and Runblock: x finishes, then x+1 begins.
- Skip `Done`, `Deferred`, and `Def-Blocked` unless `--force` /
  explicit redo / named `pN`. Stop the sequence on `Blocked`. Skip
  `Def-Blocked` (do not “run until blocked”).
- After every finished phase except the last of this run: banner only.
  After the last phase of this run: banner + full table. Single-phase
  Next stays banner + table.
- Flags (`Nimages` / `Npass`) work in **all** modes. Strip first
  (promptify Flag parse order). `-2pass` is Npass, not
  Stop-before-end. Npass on a phase is multi-pass of **that
  phase's work**, not `/plannify fromhere`.
- `-` / `-0` / `-N` is **Stop-before-end** (`C - N`). `-2pass` is a pass
  flag, not stop-before-end. Bare `3` is still Next-3.
- Invalid defer id: **do not defer**. Print a clear **Error:** line
  (red via HTML `<span style="color:red">` when the client will render
  it; otherwise bold `Error:`).
- Invalid undefer id, or undefer of a phase that is neither `Deferred`
  nor `Def-Blocked`: **do not change it**. Print the same **Error:**
  style. Bare `undefer` with no Deferred / Def-Blocked phase: say so
  — do not invent a target. Success: `Deferred` → `Left` (clear
  Reason); `Def-Blocked` → `Blocked` (keep blocker Reason). Print the
  table; do not execute. Parse `undefer` / `Nundefer` as Undefer, not
  Defer, not Rundefer.
- `rundefer` / `Nrundefer` / `rundefer N` / `rundeferN` undefer then
  execute those phases. Bare `rundefer` = next 1 Deferred /
  Def-Blocked. `rundefer N` / `Nrundefer` / `rundeferN` / `2rundefer`
  / `rundefer2` (N ≥ 1) = next N deferred, **not** named PN (unlike
  `Nundefer` / `2undefer` / `Nblock` / `2block`). Named is only `pN`
  (`rundefer pN` / `pN rundefer`); else **Error:** if that phase is
  neither `Deferred` nor `Def-Blocked`. None: say so + table; do
  **not** execute some other open phase. Fewer than N: undefer+run
  all found; say the shortfall. Undefer first (`Deferred` → `Left`,
  clear Reason; `Def-Blocked` → `Blocked`, keep blocker Reason) then
  execute just-undeferred runnable phases; **stop on Blocked** (do
  not pretend Def-Blocked became runnable). Skip if still Deferred.
  Banners / last-of-run table like other execute modes. No ack wait.
  Npass = this rundefer run, not whole-table replan. Parse `rundefer`
  **before** `undefer` / `defer`. `rundefer` ≠ `undefer` ≠ `toend` ≠
  `todo` ≠ `todone`. Do not collapse on `un` / `defer` / `run`.
  **Undefer stays status-only** (no execute).
- `runblock` / `Nrunblock` / `runblock N` / `runblockN` unblock then
  execute remaining work or mark `Done`. Skip Unblock’s verification
  loop (no ack wait; same assertiveness as rundefer / todone). Bare
  `runblock` = next 1 Blocked / Def-Blocked. `runblock N` /
  `Nrunblock` / `runblockN` / `2runblock` / `runblock2` (N ≥ 1) =
  next N blocked, **not** named PN (unlike `Nblock` / `2block` /
  `Nunblock` / `2unblock`). Named is only the `P`/`p` family
  (`runblock pN` / `runblock PN` / `runblockpN` / `runblockPN` /
  `pN runblock` / `PNrunblock`); else **Error:** if that phase is
  neither `Blocked` nor `Def-Blocked`. `runblock 0` / `0runblock` /
  `runblock0`: **Error:** (use `runblock p0`). None: say so +
  table; do **not** execute some other open phase. Fewer than N:
  unblock+run-or-mark all found; say the shortfall. Unblock first
  (`Blocked` → `Unblocked` / ready; `Def-Blocked` → `Left` / ready
  — clear **both** block and defer, unlike unblock → `Deferred`
  and unlike rundefer → `Blocked` and stop). Then execute remaining
  agent-automatable work (`Done` only if work landed) **or** mark
  `Done` when nothing is automatable (short note; no Todo briefing;
  no fake implement; Reason closed by runblock or clear). Stop the
  sequence if a just-runblocked phase becomes `Blocked` again.
  Banners / last-of-run table like other execute modes. No ack
  wait. Npass = this runblock run, not whole-table replan. Parse
  `runblock` **before** `block` / `unblock`. `runblock` ≠ `unblock`
  ≠ `block` ≠ `rundefer`. Do not collapse on `run` / `un` /
  `block`. **Unblock stays verify-only** (no execute).
- `howto` / `Nhowto` / `howto N` / `howtoN` print step-by-step
  instructions to get past the next blocked or partially blocked
  phase. Do not execute. Do not change Status. Eligible:
  `Blocked`, `Def-Blocked`, or partially blocked (`Progress` /
  `In progress` with a recorded blocker: a Reason, or
  this conversation stopped that phase on a human step). A
  `Progress` phase with no recorded blocker is not a target.
  Bare `howto` = next 1 eligible. `howto N` / `Nhowto` /
  `howtoN` / `2howto` / `howto2` (N ≥ 1) = next N eligible,
  **not** named PN. Named is only the `P`/`p` family (`howto pN`
  / `howto PN` / `pN howto` / `PNhowto`); else **Error:** if that
  phase is not blocked or partially blocked. `howto 0` /
  `0howto` / `howto0`: **Error:** (use `howto p0`). No plan:
  `/plannify` first. None eligible: **Nothing to do.** and
  reprint the aligned phase plan (statuses unchanged; not
  `/plannify fromhere`). Fewer than N: write all found, say the
  shortfall, print the table. Blocker from the record only (do
  not invent one). Numbered human steps. Always a mermaid of the
  path. A web image only when a physical or on-screen step needs
  one and the source allows reuse (cite title, URL, license; do
  not copy it into the repo; if none is reusable, say so and keep
  the diagram). Scratch images / `img` are blocker evidence. No
  COMPLETED banners. After the person finishes, `unblock`
  verifies or `runblock` continues. Npass = this howto, not a
  whole-table replan. Nothing to do: leave the window name.
  Parse `howto` as Howto, not Explain, not Unblock, not Runblock,
  not Todo.
- `show` / `refresh` are read-only. No implementation.
- `todo` / `Ntodo` / `todo N` are read-only / advisory. No
  implementation. Do not change Status. Do not execute the phase or
  later phases. Bare `todo` with nothing eligible (all `Done` or only
  `Deferred` / `Def-Blocked` left): say so and print the table. Invalid
  id: same **Error:** as defer. Named todo of a `Done` phase:
  **Error:** cannot todo a completed phase. Named todo may todo a
  `Def-Blocked` phase. Parse `todo` / `Ntodo` as Todo, not `todone`,
  not `toend`. `todo N` means named PN (not next N).
- `explain` / `Nexplain` / `explain N` / `explainN` are read-only
  / advisory. No implementation. Do not change Status. Do not
  execute the phase or later phases. Bare `explain` = next 1
  not-`Done` (**include** `Deferred`, `Def-Blocked`, `Blocked`,
  `Left`, `Unblocked`, `Progress`, `Planned`, `Not started`).
  Unlike bare todo: do **not** skip Deferred. `explain N` /
  `Nexplain` / `explainN` / `explain3` / `3explain` / `2explain`
  (N ≥ 1) = next N not-Done (**not** named PN; like `rundefer N`).
  Named is only `pN` / `PN` (`explain pN` / `explainP3` /
  `P3explain`). `explain 0` / `0explain` / `explain0`: **Error:**
  (use `explain p0`). Named `pN` may be `Done`: what landed, from
  this conversation and verified files. Thin record: say so and
  quote the description. Do not invent work. Invalid id: same
  **Error:** as defer. None not-Done: say so. Fewer than N: explain
  all found and say the shortfall. Do not rewrite or reprint the
  phased plan. Next-N Explain does **not** stop on Blocked (explains
  and continues). Pending content stays the full write-up. On
  `Blocked`, `Def-Blocked`, or partially blocked, add detailed
  unblock instructions from the record. Other statuses get no
  unblock list. Each phase ends with **TL/DR**, and that TL/DR is
  the explanation only (no process, no followup, no other
  information). No phase table. No COMPLETED banners for Explain
  itself. Parse `explain` / `Nexplain` / `explainN` as Explain, not
  Todo, not Todone, not `toend` / `end`.
- `dummy` / `Ndummy` / `dummy N` / `dummyN` match explain’s
  selectors. Non-technical intent, then a simple description. No
  commands, paths, or APIs. `dummy N` = next N not-Done. Named is
  only `pN` and may be `Done`. `dummy 0` / `0dummy` / `dummy0`:
  **Error:** (use `dummy p0`). On a block: task names, spelled out,
  not enough to perform them. No Status change. No plan rewrite.
  Bare `dummy`, `dummy N`, `dummy pN`, and `dummy guide` stay the
  phase tell. A remainder that is not a selector and not `guide`
  is the question: everyday language, no commands, paths, or APIs.
  If a fact only exists as one of those, say what the person is
  trying to accomplish and stop. Images are described only in
  that plain language. Do not retitle. A selector still wins.
- A tldr phase tell (`tldr 1`, `tldr N`, `Ntldr`, `tldrN`, `tldr pN`)
  is the explanation only. No process narration. No followup. Same
  selectors as explain. `tldr 0` is **Error:** (use `tldr p0`). On a
  block: a numbered list a capable technologist could carry out.
  Exact `tldr` stays the short page. Any other remainder is a few
  direct sentences. No headings. No follow-up. No “in other words.”
  Do not retitle. Exact `tldr` and a selector still win.
- `ask <question>` is read-only. Match `ask` before Named and
  before Next. The remainder is the question. Cite the phase ids
  the answer uses. Empty `ask` is **Error:** `ask` needs a
  question. `ask p3` and `ask 3` are questions, not Named and not
  Next. Do not execute. Do not change Status. Do not rewrite or
  reprint the phased plan. Do not start `/plannify`. Do not
  retitle. `Nimages` / `Npass` / `img=` are evidence. No new
  `images` word.
- `guide` is the second word on explain, tldr, or dummy. User-guide
  depth only when every target is blocked or partially blocked.
  Otherwise **Error:** and do not write a file. Mermaid. Web images,
  links, and PDFs only when reuse is allowed (public domain,
  Creative Commons, or an official vendor doc you may link). Do not
  copy those files into the repo. Do not invent pixels. Write
  through docify defaults. Not runblock. No Status change.
- `coach` is its own mode. One blocked or partially blocked phase,
  one instruction at a time. Wait for questions and for the output.
  If the output does not show the step is done, say what is missing
  and wait. Keep a log. After the last step, write the log, print
  the absolute path, print the summary, and offer the log. Then the
  person can `/phasify unblock` or `/phasify runblock`. No Status
  change. Match `coach` before `guide`. `coach N` for N ≥ 2 is
  **Error:** (one phase). `coach 0` is **Error:** (use `coach p0`).
- `todone` / `Ntodone` / `todone pN` / `todone N` print the Todo-depth
  briefing, then set Status `Done`. Do not execute. Do not wait for
  ack. Bare `todone` = next 1 eligible (same as bare `todo`: not
  `Done`, not `Deferred`, not `Def-Blocked`; include `Left`,
  `Blocked`, `Unblocked`, `Progress`, `Planned`, `Not started`).
  `todone N` (N ≥ 1) = next N eligible (like `block N`, **not** named
  PN). Named is only `pN` / `Ntodone` / `pN todone` (and `todone pN`).
  `todone 0` / `0todone` is named P0. Named may todone any status
  except `Done`. Named `Done`: **Error:** cannot todone a completed
  phase (same style as todo-on-Done / block-on-Done). Invalid id:
  same **Error:** as defer. Fewer eligible than requested: todone
  all eligible, say the shortfall, print the table. None eligible:
  say so + table. After each target: print the briefing, then close
  (`Done`; Reason closed by todone or clear). After all targets:
  reprint the table. Parse `todone` / `Ntodone` as Todone, not Todo,
  not `toend`, not `done`.
- `block` / `Nblock` / `block pN` / `block N` update Status only. Do
  not execute. Not `Done` → `Blocked`; `Deferred` → `Def-Blocked`.
  Bare `block` = next 1 eligible; `block N` (N ≥ 1) = next N eligible
  (not named PN); named is only `pN` / `Nblock` / `pN block`. Skip
  already `Blocked` / `Def-Blocked` on bare / `block N`. Named already
  blocked: update Reason if given; do not error. Named `Done`:
  **Error:** cannot block a completed phase. Invalid id: same
  **Error:** as defer. Fewer eligible than requested: block all
  eligible, say the shortfall, print the table. None eligible: say so
  + table. Optional reason like defer; if none, Reason says manually
  blocked. Parse `block` / `Nblock` as Block, not Unblock.
- `unblock` / `Nunblock` / `unblock N` verify then update Status.
  Do not execute the blocked phase or later phases. On passing test:
  `Blocked` → `Unblocked` (like `Left` for Next / Todo; not `Done`);
  `Def-Blocked` → `Deferred` (not `Unblocked`); clear blocker Reason.
  On fail or when a test cannot be confirmed: leave `Blocked` /
  `Def-Blocked`, state evidence, give remaining manual instructions.
  Bare `unblock`: next `Blocked` or `Def-Blocked`. None: say so and
  print the table. Invalid id: same **Error:** as defer. Named phase
  that is neither `Blocked` nor `Def-Blocked`: **Error:** (same
  style). Parse `unblock` / `Nunblock` as Unblock, not Undefer, not
  Todo, not Todone, not Block, not Runblock. Do not mark
  `Unblocked` without a passing test when a test can exist.
- `remove` / `delete` (exact alias) drop work-phase row(s) after
  a **yes/no confirm**. Do not mutate on the proposing turn.
  Bare `remove` = next 1 not-`Done` (include Deferred /
  Def-Blocked / Blocked; skip `Done`). `remove N` / `Nremove` /
  `removeN` / `2remove` (N ≥ 1) = next N not-Done, **not** named
  PN (like `explain N`). Named is `pN` / unique title (`remove
  p3` / `remove Defer - Delete IP`). `remove 0` / `0remove`:
  **Error:** (use `remove p0`). Named may remove `Done`. Never
  target Task / Flags. On yes: drop rows, compact-renumber
  remaining to P0…P(n-1), print table. On no: unchanged table.
  Ambiguous / missing title: **Error:** + table. Same-line yes
  does not skip confirm. A later non-yes/no `/phasify` cancels
  the pending Remove. Parse `remove` / `delete` before `done` /
  `todone` / `toend`. `delete` ≠ `done`. Not
  `/plannify fromhere`.
- Never invent a plan, phases, or workspace resources.
- Do not mark `Done` unless the work landed, **except Todone** (user
  asserts the work; briefing then Status `Done`; no execute; no ack
  wait) **and Runblock** when no remaining automation (short note;
  no Todo briefing; no fake implement).
- Last printed section is the **Phased plan** table in the
  `phase_layout.txt` layout (execute recap / show). **Explain**,
  **dummy**, a tldr phase tell, a tldr question, a dummy question,
  **ask**, **guide**, **coach**, and exact
  **tldr** do not print that table and do not rewrite the plan.
  Original ify Task
  text is the **Task** row (three columns, wrapped) — never a separate
  box, never a spanning cell, never generated plan text. Flags are
  both / one / none per **Capture Task and Flags**. Include **Reason**
  when any phase has a stored reason.
- Every 3-column table line is exactly 89 characters with `│` at 0, 16,
  75, 88.
- Image and pass markers are not phase selectors; acknowledge them first
  when present. Parse per promptify Flag parse order. Flags work in
  all modes; defer/block reasons must not swallow `2pass`.
