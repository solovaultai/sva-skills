# /phasify

Execute one or more phases of an existing plannify plan. Not a new
planning pass and not a full-plan `/runnify`. Implement only the selected
phase(s).

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).

```text
/phasify                 — Next (one incomplete phase). Not help.
/phasify next            — same as empty
/phasify 0               — named P0
/phasify p3              — named P3 (need p / phase prefix when N ≠ 0)
/phasify 3               — Next-N: next 3 incomplete phases
/phasify done            — Run-to-end (also finish / end / all / close / toend)
/phasify toend           — same as done (also to-end / to end)
/phasify -               — Stop-before-end (also -0 / -N)
/phasify defer [reason]  — Defer next open phase (also Ndefer / defer N)
/phasify undefer         — Undefer next Deferred phase (also Nundefer / undefer N)
/phasify rundefer        — Undefer+execute next Deferred phase (also Nrundefer / rundefer N / rundeferN)
/phasify todo            — Todo next not-done / not-deferred phase (also Ntodo / todo N)
/phasify explain         — Explain next not-Done phase (includes Deferred; also Nexplain / explain N / explainN)
/phasify todone          — Todo+close next eligible phase (also Ntodone / todone pN; todone N = next N)
/phasify block [reason]  — Block next 1 eligible phase (also Nblock / block pN / block N)
/phasify unblock         — Verify next Blocked / Def-Blocked phase (also Nunblock / unblock N)
/phasify runblock        — Unblock+run-or-mark next Blocked phase (also Nrunblock / runblock N / runblockN)
/phasify remove          — Drop next not-Done phase after yes/no (also Nremove / remove N / remove pN / remove <title>)
/phasify delete          — Exact alias of remove
/phasify smart <prompt>  — select a mode from the live plan, then run it (not Next; not implicit)
/phasify show            — print the current table (also refresh)
/phasify help            — this reference (also --help / /?)
/phasify tldr            — short form; stop (never a phase id)
/phasify pass            — Pass (Npass) subsection only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* / `next` | Next: one incomplete phase | Empty `/phasify` is Next, never help |
| `0` / `pN` | Named phase (bare `0` = P0; other ids need `p` / `phase`) | Run a specific phase; `/phasify 3` is Next-N, not P3 |
| `N` (bare ≥ 1) | Next-N: next N incomplete phases | Run several leftover phases without naming each |
| `done` / `toend` | Run-to-end: every remaining incomplete phase (`finish` / `end` / `all` / `close` / `to-end` / `to end`) | Finish the walk |
| `-` / `-0` / `-N` | Stop-before-end through 1-based index `C − N` | Stop short of the last N phases (`-2pass` is Npass, not this) |
| `defer` | Defer next open phase (also `Ndefer` / `defer N`) [reason] | Park as Deferred (“not now”); Next skips it |
| `undefer` | Undefer next Deferred phase (also `Nundefer` / `undefer N`) | Status only — set `Left`; does not execute |
| `rundefer` | Undefer then execute next Deferred phase | Resume parked work in one step |
| `todo` | Detailed list of next not-done / not-deferred phase (no Status change) | Read-only briefing; `todo N` is named PN |
| `explain` | Full explanation + glossary + TL/DR of next not-Done phase (includes Deferred) | Read-only write-up; `explain N` is next N, not named PN |
| `todone` | Todo-depth list, then set Status `Done` (no execute) | Close without running; `todone N` is next N eligible |
| `block` | Set next eligible phase `Blocked` / `Def-Blocked` [reason] | Hard stop; execute-next cannot proceed through it |
| `unblock` | Verify next Blocked / Def-Blocked phase | On pass: `Unblocked` or `Deferred`; no phase work |
| `runblock` | Unblock then execute remaining work or mark `Done` | Clear a blocker and finish or close in one step |
| `remove` / `delete` | Drop next not-Done work-phase row(s) after yes/no (`remove N` = next N; `remove pN` / title = named) | Delete from the plan (not defer); confirm first; remaining ids compact |
| `smart <prompt>` | Select a mode from the live plan, then run it | Router — not Next, not implicit |
| `show` / `refresh` | Print the current table | Read-only snapshot of statuses |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Print this short page and stop | Fast syntax + args without the full HELP |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | N newest scratch / `scratch/` images; optional on any mode | Visual clarification for a specific phase (prefer setting on plannify first) |
| `Npass` | N pipeline passes of this mode’s work, not a whole-table replan | Multi-pass on that phase’s work; `-2pass` is this flag, not stop-before-end |
