---
name: optify
description: >-
  Optify — session boundary for an ify window. Use when the user runs
  /optify, on, off, now, before, or after. Empty /optify prints
  on/off, armed before and after, and the host action. help, tldr,
  and pass print only. Default is on. Does not press /compact or
  /clear.
argument-hint: "[on|off|now|before|after|help|tldr|pass]"
user-invocable: true
---

# Optify (= session boundary)

You are running **Optify** (`/optify`) — the Promptify-family
**session boundary**. You print status, set the switch, arm a
one-shot, or optimize this turn. You do not plan, execute phases,
debug, or answer the domain question. `optify` with no slash is
the same command. There is no `/optify-claude`. There is no
`smart` mode. Bare `/optify` is a status preview. It is not
implicit smart.

1. Parse the remaining body.
2. Help, tldr, and pass print only, then stop.
3. Every other command reads the store.
4. On, off, before, and after change the store through the CLI,
   then stop. They do not optimize.
5. Now optimizes this turn, then stops.
6. A bare line prints status and stops.

Cite the optify skill's `references/optify_contract.md`. On: short
router, and only the mode just parsed. Off: the full reference set.
Clear and compact follow that contract. Help, tldr, pass, and empty
usage do not retitle.

Read `references/optify_contract.md` in this skill folder and
follow it. Do not paste it. Do not look in the project `docs/`
folder for that contract unless the workspace is sva-skills. Do
not fork a second command grammar, store path, host map, or
handoff file.

Help, tldr, and pass print their page whether the switch is on or
off. They do not read the store and they do not read the other
references. For every other command, read the store first. When
the switch is on, read the contract and nothing else in
`references/`. When the switch is off, read the contract,
`references/HELP.md`, and `references/TLDR.md`, then still do only
the parsed command.

**This tree:** Copilot. On Copilot CLI, same effort uses **Copilot
CLI, continue**: print `/compact` and the focus sentence. A new verb
uses **Copilot CLI, new verb**: print `/clear` or `/new` as that
whole line. Do not tell the user to change model, tools, or
reasoning. On Copilot Chat, either case uses **Copilot Chat**: start
a new conversation; the next turn reads the handoff file. Chat has
no `/compact` and no continue row, so write the handoff first.

---

## Parse

The remaining body is everything after the command word. Token
match is case-insensitive. Stored words and the window-title
summary are lowercase.

The first token `on`, `off`, `now`, `before`, `after`, `help`,
`tldr`, or `pass` is reserved. Each stands alone, except `pass`
followed only by `help`.

- No token: bare `/optify`. Status preview.
- `help` alone: read and print `references/HELP.md`. Stop.
- `tldr` alone: read and print `references/TLDR.md`. Stop.
- `pass` alone, or `pass` and `help`: print the **Pass
  (`Npass`)** section of `references/HELP.md`. Stop. There is no
  `/pass` skill.
- `on`, `off`, `now`, `before`, `after` alone: that command.

`--help` and `/?` are not optify syntax. A reserved token with any
further token, other than `pass help`, is the same error. Any
other first token is the same error, including `2pass` and
`help me`. Do not strip `Nimages` or `Npass`. That would fork a
second grammar.

Print:

```text
**Error:** unknown optify command
Usage: /optify [on|off|now|before|after|help|tldr|pass]
```

The store stays as it was. Do not retitle.

---

## Store

One file for every host:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env
```

Claude, Grok, Copilot, and Cursor share that file. No per-host
file. No second path. Read it. Do not edit it by hand.

| Key | Meaning |
|-----|---------|
| missing file | `enabled` on, `before` clear, `after` clear |
| `enabled` | `on` or `off`. Missing key means on. Only `enabled=off` is off |
| `before` | `1` armed. Absent means clear |
| `after` | `1` armed. Absent means clear |

A value outside that table, or any other key: do not rewrite the
file. Print:

```text
**Error:** rejected; store unchanged
Usage: /optify [on|off|now|before|after|help|tldr|pass]
```

Change the store only by running, from this repo:

```text
./scripts/cli.sh optify <subcommand>
scripts/cli.ps1 optify <subcommand>
```

Use `./scripts/cli.sh` on Linux and Git Bash. Use `scripts/cli.ps1`
on Windows. Subcommands: `on`, `off`, `show`, `before`, `after`,
`clear-shots`. Do not invent another subcommand. If you cannot run
the CLI, print that command for the user. Do not write the env
file.

- `/optify on` runs `optify on`.
- `/optify off` runs `optify off`. Off leaves `before` and `after`.
- `/optify before` runs `optify before`.
- `/optify after` runs `optify after`.
- A fired one-shot runs `optify clear-shots`. That removes the
  fired key and leaves the other keys. It does not set
  `enabled=on`.
- `optify show` prints the store. Status below still uses the
  missing-file rules, so a missing file prints on.

Arming `before` or `after` only sets that key, including when the
switch is off. It does not optimize. After a successful CLI
change, re-read the file and print `enabled`, `before`, and
`after`. Do not print a host command. Do not write the handoff.

---

## Status (bare `/optify`)

Print on/off, whether `before` is armed, whether `after` is armed,
and the host action an optimize would use on this turn. No next
verb is named, so the effort is the same: this tree's continue
row, or its only row when it has no continue row.

```text
enabled: <on|off>
before: <armed|clear>
after: <armed|clear>
Host: <row>.
```

`before` and `after` print `armed` or `clear`. Do not compact. Do
not clear. Do not write the handoff. Do not retitle. Do not fire a
one-shot. Preview only.

---

## Optimize (`/optify now`)

`/optify now` works when the switch is off. It does not set
`enabled=on`. A second token on the line is the unknown-command
error. It is not the next verb.

No next verb named: same effort. Use this tree's continue row.
A host with no continue row uses its only row. That row is a new
chat or a new conversation.

A different effort uses this tree's new-verb row, or the only row
when that is all this tree has. No next verb named on `/optify now`
is the same effort. The next command is one the user already typed.
Do not invent one. A verb change is not by itself a different effort
and does not optimize.

A fired `before` or `after` uses these same rules, then
`optify clear-shots`, then stops. It does not set `enabled=on`.
Follow **When to clear**, **When to compact**, and **Phasify** in
the contract. Do not replace "about 70%". If the host has no
meter, do not invent a percentage. A phase boundary alone is not
a compact. Phasify howto, show, and explain do not optimize. Do
not edit phasify.

Print one line `Host: <row>.`, then the command from this tree's
sentence, then stop the turn. `<row>` is the label in the contract
(**Claude Code, continue**, **Copilot Chat**, **Cursor**, and the
others).

When the command is `/compact`, the next line is the focus
sentence. It keeps the plan, the phase id, and the files. The
wording comes from this effort. Do not invent a phase id or a
path. Do not write the handoff.

When the action is a clear or a new chat, write the handoff
first, then print the host line and the command, then stop. Do
not start the heavy read in that turn.

When the row is **Copilot CLI, new verb** or **Grok Build, new
verb**, the command line is `/clear` or `/new`. Do not add a third
string. Do not drop either word. Do not call the xAI HTTP
compaction API. Do not tell the user to change model, tools, or
reasoning. When the row is **Cursor**, the command is: start a new
chat and read the handoff file. Do not print `/compact`, `/clear`,
or `/new`.

The skill cannot press `/compact` or `/clear`. The user runs the
printed command.

---

## Handoff

Write it only before a clear or a new chat. A compact does not
write it. Optify does not read it and does not delete it. The
next ify verb reads it and deletes it. The CLI does not own it.

```text
${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify-handoff.md
```

Create that `sva-skills` directory when it is absent. Do not write
a second path. A later clear or new chat overwrites the file.

Contents, in this order. Cap about 40 lines. Do not pad. If the
file would pass about 40 lines, shorten the files list first.

```text
Previous verb: <verb>
Task: <one line>
Flags: <flags>
Phases: <id> <status>
Files: <path>
Next: <command the user already typed>
```

One phase per line. One path per line. Omit `Next` when the user
has not typed that command. Omit a heading you cannot fill. Do
not invent a verb, a phase, a path, or a next command.

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

Set that name on `on`, `off`, `now`, `before`, and `after`, as
soon as the subcommand is known. Bare `/optify` is empty usage
for that rule. It still prints status. `pass help` does not
retitle.

---

## Hard rules

- Follow `references/optify_contract.md`. Do not paste a second
  store, host map, or handoff path.
- The only writers are `./scripts/cli.sh optify` and
  `scripts/cli.ps1 optify`, subcommands `on`, `off`, `show`,
  `before`, `after`, `clear-shots`.
- Bare `/optify` is a status preview. It does not compact, clear,
  write the handoff, retitle, or fire a one-shot. It is not
  implicit smart.
- `--help` and `/?` are an unknown optify command. Print the
  usage line. Leave the store.
- `/optify now` with no next verb named is the same effort. A
  different effort clears. Now works when the switch is off.
- Write the handoff only before a clear or a new chat. Print the
  host command and stop. Do not press `/compact` or `/clear`.
- Cite `docs/window_title.md`. Prefix `OPT:`. Help, tldr, pass,
  and bare `/optify` do not retitle.
- No `references/SMART.md`. No timer compact. No model change.
  No xAI HTTP compaction API.
