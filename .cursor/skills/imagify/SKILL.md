---
name: imagify
description: >-
  Imagify — print only the text in the scratch images the directive
  selects (N newest, one file a negative offset back, or their union),
  or show those images. An embedded image in the agent message is the
  source for text mode on Cursor, Grok, Claude, and GitHub Copilot, and
  the image directive does not change that. `show` always uses scratch.
  Use when the user runs /imagify, imagify, imageify, show, <n>image,
  <n>images, image<n>, images<n>, text, totext, or 2text. No image
  directive means 1image. text, totext, 2text, no other directive, or
  no directive at all means text mode. `show N` displays the N newest.
  `show -K` displays one image K back. `show 1,3` displays the newest
  and the image 3 back. `show details` lists name, date, and size for
  the 10 newest. `imgfy` and `imageify` are aliases. Text mode replies
  with that text and copies it to the clipboard. /imagify help (also
  --help, /?) prints the reference. /imagify tldr prints the short page.
---

# Imagify (= image text)

You are running **Imagify** (`/imagify`). Read images from the
standard ify scratch area and print only the text in them, or
`show` those images.

`imagify` with no slash is the same command. Canonical slash is
`/imagify`. `imgfy` and `imageify` are aliases of `imagify`. They
are not folders. `/imgfy` and `/imageify` run this same skill.
This is not `/image` and not `/imagine`.
Leave `.grok/image` unchanged. Do not answer a question about the
picture. Do not generate or edit an image.

The chat reply for a transcription is the transcribed text and
nothing else. No narrative, no acknowledgment, no heading, no
fence, and no description of the picture. `show` is not a
transcription. Its reply is the images, or the details listing.

## Optify

Cite the optify skill's `references/optify_contract.md`. Optify is
on unless `${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/optify.env`
contains `enabled=off`. A missing file or a missing `enabled` key
is on. Only `enabled=off` is off. Reading that env file is enough
to decide. On or off, the reply is still only that output (the
transcribed text, the images, or the details listing).
Do not print Intent, Workspace, an optimized prompt, or scores.

## Parse

Typed line only. File bodies are not scanned. Whole tokens,
case-insensitive.

1. **Image directives.** Every numbered image directive counts.
   A later directive is included. The selected files are the
   union, each path once, newest mtime first.
   - Positive `<n>image` or `<n>images`, one token, optional hyphen:
     `2image`, `2images`, `2-image`, `2-images`. That directive is
     the N newest.
   - Negative, same shapes plus a leading minus: `-3image`,
     `-3images`, `-3-image`, `-3-images`. Exactly one file, `|K|`
     steps back from the newest. `-1` is the second newest.
   - Two tokens: `<n>` or `-<k>` then `image` or `images`
     (`2 image`, `-3 image`, `-3 images`). Those two tokens are
     one directive.
   - Glued suffix: `image<n>`, `images<n>`, `image-<k>`,
     `images-<k>` (`image2`, `images2`, `image-3`, `images-3`).
     A hyphenated suffix is the negative offset.
   - Blank n: the whole token `image` or `images`. That directive
     is 1 (the newest). `image -3` and `image 2` stay blank n.
     The following number is not part of that directive.
   - Zero is never a count. When the source is scratch,
     `0image`, `0images`, `image0`, `images0`, and `-0image` are
     **Error** before any read. The only line is
     `Error: image count starts at 1`. When embedded agent images
     are the source, the count is not used and this is not an error.
   - No image directive: one image, the newest. That is `1image`.
   - Overlaps are one file. `1image -3image` is the newest plus
     the file three back. An offset past the end adds no file.
     Do not invent a path. If the union is empty, the only line
     is `Error: no image`.
2. **Show directive.** Whole token `show`. It selects show mode.
   Show is not text mode. When both `show` and `text` appear,
   show wins. The selector is the tokens after `show`:
   - `details` — metadata for the 10 newest. No pixels. A
     selector on that line (`show details 2`, `show details
     2images`) is **Error** before any read:
     `Error: show details takes no selector`.
   - One positive `N` (`show 2`) — the N newest.
   - One negative `-K` (`show -2`) — one file, index `|K|`.
   - A comma list or several numbers (`show 1,3`, `show 1 -3`).
     The first positive number is how many newest to include.
     Each later number is one file that many steps back. The
     index is the absolute value, so `3` and `-3` are the same
     slot. `show 1,3` is the newest and the image 3 back.
   - No selector and no image directive — the newest (`show 1`).
   - Image directives on the same line still count and union
     with that selector (`show 2images`, `show 1image -3image`).
   Zero (`show 0`, `show 1,0`) is **Error** before any read:
   `Error: image count starts at 1`. Show always reads scratch.
   An embedded agent image is not this list.
3. **Text directive.** Whole token `text`, `totext`, or `2text`.
   Any one of them selects text mode when `show` is absent.
   Text mode is also selected when the line has no directive
   other than an image directive, and when the line has no
   directive at all. Other words are not a mode and are not
   printed.
4. **Help, tldr, pass.** After the image directive, the show
   directive and its selector, the text directive, an `Npass` /
   `N-pass` / `N pass` token, and an `img=` / `img:` token are
   removed, the remaining body:
   - exactly `help`, `--help`, or `/?`: print `references/HELP.md`
     and stop.
   - exactly `tldr`: print `references/TLDR.md` and stop.
   - exactly `pass` or `pass help`: print the **Pass (`Npass`)**
     section of `references/HELP.md` and stop.
   These do not read an image and do not retitle.
   `help me` is not help. Empty `/imagify` is a real
   transcription (1image, text mode), not help and not short usage.
5. **`img=`.** On a transcription or a show line, `img=<file>`, `img:<file>`,
   `img=[a,b]`, and `img:[a,b]` are **Error** before any read.
   The only line is `Error: imagify reads the newest N scratch images`.
   Cite promptify **Named images** for the token shape. Do not
   read those files. Do not fork a second `img` grammar.
6. **`Npass`.** Strip it. Imagify does not take passes. One
   transcription, or one show.

## Images

Text mode on Cursor, Grok, Claude, and GitHub Copilot uses an image
embedded in the current agent message as the source. Use every one
of them, in the order they appear on that message. The image
directive does not change the source and does not change the count.
Negatives and unions apply only when the source is scratch or
workspace `scratch/`. `1image`, `-3image`, `image-3`, `2images`, a
blank n, a missing directive, and `0image` do not select scratch
and do not drop or add images. Do not run `scratch ls`. Do not
read workspace `scratch/`.

`show` does not use that embedded image. It always reads scratch
(or workspace `scratch/` when scratch is unset). The selector
picks files from that list.

An image from an earlier turn is not this message. An open editor
tab is not an embedded image. No embedded image on this message:
use the scratch rule below.

Cite promptify **Scratch images** for that scratch rule.
Do not fork a second scratch area. Do not print the scratch
acknowledgment.

Selectors apply only when the source is scratch. Positive N is
the N newest. Negative `-K` is index `|K|` (one file, `|K|` steps
back from the newest). Every numbered directive counts. Union,
each path once, newest mtime first. Do not pass a negative to
`scratch ls`. List once with positive `M` = the largest of the
positive counts and of `|negative| + 1`, then slice.
`1image -3image` calls `scratch ls 4` and keeps index 0 and
index 3. An offset past the end adds no file. Do not invent a
path.

1. If the scratch source config exists, run
   `scripts/cli.sh scratch ls M` from the sva-skills repo
   (or `scripts/cli.ps1 scratch ls M`). Read the sliced paths.
   Config: `~/.local/share/sva-skills/scratch.env`
   (Windows: `%LOCALAPPDATA%\sva-skills\scratch.env`).
2. Else workspace `scratch/` at the repo root. Do not create it.
   Image files `png`, `jpg`, `jpeg`, `webp`, `gif`, `bmp`, newest
   mtime first, take M (or all if fewer), then slice.
3. Read every resolved image. Do not invent pixels or text.

No file, or an offset past the end that leaves the union empty:
the only line is `Error: no image`. Do not retitle.
Fewer files than a positive count: transcribe the files that exist.
Do not say how many were missing. An offset past the end adds no file.

## Show

Display the selected scratch images. Newest mtime first. With
newest-first `e.jpg`, `d.jpg`, `c.jpg`, `b.jpg`, `a.jpg`:

| Command | What the user sees |
|---------|--------------------|
| `show 2` | The two newest: `e.jpg`, then `d.jpg` |
| `show -2` | One file, index 2: `c.jpg` |
| `show 1,3` | The newest and the image 3 back: `e.jpg`, then `b.jpg` |
| `show details` | The 10 newest: index, name, date, size, path |

`show 2` is the first two of that descending list. `d.jpg` is the
older of the two. `show 1,3` is the same pair as `1image` and
`-3image` (index 0 and index 3). `show 1 -3` is the same pair.

The show reply is those images and nothing else. One markdown
image per file, newest first, absolute path:

```markdown
![e.jpg](/absolute/path/e.jpg)
```

Read each file so the picture is visible. Do not transcribe. Do
not describe. Do not label. Do not copy the clipboard.

`show details` prints a listing and nothing else. Index 0 is the
newest. Columns are index, name, date, size, and path. Fewer than
10 files: list the ones that exist. No images. No clipboard.

An offset past the end adds no file. An empty selection is
`Error: no image`. Fewer files than a positive count: show the
files that exist. Do not say how many were missing.

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
show, show details, and an error line are not copied. An empty
transcription is not copied.

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
change the reply. Text mode is still only the transcribed text.
Show mode is still only the images or the details listing.
Help, tldr, and pass do not read files. Empty `/imagify` still
transcribes.

## Docify

Cite the docify skill's `references/docify_contract.md`. A
typed-line `docify` / `docpathify` writes the reply. Text mode
writes the transcribed text. Show mode writes the markdown
images. `show details` writes the listing. The chat reply stays
that output only. Do not add the wrote line. Help, tldr, and
pass do not write. Empty `/imagify` still transcribes.

## Window title

Cite `docs/window_title.md`. Prefix `IMG:`. Summary is three to
six words. Whole name at most 48 characters. Set the tmux window
name only when `TMUX` is set. Text mode uses words from the
transcription. Show mode uses words from the selector (`show 2
images`, `show image details`).

Help, tldr, pass, and `Error: no image` do not retitle. Empty
`/imagify` does. A transcription does. Show does.

## Hard rules

- The transcription reply is the text in the image and nothing else.
- `show` displays scratch images, newest first. `show 2` is the
  two newest. `show -K` is index `|K|`. `show 1,3` is the newest
  and the image 3 back. `show details` lists index, name, date,
  size, and path for the 10 newest. The show reply is that output
  and nothing else. Show does not use an embedded agent image.
- No image directive means `1image`. Text mode only.
- Blank n on `image` or `images` means 1. `image -3` stays that blank n. The `-3` is not part of that directive.
- `text`, `totext`, `2text`, no directive other than an image
  directive, or no directive at all means text mode.
- On Cursor, Grok, Claude, and GitHub Copilot, an image embedded
  in the current agent message is the source for text mode. The
  image directive does not drop or add those images. Negatives
  and unions apply only when the source is scratch or workspace
  `scratch/`. `show` always uses scratch.
- `0image`, `0images`, `image0`, `images0`, and `-0image` are
  **Error** before any read when the source is scratch:
  `Error: image count starts at 1`. They are not an error when
  embedded agent images are the source for text mode. `show 0`
  and `show 1,0` are that error, because show reads scratch.
- `img=` on a transcription or a show line is **Error** before any read.
- `show details` with a selector is **Error** before any read.
- Do not print the scratch acknowledgment.
- Empty `/imagify` with no embedded agent image transcribes
  the newest scratch image.
- After a transcription, copy that same text to the clipboard.
  Do not mention the copy.
- `imgfy` and `imageify` are aliases of `imagify`. They are not
  folders.
