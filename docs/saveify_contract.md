# Saveify contract

Shared contract. Lives in `docs/` like `docs/docify_contract.md`
and `docs/window_title.md`.
`/saveify` and `/resumeify` **cite this file**. Do not fork a
second store path, snapshot layout, auto-name, list order, or
confirm rule. Do not paste this file into a skill.

`/saveify` writes and deletes. `/resumeify` lists and restores.
`savify` is an alias of `/saveify`. `resumify` is an alias of
`/resumeify`. Optional leading `/`, case-insensitive. They are
not skill folders.

One snapshot is the recoverable ify artifacts of this chat.
After exit, only what was written here exists. No `smart` mode.

---

## Store

Per user on this machine. Same root as scratch and docify
config. Every new session on this machine can list these
directories. No sshub sync. No copy to another machine.

Linux:

`${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/saveify/<slug>/`

Windows:

`%LOCALAPPDATA%\sva-skills\saveify\<slug>\`

`<slug>` is one directory name. The store root is the
`saveify` directory with no slug. Create the slug directory
on a successful save. Do not create it for a refused save.

Agents change the store only through `./scripts/cli.sh
saveify` and `scripts/cli.ps1 saveify`.

---

## Snapshot

One directory per save. UTF-8 text. Omit a file that has
nothing to hold. Do not write an empty file in its place.

| File | When |
|------|------|
| `meta.json` | Every save. |
| `task.txt` | Every save. Verbatim Task. |
| `table.txt` | Latest aligned phase table. Omit when there is no plan. |
| `plan.md` | Plan body when one was printed. |
| `kickoff.md` | Planning kickoff or optimized prompt when one was printed. |
| `extra.md` | Results or debug notes when `kind` is `other`. |
| `images.txt` | Named images for this context. Omit when there are none. |

`table.txt` is the latest aligned table, statuses and reasons
included, in the `docs/phase_layout.txt` layout. Do not restate
that layout.

`task.txt` is the verbatim original ify task. When the plan
came from `/addify`, it is the combined body. Same rule as
phasify **Capture Task and Flags**: not the kickoff, not
`## Plan`, not a summary. Strip `Nimages` / `Npass` / `img`
tokens into `flags`. Leave the rest unchanged. A trailing newline
is fine. Do not rewrite.

`images.txt` is one absolute path per line. Copy each
resolved named image into `<snapshot>/images/`, basename
kept. A second file with the same basename is
`2-<basename>`, then `3-`. The line is the copy. Sources
are `img=` / `img:` on this save and named images already
in the in-flight context. Cite promptify **Named images**.
Do not fork that grammar. `flags` stores each `img` token
after the numbered image token and before the pass token.

`kind` is `plan` when this chat has a phase table or a printed
plan body. Otherwise `kind` is `other`.

A failed write leaves any previous snapshot unchanged. Do not
publish a partial directory.

---

## meta.json

One JSON object. UTF-8. Keys below, in this order, and no
other keys.

| Key | Value |
|-----|--------|
| `display_name` | Name shown in the list. |
| `slug` | Directory name. |
| `saved_at` | Local time `YYYY-MM-DDTHH:MM:SS`. No `Z`. |
| `cwd` | Absolute workspace path at save time. |
| `verb` | Last ify verb, lowercase, no slash. Not saveify or resumeify. |
| `kind` | `plan` or `other`. |
| `stage` | One line. No newline. |
| `next` | Suggested command, or empty. |
| `window_title` | Full window name that was set, or empty. |
| `flags` | Numbered flag tokens, then each `img` token, then the pass token. `[]` when none. |
| `pass_k` | Pass just finished or in progress. Integer. |
| `pass_n` | Npass value. Integer. Default `1` when Npass is absent. |

`pass_k` and `pass_n` are the Flags line "On pass k of N."
When the Flags row is absent, `pass_k` is `1` and `pass_n`
is `1`.

Stage:

| Situation | `stage` |
|-----------|---------|
| Plan exists, phasify has not run | `planned, not phasified` |
| Some work phase is not Done, and at least one is Done | `<latest Done id> Done; next <next id>` |
| No work phase is Done | `next <first work-phase id>` |
| Every work phase is Done | `complete` |
| `kind` is `other` | `<verb>` plus up to six words of the task |

Examples: `P0 Done; next P1`, `planned, not phasified`.

`next` is `/phasify` when `kind` is `plan` and any work phase
is not Done. Otherwise `next` is empty.

---

## What is saved

Saved: the files in **Snapshot**, filled from what this chat
already printed (task, table, plan, kickoff, results, or
debug notes) plus the `meta.json` fields.

Not saved:

- Hidden model state
- Unprinted reasoning
- The raw transcript
- A copy on another machine
- An sshub sync

Do not auto-save on exit.

---

## Names

A named save is `/saveify` plus the rest of the typed line.
`display_name` is that remainder, trimmed. `slug` is the
same string after the slug rules.

An empty `/saveify` is a real save. It is not short usage.
Same exception shape as empty `/phasify` = Next. It
auto-names. It does set the window title.

Reserved first tokens are modes, not names. Whole token,
case-insensitive, after flag strip: `delete`, `list`,
`help`, `tldr`, `pass`, `--help`, `/?`. `pass help` is
pass. These do not write a snapshot and do not retitle.

`list` is that mode. `/saveify list` is not a snapshot
name. On saveify, further words stay on list. On
resumeify, the remaining body exactly `list` is this
mode. Neither writes a snapshot.

### Slug

Lowercase. Each run of characters other than `a-z` and
`0-9` becomes one hyphen. Trim hyphens at the ends. At
most 48 characters; if the cut lands inside a word, drop
back to the previous hyphen when one remains.

A user name that slugs to empty: **Error:** name is empty.
Do not write.

### Auto-name

Used only when `/saveify` has no name.

Take the first six words of `task.txt`. Drop a word that
has no letter or digit. `display_name` is those words
joined by one space, original case. `slug` is that
display name under **Slug**.

No usable task words, including a Task of
`(original ify text not found)` and nothing else:
`display_name` and `slug` are
`ify-<verb>-<YYYYMMDD-HHMM>`, local time.
Example: `ify-plannify-20261005-0354`.

Auto-name never overwrites. If `<slug>` exists, use
`<slug>-2`, then `<slug>-3`, and so on until a free
directory. Do not fill a gap: a missing `<slug>` is used
even when `<slug>-2` exists.

A named save of an existing slug does not append `-2`.
It asks to replace. See **Confirm**.

---

## List

Newest `saved_at` first. `#` is the 1-based position in
that list at the moment it is printed. `1` is the newest.
`#` is not stored. It is not a stable id.

A token that is only digits is a position on resume and
on delete. On save, digits are a name (`/saveify 2`
stores the name `2`). `/resumeify 2` is position 2.
`/saveify list` is the list mode, not the name `list`.

Printed row, wherever a saved-context list is shown.
That is `/saveify list`, `/resumeify list`, empty
`/resumeify`, bare `/saveify delete`, and each
delete-confirm bullet. One shape. Do not invent a
second line.

```text
<n>  <saved_at>  <display_name>  <verb>, <phases> Phases, <stage>, <blocks> Blocks, <defers> Defers, <cwd>
```

Two spaces between `<n>`, `<saved_at>`, and
`<display_name>`. Then `<verb>,` and the rest. Phase
count once, immediately after the verb. Then the stage.
Then Blocks, then Defers, then cwd. Do not print the
phase count a second time. The words stay plural
(`0 Phases`, `1 Blocks`, `1 Defers`).

`<phases>` counts work phases in that snapshot’s
`table.txt`. Task and Flags do not count. A work phase
is a row whose Phase cell starts with `P` and digits
(`P0`, `P1 — Spec`) or with `Phase` and a number. Cite
`docs/phase_layout.txt` for the box. A markdown phase
table counts the same way. No `table.txt`, or no phase
table in it: `<phases>`, `<blocks>`, and `<defers>`
are 0.

`<blocks>` counts those work phases whose status is
`Blocked` or `Def-Blocked`. `<defers>` counts those
whose status is `Deferred` or `Def-Blocked`.
`Def-Blocked` counts in both.

`<stage>` is the stored `stage` string. Examples:
`P1 Done; next P2`, `planned, not phasified`.

Match a non-digit name to `slug`, then to `display_name`,
case-insensitive, whole value. Zero matches or more than
one: **Error:**, then this list. Do not delete or restore.

A directory with no `meta.json` is not a row.

---

## Commands

Help, `--help`, `/?`, tldr, pass, and `list` short-circuit
before any write or delete.

| Typed | Effect |
|-------|--------|
| `/saveify` | Auto-name save. Not list. |
| `/saveify <name>` | Save under that name. |
| `/saveify list` | Selection list. A saved context displays that snapshot. No phasify handoff. `Choose none` stops. |
| `/saveify delete` | Print the list. User picks. Then yes/no. |
| `/saveify delete <name>` | Show that row. Yes/no. |
| `/saveify delete <#>` | Show that row. Yes/no. |
| `/resumeify` | Selection list. A saved context restores. `Choose none` stops. |
| `/resumeify list` | Same selection. A saved context restores. `Choose none` stops. |
| `/resumeify <name>` | Restore that row. |
| `/resumeify <#>` | Restore that position. |

No ify context in this chat means no task and no phase
table. **Error:** nothing to save. Do not write a
directory.

`/resumeify` with no rows prints that nothing is saved.
Do not restore.

---

## Confirm

Overwrite and delete ask yes/no. Do not mutate on the
proposing turn. The user sees the row or the set first.
Same-line `yes` does not apply.

Cursor uses AskQuestion for that yes/no when the tool
exists. Grok and Copilot print the question and wait,
the same yes/no wait phasify Remove uses.

Bare `/saveify delete`:

1. Print the numbered list. Stop. Do not delete.
2. The user picks names or numbers. Show that set. Ask
   yes/no. Do not delete yet.
3. Apply only after yes.

One confirm covers the set. A pick that matches nothing:
**Error:** and the list. Do not delete.

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

The bullet is the printed row from **List**.

For a set, the question is `Delete these snapshot(s)? (yes/no)`.

| Reply | Effect |
|-------|--------|
| `yes` / `y` / `ok` / `confirm` | Apply. |
| `no` / `n` / `cancel` / `abort` | Cancel. Store unchanged. |
| A later command that is not yes/no | Cancel. Do not mutate. Then run that command. |
| Any other reply | Re-ask. Do not mutate. |

Case-insensitive. `/saveify yes` and `/saveify no`
complete a pending confirm. A yes/no reply with no
slash does too.

On replace yes: rewrite that slug. On delete yes: remove
those directories. Then print `**Saveify — replaced.**`
or `**Saveify — deleted.**` and the path or the rows.
On no: `**Saveify — cancelled.**` The store stays.

On confirm, resolve a `#` again. If that position is a
different slug than the one shown, stop. Do not delete.
Do not restore. **Error:** list changed.

On a replace confirm, if that slug's `saved_at` is not
the one printed, stop. Do not replace. **Error:** list
changed.

---

## Resume

No yes/no. `#` is the position when `/resumeify <#>`
runs.

Print the banner, then the saved body. `<name>` is
`display_name`. `<date>` is `saved_at`. For `kind`
`plan`, the printed `plan.md` ends at the line before
`## Phased plan`.

```text
**Resumeify — restored `<name>`.**
Saved <date>. Verb `<verb>`. Stage: <stage>. Workspace: <cwd>.
```

When `plan.md` exists, the next line is its absolute
path. That file is a verified plan file for phasify
locate. Do not invent a second locate rule.

When `images.txt` exists, the next lines are those
paths. They are part of the restored context. Read
them. Do not omit them.

When `cwd` is not this session's workspace, add:

```text
Workspace differs from this session. Not changing directory.
```

Do not change directory.

`kind` `plan` display, after the banner, the path line,
and the workspace line:

1. When `table.txt` exists, print `plan.md` and end that
   print at the line before `## Phased plan`. Leave that
   heading and every line under it out of the display.
   Then print `table.txt`. That print is the only phase
   table.
2. When `plan.md` exists and `table.txt` is absent, print
   `plan.md` in full.
3. When `plan.md` is absent, print `table.txt`.

The Task row in that table is the task (the same text
as `task.txt`).

`kind` `other`, in order: banner, full `task.txt`,
`kickoff.md` when present, `extra.md` when present.

When any work phase is not Done, the next command is
`/phasify`. Say so. When every work phase is Done, say
the plan is complete. `kind` `other` does not say either.

---

## List select

Empty `/resumeify`, `/resumeify list`, and `/saveify list`
present the saved-context list as one single-select question
when `ls` has at least one row. Do not only print the rows
and wait for `1` … `n`. Delete keeps its printed pick and
its yes/no. Empty `/saveify` is an auto-name save, not
this list.

No rows: `Nothing is saved.` Do not ask.

Options, in list order. One saved context per option. The
label is the printed **List** row (the text before the tab):
number, time, name, verb, phases, stage, blocks, defers, cwd.
No trailing slug. The last option’s label is exactly
`Choose none`.

`Choose none` selects nothing and stops. Do not restore.
Do not display a snapshot. Do not delete. Do not retitle.

Grok calls `ask_user_question`. One question.
`multi_select` is false. `question` is
`Which saved context should resumeify restore?` or, for
`/saveify list`,
`Which saved context should saveify display?`.
Each option `label` is the row or `Choose none`.
Each option `description` is `Restore this snapshot.`,
`Display this snapshot.`, or `Select nothing and stop.`
That call is the primary path. The tool may add its own
free-text row. That row is not `Choose none`. If
`ask_user_question` is unavailable, print the rows and a
final line `Choose none`, then wait.

Cursor calls `AskQuestion` with the same labels, one
question, single select. If `AskQuestion` is unavailable,
use that printed fallback.

Copilot has no selection tool. Print the rows and a final
line `Choose none`. Do not invent a widget.

A printed reply that is `Choose none`, any case, is that
option. It selects nothing and stops.

The invoking message is not the answer. A dismiss with no
answer is `Choose none`. A saved-context answer is that
row’s `#`, the leading number. Run `ls` again. If that
position is a different slug than the one shown, stop.
**Error:** list changed. Do not display. Do not restore.

`#` out of range: **Error:** not found: `<n>`.

Free text that is only digits is that `#`. On resumeify,
free text that is a name matches like `/resumeify <name>`.
On the `/saveify list` printed fallback, any other reply
re-asks. Do not load.

A later command that is not the pick cancels the pending
pick, then runs.

### Empty `/resumeify` and `/resumeify list`

A saved-context choice is a restore. Same reprint as
**Resume**, including the next-command sentence: `/phasify`
when any work phase is not Done, and the plan is complete
when every work phase is Done. That restore sets
`RESUME:`. The asking turn does not retitle. `Choose none`
does not restore. Empty `/resumeify` is not an auto-save.
Do not run `/phasify`.

### `/saveify list`

Display only. Do not hand off to phasify. Do not say
the next command is `/phasify`. Do not say the plan is
complete. Do not execute a phase. Do not retitle.
Do not pass `--yes`.

```text
**Saveify — `<name>`.**
Saved <date>. Verb `<verb>`. Stage: <stage>. Workspace: <cwd>.
```

Then the same body as **Resume**. For `kind` `plan`,
follow the three steps there: the printed `plan.md`
ends before `## Phased plan`, and `table.txt` is the
only phase table. Stop before the `/phasify` sentence.
`Choose none` does not display.

---

## Addify and phasify

Addify walks past `/saveify` and `/resumeify`. They are
not a task. The resume banner is not the task.

In a new session the only ify turn may be the resume
banner. That banner names the saved verb. The reprinted
Task is the task addify and phasify use.

Phasify may treat the snapshot as a verified plan file:
`<snapshot>/plan.md` when that file exists. Locate stays
the phasify rule (latest `## Phased plan`, or a verified
plan file). Task bytes follow **Capture Task and
Flags**. Cite `.grok/phasify/SKILL.md`. Do not restate
those sections.

---

## CLI

Next phase. Early dispatch, same shape as `docify`, in
`scripts/cli.sh` and `scripts/cli.ps1`. Libs:
`scripts/lib/saveify_resolve.sh` and
`scripts/lib/saveify_resolve.ps1`.

```text
saveify dir
saveify ls
saveify resolve <slug>
saveify rm <slug> --yes
```

| Subcommand | Effect |
|------------|--------|
| `dir` | Print the store root, one absolute path. Do not create it. |
| `ls` | Newest first. One snapshot per line. Empty store prints nothing and exits 0. No `--yes`. |
| `resolve` | Print that slug's absolute directory. |
| `rm` | Delete that slug only when `--yes` is present. |

`ls` prints the **List** row, then a tab, then the slug:

```text
<printed row>\t<slug>
```

The printed row is the shape in **List**. Skills show
that text and drop the tab and the slug. The slug is
how a selected `#` maps to `resolve` or `rm`. `resolve`
takes a slug, not a list number and not a display name.
`ls` does not prompt and does not require `--yes`.

`rm` without `--yes` refuses and does not delete. The
skill passes `--yes` only after the user confirms.

Unknown slug on `resolve` or `rm`: **Error:** not found:
`<slug>`. Store unchanged.

---

## Errors

Print **Error:** and do not write or delete.

| Condition | Error |
|-----------|-------|
| No task and no phase table | nothing to save |
| User name slugs to empty | name is empty |
| Name or `#` matches nothing | not found: `<name>` |
| `#` out of range | not found: `<n>` |
| Name matches more than one row | ambiguous: `<name>`, then the list |
| `#` or `saved_at` changed before confirm | list changed |
| `rm` without `--yes` | `--yes` required |
| Unknown slug on `resolve` or `rm` | not found: `<slug>` |

---

## Window title

Cite `docs/window_title.md`. Prefix for saveify: `SAVE:`.
Prefix for resumeify: `RESUME:`. Whole name at most 48
characters. Do not invent a second prefix.

A save, including empty `/saveify`, sets `SAVE:`. The
summary is three to six words of the task, or the
display name when the task has no usable words.

A restore sets `RESUME:`. The summary is the words after
the ancestor prefix in `window_title`. When that is
empty, use the first words of `display_name`.

The asking turn of empty `/resumeify`, `/resumeify list`,
and `/saveify list` does not retitle. `Choose none` does
not retitle. A saved-context choice that restores sets
`RESUME:`. `/saveify list` does not retitle. Delete, help,
tldr, pass, `--help`, and `/?` do not retitle.

`SAVE` and `RESUME` are not phasify ancestor prefixes.
Phasify keeps the saved verb's prefix.

---

## From files

Cite `docs/from_contract.md`. Do not restate it.
Help, tldr, and pass do not read files.

---

## Docify

Cite `docs/docify_contract.md`. Do not restate it.

---

## Out of scope

- Copying snapshots to other machines
- Saving unprinted reasoning or the full transcript
- Auto-save on exit
- A `/savify` or `/resumify` skill directory
- sshub sync
- Hidden model state

---

## Cite

A few lines in the verb's `SKILL.md`. Do not paste this
file. Put the same cite in `.grok/<verb>/`,
`.cursor/skills/<verb>/`, and `.copilot/skills/<verb>/`.

```markdown
Cite `docs/saveify_contract.md` **List select**. Writes and deletes go through that store. Help, tldr, pass, and list do not write. Empty `/saveify` is an auto-name save. `/saveify list` uses that selection: a saved context is displayed and does not hand off to phasify. `Choose none` stops.
```

Resumeify cites the same file. Empty `/resumeify` and
`/resumeify list` use **List select**. A saved context
restores so `/phasify` can continue. `Choose none` stops.
