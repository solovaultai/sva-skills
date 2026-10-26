---
name: imagify
description: >-
  Imagify — print only the text in the newest scratch image, or in N
  images, so it can be pasted into another app. An embedded image in
  the agent message is the source on Cursor, Grok, Claude, and GitHub
  Copilot, and the image directive does not change that. Use when the user runs
  /imagify, imagify, <n>image, <n>images, image<n>, images<n>, text,
  totext, or 2text. No image directive means 1image. text, totext,
  2text, no other directive, or no directive at all means text mode.
  `imgfy` and `imageify` are aliases. The reply is that text, and
  that same text is copied to the clipboard. /imagify help (also --help,
  /?) prints the reference. /imagify tldr prints the short page.
argument-hint: "[1image|2images|image2|images2|text|totext|2text|help|tldr]"
user-invocable: true
---

# Imagify (= image text)

You are running **Imagify** (`/imagify`). Read images from the
standard ify scratch area and print only the text in them.

`imagify` with no slash is the same command. Canonical slash is
`/imagify`. `imgfy` and `imageify` are aliases of `imagify`. They
are not folders. `/imgfy` and `/imageify` run this same skill.
This is not `/image` and not `/imagine`.
Leave `.grok/image` unchanged. Do not answer a question about the
picture. Do not generate or edit an image.

The chat reply for a transcription is the transcribed text and
nothing else. No narrative, no acknowledgment, no heading, no
fence, and no description of the picture.

## Optify

Cite the optify skill's `references/optify_contract.md`. Optify is
on unless `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env`
contains `enabled=off`. A missing file or a missing `enabled` key
is on. Only `enabled=off` is off. Reading that env file is enough
to decide. On or off, the reply is still only the transcribed text.
Do not print Intent, Workspace, an optimized prompt, or scores.

## Parse

Typed line only. File bodies are not scanned. Whole tokens,
case-insensitive.

1. **Image directive.** The first match sets N. A later image
   directive does not change N.
   - `<n>image` or `<n>images`, one token, optional hyphen:
     `2image`, `2images`, `2-image`, `2-images`. N is that integer.
   - Two tokens: `<n>` then `image` or `images` (`2 image`,
     `2 images`). N is that integer. Those two tokens are one
     directive.
   - `image<n>` or `images<n>`, glued: `image2`, `images2`.
     N is that integer.
   - Blank n: the whole token `image` or `images`. N is 1.
   - N is an integer from 1 up. When the source is scratch,
     `0image`, `0images`, `image0`, and `images0` are **Error**
     before any read. The only line is `Error: image count starts at 1`.
     When embedded agent images are the source, the count is
     not used and this is not an error.
   - No image directive: N is 1. That is `1image`.
   - `image 2` is blank n (N is 1). The `2` is not part of the
     directive. Use `image2` for N = 2.
2. **Text directive.** Whole token `text`, `totext`, or `2text`.
   Any one of them selects text mode. Text mode is also selected
   when the line has no directive other than an image directive,
   and when the line has no directive at all. Imagify has no
   other mode. Other words are not a mode and are not printed.
3. **Help, tldr, pass.** After the image directive, the text
   directive, an `Npass` / `N-pass` / `N pass` token, and an
   `img=` / `img:` token are removed, the remaining body:
   - exactly `help`, `--help`, or `/?`: print `references/HELP.md`
     and stop.
   - exactly `tldr`: print `references/TLDR.md` and stop.
   - exactly `pass` or `pass help`: print the **Pass (`Npass`)**
     section of `references/HELP.md` and stop.
   These do not read an image and do not retitle.
   `help me` is not help. Empty `/imagify` is a real
   transcription (1image, text mode), not help and not short usage.
4. **`img=`.** On a transcription line, `img=<file>`, `img:<file>`,
   `img=[a,b]`, and `img:[a,b]` are **Error** before any read.
   The only line is `Error: imagify reads the newest N scratch images`.
   Cite promptify **Named images** for the token shape. Do not
   read those files. Do not fork a second `img` grammar.
5. **`Npass`.** Strip it. Imagify does not take passes. One
   transcription.

## Images

On Cursor, Grok, Claude, and GitHub Copilot, an image embedded in
the current agent message is the source. Use every one of them, in
the order they appear on that message. The image directive does not
change the source and does not change the count. `1image`,
`2images`, `image2`, a blank n, a missing directive, and `0image`
do not select scratch and do not drop or add images. Do not run
`scratch ls`. Do not read workspace `scratch/`.

An image from an earlier turn is not this message. An open editor
tab is not an embedded image. No embedded image on this message:
use the scratch rule below.

Cite promptify **Scratch images** for that scratch rule.
Do not fork a second scratch area. Do not print the scratch
acknowledgment.

N is the count from the image directive, or 1. N applies only
when the source is scratch.

1. If the scratch source config exists, run
   `scripts/cli.sh scratch ls N` from the sva-skills repo
   (or `scripts/cli.ps1 scratch ls N`). Read those paths.
   Config: `~/.local/share/sva-skills/scratch.env`
   (Windows: `%LOCALAPPDATA%\sva-skills\scratch.env`).
2. Else workspace `scratch/` at the repo root. Do not create it.
   Image files `png`, `jpg`, `jpeg`, `webp`, `gif`, `bmp`, newest
   mtime first, take N (or all if fewer).
3. Read every resolved image. Do not invent pixels or text.

No file: the only line is `Error: no image`. Do not retitle.
Fewer than N files: transcribe the files that exist. Do not say
how many were missing.

## Text

Text mode converts the text in the image to text the user can
paste into another app.

- Reading order within one image: top to bottom, then left to
  right. Keep the line breaks the image shows.
- Do not correct spelling. Do not translate. Do not summarize.
- Do not describe pictures, icons, layout, or colors.
- Do not add a title, a label, a fence, or a blank explanation.
- Include the words that are visible, including short labels.
- Several scratch images: newest first. Several embedded agent
  images: the order on the message. One blank line
  between the text of one image and the next. No "Image 1" label.
- An image with no readable text contributes nothing. If every
  image has no text, the reply is empty.
- The reply is that text and nothing else.

## Clipboard

After a transcription, copy the same text that is printed. Do not
print that it was copied. Do not add a heading. Help, tldr, pass,
and an error line are not copied. An empty transcription is not
copied.

Write the text with no extra newline. Use the first tool that
applies:

1. `WAYLAND_DISPLAY` is set and `wl-copy` is on `PATH`:
   `printf '%s' "$text" | wl-copy`
2. `DISPLAY` is set and `xclip` is on `PATH`:
   `printf '%s' "$text" | xclip -selection clipboard`
3. `xsel` is on `PATH`:
   `printf '%s' "$text" | xsel --clipboard --input`
4. Windows PowerShell: `Set-Clipboard -Value $text`
5. macOS: `printf '%s' "$text" | pbcopy`

If none of those is available, still print only the text.

## From files

Cite `docs/from_contract.md`. A `from=` / `from:` splice does not
change the reply. The reply is still only the transcribed text.
Help, tldr, and pass do not read files. Empty `/imagify` still
transcribes.

## Docify

Cite the docify skill's `references/docify_contract.md`. A
typed-line `docify` / `docpathify` writes the transcribed text.
The chat reply stays that text only. Do not add the wrote line.
Help, tldr, and pass do not write. Empty `/imagify` still
transcribes.

## Window title

Cite `docs/window_title.md`. Prefix `IMG:`. Summary is three to
six words. Whole name at most 48 characters. Set the tmux window
name only when `TMUX` is set.

Help, tldr, pass, and `Error: no image` do not retitle. Empty
`/imagify` does. A transcription does.

## Hard rules

- The transcription reply is the text in the image and nothing else.
- No image directive means `1image`.
- Blank n on `image` or `images` means 1.
- `text`, `totext`, `2text`, no directive other than an image
  directive, or no directive at all means text mode.
- On Cursor, Grok, Claude, and GitHub Copilot, an image embedded
  in the current agent message is the source. The image directive
  does not change that.
- `0image` and `image0` are **Error** before any read when the
  source is scratch. They are not an error when embedded agent
  images are the source.
- `img=` on a transcription line is **Error** before any read.
- Do not print the scratch acknowledgment.
- Empty `/imagify` with no embedded agent image transcribes
  the newest scratch image.
- After a transcription, copy that same text to the clipboard.
  Do not mention the copy.
- `imgfy` and `imageify` are aliases of `imagify`. They are not
  folders.
