# /image — user reference

Print this file as the response when the user runs `/image help`,
`/image --help`, or `/image /?`. Do not attach images or answer.

Empty `/image` is default N = 1 (newest scratch image), not this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Attach the **N most recent images** in workspace `scratch/` and
**answer this request** using what they show.

This skill **runs**. It is not promptify-only. It does **not** generate
or edit images (that is **imagine** / `image_gen`).

---

## How to invoke

```text
/image <question>      — newest scratch image (N = 1) + answer
/image 2 <question>    — 2 newest scratch images + answer
/image N <question>    — N newest scratch images + answer
2image <question>      — same as /image 2
2 images <question>    — same as /image 2
2-images <question>    — same as /image 2
/image help            — this reference (also --help / /?)
```

Example: `Tell me what I am seeing in these images 2image`

`/image 2` and `2image` mean the same thing.

---

## Flag parse order

Same rule as promptify / the ify family. First numbered instance
**left to right**. Do **not** take the largest N.

| Rule | Example |
|------|---------|
| Numbered instance counts | `1image`, `1 image`, `1-image`, `2images`, `2 images`, `2-images` |
| Unnumbered word does **not** count | `image`, `images` — keep scanning |
| Later numbered wins over earlier unnumbered | `what is in this image 2image` → `2image` |
| Several numbered → first only | Do **not** take the largest N |
| `/image N` is numbered | `/image 2 what am I seeing` → N = 2 (token `/image 2`) |
| `/image` with no integer | Unnumbered; scan for `2image` / `N images` / … |
| No numbered instance | Default **N = 1** (newest image only) |

Strip these tokens before deciding Help vs task. They are not part
of the task wording.

If default N = 1 would be confusing (the question clearly means
several images and there is still no number), say to use `/image 2`
or `2image`. Prefer N = 1 for bare `/image` plus leftover question
text.

---

## Scratch folder

Resolve `scratch/` at the repo root (or the project's existing
`scratch` dir). Do **not** create one.

Read the N newest `*.png` `*.jpg` `*.jpeg` `*.webp` `*.gif` `*.bmp`
(newest mtime first). If the folder or enough images are missing,
still print the ack, then say what was missing.

**First printed content** when this skill runs:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on this request.
```

`<token>` is what they wrote (`2image`, `2 images`, …) or `/image N`.
Bare `/image` (default N = 1) uses `/image`.

---

## Hard rules (short)

- Answer the restated question (marker stripped) using the images.
- Never invent pixels. Never create `scratch/`.
- Not image generation — that is **imagine**.
- Exact `help` / `--help` / `/?` after flag strip: this page; stop.
