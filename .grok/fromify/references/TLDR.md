# /fromify

A thin file front end. Splices local files into an ify prompt and
dispatches to that verb. Default is plannify. Does not plan or execute
by itself. File slots follow `docs/from_contract.md`.

```text
/fromify <files>         — plannify of those files (same as from=)
/fromify <verb> <text>   — that verb, with file slots spliced in
/fromify help            — full reference (also --help / /?)
/fromify tldr            — short form (stop)
/fromify pass            — Pass (Npass) subsection only (also pass help)
```

`fromify file1[,file2,...]` = `plannify from=file1,file2,...`.

| Argument | What it does | Why |
|----------|--------------|-----|
| `<files>` | Same as `plannify from=<files>` | Default verb is plannify |
| `<verb>` | First ify verb or alias selects that verb and is removed | A later verb word stays in the body |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | Flag on the typed line; handed to the selected verb | Scratch source stays that verb’s, not a fromify pipeline |
| `Npass` | Flag on the typed line; handed to the selected verb | fromify does not run its own second pass loop |

`fromify john_b_changes_to_admin_page.md,marys_comments.txt` equals
plannify of those two files. `fromify runnify test.txt` equals runnify
plus the exact file text. `fromify 2pass` / `1image` apply to the
selected verb.
