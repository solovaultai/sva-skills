#!/usr/bin/env bash
# sva-skills installer — sync repo skills into ~/.grok, ~/.cursor,
# and ~/.copilot (local and/or across sshub connections from connections.env)
#
# Usage:
#   ./scripts/cli.sh install              # same as: install all (local) + tmux titles
#   ./scripts/cli.sh install all
#   ./scripts/cli.sh install grok
#   ./scripts/cli.sh install cursor
#   ./scripts/cli.sh install copilot
#   ./scripts/cli.sh install tmux         # only the ~/.tmux.conf title lines
#   ./scripts/cli.sh tmux                 # same as: install tmux
#   ./scripts/cli.sh install copilot --host
#   ./scripts/cli.sh install copilot --no-host
#   ./scripts/cli.sh project /path/to/consumer-repo   # .copilot/skills → <repo>/.github/skills
#   ./scripts/cli.sh pullinst             # git pull origin main, then install
#   ./scripts/cli.sh pullinst grok
#   ./scripts/cli.sh pullinst cursor
#   ./scripts/cli.sh pullinst copilot
#   ./scripts/cli.sh install --remote                 # all skills → all connections
#   ./scripts/cli.sh install grok --remote casai      # grok skills → one host (name or alias)
#   ./scripts/cli.sh install --remote casai cas2      # all skills → listed hosts
#   ./scripts/cli.sh install --local --remote         # local + all remotes
#   ./scripts/cli.sh status [--remote [conn...]]
#   ./scripts/cli.sh list                             # list sshub connections
#   ./scripts/cli.sh scratch show|set|search|detect|ls
#
# Options:
#   --force       Always install, even if dest is newer
#   --dry-run     Print actions only; do not write
#   --host        Install GitHub Copilot (VS Code + CLI when possible) without asking
#   --no-host     Do not install the GitHub Copilot product
#   --remote, -r  Install to remote host(s) from connections.env
#   --local       Also install locally when using --remote
#   --list, -l    List sshub connections and exit
#   -h, --help    Show help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GROK_SRC="${ROOT}/.grok"
CURSOR_SRC="${ROOT}/.cursor/skills"
COPILOT_SRC="${ROOT}/.copilot/skills"
GROK_DEST="${HOME}/.grok/skills"
CURSOR_DEST="${HOME}/.cursor/skills"
COPILOT_DEST="${HOME}/.copilot/skills"

# Remote destinations are always under the remote user's home.
REMOTE_GROK_REL=".grok/skills"
REMOTE_CURSOR_REL=".cursor/skills"
REMOTE_COPILOT_REL=".copilot/skills"
# Consumer-repo cloud dest (I6). Not a source tree; not written inside this repo.
PROJECT_REL=".github/skills"

SSHUB_BIN="${SSHUB_BIN:-$HOME/.local/bin/sshub}"
SSHUB_DATA_DIR="${SSHUB_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/sshub}"
ENV_FILE="${SSHUB_ENV_FILE:-$SSHUB_DATA_DIR/connections.env}"

FORCE=0
DRY_RUN=0
DO_REMOTE=0
# ask = prompt on a TTY when GitHub Copilot (the product) is missing
# yes  = --host (install product without asking)
# no   = --no-host (skip product)
HOST_ACTION=ask
DO_LOCAL=1 # default local; flipped off when --remote is used without --local
LOCAL_EXPLICIT=0
DO_TMUX=0
TMUX_EXPLICIT=0
SSHUB_LOADED=0
SCP_FLAGS=() # used by sshub scp_connection when sourced

# Positional / free-form after options
ARGS=()
# Connection tokens collected after --remote (empty = all connections)
REMOTE_CONNS=()

usage() {
  cat <<'EOF'
sva-skills installer — sync repo skills into ~/.grok, ~/.cursor, and ~/.copilot

Usage:
  ./scripts/cli.sh install              # same as: install all (local) + tmux titles
  ./scripts/cli.sh install all
  ./scripts/cli.sh install grok
  ./scripts/cli.sh install cursor
  ./scripts/cli.sh install copilot
  ./scripts/cli.sh install tmux         # only the ~/.tmux.conf title lines
  ./scripts/cli.sh tmux                 # same as: install tmux
  ./scripts/cli.sh install copilot --host
  ./scripts/cli.sh install copilot --no-host
  ./scripts/cli.sh project /path/to/repo # .copilot/skills → <repo>/.github/skills
  ./scripts/cli.sh project --dry-run /path/to/repo
  ./scripts/cli.sh pullinst              # git pull origin main, then install
  ./scripts/cli.sh pullinst grok
  ./scripts/cli.sh pullinst cursor
  ./scripts/cli.sh pullinst copilot
  ./scripts/cli.sh install --remote                 # all skills → all connections
  ./scripts/cli.sh install grok --remote casai      # name or alias from connections.env
  ./scripts/cli.sh install --remote casai CAS2SYS
  ./scripts/cli.sh install --local --remote         # local + every connection
  ./scripts/cli.sh status
  ./scripts/cli.sh status --remote [conn...]
  ./scripts/cli.sh list                             # list sshub connections
  ./scripts/cli.sh scratch show                     # screenshot folder for ify Nimages / Grok /image
  ./scripts/cli.sh scratch ls [N]                   # last-N image paths (default 5)

Options:
  --force       Always install, even if dest is newer
  --dry-run     Print actions only; do not write
  --host        Install GitHub Copilot (VS Code + CLI when possible) without asking
  --no-host     Do not install the GitHub Copilot product
  --remote, -r  Install to remote host(s); with no names, use all connections
  --local       Also install on this machine when using --remote
  --list, -l    List sshub connections and exit
  -h, --help    Show help

Targets:
  grok     .grok/<skill>/           →  ~/.grok/skills/<skill>/
  cursor   .cursor/skills/<skill>/  →  ~/.cursor/skills/<skill>/
  copilot  .copilot/skills/<skill>/ →  ~/.copilot/skills/<skill>/
  all      grok + cursor + copilot, and the tmux title lines
  tmux     only ~/.tmux.conf title lines (also: ./scripts/cli.sh tmux)

General install (no target, or all, or pullinst) ensures these lines in
~/.tmux.conf, locally and on each --remote host. Repeating install does
not duplicate them. If a tmux server is running and the live options
differ, it reloads the file. It does not kill the server.

  set -g set-titles on
  set -g set-titles-string "#{window_name}"

Project / cloud (copilot only; I6 — not a fourth install target):
  project  .copilot/skills/<skill>/ →  <consumer-repo>/.github/skills/<skill>/
  Refuses to write .github/skills inside this sva-skills repo (source stays
  .copilot/skills). Path omitted → current working directory. See
  docs/COPILOT_LOAD.md for gh skill install and /skills reload.

Connections come from:
  ${XDG_DATA_HOME:-~/.local/share}/sshub/connections.env
(override with SSHUB_ENV_FILE / SSHUB_DATA_DIR). Names and aliases work
the same as sshub / sshot (e.g. casai, CASSADYAIFAP).

A skill is installed when the destination is missing, or when any file under
the repo skill is newer than the newest file under the installed skill.
With --force, every skill is reinstalled regardless of mtimes.

Scratch source (ify Nimages and Grok /image last-N images):
  ./scripts/cli.sh scratch show                     # current source; unset is OK (skills use workspace scratch/)
  ./scripts/cli.sh scratch set <path>
  ./scripts/cli.sh scratch set --remote <conn> <dir>
  ./scripts/cli.sh scratch search [--remote <conn>]
  ./scripts/cli.sh scratch detect [--force]
  ./scripts/cli.sh scratch ls [N]
Config: ${XDG_DATA_HOME:-~/.local/share}/sva-skills/scratch.env
Install detects the screenshot folder and writes that file if unset.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

# Always run against this repo (ROOT), not the caller's cwd.
pull_origin_main() {
  echo "git pull origin main  (${ROOT})"
  git -C "$ROOT" pull origin main || die "git pull origin main failed; install skipped"
}

# ── sshub integration (mirrors sshot) ─────────────────────────

# Load sshub helpers without running its CLI dispatcher.
load_sshub() {
  if [[ "$SSHUB_LOADED" -eq 1 ]]; then
    return 0
  fi
  if [[ ! -f "$SSHUB_BIN" ]]; then
    die "sshub not found at $SSHUB_BIN"
  fi
  # shellcheck source=/dev/null
  set +u
  # shellcheck disable=SC1090
  source "$SSHUB_BIN"
  set -u
  if [[ ! -f "$ENV_FILE" ]]; then
    die "connections file not found: $ENV_FILE"
  fi
  SSHUB_LOADED=1
}

# Run an sshub function with nounset disabled (its internals touch optional vars).
sshub_call() {
  set +u
  "$@"
  local rc=$?
  set -u
  return "$rc"
}

list_conns() {
  load_sshub
  if declare -f list_connections >/dev/null 2>&1; then
    sshub_call list_connections
    return
  fi
  echo "Connections in $ENV_FILE:"
  local n
  for n in $(sshub_call discover_connections); do
    local alias_var="${n}_ALIAS" host_var="${n}_HOST" folder_var="${n}_FOLDER"
    local alias="${!alias_var:-}" host="${!host_var:-}" folder="${!folder_var:-}"
    if [[ -n "$alias" ]]; then
      printf "  %-16s  alias=%-10s  %s" "$n" "$alias" "$host"
    else
      printf "  %-16s  %s" "$n" "$host"
    fi
    [[ -n "$folder" ]] && printf "  (folder: %s)" "$folder"
    printf "\n"
  done
}

# Expand connection tokens (names/aliases) into RESOLVED connection names.
# No tokens → all connections from connections.env.
resolve_remote_list() {
  load_sshub
  REMOTE_NAMES=()
  if [[ "${#REMOTE_CONNS[@]}" -eq 0 ]]; then
    mapfile -t REMOTE_NAMES < <(sshub_call discover_connections)
    [[ "${#REMOTE_NAMES[@]}" -gt 0 ]] || die "no connections defined in $ENV_FILE"
    return 0
  fi
  local token
  for token in "${REMOTE_CONNS[@]}"; do
    # Allow comma-separated batches: casai,cas2
    local part rest="$token"
    while [[ -n "$rest" ]]; do
      if [[ "$rest" == *","* ]]; then
        part="${rest%%,*}"
        rest="${rest#*,}"
      else
        part="$rest"
        rest=""
      fi
      part="${part#"${part%%[![:space:]]*}"}"
      part="${part%"${part##*[![:space:]]}"}"
      [[ -n "$part" ]] || continue
      sshub_call resolve_conn "$part" || die "unknown connection: $part"
      REMOTE_NAMES+=("$RESOLVED_NAME")
    done
  done
  [[ "${#REMOTE_NAMES[@]}" -gt 0 ]] || die "no remote connections selected"
}

# SSH to currently-resolved connection (after resolve_conn).
remote_ssh() {
  local -a key_args=()
  [[ -n "${RESOLVED_KEY:-}" ]] && key_args=(-i "$RESOLVED_KEY")
  set +u
  ssh -o BatchMode=yes \
    -o StrictHostKeyChecking=accept-new \
    -o ConnectTimeout=8 \
    -o ConnectionAttempts=1 \
    -p "${RESOLVED_PORT:-22}" \
    "${key_args[@]}" \
    "${RESOLVED_USER}@${RESOLVED_HOST}" \
    "$@"
  local rc=$?
  set -u
  return "$rc"
}

# ── mtime / skill helpers ─────────────────────────────────────

# Newest mtime (epoch seconds) among regular files under a directory.
# Prints 0 if path missing or has no files.
newest_mtime() {
  local dir="$1"
  if [[ ! -d "$dir" ]]; then
    echo 0
    return
  fi
  local ts
  ts="$(find "$dir" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1 || true)"
  if [[ -z "${ts:-}" ]]; then
    echo 0
    return
  fi
  printf '%s\n' "${ts%%.*}"
}

# Query newest mtimes for many skills under $HOME/<rel_parent> in one SSH.
# Fills associative array REMOTE_MTIME[skill]=epoch (0 if missing).
# Returns non-zero if SSH itself fails.
remote_skill_mtimes() {
  local rel_parent="$1"
  shift
  unset REMOTE_MTIME 2>/dev/null || true
  declare -gA REMOTE_MTIME

  local names=("$@")
  if [[ "${#names[@]}" -eq 0 ]]; then
    return 0
  fi

  local names_q="" n
  for n in "${names[@]}"; do
    names_q+=" $(printf '%q' "$n")"
  done

  local out
  if ! out="$(remote_ssh "bash -s" <<EOF
set +e
parent="\$HOME/$(printf '%q' "$rel_parent")"
for name in${names_q}; do
  d="\$parent/\$name"
  if [ ! -d "\$d" ]; then
    printf '%s 0\n' "\$name"
    continue
  fi
  ts=\$(find "\$d" -type f -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
  if [ -z "\${ts:-}" ]; then
    printf '%s 0\n' "\$name"
  else
    printf '%s %s\n' "\$name" "\${ts%%.*}"
  fi
done
EOF
)"; then
    return 1
  fi

  local line skill ts
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    skill="${line%% *}"
    ts="${line#* }"
    [[ "$ts" =~ ^[0-9]+$ ]] || ts=0
    REMOTE_MTIME["$skill"]="$ts"
  done <<<"$out"

  # Ensure every requested skill has an entry (default 0 on parse miss).
  for n in "${names[@]}"; do
    [[ -n "${REMOTE_MTIME[$n]+x}" ]] || REMOTE_MTIME["$n"]=0
  done
  return 0
}

skill_dirs() {
  local src="$1"
  [[ -d "$src" ]] || return 0
  local d
  for d in "$src"/*/; do
    [[ -d "$d" ]] || continue
    local base
    base="$(basename "$d")"
    [[ "$base" != .* ]] || continue
    if [[ -f "${d}SKILL.md" ]] || [[ -n "$(find "$d" -type f -print -quit 2>/dev/null)" ]]; then
      printf '%s\n' "$base"
    fi
  done | sort
}

# src_ts / dest_ts comparison (0 = dest missing/empty)
should_install_ts() {
  local src_ts="$1"
  local dest_ts="$2"
  if [[ "$FORCE" -eq 1 ]]; then
    return 0
  fi
  if [[ "$dest_ts" -eq 0 ]]; then
    return 0
  fi
  if [[ "$src_ts" -gt "$dest_ts" ]]; then
    return 0
  fi
  return 1
}

reason_for_ts() {
  local src_ts="$1"
  local dest_ts="$2"
  if [[ "$FORCE" -eq 1 ]]; then
    echo "forced"
    return
  fi
  if [[ "$dest_ts" -eq 0 ]]; then
    echo "new"
    return
  fi
  if [[ "$src_ts" -gt "$dest_ts" ]]; then
    echo "newer"
    return
  fi
  if [[ "$src_ts" -eq "$dest_ts" ]]; then
    echo "same age"
    return
  fi
  echo "dest newer"
}

should_install() {
  local src="$1"
  local dest="$2"
  should_install_ts "$(newest_mtime "$src")" "$(newest_mtime "$dest")"
}

reason_for() {
  local src="$1"
  local dest="$2"
  reason_for_ts "$(newest_mtime "$src")" "$(newest_mtime "$dest")"
}

# ── local install ─────────────────────────────────────────────

install_skill_local() {
  local name="$1"
  local src="$2"
  local dest_parent="$3"
  local dest="${dest_parent}/${name}"

  if ! should_install "$src" "$dest"; then
    echo "  skip  ${name}  ($(reason_for "$src" "$dest"))"
    return 0
  fi

  local why
  why="$(reason_for "$src" "$dest")"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  would install  ${name}  (${why})  →  ${dest}"
    return 0
  fi

  mkdir -p "$dest_parent"
  local staging
  staging="$(mktemp -d "${dest_parent}/.sva-skills-staging.${name}.XXXXXX")"
  if ! cp -a "$src"/. "$staging"/; then
    rm -rf "$staging"
    die "copy failed for skill: ${name}"
  fi
  rm -rf "$dest"
  mv "$staging" "$dest"
  echo "  install  ${name}  (${why})  →  ${dest}"
}

install_target_local() {
  local target="$1"
  local src dest label
  case "$target" in
    grok)
      src="$GROK_SRC"
      dest="$GROK_DEST"
      label="grok"
      ;;
    cursor)
      src="$CURSOR_SRC"
      dest="$CURSOR_DEST"
      label="cursor"
      ;;
    copilot)
      src="$COPILOT_SRC"
      dest="$COPILOT_DEST"
      label="copilot"
      ;;
    *)
      die "unknown target: $target (use grok, cursor, copilot, or all)"
      ;;
  esac

  if [[ ! -d "$src" ]]; then
    die "source not found: $src"
  fi

  local skills
  mapfile -t skills < <(skill_dirs "$src")
  if [[ "${#skills[@]}" -eq 0 ]]; then
    echo "${label}: no skills under ${src}"
    return 0
  fi

  echo "local ${label}: ${src}  →  ${dest}"
  local name
  for name in "${skills[@]}"; do
    install_skill_local "$name" "${src}/${name}" "$dest"
  done
}

# ── GitHub Copilot product (VS Code + CLI) ─────────────────────
# Skills go to ~/.copilot/skills. The product is optional and asked
# for when missing and installable (local install only).

find_code_bin() {
  if command -v code >/dev/null 2>&1; then
    command -v code
    return 0
  fi
  if command -v code-insiders >/dev/null 2>&1; then
    command -v code-insiders
    return 0
  fi
  return 1
}

copilot_cli_present() {
  command -v copilot >/dev/null 2>&1
}

# VS Code 1.138+ ships GitHub Copilot Chat as a built-in
# (resources/app/extensions/copilot). --list-extensions does not show it.
vscode_app_root() {
  local bin rel dir
  bin="$(find_code_bin)" || true
  if [[ -n "$bin" ]]; then
    rel="$(readlink -f "$bin" 2>/dev/null || printf '%s' "$bin")"
    dir="$(dirname "$rel")"
    if [[ "$(basename "$dir")" == "bin" ]]; then
      printf '%s\n' "$(dirname "$dir")"
      return 0
    fi
  fi
  local p
  for p in /usr/share/code /snap/code/current/usr/share/code; do
    if [[ -f "${p}/resources/app/extensions/copilot/package.json" ]]; then
      printf '%s\n' "$p"
      return 0
    fi
  done
  return 1
}

copilot_vscode_builtin() {
  local root
  root="$(vscode_app_root)" || return 1
  [[ -f "${root}/resources/app/extensions/copilot/package.json" ]]
}

copilot_vscode_user_ext() {
  local bin
  bin="$(find_code_bin)" || return 1
  "$bin" --list-extensions 2>/dev/null | grep -qiFx 'GitHub.copilot'
}

copilot_vscode_present() {
  copilot_vscode_user_ext || copilot_vscode_builtin
}

copilot_host_present() {
  copilot_vscode_present || copilot_cli_present
}

copilot_vscode_installable() {
  find_code_bin >/dev/null
}

copilot_cli_installable() {
  command -v npm >/dev/null 2>&1 || return 1
  command -v node >/dev/null 2>&1 || return 1
  local major
  major="$(node -p "process.versions.node.split('.')[0]" 2>/dev/null || echo 0)"
  [[ "$major" -ge 22 ]]
}

copilot_host_installable() {
  copilot_vscode_installable || copilot_cli_installable
}

install_copilot_vscode() {
  local bin force_flag=()
  bin="$(find_code_bin)" || return 1
  if copilot_vscode_builtin; then
    echo "  skip  GitHub.copilot  (built into this VS Code; Chat cannot be marketplace-downgraded)"
    return 0
  fi
  if [[ "$FORCE" -eq 0 ]] && copilot_vscode_user_ext; then
    echo "  skip  GitHub.copilot  (already installed)"
    return 0
  fi
  if [[ "$FORCE" -eq 1 ]]; then
    force_flag=(--force)
  fi
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  would install  GitHub.copilot  via ${bin}"
    return 0
  fi
  local err
  err="$("$bin" --install-extension GitHub.copilot "${force_flag[@]+"${force_flag[@]}"}" 2>&1)" || true
  printf '%s\n' "$err"
  if copilot_vscode_present; then
    echo "  install  GitHub.copilot"
    return 0
  fi
  if printf '%s\n' "$err" | grep -qi 'cannot be downgraded\|is a built-in extension'; then
    echo "  skip  GitHub.copilot-chat  (built into this VS Code)"
    if copilot_vscode_present; then
      return 0
    fi
    echo "  note: VS Code already has Copilot Chat built in; marketplace GitHub.copilot was not added"
    return 0
  fi
  echo "  error: failed to install GitHub.copilot" >&2
  return 1
}

install_copilot_cli() {
  if copilot_cli_present; then
    echo "  skip  copilot CLI  (already on PATH)"
    return 0
  fi
  copilot_cli_installable || return 1
  local prefix="${HOME}/.local"
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  would install  @github/copilot  →  ${prefix}"
    return 0
  fi
  mkdir -p "${prefix}/bin"
  if npm install -g --prefix "$prefix" @github/copilot; then
    echo "  install  copilot CLI  →  ${prefix}/bin/copilot"
    if ! command -v copilot >/dev/null 2>&1; then
      echo "  note: add ${prefix}/bin to PATH if 'copilot' is not found"
    fi
    return 0
  fi
  echo "  error: npm install -g --prefix ${prefix} @github/copilot failed" >&2
  return 1
}

ask_install_copilot_host() {
  if [[ "$HOST_ACTION" == "yes" ]]; then
    return 0
  fi
  if [[ "$HOST_ACTION" == "no" ]]; then
    return 1
  fi
  if [[ ! -t 0 ]]; then
    echo "host: GitHub Copilot is installable but not installed."
    echo "  re-run with --host to install it, or --no-host to skip asking."
    return 1
  fi
  local reply
  if copilot_vscode_present && ! copilot_cli_present; then
    printf 'VS Code already has GitHub Copilot built in. Install Copilot CLI too? [y/N] '
  else
    printf 'GitHub Copilot is not installed. Install the VS Code host (if needed) and Copilot CLI if possible? [y/N] '
  fi
  read -r reply || return 1
  case "${reply}" in
    y | Y | yes | YES) return 0 ;;
    *) return 1 ;;
  esac
}

maybe_install_copilot_host() {
  echo "host: GitHub Copilot (product — VS Code built-in/extension and/or Copilot CLI)"
  if copilot_vscode_present && copilot_cli_present; then
    echo "  already installed (VS Code + CLI)"
    return 0
  fi
  if copilot_vscode_present && ! copilot_cli_installable; then
    echo "  already installed (VS Code)"
    return 0
  fi
  if ! copilot_vscode_present && ! copilot_cli_present && ! copilot_host_installable; then
    echo "  not installed and not installable here (need 'code' and/or Node 22+ npm)"
    return 0
  fi
  if ! ask_install_copilot_host; then
    echo "  skip  product (skills will still be copied to ${COPILOT_DEST})"
    return 0
  fi
  local ok=0
  if copilot_vscode_installable; then
    install_copilot_vscode && ok=1
  fi
  if ! copilot_cli_present && copilot_cli_installable; then
    install_copilot_cli && ok=1
  fi
  if [[ "$ok" -eq 1 ]]; then
    echo "  next: sign in to GitHub Copilot, then /skills reload (or copilot skill add)"
  fi
  return 0
}

targets_include_copilot() {
  local t
  for t in "${TARGETS[@]}"; do
    if [[ "$t" == "copilot" ]]; then
      return 0
    fi
  done
  return 1
}

# ── project / cloud dest (I6) ─────────────────────────────────
# Copy .copilot/skills into a *consumer* repo's .github/skills.
# Source of truth stays .copilot/skills. This repo is refused.

canonical_dir() {
  (cd "$1" && pwd -P)
}

resolve_project_repo() {
  local raw="${1:-.}"
  if [[ ! -d "$raw" ]]; then
    die "consumer repo not found: $raw"
  fi
  local repo root_p
  repo="$(canonical_dir "$raw")" || die "consumer repo not found: $raw"
  root_p="$(canonical_dir "$ROOT")"
  if [[ "$repo" == "$root_p" ]]; then
    die "refusing to write .github/skills inside sva-skills (source is .copilot/skills). Pass a consumer repo path."
  fi
  printf '%s\n' "$repo"
}

install_project() {
  local raw="${1:-}"
  if [[ -n "${2:-}" ]]; then
    die "project takes at most one repo path (got extra: $2)"
  fi
  if [[ "$DO_REMOTE" -eq 1 ]]; then
    die "project is local consumer-repo only (I6); do not use --remote"
  fi

  if [[ ! -d "$COPILOT_SRC" ]]; then
    die "source not found: $COPILOT_SRC"
  fi

  local repo dest
  repo="$(resolve_project_repo "${raw:-.}")"
  dest="${repo}/${PROJECT_REL}"

  local skills
  mapfile -t skills < <(skill_dirs "$COPILOT_SRC")
  if [[ "${#skills[@]}" -eq 0 ]]; then
    echo "project: no skills under ${COPILOT_SRC}"
    return 0
  fi

  echo "project copilot: ${COPILOT_SRC}  →  ${dest}"
  local name
  for name in "${skills[@]}"; do
    install_skill_local "$name" "${COPILOT_SRC}/${name}" "$dest"
  done
}

status_target_local() {
  local target="$1"
  local src dest label
  case "$target" in
    grok)
      src="$GROK_SRC"
      dest="$GROK_DEST"
      label="grok"
      ;;
    cursor)
      src="$CURSOR_SRC"
      dest="$CURSOR_DEST"
      label="cursor"
      ;;
    copilot)
      src="$COPILOT_SRC"
      dest="$COPILOT_DEST"
      label="copilot"
      ;;
    *)
      die "unknown target: $target (use grok, cursor, copilot, or all)"
      ;;
  esac

  echo "local ${label}: ${src}  →  ${dest}"
  if [[ ! -d "$src" ]]; then
    echo "  (source missing)"
    return 0
  fi

  local name src_skill dest_skill action
  while IFS= read -r name; do
    src_skill="${src}/${name}"
    dest_skill="${dest}/${name}"
    if should_install "$src_skill" "$dest_skill"; then
      action="INSTALL"
    else
      action="skip"
    fi
    printf '  %-8s  %-20s  %s\n' "$action" "$name" "$(reason_for "$src_skill" "$dest_skill")"
  done < <(skill_dirs "$src")
}

# ── remote install ────────────────────────────────────────────

# Upload one skill dir to remote $HOME/<rel_parent>/<name> (stage-then-swap).
# Caller must populate REMOTE_MTIME[name] and resolve_conn first.
install_skill_remote() {
  local name="$1"
  local src="$2"
  local rel_parent="$3" # e.g. .grok/skills
  local conn_label="$4"

  local src_ts dest_ts why
  src_ts="$(newest_mtime "$src")"
  dest_ts="${REMOTE_MTIME[$name]:-0}"
  if ! should_install_ts "$src_ts" "$dest_ts"; then
    echo "  skip  ${name}  ($(reason_for_ts "$src_ts" "$dest_ts"))"
    return 0
  fi
  why="$(reason_for_ts "$src_ts" "$dest_ts")"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "  would install  ${name}  (${why})  →  ${RESOLVED_USER}@${RESOLVED_HOST}:~/${rel_parent}/${name}"
    return 0
  fi

  # Stage under parent as .sva-skills-staging.<name>, then atomic rename.
  local stage_rel="${rel_parent}/.sva-skills-staging.${name}"
  if ! remote_ssh "bash -s" <<EOF
set -e
parent="\$HOME/$(printf '%q' "$rel_parent")"
mkdir -p "\$parent"
rm -rf "\$parent/.sva-skills-staging.$(printf '%q' "$name")"
EOF
  then
    echo "  error  ${name}  (remote stage prep failed on ${conn_label})" >&2
    return 1
  fi

  local -a key_args=()
  [[ -n "${RESOLVED_KEY:-}" ]] && key_args=(-i "$RESOLVED_KEY")
  set +u
  # scp -r <dir> host:stage_rel  → creates stage_rel with dir's contents when
  # stage_rel does not yet exist (OpenSSH).
  # -p preserves mtimes so later "repo newer?" checks stay accurate.
  if ! scp -o BatchMode=yes -o StrictHostKeyChecking=accept-new -q -r -p \
    -o ConnectTimeout=8 \
    -P "${RESOLVED_PORT:-22}" \
    "${key_args[@]}" \
    "$src" \
    "${RESOLVED_USER}@${RESOLVED_HOST}:${stage_rel}"; then
    set -u
    remote_ssh "rm -rf \"\$HOME/$(printf '%q' "$stage_rel")\"" 2>/dev/null || true
    echo "  error  ${name}  (scp failed → ${conn_label})" >&2
    return 1
  fi
  set -u

  if ! remote_ssh "bash -s" <<EOF
set -e
parent="\$HOME/$(printf '%q' "$rel_parent")"
stage="\$parent/.sva-skills-staging.$(printf '%q' "$name")"
dest="\$parent/$(printf '%q' "$name")"
# If scp nested the basename (stage/name/), lift contents up.
if [ -d "\$stage/$(printf '%q' "$name")" ] && [ ! -f "\$stage/SKILL.md" ]; then
  tmp="\$parent/.sva-skills-lift.$(printf '%q' "$name")"
  rm -rf "\$tmp"
  mv "\$stage/$(printf '%q' "$name")" "\$tmp"
  rm -rf "\$stage"
  stage="\$tmp"
fi
rm -rf "\$dest"
mv "\$stage" "\$dest"
EOF
  then
    echo "  error  ${name}  (remote swap failed on ${conn_label})" >&2
    return 1
  fi

  echo "  install  ${name}  (${why})  →  ${RESOLVED_USER}@${RESOLVED_HOST}:~/${rel_parent}/${name}"
}

install_target_remote() {
  local target="$1"
  local conn="$2"
  local src rel label

  sshub_call resolve_conn "$conn" || die "could not resolve connection: $conn"

  case "$target" in
    grok)
      src="$GROK_SRC"
      rel="$REMOTE_GROK_REL"
      label="grok"
      ;;
    cursor)
      src="$CURSOR_SRC"
      rel="$REMOTE_CURSOR_REL"
      label="cursor"
      ;;
    copilot)
      src="$COPILOT_SRC"
      rel="$REMOTE_COPILOT_REL"
      label="copilot"
      ;;
    *)
      die "unknown target: $target"
      ;;
  esac

  if [[ ! -d "$src" ]]; then
    die "source not found: $src"
  fi

  local skills
  mapfile -t skills < <(skill_dirs "$src")
  if [[ "${#skills[@]}" -eq 0 ]]; then
    echo "${RESOLVED_NAME} ${label}: no skills under ${src}"
    return 0
  fi

  echo "remote ${label} @ ${RESOLVED_NAME} (${RESOLVED_USER}@${RESOLVED_HOST}): ${src}  →  ~/${rel}/"
  if ! remote_skill_mtimes "$rel" "${skills[@]}"; then
    echo "  error: cannot reach ${RESOLVED_NAME} (${RESOLVED_USER}@${RESOLVED_HOST})" >&2
    return 1
  fi

  local name rc=0
  for name in "${skills[@]}"; do
    if ! install_skill_remote "$name" "${src}/${name}" "$rel" "$RESOLVED_NAME"; then
      rc=1
    fi
  done
  return "$rc"
}

status_target_remote() {
  local target="$1"
  local conn="$2"
  local src rel label

  sshub_call resolve_conn "$conn" || die "could not resolve connection: $conn"

  case "$target" in
    grok)
      src="$GROK_SRC"
      rel="$REMOTE_GROK_REL"
      label="grok"
      ;;
    cursor)
      src="$CURSOR_SRC"
      rel="$REMOTE_CURSOR_REL"
      label="cursor"
      ;;
    copilot)
      src="$COPILOT_SRC"
      rel="$REMOTE_COPILOT_REL"
      label="copilot"
      ;;
    *)
      die "unknown target: $target"
      ;;
  esac

  echo "remote ${label} @ ${RESOLVED_NAME} (${RESOLVED_USER}@${RESOLVED_HOST}): ~/${rel}/"
  if [[ ! -d "$src" ]]; then
    echo "  (source missing)"
    return 0
  fi

  local skills
  mapfile -t skills < <(skill_dirs "$src")
  if ! remote_skill_mtimes "$rel" "${skills[@]}"; then
    echo "  error: cannot reach host" >&2
    return 1
  fi

  local name src_ts dest_ts action
  for name in "${skills[@]}"; do
    src_ts="$(newest_mtime "${src}/${name}")"
    dest_ts="${REMOTE_MTIME[$name]:-0}"
    if should_install_ts "$src_ts" "$dest_ts"; then
      action="INSTALL"
    else
      action="skip"
    fi
    printf '  %-8s  %-20s  %s\n' "$action" "$name" "$(reason_for_ts "$src_ts" "$dest_ts")"
  done
}

# Idempotent ~/.tmux.conf title lines for the ify window-name contract.
# One of each option. A repeat leaves a correct file unchanged. When the
# file or the live server differs, reload a running server. Never kill it.
apply_tmux_title_file() {
  local conf="$1"
  local tmp changed=0
  local want_on='set -g set-titles on'
  local want_str='set -g set-titles-string "#{window_name}"'

  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo "tmux  would ensure titles in ${conf}"
    return 0
  fi

  mkdir -p "$(dirname "$conf")"
  tmp="$(mktemp)"
  if [[ -f "$conf" ]]; then
    awk '
      /^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+set-titles-string([[:space:]]|$)/ {
        if (!str) print "set -g set-titles-string \"#{window_name}\""
        str = 1
        next
      }
      /^[[:space:]]*set(-option)?[[:space:]]+-g[[:space:]]+set-titles([[:space:]]|$)/ {
        if (!on) print "set -g set-titles on"
        on = 1
        next
      }
      { print }
      END {
        if (!on) print "set -g set-titles on"
        if (!str) print "set -g set-titles-string \"#{window_name}\""
      }
    ' "$conf" > "$tmp"
  else
    printf '%s\n%s\n' "$want_on" "$want_str" > "$tmp"
  fi

  if [[ -f "$conf" ]] && cmp -s "$conf" "$tmp"; then
    echo "tmux  unchanged  ${conf}"
  else
    mv "$tmp" "$conf"
    tmp=""
    changed=1
    echo "tmux  updated  ${conf}"
  fi
  [[ -n "$tmp" && -f "$tmp" ]] && rm -f "$tmp"

  if [[ "${SVA_TMUX_NO_SOURCE:-0}" -eq 1 ]] || ! command -v tmux >/dev/null 2>&1; then
    return 0
  fi
  local live_on live_str
  live_on="$(tmux show-options -gv set-titles 2>/dev/null || true)"
  live_str="$(tmux show-options -gv set-titles-string 2>/dev/null || true)"
  if [[ -z "$live_on" && -z "$live_str" ]]; then
    return 0
  fi
  if [[ "$changed" -eq 1 || "$live_on" != "on" || "$live_str" != '#{window_name}' ]]; then
    if tmux source-file "$conf"; then
      echo "tmux  sourced  ${conf}"
    else
      echo "error: tmux source-file failed for ${conf}" >&2
      return 1
    fi
  fi
  return 0
}

ensure_tmux_titles_local() {
  apply_tmux_title_file "${HOME}/.tmux.conf"
}

ensure_tmux_titles_remote() {
  local conn="$1"
  load_sshub
  sshub_call resolve_conn "$conn" || return 1
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "tmux  would ensure titles on ${RESOLVED_USER}@${RESOLVED_HOST}:~/.tmux.conf"
    return 0
  fi
  echo "tmux titles → ${RESOLVED_USER}@${RESOLVED_HOST}:~/.tmux.conf"
  {
    declare -f apply_tmux_title_file
    echo 'apply_tmux_title_file "$HOME/.tmux.conf"'
  } | remote_ssh bash -s
}

run_for_targets() {
  # $1 = mode: install|status
  # remaining in TARGETS array, hosts in REMOTE_NAMES if DO_REMOTE
  local mode="$1"
  local t
  local failures=0

  if [[ "$DO_LOCAL" -eq 1 ]]; then
    if [[ "$mode" == "install" ]] && targets_include_copilot; then
      maybe_install_copilot_host
      echo
    fi
    for t in "${TARGETS[@]}"; do
      if [[ "$mode" == "install" ]]; then
        install_target_local "$t"
      else
        status_target_local "$t"
      fi
      echo
    done
  fi

  if [[ "$DO_REMOTE" -eq 1 ]]; then
    resolve_remote_list
    local conn
    for conn in "${REMOTE_NAMES[@]}"; do
      for t in "${TARGETS[@]}"; do
        if [[ "$mode" == "install" ]]; then
          if ! install_target_remote "$t" "$conn"; then
            echo "error: remote install failed for ${conn} (${t})" >&2
            failures=$((failures + 1))
          fi
        else
          if ! status_target_remote "$t" "$conn"; then
            echo "error: remote status failed for ${conn} (${t})" >&2
            failures=$((failures + 1))
          fi
        fi
        echo
      done
    done
  fi

  return "$failures"
}

# ── scratch source (detect / last-N) ──────────────────────────

# shellcheck source=lib/scratch_resolve.sh
source "$ROOT/scripts/lib/scratch_resolve.sh"
# scratch_cmd_show / scratch_print_unset_state / scratch_die_unset live in that file.

# scratch has its own --remote / --force; handle before installer flags.
if [[ "${1:-}" == "scratch" ]]; then
  shift
  scratch_cmd "$@"
  exit $?
fi

# ── arg parse ─────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h | --help)
      usage
      exit 0
      ;;
    --list | -l)
      list_conns
      exit 0
      ;;
    --force)
      FORCE=1
      shift
      ;;
    --host)
      if [[ "$HOST_ACTION" == "no" ]]; then
        die "use only one of --host or --no-host"
      fi
      HOST_ACTION=yes
      shift
      ;;
    --no-host)
      if [[ "$HOST_ACTION" == "yes" ]]; then
        die "use only one of --host or --no-host"
      fi
      HOST_ACTION=no
      shift
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --local)
      DO_LOCAL=1
      LOCAL_EXPLICIT=1
      shift
      ;;
    --remote | -r)
      DO_REMOTE=1
      # When --remote is used alone, prefer remote-only unless --local was set.
      if [[ "$LOCAL_EXPLICIT" -eq 0 ]]; then
        DO_LOCAL=0
      fi
      shift
      # Collect following non-option tokens as connection names until next flag
      # or a known subcommand word is not applicable (connections are freeform).
      while [[ $# -gt 0 && "$1" != -* ]]; do
        # Stop if this looks like the skill target after a misplaced order —
        # only treat as conn if install/status already seen or collect all.
        REMOTE_CONNS+=("$1")
        shift
      done
      ;;
    --)
      shift
      ARGS+=("$@")
      break
      ;;
    -*)
      die "unknown option: $1 (try --help)"
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

CMD="${ARGS[0]:-}"
# Remaining positionals after command: target (grok|cursor|copilot|all) and/or conns
# when --remote was not used with trailing conns.
REST=("${ARGS[@]:1}")

# project <repo> must run before target/conn peeling so a path is not a remote.
if [[ "$CMD" == "project" ]]; then
  install_project "${REST[@]+"${REST[@]}"}"
  rc=$?
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "(dry-run: no files written)"
  fi
  exit "$rc"
fi

# If user wrote: install grok --remote casai  → REST may hold grok only
# (remote already consumed casai). If: install --remote casai grok →
# REMOTE_CONNS has casai+grok and we need to peel skill targets from them.
# Handle skill targets in REST first; also peel known targets from REMOTE_CONNS.

TARGETS=()
TARGET_SET=0
KNOWN_TARGETS="grok|cursor|copilot|all"

is_known_target() {
  [[ "$1" =~ ^(grok|cursor|copilot|all)$ ]]
}

# Positionals after command that are skill targets, or the tmux title option.
for tok in "${REST[@]+"${REST[@]}"}"; do
  if [[ "$tok" == "tmux" ]]; then
    DO_TMUX=1
    TMUX_EXPLICIT=1
  elif is_known_target "$tok"; then
    if [[ "$tok" == "all" ]]; then
      TARGETS=(grok cursor copilot)
      DO_TMUX=1
    else
      TARGETS+=("$tok")
    fi
    TARGET_SET=1
  else
    # Extra tokens without --remote: treat as connection names and imply remote
    DO_REMOTE=1
    if [[ "$LOCAL_EXPLICIT" -eq 0 ]]; then
      DO_LOCAL=0
    fi
    REMOTE_CONNS+=("$tok")
  fi
done

# Peel accidental skill targets captured after --remote
if [[ "${#REMOTE_CONNS[@]}" -gt 0 ]]; then
  filtered=()
  for tok in "${REMOTE_CONNS[@]}"; do
    if [[ "$tok" == "tmux" ]]; then
      DO_TMUX=1
      TMUX_EXPLICIT=1
    elif is_known_target "$tok"; then
      if [[ "$TARGET_SET" -eq 0 ]]; then
        if [[ "$tok" == "all" ]]; then
          TARGETS=(grok cursor copilot)
          DO_TMUX=1
        else
          TARGETS+=("$tok")
        fi
        TARGET_SET=1
      fi
    else
      filtered+=("$tok")
    fi
  done
  REMOTE_CONNS=("${filtered[@]+"${filtered[@]}"}")
fi

if [[ "$CMD" == "tmux" ]]; then
  DO_TMUX=1
  TMUX_EXPLICIT=1
fi

# No target means the general install: every skill tree plus tmux titles.
# `install tmux` / `tmux` alone does not install skills.
if [[ "$TMUX_EXPLICIT" -eq 1 && "$TARGET_SET" -eq 0 ]]; then
  TARGETS=()
elif [[ "$TARGET_SET" -eq 0 || "${#TARGETS[@]}" -eq 0 ]]; then
  TARGETS=(grok cursor copilot)
  DO_TMUX=1
fi

# Deduplicate targets while preserving order
deduped=()
seen_t=""
for t in "${TARGETS[@]}"; do
  case " $seen_t " in
    *" $t "*) ;;
    *)
      deduped+=("$t")
      seen_t+=" $t"
      ;;
  esac
done
TARGETS=("${deduped[@]}")

case "$CMD" in
  "" | -h | --help)
    usage
    exit 0
    ;;
  list | ls)
    list_conns
    exit 0
    ;;
  install | pullinst | tmux)
    if [[ "$CMD" == "pullinst" ]]; then
      pull_origin_main
    fi
    if [[ "$DO_LOCAL" -eq 0 && "$DO_REMOTE" -eq 0 ]]; then
      DO_LOCAL=1
    fi
    rc=0
    if [[ "${#TARGETS[@]}" -gt 0 ]]; then
      run_for_targets install || rc=$?
    fi
    if [[ "$DO_TMUX" -eq 1 ]]; then
      if [[ "$DO_LOCAL" -eq 1 ]]; then
        ensure_tmux_titles_local || rc=1
      fi
      if [[ "$DO_REMOTE" -eq 1 ]]; then
        resolve_remote_list || rc=1
        for conn in "${REMOTE_NAMES[@]}"; do
          ensure_tmux_titles_remote "$conn" || rc=1
          echo
        done
      fi
    fi
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "(dry-run: no files written)"
    elif [[ "$rc" -eq 0 && "${#TARGETS[@]}" -gt 0 ]]; then
      scratch_install_detect
    fi
    exit "$rc"
    ;;
  status)
    if [[ "$DO_LOCAL" -eq 0 && "$DO_REMOTE" -eq 0 ]]; then
      DO_LOCAL=1
    fi
    run_for_targets status
    exit $?
    ;;
  *)
    die "unknown command: $CMD (try: install, pullinst, project, status, list, scratch, tmux, --help)"
    ;;
esac
