# /phasify

Execute one or more phases of an existing plannify plan. Not a new
planning pass and not a full-plan `/runnify`. Implement only the selected
phase(s). Aliases: `/phaseify`, `/phify`.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the deliverable (`the docify skill's references/docify_contract.md`). Guide and coach cite `docs/docify_contract.md`.
Window name is `PHASE:P<n>/<total>:<PREFIX>: <summary>` (`docs/window_title.md`). Exact `tldr` does not retitle. Dummy, guide, and coach use the phase they are about.

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
/phasify explain         — Full write-up of the next not-Done phase (includes Deferred; count selectors skip Done; no execute, no Status change, does not rewrite the plan; explain N / Nexplain / explainN = next N, not named PN; named pN may be Done, what landed; thin record quotes the description; pending stays the full write-up; optional second word guide; Blocked / Def-Blocked / partially blocked: detailed steps from the record; other statuses: no unblock list)
/phasify dummy           — Non-technical tell of the next not-Done phase (no execute, no Status change, does not rewrite the plan; dummy N / Ndummy / dummyN = next N, not named PN; named is only dummy pN and may be Done; dummy 0 is Error, use dummy p0; optional second word guide; on a block: spelled-out task names, not enough to perform; other statuses: no unblock list)
/phasify explain guide   — Only the second word on explain, tldr, or dummy (explain guide, tldr guide p3, dummy guide, 3explain guide). Not runblock. Every target must be blocked or partially blocked, else Error and no file. User-guide depth, mermaid, web images/links/PDFs only when reuse is allowed. Writes through docify defaults, else /home/ami/src/pytch/pytch-docs/agent/, markdown, generated CAPS name (GUIDE if title empty). Does not commit. Missing pytch-docs is Error. Does not change Status. Does not reprint the plan.
/phasify coach           — Matched before guide. coach / coach 1 = next blocked or partially blocked phase. coach pN only if that phase is blocked or partially blocked. coach 0 is Error (use coach p0). coach N for N>=2, Ncoach, coachN are Error (one phase). coach guide is Error. One instruction at a time; wait for questions and output, then the next step. Writes a COACH_LOG the same way as guide and prints the summary. Not runblock. Not howto. No Status change.
/phasify todone          — Todo+close next eligible phase (also Ntodone / todone pN; todone N = next N)
/phasify block [reason]  — Block next 1 eligible phase (also Nblock / block pN / block N)
/phasify unblock         — Verify next Blocked / Def-Blocked phase (also Nunblock / unblock N)
/phasify runblock        — Unblock+run-or-mark next Blocked phase (also Nrunblock / runblock N / runblockN)
/phasify howto           — Steps past the next blocked or partially blocked phase (also Nhowto / howto N / howtoN)
/phasify remove          — Drop next not-Done phase after yes/no (also Nremove / remove N / remove pN / remove <title>)
/phasify delete          — Exact alias of remove
/phasify smart <prompt>  — select a mode from the live plan, then run it (not Next; not implicit)
/phasify show            — print the current table (also refresh)
/phasify help            — this reference (also --help / /?)
/phasify tldr            — exact /phasify tldr with no other token prints this page and stops (never a phase id; tldr help is not help). Phase tell needs tldr 1, tldr N, Ntldr, tldrN, tldr pN, or pN tldr. tldr N = next N not-Done. Named pN may be Done. tldr 0 is Error (use tldr p0). A leftover that is not a selector and not guide is still an explanation-only question. Optional second word guide. On a block: a numbered list a capable person could carry out. Other statuses: no unblock list. Named Done: a thin record quotes the description; do not invent work.
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
| `explain` | Full write-up + glossary + TL/DR of the next not-Done phase (includes Deferred). Count selectors skip Done. Pending stays the full write-up. Named `pN` may be Done (what landed; thin record quotes the description; do not invent work). Blocked / Def-Blocked / partially blocked (`Progress` with a recorded blocker, same as howto): detailed steps from the record. Other statuses: no unblock list. Optional second word `guide`. No execute, no Status change, does not rewrite the plan | `explain N` / `Nexplain` / `explainN` = next N, not named PN |
| `dummy` | Non-technical tell of the next not-Done phase. No commands, paths, or APIs. No execute, no Status change, does not rewrite the plan. `dummy N` / `Ndummy` / `dummyN` = next N, not named PN. Named is only `dummy pN` and may be Done (thin record quotes the description; do not invent work). `dummy 0` is Error (use `dummy p0`). On Blocked / Def-Blocked / partially blocked: spelled-out task names, not enough to perform. Other statuses: no unblock list. Optional second word `guide` | Read-only tell |
| `guide` | Only the second word on explain, tldr, or dummy (`explain guide`, `tldr guide p3`, `dummy guide`, `3explain guide`). Not runblock. Every target must be blocked or partially blocked, else Error and no file. User-guide depth, mermaid, web images/links/PDFs only when reuse is allowed. Writes through docify defaults, else `/home/ami/src/pytch/pytch-docs/agent/`, markdown, generated CAPS name (`GUIDE` if title empty). Does not commit. Missing pytch-docs is Error. Does not change Status. Does not reprint the plan | Not a mode of its own |
| `coach` | Matched before guide. `coach` / `coach 1` = next blocked or partially blocked phase. `coach pN` only if that phase is blocked or partially blocked. `coach 0` is Error (use `coach p0`). `coach N` for N≥2, `Ncoach`, `coachN` are Error (one phase). `coach guide` is Error. One instruction at a time; wait for questions and output, then the next step. Writes a `COACH_LOG` the same way as guide and prints the summary. Not runblock. Not howto. No Status change | Own mode |
| `todone` | Todo-depth list, then set Status `Done` (no execute) | Close without running; `todone N` is next N eligible |
| `block` | Set next eligible phase `Blocked` / `Def-Blocked` [reason] | Hard stop; execute-next cannot proceed through it |
| `unblock` | Verify next Blocked / Def-Blocked phase | On pass: `Unblocked` or `Deferred`; no phase work |
| `runblock` | Unblock then execute remaining work or mark `Done` | Clear a blocker and finish or close in one step |
| `howto` | Steps past the next blocked or partially blocked phase (no Status change) | Human instructions, with a diagram; none → nothing to do + reprint the plan |
| `remove` / `delete` | Drop next not-Done work-phase row(s) after yes/no (`remove N` = next N; `remove pN` / title = named) | Delete from the plan (not defer); confirm first; remaining ids compact |
| `smart <prompt>` | Select a mode from the live plan, then run it | Router — not Next, not implicit |
| `show` / `refresh` | Print the current table | Read-only snapshot of statuses |
| `help` / `--help` / `/?` | Print the full user reference and stop | Long form of this page |
| `tldr` | Exact `/phasify tldr` with no other token prints this page (`references/TLDR.md`) and stops (never a phase id; `tldr help` is not help). Phase tell needs a selector: `tldr 1`, `tldr N`, `Ntldr`, `tldrN`, `tldr pN`, `pN tldr`. `tldr N` = next N not-Done. Named `pN` may be Done (what landed; thin record quotes the description). `tldr 0` is Error (use `tldr p0`). A leftover that is not a selector and not `guide` is still an explanation-only question. On a block: a numbered list a capable person could carry out. Other statuses: no unblock list. Optional second word `guide`. Does not rewrite the plan | Exact `tldr` is this page |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |
| `Nimages` | N newest scratch / `scratch/` images; optional on any mode | Visual clarification for a specific phase (prefer setting on plannify first) |
| `img` | Specific files, not a phase id. Cite promptify **Named images** | This phase reads them. A restored `images.txt` is read too |
| `Npass` | N pipeline passes of this mode’s work, not a whole-table replan | Multi-pass on that phase’s work; `-2pass` is this flag, not stop-before-end |
