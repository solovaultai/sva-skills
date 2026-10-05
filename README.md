# sva-skills

Pre-written SVA skills for Cursor agents, Grok agents, GitHub Copilot
(and Copilot Enterprise), etc.

## Skills

### Grok (`.grok/`)

Installed to `~/.grok/skills/<name>/`. Invoke with `/<name>` (or the aliases noted below).

A real ify task sets the tmux window name so a row of Grok windows can be told apart. The contract is `docs/window_title.md`. Prefixes: `PLAN:`, `DBG:`, `RUN:`, `PROMPT:`, `ASK:`, `IFY:`, `FROM:`, `DOC:`. Addify reuses the ancestor's prefix. Phasify is `PHASE:P<n>/<total>:<PREFIX>: <summary>`. Help, tldr, pass, and empty usage do not retitle. `./scripts/cli.sh install` also ensures `set -g set-titles on` and `set-titles-string "#{window_name}"` in `~/.tmux.conf`. `./scripts/cli.sh install tmux` (or `./scripts/cli.sh tmux`) does only that, and a repeat does not duplicate the lines.

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify`, `/promptify help`, `/promptify tldr` | Prompt QA against the real workspace: intent analysis, asset validation, enrichment, readiness scores, and an optimized execution-ready prompt. Does **not** run the work. `/promptify help` (also `--help`, `/?`) prints the full reference. |
| **runnify** | `/runnify`, `/promptify-run`, `/runnify help`, `/runnify tldr` | Promptify in execution mode: optimize the prompt, then **execute** it and return Results. `/runnify help` (also `--help`, `/?`) prints the full reference. |
| **askify** | `/askify`, `/promptify-ask`, `/askify help`, `/askify tldr` | Promptify ask mode: answer read-only (cited). Does not print the ask-kickoff plan unless `/askify plan`. `/askify help` (also `--help`, `/?`) prints the full reference. |
| **plannify** | `/plannify`, `/promptify-plan`, `/plannify fromhere`, `/plannify add`, `/plannify help`, `/plannify tldr` | Promptify planning mode: coach into a planning-kickoff prompt, then produce a structured plan (read-only; no implementation). `/plannify fromhere` (alias `planify fromhere`) replans from current statuses — **AskQuestion**: Keep new plan vs Continue original. `/plannify add <feature>` surgically adds a feature to the just-run plan (last ify must be plannify or phasify; no-op if nothing add/remove/changes). Trailing tables may use Status `Deferred` and an optional reason note. `/plannify help` (also `--help`, `/?`) prints the full reference. |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3`, `/phasify done`, `/phasify toend`, `/phasify -N`, `/phasify defer`, `/phasify undefer`, `/phasify rundefer`, `/phasify todo`, `/phasify explain`, `/phasify todone`, `/phasify block`, `/phasify unblock`, `/phasify runblock`, `/phasify remove`, `/phasify delete`, `/phasify smart`, `/phasify show`, `/phasify help`, `/phasify tldr` | Execute phase(s) of a plannified plan: empty `/phasify` = next incomplete (same as `next`); named P0 (`0`/`p0`); next N phases **synchronously**; **Run-to-end** (`done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` / `to end`); **Stop-before-end** (`-` / `-0` / `-N`, last included = `C - N`); **Defer** (`defer`, `Ndefer`, `defer N` [reason]); **Undefer** (`undefer`, `Nundefer`, `undefer N` — status only, no execute); **Rundefer** (`rundefer`, `Nrundefer`, `rundefer N`, `rundeferN` — undefer then execute; `rundefer N` / `2rundefer` / `rundefer2` = next N deferred, not named PN; named is `rundefer pN`); **Todo** (`todo`, `Ntodo`, `todo N` — detailed actionable list; no execute, no Status change); **Explain** (`explain`, `Nexplain`, `explain N`, `explainN` — full explanation + status glossary + TL/DR; no execute, no Status change; `explain N` / `Nexplain` / `explainN` / `2explain` = next N not-Done, including Deferred; named is only `explain pN` / `pNexplain`); **Todone** (`todone`, `Ntodone`, `todone pN`, `todone N` — Todo-depth briefing, then Status `Done`; no execute, no ack wait; `todone N` = next N eligible, not named PN); **Block** (`block`, `Nblock`, `block pN` [reason] — Status `Blocked` or `Def-Blocked`; `block N` = next N eligible, not named PN); **Unblock** (`unblock`, `Nunblock`, `unblock N` — verify a Blocked / Def-Blocked phase; Status `Unblocked` or `Deferred` on pass); **Runblock** (`runblock`, `Nrunblock`, `runblock N`, `runblockN` — user-asserted unblock then execute remaining work or mark `Done`; `runblock N` / `2runblock` / `runblock2` = next N blocked, not named PN; named is `runblock pN`); **Remove** (`remove`, `Nremove`, `remove N`, `remove pN`, `remove <title>` — drop work-phase row(s) after yes/no confirm; `remove N` / `2remove` = next N not-Done, not named PN; named is `remove pN` or unique title; remaining ids compact); **`delete`** is an exact alias of `remove`; **Show** (`show` / `refresh`). `/phasify help` (also `--help`, `/?`) prints the full reference and does **not** execute. Mid-run: banner only; last-of-run: banner + full table. On completion: aligned `phase_layout.txt` table (Task row = verbatim original ify request; Flags row only if `Nimages` and/or `Npass`; then phases; Reason if any deferral has one). Supports `Nimages` / `Npass`. `-2pass` is a pass flag, not stop-before-end. |
| **debugify** | `/debugify`, `/debug`, `/debugify help`, `/debugify tldr` | **Grok Debug Mode (default / full loop).** Hypothesize → temporary instrumentation → repro → evidence-backed fix → verify → remove probes. Not a speculative-fix loop. `/debugify help` (also `--help`, `/?`) prints the full reference. |
| **addify** | `/addify`, `/addify help`, `/addify tldr` | Thin conversation router: recover the last ify in this chat, verbatim-append the addify body, and restart or continue that skill. Empty `/addify` is short usage, not Next. `/addify help` (also `--help`, `/?`) prints the full reference. |
| **ify** | `/ify`, `/ify help`, `/ify help <verb>`, `/ify tldr`, `/ify tldr <verb>`, `/ify smart`, `/ify which` | Catalog, help, and router for the Promptify family. Does **not** plan, execute, debug, or answer domain questions. Empty `/ify` is short usage. `/ify help` prints the family catalog. `/ify help <verb>` is extreme help. `/ify tldr` prints ify’s `references/TLDR.md`; `/ify tldr <verb>` prints that verb’s. `/ify smart <prompt>` (alias `which`, or bare `/ify <prompt>`) recommends a verb + rewritten prompt and does **not** dispatch. `/ify help` (also `--help`, `/?`) prints the full reference. |
| **fromify** | `/fromify`, `/fromify help`, `/fromify tldr` | Splice local files into an ify prompt (`from=` / `from:` on any family verb; see `docs/from_contract.md`). `/fromify <files>` defaults to plannify. A verb token on the line selects that verb. `/fromify help` (also `--help`, `/?`) prints the full reference. |
| **docify** | `/docify`, `/docify help`, `/docify tldr` | Document this prompt. Default is askify; a leading ify verb selects that verb. See `.grok/docify/SKILL.md`. `/docify help` (also `--help`, `/?`) prints the full reference. |
| **saveify** | `/saveify`, `/saveify <name>`, `/saveify delete`, `/saveify help`, `/saveify tldr` | Save the current ify context (auto-name if unnamed). Delete by name or list number after yes/no. Empty `/saveify` is a real save. `savify` is a wording alias, not a folder. See `.grok/saveify/SKILL.md`. |
| **resumeify** | `/resumeify`, `/resumeify <name>`, `/resumeify <#>`, `/resumeify help`, `/resumeify tldr` | List saved contexts newest-first with dates. Restore by name or number so `/phasify` can continue. Empty `/resumeify` lists and does not restore. `resumify` is a wording alias, not a folder. See `.grok/resumeify/SKILL.md`. |
| **debug-kickoff** | `/debug-kickoff`, `/promptify-debug` | Read-only debug prep: code analysis, hypotheses, suspect paths, and a copy-pasteable Debug-Kickoff Prompt for `/debugify`. No instrument/fix. |
| **check-work** | `/check-work`, `/check`, `/verify` | Spawn a verifier subagent on session work (diff, build/test, correctness); fix and re-check until PASS. |
| **code-review** | `/code-review` | Strict maintainability audit: abstractions, giant files, spaghetti growth, ambitious restructure ideas. Model invocation disabled by default (slash only). |
| **create-skill** | `/create-skill` | Interactively scaffold a new Grok skill (`SKILL.md` + optional scripts/references). |
| **help** | `/help` (and related help asks) | Grok setup/docs: config, MCP, auth, skills, slash commands, keyboard shortcuts, onboarding. |
| **image** | `/image`, `/image 2`, `2image` | Attach the N newest images from the configured scratch source (or workspace `scratch/` if unset) and **answer** using them. `/image 2` and `2image` are the same (N = 2). Bare `/image` defaults to N = 1. Same parse as ify `Nimage` / `N images` / `N-images` (first numbered instance L→R; skip unnumbered "image"). `/image help` (also `--help`, `/?`) prints the reference. Does **not** generate images (that is **imagine**). |
| **imagine** | (auto when image tools apply) | Guidance for Grok `image_gen` / `image_edit`: when to code vs generate, prompt craft, references, factual grounding. |

**Promptify family (Grok):**

```text
/promptify <prompt>       — analyze/optimize only
/promptify help           — full promptify reference (also --help, /?)
/promptify tldr           — short form (stop)
/promptify pass help      — Pass (Npass) subsection only (also /promptify pass)
/runnify <prompt>         — optimize then EXECUTE
/runnify help             — full runnify reference (also --help, /?)
/runnify tldr             — short form (stop)
/runnify pass help        — Pass (Npass) subsection (also /runnify pass)
/askify <prompt>          — ANSWER only (read-only; no plan unless /askify plan)
/askify plan <prompt>     — print the ask-kickoff plan, then answer
/askify help              — full askify reference (also --help, /?)
/askify tldr              — short form (stop)
/askify pass help         — Pass (Npass) subsection (also /askify pass)
/plannify <prompt>        — optimize then PLAN (read-only)
/plannify fromhere        — replan from current statuses (Keep new vs Continue original)
/plannify add <feature>   — add a feature to the just-run plan (last ify must be plannify or phasify)
/plannify help            — full plannify reference (also --help, /?)
/plannify tldr            — short form (stop)
/plannify pass help       — Pass (Npass) subsection (also /plannify pass)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/phasify done             — run every remaining incomplete phase to the end (also finish/end/all/close/toend)
/phasify toend            — same as done (also to-end / to end)
/phasify -                — stop-before-end: run all but the last work phase (`-`/`-0` = `-1`; `-N` → last included = C-N)
/phasify defer [reason]   — defer the next open phase (also Ndefer / defer N / defer pN)
/phasify undefer          — undefer the next Deferred phase (also Nundefer / undefer N / undefer pN)
/phasify rundefer         — undefer+execute next Deferred phase (also Nrundefer / rundefer N / rundeferN; rundefer 2 / 2rundefer = next 2, not P2)
/phasify todo             — detailed list for the next not-done / not-deferred phase (also Ntodo / todo N / todo pN)
/phasify explain          — explain next not-Done phase (includes Deferred; also Nexplain / explain N / explainN; named is pN / PN only)
/phasify todone           — Todo+close next eligible phase (also Ntodone / todone pN; todone N = next N, not named PN)
/phasify block [reason]   — block the next 1 eligible phase (also Nblock / block pN; block N = next N, not named PN)
/phasify unblock          — verify the next Blocked / Def-Blocked phase (also Nunblock / unblock N / unblock pN)
/phasify runblock         — unblock+run-or-mark next Blocked phase (also Nrunblock / runblock N / runblockN; runblock 2 / 2runblock = next 2, not P2)
/phasify remove           — drop next not-Done phase after yes/no (also Nremove / remove N / remove pN / remove <title>; remove 2 / 2remove = next 2, not P2)
/phasify delete           — exact alias of remove
/phasify smart <prompt>   — select a mode from the live plan and run it (not Next; not implicit)
/phasify show             — print the current table (also refresh; Reason if any deferral has one)
/phasify help             — full phasify reference (also --help, /?; empty /phasify stays Next)
/phasify tldr             — short form (stop; never a phase id)
/phasify pass help        — Pass (Npass) subsection (also /phasify pass)
/phasify … Nimages Npass  — any mode; flags stripped first (`-2pass` ≠ stop-before-end)
/debugify <bug report>    — full Debug Mode loop (default)
/debugify help            — full debugify reference (also --help, /?)
/debugify tldr            — short form (stop)
/debugify pass help       — Pass (Npass) subsection (also /debugify pass)
/addify <text>            — append <text> to the last ify and restart/continue that skill
/addify help              — full addify reference (also --help, /?)
/addify tldr              — short form (stop)
/addify pass help         — Pass (Npass) subsection (also /addify pass)
/ify                      — family catalog one-liner + syntax (not Help, not Next)
/ify help                 — family catalog (also --help, /?)
/ify help <verb>          — extreme help for that ify verb
/ify tldr                 — short tldr of ify (stop)
/ify tldr <verb>          — short tldr of that verb (stop)
/ify smart <prompt>       — recommend verb + rewritten prompt (do not run)
/ify which <prompt>       — alias of smart
/ify <prompt>             — implicit smart
/ify pass help            — Pass (Npass) subsection (also /ify pass)
/fromify <files>          — plannify those files (default verb)
/fromify <verb> <files>   — that ify verb; file text is the body
/fromify help             — full fromify reference (also --help, /?)
/fromify tldr             — short form (stop)
<verb> from=<path>        — splice local files into that verb (also from:; see docs/from_contract.md)
/docify <prompt>          — askify that prompt, then docify
/docify <verb> <prompt>   — that ify verb instead of askify
/docify help              — full docify reference (also --help, /?)
/docify tldr              — short form (stop)
<verb> docify              — write that verb's deliverable (also docpathify; see docs/docify_contract.md)
/saveify [<name>]         — save current ify context (auto-name if unnamed); `/saveify list` displays one; delete by name or # after yes/no (empty is a real save)
/resumeify [<name|#>]     — list newest-first with dates; `/resumeify list` selects one for /phasify; restore by name or # (empty lists and does not restore)
/debug-kickoff <bug>      — debug brief only (read-only)
/image <question>         — newest scratch-source image (N = 1) + answer
/image 2 <question>       — 2 newest scratch-source images + answer (same as 2image)
2image <question>         — same as /image 2 (also 2 images / 2-images)
/image help               — full image reference (also --help, /?)
/image pass help          — Npass is an ify flag; see /promptify pass help
```

### Cursor (`.cursor/skills/`)

Installed to `~/.cursor/skills/<name>/`. Same Promptify family, tuned for Cursor modes.

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify`, `/promptify help`, `/promptify tldr` | Prompt QA against the real Cursor workspace: intent, validation, enrichment, scores, optimized execution-ready prompt (no run). `/promptify help` (also `--help`, `/?`) prints the full reference. |
| **runnify** | `/runnify`, `/promptify-run`, `/runnify help`, `/runnify tldr` | Promptify execution mode: optimize, then execute and return Results. `/runnify help` (also `--help`, `/?`) prints the full reference. |
| **askify** | `/askify`, `/promptify-ask`, `/askify help`, `/askify tldr` | Ask-mode: answer read-only. Does not print the ask-kickoff plan unless `/askify plan`. `/askify help` (also `--help`, `/?`) prints the full reference. |
| **plannify** | `/plannify`, `/promptify-plan`, `/plannify fromhere`, `/plannify add`, `/plannify help`, `/plannify tldr` | Planning-mode coach: optimize into a planning-kickoff prompt, then produce a structured plan (read-only). `/plannify fromhere` (alias `planify fromhere`) replans from current statuses — **AskQuestion**: Keep new plan vs Continue original. `/plannify add <feature>` surgically adds a feature to the just-run plan (last ify must be plannify or phasify; no-op if nothing add/remove/changes). Trailing tables may use Status `Deferred` and an optional reason note. `/plannify help` (also `--help`, `/?`) prints the full reference. |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3`, `/phasify done`, `/phasify toend`, `/phasify -N`, `/phasify defer`, `/phasify undefer`, `/phasify rundefer`, `/phasify todo`, `/phasify explain`, `/phasify todone`, `/phasify block`, `/phasify unblock`, `/phasify runblock`, `/phasify remove`, `/phasify delete`, `/phasify smart`, `/phasify show`, `/phasify help`, `/phasify tldr` | Execute phase(s) of a plannified plan: empty `/phasify` = next incomplete (same as `next`); named P0 (`0`/`p0`); next N phases **synchronously**; **Run-to-end** (`done` / `finish` / `end` / `all` / `close` / `toend` / `to-end` / `to end`); **Stop-before-end** (`-` / `-0` / `-N`, last included = `C - N`); **Defer** (`defer`, `Ndefer`, `defer N` [reason]); **Undefer** (`undefer`, `Nundefer`, `undefer N` — status only, no execute); **Rundefer** (`rundefer`, `Nrundefer`, `rundefer N`, `rundeferN` — undefer then execute; `rundefer N` / `2rundefer` / `rundefer2` = next N deferred, not named PN; named is `rundefer pN`); **Todo** (`todo`, `Ntodo`, `todo N` — detailed actionable list; no execute, no Status change); **Explain** (`explain`, `Nexplain`, `explain N`, `explainN` — full explanation + status glossary + TL/DR; no execute, no Status change; `explain N` / `Nexplain` / `explainN` / `2explain` = next N not-Done, including Deferred; named is only `explain pN` / `pNexplain`); **Todone** (`todone`, `Ntodone`, `todone pN`, `todone N` — Todo-depth briefing, then Status `Done`; no execute, no ack wait; `todone N` = next N eligible, not named PN); **Block** (`block`, `Nblock`, `block pN` [reason] — Status `Blocked` or `Def-Blocked`; `block N` = next N eligible, not named PN); **Unblock** (`unblock`, `Nunblock`, `unblock N` — verify a Blocked / Def-Blocked phase; Status `Unblocked` or `Deferred` on pass); **Runblock** (`runblock`, `Nrunblock`, `runblock N`, `runblockN` — user-asserted unblock then execute remaining work or mark `Done`; `runblock N` / `2runblock` / `runblock2` = next N blocked, not named PN; named is `runblock pN`); **Remove** (`remove`, `Nremove`, `remove N`, `remove pN`, `remove <title>` — drop work-phase row(s) after yes/no confirm; `remove N` / `2remove` = next N not-Done, not named PN; named is `remove pN` or unique title; remaining ids compact); **`delete`** is an exact alias of `remove`; **Show** (`show` / `refresh`). `/phasify help` (also `--help`, `/?`) prints the full reference and does **not** execute. Mid-run: banner only; last-of-run: banner + full table. On completion: aligned `phase_layout.txt` table (Task row = verbatim original ify request; Flags row only if `Nimages` and/or `Npass`; then phases; Reason if any deferral has one). Supports `Nimages` / `Npass`. `-2pass` is a pass flag, not stop-before-end. |
| **debugify** | `/debugify`, `/promptify-debug`, `/debugify help`, `/debugify tldr` | **Cursor Debug Mode kickoff only.** Code analysis + falsifiable hypotheses + copy-pasteable prompt for Cursor’s Debug mode. Does **not** instrument or fix — paste into Cursor Debug Mode to run the loop. `/debugify help` (also `--help`, `/?`) prints the full reference. |
| **addify** | `/addify`, `/addify help`, `/addify tldr` | Thin conversation router: recover the last ify in this chat, verbatim-append the addify body, and restart or continue that skill. Empty `/addify` is short usage, not Next. `/addify help` (also `--help`, `/?`) prints the full reference. |
| **ify** | `/ify`, `/ify help`, `/ify help <verb>`, `/ify tldr`, `/ify tldr <verb>`, `/ify smart`, `/ify which` | Catalog, help, and router for the Promptify family. Does **not** plan, execute, debug, or answer domain questions. Empty `/ify` is short usage. `/ify help` prints the family catalog. `/ify help <verb>` is extreme help. `/ify tldr` prints ify’s `references/TLDR.md`; `/ify tldr <verb>` prints that verb’s. `/ify smart <prompt>` (alias `which`, or bare `/ify <prompt>`) recommends a verb + rewritten prompt and does **not** dispatch. `/ify help` (also `--help`, `/?`) prints the full reference. |
| **fromify** | `/fromify`, `/fromify help`, `/fromify tldr` | Splice local files into an ify prompt (`from=` / `from:` on any family verb; see `docs/from_contract.md`). `/fromify <files>` defaults to plannify. A verb token on the line selects that verb. `/fromify help` (also `--help`, `/?`) prints the full reference. |
| **docify** | `/docify`, `/docify help`, `/docify tldr` | Document this prompt. Default is askify; a leading ify verb selects that verb. See `.cursor/skills/docify/SKILL.md`. `/docify help` (also `--help`, `/?`) prints the full reference. |
| **saveify** | `/saveify`, `/saveify <name>`, `/saveify delete`, `/saveify help`, `/saveify tldr` | Save the current ify context (auto-name if unnamed). Delete by name or list number after yes/no. Empty `/saveify` is a real save. `savify` is a wording alias, not a folder. See `.cursor/skills/saveify/SKILL.md`. |
| **resumeify** | `/resumeify`, `/resumeify <name>`, `/resumeify <#>`, `/resumeify help`, `/resumeify tldr` | List saved contexts newest-first with dates. Restore by name or number so `/phasify` can continue. Empty `/resumeify` lists and does not restore. `resumify` is a wording alias, not a folder. See `.cursor/skills/resumeify/SKILL.md`. |

**Promptify family (Cursor):**

```text
/promptify <prompt>       — analyze/optimize only
/promptify help           — full promptify reference (also --help, /?)
/promptify tldr           — short form (stop)
/promptify pass help      — Pass (Npass) subsection only (also /promptify pass)
/runnify <prompt>         — optimize then EXECUTE
/runnify help             — full runnify reference (also --help, /?)
/runnify tldr             — short form (stop)
/runnify pass help        — Pass (Npass) subsection (also /runnify pass)
/askify <prompt>          — ANSWER only (read-only; no plan unless /askify plan)
/askify plan <prompt>     — print the ask-kickoff plan, then answer
/askify help              — full askify reference (also --help, /?)
/askify tldr              — short form (stop)
/askify pass help         — Pass (Npass) subsection (also /askify pass)
/plannify <prompt>        — optimize then PLAN (read-only)
/plannify fromhere        — replan from current statuses (Keep new vs Continue original)
/plannify add <feature>   — add a feature to the just-run plan (last ify must be plannify or phasify)
/plannify help            — full plannify reference (also --help, /?)
/plannify tldr            — short form (stop)
/plannify pass help       — Pass (Npass) subsection (also /plannify pass)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/phasify done             — run every remaining incomplete phase to the end (also finish/end/all/close/toend)
/phasify toend            — same as done (also to-end / to end)
/phasify -                — stop-before-end: run all but the last work phase (`-`/`-0` = `-1`; `-N` → last included = C-N)
/phasify defer [reason]   — defer the next open phase (also Ndefer / defer N / defer pN)
/phasify undefer          — undefer the next Deferred phase (also Nundefer / undefer N / undefer pN)
/phasify rundefer         — undefer+execute next Deferred phase (also Nrundefer / rundefer N / rundeferN; rundefer 2 / 2rundefer = next 2, not P2)
/phasify todo             — detailed list for the next not-done / not-deferred phase (also Ntodo / todo N / todo pN)
/phasify explain          — explain next not-Done phase (includes Deferred; also Nexplain / explain N / explainN; named is pN / PN only)
/phasify todone           — Todo+close next eligible phase (also Ntodone / todone pN; todone N = next N, not named PN)
/phasify block [reason]   — block the next 1 eligible phase (also Nblock / block pN; block N = next N, not named PN)
/phasify unblock          — verify the next Blocked / Def-Blocked phase (also Nunblock / unblock N / unblock pN)
/phasify runblock         — unblock+run-or-mark next Blocked phase (also Nrunblock / runblock N / runblockN; runblock 2 / 2runblock = next 2, not P2)
/phasify remove           — drop next not-Done phase after yes/no (also Nremove / remove N / remove pN / remove <title>; remove 2 / 2remove = next 2, not P2)
/phasify delete           — exact alias of remove
/phasify smart <prompt>   — select a mode from the live plan and run it (not Next; not implicit)
/phasify show             — print the current table (also refresh; Reason if any deferral has one)
/phasify help             — full phasify reference (also --help, /?; empty /phasify stays Next)
/phasify tldr             — short form (stop; never a phase id)
/phasify pass help        — Pass (Npass) subsection (also /phasify pass)
/phasify … Nimages Npass  — any mode; flags stripped first (`-2pass` ≠ stop-before-end)
/debugify <bug report>    — Debug Mode kickoff prompt (for Cursor Debug Mode)
/debugify help            — full debugify reference (also --help, /?)
/debugify tldr            — short form (stop)
/debugify pass help       — Pass (Npass) subsection (also /debugify pass)
/addify <text>            — append <text> to the last ify and restart/continue that skill
/addify help              — full addify reference (also --help, /?)
/addify tldr              — short form (stop)
/addify pass help         — Pass (Npass) subsection (also /addify pass)
/ify                      — family catalog one-liner + syntax (not Help, not Next)
/ify help                 — family catalog (also --help, /?)
/ify help <verb>          — extreme help for that ify verb
/ify tldr                 — short tldr of ify (stop)
/ify tldr <verb>          — short tldr of that verb (stop)
/ify smart <prompt>       — recommend verb + rewritten prompt (do not run)
/ify which <prompt>       — alias of smart
/ify <prompt>             — implicit smart
/ify pass help            — Pass (Npass) subsection (also /ify pass)
/fromify <files>          — plannify those files (default verb)
/fromify <verb> <files>   — that ify verb; file text is the body
/fromify help             — full fromify reference (also --help, /?)
/fromify tldr             — short form (stop)
<verb> from=<path>        — splice local files into that verb (also from:; see docs/from_contract.md)
/docify <prompt>          — askify that prompt, then docify
/docify <verb> <prompt>   — that ify verb instead of askify
/docify help              — full docify reference (also --help, /?)
/docify tldr              — short form (stop)
<verb> docify              — write that verb's deliverable (also docpathify; see docs/docify_contract.md)
/saveify [<name>]         — save current ify context (auto-name if unnamed); `/saveify list` displays one; delete by name or # after yes/no (empty is a real save)
/resumeify [<name|#>]     — list newest-first with dates; `/resumeify list` selects one for /phasify; restore by name or # (empty lists and does not restore)
```

### Copilot (`.copilot/skills/`)

Installed to `~/.copilot/skills/<name>/` (Windows:
`%USERPROFILE%\.copilot\skills\<name>\`). Same Promptify family as
Cursor, with Copilot paths/tools. Cloud / github.com code review only
sees a **consumer** copy under `<repo>/.github/skills/` — see
`docs/COPILOT_LOAD.md`. Spec: `docs/COPILOT_SKILLS.md`.

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify`, `/promptify help`, `/promptify tldr` | Prompt QA against the real workspace: intent, validation, enrichment, scores, optimized execution-ready prompt (no run). `/promptify help` (also `--help`, `/?`) prints the full reference. |
| **runnify** | `/runnify`, `/promptify-run`, `/runnify help`, `/runnify tldr` | Promptify execution mode: optimize, then execute and return Results. Slash-preferable. `/runnify help` (also `--help`, `/?`) prints the full reference. |
| **askify** | `/askify`, `/promptify-ask`, `/askify help`, `/askify tldr` | Ask-mode: answer read-only. Does not print the ask-kickoff plan unless `/askify plan`. `/askify help` (also `--help`, `/?`) prints the full reference. |
| **plannify** | `/plannify`, `/promptify-plan`, `/plannify fromhere`, `/plannify add`, `/plannify help`, `/plannify tldr` | Planning-mode coach: optimize into a planning-kickoff prompt, then produce a structured plan (read-only). `/plannify fromhere` (alias `planify fromhere`) replans from current statuses — Copilot chat confirm: Keep new plan vs Continue original. `/plannify add <feature>` surgically adds a feature to the just-run plan (last ify must be plannify or phasify). `/plannify help` (also `--help`, `/?`) prints the full reference. |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3`, `/phasify done`, `/phasify toend`, `/phasify -N`, `/phasify defer`, `/phasify undefer`, `/phasify rundefer`, `/phasify todo`, `/phasify explain`, `/phasify todone`, `/phasify block`, `/phasify unblock`, `/phasify runblock`, `/phasify remove`, `/phasify delete`, `/phasify smart`, `/phasify show`, `/phasify help`, `/phasify tldr` | Same phase modes as Cursor/Grok. Empty `/phasify` = next incomplete. Slash-preferable. `/phasify help` (also `--help`, `/?`) prints the full reference and does **not** execute. Supports `Nimages` / `Npass`. |
| **debugify** | `/debugify`, `/debug`, `/promptify-debug`, `/debugify help`, `/debugify tldr` | **Copilot Debug Mode (full loop)** — same shape as Grok, not Cursor kickoff. Hypothesize → temporary instrumentation → repro → evidence-backed fix → verify → remove probes. No `/debug-kickoff` in this tree. `/debugify help` (also `--help`, `/?`) prints the full reference. |
| **addify** | `/addify`, `/addify help`, `/addify tldr` | Thin conversation router: recover the last ify in this chat, verbatim-append the addify body, and restart or continue that skill. Slash-preferable. Empty `/addify` is short usage, not Next. `/addify help` (also `--help`, `/?`) prints the full reference. |
| **ify** | `/ify`, `/ify help`, `/ify help <verb>`, `/ify tldr`, `/ify tldr <verb>`, `/ify smart`, `/ify which` | Catalog, help, and router for the Promptify family **in this Copilot tree**. Does **not** plan, execute, debug, or answer domain questions. Empty `/ify` is short usage. `/ify help` (also `--help`, `/?`) prints the full reference. |
| **fromify** | `/fromify`, `/fromify help`, `/fromify tldr` | Splice local files into an ify prompt (`from=` / `from:` on any family verb; see `docs/from_contract.md`). `/fromify <files>` defaults to plannify. A verb token on the line selects that verb. Slash-preferable. `/fromify help` (also `--help`, `/?`) prints the full reference. |
| **docify** | `/docify`, `/docify help`, `/docify tldr` | Document this prompt. Default is askify; a leading ify verb selects that verb. See `.copilot/skills/docify/SKILL.md`. `/docify help` (also `--help`, `/?`) prints the full reference. |
| **saveify** | `/saveify`, `/saveify <name>`, `/saveify delete`, `/saveify help`, `/saveify tldr` | Save the current ify context (auto-name if unnamed). Delete by name or list number after yes/no. Empty `/saveify` is a real save. `savify` is a wording alias, not a folder. See `.copilot/skills/saveify/SKILL.md`. |
| **resumeify** | `/resumeify`, `/resumeify <name>`, `/resumeify <#>`, `/resumeify help`, `/resumeify tldr` | List saved contexts newest-first with dates. Restore by name or number so `/phasify` can continue. Empty `/resumeify` lists and does not restore. `resumify` is a wording alias, not a folder. See `.copilot/skills/resumeify/SKILL.md`. |

**Promptify family (Copilot):**

```text
/promptify <prompt>       — analyze/optimize only
/promptify help           — full promptify reference (also --help, /?)
/promptify tldr           — short form (stop)
/promptify pass help      — Pass (Npass) subsection only (also /promptify pass)
/runnify <prompt>         — optimize then EXECUTE
/runnify help             — full runnify reference (also --help, /?)
/runnify tldr             — short form (stop)
/runnify pass help        — Pass (Npass) subsection (also /runnify pass)
/askify <prompt>          — ANSWER only (read-only; no plan unless /askify plan)
/askify plan <prompt>     — print the ask-kickoff plan, then answer
/askify help              — full askify reference (also --help, /?)
/askify tldr              — short form (stop)
/askify pass help         — Pass (Npass) subsection (also /askify pass)
/plannify <prompt>        — optimize then PLAN (read-only)
/plannify fromhere        — replan from current statuses (Keep new vs Continue original)
/plannify add <feature>   — add a feature to the just-run plan (last ify must be plannify or phasify)
/plannify help            — full plannify reference (also --help, /?)
/plannify tldr            — short form (stop)
/plannify pass help       — Pass (Npass) subsection (also /plannify pass)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/phasify done             — run every remaining incomplete phase to the end (also finish/end/all/close/toend)
/phasify toend            — same as done (also to-end / to end)
/phasify -                — stop-before-end: run all but the last work phase (`-`/`-0` = `-1`; `-N` → last included = C-N)
/phasify defer [reason]   — defer the next open phase (also Ndefer / defer N / defer pN)
/phasify undefer          — undefer the next Deferred phase (also Nundefer / undefer N / undefer pN)
/phasify rundefer         — undefer+execute next Deferred phase (also Nrundefer / rundefer N / rundeferN; rundefer 2 / 2rundefer = next 2, not P2)
/phasify todo             — detailed list for the next not-done / not-deferred phase (also Ntodo / todo N / todo pN)
/phasify explain          — explain next not-Done phase (includes Deferred; also Nexplain / explain N / explainN; named is pN / PN only)
/phasify todone           — Todo+close next eligible phase (also Ntodone / todone pN; todone N = next N, not named PN)
/phasify block [reason]   — block the next 1 eligible phase (also Nblock / block pN; block N = next N, not named PN)
/phasify unblock          — verify the next Blocked / Def-Blocked phase (also Nunblock / unblock N / unblock pN)
/phasify runblock         — unblock+run-or-mark next Blocked phase (also Nrunblock / runblock N / runblockN; runblock 2 / 2runblock = next 2, not P2)
/phasify remove           — drop next not-Done phase after yes/no (also Nremove / remove N / remove pN / remove <title>; remove 2 / 2remove = next 2, not P2)
/phasify delete           — exact alias of remove
/phasify smart <prompt>   — select a mode from the live plan and run it (not Next; not implicit)
/phasify show             — print the current table (also refresh; Reason if any deferral has one)
/phasify help             — full phasify reference (also --help, /?; empty /phasify stays Next)
/phasify tldr             — short form (stop; never a phase id)
/phasify pass help        — Pass (Npass) subsection (also /phasify pass)
/phasify … Nimages Npass  — any mode; flags stripped first (`-2pass` ≠ stop-before-end)
/debugify <bug report>    — full Debug Mode loop (default; same as Grok)
/debugify help            — full debugify reference (also --help, /?)
/debugify tldr            — short form (stop)
/debugify pass help       — Pass (Npass) subsection (also /debugify pass)
/addify <text>            — append <text> to the last ify and restart/continue that skill
/addify help              — full addify reference (also --help, /?)
/addify tldr              — short form (stop)
/addify pass help         — Pass (Npass) subsection (also /addify pass)
/ify                      — family catalog one-liner + syntax (not Help, not Next)
/ify help                 — family catalog (also --help, /?)
/ify help <verb>          — extreme help for that ify verb
/ify tldr                 — short tldr of ify (stop)
/ify tldr <verb>          — short tldr of that verb (stop)
/ify smart <prompt>       — recommend verb + rewritten prompt (do not run)
/ify which <prompt>       — alias of smart
/ify <prompt>             — implicit smart
/ify pass help            — Pass (Npass) subsection (also /ify pass)
/fromify <files>          — plannify those files (default verb)
/fromify <verb> <files>   — that ify verb; file text is the body
/fromify help             — full fromify reference (also --help, /?)
/fromify tldr             — short form (stop)
<verb> from=<path>        — splice local files into that verb (also from:; see docs/from_contract.md)
/docify <prompt>          — askify that prompt, then docify
/docify <verb> <prompt>   — that ify verb instead of askify
/docify help              — full docify reference (also --help, /?)
/docify tldr              — short form (stop)
<verb> docify              — write that verb's deliverable (also docpathify; see docs/docify_contract.md)
/saveify [<name>]         — save current ify context (auto-name if unnamed); `/saveify list` displays one; delete by name or # after yes/no (empty is a real save)
/resumeify [<name|#>]     — list newest-first with dates; `/resumeify list` selects one for /phasify; restore by name or # (empty lists and does not restore)
```

After a copy, Copilot CLI: `/skills reload` (or `copilot skill add`).
Chat: `/<name>`.

### Platform differences worth knowing

| Topic | Grok | Cursor | Copilot |
|-------|------|--------|---------|
| **debugify** | Full loop in-agent (`/debugify`) | Kickoff brief for product Debug Mode | Full loop in-agent (`/debugify`, `/debug`) — same as Grok |
| Debug prep only | `/debug-kickoff` | Same role as Cursor `/debugify` | No `/debug-kickoff`; stop after Investigate + Hypothesize if they only want a brief |
| Grok-only utilities | `check-work`, `code-review`, `create-skill`, `help`, `image`, `imagine` | — | — |
| Scratch images | `/image`, `/image 2`, `2image` (standalone); last-N via `scratch ls` | `2image` / `Nimages` on ify skills; last-N via `scratch ls` | `Nimages` on ify skills; last-N via `scratch ls` (no standalone `/image`) |
| Personal dest | `~/.grok/skills` | `~/.cursor/skills` | `~/.copilot/skills` (Windows `%USERPROFILE%\.copilot\skills`) |
| Cloud / github.com | — | — | Consumer `<repo>/.github/skills` (`project` / `docs/COPILOT_LOAD.md`) |

Name collision: all three trees ship a skill named `debugify` with
**different behavior on Cursor**. Grok and Copilot run the full loop
in-agent. Cursor `/debugify` is kickoff-only — paste into Cursor Debug
Mode. Prefer `/debug-kickoff` on Grok when you only want a brief.

## Install

New or updated skills in this repo (including **ify**) appear under
`~/.cursor/skills/`, `~/.grok/skills/`, and `~/.copilot/skills/` only
after install. `scripts/cli.sh` auto-discovers skill folders — no
script edit needed. Run `./scripts/cli.sh install` (or `install all`)
for grok + cursor + copilot. `install copilot` is the Copilot dest
only. On a local copilot install, if GitHub Copilot (VS Code / CLI)
is missing but installable, the installer asks whether to install
it (`--host` / `--no-host`). `pullinst` pulls `origin main` first,
then runs the same install (skip install if pull fails). Copilot
cloud dest: `project` copies into a consumer repo’s `.github/skills`
(`docs/COPILOT_LOAD.md`).

From this repo:

```bash
./scripts/cli.sh install          # install/update grok + cursor + copilot when repo is newer
./scripts/cli.sh install grok     # ~/.grok/skills/
./scripts/cli.sh install cursor   # ~/.cursor/skills/
./scripts/cli.sh install copilot  # ~/.copilot/skills/ (asks to install GitHub Copilot if missing)
./scripts/cli.sh install copilot --host     # also install VS Code Copilot + CLI when possible
./scripts/cli.sh install copilot --no-host  # skills only
./scripts/cli.sh install all      # same as ./scripts/cli.sh install (grok + cursor + copilot)
./scripts/cli.sh project /path/to/repo   # .copilot/skills → <repo>/.github/skills
./scripts/cli.sh pullinst         # git pull origin main, then install
./scripts/cli.sh pullinst grok    # pull, then ~/.grok/skills/ only
./scripts/cli.sh pullinst cursor  # pull, then ~/.cursor/skills/ only
./scripts/cli.sh pullinst copilot # pull, then ~/.copilot/skills/ only
./scripts/cli.sh status           # show what would install vs skip
./scripts/cli.sh install --dry-run
./scripts/cli.sh install --force  # overwrite even if dest is newer
```

Windows 10/11 (PowerShell 5.1 or 7+; same flags and behavior as `cli.sh`).
Use `scripts\cli.cmd` from `cmd.exe`, or if `.ps1` scripts are blocked:
`Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`.

```powershell
.\scripts\cli.ps1 install
.\scripts\cli.ps1 install grok
.\scripts\cli.ps1 install copilot
.\scripts\cli.ps1 project C:\path\to\repo
.\scripts\cli.ps1 pullinst
.\scripts\cli.ps1 pullinst grok
.\scripts\cli.ps1 pullinst copilot
.\scripts\cli.ps1 status
.\scripts\cli.ps1 install --dry-run
.\scripts\cli.ps1 install --force
# from cmd.exe: scripts\cli.cmd install
```

### Remote (sshub connections)

Uses the same connection file as `sshub` / `sshot`:

`~/.local/share/sshub/connections.env` (override with `SSHUB_ENV_FILE`).

```bash
./scripts/cli.sh list                              # list connections (name + alias)
./scripts/cli.sh install --remote                  # all skills → every connection
./scripts/cli.sh install grok --remote casai       # name or alias (e.g. casai → CASSADYAIFAP)
./scripts/cli.sh install --remote casai CAS2SYS
./scripts/cli.sh install --local --remote          # this machine + all remotes
./scripts/cli.sh status --remote casai
./scripts/cli.sh install --remote --dry-run
```

Windows uses the same `connections.env` and OpenSSH (`ssh.exe` / `scp.exe`):

```powershell
.\scripts\cli.ps1 list
.\scripts\cli.ps1 install --remote
.\scripts\cli.ps1 install grok --remote casai
.\scripts\cli.ps1 status --remote casai
```

Remote skills land in the **remote user's** home:

| Source | Destination |
|--------|-------------|
| `.grok/<skill>/` | `~/.grok/skills/<skill>/` (local or remote `$HOME`) |
| `.cursor/skills/<skill>/` | `~/.cursor/skills/<skill>/` |
| `.copilot/skills/<skill>/` | `~/.copilot/skills/<skill>/` (`install` / `install all` / `install copilot` / `--remote`) |

A skill is copied when the destination is missing (first install) or when any file in the repo skill is newer than the newest file already installed. Unchanged or newer-on-disk skills are skipped unless you pass `--force`.

Local `install` also detects the OS screenshot folder (if unset) and writes the scratch source config below.

## Scratch source

ify `Nimages` and Grok `/image` resolve last-N images from a persisted source. `install` detects the screenshot folder on this box and writes the config **only if it is missing**. `scratch detect --force` overwrites.

**Config file** (`chmod 600`; `show` prints the path it used):

| CLI | Path |
|-----|------|
| `cli.sh` (Linux / Git Bash) | `${XDG_DATA_HOME:-~/.local/share}/sva-skills/scratch.env` |
| `cli.ps1` (Windows PowerShell) | `%LOCALAPPDATA%\sva-skills\scratch.env` |

```bash
# kind=local | remote
SCRATCH_KIND=local
SCRATCH_DIR=/home/ami/Pictures/Screenshots
# remote only:
# SCRATCH_KIND=remote
# SCRATCH_CONN=cas3          # sshub name or alias
# SCRATCH_REMOTE_DIR=scratch # bare → NAME_FOLDER (same as sshub)
```

```bash
./scripts/cli.sh scratch show
./scripts/cli.sh scratch set ~/Pictures/Screenshots
./scripts/cli.sh scratch set --remote cas3 scratch
./scripts/cli.sh scratch search
./scripts/cli.sh scratch search --remote cas3
./scripts/cli.sh scratch detect          # write only if unset
./scripts/cli.sh scratch detect --force
./scripts/cli.sh scratch ls              # last 5 paths (skills use this)
./scripts/cli.sh scratch ls 3
```

```powershell
.\scripts\cli.ps1 scratch show
.\scripts\cli.ps1 scratch set $env:USERPROFILE\Pictures\Screenshots
.\scripts\cli.ps1 scratch set --remote cas3 scratch
.\scripts\cli.ps1 scratch search
.\scripts\cli.ps1 scratch ls 3
```

Detect prefers a directory that **exists and has images** (`png/jpg/jpeg/webp/gif/bmp`): `$SCREENSHOT_DIR`, then Linux `xdg-user-dir PICTURES`/`Screenshots` or `~/Pictures/Screenshots` / `~/Pictures`, then Windows `Pictures\Screenshots` / OneDrive, then the first existing candidate (even if empty). If nothing is found, it leaves the file unset and tells you to `scratch search`.

**Last-N:** `scratch ls N` prints absolute paths (default N = 5). Local: newest mtime in `SCRATCH_DIR`. Remote: `ssh` lists image mtimes in the resolved remote dir, then `scp` **only those N files** into `${XDG_CACHE_HOME:-~/.cache}/sva-skills/scratch/` (PowerShell: `%LOCALAPPDATA%\sva-skills\cache\scratch`) and prints the cache paths. Never `scp -r` the whole folder.

Skills: if `scratch.env` exists, run `scratch ls N` and **read those paths**; else workspace `scratch/`. The ack names the source (`local ~/Pictures/Screenshots` or `remote cas3:scratch`).
