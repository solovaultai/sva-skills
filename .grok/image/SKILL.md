---
name: image
description: >
  Attach the N most recent images from the workspace scratch/ folder and
  answer this request using them. Use when the user runs /image, /image 2,
  /image N, "2image", "Nimage", "N image", "N-image", "Nimages",
  "N images", "N-images", or wants scratch-folder images as extra detail
  (e.g. "Tell me what I am seeing in these images 2image"). This skill
  reads existing scratch images; it does not generate or edit images
  (that is imagine / image_gen). Print a complete reference with
  `/image help` or `/image --help` (also `/?`).
metadata:
  short-description: "Read N newest scratch/ images and answer"
---

# /image — scratch attachments

You **run** this skill. Attach the N newest images in workspace
`scratch/` and **answer the user's actual question** using what they
show. This is not promptify-only and not image generation.

**Not imagine.** Do not call `image_gen` / `image_edit`. `/imagine` is
a different skill (generate or edit). This skill only **reads** files
already in `scratch/`.

## Help (`help` / `--help` / `/?`)

Strip `/image N` and `Nimage` / `Nimages` tokens first (Flag parse
order). If the **remaining body is exactly** `help`, `--help`, or `/?`
(case-insensitive), **read and print** `references/HELP.md` (this
skill folder) and **stop**. Do not attach images or answer.

Empty `/image` is **not** Help — default N = 1 and look at the newest
scratch image. `help me …` is a **task**, not Help.

## Flag parse order (`Nimages`)

Reuse promptify's rule. Do **not** invent a new parse. Read the user
text **left to right**. Use **only the first instance that counts**.

- A **numbered** instance counts: `1image`, `1 image`, `1-image`,
  `2images`, `2 images`, `2-images`, `3image`, …
- An **unnumbered** word does **not** count: `image`, `images`. Skip
  it and keep scanning.
- If the first hit is unnumbered and a later hit **is numbered**, use
  that numbered instance (the first numbered one). Example: `what is
  in this image 2image` → use `2image`.
- If several numbered tokens appear, use only the **first** numbered
  one left to right. Do **not** take the largest N.
- Ordinary English "image" / "images" is not a marker.

**Slash-command N** (same meaning as a numbered token): `/image 2` and
`/image 2 what am I seeing` — a positive integer **immediately after**
`/image` is N. Treat that `/image N` as a numbered instance at that
position in the text (first L→R still wins). Recognized token =
`/image N`. `/image` with no following integer is unnumbered; keep
scanning for `2image` / `N images` / etc.

`/image 2` and `2image` mean the same thing: N = 2.

### Default N = 1

If `/image` has **no** number and **no** numbered token, default
**N = 1** (newest image only). Prefer this for bare `/image` plus
leftover question text (`/image what am I seeing` → N = 1).

If defaulting to 1 would be **confusing** — the leftover question
clearly means several images ("these images", "both screenshots") and
there is still no number — do **not** guess N. Say to use `/image 2`
or `2image`.

## Scratch images

The numbered token (or `/image N`, or default N = 1) is an
**attachment marker**, not part of the task wording.

**Meaning:** the **N most recent image files** in the workspace
**`scratch/`** folder provide extra visual detail for **this** request.

Do this:

1. Resolve `scratch/` at the workspace / repo root. If it is missing,
   look for the project's existing `scratch` directory. Do **not**
   create one.
2. List image files (`*.png`, `*.jpg`, `*.jpeg`, `*.webp`, `*.gif`,
   `*.bmp`). Sort by newest mtime; take **N** (or all, if fewer than N).
3. **Read** those images. Use what they show as evidence for the
   question.
4. If the folder or enough images are missing, still print the ack,
   then say what was missing. Do not invent pixels.
5. Restate the question **without** the marker; keep N and the file
   paths. Then **answer** that question.

**Tell the user (mandatory, first printed content):** As soon as the
marker is recognized (including default N = 1 on `/image`), print this
acknowledgment so it is obvious the token was **caught and correctly
interpreted**. Do not skip it. Do not bury it under later headings.

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) in `scratch/` for extra detail on this request.
```

Use the exact token they wrote (`2image`, `2 images`, `2-images`, …)
or `/image N` when N came from the slash form. For bare `/image`
(default N = 1):

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `/image` as an attachment marker. Looking at the 1 most recent
image in `scratch/` for extra detail on this request.
```

Example: user wrote `2image` →

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `2image` as an attachment marker. Looking at the 2 most recent
images in `scratch/` for extra detail on this request.
```

Example: user wrote `/image 2` →

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `/image 2` as an attachment marker. Looking at the 2 most recent
images in `scratch/` for extra detail on this request.
```

## Answer

After the ack (and any missing-folder / missing-image note):

1. Strip the marker from the restated question.
2. Answer that question using the images you read.
3. If there is no leftover question (empty `/image` or `/image 2`
   only), describe what the attached image(s) show.

## Hard rules

- Never invent scratch files or pixels.
- Never create `scratch/`.
- First printed content is the caught-and-interpreted ack.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop.
- Do not generate or edit images. That is **imagine**.
