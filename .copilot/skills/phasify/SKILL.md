---
name: phasify
description: >-
  Phasify — execute phase(s) of a plannified plan. Aliases: /phaseify,
  /phify. Empty /phasify =
  next incomplete. Named P0 (0/p0); next N (bare N≥1); done/toend =
  run-to-end; -N = stop-before-end. Modes: defer, undefer, rundefer,
  todo, explain, dummy, todone, block, unblock, runblock, howto, coach, instruct, remove (delete
  alias), smart, show, help, tldr. Optional guide on explain, tldr, and dummy.
  Instruct (`instruct`, `mini`, `instruct next`, `pN-next`) is a read-only
  mini plan. Match `pN-next` and `instruct` before Named and before Next.
  Bare `next` and bare `pN` stay execute.
  Use /phasify pN for a named phase
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

Cite the optify skill's `references/optify_contract.md`. On: this short router, and only the mode just parsed. Off: the full reference set. Clear and compact follow that contract.


Follow `~/.copilot/skills/promptify/SKILL.md` Hard rules (workspace is source
of truth; never invent files/APIs/tools/DBs) and its **Scratch images**
section. Follow `~/.copilot/skills/plannify/SKILL.md` for phase ids.
Print the recap / between-phase table using **Table layout**
(`phase_layout.txt`) — not a markdown table.

User-facing meanings of **Deferred phase**, **Todo**, **Explain**, **Dummy**,
**Guide**, **Coach**, **Instruct**, **Block**,
**Runblock**, **Howto**, and
**Addify to plannify** live in `references/HELP.md` (**Concepts**),
near the top after “what it does.” Agents follow this SKILL for parse
and behavior; `/phasify help` prints HELP. See HELP **Concepts**.

---

## Flags (`Nimages` / `Npass`)

Applies to **every** phasify mode (Next, Named, Next-N, Run-to-end,
Stop-before-end, Defer, Undefer, Rundefer, Todo, Explain, Dummy, Todone, Block,
Unblock, Runblock, Howto, Coach, Instruct, Remove, Smart, Show, Help). Parse and strip **before** mode dispatch.

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
- Skip unnumbered `image` / `images` / `pass` / `passes`. Exception: the first typed token exactly `image` (any case) counts as `1image` and is stripped.
- Several numbered → first only (not the largest N).
- No numbered instance → that flag is absent.

Strip flags **before** deciding Help vs task (`help` / `--help` /
`/?`) and **before** taking defer/block reason text. Flags are
**not** part of the task wording or reason — `2pass` must not be
swallowed as a defer/block reason.

**`-2pass` is Npass, not Stop-before-end `-2`.** Strip the pass
flag first. Leftover `-2` (no `pass`) is Stop-before-end.

**Scratch images**, **Named images**, and **Multi-pass** are in `references/shared.md`. Read that file with the mode (**Read rule**). Strip image and pass tokens before the mode parse below.

---

## Invocation (parse after stripping image and pass tokens)

Parse **after** stripping `Nimages` / `Npass` (promptify Flag parse
order — see **Flags**). Any mode may take optional flags. `-2pass`
is a pass flag, not stop-before-end. Bare `/phasify` stays **Next**.

| User text | Mode | What to run |
|-----------|------|-------------|
| `instruct`, `instruct 1`, `instruct pN` | **Instruct** | Build or reprint one blocked or partially blocked parent phase as a mini plan (no execute; no Status change). Matched before Named and before Next |
| `mini`, `instruct next`, `pN-next` | **Instruct** | Evidence for the current user substep, then the next user instruction. `pN-next` is not Named and not Next |
| (empty / no selector) | **Next** | The next incomplete phase (count = 1) |
| `0`, `p0`, `phase 0`, `phase p0`, `run phase p0` | **Named** | That specific phase (P0) |
| `pN`, `phase N`, `phase pN`, `run phase pN` | **Named** | That specific phase (PN) |
| `next`, `run next phase` | **Next** | The next incomplete phase (count = 1). Bare `next` stays execute |
| `3`, `next 3`, `run next 3 phases` | **Next-N** | The next **N** incomplete phases, **N ≥ 1** |
| `done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` / `to end` | **Run-to-end** | Every remaining incomplete phase through the end of the plan |
| `-` / `-0` / `-N` | **Stop-before-end** | Run through 1-based index `C - N`; do not run phases `> C - N` |
| `defer`, `Ndefer`, `defer N` [reason] | **Defer** | Mark that phase Deferred (optional reason); do not execute |
| `undefer`, `Nundefer`, `undefer N` | **Undefer** | Clear Deferred → `Left`; do not execute |
| `rundefer`, `Nrundefer`, `rundefer N`, `rundeferN` | **Rundefer** | Undefer then execute those Deferred / Def-Blocked phases |
| `todo`, `Ntodo`, `todo N` | **Todo** | Detailed actionable list for that phase (no execute; no Status change) |
| `explain`, `Nexplain`, `explain N`, `explainN` | **Explain** | Full explanation + glossary + TL/DR (no execute; no Status change; do not rewrite the plan). Named `pN` may be Done. Optional second word `guide` |
| `dummy`, `Ndummy`, `dummy N`, `dummyN` | **Dummy** | Non-technical intent and simple description (no execute; no Status change; do not rewrite the plan). Named `pN` may be Done. Optional second word `guide` |
| `todone`, `Ntodone`, `todone pN`, `todone N` | **Todone** | Todo-depth list, then Status `Done` (no execute; no ack wait) |
| `block`, `Nblock`, `block pN` [reason] | **Block** | Manually set eligible phase(s) `Blocked` / `Def-Blocked`; do not execute |
| `unblock`, `Nunblock`, `unblock N` | **Unblock** | Verify a Blocked / Def-Blocked phase; on pass `Unblocked` or `Deferred` |
| `runblock`, `Nrunblock`, `runblock N`, `runblockN` | **Runblock** | User-asserted unblock then execute remaining work or mark `Done` |
| `howto`, `Nhowto`, `howto N`, `howtoN` | **Howto** | Steps past the next blocked or partially blocked phase (no execute; no Status change) |
| `coach`, `coach pN` | **Coach** | One blocked or partially blocked phase, one instruction at a time (no execute; no Status change). Not runblock |
| `remove`, `Nremove`, `remove N`, `removeN`, `remove pN`, `remove <title>` | **Remove** | Drop work-phase row(s) after yes/no confirm (not execute) |
| `delete` (same shapes as `remove`) | **Remove** | Exact alias of `remove` |
| `smart <prompt>` | **Smart** | Select a mode from the live plan; print preamble; dispatch. Not Next. |
| `show` / `refresh` | **Show** | Print the current table (read-only; no implementation) |
| `help` / `--help` / `/?` | **Help** | Print `references/HELP.md`; do not execute |
| `tldr` | **tldr** | Exact `tldr` (no other token): print `references/TLDR.md` and stop. Selector `tldr 1` / `tldr N` / `Ntldr` / `tldr pN`: phase tell. Optional second word `guide`. A question that is not a selector: the explanation only. Never rewrite the plan. `tldr help` is not help |
| `pass` / `pass help` | **Pass help** | Print the Pass (`Npass`) section; do not execute |
| `/plannify fromhere` | **fromhere** | Replan from current statuses (plannify skill) |

**Disambiguation (required):**

- Match **`pN-next`** and **`instruct`** before **Named** and before
  **Next**. `pN-next` / `PN-next` is **Instruct** advance, not Named
  PN and not Next. `instruct` / `instruct 1` / `instruct pN` /
  `pN instruct` builds or reprints that parent phase. `mini` and
  `instruct next` advance the latest Instruct table. Bare `next`
  and bare `pN` stay execute. `instruct N` for N ≥ 2, `Ninstruct`,
  `instructN`, `2instruct`, and `instruct2` are **Error:** (one
  phase; use `instruct` or `instruct pN`). `instruct 0` /
  `0instruct` / `instruct0` is **Error:** (use `instruct p0`).
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
  **stop**. That print is the whole reply. Do not narrate the
  process, add a followup, or add anything around the page. Do not
  rewrite or reprint the phased plan. Do not retitle. A phase tell
  needs a selector: `tldr 1`, `tldr N`, `Ntldr`, `tldrN`, `tldr pN`
  (also `pN tldr`). `guide` only as the second word (`tldr guide`,
  `tldr guide p3`). `tldr 0` / `0tldr` / `tldr0` is **Error:** (use
  `tldr p0`). `tldr help` is not help. Any other extra tokens are
  the question: answer with the explanation only. Do not write the
  process of answering. Do not add a followup or any other
  information. Do not execute. Do not change Status. Do not rewrite
  or reprint the phased plan. Exact `tldr` is never a phase id.
- After stripping flags, remaining body exactly `pass` or `pass help`
  (case-insensitive) is **Pass help** — print the **Pass (`Npass`)**
  section of `references/HELP.md` and **stop**. Not a phase selector.
  There is no `/pass` skill.
- After stripping flags, a token that is `-`, `-0`, or `-N` (N = 0–9) is
  **Stop-before-end**, not Next-N.
- `-2pass` is a pass flag, not stop-before-end.
- Bare `3` is still Next-3. New tokens must be words (`done`, `toend`,
  `defer`, `undefer`, `rundefer`, `todo`, `todone`, `explain`, `dummy`, `coach`, `instruct`, `mini`, `block`, `unblock`, `runblock`, `howto`, `remove`, `delete`)
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
- Match **`coach`** before **`guide`**. `coach` / `coach 1` /
  `coach pN` / `pN coach` is **Coach** (one blocked or partially
  blocked phase). `coach N` for N ≥ 2, `Ncoach`, `coachN`,
  `2coach`, `coach2`: **Error:** (one phase; use `coach` or
  `coach pN`). `coach 0` / `0coach` / `coach0`: **Error:** (use
  `coach p0`). `coach guide` is **Error:**. Not runblock. Not howto.
- Match **`guide` only as the second word** on `explain`, `tldr`,
  or `dummy` (`explain guide`, `tldr guide p3`, `dummy guide`,
  `3explain guide`). A leading `guide` is **Error:**. `guide` is
  not runblock. `guide` elsewhere than the second word is
  **Error:** (`explain guide p3`, not `explain p3 guide`).
- Match **`dummy` / `Ndummy` / `dummyN`** as **Dummy**, like
  explain. **`dummy N` / `dummy3` / `3dummy` / `2dummy` means next
  N not-Done**, not named PN. Named is only `pN` (`dummy pN` /
  `pN dummy` / `PNdummy`) and may be `Done`. `dummy 0` /
  `0dummy` / `dummy0` is **Error:** (use `dummy p0`).
- Match **`explain` / `Nexplain` / `explainN`** as **Explain**, not
  Todo, not Todone, not `toend` / `end`, not Rundefer, not Dummy.
  Do not collapse a shared `end` suffix as Run-to-end.
  **`explain N` / `explain 3` / `explain3` / `3explain` /
  `Nexplain` / `explainN` / `2explain` means next N not-Done**
  (like `rundefer N` / `block N` / `todone N`), **not** named PN
  (unlike `Ntodo` / `2todo` / `Nblock` / `2block`). Named explain
  is only the `P`/`p` family (`explain pN` / `explainP3` /
  `P3explain` / `p3explain` / `p3 explain`) and may be `Done`.
  `explain 0` / `0explain` / `explain0` is **Error:** (use
  `explain p0`). Bare `explain` includes Deferred / Def-Blocked
  (unlike bare todo). `explain` ≠ `todo` ≠ `todone` ≠ `dummy` ≠
  `toend` / `end`.
- Match **`howto` / `Nhowto` / `howtoN`** as **Howto**, not
  Explain, not Unblock, not Runblock, not Todo, not Next-N.
  **`howto N` / `howto 2` / `howto2` / `2howto` / `Nhowto` /
  `howtoN` means next N blocked or partially blocked**, not
  named PN (like `explain N` / `runblock N`). Named howto is
  only the `P`/`p` family (`howto pN` / `pN howto` /
  `howtoPN` / `PNhowto`). `howto 0` / `0howto` / `howto0` is
  **Error:** (use `howto p0`). `howto` ≠ `explain` ≠ `unblock`
  ≠ `runblock`.
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
  That print is the whole reply. Do not narrate the process, add a
  followup, or add anything around the page. Do not rewrite or
  reprint the phased plan. Do not retitle. A selector (`tldr 1`,
  `tldr N`, `Ntldr`, `tldrN`, `tldr pN`, `pN tldr`) or second word
  `guide` is a phase tell, not this short page. `tldr help` is not
  help. Any other extra tokens are the question: answer with the
  explanation only. Do not write the process of answering. Do not
  add a followup or any other information. Do not execute. Do not
  change Status. Exact `tldr` is never a phase id.
- Remaining selector exactly `pass` or `pass help`
  (case-insensitive): print the **Pass (`Npass`)** section of that
  file and **stop**. There is no `/pass` skill.

Do not execute, defer, undefer, rundefer, todo, todone, explain, dummy, coach, instruct, block, unblock,
runblock, howto, remove, delete, or show. Do not invent extra modes. Help and exact `tldr` are not
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
mutation; no implementation). **Todo**, **Explain**, **Dummy**, a tldr phase tell, **Guide**, **Coach**, **Instruct**, **Howto**,
**Show**, **Help**, and exact **tldr** are read-only (no implementation). Explain, dummy, tldr-tell, guide, coach, and instruct do not optimize and do not enter Execute. They do not change Status. Handle
Defer, Undefer, Todo, Explain, Dummy, Coach, Instruct, Howto, Todone, Block, Unblock, Remove, Show, and
Help without entering Execute. Handle Rundefer as
undefer-then-Execute (do not treat it as status-only). Handle
Runblock as unblock-then-Execute-or-Done (do not treat it as
Unblock / status-only). **Smart** is a router: preamble then
dispatch the selected mode (not an execute dialect of its own).

### Smart (`smart <prompt>`)

Read `references/SMART.md`, then dispatch the selected mode (that mode's row in **Read rule**). Not Next. Not an execute dialect of its own.

## Read rule

Cite the optify skill's `references/optify_contract.md`.

Optify is **on** unless `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env` contains the line `enabled=off`. A missing file, or a file with no `enabled` key, is on. Only `enabled=off` is off. Do not require `./scripts/cli.sh` to decide; reading the env file is enough. `./scripts/cli.sh optify show` is the supported way to change the switch.

Do not read `references/HELP.md` except for `/phasify help` (also `--help`, `/?`, and `pass` / `pass help`). A normal run does not read it.

**On:** read only the parsed mode file in the table, plus `references/table_layout.md`, plus `references/shared.md` when that mode locates or updates the plan. Do not read the other mode files.

**Off:** read every mode reference: `shared.md`, `table_layout.md`, `execute.md`, `todo.md`, `explain.md`, `dummy.md`, `guide.md`, `coach.md`, `instruct.md`, `todone.md`, `howto.md`, `defer.md`, `undefer.md`, `rundefer.md`, `block.md`, `unblock.md`, `runblock.md`, `remove.md`, `show.md`, and `SMART.md`. Still do not read `HELP.md` except for help / pass.

| Parsed mode | Mode file | Also read |
|-------------|-----------|-----------|
| Next, Named, Next-N, Run-to-end, Stop-before-end | `execute.md` | `shared.md`, `table_layout.md` |
| Rundefer | `rundefer.md` | `execute.md`, `shared.md`, `table_layout.md` |
| Runblock | `runblock.md` | `execute.md`, `shared.md`, `table_layout.md` |
| Defer | `defer.md` | `shared.md`, `table_layout.md` |
| Undefer | `undefer.md` | `shared.md`, `table_layout.md` |
| Block | `block.md` | `shared.md`, `table_layout.md` |
| Unblock | `unblock.md` | `shared.md`, `table_layout.md` |
| Remove (`delete` alias) | `remove.md` | `shared.md`, `table_layout.md` |
| Todone | `todone.md` | `shared.md`, `table_layout.md` |
| Todo | `todo.md` | `shared.md`, `table_layout.md` |
| Explain | `explain.md` | `shared.md`. Also `guide.md` when the second word is `guide` |
| Dummy | `dummy.md` | `shared.md`. Also `guide.md` when the second word is `guide` |
| Coach | `coach.md` | `guide.md`, `shared.md` |
| Instruct | `instruct.md` | `shared.md` |
| Howto | `howto.md` | `shared.md`, `table_layout.md` |
| Show / refresh | `show.md` | `shared.md`, `table_layout.md` |
| Smart | `SMART.md` | then the selected mode's row |
| Help / pass | `HELP.md` | stop; no other mode file |
| tldr | Exact body: `TLDR.md`, then stop. A selector: `explain.md` (tldr tell) and `shared.md`; also `guide.md` when the second word is `guide`. A question that is not a selector: answer only. Locate the plan from `shared.md` when the question needs it. Do not rewrite the plan |

`shared.md` holds locate-plan, capture task, scratch images, named images, multi-pass, response shape, and hard rules. Todo, explain, dummy, a tldr phase tell, guide, coach, instruct, howto, and show read it so they can locate the plan. They do not optimize.

On a mutating run, apply **Phase boundary** before the mode-file read. If that optimize fires, stop. Do not read the mode file on that turn.

## Phase boundary

Cite the optify skill's `references/optify_contract.md`. Clear and compact follow that contract. A phase mutation is not an optimize. Do not compact between phases when nothing is armed and the meter is under the cutoff.

Mutating runs: Named, Next, Next-N, Run-to-end, Stop-before-end, Defer, Undefer, Rundefer, Todone, Block, Unblock, Runblock, Remove. **Howto, show, explain, dummy, a tldr phase tell, guide, coach, and instruct do not optimize.** Help, exact tldr, and pass do not optimize. A question after `tldr` does not optimize. Todo is read-only and does not optimize. Explain, dummy, tldr-tell, guide, coach, and instruct do not change Status and do not rewrite the phased plan.

**Start** of a mutating run, before the mode-file read. Optimize, then stop the turn, only when one of these is true:

- `before=1` is in the env file (armed). This fires even when optify is off. It does not set `enabled=on`.
- Optify is on, the host shows a context meter at or above about 70%, and this is the same effort. That check uses the mutation as the moment to look. The mutation is not the trigger. Do not replace "about 70%". If the host shows no meter, do not invent a percentage and do not optimize. Use this tree's continue row when it has one, and do not write the handoff. A host with no continue row uses its only row and writes the handoff.

A verb change does not optimize. The previous ify verb not being phasify does not optimize. Plannify, then phasify, does not optimize and does not write the handoff. When neither start condition above is true, open the execute instructions.

Clear `before` only when that shot fires: remove the `before` key and leave `enabled` and `after`. Do not flip `enabled`. Do not clear `after` at the start. A verb change with `before` already clear does not optimize, and there is no `before` key to remove. Remove the key through `./scripts/cli.sh optify` or `scripts/cli.ps1 optify`. Do not edit the env file by hand. Do not remove `after` in the same write.

If that start optimize already stopped the turn, an armed `after` waits for the phase that actually finishes.

**End** of a phase, if `after=1`: print the phase COMPLETED banner and the phase table **first**, land the status update, **then** optimize, then stop. Clear `after` when that shot fires (remove the `after` key; leave `enabled` and `before`). This end step is Execute, or Todone marking `Done` (those mode files carry it). Defer, undefer, block, unblock, and remove do not print a COMPLETED banner. An armed `after` fires even when optify is off and does not set `enabled=on`.

A verb change is not a clear and not a compact. Same-effort `before` / `after`, and the meter at or above about 70%, are a compact, or this host's only row when that row is the only one. Cursor, Copilot Chat, and grok.com have no continue row: same effort still uses that only row and still writes the handoff. A continue row does not write the handoff.

### Optimize

Write the handoff file only before a clear or a new chat. Do not write it before a compact. Print the exact host command. Print one line `Host: <row>.` Then stop. Do not press `/compact` or `/clear`. Do not start the heavy mode read in the same turn as a clear or a new chat.

Handoff path:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify-handoff.md
```

The skill writes that file. Cap about 40 lines. Shorter is the usual file. Do not pad. If it would pass about 40 lines, shorten the files-touched list first. Order:

- Previous verb.
- Task line.
- Flags.
- Phase table statuses (phase id and status).
- Files touched (paths).
- The next command the user already typed.

Omit the next-command line when the user has not typed that command. Do not invent one.

The focus sentence (compact rows) keeps the plan, the phase id, and the files from this run. Word it from this effort.

### Host

This tree is one skill for Copilot CLI and Copilot Chat. Use the row that matches this session. Do not tell the user to change model, tools, or reasoning.

- **Copilot CLI, same effort.** Print `Host: Copilot CLI, continue.` Do not write the handoff. The user runs `/compact` plus a focus sentence that keeps the plan, the phase id, and the files.
- **Copilot CLI, new verb.** Print `Host: Copilot CLI, new verb.` Write the handoff first. Print `/clear` or `/new` as that one line. Do not drop either word.
- **Copilot Chat, either case** (same effort or a new verb). Print `Host: Copilot Chat.` Write the handoff first. Start a new conversation; the next turn reads the handoff file. Chat has no `/compact`.
