# /resumeify

A thin restore front end. Lists saved ify contexts and reprints one.
Does not plan or execute phases. Does not write or delete. Store and
reprint follow `docs/saveify_contract.md`.
`from=` splices local files (`docs/from_contract.md`). `docify` writes
the deliverable (`the docify skill's references/docify_contract.md`). Window prefix `RESUME:`
(`docs/window_title.md`).

```text
/resumeify                — selection list, newest first; Choose none stops
/resumeify list           — same selection, then restore the one you pick
/resumeify <name>         — restore that snapshot
/resumeify <#>            — restore list position (1 = newest)
/resumeify help           — full reference (also --help / /?)
/resumeify tldr           — short form (stop)
/resumeify pass           — Pass (Npass) subsection only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Selection list (**List select**). Newest first. `Choose none` stops | Empty is not a save. A saved context restores. The asking turn does not retitle |
| `list` | Same selection, then restore the saved context you pick. `Choose none` stops | Exact `list` is not a snapshot name. The pick can continue with `/phasify` |
| `<name>` | Reprint that snapshot | A later `/phasify` can continue |
| `<#>` | Reprint list position `1` = newest | The number is not a stable id |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | Flag on the typed line; stripped | Not a snapshot name. No scratch read |
| `img` | Specific files for this restore, plus snapshot `images.txt` | Paths print after the plan path. Cite promptify **Named images** |
| `Npass` | Flag on the typed line; stripped | Resumeify does not run its own second pass loop |

`/resumeify` shows the selection. `Choose none` stops. `/resumeify 1` restores the newest.
`/resumeify my saved plan` restores that name. A different workspace
is announced and the directory stays. Unfinished plan: next command
is `/phasify`. All work phases Done: the plan is complete. When both
`plan.md` and `table.txt` exist, the printed plan ends before
`## Phased plan` and `table.txt` is the only phase table.
