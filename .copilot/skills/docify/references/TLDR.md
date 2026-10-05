# /docify

A thin front end. Documents an ify prompt. Default is askify. The
first non-control token selects another ify verb. Does not write a
second file. Controls follow `docs/docify_contract.md`.

```text
/docify <prompt>              — askify that prompt, then docify
/docify <controls> <prompt>   — same, with those directive controls
/docify <verb> <prompt>       — that ify verb instead of askify
/docify                        — write the last ify when one exists
/docify:html                   — write that last ify as html
/docify help                  — full reference (also --help / /?)
/docify tldr                  — short form (stop)
/docify pass                  — Pass (Npass) subsection only (also pass help)
```

`/docify what are the pytch cli commands controlling cloudflare`
= `/askify what are the pytch cli commands controlling cloudflare docify`.

`/docify html:page Show me all of the options for the docify skill and directive.`
= askify of that prompt with trailing `docify:html:page`. The directive
writes `SHOW_ME_ALL_OF_THE_OPTIONS.html` and opens it.

`/docify:text path=~/docs plannify 2pass create a new set of pytch CLI commands to manage and display outreaches`
= `/plannify 2pass create a new set of pytch CLI commands to manage and display outreaches docify:text:path:~/docs`.

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | askify, then one trailing `docify` | Default verb is askify |
| `<verb>` | First non-control ify verb selects that verb and is removed | A later verb word stays in the prompt. Never select `docify` |
| `docify:html` | Generated name ends in `.html` | No filename: the format token sets the extension |
| `docify:html:path:test.md` | Writes markdown | A filename extension overrides the format token |
| `help` / `--help` / `/?` | Print the full user reference and stop | No dispatch and no file |
| `tldr` | Print this short page and stop | Fast syntax |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill. Cite `/promptify pass help` |
| `Nimages` / `Npass` | Flags handed to the selected verb | This skill does not run its own pass loop |
| `set` with no prompt | `./scripts/cli.sh docify` (or `cli.ps1`) and stop | Store only. No file |
| `/docify:html` with no prompt | Write the last ify as html | Does not dispatch askify |

Help, tldr, and pass do not dispatch and do not write.
`/docify:set:txt` with no prompt changes the store only.
A write with no prompt writes the last ify deliverable.
Empty `/docify` with no last ify is short usage.
