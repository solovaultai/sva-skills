#!/usr/bin/env bash
# sva-skills saveify store — dir, ls, resolve, rm.
# Source-only. Requires die().
#
# Store: ${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/saveify/<slug>/
# See docs/saveify_contract.md. Do not create the store for dir or ls.

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  echo "error: source scripts/lib/saveify_resolve.sh — do not execute it." >&2
  exit 1
fi

# Lexical absolute path. Does not create anything and does not resolve symlinks.
saveify_abspath() {
  local path="$1"
  if [[ "$path" != /* ]]; then
    path="${PWD}/${path}"
  fi
  local -a stack=()
  local rest="${path#/}" part
  while [[ -n "$rest" ]]; do
    part="${rest%%/*}"
    if [[ "$rest" == */* ]]; then
      rest="${rest#*/}"
    else
      rest=""
    fi
    case "$part" in
      "" | ".") ;;
      "..")
        if ((${#stack[@]})); then
          unset 'stack[${#stack[@]}-1]'
        fi
        ;;
      *) stack+=("$part") ;;
    esac
  done
  if ((${#stack[@]} == 0)); then
    printf '%s' "/"
    return 0
  fi
  local out="" s
  for s in "${stack[@]}"; do
    out+="/${s}"
  done
  printf '%s' "$out"
}

saveify_store_root() {
  local base="${XDG_DATA_HOME:-$HOME/.local/share}"
  saveify_abspath "${base}/sva-skills/saveify"
}

saveify_error() {
  echo "**Error:** $*" >&2
  exit 1
}

# One path segment. Not a flag, not '.' or '..'.
saveify_slug_ok() {
  local s="$1"
  [[ -n "$s" ]] || return 1
  [[ "$s" != *"/"* && "$s" != *"\\"* ]] || return 1
  [[ "$s" != "." && "$s" != ".." ]] || return 1
  [[ "$s" != -* ]] || return 1
  [[ "$s" != *$'\n'* && "$s" != *$'\r'* && "$s" != *$'\t'* ]] || return 1
  return 0
}

# Print the snapshot directory, or return 1. Does not create the store.
saveify_snapshot_path() {
  local slug="$1"
  local root dir
  saveify_slug_ok "$slug" || return 1
  root="$(saveify_store_root)"
  dir="$(saveify_abspath "${root}/${slug}")"
  [[ "$dir" == "${root}/"* ]] || return 1
  [[ -d "$dir" && ! -L "$dir" ]] || return 1
  [[ -f "$dir/meta.json" && ! -L "$dir/meta.json" ]] || return 1
  printf '%s' "$dir"
}

saveify_usage() {
  cat <<EOF
Usage:
  ./scripts/cli.sh saveify dir
  ./scripts/cli.sh saveify ls
  ./scripts/cli.sh saveify resolve <slug>
  ./scripts/cli.sh saveify rm <slug> --yes

Store: $(saveify_store_root)
ls: newest first. Empty store prints nothing.
  <n> <saved_at> <slug> <display_name> <verb> <stage> <cwd>
  tab-separated. 1 is the newest. A directory with no meta.json is not a row.
resolve prints that slug's directory. It takes a slug, not a list number
or a display name.
rm deletes that slug only when --yes is present. It does not prompt.
EOF
}

saveify_cmd_dir() {
  [[ $# -eq 0 ]] || die "usage: saveify dir"
  printf '%s\n' "$(saveify_store_root)"
}

saveify_cmd_ls() {
  [[ $# -eq 0 ]] || die "usage: saveify ls"
  command -v python3 >/dev/null 2>&1 || die "python3 is required to list saveify snapshots"
  local root
  root="$(saveify_store_root)"
  python3 - "$root" <<'PY'
import json
import os
import sys

root = sys.argv[1]
if not os.path.isdir(root) or os.path.islink(root):
    sys.exit(0)

def field(data, key):
    val = data.get(key, "")
    if val is None:
        return ""
    if not isinstance(val, str):
        val = str(val)
    return val.replace("\t", " ").replace("\r", "").replace("\n", " ")

rows = []
try:
    names = os.listdir(root)
except OSError:
    sys.exit(0)
for name in names:
    if name in (".", "..") or "/" in name or "\\" in name:
        continue
    if "\n" in name or "\r" in name or "\t" in name:
        continue
    d = os.path.join(root, name)
    if os.path.islink(d) or not os.path.isdir(d):
        continue
    meta_path = os.path.join(d, "meta.json")
    if os.path.islink(meta_path) or not os.path.isfile(meta_path):
        continue
    try:
        with open(meta_path, encoding="utf-8-sig") as fh:
            data = json.load(fh)
    except (OSError, ValueError, UnicodeError):
        continue
    if not isinstance(data, dict):
        continue
    rows.append((
        field(data, "saved_at"),
        name,
        field(data, "display_name"),
        field(data, "verb"),
        field(data, "stage"),
        field(data, "cwd"),
    ))

rows.sort(key=lambda r: r[1])
rows.sort(key=lambda r: (r[0] != "", r[0]), reverse=True)
for i, row in enumerate(rows, 1):
    saved, slug, display, verb, stage, cwd = row
    sys.stdout.write(
        "%d\t%s\t%s\t%s\t%s\t%s\t%s\n" % (i, saved, slug, display, verb, stage, cwd)
    )
PY
}

saveify_cmd_resolve() {
  [[ $# -eq 1 && -n "${1:-}" ]] || die "usage: saveify resolve <slug>"
  local dir
  if ! dir="$(saveify_snapshot_path "$1")"; then
    saveify_error "not found: $1"
  fi
  printf '%s\n' "$dir"
}

saveify_cmd_rm() {
  local yes=0 slug="" arg dir
  for arg in "$@"; do
    if [[ "$arg" == "--yes" ]]; then
      yes=1
      continue
    fi
    if [[ -n "$slug" ]]; then
      die "usage: saveify rm <slug> --yes"
    fi
    slug="$arg"
  done
  [[ -n "$slug" ]] || die "usage: saveify rm <slug> --yes"
  if ! dir="$(saveify_snapshot_path "$slug")"; then
    saveify_error "not found: $slug"
  fi
  if [[ "$yes" -ne 1 ]]; then
    saveify_error "--yes required"
  fi
  rm -rf -- "$dir"
}

saveify_cmd() {
  local sub="${1:-}"
  shift || true
  case "$sub" in
    "" | -h | --help | help)
      saveify_usage
      ;;
    dir)
      saveify_cmd_dir "$@"
      ;;
    ls)
      saveify_cmd_ls "$@"
      ;;
    resolve)
      saveify_cmd_resolve "$@"
      ;;
    rm)
      saveify_cmd_rm "$@"
      ;;
    *)
      die "unknown saveify command: ${sub} (try: dir, ls, resolve, rm)"
      ;;
  esac
}
