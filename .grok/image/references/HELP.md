# /image — user reference

Print this file as the response when the user runs `/image help`,
`/image --help`, or `/image /?`. Do not attach images or answer.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/image` is default N = 1 (newest scratch image), not this page.
`help me …` (or any longer body) is a **task**, not Help.

---

## What it does

Attach the **N most recent images** from the configured scratch
source (or workspace `scratch/` if unset) and
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
/image pass            — Pass (Npass) note only (also pass help)
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

Strip these tokens (and `Npass` if present) before deciding Help
vs task. They are not part of the task wording. Cite promptify
**Flag parse order** — do not fork.

If default N = 1 would be confusing (the question clearly means
several images and there is still no number), say to use `/image 2`
or `2image`. Prefer N = 1 for bare `/image` plus leftover question
text.

---

## Scratch source

If `scratch.env` exists, run `scripts/cli.sh scratch ls N` (or
`scripts\cli.ps1 scratch ls N`) and **read those paths**. Else
resolve workspace `scratch/` at the repo root (or the project's
existing `scratch` dir). Do **not** create one.

Read the N newest `*.png` `*.jpg` `*.jpeg` `*.webp` `*.gif` `*.bmp`
(newest mtime first). If the source or enough images are missing,
still print the ack, then say what was missing. Name the source
(`local …` or `remote conn:dir` or workspace `scratch/`).

**First printed content** when this skill runs:

```markdown
**Scratch images — caught and correctly interpreted.**
Recognized `<token>` as an attachment marker. Looking at the N most recent
image(s) from <source> for extra detail on this request.
```

`<token>` is what they wrote (`2image`, `2 images`, …) or `/image N`.
Bare `/image` (default N = 1) uses `/image`.

---

## Pass (`Npass`)

There is **no** `/pass` skill. `/image` does **not** take `Npass`
as a pipeline flag. `Npass` is an ify-family flag (promptify /
runnify / plannify / phasify / …). Cite promptify **Flag parse
order**.

After stripping `Nimage` / `/image N` / `Npass` tokens, remaining
body exactly `pass` or `pass help` prints **this note** and stops.

Use `/promptify pass help` (or `/runnify pass help`,
`/phasify pass help`) for the full Pass reference.

`/image` tokens: `Nimage` / `2image` / `/image 2` — not `Npass`.

```text
/image pass
/image pass help
/promptify pass help
```

---

## Hard rules (short)

- Answer the restated question (marker stripped) using the images.
- Never invent pixels. Never create `scratch/`.
- Not image generation — that is **imagine**.
- Exact `help` / `--help` / `/?` after flag strip: this page; stop.
  Exact `pass` / `pass help`: print **Pass (`Npass`)** only.
