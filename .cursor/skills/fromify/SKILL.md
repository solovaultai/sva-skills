---
name: fromify
description: >-
  Fromify — front end that splices local files into an ify prompt.
  Default dispatch is plannify. Exact equivalent: fromify
  file1[,file2,...] = plannify from=file1,file2,.... The first ify
  verb or alias on the line selects that verb. Use when the user runs
  /fromify, "fromify", or wants files spliced into an ify prompt.
  Print a complete reference with `/fromify help` or `/fromify --help`
  (also `/?`). `/fromify tldr` prints the short page. Empty
  `/fromify` is short usage, not Help. Recognizes nimages / Nimages /
  N images / N-images as a pointer to the newest N images from the
  configured scratch source (or workspace scratch/). Recognizes npass
  / Npass / N-pass / N pass as a pass-count flag handed to the
  selected verb (fromify does not run its own second pass loop).
---

# Fromify (= files into an ify)

You are running **Fromify** (`/fromify`) — a **thin file front end**
in the Promptify family. You do not plan, execute, debug, or answer
by yourself. Default dispatch is **plannify**.

1. Parse help / empty / flags on the typed line.
2. Pick the ify verb (default plannify) and remove that token.
3. Splice file slots per `docs/from_contract.md`.
4. Print a short banner.
5. **Run the selected verb** as that verb’s `SKILL.md` specifies.

Follow `~/.cursor/skills/promptify/SKILL.md` for **Flag parse order**,
**Scratch images**, and **Multi-pass**. Do not run a second pass loop
of your own. Slot syntax, path resolution, splice, and errors are
`docs/from_contract.md`. Do not paste a second parser. Mutability is
**inherited** from the selected verb.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then:

- Remaining body exactly `help`, `--help`, or `/?` (case-insensitive):
  **read and print** `references/HELP.md` (this skill folder) and
  **stop**.
- Remaining body exactly `tldr` (case-insensitive):
  **read and print** `references/TLDR.md` (this skill folder) and
  **stop**. Extra tokens after `tldr` stay a **task**. There is
  no `tldr help` alias.
- Remaining body exactly `pass` or `pass help` (case-insensitive):
  print the **Pass (`Npass`)** section of that file and **stop**.
  There is no `/pass` skill.

Do not pick a verb, read files, or dispatch. Empty `/fromify` is the
short usage below, not Help. `help me …` is a **task**, not Help.
`/fromify 2pass` and `/fromify 1image` are real tasks: a flag alone
is not empty usage.

If the user invokes the skill with no prompt body, explain:

```text
/fromify <files>         — plannify of those files (same as from=)
/fromify <verb> <text>   — that verb, with file slots spliced in
/fromify help            — full reference (also --help, /?)
/fromify tldr            — short form (stop)
/fromify pass help       — Pass (Npass) subsection (also `pass`)
```

---

## Flag parse order (`Nimages` / `Npass`)

On the **typed line only**, follow promptify **Flag parse order**
(first numbered `Nimages` / `Npass` only). Strip them. They are not
body text. Do not scan file bodies for flags.

Hand the stripped flags to the **selected verb**, including the
existing scratch source that verb already uses. fromify does not run
its own second pass loop. `/fromify 2pass` and `/fromify 1image`
apply to the selected verb (default plannify when no verb token is
present).

---

## Verb pick

After flag strip, when the line is not help / tldr / pass / empty:

The first whitespace-delimited token that is an ify verb or alias
selects that verb. Optional leading `/`. Case-insensitive. **Remove**
that token from the body. Default **plannify**. Never select
`fromify` (skip that token and keep scanning). A later verb word
stays in the body.

The leading `/fromify` that invoked this skill is the front end, not
a pick.

**Ify verbs:** `addify` · `askify` · `debugify` · `ify` · `phasify` ·
`plannify` · `promptify` · `runnify`.

**Aliases → canonical**

| Alias | Canonical |
|-------|-----------|
| `promptify-plan`, `planify` | plannify |
| `promptify-run` | runnify |
| `promptify-ask` | askify |
| `promptify-debug` | debugify |

Exact equivalent when no verb token is present:

```text
fromify file1[,file2,...]  =  plannify from=file1,file2,...
```

---

## File slots

Cite `docs/from_contract.md`. Do not restate the parser.

`from=` / `from:` slots and bare path-like tokens are file slots per
that contract. Prose before and after stays in place. `fromhere` is
not a fromify mode and not a slot; it stays in the body for the
selected verb (default plannify).

Read, then splice. File bodies are literal. Do not scan them for
`from=`, flags, or verb names.

If the contract says **Error:**, stop. Do not invent file text. Do
not splice the other files. Do not dispatch.

Help, tldr, pass, and empty usage do not read files.

---

## Banner (before the selected verb’s output)

```markdown
**Fromify — <verb>.**
Dispatching to /<verb> on the spliced body.
```

Then that verb’s full pipeline (including its scratch / Npass
acknowledgments and its trailing table when that skill requires
them).

---

## Dispatch

Read the selected verb from this tree (`~/.cursor/skills/<name>/SKILL.md`
or this repo’s `.cursor/skills/<name>/SKILL.md`) and follow it
completely on the spliced body. Do not reimplement that verb.

Hand the typed-line `Nimages` / `Npass` flags through as that verb’s
flags.

---

## Worked examples

```text
fromify john_b_changes_to_admin_page.md,marys_comments.txt
```

equals plannify of those two files
(`plannify from=john_b_changes_to_admin_page.md,marys_comments.txt`).

```text
fromify runnify test.txt
```

equals runnify plus the exact file text of `test.txt`.

```text
fromify 2pass
fromify 1image
```

apply `2pass` / `1image` to the selected verb (here, plannify).

---

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `FROM:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.

## Hard rules

- Thin front end: verb pick, splice per `docs/from_contract.md`,
  dispatch. Do not reimplement the selected verb. Do not paste a
  second file parser.
- Default verb is **plannify**.
  `fromify file1[,file2,...]` = `plannify from=file1,file2,...`.
- First whitespace-delimited ify verb or alias (optional `/`,
  case-insensitive) selects that verb and is removed. Never select
  `fromify`. A later verb word stays in the body.
- `Nimages` / `Npass`: promptify flag parse order on the typed line
  only. Hand them to the selected verb, including the existing
  scratch source. fromify does not run its own second pass loop.
- `from=` / `from:` and bare path-like tokens are file slots per the
  contract. Prose before and after stays. File bodies are literal.
- Contract **Error:** stops the turn. Do not invent file text.
- Exact `help` / `--help` / `/?` after flag strip: print
  `references/HELP.md` and stop. Exact `tldr`: print
  `references/TLDR.md` and stop. Exact `pass` / `pass help`: print
  the **Pass (`Npass`)** section and stop. Empty `/fromify` is
  short usage, not Help. `help me …` is a task.
- Cite `docs/window_title.md`. Prefix `FROM:`. Help, tldr, pass, and
  empty usage do not retitle.
