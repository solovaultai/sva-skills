# Optify contract

Shared contract. Lives in `docs/` like `docs/docify_contract.md`
and `docs/window_title.md`.
Every ify verb **cites this file**. Do not fork a second
optify dialect, store path, host map, or handoff file.

Optify is a verb (`/optify`). `optify` with no slash is
the same command. The skill cites this file and does not
restate it.

This file is the source of truth for the byte copy at
`<optify-skill>/references/optify_contract.md`. Agents
read that copy. See **Cite**.

---

## Store

One file for every host:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env
```

Claude, Grok, Copilot, and Cursor share that file. One
off on this machine is off for all four. No per-host
file. No second path. `./scripts/cli.sh optify` and
`scripts/cli.ps1 optify` are the only writers. Agents
do not edit the file by hand.

Keys only. One line each, `key=value`. Rewrite the file
so a second write does not duplicate a key. No other
keys. A value outside the table is rejected and does
not change the file.

| Key | Value |
|-----|--------|
| `enabled` | `on` or `off`. A missing file means on. |
| `before` | `1` when that one-shot is armed. The key is absent when it is clear. |
| `after` | `1` when that one-shot is armed. The key is absent when it is clear. |

A missing file is `enabled=on` with `before` and `after`
clear. `/optify on` writes `enabled=on`. `/optify off`
writes `enabled=off`. Off leaves `before` and `after`
as they are. Only `enabled=off` is off. A missing
`enabled` key in a file that exists is on.

Clearing a one-shot removes that key and leaves the
other keys. The skill does that through the same CLI.

Token match for the commands below is case-insensitive.
The stored words and the window-title summary are
lowercase.

---

## Handoff

Written before a clear or a new chat. A compact does
not write this file. The next ify verb reads it and
deletes it after that read. An optify command does
not read it and does not delete it.

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify-handoff.md
```

Contents, in this order. Cap about 40 lines. Shorter
is the usual file. Do not pad. If the file would pass
about 40 lines, shorten the files-touched list first
and keep the other parts.

- Previous verb.
- Task line.
- Flags.
- Phase table statuses (phase id and status).
- Files touched (paths).
- The next command the user already typed.

Omit the next-command line when the user has not
typed that command. Do not invent one.

A later clear or new chat overwrites this file.
The CLI does not own it. The skill writes it. The
next ify verb deletes it.

---

## Commands

Identical on every AI. No host-specific verb.
`/optify-claude` is not a command.

- `/optify` — print on/off, whether `before` is
  armed, whether `after` is armed, and the host
  action that would run if an optimize happened
  on this turn. Do not compact. Do not clear. Do
  not write the handoff. Do not retitle.
- `/optify on` — set `enabled=on`. Default when
  the file is absent.
- `/optify off` — set `enabled=off`.
- `/optify now` — optimize this turn, then stop.
  Works even when off.
- `/optify before` — arm the `before` one-shot
  for the start of the next phasify phase.
- `/optify after` — arm the `after` one-shot for
  the end of the current phase, or the end of the
  next phase if none is running.
- `/optify help`, `tldr`, `pass` — print only.
  No store change. No window retitle.

The first token `on`, `off`, `now`, `before`,
`after`, `help`, `tldr`, or `pass` is reserved.
Each of those tokens stands alone. A further token
on the same line is **Error:** plus the short usage,
and the store stays as it was. Any other first token
is the same error. `--help` and `/?` are not optify
syntax.

`/optify` with no token is the status print above.
It is not an error.

---

## Two layers

Both layers are on by default (missing file, or
`enabled=on`). `/optify off` turns both off. The
short router stays on disk either way, because the
host injects all of SKILL.md.

### Read less

Short SKILL.md routers. Mode bodies live in
references and are read only for the mode just
parsed. When optify is off, read the full reference
set.

### Session boundary

Pick clear or compact from **Host action map**.
Name that row in one line:

```text
Host: <row>.
```

`<row>` is the label in that map (`Claude Code,
continue`, `Copilot Chat`, `Cursor`, and the
others).

When the action is a clear or a new chat, write
the handoff first, then print the exact host
command, then stop the turn. Do not start the
heavy read in the same turn as a clear.

When the action is a compact and the host row
has a continue line, print `/compact` and the
focus sentence, then stop the turn. Do not write
the handoff. A host with no continue row uses its
only row instead. That row is a new chat or a new
conversation.

The focus sentence keeps the plan, the phase id,
and the files. Every compact row uses those three
items. The wording of the sentence comes from this
effort.

Force commands still do this when the switch is
off. They write the handoff when the action is a
clear or a new chat, and they print the host
command. They do not turn the switch on. Force
commands are `/optify now`, and a `before` or
`after` one-shot when it fires. Arming `before`
or `after` while off only sets that key.

A context meter at or above about 70% runs only
while the switch is on. A verb change does not
optimize. A phase mutation does not optimize.
When the switch is on, a mutating phase may
check that meter. The mutation is the moment of
the check. It is not the trigger.

---

## When to clear

A clear is a new effort. Use the host row for a
new verb or a new chat. A clear happens only
when an optimize is already firing for `/optify
now`, an armed `before` or `after`, or the
meter. A verb change is not that firing. A
phase mutation is not that firing.

- `/optify now` when the next work is a different
  effort.
- An armed `before` or `after` is firing, and
  the next work is a different effort.

`/optify now` with no next verb on the line is
the same effort, so it compacts. Plannify, then
phasify, does not clear and does not optimize.

---

## When to compact

A compact is the same effort. Same effort means
the same verb is continuing, or the next phasify
phase still needs the plan. Use the host row for
continue when that row has one.

Compact when one of these is true:

- `/optify now` and this is the same effort.
- An armed `before` or `after` is firing, and
  this is the same effort.
- The host shows a context meter at or above
  about 70%, the switch is on, and this is the
  same effort.

If the host has no meter, do not invent a
percentage. With no meter, compact only on `now`
or an armed `before` or `after`. A verb change
is not a compact and not a clear.

Do not compact between every phase when nothing
is armed. A phase boundary alone is not a compact.
`phasify full` is not this compact. Between its
phases it runs Partial compress, below.
A phase mutation alone is not an optimize. Do
not replace "about 70%" with another cutoff.

An armed `after` at the end of a phase is an
optimize. Clear versus compact still follows the
rules above. The usual case is the same plan, so
the action is compact.

---

## Partial compress

A partial compress is a minor clearout inside one `phasify full` or
`phasify full rundefer` run. It is not a compact and not a clear.

It runs only between those phases, after the phase banner, when a
full optimize did not fire on that boundary.

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
`/new`. Do not stop the turn. Continue the next phase in the same
run.

A context meter at or above about 70% (switch on), an armed
`before`, and an armed `after` are still a full optimize. They
stop the turn. Do not also partial-compress that boundary. The
switch off does not turn off this partial compress. The meter
check still runs only while the switch is on.

---

## Host action map

Print the command. The user runs it. The skill
does not press `/compact` or `/clear`.

One `Host:` line, then the command.

- **Claude Code, continue.** User runs `/compact`
  plus the focus sentence (keep the plan, phase
  id, and files).
- **Claude Code, new verb.** User runs `/clear`,
  then retypes the next command. The new session
  reads the handoff file.
- **Copilot CLI, continue.** `/compact` plus the
  same focus sentence.
- **Copilot CLI, new verb.** Print `/clear` or
  `/new` as that one line. Do not tell the user
  to change model, tools, or reasoning.
- **Copilot Chat.** Either case, print: start a
  new conversation; the next turn reads the
  handoff file. Chat has no `/compact`.
- **Grok Build, continue.** `/compact` with the
  focus sentence, while the session still fits.
  Do not call the xAI HTTP compaction API. This
  row has no second command when the session
  does not fit.
- **Grok Build, new verb.** Print `/clear` or
  `/new` as that one line. Do not call the xAI
  HTTP compaction API.
- **Grok chat (grok.com).** Print: start a new
  chat; the next turn reads the handoff file.
- **Cursor.** Continue and a new verb print the
  same command string: start a new chat and read
  the handoff file.

Copilot Chat, Grok chat, and Cursor have no
continue row. When the effort is the same, they
still use that only row. The action is a new
chat or a new conversation, so write the handoff
first.

On Copilot CLI and Grok Build, `/clear` or `/new`
is the whole new-verb command. Do not add a third
string. Do not drop either word.

---

## Phasify

At the start of a mutating phase, optimize and
stop only when one of these is true:

- `before` is armed. Clear `before` when that
  shot fires. This fires when the switch is off.
  It does not set `enabled=on`. It writes the
  handoff when the action is a clear or a new
  chat, prints the host command, and stops.
- The switch is on, the host shows a context
  meter at or above about 70%, and this is the
  same effort. That is the meter check. Use the
  continue row when this host has one, and do
  not write the handoff. A host with no continue
  row uses its only row and writes the handoff.
  If the host has no meter, do not invent a
  percentage and do not optimize.

A verb change does not optimize, on or off.
`before` already clear does not optimize. There
is no `before` key to remove unless that shot
fired. Plannify, then phasify, does not
optimize. Do not clear `after` at the start.

A start optimize stops the turn. An armed `after`
waits for the phase that actually finishes.

At the end of a phase, if `after` is armed, print
the phase banner and the table first, then the
status update, then optimize, then stop. Status
updates still land before an after stop. Clear
`after` when that shot fires.

`phasify full` and `phasify full rundefer` run
Partial compress between phases when neither
start check fired and `after` is not armed.
That clearout does not stop the turn. It does
not replace the checks above.

Howto, show, and explain do not optimize.

---

## Skill diet

Notes for other verbs. This contract documents
them. It does not edit those skills.

- **Phasify.** Short router. Mode files live under
  references. When optify is on, read the parsed
  mode plus the table-layout reference. When
  optify is off, read every mode reference. Do
  not read HELP.md except for `/phasify help`.
- **Promptify sections** other verbs may open
  when optify is on: Flag parse, Scratch images,
  Named images, Multi-pass, Hard rules.
  Plannify, askify, and runnify read those
  headings only when on, and the whole promptify
  file when off.
- **Frontmatter** description stays a short
  catalog line.

The phrase "table-layout reference" is the
reference that holds the phase-table layout. This
contract does not give it another filename.

---

## Window title

Cite `docs/window_title.md` for the tmux command,
the 48-character cap, and the rule that help,
tldr, pass, and empty usage do not retitle.

Prefix for this verb: `OPT:`. The summary is the
subcommand word alone.

```text
OPT: on
OPT: off
OPT: now
OPT: before
OPT: after
```

Help, tldr, pass, and `/optify` with no token do
not retitle. `/optify` with no token is empty
usage for that rule. It still prints status.

```markdown
## Window title

Cite `docs/window_title.md`. Prefix for this verb: `OPT:`.
Summary is the subcommand (`on`, `off`, `now`, `before`, `after`).
Help, tldr, pass, and empty usage do not retitle.
```

---

## Errors

Print **Error:** and do not change the store.

| Condition | Error |
|-----------|-------|
| First token is not reserved, including `--help` and `/?` | unknown optify command |
| A reserved token is followed by another token | unknown optify command |
| Store value outside **Store** | rejected; store unchanged |

Then the short usage, on its own line:

```text
Usage: /optify [on|off|now|before|after|help|tldr|pass]
```

That usage line is the short usage. Do not print
a different one.

---

## Out of scope

- The skill cannot press `/compact` or `/clear`
  itself.
- No timer compact.
- No model changes.
- No xAI HTTP compaction API.
- `.claude-web/` and `.grok-web/` are not part of
  this verb.

---

## Cite

A few lines in the verb's `SKILL.md`. Do not paste
this file. Put the same cite in `.grok/optify/`,
`.cursor/skills/optify/`, `.copilot/skills/optify/`,
and `.claude/skills/optify/`.

Ship a byte copy of this file at
`<optify-skill>/references/optify_contract.md`
(`.claude/skills/optify/references/optify_contract.md`,
and the same path under `.cursor/skills/optify/`,
`.grok/optify/`, and `.copilot/skills/optify/`).
Agents read that copy. It is this file. Edit this
file, then copy it again. Do not edit the copy in
place.

Workspace `docs/optify_contract.md` applies when
the workspace is sva-skills. In any other project
that path is absent. Other verbs cite the optify
skill's `references/optify_contract.md`.

```markdown
Cite the optify skill's `references/optify_contract.md`. On: short router, and only the mode just parsed. Off: the full reference set. Clear and compact follow that contract. Help, tldr, pass, and empty usage do not retitle.
```
