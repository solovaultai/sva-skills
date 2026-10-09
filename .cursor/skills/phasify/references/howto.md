# Howto

### Howto

Read-only. **Step-by-step instructions to get past the blocker**
on the next blocked or partially blocked phase. Does not execute.
Does not change Status. Does not mark `Unblocked` or `Done`.
`howto` ≠ `explain` ≠ `unblock` ≠ `runblock` ≠ `todo`.

**Blocked:** Status `Blocked` or `Def-Blocked`.

**Partially blocked:** Status `Progress` (aligned recap) or
`In progress` (markdown table) **and** a blocker is on record.
A blocker is on record when any of these is true:

- the Reason cell names a stop
- the latest run of that phase in this conversation stopped
  because the remainder needs a human step the agent cannot
  finish (reboot, credential, physical action, approval, an
  install that needs the person)

A `Progress` / `In progress` phase with no recorded blocker is
**not** a target. `Left`, `Unblocked`, `Deferred` (no block),
`Not started`, `Planned`, and `Done` are not partially blocked.
`Def-Blocked` is blocked (eligible), not partial.

Parse after stripping `Nimages` / `Npass`. If `Nimages` is
present: acknowledge first, then Howto. **Read** those images
when they may show the blocker; cite only what they show.
Match `howto` / `Nhowto` / `howtoN` as this mode. Do not treat
them as Explain, Unblock, Runblock, or Next-N.

| Text | Effect |
|------|--------|
| `howto` / `howto 1` | Instructions for the **next 1** blocked or partially blocked phase (plan order). |
| `howto N` / `Nhowto` / `howtoN` (N ≥ 1) | The **next N** eligible phases. |
| `2howto` / `howto2` / `Howto2` | Same as `howto 2` — **next 2**, **not** named P2. |
| `howto pN` / `howto PN` / `howtopN` / `howtoPN` / `pN howto` / `PNhowto` | Named: that phase **only if** it is blocked or partially blocked; else **Error:** |
| `howto 0` / `0howto` / `howto0` | **Error:** (cannot "next 0"; use `howto p0`). Not named P0. |

**Parse collision (required):** `howto N` / `Nhowto` / `howtoN` /
`2howto` / `howto2` means **next N eligible**, not named PN
(like `explain N` / `runblock N`). Named howto is only the
`P`/`p` family. `howto 0` / `0howto` / `howto0` is **Error:**
(use `howto p0`).

**No plan:** stop and tell the user to `/plannify` first. Do not
say nothing to do. Do not invent phases.

**None eligible:** print the line below, then reprint the current
aligned phase plan (`phase_layout.txt`, show-style: Task, Flags
if any, every phase, Reason if any). Statuses stay as they are.
That reprint is the rewrite of the phase plan. Do not call
`/plannify fromhere`. Do not invent a target.

```text
**Nothing to do.**
```

**Fewer than N:** write a howto for every eligible phase found,
say the shortfall, then print the table.

Invalid id, or named howto of a phase that is not blocked and
not partially blocked: **do not** invent steps and **do not**
change Status. Print **Error:** (same red/bold style as invalid
unblock) and the table.

**What to write** (one section per target). Start from what
already landed. The steps cover the stuck part only. Take the
blocker from the Reason, the phase text, or the conversation.
Do not invent a cause. If the record only says blocked and names
no cause, the first steps are how to identify the cause from
that record; say the cause is not on record.

```text
## Howto — PN — <title>

Status: Blocked | Def-Blocked | Progress (partially blocked)
Blocker: <one sentence from the record>

### Steps
1. ...

**After you finish, the agent can:** <leftover agent work, if any>

### Pictures
<diagram, and a reusable image when one teaches a step>

### Do not
- Do not execute this phase or later phases
- Do not change Status
- After these steps, /phasify unblock verifies or /phasify runblock continues
```

Numbered steps. One action per step. Concrete for this block:
the command, menu, key, or check, and what done looks like for
that step. If the block is a reboot, the steps are how to reboot
**this** machine safely (save work, restart, confirm the thing
the phase needs is back), using facts from the workspace and the
phase. **After you finish, the agent can:** leftover agent work.
Do not do that work in this mode.

**Pictures (required):**

- Always include one graphic of the path through the block: a
  mermaid flowchart in the reply. Do not add a repo file for it.
  Add another diagram when a step branches or has a check. Treat
  that diagram as the infographic.
- When the host can generate an image, a generated diagram is
  fine for the path. Do not generate a fake screenshot of a
  copyrighted product UI.
- Search the web for a teaching image when a step is a physical
  or on-screen action a diagram cannot show (which key, which
  port, which dialog). Use the image only when the page states
  reuse is allowed (public domain, a Creative Commons license,
  or the publisher explicitly allows reproduction) or it is an
  official vendor document you may link. Under it, one line:
  title, URL, and license. Do not copy the file into the repo.
  Do not use an unlicensed shot, a paywalled manual, or a random
  search thumbnail. If nothing reusable turns up, say so and
  keep the diagram. Do not invent pixels.
- Scratch images and `img` files on this run are evidence of the
  blocker. Read them and cite what they show. They do not replace
  the diagram.

One table after the last target (show-style). No COMPLETED
banners. `Npass` = this howto's instruction quality, not a
whole-table replan. Window title: the target phase
(`docs/window_title.md`). Nothing to do: leave the window name.

Accepted tokens (all of these):

```text
/phasify howto
/phasify howto 1
/phasify howto 2
/phasify 2howto
/phasify howto2
/phasify howto p1
/phasify p1 howto
/phasify howtoP1
/phasify P1howto
```

`2howto` = next 2 eligible, **not** P2. Named is **only** the
`P`/`p` family.

Example shape (use the real blocker, not this text): the Reason
says the phase cannot continue until the machine reboots. The
steps are that reboot, a mermaid of save, restart, then confirm,
and a reusable image of that reboot screen when one exists.

