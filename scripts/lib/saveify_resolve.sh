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
ls: newest first. Empty store prints nothing. Does not require --yes.
  <n>  <saved_at>  <display_name>  <verb>, <phases> Phases, <stage>, <blocks> Blocks, <defers> Defers, <cwd>
  then a tab, then the slug. 1 is the newest. Show the row; map # via the slug.
  Counts come from table.txt (phase_layout box or a markdown phase table).
  No table.txt: 0 Phases, 0 Blocks, 0 Defers. A directory with no meta.json is not a row.
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
import re
import sys

root = sys.argv[1]
if not os.path.isdir(root) or os.path.islink(root):
    sys.exit(0)

WORK_RE = re.compile(r"(?i)^(?:P\d+|Phase\s+\d+)\b")
BLOCKED = {"blocked", "def-blocked"}
DEFERRED = {"deferred", "def-blocked"}


def field(data, key):
    val = data.get(key, "")
    if val is None:
        return ""
    if not isinstance(val, str):
        val = str(val)
    return val.replace("\t", " ").replace("\r", "").replace("\n", " ")


def cells_of(line, sep):
    parts = line.split(sep)
    if len(parts) >= 2 and parts[0].strip() == "" and parts[-1].strip() == "":
        parts = parts[1:-1]
    return [p.strip() for p in parts]


def header_indexes(cells):
    lows = [c.lower() for c in cells]
    if "phase" not in lows or "status" not in lows:
        return None
    return lows.index("phase"), lows.index("status")


def is_rule(cells):
    if not cells:
        return False
    return all(re.fullmatch(r":?-{1,}:?", c.replace(" ", "")) for c in cells if c != "")


def parse_box(text):
    rows = []
    found = False
    phase_i = status_i = None
    for line in text.splitlines():
        if "\u2502" not in line:
            continue
        cells = cells_of(line, "\u2502")
        if phase_i is None:
            idx = header_indexes(cells)
            if idx is None:
                continue
            phase_i, status_i = idx
            found = True
            continue
        if len(cells) <= max(phase_i, status_i):
            continue
        phase = cells[phase_i]
        if not phase:
            continue
        rows.append((phase, cells[status_i]))
    return rows, found


def parse_md(text):
    rows = []
    found = False
    phase_i = status_i = None
    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("|"):
            if found and stripped:
                break
            continue
        cells = cells_of(stripped, "|")
        if phase_i is None:
            idx = header_indexes(cells)
            if idx is None:
                continue
            phase_i, status_i = idx
            found = True
            continue
        if is_rule(cells):
            continue
        if len(cells) <= max(phase_i, status_i):
            continue
        phase = cells[phase_i]
        if not phase:
            continue
        rows.append((phase, cells[status_i]))
    return rows, found


def norm_status(status):
    text = status.replace("\u2013", "-").replace("\u2014", "-")
    return " ".join(text.split()).strip().lower()


def phase_counts(directory):
    path = os.path.join(directory, "table.txt")
    if os.path.islink(path) or not os.path.isfile(path):
        return 0, 0, 0
    try:
        with open(path, encoding="utf-8-sig") as fh:
            text = fh.read()
    except (OSError, UnicodeError):
        return 0, 0, 0
    rows, found = parse_box(text)
    if not found:
        rows, found = parse_md(text)
    if not found:
        return 0, 0, 0
    phases = blocks = defers = 0
    for phase, status in rows:
        if WORK_RE.match(phase.strip()) is None:
            continue
        phases += 1
        st = norm_status(status)
        if st in BLOCKED:
            blocks += 1
        if st in DEFERRED:
            defers += 1
    return phases, blocks, defers


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
    phases, blocks, defers = phase_counts(d)
    rows.append((
        field(data, "saved_at"),
        name,
        field(data, "display_name"),
        field(data, "verb"),
        field(data, "stage"),
        field(data, "cwd"),
        phases,
        blocks,
        defers,
    ))

rows.sort(key=lambda r: r[1])
rows.sort(key=lambda r: (r[0] != "", r[0]), reverse=True)
for i, row in enumerate(rows, 1):
    saved, slug, display, verb, stage, cwd, phases, blocks, defers = row
    printed = (
        "%d  %s  %s  %s, %d Phases, %s, %d Blocks, %d Defers, %s"
        % (i, saved, display, verb, phases, stage, blocks, defers, cwd)
    )
    sys.stdout.write("%s\t%s\n" % (printed, slug))
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
