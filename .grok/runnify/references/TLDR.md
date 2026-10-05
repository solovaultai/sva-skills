# /runnify

Promptify in Execution mode. Analyze, validate, enrich, score, then
execute only the optimized prompt and append Results. Aliases:
`/runify`, `/promptify-run`.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

```text
/runnify <prompt>      — optimize, then EXECUTE
/runnify help          — this reference (also --help / /?)
/runnify tldr          — short form (stop)
/runnify pass          — Pass (Npass) subsection only (also pass help)
/runify <prompt>       — alias of /runnify
/promptify-run <prompt>— alias of /runnify
/promptify <prompt>    — analyze only (no execute)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | Optimize, then execute only the optimized prompt and append Results | Execution mode — `/promptify` stops after the rewrite |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `runify` | Alias of `/runnify` | Short name |
| `promptify-run` | Alias of `/runnify` | Same pipeline under the older name |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` | Read them; use what they show |
| `Npass` | N pipeline passes of this execution run | If N > 1, pass 1 is a documented pre-plan; last pass executes + Results |
