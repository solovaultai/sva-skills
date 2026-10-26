#!/usr/bin/env bash
# imagify — print only the text in the selected scratch images, then copy
# that same text to the clipboard. Mirrors the /imagify ify skill.
#
# Directives (whole tokens, case-insensitive, typed line only).
# Every numbered image directive counts. Union, each path once,
# newest mtime first. Positive N is the N newest. Negative -K is
# exactly one file, |K| steps back from the newest (-1 is the second
# newest). scratch ls is always called with a positive M.
#   <n>image <n>images <n>-image <n>-images   N newest     (2images)
#   -<k>image -<k>images -<k>-image -<k>-images   one offset (-3image)
#   <n> image | -<k> image (two tokens)       same         (2 images, -3 image)
#   image<n> images<n>                        N newest     (image2)
#   image-<k> images-<k>                      one offset   (image-3)
#   image | images                            blank n = 1  (image -3 is still 1)
#   0image image0 -0image                     Error: image count starts at 1
#   text | totext | 2text                     text mode (the default, only mode)
#   help | --help | /?                        print references/HELP.md and stop
#   tldr                                      print references/TLDR.md and stop
#   pass | pass help                          print the Pass (Npass) section and stop
#   Npass / N-pass / N pass                   stripped, no effect (first numbered only)
#   img=... img:...                           Error: imagify reads the newest N scratch images
#   from=... from:...  docify  docpathify     stripped, do not change the reply
#
# Env:
#   IMAGIFY_OCR=tesseract|claude   OCR engine (default tesseract)
#   IMAGIFY_LANG=eng               tesseract language(s), e.g. eng+heb
#   SVA_SKILLS_ROOT                sva-skills repo (for scripts/cli.sh scratch ls N)
#   IMAGIFY_NO_CLIP=1              do not touch the clipboard
set -u

SKILL_DIR="${HOME}/.claude/skills/imagify"
SVA_ROOT="${SVA_SKILLS_ROOT:-${HOME}/src/sva/sva-skills}"
XDG="${XDG_DATA_HOME:-${HOME}/.local/share}"
SCRATCH_ENV="${XDG}/sva-skills/scratch.env"
OCR="${IMAGIFY_OCR:-tesseract}"
LANG_OCR="${IMAGIFY_LANG:-eng}"

err() { printf '%s\n' "$1"; exit 1; }

ref_file() {
  local name="$1" p
  for p in "${SKILL_DIR}/references/${name}" "${SVA_ROOT}/.claude/skills/imagify/references/${name}"; do
    [ -f "$p" ] && { printf '%s' "$p"; return 0; }
  done
  return 1
}

print_help() { local f; f="$(ref_file HELP.md)" || err "Error: HELP.md not found"; cat "$f"; }
print_tldr() { local f; f="$(ref_file TLDR.md)" || err "Error: TLDR.md not found"; cat "$f"; }
print_pass() {
  local f; f="$(ref_file HELP.md)" || err "Error: HELP.md not found"
  awk '/^## Pass \(`Npass`\)/{p=1; print; next} p && /^## /{exit} p' "$f"
}

# ---------- parse ----------
# SEL holds signed selectors. Positive N = indexes 0..N-1.
# Negative -K = index K only. Zero sets ZERO and is not stored.
SEL=()
ZERO=0          # 0image / -0image seen
IMG_ERR=0       # img= seen
REST=()         # tokens left after directives are removed

add_sel() {  # $1 signed integer text (3, -3, 0, -0)
  local raw="$1" sign=1 digits n
  if [[ "$raw" == -* ]]; then sign=-1; digits="${raw#-}"; else digits="$raw"; fi
  [[ "$digits" =~ ^[0-9]+$ ]] || return 1
  n=$((10#$digits))
  if [ "$n" -eq 0 ]; then ZERO=1; return 0; fi
  if [ "$sign" -lt 0 ]; then SEL+=("-$n"); else SEL+=("$n"); fi
}

tokens=("$@")
i=0
while [ $i -lt ${#tokens[@]} ]; do
  t="${tokens[$i]}"; lc="${t,,}"
  case "$lc" in
    img=*|img:*) IMG_ERR=1; i=$((i+1)); continue ;;
    from=*|from:*|docify|docpathify) i=$((i+1)); continue ;;
    text|totext|2text) i=$((i+1)); continue ;;              # text mode is the only mode
    [0-9]*pass|[0-9]*-pass) i=$((i+1)); continue ;;        # Npass stripped (first numbered only; no effect)
  esac
  # N pass (two tokens). A leading minus is not Npass.
  if [[ "$lc" =~ ^[0-9]+$ ]] && [ $((i+1)) -lt ${#tokens[@]} ] && [ "${tokens[$((i+1))],,}" = "pass" ]; then
    i=$((i+2)); continue
  fi
  # Every numbered image directive counts (union later).
  if [[ "$lc" =~ ^(-?[0-9]+)-?images?$ ]]; then            # 2images -3image -3-images
    add_sel "${BASH_REMATCH[1]}"
    i=$((i+1)); continue
  fi
  if [[ "$lc" =~ ^images?(-?[0-9]+)$ ]]; then              # image2 image-3 images-3
    add_sel "${BASH_REMATCH[1]}"
    i=$((i+1)); continue
  fi
  if [[ "$lc" =~ ^-?[0-9]+$ ]] && [ $((i+1)) -lt ${#tokens[@]} ]; then
    nx="${tokens[$((i+1))],,}"
    if [ "$nx" = "image" ] || [ "$nx" = "images" ]; then   # 2 images, -3 image
      add_sel "$lc"
      i=$((i+2)); continue
    fi
  fi
  if [[ "$lc" =~ ^images?$ ]]; then                        # image / images: blank n = 1
    add_sel 1                                              # "image -3" stays 1; -3 is not this directive
    i=$((i+1)); continue
  fi
  REST+=("$t"); i=$((i+1))
done

body="${REST[*]:-}"; body="${body,,}"
case "$body" in
  help|--help|/\?) print_help; exit 0 ;;
  tldr)            print_tldr; exit 0 ;;
  pass|"pass help") print_pass; exit 0 ;;
esac

[ "$IMG_ERR" -eq 1 ] && err "Error: imagify reads the newest N scratch images"
[ "$ZERO" -eq 1 ]    && err "Error: image count starts at 1"
[ ${#SEL[@]} -eq 0 ] && SEL=(1)

# Positive M = max(positive counts, |negative|+1). Never pass a negative to scratch ls.
M=0
for s in "${SEL[@]}"; do
  if [ "$s" -gt 0 ]; then
    [ "$s" -gt "$M" ] && M=$s
  else
    need=$(( ${s#-} + 1 ))
    [ "$need" -gt "$M" ] && M=$need
  fi
done
[ "$M" -ge 1 ] || err "Error: image count starts at 1"

# ---------- resolve images ----------
listed=()
list_dir_newest() {  # $1 dir, $2 positive M
  find "$1" -maxdepth 1 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
       -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.bmp' \) -printf '%T@\t%p\0' 2>/dev/null \
    | sort -z -t$'\t' -k1,1 -g -r | head -z -n "$2" | cut -z -f2- | tr '\0' '\n'
}

if [ -f "$SCRATCH_ENV" ]; then
  if [ -x "${SVA_ROOT}/scripts/cli.sh" ]; then
    mapfile -t listed < <("${SVA_ROOT}/scripts/cli.sh" scratch ls "$M" 2>/dev/null)
  fi
  if [ ${#listed[@]} -eq 0 ]; then
    # fallback: read the local folder straight from scratch.env
    dir="$(sed -n 's/^SCRATCH_DIR=//p' "$SCRATCH_ENV" | head -1 | sed 's/^"\(.*\)"$/\1/')"
    dir="${dir/#\~/$HOME}"
    [ -n "$dir" ] && [ -d "$dir" ] && mapfile -t listed < <(list_dir_newest "$dir" "$M")
  fi
fi
if [ ${#listed[@]} -eq 0 ]; then
  root="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
  [ -d "${root}/scratch" ] && mapfile -t listed < <(list_dir_newest "${root}/scratch" "$M")
fi
# drop blanks / missing, keep newest-first order
clean=()
if [ ${#listed[@]} -gt 0 ]; then
  for f in "${listed[@]}"; do [ -n "$f" ] && [ -f "$f" ] && clean+=("$f"); done
fi

# Slice. Positive N keeps indexes 0..N-1. Negative -K keeps index K.
# An offset past the end adds no file. Dedupe by path. Newest mtime first.
declare -A want=()
for s in "${SEL[@]}"; do
  if [ "$s" -gt 0 ]; then
    i=0
    while [ "$i" -lt "$s" ]; do want[$i]=1; i=$((i+1)); done
  else
    want[${s#-}]=1
  fi
done
files=()
declare -A seen=()
i=0
while [ "$i" -lt ${#clean[@]} ]; do
  if [ -n "${want[$i]:-}" ]; then
    f="${clean[$i]}"
    if [ -z "${seen[$f]:-}" ]; then seen[$f]=1; files+=("$f"); fi
  fi
  i=$((i+1))
done
[ ${#files[@]} -eq 0 ] && err "Error: no image"

# ---------- OCR ----------
ocr_one() {
  case "$OCR" in
    claude)
      if command -v claude >/dev/null 2>&1; then
        # Vision transcription through Claude Code print mode; only the Read tool is allowed.
        claude -p --allowedTools Read \
          "Read the image file at '$1'. Reply with only the text visible in the image, keeping its line breaks, top to bottom then left to right. Do not correct spelling, translate, summarize, or describe the picture. No commentary, no fences, no labels. If there is no readable text, reply with nothing." 2>/dev/null
      else
        tesseract "$1" - -l "$LANG_OCR" 2>/dev/null
      fi
      ;;
    *)
      command -v tesseract >/dev/null 2>&1 || err "Error: tesseract not installed"
      tesseract "$1" - -l "$LANG_OCR" 2>/dev/null
      ;;
  esac
}

out=""
for f in "${files[@]}"; do
  t="$(ocr_one "$f" | sed -e 's/[[:space:]]*$//' | sed -e '/./,$!d')"   # trim trailing ws, leading blank lines
  [ -z "$t" ] && continue
  if [ -z "$out" ]; then out="$t"; else out="${out}"$'\n\n'"${t}"; fi
done

[ -n "$out" ] && printf '%s\n' "$out"

# ---------- clipboard ----------
if [ -n "$out" ] && [ -z "${IMAGIFY_NO_CLIP:-}" ]; then
  if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
    printf '%s' "$out" | wl-copy
  elif [ -n "${DISPLAY:-}" ] && command -v xclip >/dev/null 2>&1; then
    printf '%s' "$out" | xclip -selection clipboard
  elif command -v xsel >/dev/null 2>&1; then
    printf '%s' "$out" | xsel --clipboard --input
  elif command -v pbcopy >/dev/null 2>&1; then
    printf '%s' "$out" | pbcopy
  fi
fi

# ---------- tmux window title (docs/window_title.md: IMG: prefix, <=48 chars) ----------
if [ -n "${TMUX:-}" ]; then
  summary="$(printf '%s' "$out" | tr -s '[:space:]' ' ' | awk '{for(i=1;i<=NF&&i<=6;i++) printf "%s%s",(i>1?" ":""),$i}')"
  [ -z "$summary" ] && summary="image text"
  name="IMG: ${summary}"
  while [ ${#name} -gt 48 ] && [ "${name%% *}" != "$name" ]; do name="${name% *}"; done
  name="${name:0:48}"
  tmux rename-window "$name" 2>/dev/null || true
fi
exit 0
