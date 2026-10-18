# Explain

### Explain

Read-only / advisory (like Todo / Show). **No implementation.**
**Do not** change Status. Do **not** execute the phase and do
**not** start later phases. This is a **full explanation** of
what the phase is, why it exists, and what its Status means —
not a numbered Todo checklist and not Todone / Rundefer.

**Do not rewrite the phased plan.** Do not reprint it. Do not
change Task, Flags, Description, Status, Reason, or ids. Do not
call `/plannify fromhere`. The explanation is the whole reply.

Parse after stripping `Nimages` / `Npass`. Match `explain` /
`Nexplain` / `explainN` as this mode — do **not** treat them as
`todo`, `todone`, `toend`, `end`, `dummy`, or `rundefer`. Do not
collapse a shared `end` suffix as Run-to-end.
`explain` ≠ `todo` ≠ `todone` ≠ `toend` / `end`.
**`explain N` / `explain 3` / `explain3` / `3explain` /
`Nexplain` / `explainN` / `2explain` means next N not-Done**
(like `rundefer N` / `block N` / `todone N`), **not** named PN
(unlike `Ntodo` / `2todo` / `Nblock` / `2block`). Named explain
is only the `P`/`p` family.

`guide` counts only as the **second word** (`explain guide`,
`explain guide p3`, `3explain guide`). Then follow
`references/guide.md`. `guide` is not runblock. A bare `guide`
token is not this mode.

| Text | Effect |
|------|--------|
| `explain` / `explain 1` | Explain the **next 1 not-Done** phase in plan order. **Include** `Deferred`, `Def-Blocked`, `Blocked`, `Left`, `Unblocked`, `Progress`, `Planned`, `Not started`. Unlike bare todo: do **not** skip Deferred. Skip `Done` only. If none (all `Done`), say so. Do not print or rewrite the phased plan. Do not invent a target. |
| `explain N` / `explainN` / `Nexplain` / glued (`explain3` / `3explain` / `2explain`) (N ≥ 1) | Explain the **next N not-Done** phases (same eligibility as bare `explain`). |
| `explain pN` / `explain PN` / `explainpN` / `explainPN` / `pNexplain` / `PNexplain` / `pN explain` | Named: that **table id** (`p0` = P0) **at any Status, including `Done`**. |
| `explain 0` / `0explain` / `explain0` | **Error:** (cannot “next 0”; use `explain p0`). Not named P0. |

**Parse collision (required):** `explain 3` ≠ `explain P3`.
`3explain` / `explain3` = next 3; `P3explain` / `explainP3` =
named P3. `todo N` stays named PN; `explain N` is next N (like
`block N` / `todone N` / `rundefer N`). `Ntodo` / `Nblock` stay
named PN; `Nexplain` / `explainN` are next N (like `Nrundefer` /
`rundeferN`). `2explain` / `explain2` = next 2, **not** named P2
(unlike `2todo` / `2block` / `2todone`). Named Explain is only
the `P`/`p` family. `explain 0` / `0explain` / `explain0` is
**Error:** (use `explain p0`) — like `rundefer 0`, **not** like
`todone 0` / `0block`.

**Done content** (named `pN` only). Count selectors skip `Done`.
Report what that phase actually landed, from this conversation
and verified files. If the record is thin, say so and quote the
phase description. Do not invent work. Do not change Status.
Do not reprint or rewrite the phased plan. Pending phases keep
the full write-up below (glossary, what, why, TL/DR).

**Blocked list** applies only to `Blocked`, `Def-Blocked`, and
partially blocked (same record as howto: `Progress` /
`In progress` with a Reason, or this conversation stopped that
phase on a human step). Other statuses get **no** unblock list.
At this depth the list is detailed instructions, still only from
the phase record and verified workspace facts.

Invalid id (not a number, negative, higher than last phase,
unknown id): **do not invent a target**. Print the same
**Error:** style as invalid defer.

Bare `explain` / `explain N` when fewer not-Done than requested:
explain all found and say the shortfall. None not-Done: say so.
Do not print or rewrite the phased plan in either case.

**Unlike** execute Next-N: do **not** stop the sequence on
`Blocked`. Explain does not execute; it explains the blocked
phase and continues to the next not-`Done` if N > 1.

If `Nimages` is present: acknowledge first (promptify scratch
ack), then Explain. **Read** those images when they may explain
the work; use only what they show (never invent APIs/files). If
`Npass` > 1: extra pass(es) improve explanation quality (see
**Flags**) — not a whole-table replan. `Npass` = this explain
run. Pass 1 is a documented pre-plan; the last pass emits the
explanations. Each TL/DR is the explanation only.

**Explain report** (required when a target exists and `guide`
is absent). Full write-up, not a numbered Todo checklist. Cite
files, APIs, and commands **only** when known from this
conversation and verified workspace facts — never invent. For
each phase, in plan order:

```text
## Explain — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status>
**Description:** <phase description from the plan>
**Reason:** <stored defer/block reason if any; omit if none>

### What these statuses mean
Plain-language glossary in defer / todo / blocked context (always include
these words, even if the current phase is only one of them):
- Left — still to do; Next will pick it up
- Done — finished; count selectors skip it; named pN reports what landed
- Blocked — hard stop; execute-next cannot proceed
- Deferred — parked on purpose (“not now”); Next / bare todo skip it;
  bare explain does not skip it
- Def-Blocked — deferred and blocked; table spelling of Deferred-Blocked
- Unblocked — blocker cleared; ready like Left, not complete
- Progress — started, not finished (never write “In progress” in the table)
- Planned — Task-row / not-started planning state

Tie the glossary to THIS phase’s Status and Reason (why it is deferred
or blocked, if that is the case).

### What is in this phase
Pending: full explanation of the work — narrative, not a numbered todo checklist.
Named Done: what landed (conversation and verified files). Thin record: say so
and quote the description. Cite files/APIs/commands only when verified. Never invent.

### Why this phase
Why this slice exists / why it is next (first not-Done, including Deferred)
or why it was named.

### How to get past this
Blocked, Def-Blocked, or partially blocked only. Omit otherwise.
Detailed instructions from the phase record and verified workspace facts.
Not a Status change. Not runblock.

### TL/DR
The explanation only. One or two paragraphs in clear non-technical
language: what is in the phase and why. Do not narrate the process
of answering. Do not add a followup, a next command, or any other
information. Mandatory. Last subsection of THIS phase’s write-up
before Do not.

### Do not
- Do not execute this phase from this command
- Do not change Status
- Do not invent files, APIs, or commands
- Do not print a Todo task list (use /phasify todo for that)
- Do not rewrite or reprint the phased plan
```

**Plan stays.** Explain does not rewrite the phased plan and does
not reprint it. TL/DR **ends each phase’s explanation** (last
subsection of that phase, before Do not). If `explain 3` hits
three phases, three TL/DRs, and each TL/DR is only that
explanation. After the last phase’s Do not, stop. No phase table.
No next-step. No rewritten plan. **No COMPLETED banners** for
Explain itself (advisory — nothing executed). Cite
`docs/window_title.md`: the name uses the phase this tell is
about. None eligible: leave the window name.

### Tldr tell (selector required)

Exact `/phasify tldr` with no other token prints
`references/TLDR.md` and stops. That page is not this section.
`tldr help` is not help.

A phase tell needs a selector: `tldr 1`, `tldr N`, `Ntldr`,
`tldrN`, `tldr pN` (also `pN tldr` / `PNtldr`). Same eligibility
as explain: `tldr N` / `Ntldr` / `tldrN` = next N not-Done, not
named PN. Named is only the `P`/`p` family and may be `Done`.
`tldr 0` / `0tldr` / `tldr0` is **Error:** (use `tldr p0`).

**Pending content** at this depth is the explanation only. No
process narration. No followup. **Done content** is what landed
(same rule as explain). **Blocked list:** a numbered list a
capable technologist could infer and carry out, only when the
target is blocked or partially blocked. Other statuses get no
unblock list.

`guide` as the second word (`tldr guide`, `tldr guide p3`)
follows `references/guide.md`. That stays the phase tell.

Any other remainder is the question. Answer in a few direct
sentences. No headings. No process narration. No follow-up.
No “in other words.” Strip `Nimages` / `Npass` / `img=` first.
Images on that line are evidence, then the short answer. If
the source or the images are missing, say so. Do not invent
pixels. Do not execute. Do not change Status. Do not rewrite
or reprint the phased plan. Do not start `/plannify`. Do not
retitle. Exact `tldr` does not retitle. A tldr phase tell uses
the phase it is about.

```text
## Tldr — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status>

<the explanation only, or what landed when named Done>

### To get past this
Blocked, Def-Blocked, or partially blocked only. Omit otherwise.
1. <step a capable technologist could carry out>
```

```text
/phasify explain
/phasify explain 3
/phasify explain3
/phasify 3explain
/phasify explain p1
/phasify explainP1
/phasify P1explain
/phasify p1 explain
/phasify explain guide
/phasify tldr 1
/phasify tldr p3
/phasify 3tldr
/phasify tldr guide p3
/phasify tldr why is this next
```
