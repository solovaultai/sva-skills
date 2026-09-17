# Create a Copilot skill (notes — not a slash skill)

How to scaffold a new skill in **this** tree. This is not Grok
`/create-skill` and is not installed as a Copilot skill. Frozen dests
and frontmatter live in `docs/COPILOT_SKILLS.md` (I1, I4, I5, I6).

## Name

- Directory and `name:` must be **identical** (`phasify/` → `name: phasify`).
  Copilot fails **silently** on a mismatch.
- Lowercase `a-z`, digits `0-9`, hyphens only. Start and end with a
  letter or digit. Length 2–64.

## Where to write it (sva-skills)

Always author here:

```text
.copilot/skills/<name>/SKILL.md
```

Optional: `.copilot/skills/<name>/references/`, `scripts/`.

Do **not** add a new skill as `.github/skills/` inside this repo
(that is a consumer dest). Copy into a consumer with
`./scripts/cli.sh project /path/to/repo` (see `docs/COPILOT_LOAD.md`).
Do **not** put notes or extra folders under `.copilot/skills/` unless
they are real skills (installer `skill_dirs` picks every non-dot child
that has files).

## After install (P3) — where it loads

| Scope | Path |
|-------|------|
| Personal (Linux) | `~/.copilot/skills/<name>/SKILL.md` |
| Personal (Windows) | `%USERPROFILE%\.copilot\skills\<name>\SKILL.md` |
| Project / cloud | `<consumer-repo>/.github/skills/<name>/` |

Invoke with `/<name>`. After a personal or project copy: Copilot CLI
`/skills reload` or `copilot skill add`. Full load steps (Linux +
Windows, `gh skill install`, Enterprise): `docs/COPILOT_LOAD.md`.

```bash
./scripts/cli.sh project /path/to/consumer-repo
# Windows: .\scripts\cli.ps1 project C:\path\to\consumer-repo
```

## Frontmatter

```yaml
---
name: <name>
description: >-
  ≤1024 characters. What it does, /<name>, and trigger phrases.
argument-hint: "[<prompt>]"
user-invocable: true
# Mutating verbs (runnify, phasify, addify): also set
# disable-model-invocation: true
---
```

`description` max **1024**. Do not copy Cursor `phasify` / `plannify`
YAML as-is (those exceed the cap).

## Steps

1. Confirm `<name>` is unique in `.copilot/skills/` and matches I2
   unless this is a later add.
2. `mkdir -p .copilot/skills/<name>`
3. Write `SKILL.md` with `name:` equal to the folder.
4. Point follow-paths at `~/.copilot/skills/…` and
   `.copilot/skills/…` — never `~/.cursor` or `~/.grok`.
5. Do not name Cursor-only tools (`AskQuestion`, `ask_user_question`).
6. Count `description` characters; trim if over 1024.
7. After P3: `./scripts/cli.sh install copilot` (or `cli.ps1`).

## Family already reserved (I2)

`promptify` `runnify` `askify` `plannify` `phasify` `debugify`
`addify` `ify` — do not invent a second folder for these.
