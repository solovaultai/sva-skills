#!/usr/bin/env bash
# sva-skills optify switch — enabled, before, after.
# Source-only. Requires die().
#
# Config: ${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env
#
#   ./scripts/cli.sh optify on|off|show|before|after|clear-shots

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "error: source scripts/lib/optify_resolve.sh — do not execute it." >&2
  exit 1
fi

optify_config_path() {
  printf '%s' "${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env"
}

# Empty enabled means the key is absent (on). before/after are "1" or empty.
OPTIFY_ENABLED=""
OPTIFY_BEFORE=""
OPTIFY_AFTER=""

optify_load() {
  local cfg line key val
  cfg="$(optify_config_path)"
  OPTIFY_ENABLED=""
  OPTIFY_BEFORE=""
  OPTIFY_AFTER=""
  [[ -f "$cfg" ]] || return 0
  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%$'\r'}"
    [[ "$line" =~ ^[[:space:]]*# ]] && continue
    [[ "$line" == *=* ]] || continue
    key="${line%%=*}"
    val="${line#*=}"
    case "$key" in
      enabled) OPTIFY_ENABLED="$val" ;;
      before) OPTIFY_BEFORE="$val" ;;
      after) OPTIFY_AFTER="$val" ;;
    esac
  done <"$cfg"
}

optify_write() {
  local cfg dir tmp
  cfg="$(optify_config_path)"
  dir="$(dirname "$cfg")"
  mkdir -p "$dir"
  tmp="$(mktemp "$dir/.optify.env.XXXXXX")"
  {
    echo "# sva-skills optify"
    if [[ "$OPTIFY_ENABLED" == "on" || "$OPTIFY_ENABLED" == "off" ]]; then
      echo "enabled=${OPTIFY_ENABLED}"
    fi
    # before and after are absent unless armed. Never write before=0 or after=0.
    if [[ "$OPTIFY_BEFORE" == "1" ]]; then
      echo "before=1"
    fi
    if [[ "$OPTIFY_AFTER" == "1" ]]; then
      echo "after=1"
    fi
  } >"$tmp"
  chmod 600 "$tmp"
  mv "$tmp" "$cfg"
  chmod 600 "$cfg"
}

optify_show() {
  local en before after
  optify_load
  if [[ "$OPTIFY_ENABLED" == "off" ]]; then
    en="off"
  else
    en="on"
  fi
  if [[ "$OPTIFY_BEFORE" == "1" ]]; then
    before="armed"
  else
    before="not"
  fi
  if [[ "$OPTIFY_AFTER" == "1" ]]; then
    after="armed"
  else
    after="not"
  fi
  echo "config: $(optify_config_path)"
  echo "enabled: ${en}"
  echo "before: ${before}"
  echo "after: ${after}"
}

optify_cmd_on() {
  optify_load
  OPTIFY_ENABLED="on"
  optify_write
}

optify_cmd_off() {
  optify_load
  OPTIFY_ENABLED="off"
  optify_write
}

optify_cmd_before() {
  optify_load
  OPTIFY_BEFORE="1"
  optify_write
}

optify_cmd_after() {
  optify_load
  OPTIFY_AFTER="1"
  optify_write
}

optify_cmd_clear_shots() {
  local cfg
  cfg="$(optify_config_path)"
  [[ -f "$cfg" ]] || return 0
  optify_load
  OPTIFY_BEFORE=""
  OPTIFY_AFTER=""
  optify_write
}

optify_cmd() {
  local sub="${1:-}"
  shift || true
  if [[ $# -gt 0 || -z "$sub" ]]; then
    die "usage: optify on|off|show|before|after|clear-shots"
  fi
  local low
  low="$(printf '%s' "$sub" | tr '[:upper:]' '[:lower:]')"
  case "$low" in
    on)
      optify_cmd_on
      ;;
    off)
      optify_cmd_off
      ;;
    show)
      optify_show
      ;;
    before)
      optify_cmd_before
      ;;
    after)
      optify_cmd_after
      ;;
    clear-shots)
      optify_cmd_clear_shots
      ;;
    *)
      die "usage: optify on|off|show|before|after|clear-shots"
      ;;
  esac
}
