# /debugify

Copilot Debug Mode — full loop (default). Runtime evidence loop, not a
speculative-fix loop: hypothesize → instrument → repro → analyze → fix
→ verify → clean. Aliases: `/dbgify`, `/debify`, `/debug`.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`the docify skill's references/docify_contract.md`).
Window prefix `DBG:` (`docs/window_title.md`).

```text
/debugify <bug report>      — full loop (default)
/debugify help              — this reference (also --help / /?)
/debugify tldr              — short form (stop)
/debugify pass              — Pass (Npass) subsection only (also pass help)
/dbgify <bug report>       — alias of /debugify
/debug <bug report>         — alias of /debugify
/debify <bug report>        — alias of /debugify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<bug report>` | Full evidence loop (default): hypothesize → instrument → repro → analyze → fix → verify → clean | Runtime evidence before product fixes — not a speculative-fix loop |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `dbgify` | Alias of `/debugify` | Short name |
| `debify` | Alias of `/debugify` | Short name |
| `debug` | Alias of `/debugify` | Same full loop under the shorter name |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` as existing evidence during Phase 0 | Visual evidence for Investigate |
| `img` | Specific files, not newest-N. Cite promptify **Named images** | Read before hypotheses; evidence for what the problem is |
| `Npass` | Extra pass(es) deepen investigation / hypothesis quality | If N > 1, pre-plan first; last pass runs this invocation’s loop work |
