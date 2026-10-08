# /addify

A thin conversation router. Recovers the last ify in this chat,
verbatim-appends the addify body, and dispatches to that skill. Does not
optimize or plan by itself.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`docs/docify_contract.md`).
No prefix of its own; it re-applies the ancestor label (`docs/window_title.md`).

```text
/addify <text>     — append <text> to the last ify and restart/continue that skill
/addify help       — this reference (also --help / /?)
/addify tldr       — short form (stop)
/addify pass       — Pass (Npass) subsection only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<text>` | Append verbatim to the last ify and restart/continue that skill | Thin router — recover, append, dispatch; no second pipeline |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | Flag on the addify line; applies to the restarted skill (addify-line wins) | Attachment for the dispatched skill, not addify’s own pipeline |
| `img` | Specific files on this line, handed to the restarted verb | Cite promptify **Named images**. Do not drop them |
| `Npass` | Flag on the addify line; applies to the restarted skill (addify-line wins) | If N > 1 on the restarted skill, pass 1 is a documented pre-plan |
