# /promptify

Prompt QA against the real workspace: analyze intent, validate assets,
enrich with verified facts only, score readiness, and return an optimized
execution-ready prompt. `/promptify` does not execute the work; `/runnify`
does.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

```text
/promptify <prompt>    — analyze / validate / enrich / rewrite (no execute)
/promptify help        — this reference (also --help / /?)
/promptify tldr        — short form (stop)
/promptify pass        — Pass (Npass) subsection only (also pass help)
/runnify <prompt>      — same pipeline, then EXECUTE the optimized prompt
/promptify-run <prompt>— alias of /runnify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | Analyze, validate, enrich, and rewrite (no execute) | Optimize the request against the real workspace |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` | Attachment marker — carry what they show into the rewrite |
| `Npass` | N pipeline passes before the final optimized prompt | If N > 1, pass 1 is a documented pre-plan; last pass emits the prompt |
