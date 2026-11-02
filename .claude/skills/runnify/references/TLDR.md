# /runnify

Promptify in Execution mode. Analyze, validate, enrich, score, then
execute only the optimized prompt and append Results. Aliases:
`/runify`, `/promptify-run`.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`). A from-slot still splices first. A spliced body is a prompt, not an interview. The empty-prompt interview does not read files.
`docify` / `docpathify` write the deliverable (`the docify skill's references/docify_contract.md`).
Window prefix `RUN:` (`docs/window_title.md`).
No prompt (empty, or flags only) starts the eight-section interview and does not retitle. Goal and why cannot be skipped. Context, Constraints, What a good result looks like, Deliverable and format, Preferences on approach, Examples, and Already tried or ruled out are skippable. `help` is still the command list.

```text
/runnify <prompt>      — optimize, then EXECUTE
/runnify               — no prompt: eight-section interview (Goal required; stop and wait)
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
| *(no prompt)* | Eight-section interview, then stop and wait | Body after flag strip is empty, including flags alone. Goal cannot be skipped. Not the command list. |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `runify` | Alias of `/runnify` | Short name |
| `promptify-run` | Alias of `/runnify` | Same pipeline under the older name |
| `Nimages` | Union of every numbered image directive (positive N = N newest; `-K` = one file `|K|` back) from the scratch source or workspace `scratch/` | Read them; use what they show |
| `img` | Specific files, not newest-N. Cite promptify **Named images** | The solution reads each resolved image |
| `Npass` | N pipeline passes of this execution run | If N > 1, pass 1 is a documented pre-plan; last pass executes + Results |
