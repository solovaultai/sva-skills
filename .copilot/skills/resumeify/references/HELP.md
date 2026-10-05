# Resumeify — user reference

Print this file as the response when the user runs `/resumeify help`,
`/resumeify --help`, or `/resumeify /?`. Do not list or restore.
`/resumeify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/resumeify` lists saved contexts. It is not Help and it does
not restore. `help me …` (or any longer body) is a **name**, not
Help. `/resumeify 2pass` and `/resumeify 1image` are empty after
flag strip: they list.

---

## What it does

A **thin restore front end**. Lists saved ify contexts and reprints
one so a later `/phasify` can continue. Does not plan or execute
phases. Does not write or delete.

Store, list order, and reprint follow `docs/saveify_contract.md`.
This page does not restate that store.

```text
/resumeify                — list, newest first; do not restore
/resumeify list           — same list, then restore the one you pick
/resumeify <name>         — restore that snapshot
/resumeify <#>            — restore list position (1 = newest)
/resumeify help           — this reference (also --help / /?)
/resumeify tldr           — short form; stop
/resumeify pass           — Pass (Npass) subsection only (also pass help)
```

Canonical slash is `/resumeify`. `resumify` is not a command.

---

## How to invoke

```text
/resumeify
/resumeify list
/resumeify 1
/resumeify my saved plan
/resumeify help
/resumeify tldr
/resumeify pass help
```

Empty `/resumeify` prints the list and stops. A name restores that
row. A number restores that position in the list you would see now.
`1` is the newest. The number is not a permanent id.

`/resumeify 2` is position 2, even when a snapshot is named `2`.

The text is everything after the command, or the free-text request
when they said “resumeify that plan”.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/resumeify` *(empty)* | **List** | Newest first. No restore. Does not ask. Name unchanged |
| `/resumeify list` | **List select** | Same list, then a number or a name. That pick restores for `/phasify` |
| `/resumeify <name>` | **Restore** | Reprint that snapshot |
| `/resumeify <#>` | **Restore** | `#` is current position, 1 = newest |
| `/resumeify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/resumeify tldr` | **tldr** | Print the short page; stop |
| `/resumeify pass` / `pass help` | **Pass help** | Print the Pass section; stop |
| `/resumeify 2pass` / `1image` | **Flags** | Stripped, then list |

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, `pass help`, or `list`. `list` is that mode,
not a snapshot name. `help me write a login form` is a name (look
up that snapshot).

---

## List

Newest saved first. The row is **List** in `docs/saveify_contract.md`:

```text
<n>  <saved_at>  <display_name>  <verb>, <phases> Phases, <stage>, <blocks> Blocks, <defers> Defers, <cwd>
```

Phase count once, after the verb. Then the stage, then Blocks,
then Defers, then cwd.

No rows: nothing is saved. Empty `/resumeify` does not restore and
does not change the window name. It does not ask.

`/resumeify list` prints that same list and asks for a number or a
name. The pick reprints the snapshot. If any work phase is not
Done, the next command is `/phasify`. If every work phase is Done,
the plan is complete. The asking turn does not retitle. The restore
does.

---

## Restore

No yes/no. The reprint starts:

```text
**Resumeify — restored `<name>`.**
Saved <date>. Verb `<verb>`. Stage: <stage>. Workspace: <cwd>.
```

When a plan file was saved, the next line is that file's absolute
path. That path is the plan a later `/phasify` locates. Resumeify
does not run `/phasify`.

If the saved workspace is not this session's workspace, resumeify
says so and does not change directory.

A plan reprint is the saved plan, then the phase table. If any work
phase is not Done, the next command is `/phasify`. If every work
phase is Done, the plan is complete.

A non-plan reprint is the saved task, then any saved kickoff or
notes. It does not say `/phasify` and it does not say the plan is
complete.

A missing name: **Error:** not found, then the list. More than one
match: **Error:** ambiguous, then the list. If a number points at a
different snapshot by the time it would restore: **Error:** list
changed. Nothing is restored.

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify: first numbered instance left to
right on the **typed line only**; skip unnumbered `image` / `pass`
(first typed token `image` counts as `1image`).
Strip **before** deciding Help vs list vs restore. Cite promptify
**Flag parse order** — do not fork.

Flags are not a snapshot name. Resumeify does not read scratch
images and does not run a pass loop.

`/resumeify 2pass` and `/resumeify 1image` list. A name elsewhere
on the line is still the target: `/resumeify 2pass my saved plan`
restores `my saved plan`.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this section** and stops.
Full reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right, typed line only. Default **1**.

**Meaning:** the flag is stripped so it is not a snapshot name.
Resumeify does not loop and does not take N passes. It lists or
reprints once. A later ify verb, not resumeify, applies multi-pass
when you invoke that verb.

```text
/resumeify pass
/resumeify pass help
/resumeify 2pass
/resumeify 1image
/promptify pass help
```

---

## Banner then saved body

```text
**Resumeify — restored `<name>`.**
Saved <date>. Verb `<verb>`. Stage: <stage>. Workspace: <cwd>.
```

Then the saved plan and phase table, or the saved task when there
was no plan. Resumeify stops there.

---

## Hard rules (short)

- Thin front end: list, or restore one snapshot. No planning. No
  phase execution. No delete.
- Empty `/resumeify` lists newest first and does not restore.
  `/resumeify list` asks, then restores that pick for `/phasify`.
  Exact `list` is not a snapshot name.
- `<#>` is the current list position. `1` is newest. It is not a
  stable id.
- A different workspace is announced. The directory stays.
- Unfinished plan: next command is `/phasify`. All Done: the plan
  is complete.
- Flags on the typed line are not a name. Resumeify does not loop.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  stop. Exact `tldr`: print `references/TLDR.md` (not this file).
  Exact `pass` / `pass help`: print **Pass (`Npass`)** only.
  There is no `/pass` skill.

---

## Related

| Command | Role |
|---------|------|
| `/saveify` | Write or delete a snapshot |
| `/phasify` | Execute the next plan phase after a restore |
| `/promptify pass help` | Full pass-flag reference |
| `/ify` | Family catalog |
