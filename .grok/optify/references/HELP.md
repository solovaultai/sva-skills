# Optify — user reference

Print this file as the response when the user runs `/optify help`.
Do not change the store. Do not retitle. `/optify tldr` prints
`references/TLDR.md`, not this file.

`/optify pass` and `/optify pass help` print only the **Pass
(`Npass`)** section below and stop. There is no `/pass` skill.

`--help` and `/?` are not optify syntax. They are an unknown
optify command. A reserved token with any further token, other
than `pass help`, is the same error.

Empty `/optify` prints status. It is not Help, it does not
optimize, and it is not implicit smart.

The store, the handoff, and the host map live in
`references/optify_contract.md` in this skill folder. This page
does not restate that file. Do not fork a second grammar.

---

## What it does

A **session boundary** for an ify window. It prints the switch,
arms a one-shot, or optimizes this turn. It does not plan, execute
phases, or press `/compact` or `/clear`. The user runs the printed
command.

Default is on. A missing store file is on. Only `enabled=off` is
off. `/optify off` turns both layers off. The short router stays
on disk either way.

`optify` with no slash is the same command. There is no
`/optify-claude`.

Window title prefix is `OPT:` (see `docs/window_title.md`). Help,
tldr, pass, and bare `/optify` do not retitle.

```text
/optify            — status: on/off, before, after, host action
/optify on         — set enabled=on
/optify off        — set enabled=off
/optify now        — optimize this turn, then stop
/optify before     — arm the before one-shot
/optify after      — arm the after one-shot
/optify help       — this reference
/optify tldr       — short form; stop
/optify pass       — Pass (Npass) section only (also pass help)
```

---

## How to invoke

```text
/optify
/optify on
/optify off
/optify now
/optify before
/optify after
/optify help
/optify tldr
/optify pass help
```

The text is the token after the command. The first token `on`,
`off`, `now`, `before`, `after`, `help`, `tldr`, or `pass` is
reserved. Match is case-insensitive. Each of those tokens stands
alone, except `pass help`.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/optify` *(empty)* | **Status** | Print on/off, before, after, and the host row. Do not optimize. Name unchanged |
| `/optify on` | **On** | `enabled=on` through the CLI |
| `/optify off` | **Off** | `enabled=off`. Leaves before and after |
| `/optify now` | **Now** | Optimize this turn, then stop. Works when off |
| `/optify before` | **Before** | Arm the before one-shot. Does not fire it |
| `/optify after` | **After** | Arm the after one-shot. Does not fire it |
| `/optify help` | **Help** | Print this page; stop |
| `/optify tldr` | **tldr** | Print the short page; stop |
| `/optify pass` / `pass help` | **Pass help** | Print the Pass section; stop |
| `/optify --help` / `/?` / anything else | **Error** | Unknown optify command. Store unchanged |

---

## Status

Bare `/optify` prints:

```text
enabled: <on|off>
before: <armed|clear>
after: <armed|clear>
Host: <row>.
```

`before` and `after` are `armed` when the key is `1`, and `clear`
when the key is absent. The host row is the same-effort action,
because no next verb is named. This is a preview. It does not
compact, clear, write the handoff, or retitle.

---

## Store

One file for every host:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env
```

Keys only: `enabled` (`on` or `off`), `before` (`1` or absent),
`after` (`1` or absent). A missing file is on, with both one-shots
clear. A missing `enabled` key is on.

The only writers are `./scripts/cli.sh optify` and
`scripts/cli.ps1 optify` (Windows). Subcommands: `on`, `off`,
`show`, `before`, `after`, `clear-shots`. Agents do not edit the
file. There is no second path.

`/optify off` leaves `before` and `after` as they are. Arming a
one-shot while off only sets that key.

A fired one-shot is cleared with `optify clear-shots`. That
removes the fired key and leaves the other keys. It does not turn
the switch on.

---

## Now

`/optify now` optimizes this turn, then stops. It works when the
switch is off. It does not set `enabled=on`.

No next verb named: same effort. Compact, or the host's only row
when that host has no continue row. A different effort: the
new-verb row, or that only row. A verb change is not by itself a
different effort and does not optimize. A phase mutation does not
optimize. Plannify, then phasify, does not clear and does not
optimize. A second token on the `/optify now` line is an unknown
command, not the next verb.

Write the handoff only before a clear or a new chat. A compact
does not write it. Then print:

```text
Host: <row>.
```

Then the host command, and stop. The skill does not press
`/compact` or `/clear`.

A `/compact` row adds a focus sentence on the next line. The
sentence keeps the plan, the phase id, and the files. Its wording
comes from this effort.

Same effort on Claude Code and on Copilot CLI prints `/compact`
plus that sentence. Grok Build continue does too, while the
session still fits, and that row has no second command when the
session does not fit. Do not call the xAI HTTP compaction API.
Claude Code's new verb prints `/clear`. Copilot CLI and Grok Build
new-verb print `/clear` or `/new` as that whole line. Copilot Chat
starts a new conversation; the next turn reads the handoff. Grok
chat (grok.com) starts a new chat; the next turn reads the
handoff. Cursor always starts a new chat and reads the handoff.
Do not print `/compact`, `/clear`, or `/new` on Cursor.

Full rows: `references/optify_contract.md`, **Host action map**.

---

## One-shots

`/optify before` arms `before` for the start of the next phasify
phase. `/optify after` arms `after` for the end of the current
phase, or the end of the next phase if none is running. Arming
does not optimize.

When a shot fires, clear versus compact follows the contract.
Clear the fired shot with `optify clear-shots`. Phasify howto,
show, and explain do not optimize. A phase boundary alone is not
a compact. A phase mutation alone is not an optimize. A verb
change does not optimize, on or off.

---

## Handoff

Written before a clear or a new chat. Not written before a
compact. Optify does not read it and does not delete it.

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify-handoff.md
```

Order and the 40-line cap are in the contract **Handoff** section.
Omit the next command when the user has not typed one.

---

## Pass (`Npass`)

There is **no** `/pass` skill. Remaining body exactly `pass` or
`pass help` (case-insensitive) prints **this section** and stops.
Full reference: `/promptify pass help`.

**Meaning:** optify does not run a pass loop and does not take N
passes. `pass` and `pass help` print this section. They do not
change the store and they do not retitle. A first token that is
not reserved, including `2pass`, is an unknown optify command.

```text
/optify pass
/optify pass help
/promptify pass help
```

---

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `OPT:`.
Summary is the subcommand (`on`, `off`, `now`, `before`, `after`).
Help, tldr, pass, and empty usage do not retitle.

```text
OPT: on
OPT: off
OPT: now
OPT: before
OPT: after
```

Bare `/optify` is empty usage for that rule. It still prints
status.

---

## Errors

Print **Error:** and do not change the store. Then this line:

```text
Usage: /optify [on|off|now|before|after|help|tldr|pass]
```

| Condition | Error |
|-----------|-------|
| First token is not reserved, including `--help` and `/?` | unknown optify command |
| A reserved token is followed by another token, other than `pass help` | unknown optify command |
| Store value outside the contract **Store** table | rejected; store unchanged |

---

## Hard rules (short)

- Status, switch, one-shots, and one optimize. No planning. The
  user runs `/compact` or `/clear`.
- One store file. CLI subcommands `on`, `off`, `show`, `before`,
  `after`, `clear-shots` are the writers.
- Bare `/optify` previews. It does not optimize and it does not
  retitle.
- `/optify now` with no next verb named is the same effort. A
  verb change is not a different effort and does not optimize.
  A phase mutation does not optimize. Now works when off.
- Handoff only before a clear or a new chat.
- Exact `help` prints this page. Exact `tldr` prints
  `references/TLDR.md`. Exact `pass` / `pass help` prints **Pass
  (`Npass`)** only.
- `--help` and `/?` are unknown optify commands.

---

## Related

| Command | Role |
|---------|------|
| `references/optify_contract.md` | Store, handoff, host map |
| `/phasify` | Phase boundaries where an armed shot fires |
| `/promptify pass help` | Full pass-flag reference |
| `/ify` | Family catalog |
