# /optify

Session boundary for an ify window. Prints the switch, arms a
one-shot, or optimizes this turn. Does not press `/compact` or
`/clear`. Default is on. A missing store file is on. Store, handoff,
and the host map are `references/optify_contract.md`. Window prefix
`OPT:` (`docs/window_title.md`). No smart mode. Bare `/optify` is
status, not implicit smart.

```text
/optify            — status: on/off, before, after, host action
/optify on         — set enabled=on
/optify off        — set enabled=off
/optify now        — optimize this turn, then stop
/optify before     — arm the before one-shot
/optify after      — arm the after one-shot
/optify help       — full reference
/optify tldr       — short form (stop)
/optify pass       — Pass (Npass) section only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Print on/off, before, after, and the host row | Preview. Does not compact, clear, write the handoff, or retitle |
| `on` | Set `enabled=on` through the CLI | Default when the file is absent |
| `off` | Set `enabled=off` | Leaves before and after. Only `enabled=off` is off |
| `now` | Optimize this turn, then stop | Works when off. No next verb named: same effort |
| `before` | Arm the before one-shot | Fires at the next phase start. Arming does not optimize |
| `after` | Arm the after one-shot | Fires at the end of the current phase, or the next one |
| `help` | Print the full user reference and stop | `--help` and `/?` are unknown commands |
| `tldr` | Print this short page and stop | Fast syntax without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) section only and stop | There is no `/pass` skill. No store change. No retitle |

Same effort compacts, or uses the host's only row. A different
effort clears. Copilot CLI and Grok Build new-verb print `/clear`
or `/new` as that whole line. Cursor starts a new chat and reads
the handoff. The handoff is written only before a clear or a new
chat. Writers: `./scripts/cli.sh optify` and `scripts/cli.ps1
optify` (`on`, `off`, `show`, `before`, `after`, `clear-shots`).

```text
Usage: /optify [on|off|now|before|after|help|tldr|pass]
```
