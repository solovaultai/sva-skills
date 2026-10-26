# /imagify

Print only the text in the newest scratch image, or in N images.
An image embedded in the agent message is the source on Cursor,
Grok, Claude, and GitHub Copilot, and the image directive does not
change that. `imgfy` and `imageify` are aliases. Paste that text
into another app. The reply is the text and nothing else, and that
same text is copied to the clipboard.

`from=` / `from:` splices local files into the prompt (see `docs/from_contract.md`).
`docify` / `docpathify` write the transcribed text (`the docify skill's references/docify_contract.md`). The chat reply stays that text only.
Window prefix `IMG:` (`docs/window_title.md`).

Empty `/imagify` is a real transcription, not short usage.

```text
/imagify                 — text from the newest scratch image (1image), then copy it
/imgfy                   — alias of /imagify
/imageify                — alias of /imagify
/imagify 2images         — text from the 2 newest
/imagify image2          — same count, glued
/imagify images          — blank n, same as 1image
/imagify text            — text mode (also totext, 2text, and the default)
/imagify help            — full reference (also --help / /?)
/imagify tldr            — short form (stop)
/imagify pass            — Pass (Npass) subsection only (also pass help)
```

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Newest scratch image, text only | No image directive means `1image`. Embedded agent images replace this |
| Embedded agent image | Every image embedded in this message | Cursor, Grok, Claude, and GitHub Copilot. The image directive does not change the source or the count |
| `<n>image` / `<n>images` / `image<n>` / `images<n>` | N newest. Blank n is 1 | First image directive wins. `image 2` is 1. `image2` is 2 |
| `text` / `totext` / `2text` | Text mode | Default when there is no other directive |
| `0image` / `image0` | Error before any read | Count starts at 1 |
| `img=` | Error on a transcription | Scratch newest N, not a named file |
| `help` / `tldr` / `pass` | Print that page and stop | No transcription |
