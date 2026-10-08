# Fromify — user reference

Print this file as the response when the user runs `/fromify help`,
`/fromify --help`, or `/fromify /?`. Do not pick a verb, read files,
or dispatch. `/fromify tldr` prints the short page
(`references/TLDR.md`), not this file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/fromify` is the short usage cheat, not this page.
`help me …` (or any longer body) is a **task**, not Help.
`/fromify 2pass` and `/fromify 1image` are real tasks, not empty
usage.

---

## What it does

A **thin file front end**. Splices local files into an ify prompt and
dispatches to an ify verb. Does not plan, execute, debug, or answer
by itself. Default verb is **plannify**.

File slots, path resolution, splice, and errors:
`docs/from_contract.md`. This page does not restate that parser.

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see `docs/docify_contract.md`). Help, tldr, and pass do not write.

Window title prefix is `FROM:` (see `docs/window_title.md`).
Help, tldr, and pass do not retitle.

```text
/fromify <files>         — plannify of those files (same as from=)
/fromify <verb> <text>   — that verb, with file slots spliced in
/fromify help            — this reference (also --help / /?)
/fromify tldr            — short form; stop
/fromify pass            — Pass (Npass) subsection only (also pass help)
```

Empty `/fromify` is **short usage**, not Help.

`fromify file1[,file2,...]` = `plannify from=file1,file2,...`.

---

## How to invoke

```text
fromify john_b_changes_to_admin_page.md,marys_comments.txt
fromify runnify test.txt
fromify 2pass
fromify 1image
/fromify help
/fromify tldr
/fromify pass help
```

`fromify john_b_changes_to_admin_page.md,marys_comments.txt` equals
plannify of those two files.

`fromify runnify test.txt` equals runnify plus the exact file text
of `test.txt`.

`fromify 2pass` and `fromify 1image` apply `2pass` / `1image` to the
selected verb (plannify, when the line has no verb token).

The text is everything after the command, or the free-text request
when they said “fromify these notes”. File slots still follow
`docs/from_contract.md`.

---

## Modes

| Invocation | Mode | What happens |
|------------|------|----------------|
| `/fromify <files or text>` | **Splice + plannify** | Default verb. Same as `plannify from=` |
| `/fromify <verb> <text>` | **Splice + that verb** | First verb/alias is removed from the body |
| `/fromify` *(empty)* | Short usage | No read, no dispatch |
| `/fromify help` / `--help` / `/?` | **Help** | Print this page; stop |
| `/fromify tldr` | **tldr** | Print the short page; stop |
| `/fromify pass` / `pass help` | **Pass help** | Print the Pass section; stop |
| `/fromify 2pass` / `1image` | **Flags** | Handed to the selected verb |

Exact remaining body after flag strip must be `help`, `--help`,
`/?`, `tldr`, `pass`, or `pass help`. `help me write a login form` is a
task (splice that text and dispatch).

---

## Verb pick

First whitespace-delimited ify verb or alias on the typed line.
Optional leading `/`. Case-insensitive. That token is removed.
Default **plannify**. Never select `fromify`. A later verb word stays
in the body.

**Ify verbs:** `addify` · `askify` · `debugify` · `docify` · `ify` · `phasify` ·
`plannify` · `promptify` · `resumeify` · `runnify` · `saveify`.

**docify.** Document this prompt. Default is askify; a leading ify verb selects that verb. See `.copilot/skills/docify/SKILL.md`.

**Aliases:** `promptify-plan` / `planify` / `plify` → plannify;
`promptify-run` / `runify` → runnify; `promptify-ask` → askify;
`promptify-debug` / `dbgify` / `debify` → debugify; `phaseify` / `phify` → phasify;
`prify` → promptify; `savify` → saveify;
`resumify` → resumeify.

---

## File slots

Per `docs/from_contract.md`:

- `from=` and `from:` (no space before `=` or `:`) are slots.
- A token, or a comma-separated group, is a bare file slot when it
  contains `/` or `\`, starts with `~` or `.`, or contains a
  dot-extension. Other words are prose.
- Prose before and after a slot stays where you wrote it.
- `fromhere` is not a slot. It stays in the body (default plannify
  still understands `fromhere`).
- Several files in one slot are spliced in listed order.
- File text is literal. Nothing inside a file is a flag, a verb, or
  another `from=`.
- A missing file, an ambiguous path, or a non-text file stops with
  **Error:**. No invented text. No partial splice. No dispatch.

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify: first numbered instance left to
right on the **typed line only**; skip unnumbered `image` / `pass` (first typed token `image` counts as `1image`).
Strip **before** deciding Help vs task. Cite promptify **Flag parse
order** — do not fork. Do not scan file bodies.

Flags are handed to the **selected verb**, including the scratch
source that verb already uses. fromify does not run its own second
pass loop.

`/fromify 2pass` and `/fromify 1image` apply to that verb (plannify
when no verb token is present). A verb elsewhere on the line receives
the same flags: `fromify runnify 2pass test.txt`.

---

## Named images (`img`)

Specific files, not the newest N. Cite promptify **Named images**.
Do not fork that grammar. `img=<file>`, `img:<file>`, `img=[a,b]`,
`img:[a,b]`, and empty `img=[]` / `img:[]`. Every token counts.
They stay on the rewritten line for the selected verb. They are
not file-slot text.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this section** and stops.
Full reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right, typed line only. Default **1**.

**Meaning:** the flag is handed to the **selected** verb. fromify
does not loop. If N > 1, that verb’s multi-pass applies: pass 1 is
a documented pre-plan; the last pass emits that verb’s deliverable.
Scratch images, when also present, use that verb’s existing scratch
source. Acknowledge inside the selected verb (scratch first, then
Npass).

```text
/fromify pass
/fromify pass help
/fromify 2pass
/fromify 1image
/fromify runnify 2pass test.txt
/promptify pass help
```

---

## Banner then selected verb

```markdown
**Fromify — <verb>.**
Dispatching to /<verb> on the spliced body.
```

Then that verb’s full response (including its trailing table when
that skill requires one). Fromify does not reimplement the verb.

---

## Hard rules (short)

- Thin front end: pick a verb, splice per `docs/from_contract.md`,
  dispatch. No second parser. No second pass loop.
- Default is plannify.
  `fromify file1[,file2,...]` = `plannify from=file1,file2,...`.
- First verb or alias wins and is removed. Never select `fromify`.
  A later verb word stays in the body.
- `from=` / `from:` and bare path-like tokens are file slots. Prose
  stays. **Error:** stops the turn.
- Flags on the typed line are handed to the selected verb.
- Empty `/fromify` is short usage, not Help.
- Exact `help` / `--help` / `/?` after flag strip: print this page;
  stop. Exact `tldr`: print `references/TLDR.md` (not this file).
  Exact `pass` / `pass help`: print **Pass (`Npass`)** only.
  There is no `/pass` skill.

---

## Related

| Command | Role |
|---------|------|
| `/plannify from=<files>` | Same splice, verb named up front |
| `/plannify <prompt>` | Optimize then plan (read-only) |
| `/plannify fromhere` | Replan from current statuses |
| `/runnify <prompt>` | Optimize then execute |
| `/promptify <prompt>` | Analyze / optimize only |
| `/askify <prompt>` | Optimize then answer (read-only) |
| `/debugify <bug>` | Debugify for this platform |
| `/phasify` | Execute the next plan phase |
| `/addify <text>` | Append text to the last ify and restart/continue |
| `/ify` | Family catalog + help + router (`smart` recommends; does not dispatch) |
