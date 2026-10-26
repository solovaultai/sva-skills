# /promptify

Prompt QA against the real workspace: analyze intent, validate assets,
enrich with verified facts only, score readiness, and return an optimized
execution-ready prompt. `/promptify` does not execute the work; `/runnify`
does.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`the docify skill's references/docify_contract.md`).
Window prefix `PROMPT:` (`docs/window_title.md`).

```text
/promptify <prompt>    — analyze / validate / enrich / rewrite (no execute)
/prify <prompt>         — alias of /promptify
/promptify help        — this reference (also --help / /?)
/promptify tldr        — short form (stop)
/promptify pass        — Pass (Npass) subsection only (also pass help)
/runnify <prompt>      — same pipeline, then EXECUTE the optimized prompt
/promptify-run <prompt>— alias of /runnify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | Analyze, validate, enrich, and rewrite (no execute) | Optimize the request against the real workspace |
| `prify` | Alias of `/promptify` | Short name |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | Every numbered directive: positive N newest; negative `-K` is one file, K steps back; union, newest first. `scratch ls M` (positive), then slice | Attachment marker — name every token; carry what they show into the rewrite |
| `img` | Specific files, not newest-N. Cite promptify **Named images** | Every token counts. Used in the rewrite and the solution |
| `Npass` | N pipeline passes before the final optimized prompt | If N > 1, pass 1 is a documented pre-plan; last pass emits the prompt |
