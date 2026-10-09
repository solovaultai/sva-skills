# Remove

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

