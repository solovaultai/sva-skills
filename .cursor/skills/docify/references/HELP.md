# Docify — user reference

Print this file as the response when the user runs `/docify help`,
`/docify --help`, or `/docify /?`. Do not dispatch and do not write.
`/docify tldr` prints the short page (`references/TLDR.md`), not this
file.

If the remaining body after flag strip is exactly `pass` or
`pass help` (case-insensitive), print only the **Pass (`Npass`)**
section below and stop. There is no `/pass` skill.

Empty `/docify` is the short usage cheat, not this page.
`help me …` is a **prompt**, not Help.

---

## What it does

A **thin front end**. Collects docify directive controls, then
dispatches an ify verb. Default verb is **askify**. Does not answer,
plan, or write a second file. The selected verb writes under
`docs/docify_contract.md`.

```text
/docify <prompt>              — askify that prompt, then docify
/docify <controls> <prompt>   — same, with those directive controls
/docify <verb> <prompt>       — that ify verb instead of askify
/docify help                  — this reference (also --help / /?)
/docify tldr                  — short form; stop
/docify pass                  — Pass (Npass) subsection only (also pass help)
```

Empty `/docify` is **short usage**, not Help. Help, tldr, pass, and
empty usage do not dispatch and do not write.

`/docify:set:txt` with no prompt runs `./scripts/cli.sh docify` (or
`scripts/cli.ps1 docify`) and stops. The store changes. No file is
written.

---

## Equivalences

`/docify what are the pytch cli commands controlling cloudflare`
= `/askify what are the pytch cli commands controlling cloudflare docify`.

`/docify html:page Show me all of the options for the docify skill and directive.`
= `/askify Show me all of the options for the docify skill and directive. docify:html:page`.
The directive writes `SHOW_ME_ALL_OF_THE_OPTIONS.html` and opens it.

`/docify:text path=~/docs plannify 2pass create a new set of pytch CLI commands to manage and display outreaches`
= `/plannify 2pass create a new set of pytch CLI commands to manage and display outreaches docify:text:path:~/docs`.

Only the first non-control token is tested. A later verb word stays
in the prompt. Never select `docify`. `docpathify` is a control, not
a skill.

A body that does not start with `docify` (fromify already removed the
verb) still collects controls from the front.

---

## Format wins

No filename: the format token sets the extension of the generated
name. `docify:html` writes `CAPS.html`. `docify:txt` writes `.txt`.
`docify:docx` writes `.docx`. No format token stays markdown `.md`.
A stored `format` is the same kind of format token for a later line
that does not set one.

An explicit filename overrides. `docify:html:path:test.md` and
`docify:txt=test.md` write markdown. A filename with no extension
stays text and keeps no extension (`path=scratch/test` → `test`).
A directory `path=` is not a filename. The generated name in that
folder still uses the format extension.

`html:page` with no filename stays `docify:html:page`. The directive
generates the `.html` name and opens the browser. This skill does
not append `=<NAME>.html`.

---

## Flags (`Nimages` / `Npass`)

Same parse order as promptify. Strip the first numbered `Nimages` /
`Npass` and hand them to the selected verb. This skill does not run
its own pass loop and does not resolve images. Cite promptify
**Flag parse order**.

`/docify plannify 2pass create a plan` selects plannify and hands
`2pass` to it. `/docify 2pass plannify create a plan` keeps askify:
`2pass` is first and is a flag, not a verb. A later verb word stays
in the prompt.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, remaining body
exactly `pass` or `pass help` prints **this section** and stops.
Full reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right, typed line only. Default **1**.

**Meaning:** the flag is handed to the **selected** verb. docify
does not loop. If N > 1, that verb’s multi-pass applies: pass 1 is
a documented pre-plan; the last pass emits that verb’s deliverable.
Cite promptify **Multi-pass**. Do not fork it.

```text
/docify pass
/docify pass help
/docify plannify 2pass create a plan
/promptify pass help
```

---

## Hard rules (short)

- Thin front end. Default is askify.
  `docify <prompt>` = `askify <prompt> docify`.
- First non-control token, if it is an ify verb or alias, replaces
  askify. Only that token. Never select `docify`.
- `docify:html` with no filename writes a generated `.html` file.
  `docify:html:path:test.md` writes markdown.
- Help, tldr, pass, and empty do not dispatch and do not write.
- `/docify:set:txt` with no prompt changes the store only.
