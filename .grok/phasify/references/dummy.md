# Dummy

### Dummy

Read-only / advisory (like Explain / Show). **No implementation.**
**Do not** change Status. Do **not** execute the phase and do
**not** start later phases. This is a **non-technical** tell:
the intent of the phase, then a simple description. Not a
numbered Todo checklist, not Explain’s glossary, and not
Todone / Rundefer / Runblock.

**No commands, paths, or APIs** in a dummy tell. If a fact is
only expressible as a command, path, or API, say what the
person is trying to accomplish and stop there.

**Do not rewrite the phased plan.** Do not reprint it. Do not
change Task, Flags, Description, Status, Reason, or ids. Do not
call `/plannify fromhere`. The tell is the whole reply.

Parse after stripping `Nimages` / `Npass`. Match `dummy` /
`Ndummy` / `dummyN` as this mode — do **not** treat them as
`todo`, `explain`, `todone`, `toend`, `howto`, or `coach`.
**`dummy N` / `dummy 3` / `dummy3` / `3dummy` / `Ndummy` /
`dummyN` / `2dummy` means next N not-Done** (like `explain N`),
**not** named PN. Named dummy is only the `P`/`p` family.
`dummy 0` / `0dummy` / `dummy0` is **Error:** (use `dummy p0`).

`guide` counts only as the **second word** (`dummy guide`,
`dummy guide p3`, `3dummy guide`). Then follow
`references/guide.md`. `guide` is not runblock.

| Text | Effect |
|------|--------|
| `dummy` / `dummy 1` | The **next 1 not-Done** phase in plan order. **Include** `Deferred`, `Def-Blocked`, `Blocked`, `Left`, `Unblocked`, `Progress`, `Planned`, `Not started`. Skip `Done` only. If none (all `Done`), say so. Do not print or rewrite the phased plan. |
| `dummy N` / `dummyN` / `Ndummy` / glued (`dummy3` / `3dummy` / `2dummy`) (N ≥ 1) | The **next N not-Done** phases (same eligibility). |
| `dummy pN` / `dummy PN` / `dummypN` / `dummyPN` / `pNdummy` / `PNdummy` / `pN dummy` | Named: that **table id** (`p0` = P0) **at any Status, including `Done`**. |
| `dummy 0` / `0dummy` / `dummy0` | **Error:** (cannot “next 0”; use `dummy p0`). Not named P0. |

**Parse collision (required):** `dummy 3` ≠ `dummy P3`.
`3dummy` / `dummy3` = next 3; `P3dummy` / `dummyP3` = named P3.
`2dummy` / `dummy2` = next 2, **not** named P2 (unlike `2todo` /
`2block`). `dummy 0` / `0dummy` / `dummy0` is **Error:** (use
`dummy p0`).

Bare `dummy`, `dummy N`, `dummy pN`, and `dummy guide` stay
the phase tell. A remainder that is not a selector and not
`guide` is the question. Answer in everyday language. No
commands, paths, or APIs. If a fact only exists as a command,
a path, or an API, say what the person is trying to accomplish
and stop. Strip `Nimages` / `Npass` / `img=` first. Images are
described only in that plain language. If the source or the
images are missing, say so. Do not invent pixels. Do not
execute. Do not change Status. Do not rewrite or reprint the
phased plan. Do not start `/plannify`. Do not retitle.

**No plan:** `/plannify` first. Do not invent phases.

**Done content** (named `pN` only; count selectors skip `Done`):
what that phase actually landed, from this conversation and
verified files. If the record is thin, say so and quote the
phase description. Do not invent work. Do not change Status.
Do not reprint or rewrite the phased plan. Still no commands,
paths, or APIs.

**Pending content** stays this tell: intent, then a simple
description.

**Blocked list** applies only to `Blocked`, `Def-Blocked`, and
partially blocked (same record as howto: `Progress` /
`In progress` with a Reason, or this conversation stopped that
phase on a human step). Other statuses get **no** unblock list.
On a block, the list is task **names**, spelled out, not enough
to perform them. Still no commands, paths, or APIs.

Invalid id (not a number, negative, higher than last phase,
unknown id): **do not invent a target**. Print **Error:** (same
red/bold style as invalid defer).

Bare `dummy` / `dummy N` when fewer not-Done than requested:
tell all found and say the shortfall. None not-Done: say so.
Do not print or rewrite the phased plan. Do not stop the
sequence on `Blocked` (this mode does not execute).

If `Nimages` is present: acknowledge first, then Dummy. Use
only what the images show, in non-technical language. If
`Npass` > 1: extra pass(es) improve this tell — not a
whole-table replan. The last pass emits the tell.

**Dummy report** (required when a target exists). For each
phase, in plan order:

```text
## Dummy — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status>
**Description:** <phase description from the plan>
**Reason:** <stored reason if any; omit if none>

### Intent
Why this phase exists, in everyday language.

### In plain language
A simple description of the phase. No commands, paths, or APIs.

### What landed
Named Done only. What this conversation and verified files show.
Thin record: say so, then quote the description. Omit on a pending phase.

### To get past this
Blocked, Def-Blocked, or partially blocked only. Omit otherwise.
A short list of task names, spelled out. Not enough to perform them.

### Do not
- Do not execute this phase from this command
- Do not change Status
- Do not print commands, paths, or APIs
- Do not invent work
- Do not rewrite or reprint the phased plan
```

No phase table. No COMPLETED banners. Cite
`docs/window_title.md`: the name uses the phase this tell is
about. None eligible: leave the window name. A dummy question
does not retitle.

```text
/phasify dummy
/phasify dummy 3
/phasify dummy3
/phasify 3dummy
/phasify dummy p1
/phasify dummyP1
/phasify P1dummy
/phasify p1 dummy
/phasify dummy guide
/phasify dummy 0
/phasify dummy why are we doing this
```

`dummy 0` is **Error:** (use `dummy p0`).
