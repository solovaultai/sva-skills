# /resumeify

A thin restore front end. Lists saved ify contexts and reprints one.
Does not plan or execute phases. Does not write or delete. Store and
reprint follow `docs/saveify_contract.md`.

```text
/resumeify                — list, newest first; do not restore
/resumeify <name>         — restore that snapshot
/resumeify <#>            — restore list position (1 = newest)
/resumeify help           — full reference (also --help / /?)
/resumeify tldr           — short form (stop)
/resumeify pass           — Pass (Npass) subsection only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | List number, date, name, verb, stage, cwd. Newest first | Empty is not a save and does not restore or retitle |
| `<name>` | Reprint that snapshot | A later `/phasify` can continue |
| `<#>` | Reprint list position `1` = newest | The number is not a stable id |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | Flag on the typed line; stripped | Not a snapshot name. No scratch read |
| `Npass` | Flag on the typed line; stripped | Resumeify does not run its own second pass loop |

`/resumeify` prints the list. `/resumeify 1` restores the newest.
`/resumeify my saved plan` restores that name. A different workspace
is announced and the directory stays. Unfinished plan: next command
is `/phasify`. All work phases Done: the plan is complete.
