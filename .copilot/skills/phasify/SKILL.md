---
name: phasify
description: >-
  Phasify — execute phase(s) of a plannified plan. Empty /phasify =
  next incomplete. Named P0 (0/p0); next N (bare N≥1); done/toend =
  run-to-end; -N = stop-before-end. Modes: defer, undefer, rundefer,
  todo, explain, todone, block, unblock, runblock, remove (delete
  alias), smart, show, help, tldr. Use /phasify pN for a named phase
  that is not P0. Supports Nimages/Npass. /phasify help for the full
  reference.
argument-hint: "[<selector>]"
user-invocable: true
disable-model-invocation: true
---

# Phasify (= execute plannified phase(s))

You are running **Phasify** (`/phasify`) — **execute** one or more phases of
an existing **plannify** plan. This is not a new planning pass and not a
full-plan `/runnify`. Implement only the selected phase(s).

Follow `~/.copilot/skills/promptify/SKILL.md` Hard rules (workspace is source
of truth; never invent files/APIs/tools/DBs) and its **Scratch images**
section. Follow `~/.copilot/skills/plannify/SKILL.md` for phase ids.
Print the recap / between-phase table using **Table layout**
(`phase_layout.txt`) — not a markdown table.

User-facing meanings of **Deferred phase**, **Todo**, **Explain**, **Block**,
**Runblock**, and
**Addify to plannify** live in `references/HELP.md` (**Concepts**),
near the top after “what it does.” Agents follow this SKILL for parse
and behavior; `/phasify help` prints HELP. See HELP **Concepts**.

---

## Flags (`Nimages` / `Npass`)

Applies to **every** phasify mode (Next, Named, Next-N, Run-to-end,
Stop-before-end, Defer, Undefer, Rundefer, Todo, Explain, Todone, Block,
Unblock, Runblock, Remove, Smart, Show, Help). Parse and strip **before** mode dispatch.

**Intent (short):** Flags are optional mid-walk. Prefer setting
images/pass on promptify/plannify **before** `/phasify`. Use on
phasify when a **specific phase** needs visual clarification or a
multi-pass definition/execution.

### Flag parse order

Cite promptify **Flag parse order** — do not fork a different parse.
Read left to right. Each family independently. **First numbered
instance** wins.

- Numbered tokens count: `1image`, `2pass`, `2-pass`, `1images`,
  `N images`, `N-images` (also `Nimage` / `N-image` / `N pass`).
- Skip unnumbered `image` / `images` / `pass` / `passes`.
- Several numbered → first only (not the largest N).
- No numbered instance → that flag is absent.

Strip flags **before** deciding Help vs task (`help` / `--help` /
`/?`) and **before** taking defer/block reason text. Flags are
**not** part of the task wording or reason — `2pass` must not be
swallowed as a defer/block reason.

**`-2pass` is Npass, not Stop-before-end `-2`.** Strip the pass
flag first. Leftover `-2` (no `pass`) is Stop-before-end.

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

### Multi-pass (`Npass`)

Inherited from promptify **Multi-pass**. When **`Npass`** /
**`N-pass`** / **`N pass`** is present (same Flag parse order), take
**N** pipeline passes on **this invocation's mode work**. Default
N = 1 if absent. Not a phase selector and not Task wording.

When **N > 1**, pass 1 is a documented pre-plan only (`## Pre-plan
(pass 1)` — inventories, approach, gaps for **this mode**). Passes
2–N use that base; the last pass produces the mode's deliverable
(execute, Rundefer undefer+execute, Runblock unblock+execute-or-Done,
Todo briefing, Explain
briefing, Unblock test,
Block/Defer reason, Remove target list + confirm, Show table, …).

**Npass on a single phase** is a multi-pass run of **that phase's
work** (definition, clarification, verification, or execute) — not
a re-plan of the whole table. Whole-table replan remains
`/plannify fromhere`. Extra pass(es) are especially for Todo
briefing quality, Explain briefing quality, Unblock test design, Block/Defer reason quality,
or execute / Rundefer / Runblock of a complex / complete phase.

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

---

## Invocation (parse after stripping image and pass tokens)

Parse **after** stripping `Nimages` / `Npass` (promptify Flag parse
order — see **Flags**). Any mode may take optional flags. `-2pass`
is a pass flag, not stop-before-end. Bare `/phasify` stays **Next**.

| User text | Mode | What to run |
|-----------|------|-------------|
| (empty / no selector) | **Next** | The next incomplete phase (count = 1) |
| `0`, `p0`, `phase 0`, `phase p0`, `run phase p0` | **Named** | That specific phase (P0) |
| `pN`, `phase N`, `phase pN`, `run phase pN` | **Named** | That specific phase (PN) |
| `next`, `run next phase` | **Next** | The next incomplete phase (count = 1) |
| `3`, `next 3`, `run next 3 phases` | **Next-N** | The next **N** incomplete phases, **N ≥ 1** |
| `done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` / `to end` | **Run-to-end** | Every remaining incomplete phase through the end of the plan |
| `-` / `-0` / `-N` | **Stop-before-end** | Run through 1-based index `C - N`; do not run phases `> C - N` |
| `defer`, `Ndefer`, `defer N` [reason] | **Defer** | Mark that phase Deferred (optional reason); do not execute |
| `undefer`, `Nundefer`, `undefer N` | **Undefer** | Clear Deferred → `Left`; do not execute |
| `rundefer`, `Nrundefer`, `rundefer N`, `rundeferN` | **Rundefer** | Undefer then execute those Deferred / Def-Blocked phases |
| `todo`, `Ntodo`, `todo N` | **Todo** | Detailed actionable list for that phase (no execute; no Status change) |
| `explain`, `Nexplain`, `explain N`, `explainN` | **Explain** | Full explanation + status glossary + TL/DR (no execute; no Status change) |
| `todone`, `Ntodone`, `todone pN`, `todone N` | **Todone** | Todo-depth list, then Status `Done` (no execute; no ack wait) |
| `block`, `Nblock`, `block pN` [reason] | **Block** | Manually set eligible phase(s) `Blocked` / `Def-Blocked`; do not execute |
| `unblock`, `Nunblock`, `unblock N` | **Unblock** | Verify a Blocked / Def-Blocked phase; on pass `Unblocked` or `Deferred` |
| `runblock`, `Nrunblock`, `runblock N`, `runblockN` | **Runblock** | User-asserted unblock then execute remaining work or mark `Done` |
| `remove`, `Nremove`, `remove N`, `removeN`, `remove pN`, `remove <title>` | **Remove** | Drop work-phase row(s) after yes/no confirm (not execute) |
| `delete` (same shapes as `remove`) | **Remove** | Exact alias of `remove` |
| `smart <prompt>` | **Smart** | Select a mode from the live plan; print preamble; dispatch. Not Next. |
| `show` / `refresh` | **Show** | Print the current table (read-only; no implementation) |
| `help` / `--help` / `/?` | **Help** | Print `references/HELP.md`; do not execute |
| `tldr` | **tldr** | Print `references/TLDR.md`; do not execute. Never a phase id |
| `pass` / `pass help` | **Pass help** | Print the Pass (`Npass`) section; do not execute |
| `/plannify fromhere` | **fromhere** | Replan from current statuses (plannify skill) |

**Disambiguation (required):**

- Bare **`0`** is **named P0** (you cannot run "next 0 phases").
- Bare integer **N ≥ 1** is **next N phases** (`phasify 3` = next 3, not P3).
- To run a specific phase that is not P0, require the **`p` / `phase` prefix**
  (`phasify p3`, `run phase 3`).
- After stripping flags, first token `smart` is **Smart** —
  remainder is the prompt. Not Next. Not implicit on other tokens.
  Empty `smart`: short usage + “smart needs a prompt.” `which` is
  **not** a phasify mode.
- Empty `/phasify` (no selector) is **Next**, not help.
- After stripping flags, if the remaining selector is exactly `help`,
  `--help`, or `/?` (case-insensitive), that is **Help** — print
  `references/HELP.md` and **stop**. Extra tokens after a help trigger
  are ignored. Help is not a phase selector.
- After stripping flags, remaining body exactly `tldr`
  (case-insensitive) is **tldr** — print `references/TLDR.md` and
  **stop**. Extra tokens after `tldr` stay a **task**. There is no
  `tldr help` alias. `tldr` is never a phase id.
- After stripping flags, remaining body exactly `pass` or `pass help`
  (case-insensitive) is **Pass help** — print the **Pass (`Npass`)**
  section of `references/HELP.md` and **stop**. Not a phase selector.
  There is no `/pass` skill.
- After stripping flags, a token that is `-`, `-0`, or `-N` (N = 0–9) is
  **Stop-before-end**, not Next-N.
- `-2pass` is a pass flag, not stop-before-end.
- Bare `3` is still Next-3. New tokens must be words (`done`, `toend`,
  `defer`, `undefer`, `rundefer`, `todo`, `todone`, `explain`, `block`, `unblock`, `runblock`, `remove`, `delete`)
  or a **leading minus** (`-2`), never collide with `2pass`.
- Match **`runblock` / `Nrunblock` / `runblockN`** as **Runblock**
  **first** (the token contains `block` and `run`). Do not collapse
  to `block`, `unblock`, `rundefer`, or Next-N. `runblock` ≠
  `unblock` ≠ `block` ≠ `rundefer`. **`runblock N` / `Nrunblock` /
  `runblockN` / `2runblock` / `runblock2` means next N Blocked /
  Def-Blocked**, then run-or-mark — **not** named PN (unlike
  `Nblock` / `2block` / `Nunblock` / `2unblock`). Named runblock is
  only the `P`/`p` family (`runblock pN` / `pN runblock` /
  `runblockPN` / `PNrunblock`). `runblock 0` / `0runblock` /
  `runblock0` is **Error:** (use `runblock p0`).
- Match **`rundefer` / `Nrundefer` / `rundeferN`** as **Rundefer**
  **first** (the token contains `undefer` / `defer`). Do not collapse
  on `run` / `un` / `defer`. `rundefer` ≠ `undefer` ≠ `toend` ≠
  `todo` ≠ `todone`. **`rundefer N` / `Nrundefer` / `rundeferN` /
  `2rundefer` / `rundefer2` means next N Deferred / Def-Blocked**,
  then execute — **not** named PN (unlike `Nundefer` / `2undefer` /
  `Nblock` / `2block`). Named rundefer is only `pN` (`rundefer pN` /
  `pN rundefer`).
- Match **`undefer` / `Nundefer`** as **Undefer**, not Defer, not
  Rundefer. Do not treat the suffix `defer` inside `undefer` as Defer.
- Match **`todo` / `Ntodo`** as **Todo**, not `todone`, not `toend`, and
  not Unblock. Do not collapse a shared `to` / `todo` prefix with
  `todone` or `toend`.
  **`todo N` / `todo 3` means named P3** (not next 3).
- Match **`todone` / `Ntodone`** as **Todone**, not Todo, not `toend`,
  not `done`. Do not collapse a shared `to` / `todo` prefix.
  **`todone N` / `todone 3` means next N eligible** (like `block N`),
  not named PN. Named todone is only `pN` / `Ntodone` / `pN todone`
  (and `todone pN`). `todone 0` / `0todone` is named P0.
  `todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
- Match **`block` / `Nblock`** as **Block**, not Unblock, not Next-N.
  `block N` (bare integer N ≥ 1) is **next N eligible**, not named PN.
  Named block is only `pN` / `Nblock` / `pN block`. `2block` = named P2
  (same family as `Ntodo` / `Ntodone` / `Ndefer`). Do not treat `block` as
  `unblock` (shared `block` suffix / `un` prefix).
- Match **`unblock` / `Nunblock`** as **Unblock**, not Undefer, not Todo,
  not Todone, not Block. Do not treat a shared `un` prefix or shared
  `block` suffix as the other mode.
  `unblock` ≠ `undefer` ≠ `rundefer` ≠ `runblock` ≠ `todo` ≠ `todone` ≠ `explain` ≠ `block`.
- Match **`explain` / `Nexplain` / `explainN`** as **Explain**, not
  Todo, not Todone, not `toend` / `end`, not Rundefer. Do not
  collapse a shared `end` suffix as Run-to-end.
  **`explain N` / `explain 3` / `explain3` / `3explain` /
  `Nexplain` / `explainN` / `2explain` means next N not-Done**
  (like `rundefer N` / `block N` / `todone N`), **not** named PN
  (unlike `Ntodo` / `2todo` / `Nblock` / `2block`). Named explain
  is only the `P`/`p` family (`explain pN` / `explainP3` /
  `P3explain` / `p3explain` / `p3 explain`). `explain 0` /
  `0explain` / `explain0` is **Error:** (use `explain p0`).
  Bare `explain` includes Deferred / Def-Blocked (unlike bare
  todo). `explain` ≠ `todo` ≠ `todone` ≠ `toend` / `end`.
- Match **`remove` / `Nremove` / `removeN`** and the exact alias
  **`delete` / `Ndelete` / `deleteN`** as **Remove** first. Do not
  collapse `delete` to `done` / `todone` / `toend`. `remove` ≠
  `delete` token-wise (same mode) ≠ `done` ≠ `defer`.
  **`remove N` / `remove 3` / `remove3` / `3remove` / `Nremove` /
  `removeN` / `2remove` means next N not-Done** (like `explain N`
  / `todone N`), **not** named PN (unlike `Ntodo` / `2todo` /
  `Nblock` / `2block`). Named is `pN` / `PN` **or** a unique
  title (`remove p3` / `remove P3` / `remove Defer - Delete IP`).
  `remove 0` / `0remove` / `remove0` (and the `delete` spellings):
  **Error:** (use `remove p0`). Bare `remove` includes Deferred /
  Def-Blocked (unlike bare todo). Always **yes/no confirm** before
  dropping rows. `delete` is not a second mode.
- `done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` /
  `to end` are case-insensitive **Run-to-end** aliases. After flag
  strip, remaining body exactly `toend`, `to-end`, or `to end` is
  Run-to-end (not empty Next). `to-end` is not Stop-before-end (no
  leading minus). Bare `end` stays Run-to-end.

If there is no selector after `/phasify`, treat the empty invocation as
**Next** mode (count = 1) — same as `next` / `run next phase`. Do not
print a help/usage block. Strip image/pass tokens before this parse, so
`/phasify 1image` is still Next + 1 image, and `/phasify` with nothing
is Next.

### Help (`help` / `--help` / `/?` / `tldr`)

Strip image/pass tokens first. Then:

- Remaining selector exactly `help`, `--help`, or `/?`
  (case-insensitive): **read and print** `references/HELP.md` (this
  skill folder) and **stop**.
- Remaining selector exactly `tldr` (case-insensitive): **read and
  print** `references/TLDR.md` (this skill folder) and **stop**.
  Extra tokens after `tldr` stay a **task**. There is no `tldr
  help` alias. `tldr` is never a phase id.
- Remaining selector exactly `pass` or `pass help`
  (case-insensitive): print the **Pass (`Npass`)** section of that
  file and **stop**. There is no `/pass` skill.

Do not execute, defer, undefer, rundefer, todo, todone, explain, block, unblock,
runblock, remove, delete, or show. Do not invent extra modes. Help and `tldr` are not
phase selectors. Empty `/phasify` is **Next**, not Help.

**Mode dispatch:** Named / Next / Next-N / Run-to-end / Stop-before-end /
**Rundefer** / **Runblock** are **execute** modes (mutating).
**Rundefer** undefer then execute (single step). **Runblock**
unblock then execute-or-mark-Done (single step). **Defer**,
**Undefer**, **Block**, **Unblock** (on verified pass), and
**Todone** update status only (no implementation). **Undefer**
does **not** execute. **Todone** also prints a Todo-depth briefing,
then sets Status `Done` (no ack wait). **Remove** (`delete`
alias) drops work-phase row(s) after a **yes/no confirm** (plan
mutation; no implementation). **Todo**, **Explain**,
**Show**, **Help**, and **tldr** are read-only (no implementation). Handle
Defer, Undefer, Todo, Explain, Todone, Block, Unblock, Remove, Show, and
Help without entering Execute. Handle Rundefer as
undefer-then-Execute (do not treat it as status-only). Handle
Runblock as unblock-then-Execute-or-Done (do not treat it as
Unblock / status-only). **Smart** is a router: preamble then
dispatch the selected mode (not an execute dialect of its own).

### Smart (`smart <prompt>`)

Cite `docs/smart_contract.md`. Decision table + frozen EX-1/2/3:
`references/SMART.md`. Thin dispatch only.

After flag strip, first token `smart` (case-insensitive) is this
mode. Remainder is the prompt. **Not** Next. **Not** implicit on
other tokens. `which` is not a phasify mode.

1. Empty `smart`: short usage + “smart needs a prompt.” Stop.
2. Recover the current plan (same locate-plan rules). No plan →
   **Error:** `/plannify` first. No dispatch.
3. Live-resolve the prompt against the current table
   (`references/SMART.md`). Ambiguity → **Error:** + current
   table. No dispatch.
4. Print the family preamble (after scratch / Npass acks).
5. **Dispatch** the selected invocation as if the user typed it.
   No ack. Do not implement runblock here — only select it.

### Run-to-end

One mode. Aliases (case-insensitive): `done`, `finish`, `end`, `all`,
`close`, `toend`, `to-end`, `to end`. After flag strip, remaining body
exactly `toend`, `to-end`, or `to end` selects this mode (not empty
Next; `to-end` is not `-N`).

If `Nimages` is present: acknowledge first (see **Flags**), then run.
If `Npass` is present: extra pass(es) apply to this run's remaining
phases (not a whole-table replan).

Run every remaining incomplete phase through the end of the plan. Last
executed phase of the plan gets the full recap.

### Stop-before-end (`-N`)

After stripping flags, a token that is `-`, `-0`, or `-N` (N = 0–9) is
**Stop-before-end**, not Next-N. **`-2pass` is Npass**, not this
mode — `/phasify -2` stops before the last 2 work phases;
`/phasify -2pass` is Next + `2pass` (unless another selector remains).
If `Nimages` is present: acknowledge first, then run.

Let `C` = work-phase count (not Task/Flags). 1-based index `i` maps to
`P(i-1)` (so phase 1 = P0).

- Last **included** 1-based index = `C - N`
- Do not run 1-based phases `> C - N`
- **`N = 0` or bare `-`:** treat as **`N = 1`** (run all but the last phase)

Examples:

- 3 phases (P0–P2), `-` / `-0` / `-1`: run 1 and 2 (P0, P1); leave P2
- 6 phases (P0–P5), `-2`: `C - N = 4` → run through P3; do not run P4 or P5 (“up to but not including” 1-based phase 5)

If every remaining incomplete phase is past that cutoff, print the table
and say there is nothing to run. Still skip Deferred / Def-Blocked /
Done inside the allowed window.

### Defer

Non-executing. Update the current plan’s status and keep the reason on
that row. If `Nimages` is present: acknowledge first (see **Flags**),
then Defer. Strip flags **before** taking the reason.

| Text | Effect |
|------|--------|
| `defer` | Defer the **next open** phase (same “next incomplete” rule). If none, say so — do not invent a target. |
| `Ndefer` / `pN defer` / `defer N` / `defer pN` | Defer that **table id** (`0`/`p0` = P0). |

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not defer**. Print a clear **Error:** line (red via HTML
`<span style="color:red">` when the client will render it; otherwise
bold `Error:`).

Optional reason: remainder of the line after the defer token
**and after flag strip** (`defer API freeze` / `2defer waiting on legal`).
`2pass` / `1image` are flags, never reason text. Store on the phase
permanently for this plan (reprint on every recap/show). Empty reason
is allowed.

Future execute modes **skip** `Deferred` and `Def-Blocked` unless the
user explicitly says to run that phase (`pN`, `redo`, `--force`).

### Undefer

Non-executing. Inverse of Defer. Clear `Deferred` so Next / Next-N /
done will pick the phase up again. Parse after stripping `Nimages` /
`Npass`. If `Nimages` is present: acknowledge first, then Undefer.
Match `undefer` / `Nundefer` as this mode — do **not** treat
them as `defer` / `Ndefer`.

| Text | Effect |
|------|--------|
| `undefer` | Undefer the **next Deferred** phase in plan order (first status `Deferred` or `Def-Blocked`). If none, say so — do not invent a target. |
| `Nundefer` / `pN undefer` / `undefer N` / `undefer pN` | Undefer that **table id** (`0`/`p0` = P0). |

If that phase is not `Deferred` and not `Def-Blocked`: **do not change
it**. Print a clear **Error:** line (same red/bold style as invalid
defer).

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not undefer**. Print the same **Error:** style as invalid defer.

After success:
- `Deferred` → Status `Left`. **Clear** the stored Reason so `show` no
  longer lists it as deferred-with-reason.
- `Def-Blocked` → Status `Blocked` (clear defer, keep the block). Keep
  the blocker Reason.

Print the updated table (show-style). Do not execute the phase.

### Rundefer

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

| Text | Effect |
|------|--------|
| `rundefer` | Undefer the **next 1** Deferred or Def-Blocked phase (plan order), then execute it. |
| `rundefer N` / `Nrundefer` / `rundeferN` (N ≥ 1) | Undefer the **next N** Deferred / Def-Blocked phases, then execute them in plan order (like Next-N on those just-undeferred phases). |
| `2rundefer` / `rundefer2` / `Rundefer2` | Same as `rundefer 2` — **next 2** deferred, **not** named P2. |
| `rundefer pN` / `pN rundefer` | Named: that phase **only if** it is `Deferred` or `Def-Blocked`; else **Error:** |

**Parse collision (required):** `rundefer N` / `Nrundefer` / `rundeferN`
/ `2rundefer` / `rundefer2` means **next N deferred**, not named PN
(like `block 2` / `todone 2` — and **unlike** `Nundefer` / `2undefer` /
`Nblock` / `2block`, which are named PN). Named rundefer is only `pN`.
`rundefer 0` / `0rundefer` is not “next 0” — **Error:** (use
`rundefer p0` to target P0). `rundefer` ≠ `undefer` ≠ `toend` ≠
`todo` ≠ `todone`.

**Semantics:**

1. Find targets: next N phases with Status `Deferred` or `Def-Blocked`
   (skip Done, Left, Blocked-without-defer, Unblocked, Progress,
   Planned, Not started, etc.).
2. If **none**: say so and print the table (show-style). Do **not**
   execute some other open phase.
3. If **fewer than N**: undefer+run all found; say the shortfall.
4. **Undefer first** (same transitions as **Undefer** — do not change
   Undefer’s no-execute behavior):
   - `Deferred` → `Left` (clear defer Reason)
   - `Def-Blocked` → `Blocked` (keep blocker Reason) — then execute
     **stops** on that phase like any Blocked phase. Do **not** pretend
     it became runnable.
5. **Then execute** the just-undeferred phases that are now `Left` /
   `Unblocked` / runnable, in plan order, as a normal phasify execute
   (Named / Next semantics on those ids). Stop at `Blocked`. Skip if
   somehow still `Deferred`. Print COMPLETED / BLOCKED banners and the
   last-of-run table per **Execute** / **Phase COMPLETED banner**.
6. Do not wait for ack. Nimages ack first if present. `Npass` = multi-pass
   of **this rundefer run** (that mode’s work), not a whole-table replan.

If the first just-undeferred phase is `Blocked` (was `Def-Blocked`):
print the BLOCKED banner and the last-of-run table; do not start later
just-undeferred phases; do not pick some other Left phase that was
never a target.

Invalid named id, or named rundefer of a phase that is neither
`Deferred` nor `Def-Blocked`: **do not change it** and **do not
execute**. Print a clear **Error:** line (same red/bold style as
invalid undefer).

### Todo

Read-only / advisory (like Show). **No implementation.** **Do not**
change Status. Do **not** execute the phase and do **not** start
later phases. This is a detailed actionable list of what that phase
requires — far more than a one-liner.

Parse after stripping `Nimages` / `Npass`. Match `todo` /
`Ntodo` as this mode — do **not** treat them as `todone`,
`toend`, or `unblock`. Do not collapse a shared `to` / `todo`
prefix with `todone` or `toend`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.
**`todo N` / `todo 3` means named P3** (not next 3).
**`todone N` / `todone 3` means next N eligible** (like `block N`).

| Text | Effect |
|------|--------|
| `todo` | Detail the **next not-done, not-deferred** phase in plan order (first Status that is not `Done`, not `Deferred`, and not `Def-Blocked`). Include `Left`, `Blocked`, `Unblocked`, `Progress` / in-progress, `Planned`, `Not started`, etc. Skip `Done`, `Deferred`, and `Def-Blocked` (treat `Def-Blocked` as deferred). If none (all `Done`, or only `Deferred` / `Def-Blocked` left), say so and print the current table (show-style). Do not invent a target. |
| `Ntodo` / `pN todo` / `todo N` / `todo pN` | Detail that **table id** (`0`/`p0` = P0) **no matter the Status except `Done`**. Named todo may todo a `Def-Blocked` phase (not `Done`). |

If that phase is already `Done`: **do not change it**. Print a clear
**Error:** line (same red/bold style as invalid defer): cannot todo a
completed phase.

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not invent a target**. Print the same **Error:** style as invalid
defer.

If `Nimages` is present: acknowledge first (promptify scratch ack),
then Todo. **Read** those images when they may explain the work; use
only what they show (never invent APIs/files). If `Npass` > 1: extra
pass(es) improve briefing quality (see **Flags**) — not a whole-table
replan.

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

### Explain

Read-only / advisory (like Todo / Show). **No implementation.**
**Do not** change Status. Do **not** execute the phase and do
**not** start later phases. This is a **full explanation** of
what the phase is, why it exists, and what its Status means —
not a numbered Todo checklist and not Todone / Rundefer.

Parse after stripping `Nimages` / `Npass`. Match `explain` /
`Nexplain` / `explainN` as this mode — do **not** treat them as
`todo`, `todone`, `toend`, `end`, or `rundefer`. Do not collapse
a shared `end` suffix as Run-to-end.
`explain` ≠ `todo` ≠ `todone` ≠ `toend` / `end`.
**`explain N` / `explain 3` / `explain3` / `3explain` /
`Nexplain` / `explainN` / `2explain` means next N not-Done**
(like `rundefer N` / `block N` / `todone N`), **not** named PN
(unlike `todo N` / `Ntodo` / `2todo` / `Nblock` / `2block`).
Named explain is only the `P`/`p` family.

| Text | Effect |
|------|--------|
| `explain` / `explain 1` | Explain the **next 1 not-Done** phase in plan order. **Include** `Deferred`, `Def-Blocked`, `Blocked`, `Left`, `Unblocked`, `Progress`, `Planned`, `Not started`. Unlike bare todo: do **not** skip Deferred. Skip `Done` only. If none (all `Done`), say so and print the current table (show-style). Do not invent a target. |
| `explain N` / `explainN` / `Nexplain` / glued (`explain3` / `3explain` / `2explain`) (N ≥ 1) | Explain the **next N not-Done** phases (same eligibility as bare `explain`). |
| `explain pN` / `explain PN` / `explainpN` / `explainPN` / `pNexplain` / `PNexplain` / `pN explain` | Named: that **table id** (`p0` = P0) **no matter the Status except `Done`**. |
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

If that phase is already `Done`: **do not change it**. Print a
clear **Error:** line (same red/bold style as invalid defer /
todo-on-Done / block-on-Done): cannot explain a completed phase.

Invalid id (not a number, negative, higher than last phase,
unknown id): **do not invent a target**. Print the same
**Error:** style as invalid defer.

Bare `explain` / `explain N` when fewer not-Done than requested:
explain all found, say the shortfall, print the table. None
not-Done: say so and print the current table.

**Unlike** execute Next-N: do **not** stop the sequence on
`Blocked`. Explain does not execute; it explains the blocked
phase and continues to the next not-`Done` if N > 1.

If `Nimages` is present: acknowledge first (promptify scratch
ack), then Explain. **Read** those images when they may explain
the work; use only what they show (never invent APIs/files). If
`Npass` > 1: extra pass(es) improve explanation quality (see
**Flags**) — not a whole-table replan. `Npass` = this explain
run. Pass 1 is a documented pre-plan; the last pass emits the
explanations + TL/DRs + table.

**Explain report** (required when a target exists). Full
write-up, not a numbered Todo checklist. Cite files, APIs, and
commands **only** when known from this conversation and verified
workspace facts — never invent. For each phase, in plan order:

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
- Done — finished; Explain will not target it (named Done = Error)
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
Full explanation of the work — narrative, not a numbered todo checklist.
Cite files/APIs/commands only when verified. Never invent.

### Why this phase
Why this slice exists / why it is next (first not-Done, including Deferred)
or why it was named.

### TL/DR
One or two paragraphs. Clear non-technical language: what is in the
phase and why. Mandatory. Last subsection of THIS phase’s write-up
before Do not.

### Do not
- Do not execute this phase from this command
- Do not change Status
- Do not invent files, APIs, or commands
- Do not print a Todo task list (use /phasify todo for that)
```

**TL/DR vs table:** TL/DR **ends each phase’s explanation** (last
subsection of that phase, before Do not). If `explain 3` hits
three phases, three TL/DRs. After **all** explanations, print the
aligned 89-char `phase_layout.txt` table as the **last printed
item** of the whole response (optional one-line next-step only,
e.g. `/phasify todo` or `/phasify pN`). Do not put the table
between phases. **No COMPLETED banners** for Explain itself
(advisory — nothing executed).

```text
/phasify explain
/phasify explain 3
/phasify explain3
/phasify 3explain
/phasify explain p1
/phasify explainP1
/phasify P1explain
/phasify p1 explain
```

### Todone

Todo + close. **No implementation.** Print the same detailed
actionable list as **Todo**, then set that phase Status to
**`Done`**. Do **not** wait for user acknowledgement. Using
`todone` means the user already did (or is asserting) the work.
Do **not** execute the phase and do **not** start later phases.

Parse after stripping `Nimages` / `Npass`. Match `todone` /
`Ntodone` as this mode — do **not** treat them as `todo` /
`Ntodo`, `toend`, or `done`. Do not collapse a shared `to` /
`todo` prefix. `todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.
**`todo N` / `todo 3` means named P3.** **`todone N` /
`todone 3` means next N eligible** (like `block N`), not named
PN.

| Text | Effect |
|------|--------|
| `todone` | Todo+close the **next 1 eligible** phase (same selection as bare `todo`: first Status that is not `Done`, not `Deferred`, and not `Def-Blocked`). Include `Left`, `Blocked`, `Unblocked`, `Progress` / in-progress, `Planned`, `Not started`. Skip `Done`, `Deferred`, and `Def-Blocked`. If none, say so and print the current table (show-style). Do not invent a target. |
| `todone pN` / `pN todone` / `Ntodone` | Todo+close that **table id** (`0`/`p0` = P0) **no matter the Status except `Done`**. Named todone may todone a `Deferred` / `Def-Blocked` / `Blocked` / `Left` / etc. phase (not `Done`). |
| `todone N` (bare integer N ≥ 1, not `pN`) | Todo+close the **next N eligible** phases (same eligibility as bare `todone`). |
| `todone 0` / `0todone` | Named P0 (like `block 0` / `0block`). You cannot todone “next 0”. |

**Parse collision (required):** `todo N` / `todo 3` means named P3.
`todone 2` / `todone N` means **next N**, not phase N. Named todone
is only `pN` / `Ntodone` / `pN todone` (and `todone pN`).
`2todone` = named P2 (same family as `Ntodo` / `Ndefer` / `Nblock`).
`todo` ≠ `todone` ≠ `toend` / `to-end` / `done`.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

If that phase is already `Done`: **do not change it**. Print a clear
**Error:** line (same red/bold style as invalid defer / todo-on-Done /
block-on-Done): cannot todone a completed phase.

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not invent a target**. Print the same **Error:** style as invalid
defer.

Bare `todone` / `todone N` when fewer eligible than requested: todone
all eligible, say how many were todone'd vs requested, print the
table. None eligible: say so and print the current table.

If `Nimages` is present: acknowledge first (promptify scratch ack),
then Todone. **Read** those images when they may explain the work; use
only what they show (never invent APIs/files). If `Npass` > 1: extra
pass(es) improve briefing quality (see **Flags**) — not a whole-table
replan.

**Report + close** (required when a target exists). For each phase
todone'd, in plan order:

1. Print the **Todo report** (same depth as **Todo**): heading,
   id + title + **status-before**, description, why this phase,
   numbered tasks (manual / agent), done-looks-like. Keep it
   detailed. For `Blocked` / `Def-Blocked` phases, include **both**
   the remaining phase work **and** the blocker / manual-human
   tasks. Cite files, APIs, and commands **only** when known from
   this conversation and verified workspace facts — never invent.
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

### Block

Non-executing. Manually set phase(s) to `Blocked` (or `Def-Blocked`
if already `Deferred`). Status mutation + table reprint only — like
defer / undefer, **not** a briefing and **not** Unblock. Do **not**
execute the phase.

Parse after stripping `Nimages` / `Npass`. If `Nimages` is
present: acknowledge first, then Block. Strip flags **before**
taking the reason. Match `block` /
`Nblock` as this mode — do **not** treat them as `unblock` /
`Nunblock`. Do not collapse a shared `block` suffix or `un`
prefix. `unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

| Text | Effect |
|------|--------|
| `block` | Manually block the **next 1 eligible** phase (plan order). If none, say so and print the current table (show-style). Do not invent a target. |
| `block pN` / `pN block` / `Nblock` | Manually block that **table id** (`0`/`p0` = P0). `block 0` / `0block` is named P0 (you cannot block “next 0”). |
| `block N` (bare integer N ≥ 1, not `pN`) | Manually block the **next N eligible** open phases. |

**Parse collision (required):** `todo N` / `todo 3` means named P3.
`block 2` / `block N` means **next N**, not phase N. Named block is
only `pN` / `Nblock` / `pN block`. `2block` = named P2 (same family
as `Ntodo` / `Ntodone` / `Ndefer`). `unblock` ≠ `undefer` ≠
`todo` ≠ `todone` ≠ `block`. `block` is not `unblock`.

**Eligible** for bare `block` / `block N`: not `Done`, not already
`Blocked`, not already `Def-Blocked`. Include `Left`, `Unblocked`,
`Progress`, `Planned`, `Not started`, **`Deferred`** (→
`Def-Blocked`). Skip `Done`. Skip already-blocked so `block 2`
blocks two phases that are not yet blocked.

Named can target `Deferred` (→ `Def-Blocked`). Named already
`Blocked` / `Def-Blocked`: update Reason if a reason is given;
stay blocked; do not error.

Named `Done`: **do not change it**. Print a clear **Error:** line
(same red/bold style as invalid defer / todo-on-Done): cannot
block a completed phase.

Invalid id (not a number, negative, higher than last phase, unknown
id): **do not invent a target**. Print the same **Error:** style as
invalid defer.

Bare `block` / `block N` when fewer eligible than requested: block
all eligible, say how many were blocked vs requested, print the
table. None eligible: say so and print the current table.

Optional reason: remainder of the line after the block token
**and after flag strip** (`block waiting on legal` / `2block API freeze`
/ `block p3 creds`). `2pass` / `1image` are flags, never reason text.
Store on the phase (like defer). If no reason, still block; Reason
should state it was manually blocked (short).

**Status:**
- Not `Deferred` → **`Blocked`**
- `Deferred` → **`Def-Blocked`** in the table Status cell. Canonical
  name **Deferred-Blocked** / **Def-Blocked**. `Deferred-Blocked` is
  16 characters and does not fit the 12-wide Status inner width;
  `Def-Blocked` is 11 and fits (` Def-Blocked`).

Do not execute the phase.

### Unblock

Status-updating after verification (like Defer / Undefer). **No
implementation of the phase work.** Do **not** execute the blocked
phase and do **not** start later phases. Success means the unblock
*operation* is done — **not** that the phase work is `Done`.

Parse after stripping `Nimages` / `Npass`. Match `unblock` /
`Nunblock` as this mode — do **not** treat them as `undefer` /
`Nundefer`, `todo` / `Ntodo`, `todone` / `Ntodone`, or `block` /
`Nblock`. Do not treat a shared `un` prefix or shared `block`
suffix as the other mode.
`unblock` ≠ `undefer` ≠ `todo` ≠ `todone` ≠ `block`.

| Text | Effect |
|------|--------|
| `unblock` | Target the **next** phase whose Status is `Blocked` **or** `Def-Blocked` (plan order). If none, say so and print the current table (show-style). Do not invent a target. |
| `Nunblock` / `pN unblock` / `unblock N` / `unblock pN` | Target that **table id** (`0`/`p0` = P0). |

If that phase is neither `Blocked` nor `Def-Blocked`: **do not
change it**. Print a clear **Error:** line (same red/bold style as
invalid defer).

Invalid id (not a number, negative, higher than last phase, unknown id):
**do not invent a target**. Print the same **Error:** style as invalid
defer.

If `Nimages` is present: acknowledge first, then Unblock. **Read**
those images when they may explain the blocker; use only what they
show (never invent APIs/files). If `Npass` > 1: extra pass(es)
improve test design / verification (see **Flags**).

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
     Reason (keep a remaining defer reason if one is stored and
     distinct; otherwise clear).
   Print what was verified and the updated table (show-style). Do
   **not** mark the phase `Done`.
6. **Fail** → leave Status **`Blocked`** or **`Def-Blocked`**. State
   the failure with evidence. Give the best remaining manual unblock
   instructions (same depth as the Todo report: why blocked, numbered
   manual tasks, what unblocked looks like, what not to do).

Example (only when these facts are in the conversation): a phase
blocked because an Eleven Labs agent must be deleted manually (no
programmatic delete in the story) — Unblock must check whether that
agent is gone. If still present: do not unblock; explain; leave
`Blocked`.

Display Status string on success: **`Unblocked`** (from `Blocked`)
or **`Deferred`** (from `Def-Blocked`). `Unblocked` fits the
12-wide Status column (` Unblocked  `).

### Runblock

**User-asserted unblock then run-or-mark-Done** those phases in one
step. Skip Unblock’s verification loop (no ack wait; same
assertiveness as rundefer / todone). `runblock` ≠ `unblock` ≠
`block` ≠ `rundefer`. Do not collapse on `run` / `un` / `block`.
**`unblock` still only verifies** (no execute). **`runblock` =
unblock + execute remaining work, or mark `Done` when nothing is
automatable.**

Parse after stripping `Nimages` / `Npass`. If `Nimages` is present:
acknowledge first, then Runblock. Match `runblock` / `Nrunblock` /
`runblockN` as this mode **first** — the token contains `block` and
`run`. Do **not** treat them as `block` / `Nblock`, `unblock` /
`Nunblock`, or `rundefer` / `Nrundefer`.

| Text | Effect |
|------|--------|
| `runblock` | Unblock the **next 1** Blocked or Def-Blocked phase (plan order), then run remaining work or mark `Done`. |
| `runblock N` / `Nrunblock` / `runblockN` (N ≥ 1) | Unblock the **next N** Blocked / Def-Blocked phases, then run-or-mark them in plan order (like Next-N on those just-unblocked phases). |
| `2runblock` / `runblock2` / `Runblock2` | Same as `runblock 2` — **next 2** blocked, **not** named P2. |
| `runblock pN` / `runblock PN` / `runblockpN` / `runblockPN` / `pN runblock` / `PNrunblock` | Named: that phase **only if** it is `Blocked` or `Def-Blocked`; else **Error:** |
| `runblock 0` / `0runblock` / `runblock0` | **Error:** (cannot “next 0”; use `runblock p0`). Not named P0. |

**Parse collision (required):** `runblock N` / `Nrunblock` /
`runblockN` / `2runblock` / `runblock2` means **next N blocked**,
not named PN (like `rundefer N` / `explain N` — and **unlike**
`Nblock` / `2block` / `Nunblock` / `2unblock`, which are named PN).
Named runblock is only the `P`/`p` family. `runblock 0` /
`0runblock` / `runblock0` is not “next 0” — **Error:** (use
`runblock p0` to target P0). `runblock` ≠ `unblock` ≠ `block` ≠
`rundefer`.

**Semantics:**

1. Find targets: next N phases with Status `Blocked` or
   `Def-Blocked` (skip Done, Left, Deferred-without-block,
   Unblocked, Progress, Planned, Not started, etc.).
2. If **none**: say so and print the table (show-style). Do **not**
   execute some other open phase.
3. If **fewer than N**: unblock+run-or-mark all found; say the
   shortfall.
4. **Unblock first** so the phase is runnable (skip Unblock’s
   verification loop — user-asserted; no ack wait):
   - `Blocked` → treat as cleared (`Unblocked` / ready)
   - `Def-Blocked` → clear **both** block and defer (`Left` /
     ready) so it can actually run (unlike **unblock** →
     `Deferred`, unlike **rundefer** → `Blocked` and stop)
5. **Then run or mark as run:**
   - Remaining **agent-automatable** work → normal phasify
     **Execute** (banners + last-of-run table). `Done` only if
     work landed.
   - **No remaining automation** (typical blocked gate: human
     work already done, nothing for the agent) → mark Status
     **`Done`**, short note, no Todo briefing, no fake implement.
     Clear blocker Reason (e.g. closed by runblock).
6. Sequential, plan order, like rundefer. Stop the sequence if a
   just-runblocked phase becomes `Blocked` again. Do not wait for
   ack. Nimages ack first if present. `Npass` = multi-pass of
   **this runblock run** (that mode’s work), not a whole-table
   replan.

Invalid named id, or named runblock of a phase that is neither
`Blocked` nor `Def-Blocked`: **do not change it** and **do not
execute**. Print a clear **Error:** line (same red/bold style as
invalid unblock).

Accepted tokens (all of these):

```text
/phasify runblock
/phasify runblock P0
/phasify runblock p0
/phasify runblock 1
/phasify runblockP0
/phasify P0runblock
/phasify 1runblock
/phasify 2runblock
/phasify2runblock
/phasify 2runblock
/phasify runblock2
/phasify runblock p1
/phasify p1 runblock
```

`2runblock` = next 2 blocked, **not** P2. Named is **only** the
`P`/`p` family.

### Remove (`delete` alias)

Non-executing. **Drop work-phase row(s)** from the current plan
(not defer, not todone). Requires a **yes/no confirm** before
any mutation. `delete` is an **exact alias** — same parse, same
effect, not a second mode. Parse `remove` / `delete` **before**
`done` / `todone` / `toend` / `defer`. `delete` ≠ `done`.

Parse after stripping `Nimages` / `Npass`. If `Nimages` is
present: acknowledge first, then Remove. Match `remove` /
`Nremove` / `removeN` and `delete` / `Ndelete` / `deleteN` as
this mode.

| Text | Effect |
|------|--------|
| `remove` / `delete` | Propose the **next 1** not-`Done` work phase (plan order). |
| `remove N` / `delete N` / `Nremove` / `Ndelete` / `removeN` / `deleteN` (N ≥ 1) | Propose the **next N** not-`Done` work phases (like `explain N` / `todone N`). |
| `2remove` / `remove2` / `2delete` / `delete2` | Same as `remove 2` — **next 2** not-Done, **not** named P2. |
| `remove pN` / `delete pN` / `pN remove` / `pN delete` / `remove PN` | Named: that **table id** only. |
| `remove <title>` / `delete <title>` | Named by **unique title** (Phase title after `—`, or Description). Example: `remove Defer - Delete IP`. |

**Parse collision (required):** `remove N` / `delete N` /
`Nremove` / `2remove` means **next N not-Done**, not named PN
(like `explain N` / `rundefer N`). Named id is only the `P`/`p`
family. `remove 0` / `0remove` / `remove0` (and `delete`
spellings): **Error:** (use `remove p0`). `2remove` ≠ `2todo` /
`2block` (those are named P2).

**Eligible** for bare / count: Status is not `Done`. Include
`Left`, `Unblocked`, `Progress`, `Planned`, `Not started`,
`Blocked`, **`Deferred`**, **`Def-Blocked`**. Skip `Done`. Named
`pN` / unique title may target **any** work phase, including
`Done`. Never target Task or Flags.

**Title match:** case-insensitive. Bind to a **unique** hit
against (1) the full Phase cell (`P3 — Defer - Delete IP`),
(2) the title after the em-dash / hyphen, (3) the Description
(unique substring). No hit or more than one hit: **Error:** +
list the matches or real ids + table. Do **not** remove.

Invalid id (not a number, negative, higher than last phase,
unknown id): **do not remove**. Print **Error:** (same red/bold
style as invalid defer).

Bare / count when none not-Done: say so + table. Do not invent
a target. Fewer than N: propose all found, say the shortfall,
still confirm that shorter list.

**Confirm (mandatory — unlike todone / rundefer / runblock):**
do **not** drop rows on the proposing turn. Print the candidate
list (id, title, Status) and the compact-renumber preview
(later ids shift down). Ask a simple **yes/no**. Stop and wait.

```text
**Remove — confirm.**
About to drop these work-phase row(s) from the plan (not defer):

- P3 — Defer - Delete IP  (Deferred)

After yes, remaining work phases compact to contiguous P0…Pn
(P4 — API → P3 — API).

Remove these phase(s)? (yes/no)
```

Use a yes/no prompt (plain question in Copilot chat). Do not
mutate until the user answers.

| Reply | Effect |
|-------|--------|
| `yes` / `y` / `ok` / `confirm` (case-insensitive) | Apply. |
| `no` / `n` / `cancel` / `abort` | Cancel. Print unchanged table. |
| Anything else | Re-ask. Do **not** remove. |

A pending Remove confirm is completed by the next yes/no even
without `/phasify`. `/phasify yes` / `/phasify no` also complete
it. Same-line `yes` on the proposing invocation does **not**
skip the confirm — they must see the list first. A new
`/phasify` that is not yes/no **cancels** the pending Remove
(do not apply) and dispatches that mode.

**On yes:** drop the proposed work-phase row(s). Compact-
renumber remaining work phases to contiguous `P0`…`P(n-1)` in
plan order (titles after `—` stay). Task and Flags are
unchanged. Reasons on remaining rows stay. Print
`**Remove — applied.**` (what dropped + renumber note) and the
updated table. No COMPLETED banners (this is not execute).

**On no:** print `**Remove — cancelled.**` and the unchanged
table.

This is **not** `/plannify fromhere`. Other phases keep their
statuses. Npass on Remove is multi-pass of **target resolution**
(title match / confirm wording); the last pass still asks
confirm before mutate.

Accepted tokens (all of these; `delete` swaps in for `remove`):

```text
/phasify remove
/phasify delete
/phasify remove p3
/phasify remove P3
/phasify p3 remove
/phasify remove 2
/phasify 2remove
/phasify remove2
/phasify remove Defer - Delete IP
/phasify delete p0
```

`2remove` = next 2 not-Done, **not** P2. Named id is **only**
the `P`/`p` family (or a unique title).

### Show / refresh

Aliases: `show`, `refresh`. **Read-only.** No implementation.
If `Nimages` is present: acknowledge first (see **Flags**), then Show.

Print the current aligned table (Task, Flags if present, all phase
statuses). Include Reason if any deferral has one. If no plan, tell the
user to `/plannify` first.

---

## Locate the plan vs the original ify text

Keep two things separate:

1. **Phased plan table** (what you execute / update) — from the latest
   `/plannify` (or equivalent) `## Phased plan`, or a verified plan file.
   If no plan is found, stop and tell the user to `/plannify` first.
   Do not invent phases.
2. **Original ify text** (what you put in the **Task** row) — the user's
   **raw request** that kicked off promptify, askify, runnify, plannify,
   debugify, addify, or whatever ify produced this plan. That is the
   text they typed after the slash command (or the free-text they asked
   to ify). When the plan came from `/addify`, use the **combined**
   text (ancestor body + addify bodies). It is **not** Intent Analysis,
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
text (ancestor body + addify bodies). Not `## Plan`, not Intent
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
`image` / `pass` so a later `1image` / `2pass` can count. No numbered
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

## Execute (mutating, phase-scoped)

All multi-phase execute modes stay **sequential, synchronous, in plan
order**. No parallel/fan-out. Skip `Done`, `Deferred`, and
`Def-Blocked` unless `--force` / explicit redo. Stop the sequence on
`Blocked` (not on `Def-Blocked` — skip it). Between
phases, re-read Task + Flags and confirm the next phase still serves
that goal; if not, stop and say why.

1. Validate the selected phase(s) against the real workspace (read/search).
2. **Execute only** that phase's exit criteria — implement, edit, test as
   needed. Do not start later phases. Do not reopen earlier `Done` work
   except to fix a blocker this phase depends on.
3. **Synchronous multi-phase (mandatory):** finish phase x **completely**
   (work landed or explicitly Blocked) **before** phase x+1 begins.
   Do **not** run phases in parallel, as background agents, or as a batch
   of simultaneous todos. No async fan-out. Applies to Next-N,
   Run-to-end, Stop-before-end, Rundefer, and Runblock.
4. Mark status accurately: `Done` only if the work **landed**; else
   `In progress`, `Blocked`, or leave as `Left`. Remaining unstarted work
   after a partial run is **`Left`**.
5. If a phase is **Blocked**, stop the sequence. Do not start x+1.

If `Nimages` is present: acknowledge first, then execute. Use scratch
images (when marked) as extra detail while implementing. If `Npass` >
1: extra pass(es) apply to **this phase's work** (see **Flags**), not
a whole-table replan.

---

## Phase COMPLETED banner (obvious)

After each phase that **finishes** (Done or Blocked), print a single-line
box **before** starting the next phase. Pad so every banner line is the
same width:

```text
┌──────────────────────────────────────────────────────────────┐
│  ✓  PHASE P1 — API   COMPLETED                               │
└──────────────────────────────────────────────────────────────┘
```

Use `✓` and `COMPLETED` for Done. If Blocked:

```text
┌──────────────────────────────────────────────────────────────┐
│  ✗  PHASE P1 — API   BLOCKED                                 │
└──────────────────────────────────────────────────────────────┘
```

**Between-phase vs last-of-run:**

- After every finished phase **except the last phase of this run:**
  COMPLETED/BLOCKED banner only (no full table).
- After the **last phase of this run:** banner + full `phase_layout.txt`
  recap (Task, Flags if any, statuses).

Apply this to Next-N, Run-to-end, Stop-before-end, Rundefer, and
Runblock. Single-phase Next stays banner + table. Named single-phase
(`0` / `pN`) also stays banner + table. Rundefer of one deferred
phase stays banner + table. Runblock of one blocked phase stays
banner + table (execute or mark-Done). A Def-Blocked rundefer target
that becomes `Blocked` uses the BLOCKED banner (execute stops; do
not pretend it became runnable). A just-runblocked phase that
becomes `Blocked` again stops the sequence (BLOCKED banner).

---

## Table layout (mandatory — `phase_layout.txt`)

Misaligned borders make the table unreadable. Copy this layout exactly.
**Do not** use a markdown table. **Do not** merge or span cells. **Do not**
put the original ify text in its own box.

Print the table inside a fenced `text` code block so the chat cannot
reflow the lines.

If the workspace has `docs/phase_layout.txt`, or this skill folder has
`phase_layout.txt`, match that file's column widths. The copy next to
this skill is the installed source of truth.

### Fixed widths (every line is **exactly 89** characters)

Match `docs/phase_layout.txt`. Status is **12** so `Understood` fits.

| Piece | Inner width | `│` column index |
|-------|-------------|------------------|
| Phase | **15** | left border = 0; after Phase = **16** |
| Description | **58** | after Description = **75** |
| Status | **12** | right border = **88** |

`1 + 15 + 1 + 58 + 1 + 12 + 1 = 89`. Count characters before sending.
If any line is not 89, or any `│` is not in columns 0 / 16 / 75 / 88,
rebuild the line. No trailing space after the right border.

### Characters

- Single-line box only: `┌┬┐ ├┼┤ └┴┘ │ ─` (not `╔═╗`, not markdown pipes).
- Pad with spaces — **never tabs**.
- Cell text: one leading space, then content, then spaces to the inner
  width. Example Phase ` P0 — Spec     ` (15), Status ` Done       ` (12).
  Task / Flags use a two-space indent as in the layout (`  Task`,
  `  Flags`).

### Wrap — keep the three columns on every line

Long text wraps **inside Description only** (max **56** characters of
content after the leading space). Word-wrap; never overflow a cell.

- **Task** (verbatim original ify text): Status `Planned` on the **first**
  Task line only; blank after. First Task line has a blank Phase; label
  `Task` on the next line; further wraps blank Phase. See **Capture Task
  and Flags**.
- **Flags** (both / one / none — see **Capture Task and Flags**): one
  Description line per present flag (`Caught and correctly interpreted
  <token>. On pass k of N.`). Phase `Flags` and Status `Understood` on
  the first Flags line only; blank after. Omit the row if neither flag
  was included.
- **Work phases:** Phase id (`P0 — Spec`) and Status on the **first**
  wrap line only; continuations have a blank Phase and a blank Status.

Row separators always keep three columns (`┼` / `┬` / `┴`). Never
collapse a separator across the full table width.

### Reason column (`show` / recap)

If any phase has a stored reason, add a **Reason** column on
`show`/`refresh` only (keep the 3-column execute recap unless a reason
exists — then include Reason so it is retrievable quickly). Reprint the
stored reason on every recap/show. Omit the column entirely if no phase
has a reason. Align with box-drawing; not a markdown table. 3-column
lines stay exactly 89 characters (`phase_layout.txt`); when Reason is
present, keep every line the same width.

### Row order

1. Column titles: `Phase` / `Description` / `Status` (and **Reason** when
   any phase has a stored reason)
2. **Task** — verbatim original ify Task text (promptify / askify /
   runnify / plannify / debugify / addify). When the plan came from
   `/addify`, use the combined text. No generated plan text. See
   **Capture Task and Flags**.
3. **Flags** — both flags, one flag, or omit the row (neither present)
4. Work phases in order, current statuses (Reason on that row when stored)

### Status words (must fit in 12 with the leading space)

Use exactly: `Planned` · `Done` · `Left` · `Blocked` · `Unblocked` ·
`Deferred` · `Def-Blocked` · `Progress` · `Understood`. Do **not**
write `In progress` (too long). `Unblocked` fits the 12-wide Status
column (` Unblocked  `). `Def-Blocked` is the table spelling of
canonical **Deferred-Blocked** (16 chars; does not fit). `Def-Blocked`
is 11 and fits (` Def-Blocked`). Treat `Unblocked` like `Left` for
Next / Todo selection. Skip `Def-Blocked` like `Deferred` for Next /
bare Todo. Mark from this run + prior **verified** work only.

### Canonical example (copy these widths)

This is `docs/phase_layout.txt` — 89 characters per line. Both flags
present ⇒ two Flags Description lines. Copy this file next to the skill
when widths drift.

```text
┌───────────────┬──────────────────────────────────────────────────────────┬────────────┐
│ Phase         │ Description                                              │ Status     │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│               │ I want to add an icon  to campaigns that will be used    │ Planned    │
│  Task         │ wherever the campaign is used for quick identification.  │            │
│               │ If none is supplied the icon should be a badge           │            │
│               │ <text cut but will be shown by cursor and grok>          │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│  Flags        │ Caught and correctly interpreted 1image. On pass 1 of 2. │ Understood │
│               │ Caught and correctly interpreted 2pass. On pass 1 of 2.  │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P0 — Spec     │ Freeze I1–I8 in DESIGN_FLUENT_CAMPAIGN_ICON.md + PRODUCT │ Done       │
│               │ row; initials examples including EEFF2                   │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P1 — Mark     │ campaignInitials + CampaignMark; tests; initials on      │ Done       │
│               │ campaign lists with no API                               │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P2 — API      │ 081_campaign_icon.sql icon_url; PATCH/POST; series       │ Done       │
│               │ campaign_icon_url; Console tests                         │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P3 — Edit     │ Properties Identity + create dialog URL field on         │ Done       │
│               │ existing instance-edit snapshot                          │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P4 — Tables   │ Per-row nameIcon; campaign lists + run Campaign column,  │ Done       │
│               │ 20px                                                     │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P5 — Surfaces │ Blade title, picker, runner, Home campaign rows, run     │ Left       │
│               │ essentials campaign label                                │            │
├───────────────┼──────────────────────────────────────────────────────────┼────────────┤
│ P6 — Bake     │ PRODUCT greps, rebuild Fluent, Console tests green       │ Left       │
└───────────────┴──────────────────────────────────────────────────────────┴────────────┘
```

---

## Closing recap (mandatory when the run's phase(s) complete)

After the last banner of this run, print **only** `## Phased plan` plus
the aligned table (last section; promptify trailing-table rule). Nothing
after the table except an optional one-line next-step (e.g.
`/phasify next`). Mid-run phases get the banner only — not this recap.
Include Reason if any phase has a stored reason.

---

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
eligible” + table). Invalid explain id, or named explain of a
`Done` phase: **Error:** (same style as defer / todo-on-Done).
`explain 0` / `0explain` / `explain0`: **Error:** (use
`explain p0`). Bare `explain` / `explain N` with none not-Done:
say so + table. Fewer than N not-Done: explain all found, say
the shortfall, print the table. No COMPLETED banners for Explain
itself (advisory). After all explanations: 89-char table last.
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
- Cite `docs/window_title.md`. Name is `PHASE:P<n>/<total>:<PREFIX>: <summary>`. Set the tmux window name per that contract on a real task. Help, tldr, and pass do not retitle. Empty `/phasify` is Next, so it does.

- Cite `docs/from_contract.md`. `from=` and `from:` splice local files into this prompt. Help, tldr, pass, and empty do not read files.

- Execute only the selected phase(s). Do not re-plan the whole project.
  Use `/plannify fromhere` (plannify skill) to replan from current
  statuses.
- Empty `/phasify` (no selector after stripping image/pass tokens) is
  **Next** (count = 1), same as `next`. Never print help/usage for an
  empty invocation. After flag strip, first token `smart` is **Smart**
  (cite `docs/smart_contract.md` + `references/SMART.md`); not Next;
  not implicit NL. After flag strip, `help` / `--help` / `/?` prints
  `references/HELP.md` and stops — do not execute. After flag strip,
  exact `tldr` prints `references/TLDR.md` and stops — never a phase
  id. After flag strip,
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
  (use `explain p0`). Named `Done`: **Error:** cannot explain a
  completed phase. Invalid id: same **Error:** as defer. None
  not-Done: say so + table. Fewer than N: explain all found, say
  the shortfall, print the table. Next-N Explain does **not**
  stop on Blocked (explains and continues). Each phase ends with
  **TL/DR**. Table last. No COMPLETED banners for Explain itself.
  Parse `explain` / `Nexplain` / `explainN` as Explain, not Todo,
  not Todone, not `toend` / `end`.
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
  `phase_layout.txt` layout (execute recap / show). Original ify Task
  text is the **Task** row (three columns, wrapped) — never a separate
  box, never a spanning cell, never generated plan text. Flags are
  both / one / none per **Capture Task and Flags**. Include **Reason**
  when any phase has a stored reason.
- Every 3-column table line is exactly 89 characters with `│` at 0, 16,
  75, 88.
- Image and pass markers are not phase selectors; acknowledge them first
  when present. Parse per promptify Flag parse order. Flags work in
  all modes; defer/block reasons must not swallow `2pass`.
