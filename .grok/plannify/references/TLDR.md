# /plannify

Promptify in Planning mode. Coach the request into a planning-kickoff
prompt, then run that prompt read-only and emit a structured plan. Never
implements, edits, or mutates the workspace.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

```text
/plannify <prompt>     — coach, then produce a plan (read-only)
/plannify fromhere     — replan from current statuses (also planify fromhere)
/plannify add <feat>   — add a feature to the just-run plan (last ify: plannify or phasify)
/plannify help         — this reference (also --help / /?)
/plannify tldr         — short form (stop)
/plannify pass         — Pass (Npass) subsection only (also pass help)
/promptify-plan <prompt>— alias of /plannify
```

| Argument | What it does | Why |
|----------|--------------|-----|
| `<prompt>` | Coach, then produce a plan (read-only) | Planning mode — never implements or mutates the workspace |
| `fromhere` | Replan from the current plan’s statuses (also `planify fromhere`) | Replan without a greenfield plan; keeps Done / Deferred / Def-Blocked |
| `add <feature>` | Surgical feature add on the just-run plan | Last ify must be plannify or phasify; keep unaffected phases |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `promptify-plan` | Alias of `/plannify` | Same planning pipeline under the older name |
| `Nimages` | N newest images from the scratch source or workspace `scratch/` | Carry what they show into the Planning-Kickoff Prompt and the plan |
| `Npass` | N passes before producing the plan | If N > 1, pass 1 is pre-plan only; last pass produces the kickoff and Plan |
