# Instruct

### Instruct

Its own mode. Read-only. **No implementation.** **Do not**
change parent Status. Do **not** execute. Do **not** rewrite the
parent phased plan. Not `howto`. Not `coach`. Not `next`. Not
`unblock`. Not `runblock`.

One blocked or partially blocked parent phase. The output is a
mini plan the agent must not execute. Mini-plan ids live only in
that table. They are not rows of the parent `## Phased plan`, so
a later `/phasify next` cannot run `P7-P1`.

**Blocked:** Status `Blocked` or `Def-Blocked`.
**Partially blocked:** same record as howto and coach
(`Progress` / `In progress` with a Reason, or this conversation
stopped that phase on a human step). Any other status is
**Error:**.

Match `pN-next` and `instruct` before Named and before Next.
Bare `next` and bare `pN` stay execute. `pN-next` is not Named
and not Next.

| Text | Effect |
|------|--------|
| `instruct` / `instruct 1` | Build or reprint the mini plan for the **next 1** blocked or partially blocked phase. |
| `instruct pN` / `instruct PN` / `instructpN` / `instructPN` / `pN instruct` / `PNinstruct` | Named: that phase **only if** it is blocked or partially blocked; else **Error:** |
| `instruct N` (N ≥ 2) / `Ninstruct` / `instructN` / `2instruct` / `instruct2` | **Error:** instruct is one phase (use `instruct` or `instruct pN`). Not named PN. Not next N. |
| `instruct 0` / `0instruct` / `instruct0` | **Error:** (use `instruct p0`). Not named P0. |
| `mini` / `instruct next` / `pN-next` / `PN-next` | Submit evidence for the current user substep. Revise the tail if needed. Print the next user instruction. |
| bare `next` / bare `pN` | Not this mode. **Execute.** |

**No plan:** `/plannify` first. Do not invent phases.
**None eligible:** say so. Do not rewrite the parent plan.
Leave the window name (`docs/window_title.md`).
Invalid id, or a named phase that is not blocked and not
partially blocked: **Error:** (same style as invalid unblock).
Do not invent a target. Do not change parent Status.
No Instruct table yet, and the line is `mini`, `instruct next`,
or `pN-next`: **Error:** run `instruct` or `instruct pN` first.

### Mini plan

Recover the parent phase from the current plan (latest
`## Phased plan`, or resumeify `plan.md` — `references/shared.md`).
On `instruct` / `instruct 1` / `instruct pN`, if this conversation
already has an Instruct table for that parent id, reprint it.
Do not rebuild. Do not re-run a Done Agent row. If none exists,
build one.

Emit substeps `PN-P0`, `PN-P1`, … in parent order. Each row has
an actor: **Agent** or **User**. Status is `Done` or
`Not started`.

Leading Agent rows run in that turn. Read-only research only.
Mark them Done. The reply then prints the first User row and
stops. Do not print later user instructions on that turn.

User-row text is a procedure, not an explanation. One action:
where to click or what to run, and a single **Done when** line.
No cause essay. No mermaid. No picture section. No “after you
finish the agent can”. No guide file.

```text
## Instruct — PN — <title>

Parent status: Blocked | Def-Blocked | Progress (partially blocked)

| Id | Actor | Status | Step |
|----|-------|--------|------|
| PN-P0 | Agent | Done | <read-only result> |
| PN-P1 | User | Not started | <one action> |

### Now
<current User action>

**Done when:** <one line>
```

The table is the step list. **Now** is only the current User
row. The table lives in the conversation (latest Instruct table
for that parent id). Do not write it into the parent table.

Cite `docs/window_title.md`. The name uses the parent phase.
Help, exact tldr, and pass do not retitle.

`Npass` > 1: pass 1 is a documented pre-plan of this mini list.
The last pass still stops on the first User row. Not a
whole-table replan.

### Evidence

`mini`, `instruct next`, and `pN-next` take the rest of the line
as evidence (comments, pasted command output, error text).
`mini` and `instruct next` use the latest Instruct table.
`pN-next` uses the table for that parent id.

Strip `Nimages` / `Npass` / `img=` first (promptify Flag parse
order and Named images). Read those images. On an advance, say
what they show in one sentence, then apply the rules below.

- Evidence shows the current user row is done: mark that row
  Done. Do not rewrite earlier rows. Print only the next User
  instruction.
- Evidence shows a failure or a different screen (timeout, wrong
  page, permission error): do not mark the row Done. Insert or
  replace only later Not-started rows. One line naming what
  changed, then the revised mini list, then the new current
  instruction.
- Evidence does not show done or failure: do not advance. One
  line saying what is still missing.

Agent rows reached by an advance run immediately and are not
shown as user instructions. When the last user row is Done, one
line: the parent phase is still blocked; the user can
`/phasify unblock` or `/phasify runblock`. Do not run those.
Do not change parent Status. Do not rewrite the parent table.

### Not these

Howto stays the one-shot full write-up (every step, a mermaid,
no wait). Coach stays the narrative one-step guide (guide
depth, a log, no revised step list). Instruct does not replace
them. `next` and `pN` execute. `unblock` verifies. `runblock`
executes after the user asserts the block is gone. Instruct
does not call them and does not change parent Status.

```text
/phasify instruct
/phasify instruct 1
/phasify instruct p7
/phasify p7 instruct
/phasify mini
/phasify instruct next
/phasify p7-next
/phasify instruct 0
```

`instruct 0` is **Error:** (use `instruct p0`). Bare `next` and
bare `p7` stay execute.

Example shape (not a parent phase; use the real record):
`instruct` on blocked P7 yields `P7-P0` Agent (name the token
page from the phase record), then User rows for login, the menu
path, create, and name. `p7-next 1image …` reads the image, one
sentence on what it shows, then either the next User row or a
revised tail.
