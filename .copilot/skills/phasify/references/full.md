# Full

`full` runs the rest of the plan, or until `Blocked`, with a partial
compress between phases. `full rundefer` and `rundefer full` do that
same walk and rundefer each `Deferred` phase as the walk reaches it.

This is not Run-to-end. `done` / `finish` / `end` / `all` / `close` /
`toend` / `to-end` / `to end` still run the rest of the plan with no
partial compress.

Cite the optify skill's `references/optify_contract.md` section
**Partial compress**. Do not invent a second clearout.

## Parse

After flag strip. Case-insensitive. Match these before **Rundefer**
and before **Run-to-end**.

| Text | Effect |
|------|--------|
| `full` | Full. Skip `Deferred` and `Def-Blocked`. |
| `full rundefer` / `rundefer full` | Full, and rundefer `Deferred` phases in plan order. |

`full` is one bare token. The only second token is `rundefer`.
`full N`, `Nfull`, `full2`, `2full`, `full pN`, `full 0`, and any
other extra token are **Error:**. `full` is not a count and not a
phase id. `full rundefer` is not named PN and not next-N deferred.

`full` ≠ `toend` ≠ `done` ≠ `all` ≠ `rundefer`.

## Walk

Sequential, plan order. Finish phase x before phase x+1 begins.
No parallel work. Banners and the last-of-run table follow Execute.

**`full`:** same eligible set as Run-to-end. Skip `Done`,
`Deferred`, and `Def-Blocked`. Stop on `Blocked`.

**`full rundefer`:** do not skip `Deferred`. When the walk reaches
a `Deferred` phase, undefer it (`Deferred` → `Left`, clear the
defer Reason) and execute it. When the walk reaches
`Def-Blocked`, undefer it to `Blocked` (keep the blocker Reason)
and stop. Do not execute that phase. An already `Blocked` phase
stops the walk. Skip `Done`. Run `Left`, `Unblocked`,
`Not started`, `In progress`, `Planned`, and a just-undeferred
`Left` phase. Every `Deferred` phase still ahead is included
until the walk stops. This is not bare `rundefer` (next 1 only).

Stop at the end of the plan or on `Blocked`.

## Partial compress

Between phases of this run, after the phase banner, when a full
optimize did not fire on that boundary.

Drop from what the next phase carries:

- the finished phase's command output
- file bodies already read for that phase
- that phase's narrative

Keep:

- Task
- Flags
- phase id and status
- paths touched
- the next phase id

Do not write the handoff. Do not print `/compact`, `/clear`, or
`/new`. Do not stop the turn. Start the next phase in this same
run.

A full optimize still wins. At the start of a phase, armed
`before`, or optify on with a context meter at or above about
70%, is the existing full optimize and stops the turn. At the
end of a phase, armed `after` is that full optimize and stops
the turn after the banner and the status update. Do not also
partial-compress that boundary. Optify off does not turn off
this partial compress. The meter check still runs only while
optify is on.

If `Nimages` is present: acknowledge first, then run. `Npass`
is multi-pass of this Full run, not a whole-table replan.
