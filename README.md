# sva-skills

Pre-written SVA skills for Cursor agents, Grok agents, etc.

## Skills

### Grok (`.grok/`)

Installed to `~/.grok/skills/<name>/`. Invoke with `/<name>` (or the aliases noted below).

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify`, `/promptify help` | Prompt QA against the real workspace: intent analysis, asset validation, enrichment, readiness scores, and an optimized execution-ready prompt. Does **not** run the work. `/promptify help` (also `--help`, `/?`) prints the full reference. |
| **runnify** | `/runnify`, `/promptify-run`, `/runnify help` | Promptify in execution mode: optimize the prompt, then **execute** it and return Results. `/runnify help` (also `--help`, `/?`) prints the full reference. |
| **askify** | `/askify`, `/promptify-ask`, `/askify help` | Promptify ask mode: coach into an ask-kickoff prompt, then answer read-only (cited findings; no plan, no edits). `/askify help` (also `--help`, `/?`) prints the full reference. |
| **plannify** | `/plannify`, `/promptify-plan`, `/plannify fromhere`, `/plannify help` | Promptify planning mode: coach into a planning-kickoff prompt, then produce a structured plan (read-only; no implementation). `/plannify fromhere` (alias `planify fromhere`) replans from current statuses — **AskQuestion**: Keep new plan vs Continue original. Trailing tables may use Status `Deferred` and an optional reason note. `/plannify help` (also `--help`, `/?`) prints the full reference. |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3`, `/phasify done`, `/phasify -N`, `/phasify defer`, `/phasify show`, `/phasify help` | Execute phase(s) of a plannified plan: empty `/phasify` = next incomplete (same as `next`); named P0 (`0`/`p0`); next N phases **synchronously**; **Run-to-end** (`done` / `finish` / `end` / `all` / `close`); **Stop-before-end** (`-` / `-0` / `-N`, last included = `C - N`); **Defer** (`defer`, `Ndefer`, `defer N` [reason]); **Show** (`show` / `refresh`). `/phasify help` (also `--help`, `/?`) prints the full reference and does **not** execute. Mid-run: banner only; last-of-run: banner + full table. On completion: aligned `phase_layout.txt` table (Task row = verbatim original ify request; Flags row only if `Nimages` and/or `Npass`; then phases; Reason if any deferral has one). Supports `Nimages` / `Npass`. `-2pass` is a pass flag, not stop-before-end. |
| **debugify** | `/debugify`, `/debug`, `/debugify help` | **Grok Debug Mode (default / full loop).** Hypothesize → temporary instrumentation → repro → evidence-backed fix → verify → remove probes. Not a speculative-fix loop. `/debugify help` (also `--help`, `/?`) prints the full reference. |
| **debug-kickoff** | `/debug-kickoff`, `/promptify-debug` | Read-only debug prep: code analysis, hypotheses, suspect paths, and a copy-pasteable Debug-Kickoff Prompt for `/debugify`. No instrument/fix. |
| **check-work** | `/check-work`, `/check`, `/verify` | Spawn a verifier subagent on session work (diff, build/test, correctness); fix and re-check until PASS. |
| **code-review** | `/code-review` | Strict maintainability audit: abstractions, giant files, spaghetti growth, ambitious restructure ideas. Model invocation disabled by default (slash only). |
| **create-skill** | `/create-skill` | Interactively scaffold a new Grok skill (`SKILL.md` + optional scripts/references). |
| **help** | `/help` (and related help asks) | Grok setup/docs: config, MCP, auth, skills, slash commands, keyboard shortcuts, onboarding. |
| **image** | `/image`, `/image 2`, `2image` | Attach the N newest images in workspace `scratch/` and **answer** using them. `/image 2` and `2image` are the same (N = 2). Bare `/image` defaults to N = 1. Same parse as ify `Nimage` / `N images` / `N-images` (first numbered instance L→R; skip unnumbered "image"). `/image help` (also `--help`, `/?`) prints the reference. Does **not** generate images (that is **imagine**). |
| **imagine** | (auto when image tools apply) | Guidance for Grok `image_gen` / `image_edit`: when to code vs generate, prompt craft, references, factual grounding. |

**Promptify family (Grok):**

```text
/promptify <prompt>       — analyze/optimize only
/promptify help           — full promptify reference (also --help, /?)
/runnify <prompt>         — optimize then EXECUTE
/runnify help             — full runnify reference (also --help, /?)
/askify <prompt>          — optimize then ANSWER (read-only)
/askify help              — full askify reference (also --help, /?)
/plannify <prompt>        — optimize then PLAN (read-only)
/plannify fromhere        — replan from current statuses (Keep new vs Continue original)
/plannify help            — full plannify reference (also --help, /?)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/phasify done             — run every remaining incomplete phase to the end (also finish/end/all/close)
/phasify -                — stop-before-end: run all but the last work phase (`-`/`-0` = `-1`; `-N` → last included = C-N)
/phasify defer [reason]   — defer the next open phase (also Ndefer / defer N / defer pN)
/phasify show             — print the current table (also refresh; Reason if any deferral has one)
/phasify help             — full phasify reference (also --help, /?; empty /phasify stays Next)
/debugify <bug report>    — full Debug Mode loop (default)
/debugify help            — full debugify reference (also --help, /?)
/debug-kickoff <bug>      — debug brief only (read-only)
/image <question>         — newest scratch image (N = 1) + answer
/image 2 <question>       — 2 newest scratch images + answer (same as 2image)
2image <question>         — same as /image 2 (also 2 images / 2-images)
/image help               — full image reference (also --help, /?)
```

### Cursor (`.cursor/skills/`)

Installed to `~/.cursor/skills/<name>/`. Same Promptify family, tuned for Cursor modes.

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify`, `/promptify help` | Prompt QA against the real Cursor workspace: intent, validation, enrichment, scores, optimized execution-ready prompt (no run). `/promptify help` (also `--help`, `/?`) prints the full reference. |
| **runnify** | `/runnify`, `/promptify-run`, `/runnify help` | Promptify execution mode: optimize, then execute and return Results. `/runnify help` (also `--help`, `/?`) prints the full reference. |
| **askify** | `/askify`, `/promptify-ask`, `/askify help` | Ask-mode coach: optimize into an ask-kickoff prompt, then answer read-only (no plan, no edits). `/askify help` (also `--help`, `/?`) prints the full reference. |
| **plannify** | `/plannify`, `/promptify-plan`, `/plannify fromhere`, `/plannify help` | Planning-mode coach: optimize into a planning-kickoff prompt, then produce a structured plan (read-only). `/plannify fromhere` (alias `planify fromhere`) replans from current statuses — **AskQuestion**: Keep new plan vs Continue original. Trailing tables may use Status `Deferred` and an optional reason note. `/plannify help` (also `--help`, `/?`) prints the full reference. |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3`, `/phasify done`, `/phasify -N`, `/phasify defer`, `/phasify show`, `/phasify help` | Execute phase(s) of a plannified plan: empty `/phasify` = next incomplete (same as `next`); named P0 (`0`/`p0`); next N phases **synchronously**; **Run-to-end** (`done` / `finish` / `end` / `all` / `close`); **Stop-before-end** (`-` / `-0` / `-N`, last included = `C - N`); **Defer** (`defer`, `Ndefer`, `defer N` [reason]); **Show** (`show` / `refresh`). `/phasify help` (also `--help`, `/?`) prints the full reference and does **not** execute. Mid-run: banner only; last-of-run: banner + full table. On completion: aligned `phase_layout.txt` table (Task row = verbatim original ify request; Flags row only if `Nimages` and/or `Npass`; then phases; Reason if any deferral has one). Supports `Nimages` / `Npass`. `-2pass` is a pass flag, not stop-before-end. |
| **debugify** | `/debugify`, `/promptify-debug`, `/debugify help` | **Cursor Debug Mode kickoff only.** Code analysis + falsifiable hypotheses + copy-pasteable prompt for Cursor’s Debug mode. Does **not** instrument or fix — paste into Cursor Debug Mode to run the loop. `/debugify help` (also `--help`, `/?`) prints the full reference. |

**Promptify family (Cursor):**

```text
/promptify <prompt>       — analyze/optimize only
/promptify help           — full promptify reference (also --help, /?)
/runnify <prompt>         — optimize then EXECUTE
/runnify help             — full runnify reference (also --help, /?)
/askify <prompt>          — optimize then ANSWER (read-only)
/askify help              — full askify reference (also --help, /?)
/plannify <prompt>        — optimize then PLAN (read-only)
/plannify fromhere        — replan from current statuses (Keep new vs Continue original)
/plannify help            — full plannify reference (also --help, /?)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/phasify done             — run every remaining incomplete phase to the end (also finish/end/all/close)
/phasify -                — stop-before-end: run all but the last work phase (`-`/`-0` = `-1`; `-N` → last included = C-N)
/phasify defer [reason]   — defer the next open phase (also Ndefer / defer N / defer pN)
/phasify show             — print the current table (also refresh; Reason if any deferral has one)
/phasify help             — full phasify reference (also --help, /?; empty /phasify stays Next)
/debugify <bug report>    — Debug Mode kickoff prompt (for Cursor Debug Mode)
/debugify help            — full debugify reference (also --help, /?)
```

### Platform differences worth knowing

| Topic | Grok | Cursor |
|-------|------|--------|
| **debugify** | Full loop in-agent (`/debugify`) | Kickoff brief for product Debug Mode |
| Debug prep only | `/debug-kickoff` | Same role as Cursor `/debugify` |
| Grok-only utilities | `check-work`, `code-review`, `create-skill`, `help`, `image`, `imagine` | — |
| Scratch images | `/image`, `/image 2`, `2image` (standalone) | `2image` / `Nimages` on ify skills |

Name collision: both trees ship a skill named `debugify` with **different behavior**. Prefer `/debug-kickoff` on Grok when you only want a brief; use Cursor Debug Mode after Cursor `/debugify`.

## Install

From this repo:

```bash
./scripts/cli.sh install          # install/update grok + cursor skills when repo is newer
./scripts/cli.sh install grok     # ~/.grok/skills/
./scripts/cli.sh install cursor   # ~/.cursor/skills/
./scripts/cli.sh install all      # same as ./scripts/cli.sh install
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

A skill is copied when the destination is missing (first install) or when any file in the repo skill is newer than the newest file already installed. Unchanged or newer-on-disk skills are skipped unless you pass `--force`.
