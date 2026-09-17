# Copilot / Enterprise load (P4)

How to put Promptify-family Copilot skills where GitHub Copilot and
Copilot Enterprise actually read them. Destinations are frozen in
`docs/COPILOT_SKILLS.md` (I5, I6, I10). Do not invent other paths.

Author skills in this repo under `.copilot/skills/<name>/`. That is the
source. `.github/skills` is a **consumer-repo** dest only — not authored
inside sva-skills.

---

## Where skills load

| Scope | Linux | Windows | Who sees it |
|-------|-------|---------|-------------|
| Personal (I5) | `~/.copilot/skills/<name>/` | `%USERPROFILE%\.copilot\skills\<name>\` | Local VS Code, Visual Studio, Copilot CLI on that machine. Every local repo. |
| Project / cloud (I6) | `<repo>/.github/skills/<name>/` | `<repo>\.github\skills\<name>\` | Copilot **cloud agent** and **code review** on github.com for **that** repo only. |

Personal `~/.copilot/skills` is **not** uploaded to cloud jobs. Cloud
only sees skills committed (or otherwise present) in the repo it opens.

There is **no org-wide skill store**. Copilot Enterprise still uses I5
and/or I6:

1. Each developer: personal install (I5), and/or
2. Template / copy `.github/skills` into every repo the cloud agent opens (I6)

**Not skills:** Enterprise custom agents (`.github-private` `/agents`).
Those are out of scope.

---

## 1. Personal install (all local projects)

Once per user/machine. Covers every **local** repo.

### Linux (this installer)

```bash
./scripts/cli.sh install copilot
./scripts/cli.sh install copilot --dry-run
./scripts/cli.sh pullinst copilot
```

Dest: `$HOME/.copilot/skills`.

### Windows (this installer)

```powershell
.\scripts\cli.ps1 install copilot
.\scripts\cli.ps1 install copilot --dry-run
.\scripts\cli.ps1 pullinst copilot
```

Dest: `%USERPROFILE%\.copilot\skills`.

`install` / `install all` installs grok + cursor + copilot. Use
`install copilot` for the Copilot dest only.

When the **copilot** skill target is selected (including `install` /
`install all`), the installer also checks for the **GitHub Copilot
product** (VS Code `GitHub.copilot` and/or the `copilot` CLI):

- Already installed → copy skills.
- Missing and installable (`code` on PATH, and/or Node 22+ `npm`) →
  ask on a TTY. `--host` installs without asking. `--no-host` skips
  the product. Non-interactive runs skip the product and print how
  to pass `--host`.
- Skills are still copied to `~/.copilot/skills` if you skip the
  product.

### Linux or Windows — `gh skill` (user scope)

Requires GitHub CLI `gh` ≥ 2.90.0 (`gh skill install`). Source lives in
a hidden tree (`.copilot/skills`), so pass `--allow-hidden-dirs`.
`--agent github-copilot` and `--scope user` write the personal dest.

From a published repo (replace `<org>`):

```text
gh skill install <org>/sva-skills --agent github-copilot --scope user --allow-hidden-dirs --all
```

From a local checkout (`--from-local`):

```bash
# Linux
gh skill install /path/to/sva-skills --from-local --agent github-copilot --scope user --allow-hidden-dirs --all
```

```powershell
# Windows
gh skill install C:\path\to\sva-skills --from-local --agent github-copilot --scope user --allow-hidden-dirs --all
```

`gh skill install` copies files (does not symlink) and injects source
tracking into frontmatter. Prefer `./scripts/cli.sh install copilot`
when you want a clean copy of this tree without that metadata.

---

## 2. Project / cloud copy (per consumer repo)

Copilot cloud / github.com code review only see skills in the repo they
open. Copy this tree into **that** repo’s `.github/skills`.

### This installer (frozen I6 dest)

Always copies `.copilot/skills` → `<consumer-repo>/.github/skills`.
Refuses to write `.github/skills` inside sva-skills itself.

```bash
# Linux — consumer path required when cwd is sva-skills
./scripts/cli.sh project /path/to/consumer-repo
./scripts/cli.sh project --dry-run /path/to/consumer-repo
```

```powershell
# Windows
.\scripts\cli.ps1 project C:\path\to\consumer-repo
.\scripts\cli.ps1 project --dry-run C:\path\to\consumer-repo
```

Path omitted → current working directory (must not be sva-skills).
`--force` reinstalls regardless of mtimes. `--remote` is rejected
(project is local I6 only).

Commit the copied `.github/skills` in the **consumer** repo so the
cloud agent can see them.

### `gh skill` (project scope)

Default `gh skill install` scope is `project` (current git repo).
`--allow-hidden-dirs` is still required to discover `.copilot/skills`.

```bash
# Linux — run from the consumer repo
cd /path/to/consumer-repo
gh skill install /path/to/sva-skills --from-local --agent github-copilot --scope project --allow-hidden-dirs --all
```

```powershell
# Windows — run from the consumer repo
cd C:\path\to\consumer-repo
gh skill install C:\path\to\sva-skills --from-local --agent github-copilot --scope project --allow-hidden-dirs --all
```

Published-repo form (from the consumer checkout):

```text
gh skill install <org>/sva-skills --agent github-copilot --scope project --allow-hidden-dirs --all
```

Note: `gh skill install --scope project` for GitHub Copilot may land in
`.agents/skills` (shared project dest for several hosts). This plan’s
frozen cloud dest is **`.github/skills`**. Use `./scripts/cli.sh project`
(or `cli.ps1 project`) when you need that exact path.

---

## 3. Reload after copy

After a personal or project copy, make Copilot pick the skills up.

### Copilot CLI (Linux and Windows)

Inside an interactive session:

```text
/skills reload
/skills info promptify
```

From a terminal (no session):

```text
copilot skill list
copilot skill add
```

`/skills reload` avoids restarting the CLI after adding a skill in the
same session.

### VS Code / Visual Studio

Open (or reload) the workspace. Project skills come from that repo’s
`.github/skills`. Personal skills come from `~/.copilot/skills` /
`%USERPROFILE%\.copilot\skills`. Chat: `/<name>` (for example
`/promptify`).

---

## Enterprise checklist

| Goal | Linux | Windows |
|------|-------|---------|
| All local repos on this machine | `./scripts/cli.sh install copilot` then `/skills reload` | `.\scripts\cli.ps1 install copilot` then `/skills reload` |
| Same via `gh` (user) | `gh skill install … --scope user --allow-hidden-dirs --all` | same `gh` command |
| Cloud / github.com for one repo | `./scripts/cli.sh project /path/to/repo` and commit `.github/skills` | `.\scripts\cli.ps1 project C:\path\to\repo` and commit |
| Org-wide | Repeat I5 per developer and/or copy I6 into each template/repo | same |
| Custom agents | Do not use this plan | Do not use this plan |
