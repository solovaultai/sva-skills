---
name: resumeify
description: >-
  Resumeify — list and restore a saved ify context. Empty /resumeify
  and /resumeify list show saved contexts in one selection, newest
  first. Choose none stops without restore or retitle. A saved
  context restores so a later /phasify can continue. /resumeify <name> or /resumeify <#>
  reprints that row so a later /phasify can continue. # is the current
  list position (1 = newest),
  not a stable id. Use when the user runs /resumeify, "resumify", or
  wants to resume a saved ify context. Does not plan or execute
  phases. Does not write or delete. Print a complete reference with
  `/resumeify help` or `/resumeify --help` (also `/?`). `/resumeify
  tldr` prints the short page. `/resumeify pass` prints the Pass
  (Npass) subsection (also `pass help`). Strips every numbered image
  directive, including negatives, multiples, and zero. Does not read
  scratch and does not print the imagify zero error. Npass stays the
  first numbered instance. Resumeify does not run its own second
  pass loop.
argument-hint: "[<name|#|list>]"
user-invocable: true
---

# Resumeify (= list and restore)

You are running **Resumeify** (`/resumeify`) — a **thin restore front
end** in the Promptify family. You list saved ify contexts and
reprint one. You do not plan, execute phases, or delete. You do not
run `/phasify`.

1. If a list pick is pending, handle that reply first.
2. Parse help / tldr / pass / list / flags on the typed line.
3. Empty remaining body: selection list. Do not restore until a
   saved context is chosen. `Choose none` stops.
4. Remaining body exactly `list`: same selection. Do not restore
   until a saved context is chosen.
5. A name or `#`: load that row and reprint it.
6. Stop. A later `/phasify` continues from a restore.

Cite `docs/saveify_contract.md` **List select**. List and restore
go through that store. Help, tldr, and pass do not write. Empty
`/resumeify` and `/resumeify list` use that selection. A saved
context restores so `/phasify` can continue. `Choose none` stops.
Do not paste a second copy of the rule.

Claude Code calls `AskUserQuestion` (one question, single select).
That is the primary path. If `AskUserQuestion` is unavailable,
print the rows and a final line `Choose none`. A reply of
`Choose none` selects nothing and stops. Do not invent a
selection widget.

Follow `~/.claude/skills/promptify/SKILL.md` for **Flag parse order**.
Do not fork a second parse. Do not run a second pass loop.

Canonical slash is `/resumeify`. `resumify` is an alias of
`/resumeify`, not a folder.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**.
- Remaining body exactly `tldr` (case-insensitive):
  **read and print** `references/TLDR.md` (this skill folder) and
  **stop**. Extra tokens after `tldr` are a **name**, not tldr.
  There is no `tldr help` alias.
- Remaining body exactly `pass` or `pass help` (case-insensitive):
  print the **Pass (`Npass`)** section of `references/HELP.md` and
  **stop**. There is no `/pass` skill.
- Remaining body exactly `list` (case-insensitive): **List select**.
  Not a snapshot name. Not Help.

Do not list, resolve, or retitle on help, tldr, or pass. `help me …`
is a **name**, not Help. `list` is reserved only when it is the whole
remaining body. A flag-only line (`/resumeify 2pass`, `/resumeify 1image`)
is **empty** after the strip: selection list. `Choose none` stops.

---

## Flag parse order (`Nimages` / `Npass`)

On the **typed line only**. Do not scan snapshot files for flags.

**Image family.** Strip every numbered image directive on the
typed line. `1image -3image` strips both. A negative count is
one directive.

Accepted shapes (case-insensitive). N is digits, including 0:

- `Nimage`, `Nimages`, `N-image`, `N-images`, `N image`, `N images`
- `imageN`, `imagesN`
- `-Nimage`, `-Nimages`, `-N-image`, `-N-images`, `-N image`, `-N images`
- `image-N`, `images-N`

`0image`, `image0`, and `-0image` are in that list, and so is every
other accepted shape whose digits are 0. Strip them. Do not print
`Error: image count starts at 1`.

`image -3` is not a negative directive. When that `image` is the
first token, it is `1image` and the `-3` stays on the line. Use
`-3image` or `image-3` for a negative. `image -3image` is two
directives when `image` is the first token (`1image` and `-3image`).
Both are stripped. Unnumbered `image` / `images` are not directives
except that leading `image`. `images` and a non-leading `image` stay
unnumbered.

**Pass family.** The first numbered `Npass`, `N-pass`, or `N pass`
is the pass flag. A later numbered pass token stays on the line.
Do not take the largest N. Unnumbered `pass` / `passes` are not
pass flags.

Strip every image directive and that first numbered pass. They are
not the snapshot name. Resumeify does not read scratch images, does
not run a pass loop, and does not print the scratch or Npass
acknowledgements.

## Named images (`img`)

Cite promptify **Named images**. Do not fork that grammar.
When `images.txt` exists in the snapshot, print those paths
after the plan path. They are part of the restored context.
Read them. `img=<file>`, `img:<file>`, `img=[a,b]`, and
`img:[a,b]` on this line add those files for this restore.
Do not rewrite the snapshot. Print the named-images ack when
this line has an `img` token.

---

## List (empty `/resumeify`)

Remaining body empty: list only. This is not a save. Do not restore.
Do not retitle.

Run, from this repo:

```text
./scripts/cli.sh saveify ls
scripts/cli.ps1 saveify ls
```

Use `./scripts/cli.sh` on Linux and Git Bash. Use `scripts/cli.ps1`
on Windows. Do not call `saveify rm`. Do not delete. Do not invent a
store path. A directory the CLI omits is not a row.

`ls` is newest first and exits 0 when nothing is saved. One snapshot
per line: the **List** row from `docs/saveify_contract.md`, then a
tab, then the slug. The printed row is the text before the tab.
Keep the slug. Do not invent a second line. Do not re-sort.

`<n>` is the 1-based position in that line order. `1` is the newest.
It is not stored and it is not a stable id.

No lines: print `Nothing is saved.` and stop. Do not ask.

Otherwise follow **List select** in `docs/saveify_contract.md`.
Print this banner, then the selection. On the `AskUserQuestion`
path, do not also print the rows.

```text
**Resumeify — saved contexts.**
```

Call `AskUserQuestion` (one question, single select), including
`Choose none`. That is the primary path. If the tool is
unavailable, print the rows and a final line `Choose none`, then
wait.

`Choose none` stops. Do not restore. A saved-context
choice is a restore per **List select**. Set `RESUME:` on that
restore. Do not run `/phasify`.

---

## List select (`/resumeify list`)

Remaining body exactly `list`. Same numbered list as empty
`/resumeify`. This is not a save. The asking turn does not retitle
and does not restore.

No lines: `Nothing is saved.` Stop. Do not ask.

Otherwise use the same selection as empty `/resumeify`. Follow
**List select**. Call `AskUserQuestion` (one question, single
select), including `Choose none`. That is the primary path.
Do not restore yet. If the tool is unavailable, print the rows
and a final line `Choose none`, then wait.

A digits-only reply is that `#`. Run `saveify ls` again. If that
position is a different slug than the one shown, **Error:** list
changed. Do not restore.

A name uses the restore match below (slug, then display name).

Out of range, or a name that matches nothing: **Error:**, then the
list. Do not restore. More than one display name: **Error:**
ambiguous, then the list.

A later slash command cancels the pending pick and runs that
command. `Choose none` stops. Any other reply re-asks. Do not restore.

On a match: this is a restore. Follow **Restore** and **Reprint**,
including the `/phasify` sentence when any work phase is not Done,
and the plan is complete when every work phase is Done. Set
`RESUME:` on that restore. Do not run `/phasify`.

---

## Restore (`/resumeify <name>` or `/resumeify <#>`)

The remaining body is one target. It is not an ify verb to run.
`/resumeify phasify` looks up a snapshot named `phasify`.

A token that is only digits is a position. `/resumeify 2` is
position 2, not the snapshot whose name is `2`.

Anything else is a name. Match `<slug>`, then `<display_name>`,
case-insensitive, whole value. A slug hit wins. Do not also require
the display name.

| Result | Effect |
|--------|--------|
| One row | Remember its `<slug>` and `<n>`. |
| None | **Error:** not found: `<name>` or not found: `<n>`, then the list. Stop. |
| More than one display name | **Error:** ambiguous: `<name>`, then the list. Stop. |

Map the row to a slug, then resolve. `resolve` takes a slug, not a
list number and not a display name.

```text
./scripts/cli.sh saveify resolve <slug>
scripts/cli.ps1 saveify resolve <slug>
```

When the target was a `#`, run `saveify ls` again before you read.
If position `<n>` is a different slug, **Error:** list changed. Do
not restore.

Unknown slug: **Error:** not found: `<slug>`. Do not invent files.

Read `meta.json` in the resolved directory. Banner fields are that
file's `display_name`, `saved_at`, `verb`, `stage`, `cwd`, and
`kind`. Do not invent keys. Omit a snapshot file that is absent. Do
not write a substitute.

---

## Reprint

`<name>` is `display_name`. `<date>` is `saved_at`. Print the banner,
then the saved body. For `kind` `plan`, the printed `plan.md` ends
at the line before `## Phased plan`.

```text
**Resumeify — restored `<name>`.**
Saved <date>. Verb `<verb>`. Stage: <stage>. Workspace: <cwd>.
```

When `plan.md` exists, the next line is its absolute path. That file
is phasify's verified plan file. Cite `.claude/skills/phasify/SKILL.md`
locate. Do not invent a second locate rule. Do not print a second
path.

When `cwd` is not this session's workspace, add:

```text
Workspace differs from this session. Not changing directory.
```

Do not change directory.

`kind` `plan` display, after the banner, the path line, and the
workspace line:

1. When `table.txt` exists, print `plan.md` and end that print at
   the line before `## Phased plan`. Leave that heading and every
   line under it out of the display. Then print `table.txt`. That
   print is the only phase table.
2. When `plan.md` exists and `table.txt` is absent, print `plan.md`
   in full.
3. When `plan.md` is absent, print `table.txt`.

The Task row in that table is the task.

`kind` `other`, in order: banner, the `plan.md` path line when that
file exists, the workspace line when `cwd` differs, full `task.txt`,
`kickoff.md` when present, `extra.md` when present.

After a `kind` `plan` reprint: if any work phase is not Done,
including none Done yet, say the next command is `/phasify`. If
every work phase is Done, say the plan is complete. Task and Flags
are not work phases. When `table.txt` is absent and `kind` is
`plan`, say the next command is `/phasify`. `kind` `other` says
neither.

Do not run `/phasify`. The banner is not the task. The reprinted
task is the task a later `/phasify` uses.

---

## From files

Cite `docs/from_contract.md`. Do not restate it.
Help, tldr, and pass do not read files.

## Docify

Cite `the docify skill's references/docify_contract.md`. Do not restate it.
This skill does not write or delete a snapshot.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `RESUME:`.
Set the tmux window name per that contract on a real restore.
The summary is the words after the ancestor prefix in the snapshot
`window_title`. When that is empty, use the first words of
`display_name`. Do not invent a second prefix.
Help, tldr, pass, `Choose none`, and the asking turn do not
retitle. A saved-context restore does, including empty
`/resumeify` and `/resumeify list`.

## Hard rules

- Thin front end: list or restore per `docs/saveify_contract.md`.
  Do not plan. Do not execute phases. Do not run `/phasify`.
  No `smart` mode.
- Store access is `saveify ls` and `saveify resolve` only
  (`./scripts/cli.sh`, or `scripts/cli.ps1` on Windows). Do not
  delete. Do not call `saveify rm`. Do not paste a second store
  format.
- Empty `/resumeify` and `/resumeify list` use **List select**.
  Call `AskUserQuestion`. If that tool is missing, print the rows
  and a final line `Choose none`. `Choose none` stops. A saved
  context restores (next command
  `/phasify` when any work phase is not Done). Not a save. The
  asking turn does not retitle. No rows: `Nothing is saved.`
- `#` is the current list position (`1` = newest), not a stable id.
  Digits are always a position. If that position's slug changed
  before you read, **Error:** list changed. Do not restore.
- Banner, then the saved body. The `plan.md` path in the banner is
  phasify's verified plan file. Cite `.claude/skills/phasify/SKILL.md`.
- A different `cwd` is announced. Do not change directory.
- Unfinished plan: the next command is `/phasify`. All work phases
  Done: the plan is complete. `kind` `other` says neither.
- Image directives: strip every numbered one on the typed line,
  including negatives and zero. They are not a snapshot name. Pass
  stays the first numbered instance. Do not read scratch. Do not
  loop. Do not print `Error: image count starts at 1`.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `tldr`: print
  `references/TLDR.md` and stop. Exact `pass` / `pass help`: print
  the **Pass (`Npass`)** section and stop.
- Cite `docs/window_title.md`. Prefix `RESUME:`. Set it on a real
  restore, including empty `/resumeify` and a `/resumeify list`
  pick. Help, tldr, pass, `Choose none`, and the asking turn do
  not retitle.
- Canonical slash is `/resumeify`. `resumify` is an alias, not a folder.
