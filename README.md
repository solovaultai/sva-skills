# sva-skills

Pre-written SVA skills for Cursor agents, Grok agents, etc.

## Skills

### Grok (`.grok/`)

Installed to `~/.grok/skills/<name>/`. Invoke with `/<name>` (or the aliases noted below).

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify` | Prompt QA against the real workspace: intent analysis, asset validation, enrichment, readiness scores, and an optimized execution-ready prompt. Does **not** run the work. |
| **runnify** | `/runnify`, `/promptify-run` | Promptify in execution mode: optimize the prompt, then **execute** it and return Results. |
| **askify** | `/askify`, `/promptify-ask` | Promptify ask mode: coach into an ask-kickoff prompt, then answer read-only (cited findings; no plan, no edits). |
| **plannify** | `/plannify`, `/promptify-plan` | Promptify planning mode: coach into a planning-kickoff prompt, then produce a structured plan (read-only; no implementation). |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3` | Execute phase(s) of a plannified plan: empty `/phasify` = next incomplete (same as `next`); named P0 (`0`/`p0`); or next N phases **synchronously**. On completion: aligned `phase_layout.txt` table (Task row = verbatim original ify request; Flags row only if `Nimages` and/or `Npass`; then phases). Supports `Nimages` / `Npass`. |
| **debugify** | `/debugify`, `/debug` | **Grok Debug Mode (default / full loop).** Hypothesize → temporary instrumentation → repro → evidence-backed fix → verify → remove probes. Not a speculative-fix loop. |
| **debug-kickoff** | `/debug-kickoff`, `/promptify-debug` | Read-only debug prep: code analysis, hypotheses, suspect paths, and a copy-pasteable Debug-Kickoff Prompt for `/debugify`. No instrument/fix. |
| **check-work** | `/check-work`, `/check`, `/verify` | Spawn a verifier subagent on session work (diff, build/test, correctness); fix and re-check until PASS. |
| **code-review** | `/code-review` | Strict maintainability audit: abstractions, giant files, spaghetti growth, ambitious restructure ideas. Model invocation disabled by default (slash only). |
| **create-skill** | `/create-skill` | Interactively scaffold a new Grok skill (`SKILL.md` + optional scripts/references). |
| **help** | `/help` (and related help asks) | Grok setup/docs: config, MCP, auth, skills, slash commands, keyboard shortcuts, onboarding. |
| **imagine** | (auto when image tools apply) | Guidance for Grok `image_gen` / `image_edit`: when to code vs generate, prompt craft, references, factual grounding. |

**Promptify family (Grok):**

```text
/promptify <prompt>       — analyze/optimize only
/runnify <prompt>         — optimize then EXECUTE
/askify <prompt>          — optimize then ANSWER (read-only)
/plannify <prompt>        — optimize then PLAN (read-only)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/debugify <bug report>    — full Debug Mode loop (default)
/debug-kickoff <bug>      — debug brief only (read-only)
```

### Cursor (`.cursor/skills/`)

Installed to `~/.cursor/skills/<name>/`. Same Promptify family, tuned for Cursor modes.

| Skill | Command | Description |
|-------|---------|-------------|
| **promptify** | `/promptify` | Prompt QA against the real Cursor workspace: intent, validation, enrichment, scores, optimized execution-ready prompt (no run). |
| **runnify** | `/runnify`, `/promptify-run` | Promptify execution mode: optimize, then execute and return Results. |
| **askify** | `/askify`, `/promptify-ask` | Ask-mode coach: optimize into an ask-kickoff prompt, then answer read-only (no plan, no edits). |
| **plannify** | `/plannify`, `/promptify-plan` | Planning-mode coach: optimize into a planning-kickoff prompt, then produce a structured plan (read-only). |
| **phasify** | `/phasify`, `/phasify 0`, `/phasify next`, `/phasify 3` | Execute phase(s) of a plannified plan: empty `/phasify` = next incomplete (same as `next`); named P0 (`0`/`p0`); or next N phases **synchronously**. On completion: aligned `phase_layout.txt` table (Task row = verbatim original ify request; Flags row only if `Nimages` and/or `Npass`; then phases). Supports `Nimages` / `Npass`. |
| **debugify** | `/debugify`, `/promptify-debug` | **Cursor Debug Mode kickoff only.** Code analysis + falsifiable hypotheses + copy-pasteable prompt for Cursor’s Debug mode. Does **not** instrument or fix — paste into Cursor Debug Mode to run the loop. |

**Promptify family (Cursor):**

```text
/promptify <prompt>       — analyze/optimize only
/runnify <prompt>         — optimize then EXECUTE
/askify <prompt>          — optimize then ANSWER (read-only)
/plannify <prompt>        — optimize then PLAN (read-only)
/phasify                  — execute the next incomplete phase (same as next)
/phasify 0                — execute phase P0 of the current plan
/phasify next             — execute the next incomplete phase
/phasify 3                — execute the next 3 phases, one after another
/debugify <bug report>    — Debug Mode kickoff prompt (for Cursor Debug Mode)
```

### Platform differences worth knowing

| Topic | Grok | Cursor |
|-------|------|--------|
| **debugify** | Full loop in-agent (`/debugify`) | Kickoff brief for product Debug Mode |
| Debug prep only | `/debug-kickoff` | Same role as Cursor `/debugify` |
| Grok-only utilities | `check-work`, `code-review`, `create-skill`, `help`, `imagine` | — |

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
