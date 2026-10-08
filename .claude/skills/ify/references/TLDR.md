# /ify

Promptify-family **front door**: catalog, help, and router. Does
**not** plan, execute, debug, or answer domain questions.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`docs/docify_contract.md`).
Window prefix `IFY:` (`docs/window_title.md`).

```text
/ify                 — catalog + help + router (does not plan or execute)
/ify help            — this family catalog (also --help, /?)
/ify help <verb>     — extreme help for that ify verb
/ify tldr            — short tldr of ify (stop)
/ify tldr <verb>     — short tldr of that verb (stop)
/ify smart <prompt>  — recommend verb + rewritten prompt (do not run)
/ify which <prompt>  — alias of smart
/ify <prompt>        — implicit smart
/ify pass help       — Pass (Npass) subsection (also `pass`)

Already know the verb? Run it directly. Append to last ify? /addify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Short usage (catalog one-liner + syntax). Not Help, not Next. | Empty `/ify` is not the catalog and not phasify-style Next. |
| `help` / `--help` / `/?` | Print the family catalog; stop | Front-door catalog without running a verb |
| `help <verb>` | Extreme help for that ify verb | Full user-facing help from this tree |
| `tldr` | Print ify’s `references/TLDR.md`; stop | Short page without the catalog |
| `tldr <verb>` | Print that verb’s `references/TLDR.md`; stop | Same bytes as `/<verb> tldr` |
| `smart <prompt>` | Recommend verb + rewritten prompt. Do not run it. | Router when you don’t know which verb |
| `which <prompt>` | Alias of `smart` | Same recommendation without a second command |
| `<prompt>` | Implicit `smart` | Bare prompt still recommends |
| `pass` / `pass help` / `help pass` | Print the Pass (`Npass`) section; stop | Flag reference without the full catalog |
| `Nimages` | Newest N scratch images (first numbered instance) | Family flag; strip before dispatch |
| `img` | Specific files handed to the verb this router runs | Cite promptify **Named images**. Strip before the mode word |
| `Npass` | N pipeline passes of this ify mode’s work | Family flag; strip before dispatch |
