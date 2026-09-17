# Copilot skills — frozen spec (P0)

Source of truth for adding a **third** Promptify-family tree for GitHub
Copilot and Copilot Enterprise. Later phases implement this file; they
do not reopen these decisions without `/plannify fromhere`.

Verified from this repo (`scripts/cli.sh`, `scripts/cli.ps1`,
`.cursor/skills/`, `.grok/`, `README.md`) and published Copilot skill
locations. Do not invent other dests.

---

## I1 — Repo source tree

sva-skills authors Copilot skills under:

```text
.copilot/skills/<name>/SKILL.md
```

Same layout idea as `.cursor/skills/<name>/` (not Grok’s flat `.grok/<name>/`).

Do **not** author the canonical copies in `.github/skills/` inside
sva-skills. That path is a **consumer-repo** project dest (I6), copied
later (P4), not the source of truth.

Also accepted by Copilot hosts but **not** used as this repo’s source:
`.agents/skills`, `.claude/skills`, `~/.agents/skills`.

## I2 — Family set (in scope)

Port these eight skills only:

| Skill | Copy from | Notes |
|-------|-----------|--------|
| promptify | Cursor | Paths/tools/hints only |
| runnify | Cursor | Mutating; slash-preferable (I4) |
| askify | Cursor | Read-only answer |
| plannify | Cursor | Trim `description` (I4) |
| phasify | Cursor | Trim `description` (I4); mutating |
| debugify | **Grok** | Full in-agent loop (I3) — not Cursor kickoff |
| addify | Cursor | Mutating; slash-preferable (I4) |
| ify | Cursor | Catalog/router; this tree = Copilot |

**Out of scope** unless a later `/plannify add`:

- Grok-only: `image`, `imagine`, `help`, `create-skill`
- Optional later: `check-work`, `code-review`, `debug-kickoff`

P1 may add Copilot `create-skill` **notes** (how to scaffold a Copilot
skill in this tree). That is not shipping Grok `/create-skill`.

## I3 — debugify = full loop

Copilot has no Cursor Debug Mode product. Copilot `debugify` is the
**Grok** loop, not the Cursor kickoff-only coach:

1. Investigate → 2. Hypothesize → 3. Instrument → 4. Reproduce →
5. Analyze → 6. Fix → 7. Verify → 8. Clean

Hard gate: no production fix until runtime (or equivalent hard)
evidence. Alias `/debug` as on Grok.

Cursor `.cursor/skills/debugify/` stays kickoff-only. Do not change it.

## I4 — Frontmatter (Copilot tree only)

Published Copilot / VS Code Agent Skills rules:

- `name` **must match** the directory (`phasify/` → `name: phasify`).
  Invalid names fail silently on Copilot.
- `description` **≤ 1024 characters**.
- Add `argument-hint` (e.g. `[<prompt>]`, `[<selector>]`).
- Keep `user-invocable: true`.
- Use `disable-model-invocation: true` on mutating verbs (`runnify`,
  `phasify`, `addify`) so they stay slash-invoked.

Measured Cursor YAML descriptions (do **not** shrink Cursor/Grok):

| Skill | Cursor `description` chars | Copilot action |
|-------|----------------------------|----------------|
| promptify | 970 | Fits; keep or lightly adapt |
| runnify | 717 | Fits |
| askify | 829 | Fits |
| plannify | **1153** | **Must trim** in `.copilot/skills` only |
| phasify | **4343** | **Must trim** in `.copilot/skills` only |
| debugify | 730 | Fits; rewrite to Grok-loop wording |
| addify | 804 | Fits |
| ify | 1009 | Fits (leave headroom if adapted) |

## I5 — Personal install dest (all local projects)

Once per user/machine. Covers every **local** repo in VS Code, Visual
Studio, and Copilot CLI. Not every GitHub remote.

| OS | Destination |
|----|-------------|
| Linux | `~/.copilot/skills/<name>/` (`$HOME/.copilot/skills`) |
| Windows | `%USERPROFILE%\.copilot\skills\<name>\` |

Remote sshub (Linux remotes): `$HOME/.copilot/skills`.
Document Windows remotes as `%USERPROFILE%\.copilot\skills`.

Installer commands (P3; same on `cli.sh` and `cli.ps1`):

```text
./scripts/cli.sh install copilot
./scripts/cli.sh install copilot --dry-run
./scripts/cli.sh install copilot --host
./scripts/cli.sh install copilot --no-host
./scripts/cli.sh pullinst copilot
.\scripts\cli.ps1 install copilot
```

Local `install` / `install all` / `install copilot` checks the GitHub
Copilot product, then copies skills. If the product is missing and
installable, the installer asks (TTY) or honors `--host` / `--no-host`.

## I6 — Project / cloud dest (per repo)

Copilot **cloud agent** and **code review on github.com** only see
skills in the repo they open:

```text
<consumer-repo>/.github/skills/<name>/
```

Personal `~/.copilot/skills` is **not** uploaded to those jobs.

Implemented (P4): `./scripts/cli.sh project <repo>` /
`.\scripts\cli.ps1 project <repo>` copies `.copilot/skills` →
`<repo>/.github/skills`. Refuses to write that dest inside sva-skills.
How-to (including `gh skill` and `/skills reload`): `docs/COPILOT_LOAD.md`.

## I7 — `install all` is grok + cursor + copilot

`install` / `install all` / a missing target = grok + cursor + copilot
(`scripts/cli.sh` / `scripts/cli.ps1`). Explicit `install grok`,
`install cursor`, and `install copilot` still install one dest.

`project` is unchanged: consumer `.github/skills` only, not part of
`install`.

## I8 — Isolation

Do **not** edit `.cursor/skills/` or `.grok/` skill bodies for Copilot
quirks. Allowed outside the Copilot tree:

- `scripts/cli.sh` / `scripts/cli.ps1` (add the `copilot` target)
- `README.md` / ify Related (P5)

## I9 — Copilot-only skill adaptations (P2)

Copy Cursor (debugify: Grok). Then change only:

1. **Follow-paths** — `~/.copilot/skills/promptify/SKILL.md` and this
   repo `.copilot/skills/…`. Never `~/.cursor` / `~/.grok`.
2. **Frontmatter** — I4.
3. **Tools** — Copilot/VS Code chat confirm. Do **not** name
   `AskQuestion`, `ask_user_question`, or other Cursor-only tools.
4. **debugify** — I3.
5. **ify / SMART** — this tree is Copilot. Not-ify list without Grok
   `/image` `/imagine` unless those skills exist here.
6. **Scratch** — keep `scripts/cli.sh scratch ls N` / `cli.ps1`
   (already Linux + Windows).

## I10 — Copilot Enterprise

Skills still load from I5 and/or I6. There is no extra org-wide skill
store in what was verified.

Org-wide means:

1. Each developer: personal install (I5), and/or
2. Template / copy `.github/skills` into repos the cloud agent opens (I6)

Documented extra path (P4):

```text
gh skill install <org>/sva-skills --agent github-copilot --scope user --allow-hidden-dirs
```

Requires `gh` ≥ 2.90.0. Also `--from-local` / project-scope copy into
`.github/skills`. After copy: Copilot CLI `/skills reload`.
Linux + Windows commands: `docs/COPILOT_LOAD.md`.

**Not skills:** Enterprise **custom agents**
(`.github-private` `/agents`). Do not implement those in this plan.

## I11 — Installer lockstep

`cli.sh` (Linux) and `cli.ps1` (Windows) stay in lockstep for the
`copilot` target, dests, `--dry-run`, `--force`, `pullinst`, `status`,
and remote relative dest `.copilot/skills`.

Today dests (do not change these when adding copilot):

| Tree | Source | Local dest |
|------|--------|------------|
| grok | `.grok/` | `~/.grok/skills` |
| cursor | `.cursor/skills/` | `~/.cursor/skills` |
| copilot (new) | `.copilot/skills/` | `~/.copilot/skills` |

## I12 — Invocation

- Chat: `/<name>` (VS Code Agent Skills / Copilot)
- Copilot CLI: `/skills reload` or `copilot skill add`

---

## Out of scope (whole plan)

- Rewriting Cursor or Grok SKILL bodies for Copilot
- Replacing skills with Copilot custom instructions
- Implementing Enterprise custom **agents** instead of skills

## Phase map (do not execute here)

| Phase | Work |
|-------|------|
| P1 — Scaffold | `.copilot/skills/` layout + Copilot create-skill notes; `name` matches folder |
| P2 — Family port | Port the I2 eight; apply I9 |
| P3 — Installer | I5 + I7 + I11 |
| P4 — Enterprise load | I6 + I10 |
| P5 — Docs | README Copilot section, collision table row, ify Related |
| P6 — Verify | `/promptify` on Linux and Windows; cloud via `.github/skills` if available |
