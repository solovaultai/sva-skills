# Family window-title contract

Shared contract. Lives in `docs/` like `docs/smart_contract.md`.
Every ify verb **cites this file**. Do not fork a second prefix
table, length rule, or rename command.

The label is the **tmux window name** on the status bar. That bar
lists every Grok window in the client. Grok repaints the pane title
on each turn, and there is no agent command for `/rename`, so the
pane title is not this label.

```text
tmux rename-window 'PLAN: ify window titles'
```

---

## When

On a **real task**, set the name as soon as the verb is known and a
rough summary can be taken from the user's text, before the long
read. Tighten the summary once the plan, bug, or answer is clear.
Same prefix both times.

Leave the name when the turn ends. Do not restore `gHHMMSS`.

**Do not retitle** help, `--help`, `/?`, tldr, `pass`, `pass help`,
or empty usage. Empty `/phasify` is Next, so it does set the name.
Empty `/saveify` is a real save, so it does set the name. Empty
`/resumeify` lists and leaves the name.

---

## Name

The whole window name is at most **48 characters**. Summary is three
to six words. No newline. If the name would exceed 48, drop words
from the end of the summary until it fits. Never cut the prefix.

| Verb | Name |
|------|------|
| plannify | `PLAN: <summary>` |
| debugify | `DBG: <summary>` |
| runnify | `RUN: <summary>` |
| promptify | `PROMPT: <summary>` |
| askify | `ASK: <summary>` |
| ify | `IFY: <summary>` |
| fromify | `FROM: <summary>` |
| docify | `DOC: <summary>` |
| addify | No prefix of its own. Re-apply the **ancestor** verb's row to the combined text. |
| phasify | `PHASE:P<n>/<total>:<PREFIX>: <summary>` |
| saveify | `SAVE: <summary>` |
| resumeify | `RESUME: <summary>` |

`<PREFIX>` is the ancestor's token (`PLAN`, `DBG`, `RUN`, `PROMPT`,
`ASK`, `IFY`, `FROM`, `DOC`). `<summary>` is a few words of the recovered Task, not
a new sentence. If this window already shows `<PREFIX>: <summary>`,
keep that summary text.

`<n>` is the work phase this run is on (`P0` prints as `P0`).
`<total>` is the work-phase count. Task and Flags do not count.
Next-N, run-to-end, stop-before-end, rundefer, and runblock update
the name at the **start** of each phase. Show, todo, and explain use
the phase that mode is about. Help, tldr, and pass do not retitle.

```text
PLAN: ify window titles
DBG: inbound route mismatch
PHASE:P1/4:PLAN: ify window titles
```

---

## Command

Run only when `TMUX` is set. Otherwise do nothing. Do not print an
OSC title. Do not write `summary.json`. Do not type `/rename`.

```bash
if [ -n "${TMUX:-}" ]; then
  tmux rename-window 'PLAN: ify window titles'
fi
```

Substitute the name from the table. Quote it.

Plannify, askify, promptify, ify, and phasify's read-only modes may
run this command. It is not a repo edit, commit, install, or build.

---

## Frame

The focused GNOME frame shows the window name when `~/.tmux.conf` has:

```tmux
set -g set-titles on
set -g set-titles-string "#{window_name}"
```

`./scripts/cli.sh install` (and `install all` / `pullinst`) writes those
lines if they are missing or different, then reloads a running tmux
server. `./scripts/cli.sh install tmux` and `./scripts/cli.sh tmux` do
only that. A second run does not add a second copy. Skills do not edit
the file themselves. Do not kill the server.

---

## Cite

A few lines in the verb's `SKILL.md`. Do not paste this file. If that
`SKILL.md` is near 500 lines, one hard-rule bullet is enough.

```markdown
## Window title

Cite `docs/window_title.md`. Prefix for this verb: `PLAN:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.
```

Put the same cite in `.grok/<verb>/`, `.cursor/skills/<verb>/`, and
`.copilot/skills/<verb>/`. Off tmux the command does nothing.

---

## Adding a verb

1. Add one row to the prefix table in this file.
2. Thin cite in that verb's `SKILL.md` in all three trees.
3. Do not invent a second title dialect.
4. Catalog line (README and ify HELP) only when the verb is new.
