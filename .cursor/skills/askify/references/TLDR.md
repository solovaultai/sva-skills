# /askify

Promptify in Ask mode. Coach the request into an ask-kickoff prompt,
then run it read-only and return a cited answer. Never implements and
never emits a plan.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`the docify skill's references/docify_contract.md`).
Window prefix `ASK:` (`docs/window_title.md`).

```text
/askify <prompt>       — answer only (read-only; do not print the plan)
/askify plan <prompt>  — print the ask-kickoff plan, then answer
/askify dummy <prompt> — non-technical tell (no commands, paths, or APIs)
/askify help           — this reference (also --help / /?)
/askify tldr           — short form (stop)
/askify pass           — Pass (Npass) subsection only (also pass help)
/promptify-ask <prompt>— alias of /askify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | Answer read-only (cited); do not print the plan | Default — the plan is internal unless asked for |
| `plan` | Print Intent / Workspace / Ask-Kickoff / Scores, then Answer | Only when the user specified `/askify plan` |
| `dummy` | Non-technical tell: Intent, then plain language. No commands, paths, or APIs. Cite the phasify skill's `references/dummy.md` | First token, or beside a leading `plan`. Not a phase selector. Empty `dummy` needs a prompt |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `promptify-ask` | Alias of `/askify` | Same ask pipeline under the older name |
| `Nimages` | Union of every numbered image directive (positive N = N newest; `-K` = one file `|K|` back) from the scratch source or workspace `scratch/` | Carry what they show into the Ask-Kickoff Prompt and the answer |
| `img` | Specific files, not newest-N. Cite promptify **Named images** | The answer uses each resolved image as evidence |
| `Npass` | N passes before answering | If N > 1, pass 1 is pre-plan only; last pass produces the kickoff and Answer |
