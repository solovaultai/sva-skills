# /saveify

A thin snapshot verb. Writes the current ify context, or deletes a
snapshot after yes/no. Does not plan, execute, or restore.
`/resumeify` restores. Layout is `docs/saveify_contract.md`. No
`smart` mode. Canonical slash is `/saveify`. `savify` is a trigger
word, not a command.

```text
/saveify                 — auto-name save
/saveify <name>          — save under that name
/saveify list            — list, pick a number, display only
/saveify delete          — list, pick, then yes/no
/saveify delete <name>   — that row, then yes/no
/saveify delete <#>      — that position, then yes/no
/saveify help            — full reference (also --help / /?)
/saveify tldr            — short form (stop)
/saveify pass            — Pass (Npass) subsection only (also pass help)
```

Empty `/saveify` is a real auto-name save, not short usage.

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Auto-name save | Same exception shape as empty `/phasify` = Next |
| `<name>` | Save under that name | An existing slug asks yes/no before replace |
| `list` | Show every saved context, then display the number you pick | Not a name. Does not run `/phasify`. Empty `/saveify` still saves |
| `delete` | List, then you pick, then yes/no | Nothing is deleted on the proposing line |
| `delete <name>` | Show that row, then yes/no | Name matches slug, then display name |
| `delete <#>` | Show that position, then yes/no | `#` is the list position right now; 1 is newest |
| `help` / `--help` / `/?` | Print the full user reference and stop | Further words (`help me …`) stay on Help |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` / `Npass` | Stripped before the name | Saveify does not run its own pass loop |

`/saveify testme` saves that name. `/saveify 2` stores the name `2`.
`/saveify delete 2` is position 2. No task and no phase table:
**Error:** nothing to save.
