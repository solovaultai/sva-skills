---
name: docify
description: >-
  Docify — front end that writes an ify deliverable. Default dispatch
  is askify. Exact equivalent: docify <prompt> = askify <prompt> docify.
  The first token that is not a docify control selects another ify verb.
  Controls match the docify directive (format, path, html, page, scratch,
  set, clear, docpathify). Use when the user runs /docify, "docify" as
  the command, or wants a prompt documented with those controls.
  Print a complete reference with `/docify help` or `/docify --help`
  (also `/?`). `/docify tldr` prints the short page. A write with
  no prompt documents the last ify in this chat. Empty `/docify`
  with no last ify is short usage, not Help.
---

# Docify (= document an ify prompt)

You are running **Docify** (`/docify`) — a **thin front end** in the
Promptify family. You do not answer, plan, or execute by yourself.
Default dispatch is **askify**. The prompt is what is being documented.
The selected verb produces the deliverable and writes it.

1. Parse help, empty, and flags on the typed line.
2. Collect directive controls. Cite `docs/docify_contract.md`. Do not
   fork that grammar.
3. If the first remaining token is another ify verb or alias, that
   verb replaces askify. Remove only that token.
4. Rebuild one trailing `docify:…` token. Do not append
   `=<NAME>.html`. No filename: the format token sets the
   generated extension. `docify:html` writes `CAPS.html`.
   `docify:html:path:test.md` writes markdown.
5. Print the banner and follow that verb’s `SKILL.md` on the
   rewritten line.

Follow `~/.cursor/skills/promptify/SKILL.md` for **Flag parse order**,
**Scratch images**, and **Multi-pass**. Do not run a second pass loop.
Hand stripped flags to the selected verb.

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first. Then:

- Remaining body exactly `help`, `--help`, or `/?`: read and print
  `references/HELP.md` and stop.
- Remaining body exactly `tldr`: read and print `references/TLDR.md`
  and stop. Extra tokens after `tldr` stay a prompt.
- Remaining body exactly `pass` or `pass help`: print the Pass
  (`Npass`) section and stop.

Do not dispatch. Do not write. Empty `/docify` with no last ify
is short usage, not Help. `help me …` is a prompt.

```text
/docify <prompt>              — askify that prompt, then docify
/docify <controls> <prompt>   — same, with those directive controls
/docify <verb> <prompt>       — that ify verb instead of askify
/docify                        — write the last ify when one exists
/docify:html                   — write that last ify as html
/docify help                  — full reference (also --help, /?)
/docify tldr                  — short form (stop)
/docify pass help             — Pass (Npass) subsection (also `pass`)
```

## Controls

Cite `docs/docify_contract.md`. Consume a leading `docify` /
`docify:…` token when it is present, then the following
directive pieces. A body that does not start with `docify`
still yields those pieces from the front (fromify already
removed the verb). Stop at the first token that is not a
piece. `docpathify` is a control, not a skill.

`set` / `clear` with no prompt: `./scripts/cli.sh docify` or
`scripts/cli.ps1 docify`, then stop. The store changes. Do not
dispatch. Do not write. A write with no prompt, including bare
`/docify` and `/docify:html`, documents the last ify in this
conversation. Cite **No prompt** in `docs/docify_contract.md`.
Do not dispatch askify. Do not re-run the verb. No recoverable
ify: **Error:** nothing to docify, then short usage. Do not
write an empty document.

## Verb

First non-control token only. Optional `/`. Case-insensitive.
Remove it when it matches. Otherwise askify, and the token stays.

`askify` / `promptify-ask` · `plannify` / `planify` / `promptify-plan` / `plify`
· `runnify` / `runify` / `promptify-run` · `promptify` / `prify` · `phasify` / `phaseify` / `phify` · `debugify` /
`promptify-debug` / `dbgify` / `debify` · `addify` · `fromify` · `ify`.

Never select `docify`. A later verb word stays in the prompt.

## Rewrite

One trailing token. Piece order preserved. Join with `:`. Emit
`key=value` as `key:value`. No pieces: the word `docify`.

Do not append `=<NAME>.html`. No filename: the format token
sets the generated extension. `docify:html` writes
`CAPS.html`. `docify:html:path:test.md` writes markdown. A
filename with no extension stays text and keeps no extension.
`html:page` with no filename stays `docify:html:page`. The
directive generates the `.html` name and opens the browser.

## Banner

```markdown
**Docify — <verb>.**
`<rewritten line>`
```

Then that verb’s full pipeline, including its docify write.

## Equivalences

`/docify what are the pytch cli commands controlling cloudflare`
= `/askify what are the pytch cli commands controlling cloudflare docify`.

`/docify html:page Show me all of the options for the docify skill and directive.`
= `/askify Show me all of the options for the docify skill and directive. docify:html:page`.
The directive writes `SHOW_ME_ALL_OF_THE_OPTIONS.html` and opens it.

`/docify:text path=~/docs plannify 2pass create a new set of pytch CLI commands to manage and display outreaches`
= `/plannify 2pass create a new set of pytch CLI commands to manage and display outreaches docify:text:path:~/docs`.

## From files

Cite `docs/from_contract.md`. Slots stay on the rewritten line for
the selected verb. Help, tldr, pass, and empty do not read files.

## Docify

Cite `docs/docify_contract.md`. The rewritten line’s `docify` /
`docpathify` writes that verb’s deliverable. A write with no
prompt writes the last ify deliverable. Help, tldr, and pass do
not write. Empty `/docify` with no last ify does not write.
This skill does not write a second file.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `DOC:`.
Set the tmux window name per that contract on a real task.
Help, tldr, pass, and empty usage do not retitle.
The selected verb then sets its own prefix.

## Hard rules

- Thin front end. Default verb is askify.
  `docify <prompt>` = `askify <prompt> docify`.
- First non-control token, if it is an ify verb or alias, replaces
  askify. Only that token. Never select `docify`.
- Controls are the directive’s controls. One trailing token.
  A body that does not start with `docify` still collects
  controls from the front.
- No filename: the format token sets the generated extension.
  Do not append `=<NAME>.html`. `docify:html` writes
  `CAPS.html`. `docify:html:path:test.md` writes markdown.
- `Nimages` / `Npass` are handed to the selected verb.
- Help, tldr, and pass do not dispatch and do not write.
  A write with no prompt writes the last ify deliverable.
  Empty `/docify` with no last ify is short usage.
