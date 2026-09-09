# Phasify — user reference

Print this file as the response when the user runs `/phasify help`,
`/phasify --help`, or `/phasify /?`. Do not execute, defer, undefer,
rundefer, todo, todone, block, unblock, or show.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/phasify` is **Next**, not this page.

---

## What it does

Execute one or more phases of an existing **plannify** plan. Not a new
planning pass and not a full-plan `/runnify`. Implement only the selected
phase(s).

Need a new plan from current statuses? Use **`/plannify fromhere`**
(plannify skill) — not a phasify mode.

---

## Concepts

Plain-language meanings. Token tables and parse rules follow below.
Agents: this is the user-facing page — keep these definitions in view.

### Deferred phase

A phase with Status **`Deferred`** (or **`Def-Blocked`**) is parked on
purpose. Next, execute (`/phasify` / `next` / Next-N / done / `-N`),
bare todo, bare todone, and bare rundefer-eligibility **skip** it until
you **undefer** or **rundefer**.

This is **not** the same as **Blocked**. Blocked is a hard stop:
execute-next cannot proceed through it. Deferred means “not now” —
later, out of order, or waiting on something that is **not** a hard
blocker.

**Why you’d defer:** run other phases first; come back out of order;
wait without treating the wait as a hard blocker.

**Undefer** (status only — does **not** execute):

- `Deferred` → `Left` (clear the defer Reason)
- `Def-Blocked` → `Blocked` (keep the blocker Reason)

**Rundefer** undefer then immediately executes the just-undeferred
runnable phases (see **Rundefer**). A `Def-Blocked` target becomes
`Blocked` and execute **stops** on it — it does not become runnable.

### Todo

`/phasify todo` prints a **detailed actionable list** for a phase. It
does **not** execute the phase and does **not** change Status.

| Command | List? | Status? | Execute? |
|---------|-------|---------|----------|
| `/phasify todo` | Yes | No change | No |
| `/phasify todone` | Same list | Then `Done` (no ack wait) | No |
| `/phasify` / `next` / named `pN` | No | After work | **Yes** — implement the phase |

Todone means you already did (or are asserting) the work. Execute
(`/phasify` / next) is what actually implements a phase.

### Block

`/phasify block` **manually** sets Status **`Blocked`** (or
**`Def-Blocked`** if the phase was already `Deferred`). That **stops
execute-next**. It is **not** the same as defer: defer parks a phase
so Next skips it; block is a hard stop.

**Unblock** verifies the blocker, then:

- `Blocked` → `Unblocked` (ready like `Left`, not complete)
- `Def-Blocked` → `Deferred` (stay parked; block cleared)

### Addify to plannify (not a phasify mode)

`/addify …` is the **addify** skill, not a phasify mode. When the last
ify in this conversation is **plannify**, addify **appends your text
verbatim** to the previous plannify body and **restarts `/plannify`
from scratch** (new Planning-Kickoff + new plan). It is **not**
`/plannify fromhere`. Old phase statuses are **discarded**.

That is how you **revise the plan text** after a plannify run.

To replan **from current statuses** (keep Done / Deferred /
Def-Blocked and reasons), use **`/plannify fromhere`**. If the last
ify was **phasify**, `/addify` uses that fromhere path (keep statuses;
AskQuestion: Keep new plan vs Continue original).

See HELP **Concepts** here; addify behavior is defined in addify
`SKILL.md` (do not guess a different dispatch).

---

## How to invoke

```text
/phasify                 — Next (one incomplete phase). Not help.
/phasify next            — same as empty
/phasify 0               — named P0
/phasify p3              — named P3 (need p / phase prefix when N ≠ 0)
/phasify 3               — Next-N: next 3 incomplete phases
/phasify done            — Run-to-end (also finish / end / all / close / toend)
/phasify toend           — same as done (also to-end / to end)
/phasify -               — Stop-before-end (also -0 / -N)
/phasify defer [reason]  — Defer next open phase (also Ndefer / defer N)
/phasify undefer         — Undefer next Deferred phase (also Nundefer / undefer N)
/phasify rundefer        — Undefer+execute next Deferred phase (also Nrundefer / rundefer N / rundeferN)
/phasify todo            — Todo next not-done / not-deferred phase (also Ntodo / todo N)
/phasify todone          — Todo+close next eligible phase (also Ntodone / todone pN; todone N = next N)
/phasify block [reason]  — Block next 1 eligible phase (also Nblock / block pN / block N)
/phasify unblock         — Verify next Blocked / Def-Blocked phase (also Nunblock / unblock N)
/phasify show            — print the current table (also refresh)
/phasify help            — this reference (also --help / /?)
/phasify pass            — Pass (Npass) subsection only (also pass help)
```

Parse **after** stripping `Nimages` / `Npass` (see Flags). Any mode may
take optional flags. `-2pass` is a pass flag, not stop-before-end.
Help is **not** a phase selector. `pass` / `pass help` after strip is
Pass help, not a task.

---

## Modes

| Text after `/phasify` | Mode | Runs work? |
|-----------------------|------|------------|
| *(empty)* | **Next** | Yes — next incomplete phase (count = 1) |
| `next`, `run next phase` | **Next** | Yes — same as empty |
| `0`, `p0`, `phase 0`, `run phase p0` | **Named** | Yes — that phase (P0) |
| `pN`, `phase N`, `phase pN`, `run phase pN` | **Named** | Yes — that phase (PN) |
| `3`, `next 3`, `run next 3 phases` | **Next-N** | Yes — next **N ≥ 1** incomplete phases |
| `done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` / `to end` | **Run-to-end** | Yes — every remaining incomplete phase |
| `-` / `-0` / `-N` | **Stop-before-end** | Yes — through 1-based index `C − N` |
| `defer`, `Ndefer`, `defer N` [reason] | **Defer** | No — status only |
| `undefer`, `Nundefer`, `undefer N` | **Undefer** | No — status only (`Left`) |
| `rundefer`, `Nrundefer`, `rundefer N`, `rundeferN` | **Rundefer** | Yes — undefer then execute those phases |
| `todo`, `Ntodo`, `todo N` | **Todo** | No — detailed list only (no Status change) |
| `todone`, `Ntodone`, `todone pN`, `todone N` | **Todone** | No phase work — Todo-depth list, then Status `Done` |
| `block`, `Nblock`, `block pN` [reason] | **Block** | No — Status `Blocked` / `Def-Blocked` only |
| `unblock`, `Nunblock`, `unblock N` | **Unblock** | No phase work — verify, then `Unblocked` or `Deferred` on pass |
| `show` / `refresh` | **Show** | No — print table only |
| `help` / `--help` / `/?` | **Help** | No — print this reference |
| `pass` / `pass help` | **Pass help** | No — print the Pass (`Npass`) section |
| `/plannify fromhere` | **fromhere** | Replan (plannify skill, not phasify) |

**Execute modes** (mutating): Named · Next · Next-N · Run-to-end ·
Stop-before-end · **Rundefer** (undefer then execute). **Defer**,
**Undefer**, **Block**, **Unblock** (on verified pass), and **Todone**
update status only. **Undefer** does **not** execute. **Todone**
also prints a Todo-depth briefing, then sets `Done` (no ack wait).
**Todo**, **Show**, and **Help** are read-only.

---

## Disambiguation

| Token | Means |
|-------|--------|
| Bare `0` | Named **P0** (you cannot run “next 0 phases”) |
| Bare integer `N ≥ 1` | **Next-N** (`/phasify 3` = next 3, **not** P3) |
| Specific phase other than P0 | Require `p` / `phase` (`/phasify p3`) |
| Empty (no selector) | **Next**, never help |
| `-` / `-0` / `-N` (N = 0–9) after flag strip | **Stop-before-end** |
| `-2pass` | Pass flag, **not** stop-before-end |
| `help` / `--help` / `/?` after flag strip | **Help**, do not execute |
| `pass` / `pass help` after flag strip | **Pass help** (Npass subsection), not a task |
| `done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` / `to end` | Run-to-end (case-insensitive) |
| `toend` / `to-end` / `to end` after flag strip | Run-to-end (not empty Next; `to-end` is not `-N`) |

New tokens are words (`done`, `toend`, `defer`, `undefer`, `rundefer`,
`todo`, `todone`, `block`, `unblock`) or a **leading minus** (`-2`),
never something that collides with `2pass`. Match `rundefer` /
`Nrundefer` / `rundeferN` as **Rundefer** first (the token contains
`undefer` / `defer` — do not collapse on `run` / `un` / `defer`).
`rundefer` ≠ `undefer` ≠ `toend` ≠ `todo` ≠ `todone`. **`rundefer N`
/ `Nrundefer` / `rundeferN` / `2rundefer` / `rundefer2` means next N
Deferred / Def-Blocked** (like `block 2` / `todone 2`), **not** named
PN. Named rundefer is only `pN` (`rundefer pN` / `pN rundefer`).
Match `undefer` / `Nundefer` as **Undefer**, not Defer, not Rundefer.
Match `todo` / `Ntodo` as **Todo**, not
`todone`, not `toend`. **`todo N` / `todo 3` means named P3.**
Match `todone` / `Ntodone` as **Todone**, not Todo, not `toend`,
not `done`. **`todone N` / `todone 3` means next N eligible** (like
`block N`), not named PN. Named todone is only `pN` / `Ntodone` /
`pN todone` (and `todone pN`). `todone 0` / `0todone` is named P0.
`todo` ≠ `todone` ≠ `toend` / `to-end` / `done`. Match `block` /
`Nblock` as **Block**, not Unblock. `block N` (N ≥ 1) is **next N
eligible**, not named PN. Named block is only `pN` / `Nblock` /
`pN block`. `2block` = named P2. Match `unblock` / `Nunblock` as
**Unblock**, not Undefer, not Rundefer, not Todo, not Todone, not Block.
`unblock` ≠ `undefer` ≠ `rundefer` ≠ `todo` ≠ `todone` ≠ `block`.

### Parse collisions

| Token | Means | Not |
|-------|--------|-----|
| `todo N` / `todo 3` | Named **P3** | Next-N |
| `todone N` / `todone 3` | **Next N** eligible (like `block N`) | Named PN |
| `block N` / `block 2` | **Next N** eligible | Named PN |
| `rundefer N` / `rundefer 2` / `Nrundefer` / `rundeferN` / `2rundefer` / `rundefer2` | **Next N** Deferred / Def-Blocked, then execute | Named PN |
| `unblock N` / `defer N` / `undefer N` | Named **PN** (table id) | Next-N |
| `Ntodo` / `Ntodone` / `Nblock` / `Ndefer` / `Nundefer` | Named **PN** | Next-N |
| `todone 0` / `0todone` / `block 0` | Named **P0** | “next 0” |
| `2todone` / `2block` / `2todo` / `2undefer` | Named **P2** | Next-2 |
| `2rundefer` / `rundefer2` / `Rundefer2` | **Next 2** deferred + execute | Named P2 |
| `undefer` | **Undefer** (status only) | Defer · rundefer |
| `rundefer` | **Rundefer** (undefer + execute) | Undefer · defer · toend · todo · todone |
| `unblock` | **Unblock** | Block · undefer · rundefer · todo · todone |
| `toend` / `to-end` / `to end` | Run-to-end | Todo · todone · `-N` |
| `-2pass` | **Npass** flag | Stop-before-end `-2` |
| `pass` / `pass help` after strip | **Pass help** | A task · a phase |

`unblock` ≠ `undefer` ≠ `rundefer` ≠ `todo` ≠ `todone` ≠ `block`.
`todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`rundefer` ≠ `undefer` ≠ `toend` ≠ `todo` ≠ `todone`.

---

## Next and Next-N

**Next** = first phase whose Status is not `Done`, not `Deferred`,
and not `Def-Blocked` (`Not started`, `Left`, `Unblocked`,
`In progress` / `Progress`, `Planned`, `Blocked` are eligible).
`Unblocked` is like `Left` (ready to run, not complete). If
`Blocked`, try only if this run can unblock it; otherwise skip and
say so. `Def-Blocked` is **skipped** (deferred) — not “run until
blocked.”

**Next-N:** run the next N incomplete phases, one after another. If
fewer than N remain, run the remainder and say the shortfall.

Skip `Done`, `Deferred`, and `Def-Blocked` unless `--force` /
explicit redo. Named `pN` is an explicit request to run that phase
(even if Deferred / Def-Blocked). Stop the sequence on `Blocked`.
Do **not** stop on `Def-Blocked` — skip it like `Deferred`.

If the named phase does not exist, stop and list real phase ids. If it
is already `Done`, do not redo unless `redo` / `--force`; still print
the closing recap.

---

## Run-to-end

Aliases (case-insensitive): `done`, `finish`, `end`, `all`, `close`,
`toend`, `to-end`, `to end`. After flag strip, remaining body exactly
`toend`, `to-end`, or `to end` selects this mode (not empty Next;
`to-end` is not Stop-before-end). Bare `end` stays Run-to-end.

If `Nimages` is present: acknowledge first, then run. If `Npass` is
present: extra pass(es) apply to this run's remaining phases (not a
whole-table replan).

Run every remaining incomplete phase through the end of the plan.
Last executed phase of the plan gets the full recap.

```text
/phasify done
/phasify finish
/phasify toend
```

---

## Stop-before-end (`-N`)

After stripping flags, `-`, `-0`, or `-N` (N = 0–9) is Stop-before-end.
**`-2pass` is Npass**, not this mode: `/phasify -2` = stop-before-end
N=2; `/phasify -2pass` = Next + `2pass` (unless another selector remains).
If `Nimages` is present: acknowledge first, then run.

Let `C` = work-phase count (not Task / Flags). 1-based index `i` maps
to `P(i−1)` (phase 1 = P0).

- Last **included** 1-based index = `C − N`
- Do not run 1-based phases `> C − N`
- **`N = 0` or bare `-`:** treat as **`N = 1`** (all but the last work phase)

Examples:

| Plan | Token | Runs | Leaves |
|------|-------|------|--------|
| P0–P2 (C = 3) | `-` / `-0` / `-1` | P0, P1 | P2 |
| P0–P5 (C = 6) | `-2` | through P3 (`C−N = 4`) | P4, P5 |

If every remaining incomplete phase is past the cutoff, print the table
and say there is nothing to run. Still skip Deferred / Def-Blocked /
Done inside the window.

```text
/phasify -
/phasify -2
```

---

## Defer

Non-executing. Marks a phase `Deferred` and keeps an optional reason
on that row. If `Nimages` is present: acknowledge first, then Defer.
Strip flags **before** taking the reason (`2pass` is not reason text).

| Text | Effect |
|------|--------|
| `defer` | Defer the **next open** phase. If none, say so — do not invent a target. |
| `Ndefer` / `pN defer` / `defer N` / `defer pN` | Defer that table id (`0` / `p0` = P0) |

Invalid id (not a number, negative, past last phase, unknown): **do not
defer**. Print **Error:** (red HTML `<span>` when the client renders it;
otherwise bold `Error:`).

Optional reason = remainder of the line after the defer token
**and after flag strip** (`defer API freeze`, `2defer waiting on legal`).
`2pass` / `1image` are flags, never reason text. Stored for this plan
and reprinted on every recap/show. Empty reason is allowed.

Future execute modes **skip** `Deferred` and `Def-Blocked` unless the
user explicitly runs that phase (`pN`, `redo`, `--force`).

```text
/phasify defer
/phasify defer API freeze
/phasify 2defer waiting on legal
/phasify defer p1
```

---

## Undefer

Non-executing. Inverse of Defer. Clears `Deferred` so Next / Next-N /
done will pick the phase up again. Parse after stripping `Nimages` /
`Npass`. If `Nimages` is present: acknowledge first, then Undefer.
Match `undefer` / `Nundefer` as this mode — not `defer` /
`Ndefer`.

| Text | Effect |
|------|--------|
| `undefer` | Undefer the **next Deferred** phase in plan order (first status `Deferred` or `Def-Blocked`). If none, say so — do not invent a target. |
| `Nundefer` / `pN undefer` / `undefer N` / `undefer pN` | Undefer that table id (`0` / `p0` = P0) |

If that phase is not `Deferred` and not `Def-Blocked`: **do not change
it**. Print **Error:** (same red/bold style as invalid defer).

Invalid id (not a number, negative, past last phase, unknown): **do not
undefer**. Print the same **Error:** style as invalid defer.

After success:
- `Deferred` → Status `Left`. **Clear** the stored Reason.
- `Def-Blocked` → Status `Blocked` (clear defer, keep the block and
  blocker Reason).

Print the updated table (show-style). Do not execute the phase.

```text
/phasify undefer
/phasify 2undefer
/phasify undefer p1
/phasify p1 undefer
```

---

## Rundefer

**Undefer then execute** those phases in one step — as if `/phasify`
ran after the undefer, but only on the just-undeferred ids. Do **not**
wait for ack. `rundefer` ≠ `undefer` ≠ `toend` ≠ `todo` ≠ `todone`.
Do not collapse on `un` / `defer` / `run`. **`undefer` still only
changes Status** (no execute). **`rundefer` = undefer + execute.**

Parse after stripping `Nimages` / `Npass`. If `Nimages` is present:
acknowledge first, then Rundefer. Match `rundefer` / `Nrundefer` /
`rundeferN` as this mode **first** — the token contains `undefer` /
`defer`. Do **not** treat them as `undefer` / `Nundefer` or `defer` /
`Ndefer`.

| Token | Effect |
|-------|--------|
| `rundefer` | Undefer the **next 1** Deferred or Def-Blocked phase (plan order), then execute it. |
| `rundefer N` / `Nrundefer` / `rundeferN` (N ≥ 1) | Undefer the **next N** Deferred / Def-Blocked phases, then execute them in plan order (like Next-N on those just-undeferred phases). |
| `2rundefer` / `rundefer2` / `Rundefer2` | Same as `rundefer 2` — **next 2** deferred, **not** named P2. |
| `rundefer pN` / `pN rundefer` | Named: that phase **only if** it is `Deferred` or `Def-Blocked`; else **Error:** |

**N means next N deferred, not named PN.** `rundefer 2` = next 2
deferred (like `block 2` / `todone 2`), **not** P2. Named is only
`pN`. `2rundefer` / `rundefer2` / `Rundefer2` = next 2. This differs
from `Nundefer` / `2undefer` / `Nblock` / `2block` (those are named
PN). `rundefer 0` / `0rundefer` is not “next 0” — **Error:** (use
`rundefer p0` to target P0).

**Semantics:**

1. Find targets: next N phases with Status `Deferred` or `Def-Blocked`
   (skip Done, Left, Blocked-without-defer, Unblocked, etc.).
2. If **none**: say so and print the table. Do **not** execute some
   other open phase.
3. If **fewer than N**: undefer+run all found; say the shortfall.
4. **Undefer first** (same transitions as **Undefer**):
   - `Deferred` → `Left` (clear defer Reason)
   - `Def-Blocked` → `Blocked` (keep blocker Reason) — then execute
     **stops** on that phase like any Blocked phase. Do **not** pretend
     it became runnable.
5. **Then execute** the just-undeferred phases that are now `Left` /
   `Unblocked` / runnable, in plan order, as a normal phasify execute
   (Named / Next semantics on those ids). Stop at `Blocked`. Skip if
   somehow still `Deferred`. Print COMPLETED banners / last-of-run
   table per existing execute rules.
6. Do not wait for ack. Nimages ack first if present. `Npass` = multi-pass
   of **this rundefer run** (that mode’s work), not a whole-table replan.

If the first just-undeferred phase is `Blocked` (was `Def-Blocked`):
print the BLOCKED banner and the last-of-run table; do not start later
just-undeferred phases; do not pick some other Left phase that was
never a target.

Invalid named id, or named rundefer of a phase that is neither
`Deferred` nor `Def-Blocked`: **Error:** (same red/bold style as
invalid undefer). Do not execute.

```text
/phasify rundefer
/phasify rundefer 2
/phasify 2rundefer
/phasify rundefer2
/phasify rundefer p1
/phasify p1 rundefer
```

---

## Todo

Read-only / advisory (like Show). **No implementation.** **Do not**
change Status. Do **not** execute the phase and do **not** start
later phases. A detailed actionable list of what that phase requires
— far more than a one-liner.

Parse after stripping `Nimages` / `Npass`. Match `todo` /
`Ntodo` as this mode — not `todone`, `toend`, or `unblock`. Do
not collapse a shared `to` / `todo` prefix with `todone` or
`toend`. `unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.
**`todo N` / `todo 3` means named P3** (not next 3).
**`todone N` / `todone 3` means next N eligible** (like `block N`).

| Text | Effect |
|------|--------|
| `todo` | Detail the **next not-done, not-deferred** phase in plan order (first Status that is not `Done`, not `Deferred`, and not `Def-Blocked`). Include `Left`, `Blocked`, `Unblocked`, `Progress` / in-progress, `Planned`, `Not started`, etc. Skip `Done`, `Deferred`, and `Def-Blocked` (treat `Def-Blocked` as deferred). If none (all `Done`, or only `Deferred` / `Def-Blocked` left), say so and print the current table (show-style). Do not invent a target. |
| `Ntodo` / `pN todo` / `todo N` / `todo pN` | Detail that table id (`0` / `p0` = P0) **no matter the Status except `Done`**. Named todo may todo a `Def-Blocked` phase (not `Done`). |

If that phase is already `Done`: **do not change it**. Print **Error:**
cannot todo a completed phase (same red/bold style as invalid defer).

Invalid id (not a number, negative, past last phase, unknown): **do not
invent a target**. Print the same **Error:** style as invalid defer.

If `Nimages` is present: acknowledge first, then Todo. **Read**
those images when they may explain the work; use only what they
show (never invent APIs/files). If `Npass` > 1: extra pass(es)
improve briefing quality (see Flags) — not a whole-table replan.

**Todo report** (required when a target exists). Be incredibly
detailed and practical. Numbered tasks; mark each **manual / human**
vs **agent**. Cite files, APIs, and commands **only** when known from
this conversation and verified workspace facts — never invent. For
`Blocked` / `Def-Blocked` phases, include **both** the remaining
phase work **and** the blocker / manual-human tasks.

```text
## Todo — PN — <title>

**Phase:** PN — <title>
**Status:** <current Status>
**Description:** <phase description from the plan>

### Why this phase
<why this is next (first not-Done, not-Deferred, not-Def-Blocked) / why named>

### Tasks
1. <manual | agent> — <implementation step; files/APIs/commands when known>
2. …

### Done looks like
<exit criteria the human or later /phasify can verify>

### Do not
- Do not execute this phase from this command
- Do not change Status
- Do not invent files, APIs, or commands

/phasify pN
```

The last line is an optional one-line next-step (`/phasify pN` or
`/phasify next`). Do not print it as if the work already ran.

```text
/phasify todo
/phasify 2todo
/phasify todo p1
/phasify p1 todo
```

---

## Todone

Todo + close. **No implementation.** Print the same detailed
actionable list as **Todo**, then set that phase Status to
**`Done`**. Do **not** wait for user acknowledgement. Using
`todone` means the user already did (or is asserting) the work.
Do **not** execute the phase and do **not** start later phases.

Parse after stripping `Nimages` / `Npass`. Match `todone` /
`Ntodone` as this mode — not `todo` / `Ntodo`, `toend`, or
`done`. Do not collapse a shared `to` / `todo` prefix.
`todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.
**`todo N` / `todo 3` means named P3.** **`todone N` /
`todone 3` means next N eligible** (like `block N`), not named
PN.

| Text | Effect |
|------|--------|
| `todone` | Todo+close the **next 1 eligible** phase (same selection as bare `todo`: first Status that is not `Done`, not `Deferred`, and not `Def-Blocked`). Include `Left`, `Blocked`, `Unblocked`, `Progress` / in-progress, `Planned`, `Not started`. Skip `Done`, `Deferred`, and `Def-Blocked`. If none, say so and print the current table (show-style). Do not invent a target. |
| `todone pN` / `pN todone` / `Ntodone` | Todo+close that table id (`0` / `p0` = P0) **no matter the Status except `Done`**. Named todone may todone a `Deferred` / `Def-Blocked` / `Blocked` / `Left` / etc. phase (not `Done`). |
| `todone N` (bare integer N ≥ 1, not `pN`) | Todo+close the **next N eligible** phases (same eligibility as bare `todone`). |
| `todone 0` / `0todone` | Named P0 (like `block 0` / `0block`). You cannot todone “next 0”. |

**Parse collision:** `todo N` / `todo 3` means named P3. `todone 2` /
`todone N` means **next N**, not phase N. Named todone is only `pN` /
`Ntodone` / `pN todone` (and `todone pN`). `2todone` = named P2
(same family as `Ntodo` / `Ndefer` / `Nblock`).
`todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

If that phase is already `Done`: **do not change it**. Print
**Error:** cannot todone a completed phase (same red/bold style as
invalid defer / todo-on-Done / block-on-Done).

Invalid id (not a number, negative, past last phase, unknown): **do
not invent a target**. Print the same **Error:** style as invalid
defer.

Bare `todone` / `todone N` when fewer eligible than requested:
todone all eligible, say how many were todone'd vs requested, print
the table. None eligible: say so and print the current table.

If `Nimages` is present: acknowledge first, then Todone. **Read**
those images when they may explain the work; use only what they
show (never invent APIs/files). If `Npass` > 1: extra pass(es)
improve briefing quality (see Flags) — not a whole-table replan.

**Report + close** (required when a target exists). For each phase
todone'd, in plan order:

1. Print the **Todo report** (same depth as **Todo**): heading,
   id + title + **status-before**, description, why this phase,
   numbered tasks (manual / agent), done-looks-like. Keep it
   detailed. For `Blocked` / `Def-Blocked` phases, include **both**
   the remaining phase work **and** the blocker / manual-human
   tasks.
2. Then set Status **`Done`**. Clear or update Reason (e.g. closed
   by todone). Do **not** wait for acknowledgement.
3. After **all** targets: reprint the full phase table
   (last-of-run / show-style).

```text
## Todone — PN — <title>

**Phase:** PN — <title>
**Status:** <status-before>
**Description:** <phase description from the plan>

### Why this phase
<why this is next (first not-Done, not-Deferred, not-Def-Blocked) / why named>

### Tasks
1. <manual | agent> — <implementation step; files/APIs/commands when known>
2. …

### Done looks like
<exit criteria the human asserted or a later /phasify show can verify>

### Do not
- Do not execute this phase from this command
- Do not wait for acknowledgement
- Do not invent files, APIs, or commands
```

Then set Status `Done` (Reason: closed by todone, or clear). After
every target in this run, print the aligned table last.

```text
/phasify todone
/phasify 2todone
/phasify todone p1
/phasify p1 todone
/phasify todone 2
/phasify todone 0
```

---

## Block

Non-executing. Manually set phase(s) to `Blocked` (or `Def-Blocked`
if already `Deferred`). Status mutation + table reprint only — like
defer / undefer, **not** a briefing and **not** Unblock. Do **not**
execute the phase.

Parse after stripping `Nimages` / `Npass`. If `Nimages` is
present: acknowledge first, then Block. Strip flags **before**
taking the reason. Match `block` /
`Nblock` as this mode — not `unblock` / `Nunblock`. Do not collapse
a shared `block` suffix or `un` prefix. `unblock` ≠ `undefer` ≠
`todo` ≠ `todone` ≠ `block`.

| Text | Effect |
|------|--------|
| `block` | Manually block the **next 1 eligible** phase (plan order). If none, say so and print the current table (show-style). Do not invent a target. |
| `block pN` / `pN block` / `Nblock` | Manually block that table id (`0` / `p0` = P0). `block 0` / `0block` is named P0. |
| `block N` (bare integer N ≥ 1, not `pN`) | Manually block the **next N eligible** open phases. |

**Parse collision:** `todo N` / `todo 3` means named P3. `block 2` /
`block N` means **next N**, not phase N. Named block is only `pN` /
`Nblock` / `pN block`. `2block` = named P2 (same family as `Ntodo` /
`Ntodone` / `Ndefer`). `unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠
`block`. `block` is not `unblock`.

**Eligible** for bare `block` / `block N`: not `Done`, not already
`Blocked`, not already `Def-Blocked`. Include `Left`, `Unblocked`,
`Progress`, `Planned`, `Not started`, **`Deferred`** (→
`Def-Blocked`). Skip `Done`. Skip already-blocked so `block 2`
blocks two phases that are not yet blocked.

Named can target `Deferred` (→ `Def-Blocked`). Named already
`Blocked` / `Def-Blocked`: update Reason if a reason is given;
stay blocked; do not error.

Named `Done`: **do not change it**. Print **Error:** cannot block a
completed phase (same red/bold style as invalid defer / todo-on-Done).

Invalid id (not a number, negative, past last phase, unknown): **do
not invent a target**. Print the same **Error:** style as invalid
defer.

Bare `block` / `block N` when fewer eligible than requested: block
all eligible, say how many were blocked vs requested, print the
table. None eligible: say so and print the current table.

Optional reason = remainder of the line after the block token
**and after flag strip** (`block waiting on legal`, `2block API freeze`,
`block p3 creds`). `2pass` / `1image` are flags, never reason text.
Stored like defer. If no reason, still block; Reason should state
it was manually blocked (short).

**Status:**
- Not `Deferred` → **`Blocked`**
- `Deferred` → **`Def-Blocked`** in the table Status cell. Canonical
  name **Deferred-Blocked** / **Def-Blocked**. `Deferred-Blocked` is
  16 characters and does not fit the 12-wide Status inner width;
  `Def-Blocked` is 11 and fits (` Def-Blocked`).

```text
/phasify block
/phasify block waiting on legal
/phasify 2block API freeze
/phasify block p3
/phasify block 2
```

---

## Unblock

Status-updating after verification (like Defer / Undefer). **No
implementation of the phase work.** Do **not** execute the blocked
phase and do **not** start later phases. Success means the unblock
*operation* is done — **not** that the phase work is `Done`.

Parse after stripping `Nimages` / `Npass`. Match `unblock` /
`Nunblock` as this mode — not `undefer` / `Nundefer`, `todo` /
`Ntodo`, `todone` / `Ntodone`, or `block` / `Nblock`. Do not treat a shared `un` prefix
or shared `block` suffix as the other mode.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

| Text | Effect |
|------|--------|
| `unblock` | Target the **next** phase whose Status is `Blocked` **or** `Def-Blocked` (plan order). If none, say so and print the current table (show-style). Do not invent a target. |
| `Nunblock` / `pN unblock` / `unblock N` / `unblock pN` | Target that table id (`0` / `p0` = P0) |

If that phase is neither `Blocked` nor `Def-Blocked`: **do not
change it**. Print **Error:** (same red/bold style as invalid defer).

Invalid id (not a number, negative, past last phase, unknown): **do not
invent a target**. Print the same **Error:** style as invalid defer.

If `Nimages` is present: acknowledge first, then Unblock. **Read**
those images when they may explain the blocker; use only what they
show (never invent APIs/files). If `Npass` > 1: extra pass(es)
improve test design / verification (see Flags).

**Verification loop** (required):

1. Identify the target Blocked or Def-Blocked phase.
2. Infer from this conversation + verified workspace what the blocker
   was (facts only; never invent APIs/files).
3. Design the cheapest honest test (API, CLI, file exists, HTTP,
   dashboard-equivalent command already in the repo). If no test is
   possible, say so and do **not** flip Status unless the user
   explicitly asserted the work is done **and** there is nothing to
   test. Prefer leaving `Blocked` / `Def-Blocked` and asking for
   evidence when a test is possible but unrunnable (missing creds).
4. Run the test when tools/creds exist.
5. **Pass:**
   - `Blocked` → set Status to **`Unblocked`**. Treat `Unblocked`
     like `Left` for Next / Todo selection (ready to run, not
     complete). Clear or update Reason so it no longer reads as
     blocked.
   - `Def-Blocked` → set Status back to **`Deferred`** (not
     `Unblocked`); they asked to stay deferred. Clear the blocker
     Reason.
   Print what was verified and the updated table (show-style). Do
   **not** mark the phase `Done`.
6. **Fail** → leave Status **`Blocked`** or **`Def-Blocked`**. State
   the failure with evidence. Give the best remaining manual unblock
   instructions (same depth as the Todo report).

Example (only when these facts are in the conversation): a phase
blocked because an Eleven Labs agent must be deleted manually (no
programmatic delete in the story) — Unblock must check whether that
agent is gone. If still present: do not unblock; explain; leave
`Blocked`.

Display Status string on success: **`Unblocked`** (from `Blocked`)
or **`Deferred`** (from `Def-Blocked`).

```text
/phasify unblock
/phasify 2unblock
/phasify unblock p1
/phasify p1 unblock
```

---

## Show / refresh

Aliases: `show`, `refresh`. **Read-only.** No implementation.
If `Nimages` is present: acknowledge first, then Show.

Print the current aligned table (Task, Flags if present, all phase
statuses). Include Reason if any deferral has one. If no plan, tell
the user to `/plannify` first.

```text
/phasify show
/phasify refresh
```

---

## Flags (`Nimages` / `Npass`) — strip first

Applies to **every** mode. Not phase selectors and not Task wording.
Strip them **before** choosing a mode (same parse as promptify —
do not fork).

**Intent (short):** Flags are optional mid-walk. Prefer setting
images/pass on promptify/plannify **before** `/phasify`. Use on
phasify when a **specific phase** needs visual clarification or a
multi-pass definition/execution.

**Parse order** (each family independently, left to right):

- First **numbered** instance counts: `1image`, `2pass`, `2-pass`,
  `1images`, `N images`, `N-images` (also `1 image`, `1-image`,
  `N pass`)
- Unnumbered `image` / `images` / `pass` / `passes` does **not** count
- Several numbered tokens → first only (not the largest N)
- No numbered instance → that flag is absent
- Strip before Help vs task. Flags are **not** reason text —
  defer/block must not swallow `2pass` as reason
- `-2pass` is a **pass** flag, not stop-before-end

**`Nimages`:** if `scratch.env` exists, run `scripts/cli.sh scratch ls N`
(or `cli.ps1`) and **read those paths**; else workspace `scratch/`
(`*.png` `*.jpg` `*.jpeg` `*.webp` `*.gif` `*.bmp`). Do not create
`scratch/`. Use what they show (blocker evidence, UI state, phase
clarification). Acknowledge first when present (name the source),
then run the chosen mode.

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on the issue under review.
```

**`Npass`:** inherited from promptify — N pipeline passes of **this
mode's work**. Default N = 1 if absent. When N > 1, pass 1 is a
documented pre-plan; passes 2–N use that base. **Npass on a single
phase** is a multi-pass run of **that phase's work** (Todo briefing,
Unblock test, Block/Defer reason, or execute) — not a whole-table
replan (`/plannify fromhere`). Acknowledge after the scratch ack
when both appear.

Examples after strip:

| User text | Mode | Flags |
|-----------|------|--------|
| `/phasify` | Next | none |
| `/phasify 1image` | Next | 1 image |
| `/phasify 3 2images` | Next-3 | 2 images |
| `/phasify help 2images` | Help | (print this page; do not execute) |
| `/phasify -2pass` | Next (pass flag only) | `2pass` |
| `/phasify -2` | Stop-before-end N=2 | none |
| `/phasify toend` | Run-to-end | none |
| `/phasify to-end` | Run-to-end | none |
| `/phasify to end` | Run-to-end | none |
| `/phasify toend 1image` | Run-to-end | 1 image |
| `/phasify p3 2pass` | Named P3 | `2pass` (that phase's work, not whole table) |
| `/phasify next 1images` | Next | 1 image |
| `/phasify todo 1image` | Todo | 1 image |
| `/phasify todone 1image` | Todone | 1 image |
| `/phasify defer 2pass waiting on legal` | Defer next | `2pass`; reason = waiting on legal |
| `/phasify rundefer 1image` | Rundefer | 1 image |
| `/phasify rundefer 2 2pass` | Rundefer next 2 deferred | `2pass` (this rundefer run) |
| `/phasify block 1image` | Block | 1 image |
| `/phasify unblock 1image` | Unblock | 1 image |
| `/phasify show 2pass` | Show | `2pass` |
| `/phasify pass` | Pass help | none (print this Pass section) |
| `/phasify pass help` | Pass help | none |
| `/phasify 2pass pass help` | Pass help | `2pass` (stripped first) |

---

## Pass (`Npass`)

There is **no** `/pass` skill. `Npass` is a shared flag (promptify
**Flag parse order** — do not fork). After flag strip, remaining
body exactly `pass` or `pass help` prints **this section** and
stops. Full reference: `/phasify help`.

**Tokens:** `Npass` / `N-pass` / `N pass` (e.g. `2pass`, `2-pass`,
`2 pass`). First numbered instance left to right. Skip unnumbered
`pass` / `passes`. Default **1** if absent.

**Meaning on phasify:** N pipeline passes of **this invocation's
mode work** (execute, Rundefer undefer+execute, Todo briefing,
Unblock test, Block/Defer reason, Show). Not a phase selector. Not a
whole-table replan
(`/plannify fromhere`). Prefer setting images/pass on
promptify/plannify **before** the walk; use on phasify when a
**specific phase** needs multi-pass definition/execution.

| N | Behavior |
|---|----------|
| **1** | Normal mode once. No pre-plan section. |
| **> 1** | Pass 1 = documented `## Pre-plan (pass 1)` for **this mode**. Passes 2–N use that base. Last pass emits the mode deliverable. |

**`-2pass` is Npass**, not Stop-before-end `-2`. Strip the pass
flag first. Leftover `-2` (no `pass`) is Stop-before-end.
`/phasify -2pass` is Next + `2pass`.

Acknowledge after the scratch ack when both appear. Flags work
in **all** modes. Defer/block reasons must not swallow `2pass`.

```text
/phasify pass
/phasify pass help
/phasify p3 2pass
/phasify -2pass
/promptify pass help
```

---

## Task and Flags in the table

Three columns. No extra box. No spanning cell.

**Task Description** = verbatim original ify request (the words after
promptify / askify / runnify / plannify / debugify / addify). When
the current plan came from `/addify`, Task is the **combined** text
(ancestor body + addify bodies), not generated plan text. Not Intent
Analysis, not the Kickoff/Optimized Prompt, not `## Plan`. Strip
image/pass tokens from Task (they belong in Flags). If the raw request
cannot be recovered: `(original ify text not found)` — do not
substitute the plan.

- Status `Planned` on the **first** Task line only
- Phase blank on first Task line; label `Task` on the next; blank after

**Flags row — both, one, or none:**

| User included | Flags row |
|---------------|-----------|
| Both `Nimages` and `Npass` | Two Description lines (image family, then pass family) |
| Only one of them | One Description line |
| Neither | **Omit** the Flags row |

Each present flag:

`Caught and correctly interpreted <token>. On pass k of N.`

- `<token>` = exact numbered token (`1image`, `2pass`, …)
- **N** = Npass value (default 1 if `Npass` is absent)
- **k** = pass just finished or in progress (`On pass N of N` after the last)
- Phase `Flags` and Status `Understood` on the first Flags line only

This row is not a work phase.

---

## Execute (mutating modes)

All multi-phase runs are **sequential, synchronous, in plan order**.
No parallel / fan-out / background batch.

1. Validate the selected phase(s) against the real workspace.
2. Execute only that phase’s exit criteria.
3. Finish phase x completely (landed or Blocked) **before** x+1.
4. `Done` only if the work **landed**; else `Progress` / `Blocked` /
   `Left`. Remaining unstarted work after a partial run is `Left`.
5. `Blocked` stops the sequence.

Between phases, re-read Task + Flags and confirm the next phase still
serves that goal; if not, stop and say why.

---

## Banners vs last-of-run table

After each finished phase (Done or Blocked), print a single-line
COMPLETED / BLOCKED banner.

| When | What to print |
|------|----------------|
| Mid-run (finished, but not the last phase of **this** run) | Banner **only** — no full table |
| Last phase of this run | Banner **+** full `phase_layout.txt` recap |
| Single-phase Next or named (`0` / `pN`) | Banner + table |

Applies to Next-N, Run-to-end, Stop-before-end, and Rundefer.

---

## Table layout (`phase_layout.txt`)

**Not** a markdown table. Print inside a fenced `text` block. Match
`docs/phase_layout.txt` / this skill’s `phase_layout.txt`.

Every 3-column line is **exactly 89** characters. `│` at columns
0 / 16 / 75 / 88. Status inner width **12** so `Understood` fits.
Spaces, never tabs. Single-line box: `┌┬┐ ├┼┤ └┴┘ │ ─`.

Wrap inside Description only (max 56 content characters after the
leading space).

**Row order:** titles → Task → Flags (if any) → work phases.

**Status words** (must fit in 12 with the leading space):
`Planned` · `Done` · `Left` · `Blocked` · `Unblocked` · `Deferred` ·
`Def-Blocked` · `Progress` · `Understood`. Do **not** write
`In progress`. `Unblocked` is like `Left` for Next / Todo (ready to
run, not complete). `Def-Blocked` is the table spelling of canonical
**Deferred-Blocked** (16 chars; does not fit). `Def-Blocked` is 11
and fits (` Def-Blocked`). Skip `Def-Blocked` like `Deferred` for
Next / bare Todo.

**Reason column:** if any phase has a stored reason, add Reason on
`show` / recap so it is retrievable. Omit the column if no phase has
a reason. 3-column lines stay 89 characters; with Reason, keep every
line the same width.

Closing recap: after the last banner of this run, print only
`## Phased plan` plus the aligned table (last section). Optional
one-line next-step (e.g. `/phasify next`). `show` prints only the
table. `todo` prints the Todo report (or “nothing eligible” + table).
`todone` prints the Todo-depth briefing for each target, sets Status
`Done` (no ack wait), then the full table. Named todone of a `Done`
phase: **Error:** cannot todone a completed phase. `block` prints
the updated table (or “none eligible” / shortfall +
table). Named block of a `Done` phase: **Error:** cannot block a
completed phase. `unblock` prints verification + updated table on
pass, or stays `Blocked` / `Def-Blocked` with evidence + manual
instructions on fail (or “none blocked” + table). `defer` and
`undefer` print **Error:** on invalid id (or undefer of a phase that
is neither `Deferred` nor `Def-Blocked`), otherwise the updated table.
`rundefer` undefer then execute; none deferred: say so + table (do
not execute some other open phase). Named rundefer of a phase that
is neither `Deferred` nor `Def-Blocked`: **Error:**. Last-of-run:
banner + table. A `Def-Blocked` target becomes `Blocked` and stops
execute.

---

## fromhere (not a phasify mode)

`/plannify fromhere` (alias `planify fromhere`) replans from current
statuses — **AskQuestion**: Keep new plan vs Continue original. That
is the **plannify** skill. Phasify does not replan.

---

## Hard rules (short)

- Execute only the selected phase(s). Replan with `/plannify fromhere`.
- Empty `/phasify` is Next. Never print this help for an empty invocation.
- `help` / `--help` / `/?` (after flag strip) prints this page and stops.
  `pass` / `pass help` (after flag strip) prints **Pass (`Npass`)**
  and stops. There is no `/pass` skill.
- Multi-phase runs are sequential and synchronous. Stop on `Blocked`.
  Skip `Def-Blocked` like `Deferred` (do not “run until blocked”).
- Skip `Done` / `Deferred` / `Def-Blocked` unless `--force` / redo /
  named `pN`.
- Mid-run: banner only. Last-of-run: banner + full table.
- Flags (`Nimages` / `Npass`) work in **all** modes. Strip first.
  `-2pass` is Npass, not stop-before-end. Npass on a phase is
  multi-pass of that phase's work, not `/plannify fromhere`.
  Defer/block reasons must not swallow `2pass`.
- `-` / `-0` / `-N` is Stop-before-end. `-2pass` is a pass flag.
- Invalid defer id: do not defer; print **Error:**.
- Invalid undefer id, or undefer of a phase that is neither `Deferred`
  nor `Def-Blocked`: do not change it; print **Error:**. Bare
  `undefer` with no Deferred / Def-Blocked phase: say so. Success:
  `Deferred` → `Left` (clear Reason); `Def-Blocked` → `Blocked` (keep
  blocker Reason). Print the table; do not execute. Parse `undefer` /
  `Nundefer` as Undefer, not Defer, not Rundefer.
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
  **Undefer stays status-only.**
- `show` / `refresh` are read-only.
- `todo` / `Ntodo` / `todo N` are read-only / advisory. Do not
  change Status. Do not execute the phase or later phases. Bare
  `todo` with nothing eligible (all `Done` or only `Deferred` /
  `Def-Blocked` left): say so and print the table. Invalid id: same
  **Error:** as defer. Named todo of a `Done` phase: **Error:** cannot
  todo a completed phase. Named todo may todo a `Def-Blocked` phase.
  Parse `todo` / `Ntodo` as Todo, not `todone`, not `toend`. `todo N`
  means named PN (not next N).
- `todone` / `Ntodone` / `todone pN` / `todone N` print the
  Todo-depth briefing, then set Status `Done`. Do not execute. Do
  not wait for ack. Bare `todone` = next 1 eligible (same as bare
  `todo`: not `Done`, not `Deferred`, not `Def-Blocked`; include
  `Left`, `Blocked`, `Unblocked`, `Progress`, `Planned`, `Not
  started`). `todone N` (N ≥ 1) = next N eligible (like `block N`,
  **not** named PN). Named is only `pN` / `Ntodone` / `pN todone`
  (and `todone pN`). `todone 0` / `0todone` is named P0. Named may
  todone any status except `Done`. Named `Done`: **Error:** cannot
  todone a completed phase. Invalid id: same **Error:** as defer.
  Fewer eligible than requested: todone all eligible, say the
  shortfall, print the table. None eligible: say so + table. Parse
  `todone` / `Ntodone` as Todone, not Todo, not `toend`, not `done`.
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
  Todo, not Todone, not Block. Do not mark `Unblocked` without a
  passing test when a test can exist.
- Never invent a plan, phases, or workspace resources.
- Do not mark `Done` unless the work landed, **except Todone** (user
  asserts the work; briefing then Status `Done`; no execute; no ack
  wait).
- Task row = verbatim original ify text. Flags = both / one / none.
- Every 3-column line is 89 characters with `│` at 0, 16, 75, 88.
- Image and pass markers are not phase selectors. Flags work in
  all modes; acknowledge first when present.

---

## Related

| Command | Role |
|---------|------|
| `/plannify <prompt>` | Create the plan |
| `/plannify fromhere` | Replan from current statuses |
| `/plannify help` | Plannify reference |
| `/promptify pass help` | Canonical Pass (`Npass`) reference |
| `/runnify <prompt>` | Execute a whole optimized task (not phase-scoped) |
| `/addify <text>` | Append `<text>` to the last ify and restart/continue that skill. Last ify **plannify** = restart plannify **from scratch** (revise plan text; discard statuses). Replan from statuses = `/plannify fromhere` (or addify when last is **phasify**). Not a phasify mode. See **Concepts**. |
