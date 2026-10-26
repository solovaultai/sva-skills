# /debugify

Promptify in Debug mode — a kickoff coach for Cursor Debug Mode. Analyze
the bug plus related code (read-only) and emit a copy-pasteable
Debug-Kickoff Prompt. This skill does not instrument, fix, or mutate
code.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`the docify skill's references/docify_contract.md`).
Window prefix `DBG:` (`docs/window_title.md`).

```text
/debugify <bug report>  — code analysis + Debug Mode kickoff prompt
/debugify help          — this reference (also --help / /?)
/debugify tldr          — short form (stop)
/debugify pass          — Pass (Npass) subsection only (also pass help)
/dbgify <bug>            — alias of /debugify
/promptify-debug <bug>  — alias of /debugify
/debify <bug>            — alias of /debugify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<bug report>` | Code analysis + copy-pasteable Debug Mode kickoff prompt | Kickoff only — paste into Cursor Debug mode to run the loop |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `dbgify` | Alias of `/debugify` | Short name |
| `debify` | Alias of `/debugify` | Short name |
| `promptify-debug` | Alias of `/debugify` | Same kickoff coach under the older name |
| `Nimages` | Union of every numbered image directive (positive N = N newest; `-K` = one file `|K|` back) from the scratch source or workspace `scratch/` as existing evidence | Carry what they show into the kickoff |
| `img` | Specific files, not newest-N. Cite promptify **Named images** | Evidence in the Debug-Kickoff Prompt under Existing Evidence |
| `Npass` | Extra pass(es) deepen the kickoff / code analysis | If N > 1, pre-plan first; last pass emits the Debug-Kickoff Prompt |
