# Imagify — user reference

Print this file as the response when the user runs `/imagify help`,
`/imagify --help`, or `/imagify /?`. Do not transcribe.
`/imagify tldr` prints the short page (`references/TLDR.md`), not
this file.

If the remaining body after the image directive, the text
directive, `Npass`, and `img=` are removed is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/imagify` is a real transcription, not this page and not
short usage. `help me …` is a transcription, not Help.

---

## What it does

Read images from the standard ify scratch area and print only the
text in them, so it can be pasted into another app. No narrative.
On Cursor, Grok, Claude, and GitHub Copilot, an image embedded in
the current agent message is the source. The image directive does
not change which images or how many.

This is not `/image` and not `/imagine`. `/image` answers a
question about the pictures. Imagify prints the text and nothing
else.

`imgfy` and `imageify` are aliases of `imagify`. They are not
folders. `/imgfy` and `/imageify` run this same command.

After a transcription, that same text is copied to the clipboard.
The reply does not say that it was copied. Help, tldr, pass, and
an error are not copied.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`). The reply is still only the transcribed text.

A typed-line `docify` / `docpathify` writes that text (see `the docify skill's references/docify_contract.md`). The chat reply stays that text only. Help, tldr, and pass do not write.

Window title prefix is `IMG:` (see `docs/window_title.md`).
Help, tldr, pass, and a missing image do not retitle. Empty
`/imagify` does.

```text
/imagify                 — text from the newest scratch image (1image), then copy it
/imgfy                   — alias of /imagify
/imageify                — alias of /imagify
/imagify 2images         — text from the 2 newest (<n>images)
/imagify 2image          — same count (<n>image)
/imagify 2 image         — same count, two tokens
/imagify 2-images        — same count, hyphen
/imagify image2          — same count, glued (image<n>)
/imagify images2         — same count, glued (images<n>)
/imagify image           — blank n, same as 1image
/imagify images          — blank n, same as 1image
/imagify -3image         — one file, 3 back from the newest
/imagify 1image -3image  — union: newest plus the file 3 back
/imagify image -3        — blank n, still the newest
/imagify text            — text mode (also the default)
/imagify totext          — text mode
/imagify 2text           — text mode
/imagify help            — this reference (also --help, /?)
/imagify tldr            — short form (stop)
/imagify pass            — Pass (Npass) subsection only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Transcribe the newest scratch image | No image directive means `1image`. No other directive means text |
| `<n>image` / `<n>images` / `-<k>image` | Positive N is the N newest. `-K` is one file, `|K|` back. One token, `<n>` then the word, or a hyphen (`2-images`, `-3-image`, `-3 image`) | Every numbered directive counts. Union, newest mtime first. N is never 0 |
| `image<n>` / `images<n>` / `image-<k>` | Glued suffix. `image2` is the 2 newest. `image-3` is the offset | `image 2` and `image -3` are blank n (1). The following number is not part of that directive |
| `image` / `images` | Blank n. That directive is the newest | Same as `1image`. `image -3` stays this |
| `text` / `totext` / `2text` | Text mode | Also the default when the line has no other directive, or no directive at all |
| Embedded agent image | Every image embedded in this message, in that order | Cursor, Grok, Claude, and GitHub Copilot. The directive does not drop or add those images. Negatives and unions apply only to scratch. No scratch read |
| `0image` / `image0` / `-0image` | **Error:** `Error: image count starts at 1` when the source is scratch | Before any read. Not an error when embedded agent images are the source |
| `img=` | **Error** on a transcription: `Error: imagify reads the newest N scratch images` | Newest N from the scratch area. Not a named file |
| `help` / `--help` / `/?` | Print this page and stop | No transcription |
| `tldr` | Print the short page and stop | Fast syntax |
| `pass` / `pass help` | Print the Pass subsection and stop | Imagify does not take Npass |

## Where the images come from

On Cursor, Grok, Claude, and GitHub Copilot, an image embedded in
the current agent message. Every one, in message order. The image
directive does not drop or add those images. Negatives and unions
apply only when the source is scratch or workspace `scratch/`.

Otherwise the standard ify scratch area. Cite promptify **Scratch images**.
Do not pass a negative to `scratch ls`. List once with positive `M`
= the largest of the positive counts and of `|negative| + 1`, then
slice. `1image -3image` calls `scripts/cli.sh scratch ls 4` and keeps
index 0 and index 3. Otherwise workspace `scratch/`, newest mtime
first, take M, then slice. Do not create that folder.

No scratch file, and no embedded agent image, and an empty union:
the only line is `Error: no image`. Fewer files than a positive count:
transcribe the ones that exist. An offset past the end adds no file.

## Text

The reply is the text in the image and nothing else. Keep the
line breaks. Do not correct spelling, translate, summarize, or
describe the picture. Several scratch images: newest first.
Several embedded agent images: message order. One blank
line between them, no labels.

## Pass (`Npass`)

Imagify does not take passes. One transcription. An `Npass` token
is stripped and does not change which images are read or the mode. There is no
`/pass` skill.
