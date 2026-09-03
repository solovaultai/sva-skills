#!/usr/bin/env bash
# sva-skills scratch source — config, detect, search, last-N resolve.
# Source-only. Requires die(); remote ops also need load_sshub, sshub_call,
# remote_ssh, and RESOLVED_* from cli.sh.
#
# Config: ${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/scratch.env
# Cache (remote last-N): ${XDG_CACHE_HOME:-$HOME/.cache}/sva-skills/scratch/

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "error: source scripts/lib/scratch_resolve.sh — do not execute it." >&2
  exit 1
fi

SCRATCH_IMAGE_EXT_RE='png|jpg|jpeg|webp|gif|bmp'
SCRATCH_FIND_INAME=(-iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp')

scratch_config_path() {
  printf '%s' "${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/scratch.env"
}

scratch_cache_dir() {
  printf '%s' "${XDG_CACHE_HOME:-$HOME/.cache}/sva-skills/scratch"
}

scratch_data_dir() {
  printf '%s' "${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills"
}

# Convert Windows / Git Bash paths to a POSIX path this shell can open.
scratch_normalize_path() {
  local p="$1"
  case "$p" in
    "") printf '' ;;
    "~") printf '%s' "$HOME" ;;
    "~/"*) printf '%s' "$HOME/${p#~/}" ;;
    \\\\?\\*) p="${p:4}" ;;
    //?/*) p="${p:4}" ;;
  esac
  if [[ "$p" =~ ^[A-Za-z]:([\\/]|$) ]]; then
    local drive rest
    drive=$(printf '%s' "${p:0:1}" | tr '[:upper:]' '[:lower:]')
    rest="${p:2}"
    rest="${rest//\\//}"
    printf '/%s%s' "$drive" "$rest"
    return 0
  fi
  if [[ "$p" == *\\* ]]; then
    printf '%s' "${p//\\//}"
    return 0
  fi
  printf '%s' "$p"
}

scratch_is_image_name() {
  local base="${1##*/}"
  local ext="${base##*.}"
  [[ "$base" != "$ext" ]] || return 1
  local lower
  lower=$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')
  [[ "$lower" =~ ^($SCRATCH_IMAGE_EXT_RE)$ ]]
}

scratch_dir_image_count() {
  local dir="$1"
  [[ -d "$dir" ]] || { echo 0; return; }
  local n=0 f
  # Non-recursive: only this directory.
  shopt -s nullglob nocaseglob
  local files=("$dir"/*)
  shopt -u nullglob nocaseglob
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    if scratch_is_image_name "$f"; then
      n=$((n + 1))
    fi
  done
  echo "$n"
}

scratch_dir_has_images() {
  local n
  n="$(scratch_dir_image_count "$1")"
  [[ "$n" -gt 0 ]]
}

# Newest-first: epoch<TAB>abspath
scratch_list_local_images() {
  local dir="$1"
  [[ -d "$dir" ]] || return 0
  local f
  shopt -s nullglob nocaseglob
  local files=("$dir"/*)
  shopt -u nullglob nocaseglob
  for f in "${files[@]}"; do
    [[ -f "$f" ]] || continue
    scratch_is_image_name "$f" || continue
    local ts
    ts="$(stat -c '%Y' "$f" 2>/dev/null || stat -f '%m' "$f" 2>/dev/null || echo 0)"
    printf '%s\t%s\n' "$ts" "$(cd "$(dirname "$f")" && pwd)/$(basename "$f")"
  done | sort -t $'\t' -k1,1nr
}

# Same prefix rules as sshub resolve_remote_path.
# bare x → NAME_FOLDER/x; ~ ~/x /abs stay verbatim.
scratch_resolve_remote_path() {
  local dir="$1"
  local base="${2-${RESOLVED_FOLDER:-}}"
  case "$dir" in
    "" | "~" | "~/"* | "/"*) printf '%s' "$dir" ;;
    *)
      if [[ -n "$base" ]]; then
        case "$base" in
          */) printf '%s%s' "$base" "$dir" ;;
          *) printf '%s/%s' "$base" "$dir" ;;
        esac
      else
        printf '%s' "$dir"
      fi
      ;;
  esac
}

scratch_load() {
  SCRATCH_KIND=""
  SCRATCH_DIR=""
  SCRATCH_CONN=""
  SCRATCH_REMOTE_DIR=""
  local cfg
  cfg="$(scratch_config_path)"
  [[ -f "$cfg" ]] || return 1
  # shellcheck disable=SC1090
  set +u
  # Only accept our keys (ignore junk / exports).
  local line key val
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line#"${line%%[![:space:]]*}"}"
    [[ -z "$line" || "$line" == \#* ]] && continue
    [[ "$line" == export* ]] && line="${line#export }"
    line="${line#"${line%%[![:space:]]*}"}"
    [[ "$line" == *=* ]] || continue
    key="${line%%=*}"
    val="${line#*=}"
    val="${val%$'\r'}"
    if [[ "$val" == \"*\" ]]; then
      val="${val:1:${#val}-2}"
    elif [[ "$val" == \'*\' ]]; then
      val="${val:1:${#val}-2}"
    fi
    case "$key" in
      SCRATCH_KIND) SCRATCH_KIND="$val" ;;
      SCRATCH_DIR) SCRATCH_DIR="$val" ;;
      SCRATCH_CONN) SCRATCH_CONN="$val" ;;
      SCRATCH_REMOTE_DIR) SCRATCH_REMOTE_DIR="$val" ;;
    esac
  done <"$cfg"
  set -u
  return 0
}

scratch_write() {
  local cfg dir
  cfg="$(scratch_config_path)"
  dir="$(dirname "$cfg")"
  if [[ "${DRY_RUN:-0}" -eq 1 ]]; then
    echo "would write  $cfg" >&2
    return 0
  fi
  mkdir -p "$dir"
  local tmp
  tmp="$(mktemp "$dir/.scratch.env.XXXXXX")"
  {
    echo "# sva-skills scratch source — kind=local|remote"
    echo "SCRATCH_KIND=${SCRATCH_KIND}"
    if [[ "${SCRATCH_KIND}" == "remote" ]]; then
      echo "SCRATCH_CONN=${SCRATCH_CONN}"
      echo "SCRATCH_REMOTE_DIR=${SCRATCH_REMOTE_DIR}"
    else
      echo "SCRATCH_DIR=${SCRATCH_DIR}"
    fi
  } >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$cfg"
  chmod 600 "$cfg"
}

# Ordered local candidates (this box). Prints one path per line.
scratch_local_candidates() {
  local seen="" add
  add() {
    local p="$1"
    [[ -n "$p" ]] || return 0
    p="$(scratch_normalize_path "$p")"
    [[ -n "$p" ]] || return 0
    case " $seen " in
      *" $p "*) return 0 ;;
    esac
    seen+=" $p"
    printf '%s\n' "$p"
  }

  if [[ -n "${SCREENSHOT_DIR:-}" ]]; then
    add "$SCREENSHOT_DIR"
  fi

  local ost
  ost="$(uname -s 2>/dev/null || echo unknown)"
  local is_win=0
  case "${OSTYPE:-}:$ost" in
    msys*|cygwin*|mingw*|win32*|windows*|*:MINGW*|*:MSYS*|*:CYGWIN*|*:Windows_NT) is_win=1 ;;
  esac

  if [[ "$is_win" -eq 0 ]]; then
    local pictures=""
    if command -v xdg-user-dir >/dev/null 2>&1; then
      pictures="$(xdg-user-dir PICTURES 2>/dev/null || true)"
    fi
    if [[ -n "$pictures" ]]; then
      add "${pictures}/Screenshots"
      add "$pictures"
    fi
  fi

  add "$HOME/Pictures/Screenshots"
  add "$HOME/Pictures"

  if [[ "$is_win" -eq 1 ]]; then
    add "$HOME/Pictures/Screenshots"
    add "$HOME/OneDrive/Pictures/Screenshots"
    add "$HOME/OneDrive/Pictures"
    if [[ -n "${USERPROFILE:-}" ]]; then
      add "${USERPROFILE}/Pictures/Screenshots"
      add "${USERPROFILE}/Pictures"
      add "${USERPROFILE}/OneDrive/Pictures/Screenshots"
      add "${USERPROFILE}/OneDrive/Pictures"
    fi
    if [[ -n "${OneDrive:-}" ]]; then
      add "${OneDrive}/Pictures/Screenshots"
      add "${OneDrive}/Pictures"
    fi
  fi
}

# Pick best candidate: prefer exists+images, else first existing.
# Prints path or empty.
scratch_pick_detect() {
  local first_existing="" p
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    if [[ -d "$p" ]]; then
      if scratch_dir_has_images "$p"; then
        printf '%s' "$p"
        return 0
      fi
      if [[ -z "$first_existing" ]]; then
        first_existing="$p"
      fi
    fi
  done < <(scratch_local_candidates)
  printf '%s' "$first_existing"
}

scratch_fmt_mtime() {
  local ts="$1"
  if date -d "@${ts}" '+%Y-%m-%d %H:%M:%S' >/dev/null 2>&1; then
    date -d "@${ts}" '+%Y-%m-%d %H:%M:%S'
  elif date -r "$ts" '+%Y-%m-%d %H:%M:%S' >/dev/null 2>&1; then
    date -r "$ts" '+%Y-%m-%d %H:%M:%S'
  else
    printf '%s' "$ts"
  fi
}

scratch_ensure_conn() {
  local token="$1"
  load_sshub
  sshub_call resolve_conn "$token" || die "unknown connection: $token"
}

# Remote image list: epoch<TAB>basename (newest first). Uses GNU find -printf,
# then per-file stat, then ls -lt. Never copies the tree.
scratch_remote_list_images() {
  local rdir="$1"
  local out
  if ! out="$(remote_ssh "bash -s" <<EOF
set +e
dir=$(printf '%q' "$rdir")
case "\$dir" in
  ~) dir="\$HOME" ;;
  "~/"*) dir="\$HOME/\${dir#\~/}" ;;
esac
if [ ! -d "\$dir" ]; then
  echo "NODIR" >&2
  exit 2
fi
exts='png|jpg|jpeg|webp|gif|bmp'
is_img() {
  b="\${1##*/}"
  e="\${b##*.}"
  [ "\$b" != "\$e" ] || return 1
  e=\$(printf '%s' "\$e" | tr '[:upper:]' '[:lower:]')
  echo "\$e" | grep -Eq "^(\$exts)\$"
}
if find "\$dir" -maxdepth 1 -type f -printf '%T@ %f\\n' >/dev/null 2>&1; then
  find "\$dir" -maxdepth 1 -type f \\( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \\) -printf '%T@\\t%f\\n'
  exit 0
fi
# Per-file stat (GNU or BSD).
found=0
for f in "\$dir"/*; do
  [ -f "\$f" ] || continue
  is_img "\$f" || continue
  ts=\$(stat -c '%Y' "\$f" 2>/dev/null || stat -f '%m' "\$f" 2>/dev/null || echo "")
  [ -n "\$ts" ] || continue
  found=1
  printf '%s\\t%s\\n' "\$ts" "\${f##*/}"
done
if [ "\$found" -eq 1 ]; then
  exit 0
fi
# ls -lt fallback: newest first; fake descending ranks.
n=100000
ls -lt "\$dir" 2>/dev/null | while IFS= read -r line; do
  case "\$line" in
    total*) continue ;;
  esac
  name=\$(printf '%s' "\$line" | awk '{print \$NF}')
  [ -n "\$name" ] || continue
  is_img "\$name" || continue
  printf '%s\\t%s\\n' "\$n" "\$name"
  n=\$((n - 1))
done
EOF
)"; then
    return 1
  fi
  printf '%s\n' "$out" | grep -v '^$' | sort -t $'\t' -k1,1nr || true
}

scratch_remote_scp_one() {
  local remote_file="$1"
  local dest="$2"
  local -a key_args=()
  [[ -n "${RESOLVED_KEY:-}" ]] && key_args=(-i "$RESOLVED_KEY")
  set +u
  scp -o BatchMode=yes -o StrictHostKeyChecking=accept-new -q -p \
    -o ConnectTimeout=8 \
    -P "${RESOLVED_PORT:-22}" \
    "${key_args[@]}" \
    "${RESOLVED_USER}@${RESOLVED_HOST}:${remote_file}" \
    "$dest"
  local rc=$?
  set -u
  return "$rc"
}

# Fetch only N newest remote images into cache; print cache paths.
scratch_fetch_remote_lastn() {
  local n="$1"
  local rdir="$2"
  local cache
  cache="$(scratch_cache_dir)"
  mkdir -p "$cache"

  local listing
  listing="$(scratch_remote_list_images "$rdir")" || die "cannot list remote images in ${rdir}"
  if [[ -z "${listing//[$'\t\n\r ']/}" ]]; then
    return 0
  fi

  # Expand ~ for scp (scp does not always expand remote ~).
  local scp_dir="$rdir"
  case "$scp_dir" in
    ~) scp_dir="" ;;
    "~/"*) scp_dir="${scp_dir#~/}" ;;
  esac

  local count=0 line ts name
  while IFS= read -r line; do
    [[ -n "$line" ]] || continue
    ts="${line%%$'\t'*}"
    name="${line#*$'\t'}"
    [[ -n "$name" ]] || continue
    local remote_spec dest
    if [[ -z "$scp_dir" ]]; then
      remote_spec="$name"
    else
      remote_spec="${scp_dir%/}/${name}"
    fi
    dest="${cache}/${name}"
    if ! scratch_remote_scp_one "$remote_spec" "$dest"; then
      die "scp failed for ${name}"
    fi
    printf '%s\n' "$dest"
    count=$((count + 1))
    [[ "$count" -ge "$n" ]] && break
  done <<<"$listing"
}

scratch_source_label() {
  if ! scratch_load; then
    printf 'workspace scratch/'
    return
  fi
  case "${SCRATCH_KIND}" in
    remote)
      printf 'remote %s:%s' "${SCRATCH_CONN}" "${SCRATCH_REMOTE_DIR}"
      ;;
    local)
      printf 'local %s' "${SCRATCH_DIR}"
      ;;
    *)
      printf 'workspace scratch/'
      ;;
  esac
}

scratch_print_purpose() {
  cat <<'EOF'
Screenshot / scratch image source
This is the folder ify Nimages and Grok /image use for last-N images
(png, jpg, jpeg, webp, gif, bmp).
EOF
}

scratch_print_next_steps() {
  cat <<'EOF'
Next steps (copy-paste):
  cli scratch detect
  ./scripts/cli.sh scratch detect

  cli scratch search
  ./scripts/cli.sh scratch search

  cli scratch set ~/Pictures/Screenshots
  ./scripts/cli.sh scratch set ~/Pictures/Screenshots
EOF
}

scratch_print_config_note() {
  local cfg="$1"
  scratch_kv "Config file:" "$cfg"
  if [[ -f "$cfg" ]]; then
    echo "               (exists but no source is set — detect/set will write it here)"
  else
    echo "               (not created yet — detect/set will save the source here)"
  fi
}

scratch_has_source() {
  scratch_load || return 1
  case "${SCRATCH_KIND}" in
    local) [[ -n "${SCRATCH_DIR}" ]] ;;
    remote) [[ -n "${SCRATCH_CONN}" ]] ;;
    *) return 1 ;;
  esac
}

scratch_print_unset_state() {
  local cfg
  cfg="$(scratch_config_path)"
  scratch_print_purpose
  echo
  echo "No screenshot folder is configured yet."
  echo "This is not broken. Skills fall back to the workspace scratch/ directory"
  echo "(repo root, or the project's existing scratch dir). last-N will not use"
  echo "~/Pictures/Screenshots until you detect or set a source."
  echo
  scratch_print_config_note "$cfg"
  echo
  scratch_print_next_steps
}

scratch_die_unset() {
  echo "error: no screenshot folder is configured yet" >&2
  echo "This is not broken. Skills fall back to the workspace scratch/ directory." >&2
  echo "last-N will not use ~/Pictures/Screenshots until you detect or set a source." >&2
  echo >&2
  scratch_print_config_note "$(scratch_config_path)" >&2
  echo >&2
  scratch_print_next_steps >&2
  exit 1
}

scratch_kv() {
  printf '%-15s%s\n' "$1" "$2"
}

scratch_usage() {
  cat <<EOF
sva-skills scratch source — last-N images for ify Nimages and Grok /image

\`scratch show\` reports the screenshot / scratch folder those skills read.
If unset, skills fall back to the workspace scratch/ directory (not broken).

Usage:
  ./scripts/cli.sh scratch show
  ./scripts/cli.sh scratch set <path>
  ./scripts/cli.sh scratch set --remote <conn> <dir>
  ./scripts/cli.sh scratch search
  ./scripts/cli.sh scratch search --remote <conn>
  ./scripts/cli.sh scratch detect [--force]
  ./scripts/cli.sh scratch ls [N]          # default N=5; paths only (skills use this)

Config:
  $(scratch_config_path)
  kind=local|remote  (install writes if unset; detect --force overwrites)

Remote dirs use sshub rules: bare name joins NAME_FOLDER; ~ ~/x /abs stay verbatim.
Last-N remote: ssh list by mtime, scp only those N files into
  $(scratch_cache_dir)
EOF
}

scratch_cmd_show() {
  local cfg
  cfg="$(scratch_config_path)"
  if ! scratch_has_source; then
    scratch_print_unset_state
    return 0
  fi
  scratch_print_purpose
  echo
  scratch_kv "Kind:" "${SCRATCH_KIND}"
  case "${SCRATCH_KIND}" in
    local)
      if [[ -d "${SCRATCH_DIR}" ]]; then
        scratch_kv "Local folder:" "${SCRATCH_DIR}"
        scratch_kv "Images:" "$(scratch_dir_image_count "${SCRATCH_DIR}")"
        echo "Recent:"
        local line ts path i=0
        while IFS= read -r line; do
          [[ -n "$line" ]] || continue
          ts="${line%%$'\t'*}"
          path="${line#*$'\t'}"
          printf '  %s  %s\n' "$(scratch_fmt_mtime "$ts")" "$(basename "$path")"
          i=$((i + 1))
          [[ "$i" -ge 5 ]] && break
        done < <(scratch_list_local_images "${SCRATCH_DIR}")
        if [[ "$i" -eq 0 ]]; then
          echo "  (none)"
        fi
      else
        scratch_kv "Local folder:" "${SCRATCH_DIR}  (missing on this box)"
      fi
      ;;
    remote)
      scratch_kv "Remote host:" "${SCRATCH_CONN}"
      scratch_kv "Remote folder:" "${SCRATCH_REMOTE_DIR}"
      if scratch_ensure_conn "${SCRATCH_CONN}"; then
        local rdir
        rdir="$(scratch_resolve_remote_path "${SCRATCH_REMOTE_DIR}")"
        scratch_kv "Resolved as:" "${rdir}  (${RESOLVED_USER}@${RESOLVED_HOST})"
        local line ts name i=0
        if listing="$(scratch_remote_list_images "$rdir")"; then
          echo "Recent:"
          while IFS= read -r line; do
            [[ -n "$line" ]] || continue
            ts="${line%%$'\t'*}"
            name="${line#*$'\t'}"
            printf '  %s  %s\n' "$(scratch_fmt_mtime "$ts")" "$name"
            i=$((i + 1))
            [[ "$i" -ge 5 ]] && break
          done <<<"$listing"
          if [[ "$i" -eq 0 ]]; then
            echo "  (none reachable)"
          fi
        else
          scratch_kv "Recent:" "(host unreachable)"
        fi
      fi
      ;;
  esac
  scratch_kv "Config file:" "$cfg"
}

scratch_cmd_set() {
  if [[ "${1:-}" == "--remote" || "${1:-}" == "-r" ]]; then
    shift
    local conn="${1:-}"
    local rdir="${2:-}"
    [[ -n "$conn" && -n "$rdir" ]] || die "usage: scratch set --remote <conn> <dir>"
    scratch_ensure_conn "$conn"
    SCRATCH_KIND=remote
    SCRATCH_CONN="$RESOLVED_NAME"
    SCRATCH_REMOTE_DIR="$rdir"
    SCRATCH_DIR=""
    scratch_write
    echo "scratch source: remote ${SCRATCH_CONN}:${SCRATCH_REMOTE_DIR}"
    echo "config:         $(scratch_config_path)"
    return 0
  fi
  local path="${1:-}"
  [[ -n "$path" ]] || die "usage: scratch set <path>   or   scratch set --remote <conn> <dir>"
  path="$(scratch_normalize_path "$path")"
  if [[ ! -d "$path" ]]; then
    die "directory not found: $path"
  fi
  # Prefer absolute.
  path="$(cd "$path" && pwd)"
  SCRATCH_KIND=local
  SCRATCH_DIR="$path"
  SCRATCH_CONN=""
  SCRATCH_REMOTE_DIR=""
  scratch_write
  echo "scratch source: local ${SCRATCH_DIR}"
  echo "config:         $(scratch_config_path)"
}

scratch_cmd_search() {
  if [[ "${1:-}" == "--remote" || "${1:-}" == "-r" ]]; then
    local conn="${2:-}"
    [[ -n "$conn" ]] || die "usage: scratch search --remote <conn>"
    scratch_ensure_conn "$conn"
    echo "remote search @ ${RESOLVED_NAME} (${RESOLVED_USER}@${RESOLVED_HOST})"
    local folder="${RESOLVED_FOLDER:-}"
    local -a cands=()
    if [[ -n "$folder" ]]; then
      cands+=("$folder" "${folder%/}/scratch")
    fi
    cands+=("scratch" "~/Pictures/Screenshots" "~/Pictures" "~/Desktop")
    local d
    for d in "${cands[@]}"; do
      local rdir
      rdir="$(scratch_resolve_remote_path "$d")"
      local out rc
      set +e
      out="$(remote_ssh "bash -s" <<EOF
set +e
dir=$(printf '%q' "$rdir")
case "\$dir" in
  ~) dir="\$HOME" ;;
  "~/"*) dir="\$HOME/\${dir#\~/}" ;;
esac
if [ ! -d "\$dir" ]; then
  echo "missing"
  exit 0
fi
n=0
for f in "\$dir"/*; do
  [ -f "\$f" ] || continue
  b="\${f##*/}"
  e="\${b##*.}"
  [ "\$b" != "\$e" ] || continue
  e=\$(printf '%s' "\$e" | tr '[:upper:]' '[:lower:]')
  echo "\$e" | grep -Eq '^(png|jpg|jpeg|webp|gif|bmp)\$' || continue
  n=\$((n + 1))
done
echo "ok \$n"
EOF
)"
      rc=$?
      set -eu
      if [[ "$rc" -ne 0 ]]; then
        printf '  %-40s  (unreachable)\n' "$rdir"
        continue
      fi
      if [[ "$out" == missing ]]; then
        printf '  %-40s  missing\n' "$rdir"
      else
        local n="${out#ok }"
        printf '  %-40s  %s images\n' "$rdir" "$n"
      fi
    done
    return 0
  fi

  echo "local search (this box):"
  local p n exists imgs
  while IFS= read -r p; do
    [[ -n "$p" ]] || continue
    if [[ -d "$p" ]]; then
      exists="exists"
      n="$(scratch_dir_image_count "$p")"
      imgs="${n} images"
    else
      exists="missing"
      imgs="-"
    fi
    printf '  %-50s  %-8s  %s\n' "$p" "$exists" "$imgs"
  done < <(scratch_local_candidates)
}

# Write detect result. $1 = force (1 overwrite).
scratch_detect_write() {
  local force="${1:-0}"
  local cfg
  cfg="$(scratch_config_path)"
  if [[ -f "$cfg" && "$force" -eq 0 ]] && scratch_has_source; then
    echo "scratch source already set ($(scratch_config_path)) — use --force to overwrite"
    scratch_cmd_show
    return 0
  fi
  local picked
  picked="$(scratch_pick_detect)"
  if [[ -z "$picked" ]]; then
    echo "No screenshot folder was found on this box."
    echo "This is not broken. Skills fall back to the workspace scratch/ directory."
    echo "last-N will not use ~/Pictures/Screenshots until you set a source."
    echo
    scratch_print_config_note "$cfg"
    echo
    scratch_print_next_steps
    return 0
  fi
  SCRATCH_KIND=local
  SCRATCH_DIR="$picked"
  SCRATCH_CONN=""
  SCRATCH_REMOTE_DIR=""
  scratch_write
  echo "scratch source: local ${SCRATCH_DIR}"
  echo "config:         $(scratch_config_path)"
}

scratch_cmd_detect() {
  local force=0
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force) force=1; shift ;;
      *) die "unknown option for scratch detect: $1" ;;
    esac
  done
  # Global --force (install-style) also overwrites.
  if [[ "${FORCE:-0}" -eq 1 ]]; then
    force=1
  fi
  scratch_detect_write "$force"
}

# Install hook: write only if unset. Never overwrite.
scratch_install_detect() {
  local cfg
  cfg="$(scratch_config_path)"
  if [[ -f "$cfg" ]]; then
    return 0
  fi
  echo
  echo "scratch source (first install):"
  scratch_detect_write 0
}

scratch_cmd_ls() {
  local n="${1:-5}"
  if [[ ! "$n" =~ ^[0-9]+$ ]] || [[ "$n" -lt 1 ]]; then
    die "scratch ls: N must be a positive integer (got: ${n})"
  fi
  if ! scratch_has_source; then
    scratch_die_unset
  fi
  case "${SCRATCH_KIND}" in
    local)
      [[ -n "${SCRATCH_DIR}" ]] || die "SCRATCH_DIR is empty"
      [[ -d "${SCRATCH_DIR}" ]] || die "scratch dir not found: ${SCRATCH_DIR}"
      local line path i=0
      while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        path="${line#*$'\t'}"
        printf '%s\n' "$path"
        i=$((i + 1))
        [[ "$i" -ge "$n" ]] && break
      done < <(scratch_list_local_images "${SCRATCH_DIR}")
      ;;
    remote)
      [[ -n "${SCRATCH_CONN}" ]] || die "SCRATCH_CONN is empty"
      scratch_ensure_conn "${SCRATCH_CONN}"
      local rdir
      rdir="$(scratch_resolve_remote_path "${SCRATCH_REMOTE_DIR:-scratch}")"
      scratch_fetch_remote_lastn "$n" "$rdir"
      ;;
    *)
      die "unknown SCRATCH_KIND: ${SCRATCH_KIND}"
      ;;
  esac
}

scratch_cmd() {
  local sub="${1:-}"
  shift || true
  case "$sub" in
    "" | -h | --help | help)
      scratch_usage
      ;;
    show)
      scratch_cmd_show
      ;;
    set)
      scratch_cmd_set "$@"
      ;;
    search)
      scratch_cmd_search "$@"
      ;;
    detect)
      scratch_cmd_detect "$@"
      ;;
    ls)
      scratch_cmd_ls "$@"
      ;;
    *)
      die "unknown scratch command: ${sub} (try: show, set, search, detect, ls)"
      ;;
  esac
}
