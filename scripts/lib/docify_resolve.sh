#!/usr/bin/env bash
# sva-skills docify defaults — scratch, format, path, prefix.
# Source-only. Requires die().
#
# Config: ${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/docify.env

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "error: source scripts/lib/docify_resolve.sh — do not execute it." >&2
  exit 1
fi

docify_config_path() {
  printf '%s' "${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/docify.env"
}

DOCIFY_SCRATCH=""
DOCIFY_FORMAT=""
DOCIFY_PATH=""
DOCIFY_PREFIX=""

docify_load() {
  local cfg line key val
  cfg="$(docify_config_path)"
  DOCIFY_SCRATCH=""
  DOCIFY_FORMAT=""
  DOCIFY_PATH=""
  DOCIFY_PREFIX=""
  [[ -f "$cfg" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" == *=* ]] || continue
    key="${line%%=*}"
    val="${line#*=}"
    case "$key" in
      scratch) DOCIFY_SCRATCH="$val" ;;
      format) DOCIFY_FORMAT="$val" ;;
      path) DOCIFY_PATH="$val" ;;
      prefix) DOCIFY_PREFIX="$val" ;;
    esac
  done <"$cfg"
}

docify_write() {
  local cfg dir tmp
  cfg="$(docify_config_path)"
  dir="$(dirname "$cfg")"
  mkdir -p "$dir"
  tmp="$(mktemp "$dir/.docify.env.XXXXXX")"
  {
    echo "# sva-skills docify defaults"
    echo "scratch=${DOCIFY_SCRATCH}"
    echo "format=${DOCIFY_FORMAT}"
    echo "path=${DOCIFY_PATH}"
    echo "prefix=${DOCIFY_PREFIX}"
  } >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$cfg"
  chmod 600 "$cfg"
}

docify_show() {
  docify_load
  echo "config: $(docify_config_path)"
  echo "scratch: ${DOCIFY_SCRATCH}"
  echo "format: ${DOCIFY_FORMAT}"
  echo "path: ${DOCIFY_PATH}"
  echo "prefix: ${DOCIFY_PREFIX}"
}

# Print the canonical format token, or return 1.
docify_norm_format() {
  local t
  t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$t" in
    md | markdown) printf '%s' md ;;
    txt | text) printf '%s' txt ;;
    word | docx) printf '%s' docx ;;
    html) printf '%s' html ;;
    *) return 1 ;;
  esac
}

docify_is_format_alias() {
  local t
  t="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  case "$t" in
    format | md | markdown | txt | text | word | docx | html) return 0 ;;
    *) return 1 ;;
  esac
}

docify_cmd_set() {
  local key="${1:-}"
  shift || true
  [[ -n "$key" ]] || die "usage: docify set scratch|format|path|prefix"
  local low
  low="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"
  case "$low" in
    docif | scrach)
      die "unknown docify key: $key"
      ;;
  esac
  case "$low" in
    scratch)
      if [[ $# -gt 1 || ( $# -eq 1 && "$1" != "1" ) ]]; then
        die "usage: docify set scratch"
      fi
      ;;
    format)
      [[ $# -eq 1 ]] || die "usage: docify set format md|txt|docx|html"
      docify_norm_format "$1" >/dev/null || die "unknown docify format: $1"
      ;;
    path)
      [[ $# -eq 1 && -n "$1" ]] || die "usage: docify set path <dir>"
      ;;
    prefix)
      [[ $# -eq 1 ]] || die "usage: docify set prefix <text>"
      ;;
    *)
      die "unknown docify key: $key (try: scratch, format, path, prefix)"
      ;;
  esac
  docify_load
  case "$low" in
    scratch) DOCIFY_SCRATCH=1 ;;
    format) DOCIFY_FORMAT="$(docify_norm_format "$1")" ;;
    path) DOCIFY_PATH="$1" ;;
    prefix) DOCIFY_PREFIX="$1" ;;
  esac
  docify_write
  docify_show
}

docify_cmd_clear() {
  local key="${1:-}"
  [[ $# -eq 1 && -n "$key" ]] || die "usage: docify clear scratch|format|path|prefix"
  local low
  low="$(printf '%s' "$key" | tr '[:upper:]' '[:lower:]')"
  case "$low" in
    docif | scrach)
      die "unknown docify key: $key"
      ;;
  esac
  case "$low" in
    scratch | path | prefix | clearprefix) ;;
    *)
      docify_is_format_alias "$low" || die "unknown docify key: $key (try: scratch, format, path, prefix)"
      ;;
  esac
  docify_load
  case "$low" in
    scratch) DOCIFY_SCRATCH="" ;;
    path) DOCIFY_PATH="" ;;
    prefix | clearprefix) DOCIFY_PREFIX="" ;;
    *) DOCIFY_FORMAT="" ;;
  esac
  docify_write
  docify_show
}

docify_usage() {
  cat <<EOF
Usage:
  ./scripts/cli.sh docify show
  ./scripts/cli.sh docify set scratch
  ./scripts/cli.sh docify set format md|txt|docx|html
  ./scripts/cli.sh docify set path <dir>
  ./scripts/cli.sh docify set prefix <text>
  ./scripts/cli.sh docify clear scratch|format|path|prefix

Config: $(docify_config_path)
Keys: scratch, format, path, prefix.
A format alias (md, markdown, txt, text, word, docx, html) clears format only.
docif and scrach are not keys.
EOF
}

docify_cmd() {
  local sub="${1:-}"
  shift || true
  case "$sub" in
    "" | -h | --help | help)
      docify_usage
      ;;
    show)
      docify_show
      ;;
    set)
      docify_cmd_set "$@"
      ;;
    clear)
      docify_cmd_clear "$@"
      ;;
    docif | scrach)
      die "unknown docify command: ${sub} (try: show, set, clear)"
      ;;
    *)
      die "unknown docify command: ${sub} (try: show, set, clear)"
      ;;
  esac
}
