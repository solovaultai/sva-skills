# docify design

Applies after any ify command: `askify`, `plannify`, `runnify`, `promptify`, `debugify`, `phasify`, `ify`.

## Task 1: `image` is the same as `1image`

If the first word after any ify command is `image`, that is the same as `1image`.

Example: `phasify image` is the same thing as `phasify 1image`.

## Task 2: `docify` writes a user-readable document

If anywhere in the prompt of an ify command the word `docify` is used, that section (or the entire plan of action) should be written to a user-readable markdown document in the appropriate folder in `pytch-docs` with the appropriate name.

### Task 2a: default file names

By default markdown file names are in caps and underline separated.

Example: `TEST_ME.md`

### Task 2b: explicit file name

If `docify` is followed by a markdown file name (example: `my_doc.md`) that is the file name to be generated.

### Task 2c: path

If the post-`docify` term is a relative or fully qualified path then write to that path.

Since there is no way to determine if the next term is meant as a document directive if there is no file name, there is no way to just specify a folder without a doc name.

Example: `/home/ami/scratch` will not create a document at that location.

### Task 2d: `docpathify`

To work around Task 2c, a `docpathify` command does one thing: specifies a document location (either a relative or fully qualified folder, or the same with a file name).

`docpathify` is really only to handle a path with no filename, but it should still accept a filename just to keep confusion and misuse from occurring.

### Task 2e: `docify` directives

Optionally the user can use a `docify` directive to do the same as `docpathify`.

#### Task 2e1: output format

```text
select output format [[md|markdown]|[word:docx]|[txt|text]|html[:<directive>]]
```

- Example: `docify:txt`
- Default = markdown (`md`)
- `word` and `docx` both produce docx format
- `md` and `markdown` both produce markdown (`.md`)

#### Task 2e2: path

```text
[path][:|=][[folders][/][filename][.][md,docx,txt]
```

| Example | Meaning |
|---------|---------|
| `docify path:/home/ami/scratch` | Write file to `/home/ami/scratch` named as the tool deems appropriate |
| `docify path=/home/ami/scratch` | Same as `path:`. Write file to `/home/ami/scratch` named as the tool deems appropriate |
| `docif path=test.md` | Filename = `test.md`. Tool must decide where is best to put the document (folder) |
| `docif path=scratch/test.md` | Root of where the AI is running, offset by `scratch`. Filename `test.md`. Format = markdown |
| `docif path=scratch/test` | Root of where the AI is running, offset by `scratch`. Filename `test`. Format = text (no extension = text) |
| `docif path=test.txt` | Root of where the AI is running. Filename `test.txt`. Format = text. Overrides selected format |

Extension on a filename overrides any other format specification. Example: `docify:txt=test.md` will write in markdown format.

#### Task 2e3: HTML handling

`docify path=test.html` writes at the root of where the AI is running. Filename `test.html`. Format = html.

HTML has a modifier of its own:

```text
docify:html[:[[doc|full]|iframe|embed|object|[docx|word]|[md|markdown]]]
```

**`docify:html:docx`** — generate the docx file then render with some version of:

```html
<div id="docx-viewer" style="height:500px; overflow-y:auto; border:1px solid #ccc;">Loading...</div>
<script src="https://unpkg.com"></script>
<script src="https://unpkg.com"></script>
<script>
  fetch('scratch/test.docx')
    .then(res => res.blob())
    .then(blob => {
      const container = document.getElementById('docx-viewer');
      container.innerHTML = '';
      docx.renderAsync(blob, container);
    });
</script>
```

**`docify:html:md`** — generate the markdown file then render with some version of:

```html
<div id="md-viewer">Loading...</div>
<script src="https://jsdelivr.net"></script>
<script>
  fetch('scratch/test.md')
    .then(res => res.text())
    .then(text => document.getElementById('md-viewer').innerHTML = marked.parse(text));
</script>
```

**`docify:html:txt`** — generate the text file then render with some version of:

```html
<iframe src="scratch/test.txt" width="100%" height="400px" style="border: 1px solid #ccc;"></iframe>
```

**`docify:html`** — generate the formatted html embedded in the iframe:

```html
<iframe srcdoc="
  <html>
    <head>
      <style>
        body { font-family: sans-serif; background-color: #f4f4f9; padding: 20px; color: #333; }
        h1 { color: #0066cc; }
      </style>
    </head>
    <body>
      <h1>Inline Formatted Title</h1>
      <p>This styled content lives <strong>directly inside</strong> the iframe tag!</p>
    </body>
  </html>"
  width="100%"
  height="400px"
  style="border: 1px solid #ccc;">
</iframe>
```

**`docify:html:docx|page`** — generate the docx file then generate a standalone html page:

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://unpkg.com"></script>
  <script src="https://unpkg.com"></script>
</head>
<body>
  <div id="v"></div>
  <script>
    fetch('scratch/test.docx').then(r => r.blob()).then(b => docx.renderAsync(b, document.getElementById('v')));
  </script>
</body>
</html>
```

**`docify:html:md:page`** — generate the markdown file then generate a standalone html page:

```html
<!DOCTYPE html>
<html>
<head>
  <script src="https://jsdelivr.net"></script>
</head>
<body>
  <div id="v"></div>
  <script>
    fetch('scratch/test.md').then(r => r.text()).then(t => document.getElementById('v').innerHTML = marked.parse(t));
  </script>
</body>
</html>
```

**`docify:html:txt:page`** — generate the text file then generate a standalone html page:

```html
<!DOCTYPE html>
<html>
<body>
  <iframe src="scratch/test.txt"></iframe>
</body>
</html>
```

**`docify:html:page`** — generate a standalone html page:

```html
<!DOCTYPE html>
<html>
<body>
  <iframe srcdoc="<h1>Title</h1><p>This is <b>formatted</b> text.</p>"></iframe>
</body>
</html>
```

**Note 2e3a.** For all page-level HTML generation, after generation open a browser session with the new html page.

**Note 2e3b.** No filename: the format token sets the extension of the generated name. `docify:html` writes `CAPS.html`. `docify:txt` writes `.txt`. `docify:docx` writes `.docx`. No format token stays markdown `.md`. A stored `format` is the same kind of format token for a later line that does not set one. An explicit filename overrides. `docify:html:path:test.md` and `docify:txt=test.md` write markdown. A filename with no extension stays text and keeps no extension (`path=scratch/test` → `test`). A directory `path=` is not a filename. The generated name in that folder still uses the format extension. `html:page` with no filename is an HTML page (open the browser). The directive generates the `.html` name. Do not print a no-filename fallback banner. A filename override writes that format directly.

### Task 2f: scratch override

`docify:scratch` or `docify:html:scratch`, and so on, do all work in scratch. This directive overrides all other file naming and pathing arguments, so `docify:scratch path=/home/ami/test` would still write everything to scratch. Scratch is already defined in the ify system, so use that location.

### Task 2g: set defaults

```text
docify:set:[scratch][:<output format type>][path=<path>][prefix=<text>]
```

Set all future `docify` commands to happen in the specified format.

| Example | Meaning |
|---------|---------|
| `docify:set:scratch` | All future file writes go to scratch until changed, overridden, or cleared |
| `docify set:txt` | All future documents are text format until changed, overridden, or cleared |
| `docify set:txt` followed by `docify:docx` | Generate a docx file |
| `docify set:path=/home/ami/docs` | All future docs are generated into `/home/ami/docs` until overridden, changed, or cleared |
| `docify set:path=/home/bob` followed by `docify path=/home/ami` | File written to `/home/ami` |
| `docify:set:path=/home/bob` followed by `docify:path=/home/ami` | Same as the prior row. A space or a colon separator are both supported. Colon is preferred |
| `docify:set:prefix=AMI_` followed by `docify:txt` | Generate file `AMI_<tool generated name>.txt` until overridden, changed, or cleared |
| `docify:set:prefix=AMI_` followed by `docify:txt:[NOPREFIX\|PREFIX=]` | Generate file `<tool generated name>.txt` |

### Task 2g: clear defaults

```text
docify:clear:[scratch][format|docx|word|md|markdown|text|txt][path]|[prefix]
```

Clear previously set defaults.

| Example | Meaning |
|---------|---------|
| `docify clear:scrach` | No longer default to scratch file location |
| `docify:clear:format` | No longer have a default output format |
| `docify:clear:docx` | Same as `docify:clear:format`. A shortcut. Any extension will clear the default extension |
| `docify clear:path` | No longer default path |
| `docify:clearprefix` | Do not apply a file prefix to future generated files |

---

# `/docify` skill

A front-end skill. It is not a second write implementation. It collects the same controls as the docify directive, takes the rest of the line as the prompt (what is being asked, planned, or executed), and dispatches one existing ify verb with those controls moved to the end of that verb’s line. The selected verb writes the file under `docs/docify_contract.md`. This skill does not write a second file and does not restate the directive grammar.

Default verb is **askify**. The first remaining token selects another ify verb when that token is one. In the worked case that verb is plannify, and plannify replaces the askify default.

This section is the skill. It cites `docs/docify_contract.md` and does not fork that grammar. The same text is installed under `.cursor/skills/docify/`, `.grok/docify/`, and `.copilot/skills/docify/`.

## What the line means

| Piece | Role |
|-------|------|
| Leading `docify` or `docify:…` | This skill. Optional leading `/`. Not a write by itself. |
| Directive controls | Same pieces as the directive: format, html modifiers, `page`, `scratch`, `path=` / `path:`, filename, `docpathify`, `set`, `clear`, `NOPREFIX`, `PREFIX=`. Colon and whitespace both separate. Cite `docs/docify_contract.md`. Do not fork a second piece table. |
| Prompt | Everything after those controls, minus a leading verb token when one is selected. This is what is being documented. |

`docpathify` stays a directive control, not a second skill.

## Parse

Typed line only. Do not scan a spliced file body.

1. **Flags.** Promptify flag parse order. Strip the first numbered `Nimages` / `Npass` only. Hand them to the selected verb. This skill does not run its own pass loop and does not resolve images.
2. **Help.** After that strip, if nothing remains, or the first remaining token is `help`, `--help`, `/?`, `tldr`, or `pass` (`pass help` included): this skill’s own help, tldr, or pass page. Stop. Do not dispatch. Do not write. Do not `set` or `clear`. `help me …` is a prompt, not help.
3. **Controls.** Collect directive pieces from the front of the body. If the first token is `docify` or starts with `docify:` (optional leading `/`), split that token on `:`. Then consume following tokens that are directive pieces. A body that does not start with `docify` still collects those pieces from the front: when fromify dispatches this skill, the verb token is already removed. Stop at the first token that is not a piece. `set` / `clear` and their keys are controls. An ify verb is not a control.
4. **Verb.** Look only at that first non-control token. Optional leading `/`. Case-insensitive.
   - It is an ify verb or alias in the table below: that verb replaces askify. Remove the token. The rest of the line is the prompt.
   - It is not: the verb stays **askify**. That token stays in the prompt.
   - A later verb word stays in the prompt. Never select `docify`. Never select `docpathify` (it is a control, already consumed).
5. **Rewrite** one line and follow that verb’s `SKILL.md` on it.

A verb token is not searched for later in the line. `/docify 2pass plannify create a plan` keeps askify, because `2pass` is first and is a flag, not a verb. `/docify plannify 2pass create a plan` selects plannify.

| Token | Selects |
|-------|---------|
| `askify`, `promptify-ask` | askify |
| `plannify`, `planify`, `promptify-plan` | plannify |
| `runnify`, `promptify-run` | runnify |
| `promptify` | promptify |
| `phasify` | phasify |
| `debugify`, `promptify-debug` | debugify |
| `addify` | addify |
| `fromify` | fromify |
| `ify` | ify |

Not verbs: `image`, `imagine`, `help`, `check-work`, `code-review`, `create-skill`, `debug-kickoff`.

## Trailing control token

One token, appended after the prompt. Pieces stay in encounter order, joined by `:`. A `key=value` piece is emitted as `key:value`. No pieces means the single word `docify`.

`path=~/docs` is emitted as `path:~/docs`. The inner verb expands `~`. This skill does not resolve the path.

No filename: the format token sets the extension of the generated name. The directive does that. This skill does not append `=<NAME>.html`. `docify:html` writes `CAPS.html`. `docify:html:path:test.md` writes markdown, because the filename extension overrides the format token. `html:page` with no filename stays in the trailing token as `page`. The directive generates the `.html` name and opens the browser.

`set` / `clear` with no prompt: apply them through `./scripts/cli.sh docify` (or `cli.ps1`) and stop. Do not dispatch. A write control with no prompt: short usage. A prompt is required. Do not write an empty document.

## Dispatch

Print this banner, then run the selected verb on the rewritten line. Mutability is that verb’s. Askify, plannify, and promptify stay read-only except for the one resolved docify file.

```markdown
**Docify — <verb>.**
`<rewritten line>`
```

The inner verb prints **Docify — wrote.** and the path. This skill does not print a second path.

## Equivalences

These three lines are the rule.

```text
/docify what are the pytch cli commands controlling cloudflare
```

is

```text
/askify what are the pytch cli commands controlling cloudflare docify
```

```text
/docify html:page Show me all of the options for the docify skill and directive.
```

is askify of that prompt with trailing `docify:html:page`. The directive writes `SHOW_ME_ALL_OF_THE_OPTIONS.html` and opens it:

```text
/askify Show me all of the options for the docify skill and directive. docify:html:page
```

The page is about this skill and about the directive.

```text
/docify:text path=~/docs plannify 2pass create a new set of pytch CLI commands to manage and display outreaches
```

is

```text
/plannify 2pass create a new set of pytch CLI commands to manage and display outreaches docify:text:path:~/docs
```

`plannify` was the first non-control token, so it replaces askify. `2pass` stays on plannify’s line. `text` and `path=~/docs` move to the trailing token.

## Empty, help, window

Empty `/docify`:

```text
/docify <prompt>              — askify that prompt, then docify
/docify <controls> <prompt>   — same, with those directive controls
/docify <verb> <prompt>       — that ify verb instead of askify
/docify help                  — full reference (also --help, /?)
/docify tldr                  — short form (stop)
/docify pass help             — Pass (Npass) subsection (also `pass`)
```

Cite `docs/from_contract.md` on the rewritten line only. This skill does not splice. A `from=` slot stays in the prompt for the selected verb.

Cite `docs/window_title.md`. Prefix for this skill: `DOC:`. Set it on a real task, then let the selected verb replace it with that verb’s prefix. Help, tldr, pass, and empty usage do not retitle.

## Skill text

When this design is copied into `SKILL.md`, the front matter and the body below are the skill. The description’s trigger list is part of the skill.

````markdown
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
  (also `/?`). `/docify tldr` prints the short page. Empty `/docify`
  is short usage, not Help.
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

Do not dispatch. Do not write. Empty `/docify` is short usage, not
Help. `help me …` is a prompt.

```text
/docify <prompt>              — askify that prompt, then docify
/docify <controls> <prompt>   — same, with those directive controls
/docify <verb> <prompt>       — that ify verb instead of askify
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
dispatch. Do not write. A write control with no prompt: short
usage. A prompt is required. Do not write an empty document.

## Verb

First non-control token only. Optional `/`. Case-insensitive.
Remove it when it matches. Otherwise askify, and the token stays.

`askify` / `promptify-ask` · `plannify` / `planify` / `promptify-plan`
· `runnify` / `promptify-run` · `promptify` · `phasify` · `debugify` /
`promptify-debug` · `addify` · `fromify` · `ify`.

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
`docpathify` writes that verb’s deliverable. Help, tldr, pass, and
empty do not write. This skill does not write a second file.

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
- Help, tldr, pass, and empty do not dispatch and do not write.
````

## Landing

The skill text above is installed in `.cursor/skills/docify/`, `.grok/docify/`, and `.copilot/skills/docify/`, each with `references/HELP.md` and `references/TLDR.md`. `docs/docify_contract.md` keeps one directive grammar. The skill cites it. `docs/window_title.md` has `DOC: <summary>`. `docs/from_contract.md` and fromify’s pick table include `docify`. fromify may select it. Docify never selects itself.

The directive’s checklist stays the write checklist. The skill’s checklist is the three equivalences above, plus `/docify help` stopping with no file, and `/docify:set:txt` with no prompt changing the store only.
