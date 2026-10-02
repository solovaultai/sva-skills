# /debugify

Promptify in Debug mode — a kickoff coach for Cursor Debug Mode. Analyze
the bug plus related code (read-only) and emit a copy-pasteable
Debug-Kickoff Prompt. This skill does not instrument, fix, or mutate
code.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

```text
/debugify <bug report>  — code analysis + Debug Mode kickoff prompt
/debugify help          — this reference (also --help / /?)
/debugify tldr          — short form (stop)
/debugify pass          — Pass (Npass) subsection only (also pass help)
/promptify-debug <bug>  — alias of /debugify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<bug report>` | Code analysis + copy-pasteable Debug Mode kickoff prompt | Kickoff only — paste into Cursor Debug mode to run the loop |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `promptify-debug` | Alias of `/debugify` | Same kickoff coach under the older name |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` as existing evidence | Carry what they show into the kickoff |
| `Npass` | Extra pass(es) deepen the kickoff / code analysis | If N > 1, pre-plan first; last pass emits the Debug-Kickoff Prompt |
