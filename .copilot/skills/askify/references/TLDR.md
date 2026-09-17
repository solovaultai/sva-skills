# /askify

Promptify in Ask mode. Coach the request into an ask-kickoff prompt,
then run it read-only and return a cited answer. Never implements and
never emits a plan.

```text
/askify <prompt>       — coach, then answer (read-only)
/askify help           — this reference (also --help / /?)
/askify tldr           — short form (stop)
/askify pass           — Pass (Npass) subsection only (also pass help)
/promptify-ask <prompt>— alias of /askify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | Coach, then answer read-only (cited) | Ask mode — never implements or emits a plan |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `promptify-ask` | Alias of `/askify` | Same ask pipeline under the older name |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` | Carry what they show into the Ask-Kickoff Prompt and the answer |
| `Npass` | N passes before answering | If N > 1, pass 1 is pre-plan only; last pass produces the kickoff and Answer |
