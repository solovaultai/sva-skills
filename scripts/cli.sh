#!/usr/bin/env bash
# sva-skills installer — sync repo skills into ~/.grok and ~/.cursor
# (local and/or across sshub connections from connections.env)
#
# Usage:
#   ./scripts/cli.sh install              # same as: install all (local)
#   ./scripts/cli.sh install all
#   ./scripts/cli.sh install grok
#   ./scripts/cli.sh install cursor
#   ./scripts/cli.sh pullinst             # git pull origin main, then install
#   ./scripts/cli.sh pullinst grok
#   ./scripts/cli.sh pullinst cursor
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
#   --remote, -r  Install to remote host(s) from connections.env
#   --local       Also install locally when using --remote
#   --list, -l    List sshub connections and exit
#   -h, --help    Show help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

GROK_SRC="${ROOT}/.grok"
CURSOR_SRC="${ROOT}/.cursor/skills"
GROK_DEST="${HOME}/.grok/skills"
CURSOR_DEST="${HOME}/.cursor/skills"

# Remote destinations are always under the remote user's home.
REMOTE_GROK_REL=".grok/skills"
REMOTE_CURSOR_REL=".cursor/skills"

SSHUB_BIN="${SSHUB_BIN:-$HOME/.local/bin/sshub}"
SSHUB_DATA_DIR="${SSHUB_DATA_DIR:-${XDG_DATA_HOME:-$HOME/.local/share}/sshub}"
ENV_FILE="${SSHUB_ENV_FILE:-$SSHUB_DATA_DIR/connections.env}"

FORCE=0
DRY_RUN=0
DO_REMOTE=0
DO_LOCAL=1 # default local; flipped off when --remote is used without --local
LOCAL_EXPLICIT=0
SSHUB_LOADED=0
SCP_FLAGS=() # used by sshub scp_connection when sourced

# Positional / free-form after options
ARGS=()
# Connection tokens collected after --remote (empty = all connections)
REMOTE_CONNS=()

usage() {
  cat <<'EOF'
sva-skills installer — sync repo skills into ~/.grok and ~/.cursor

Usage:
  ./scripts/cli.sh install              # same as: install all (local)
  ./scripts/cli.sh install all
  ./scripts/cli.sh install grok
  ./scripts/cli.sh install cursor
  ./scripts/cli.sh pullinst              # git pull origin main, then install
  ./scripts/cli.sh pullinst grok
  ./scripts/cli.sh pullinst cursor
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
  --remote, -r  Install to remote host(s); with no names, use all connections
  --local       Also install on this machine when using --remote
  --list, -l    List sshub connections and exit
  -h, --help    Show help

Targets:
  grok    .grok/<skill>/          →  ~/.grok/skills/<skill>/
  cursor  .cursor/skills/<skill>/ →  ~/.cursor/skills/<skill>/
  all     both (default when target omitted)

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
    *)
      die "unknown target: $target (use grok, cursor, or all)"
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
    *)
      die "unknown target: $target (use grok, cursor, or all)"
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

run_for_targets() {
  # $1 = mode: install|status
  # remaining in TARGETS array, hosts in REMOTE_NAMES if DO_REMOTE
  local mode="$1"
  local t
  local failures=0

  if [[ "$DO_LOCAL" -eq 1 ]]; then
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
# Remaining positionals after command: target (grok|cursor|all) and/or conns
# when --remote was not used with trailing conns.
REST=("${ARGS[@]:1}")

# If user wrote: install grok --remote casai  → REST may hold grok only
# (remote already consumed casai). If: install --remote casai grok →
# REMOTE_CONNS has casai+grok and we need to peel skill targets from them.
# Handle skill targets in REST first; also peel known targets from REMOTE_CONNS.

TARGETS=()
TARGET_SET=0
KNOWN_TARGETS="grok|cursor|all"

is_known_target() {
  [[ "$1" =~ ^(grok|cursor|all)$ ]]
}

# Positionals after command that are skill targets
for tok in "${REST[@]+"${REST[@]}"}"; do
  if is_known_target "$tok"; then
    if [[ "$tok" == "all" ]]; then
      TARGETS=(grok cursor)
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
    if is_known_target "$tok"; then
      if [[ "$TARGET_SET" -eq 0 ]]; then
        if [[ "$tok" == "all" ]]; then
          TARGETS=(grok cursor)
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

if [[ "$TARGET_SET" -eq 0 || "${#TARGETS[@]}" -eq 0 ]]; then
  TARGETS=(grok cursor)
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
  install | pullinst)
    if [[ "$CMD" == "pullinst" ]]; then
      pull_origin_main
    fi
    if [[ "$DO_LOCAL" -eq 0 && "$DO_REMOTE" -eq 0 ]]; then
      DO_LOCAL=1
    fi
    run_for_targets install
    rc=$?
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "(dry-run: no files written)"
    elif [[ "$rc" -eq 0 ]]; then
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
    die "unknown command: $CMD (try: install, pullinst, status, list, scratch, --help)"
    ;;
esac
