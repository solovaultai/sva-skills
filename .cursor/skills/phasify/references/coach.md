# Coach

### Coach

Its own mode. Read-only. **No implementation.** **Do not**
change Status. Do **not** execute. Do **not** reprint or rewrite
the phased plan. Not `runblock`. Not `howto`. Not `guide` (match
`coach` before `guide`).

One blocked or partially blocked phase. One instruction at a
time. The steps are the guide’s steps (read
`references/guide.md` for user-guide depth, the mermaid, and
the reuse bar). Deliver them one at a time. Do not print the
later steps. Do not write the guide file; write the log below.

**Blocked:** Status `Blocked` or `Def-Blocked`.
**Partially blocked:** same record as howto (`Progress` /
`In progress` with a Reason, or this conversation stopped that
phase on a human step). Anything else is not a target.

| Text | Effect |
|------|--------|
| `coach` / `coach 1` | The **next 1** blocked or partially blocked phase. |
| `coach pN` / `coach PN` / `coachpN` / `coachPN` / `pN coach` / `PNcoach` | Named: that phase **only if** it is blocked or partially blocked; else **Error:** |
| `coach N` (N ≥ 2) / `Ncoach` / `coachN` / `2coach` / `coach2` | **Error:** coach is one phase (use `coach` or `coach pN`). Not named PN. Not next N. |
| `coach 0` / `0coach` / `coach0` | **Error:** (use `coach p0`). Not named P0. |
| `coach guide` | **Error:** coach does not take `guide`. |

**No plan:** `/plannify` first. Do not write a file.
**None eligible:** say so. Do not rewrite the plan. Do not write
a file. Leave the window name (`docs/window_title.md`).
Invalid id: **Error:** (same style as invalid unblock). Do not
invent a target. Do not write a file.

### One step

The steps come from the phase record and verified workspace
facts. Same reuse bar as howto and guide: public domain,
Creative Commons, or an official vendor doc you may link. Do
not copy those files into the repo. Do not invent pixels. A
mermaid of the whole path may be named once on the first step;
do not dump every step.

On the first turn, print only step 1. Ask for questions, then
for the output of that step (what the person entered or ran).
Stop and wait.

On a later turn:

- A question: answer it. Stay on this step. Do not advance.
- Output that does not show the step is done: say what is
  missing. Wait. Do not advance.
- Output that shows the step is done: record the verdict. If
  another step remains, print only that next step and wait.
- After the last step is done: print the log summary, write the
  log, print the absolute path, and offer that log. Then the
  person can `/phasify unblock` or `/phasify runblock`. Do not
  run those yourself. Do not change Status.

Keep a short log of each step, what the person entered or ran,
and the verdict (done, or what was missing).

If `Npass` > 1: pass 1 is a documented pre-plan of the step
list. The last pass starts at step 1 and still waits. Not a
whole-table replan. `Nimages`: acknowledge first; use them as
blocker evidence.

Cite `docs/window_title.md`. The name uses the phase this coach
is about.

### Write the log

Cite `docs/docify_contract.md`. One file for this phase. Do not
invent a second path. Do not commit the file. Write it when the
last step is done (or when the person stops the coach). Until
then, keep the log in the conversation.

1. Read the defaults store when it exists:
   `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/docify.env`.
   Use `path`, `format`, and `prefix`.
2. Directory: stored `path` when set. Otherwise
   `/home/ami/src/pytch/pytch-docs/agent/`.
3. The default folder requires the pytch-docs checkout. If that
   checkout is missing: **Error:** pytch-docs not found. Do not
   invent another folder. Do not write. Still print the log
   summary in chat.
4. Format: stored `format` when set. Otherwise markdown (`.md`).
   Follow the contract for txt, docx, and html bytes.
5. Name: generated `CAPS_WITH_UNDERSCORES` from the phase title
   (three to six words). Apply a stored `prefix` to that
   generated name. If the title is empty, the name is
   `COACH_LOG`.
6. Create `agent/` on first use of the default folder.
   Overwrite an existing target. The reply may create or
   overwrite only this resolved file.

```text
## Coach — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status — unchanged>
**Step:** k of K

<one instruction>

Questions, then the output of this step.
```

End of the last step:

```text
## Coach log — PN — <title>

1. <step> — <what the person entered or ran> — <verdict>
2. …

You can `/phasify unblock` or `/phasify runblock`.

**Docify — wrote.**
`<absolute path>`
```

The log in the file is that summary. Offer the log by printing
the absolute path. No phase table. No COMPLETED banner.

```text
/phasify coach
/phasify coach p1
/phasify p1 coach
/phasify coach 0
```

`coach 0` is **Error:** (use `coach p0`).
