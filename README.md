# sva-skills

Pre-written SVA skills for Cursor agents, Grok agents, etc.

## Install

From this repo:

```bash
./cli install          # install/update grok + cursor skills when repo is newer
./cli install grok     # ~/.grok/skills/
./cli install cursor   # ~/.cursor/skills/
./cli install all      # same as ./cli install
./cli status           # show what would install vs skip
./cli install --dry-run
./cli install --force  # overwrite even if dest is newer
```

### Remote (sshub connections)

Uses the same connection file as `sshub` / `sshot`:

`~/.local/share/sshub/connections.env` (override with `SSHUB_ENV_FILE`).

```bash
./cli list                              # list connections (name + alias)
./cli install --remote                  # all skills → every connection
./cli install grok --remote casai       # name or alias (e.g. casai → CASSADYAIFAP)
./cli install --remote casai CAS2SYS
./cli install --local --remote          # this machine + all remotes
./cli status --remote casai
./cli install --remote --dry-run
```

Remote skills land in the **remote user's** home:

| Source | Destination |
|--------|-------------|
| `.grok/<skill>/` | `~/.grok/skills/<skill>/` (local or remote `$HOME`) |
| `.cursor/skills/<skill>/` | `~/.cursor/skills/<skill>/` |

A skill is copied when the destination is missing (first install) or when any file in the repo skill is newer than the newest file already installed. Unchanged or newer-on-disk skills are skipped unless you pass `--force`.
