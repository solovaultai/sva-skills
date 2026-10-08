---
name: saveify
description: >-
  Saveify — write a snapshot of the current ify context, or delete one
  after yes/no. Use when the user runs /saveify, says "saveify" or
  "savify", says "save the ify context", or says "delete a saved
  context". /saveify <name> saves under that name and asks yes/no
  before replacing an existing snapshot. Empty /saveify is an
  auto-name save, not short usage. /saveify delete lists, the user
  picks, then yes/no. /saveify delete <name> and /saveify delete <#>
  show that row, then yes/no. Every delete requires confirmation.
  Nothing is deleted on the proposing turn. /saveify list shows
  every saved context in a selection and displays the one you pick.
  Choose none stops. It does not
  hand off to phasify and it does not execute a phase. /saveify help or
  /saveify --help (also /?) prints the full reference. /saveify tldr
  prints the short page. /saveify pass and pass help print the Pass
  (Npass) subsection. savify is an alias of /saveify, not a
  folder. Canonical slash is /saveify. No smart mode.
  Recognizes nimages / Nimages / N images / N-images and npass /
  Npass / N-pass / N pass per promptify Flag parse order (stripped
  before the name; saveify does not run its own pass loop).
argument-hint: "[<name>|list|delete]"
user-invocable: true
disable-model-invocation: true
---

# Saveify (= snapshot the ify context)

You are running **Saveify** (`/saveify`) — a **thin snapshot verb**
in the Promptify family. You write or delete one saved ify context.
You do not plan, execute, debug, answer, or restore. Restoring is
`/resumeify`. There is no `smart` mode.

1. If a list pick, a delete pick, or a yes/no confirm is pending,
   handle that reply first.
2. Strip `Nimages` / `Npass` on the typed line (Flag parse order).
3. Dispatch help, tldr, pass, list, delete, empty, or a named save.
4. On a save, write the snapshot the contract names, through the
   CLI below.
5. Set the window title on a save.

Cite `docs/saveify_contract.md` **List select**. Writes and deletes go through that store. Help, tldr, pass, and list do not write. Empty `/saveify` is an auto-name save. `/saveify list` uses that selection: a saved context is displayed and does not hand off to phasify. `Choose none` stops.

Claude Code calls `AskUserQuestion` (one question, single select). That is the primary path. If `AskUserQuestion` is unavailable, print the rows and a final line `Choose none`. A reply of `Choose none` selects nothing and stops. Do not invent a selection widget.

Read that file and follow it. Do not paste a second store path,
snapshot layout, auto-name, list order, or confirm rule. `savify`
is an alias of `/saveify`, not a folder. Canonical
slash is `/saveify`.

Follow `~/.claude/skills/promptify/SKILL.md` for **Flag parse order**
only. Do not run a second pass loop. Do not run Scratch images.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then take the
first whole token, case-insensitive. Reserved first tokens are
modes, not names: `delete`, `list`, `help`, `tldr`, `pass`,
`--help`, `/?`.
`pass help` is pass. These do not write a snapshot and do not
retitle.

- First token `help`, `--help`, or `/?`: **read and print**
  `references/HELP.md` (this skill folder) and **stop**. Further
  words on that line (`help me …`) stay on Help. They do not save.
- First token `tldr`: **read and print** `references/TLDR.md` and
  **stop**. There is no `tldr help` alias. Further words stay on
  tldr.
- First token `pass`, including body `pass help`: print the
  **Pass (`Npass`)** section of `references/HELP.md` and **stop**.
  There is no `/pass` skill. Further words stay on pass.

`password` and `helpful` are names. They are not the whole tokens
`pass` and `help`.

Empty `/saveify` is an auto-name save, not Help and not short usage.
Same exception shape as empty `/phasify` = Next.

```text
/saveify                 — auto-name save
/saveify <name>          — save under that name
/saveify list            — selection list, display only; Choose none stops
/saveify delete          — list, pick, then yes/no
/saveify delete <name>   — that row, then yes/no
/saveify delete <#>      — that position, then yes/no
/saveify help            — full reference (also --help, /?)
/saveify tldr            — short form (stop)
/saveify pass help       — Pass (Npass) subsection (also `pass`)
```

---

## Flag parse order (`Nimages` / `Npass`)

On the **typed line only**, follow promptify **Flag parse order**
(first numbered `Nimages` / `Npass` only). Strip them before the
mode or the name. They are not body text and not part of the
display name. Do not fork that parse.

Saveify does not loop, does not open scratch for `Nimages`, and does not print
the scratch or Npass acknowledgements. One save. A line that is
only flags is an auto-name save.

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
`img=<file>`, `img:<file>`, `img=[a,b]`, and `img:[a,b]` name
specific files. Every token counts. Strip them before the name.
Copy the resolved files into the snapshot per
`docs/saveify_contract.md` (`images/` and `images.txt`). Also
copy named images already in the in-flight context. Print the
named-images ack.

Snapshot `flags`, `pass_k`, and `pass_n` come from the in-flight
ify context per `docs/saveify_contract.md`, not from a new loop.

---

## Names

A named save is `/saveify` plus the rest of the typed line after
flag strip, when the first token is not a reserved mode.
`display_name` is that remainder, trimmed. `slug` follows **Slug**
in the contract.

On save, a digits-only name is a name (`/saveify 2` stores `2`).
On delete, a digits-only token is a list position.

Empty `/saveify` auto-names per **Auto-name**. Auto-name never
overwrites: a taken slug uses `-2`, then `-3`, and does not fill a
gap. A named save of an existing slug does not append `-2`. It asks
to replace.

A user name that slugs to empty: **Error:** name is empty. Do not
write.

Parse `delete` and `list` before a named save when either is
the first token. `/saveify delete help` is a delete target,
not Help. `/saveify list` is not a snapshot name. Further
words stay on list. `/saveify list delete` is list, not a
save and not a delete.

---

## Save

No task and no phase table in this chat: **Error:** nothing to save.
Do not write a directory. Do not create a slug directory.

When there is context, build the snapshot from what this chat
already printed. Cite **Capture Task and Flags** in
`~/.claude/skills/phasify/SKILL.md` (repo: `.claude/skills/phasify/SKILL.md`).
Do not restate it. `task.txt` is that verbatim Task. When the plan
came from `/addify`, it is the combined body. Cite
`docs/phase_layout.txt` for the phase table. Do not restate that
layout. Fill task, flags, that table, the plan body, and the
kickoff from what was already printed, per **Snapshot**.

Write only the files **Snapshot** lists, and only the `meta.json`
keys in that section, in that order. Omit a file that has
nothing to hold. Do not write an empty file in its place. `kind`,
`stage`, and `next` are the contract’s. The snapshot is recoverable
artifacts, not the raw transcript, not unprinted reasoning, and not
hidden model state. Do not auto-save on exit.

Create the slug directory only as part of a successful save. A
failed write leaves any previous snapshot unchanged. Do not publish
a partial directory.

A new save prints the absolute snapshot directory and the display
name. Set `SAVE:` (below), including empty `/saveify`.

An existing slug on a **named** save does not write on this turn.
Print the contract’s replace confirm and stop. See **Confirm**.

---

## List (`/saveify list`)

First token `list` is a mode, not a name. It does not write,
delete, or retitle. It does not need an ify context. Empty
`/saveify` stays an auto-name save. Do not pass `--yes`.

Call `saveify ls`. The option label is the contract’s numbered
row (**List** in `docs/saveify_contract.md`): the text before
the tab. The slug after the tab is not part of the label.
Do not invent a second line. Print the rows only when
`AskUserQuestion` is unavailable.

No lines: `Nothing is saved.` Stop. Do not ask.

Otherwise follow **List select** in `docs/saveify_contract.md`.
Call `AskUserQuestion` (one question, single select)
with those labels, including `Choose none`. That is the primary
path. Do not load yet. If the tool is unavailable, print the
rows and a final line `Choose none`, then wait.

A reply that is only digits is that `#`. Run `saveify ls`
again. If that position is a different slug than the one
shown, stop. **Error:** list changed. Do not display.

Out of range: **Error:** not found: `<n>`.

A later slash command cancels the pending pick and runs that
command. `Choose none` stops. Any other reply re-asks. Do not load.

On a matching number: `resolve` that slug. Display only, per
**List select** in the contract. For `kind` `plan`, end the
printed `plan.md` at the line before `## Phased plan`. Leave
that heading and every line under it out. Print `table.txt`
next. That file is the only phase table in the display. Do
not say the next command is `/phasify`. Do not say the plan
is complete. Do not run `/phasify`. Do not execute a phase.

---

## Delete

Every delete requires confirmation. Never delete on the proposing
turn. Delete does not need an ify context and does not retitle.

| Typed | Effect |
|-------|--------|
| `/saveify delete` | Print the numbered list. Stop. Do not delete. |
| `/saveify delete <name>` | Show that row. Yes/no. Do not delete yet. |
| `/saveify delete <#>` | Show that row. Yes/no. Do not delete yet. |

Call `saveify ls`. Print the contract’s numbered row (**List**).
Show the text before the tab. Keep the slug after the tab for
the later `rm`. Do not invent a second line.
`#` is the 1-based position in that list at the moment it is
printed. `1` is the newest. `#` is not stored.

Match a non-digit name to `slug`, then to `display_name`,
case-insensitive, whole value. Zero matches or more than one:
**Error:**, then the list. Do not delete. `#` out of range:
**Error:** not found: `<n>`.

Bare `/saveify delete`:

1. Print the numbered list. Stop. Do not delete. Empty `ls` means
   nothing is saved. Do not ask for a pick.
2. The user picks names or numbers. Show that set. Ask yes/no.
   Do not delete yet. A pick that matches nothing: **Error:** and
   the list. Do not delete.
3. Apply only after yes. One confirm covers the set. The question
   for a set is `Delete these snapshot(s)? (yes/no)`.

While waiting for a pick, a new slash command cancels the pending
delete and runs that command.

---

## Confirm

Overwrite and delete ask yes/no. The user sees the row or the set
first. Same-line `yes` does not apply. Do not mutate on the
proposing turn.

Call `AskUserQuestion` for this yes/no. If that tool is missing,
print the question and a final line `Choose none`, then wait.
`Choose none` cancels (same as no). Same yes/no wait as phasify
Remove in `~/.claude/skills/phasify/SKILL.md` (repo:
`.claude/skills/phasify/SKILL.md`). Stop. The next user message
is the reply.

Use the contract’s confirm text:

```text
**Saveify — confirm replace.**
`<display_name>` already exists (`<absolute snapshot dir>`).
Saved <saved_at>. Verb `<verb>`. Stage: <stage>.

Replace this snapshot? (yes/no)
```

```text
**Saveify — confirm delete.**
- <n>  <saved_at>  <display_name>  <verb>, <phases> Phases, <stage>, <blocks> Blocks, <defers> Defers, <cwd>

Delete this snapshot? (yes/no)
```

The bullet is the **List** row.

| Reply | Effect |
|-------|--------|
| `yes` / `y` / `ok` / `confirm` | Apply. |
| `no` / `n` / `cancel` / `abort` | Cancel. Store unchanged. |
| A later command that is not yes/no | Cancel. Do not mutate. Then run that command. |
| Any other reply | Re-ask. Do not mutate. |

Case-insensitive. `/saveify yes` and `/saveify no` complete a
pending confirm. A yes/no reply with no slash does too.

On replace yes: rewrite that slug. On delete yes: `rm` those
directories with `--yes`. Then print `**Saveify — replaced.**` or
`**Saveify — deleted.**` and the path or the rows. On no:
`**Saveify — cancelled.**` The store stays.

On confirm, resolve a `#` again (`saveify ls`). If that position is
a different slug than the one shown, stop. Do not delete.
**Error:** list changed. If any `#` in a set moved, abort the whole
set.

On a replace confirm, if that slug’s `saved_at` is not the one
printed, stop. Do not replace. **Error:** list changed.

---

## CLI

Agents change the store only through this CLI. Do not invent a
different root, a different slug layout, or a hand-rolled delete.

Linux, from the sva-skills repo:

```text
./scripts/cli.sh saveify dir
./scripts/cli.sh saveify ls
./scripts/cli.sh saveify resolve <slug>
./scripts/cli.sh saveify rm <slug> --yes
```

Windows:

```text
scripts/cli.ps1 saveify dir
scripts/cli.ps1 saveify ls
scripts/cli.ps1 saveify resolve <slug>
scripts/cli.ps1 saveify rm <slug> --yes
```

| Subcommand | Effect |
|------------|--------|
| `dir` | Print the store root, one absolute path. Do not create it. |
| `ls` | Newest first. One snapshot per line. Empty store prints nothing and exits 0. |
| `resolve` | Print that slug’s absolute directory. |
| `rm` | Delete that slug only when `--yes` is present. |

`ls` prints the **List** row, then a tab, then the slug. Show
the row. Map a name or `#` to that slug, then call `resolve`
or `rm`. Do not invent a second line. `ls` does not require
`--yes`.

`resolve` takes a slug, not a list number and not a display name.

Pass `--yes` only after the user confirms. `rm` without `--yes`
refuses and does not delete. One `rm` per slug. Unknown slug on
`resolve` or `rm`: **Error:** not found: `<slug>`. Store unchanged.

Write snapshot bytes only under the slug directory of the root
`dir` printed, and only on a successful save. Filenames are the
contract’s Snapshot list. Do not mkdir the store root yourself.

---

## From files

Cite `docs/from_contract.md`. Do not restate it.
Help, tldr, and pass do not read files.

## Docify

Cite `docs/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, and pass do not write that file. Empty `/saveify` still writes the snapshot.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `SAVE:`.
Set the tmux window name per that contract on a save, including
empty `/saveify` and a replace proposal. The summary is three to
six words of the task, or the display name when the task has no
usable words (`docs/saveify_contract.md`). Whole name at most 48
characters. Do not invent a second prefix.

Help, tldr, pass, list, delete, `--help`, and `/?` do not retitle.
`SAVE` is not a phasify ancestor prefix.

## Hard rules

- Thin snapshot verb. Cite `docs/saveify_contract.md`. Do not paste
  a second store format. No `smart` mode. Do not restore
  (`/resumeify` does that). Do not auto-save on exit.
- CLI is `./scripts/cli.sh saveify` or `scripts/cli.ps1 saveify`:
  `dir`, `ls`, `resolve`, `rm`. `rm` only with `--yes`, and only
  after the user confirms. Do not invent another path.
- Empty `/saveify` is an auto-name save. It sets `SAVE:`. It is not
  short usage.
- Named existing slug: yes/no, then replace on a later reply.
  Auto-name never overwrites. Do not replace on the proposing turn.
- Every delete confirms. Bare delete lists, the user picks, then
  yes/no. Never delete on the proposing turn. Call `AskUserQuestion`
  for the yes/no. If that tool is missing, print the question and a
  final line `Choose none`, then wait. `Choose none` cancels (same
  as no). Same yes/no wait as phasify Remove.
- A later command that is not yes/no cancels, then runs. If `#`
  points at a different slug by confirm time, **Error:** list
  changed. Do not delete.
- No task and no phase table: **Error:** nothing to save. Do not
  write a directory.
- Capture task, flags, phase table, plan body, and kickoff per the
  contract. Cite phasify **Capture Task and Flags**. Snapshot files
  are recoverable artifacts, not the raw transcript.
- `/saveify list` uses **List select**, including `Choose none`.
  Call `AskUserQuestion`. If that tool is missing, print the rows
  and a final line `Choose none`. A saved context is displayed. For `kind` `plan`, the
  printed `plan.md` ends before `## Phased plan`, and
  `table.txt` is the only phase table. Display only. Do not
  say `/phasify`. Do not execute a phase. A `#` that moved
  is **Error:** list changed.
- Reserved first tokens are modes, not names, including `list`.
  Help, tldr, and pass print their page and stop. `savify` is
  an alias of `/saveify`. Empty `/saveify` is still an auto-name save.
- `Nimages` / `Npass`: promptify Flag parse order. Do not fork. Do
  not loop.
- Cite `docs/from_contract.md`, `docs/docify_contract.md`, and
  `docs/window_title.md`. Prefix `SAVE:`.
