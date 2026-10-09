# Docify contract

Shared contract. Lives in `docs/` like `docs/from_contract.md`
and `docs/window_title.md`.
Every ify verb **cites this file**. Do not fork a second
docify dialect, path rule, HTML shell, or defaults file.

Docify is a **directive** on a typed ify line and a verb
(`/docify`). One directive grammar. The skill cites this
file and does not restate it. `docpathify` is a directive
token, not a verb and not a skill.

---

## Scope

Ify set: addify, askify, debugify, docify, fromify, gitify,
ify, phasify, plannify, promptify, resumeify, runnify, saveify.

Not ify utilities. They do not detect docify: `image`,
`imagine`, `help`, `check-work`, `code-review`,
`create-skill`, `debug-kickoff`. Leave `.grok/image`
unchanged.

---

## Detect

Typed line only. Parse after flag strip and after `from=`
splice. A file body is not scanned. The word `docify`
inside a spliced file does not write.

Whole tokens, case-insensitive:

- exactly `docify`
- a token that starts with `docify:`
- exactly `docpathify`, or a token that starts with
  `docpathify:`

A longer token that merely begins with the letters
`docify` (`docifyset`) is prose. `docif` and `scrach`
are not syntax.

Colon and whitespace both separate `docify` from the
rest. Colon is the documented form. `docify:txt` and
`docify txt` are the same directive. After a bare
`docify` token, consume the following tokens that are
part of this grammar and stop at the first token that
is not. Strip every consumed token from the task text
the verb reasons about.

Pieces, split on `:` as well as whitespace:

| Piece | Role |
|-------|------|
| `set` | Update the store. Not a write by itself. |
| `clear`, `clearprefix` | Clear store keys. Not a write by itself. |
| `scratch` | This write uses the scratch folder. |
| `md`, `markdown` | Format markdown. |
| `txt`, `text` | Format text. |
| `word`, `docx` | Format docx. |
| `html` | Format html, plus the modifiers below. |
| `doc`, `full`, `iframe` | srcdoc iframe fragment. |
| `embed`, `object` | Companion tag fragment. |
| `page` | Full HTML page. Also the bar form `docx\|page`, `md\|page`, `txt\|page`, `word\|page`. |
| `path=` / `path:` | Location. The value is the rest of that piece, or the next piece. |
| `NOPREFIX`, `PREFIX=` | Skip the stored prefix for this write only. |
| `prefix=` | Store prefix. Only under `set`. |
| a filename or path | Bare name, relative path, or absolute path. |

`docify:txt=test.md` is format plus filename in one
piece. The filename extension wins (that example is
markdown).

---

## When it does not write

Help, `--help`, `/?`, tldr, `pass`, and `pass help`
short-circuit before any write and before any `set` /
`clear`. Empty `/docify` with no recoverable last ify
is short usage and does not write. Empty `/docify`
with a last ify is a write of that deliverable.

`set` and `clear` update the store and write a file
only when the same line also has a write directive.
A write directive is `docpathify`, or `docify` with
any piece other than `set` / `clear` and their keys.
Bare `docify` is a write. `docify:txt` is a write.
`docify:set:txt` is not.

---

## No prompt

A write with no task text documents the newest ify
turn in this conversation. A resumeify restore is
that turn. The reprinted body is the file. When the
restore printed a `plan.md` path, read that file and
write it. `plan.md` already holds one phase table.
Do not append `table.txt`. `/docify:html` writes
that body as html.

Do not print short usage for that line. Do not say a
prompt is required. Do not dispatch askify. Do not
re-run the saved verb named in the resume banner.

Chat only. There is no last-ify file. Aliases match
addify **Recover last ify**. Cite
`.grok/addify/SKILL.md` for the alias table only. Do
not apply that section's skip of saveify and
resumeify. Those turns are the deliverable. Still
skip help, tldr, pass, and empty usage.

Saveify writes the snapshot: `plan.md` when `kind`
is `plan`, otherwise `task.txt`, then `kickoff.md`
and `extra.md` when those files exist. Any other
verb writes the deliverable in **What is written**.

Name words come from that task. When the task is
empty, use the snapshot `display_name`. When both
are empty, use `DOCIFY`.

No recoverable ify: **Error:** nothing to docify.
Then the short usage. Do not write an empty file.

`set` / `clear` with no task still change the store
only.

---

## Store, then this line

Apply `set` / `clear` first. Then resolve this write.
This line's path, filename, and `docpathify` override
the stored path for this file only. `NOPREFIX` and
`PREFIX=` skip the prefix for this file only. The
store keeps the prefix.

Precedence for one write:

1. A `scratch` piece on this line. Ignore every path
   on the line, including `path=` and `docpathify`.
2. This line's path, filename, or `docpathify`.
3. Stored defaults.
4. `/home/ami/src/pytch/pytch-docs/agent/` and
   markdown.

---

## Defaults store

Linux:
`${XDG_DATA_HOME:-$HOME/.local/share}/sva-skills/docify.env`

Windows: `%LOCALAPPDATA%\sva-skills\docify.env`

Keys only: `scratch`, `format`, `path`, `prefix`.
One line each, `key=value`. Rewrite the file so a
second set does not duplicate a key. `chmod 600` on
Linux. Missing keys are empty.

| Key | Set value |
|-----|-----------|
| `scratch` | `1` when future writes go to scratch. Empty when cleared. |
| `format` | `md`, `txt`, `docx`, or `html`. |
| `path` | Directory for a later generated or bare filename. |
| `prefix` | Text applied to a generated name (`AMI_`). |

Agents change the file only through `./scripts/cli.sh
docify` and `scripts/cli.ps1 docify`:

```text
docify show
docify set scratch
docify set format txt
docify set path /home/ami/docs
docify set prefix AMI_
docify clear scratch
docify clear format
docify clear path
docify clear prefix
```

`show` prints the env path and all four keys.
`set` and `clear` change only those keys. Unknown
keys, `docif`, and `scrach` are rejected and do not
change the file.

Accepted on a typed line: `docify:set:scratch`,
`docify set:txt`, `docify:set:path=/home/ami/docs`,
`docify:set:prefix=AMI_`, and those keys combined in
one `set`. Accepted clears: `docify:clear:scratch`,
`clear:format`, `clear:path`, `clear:prefix`, and
`docify:clearprefix`. `clear:docx` and any format
alias (`md`, `markdown`, `txt`, `text`, `word`,
`html`) clear `format` only.

---

## What is written

The verb's user-facing deliverable. Chat still prints
the normal reply.

| Verb | File body |
|------|-----------|
| plannify | `## Plan` through the phased table |
| promptify | Optimized Prompt |
| runnify | Results and the artifact that run produced |
| askify | The answer |
| debugify | That tree's outcome (Cursor kickoff prompt, or the Grok fix report) |
| phasify | This run's banner and table |
| ify | The catalog, recommendation, or other text it printed |
| fromify | The selected verb writes one file |
| addify | The restarted verb writes one file |
| docify | The selected verb writes one file. No task text: the last ify deliverable |
| resumeify | The reprinted saved body |
| saveify | Snapshot `plan.md`, or `task.txt` then kickoff and notes |
| gitify | Each commit message in the bunch, and each tag name when one was made |

If the typed line names one heading that appears in
that deliverable (the heading words, with or without
leading `#`), write that section only: from the
heading through the line before the next heading of
equal or higher level. Otherwise write the whole
deliverable. Do not invent a `section=` key.

Named images on the typed line, or restored with the
context, are part of the file. Markdown and docx
include a markdown image whose target is the absolute
path. HTML includes `<img src="file://…">` with that
path. Text lists the absolute paths. Cite promptify
**Named images**. Do not fork that grammar.

Immediately before the trailing phase table:

```text
**Docify — wrote.**
`<absolute path>`
```

The table stays last. On failure print **Error:** and
do not claim a path. Overwrite an existing target and
name that path in the ack.

**Read-only carve-out.** Plannify, askify, promptify
analysis, ify, Cursor debugify, and phasify `show` /
`todo` / `explain` may create or overwrite **only**
the resolved output file.

**Window title.** Unchanged. The verb that ran keeps
its prefix from `docs/window_title.md`.

---

## Names and formats

Generated name: three to six words from the stripped
task, `CAPS_WITH_UNDERSCORES`, then the extension. If
fewer than three words remain, use those words. If
none remain, use `DOCIFY`. A stored prefix is applied
to generated names only (`AMI_` + `TEST_ME` →
`AMI_TEST_ME.md`). An explicit filename is used as
given, with no prefix.

| Format token | Extension | Bytes |
|--------------|-----------|-------|
| `md`, `markdown` (default) | `.md` | Markdown text |
| `txt`, `text` | `.txt` | Plain text |
| `word`, `docx` | `.docx` | `pandoc -f markdown -t docx -o <path>` |
| `html` | `.html` | See **HTML** |

No filename: the format token sets the extension of the
generated name, including a stored `format` on a later
line that does not set one. `docify:html` writes
`CAPS.html`. A directory `path=` is not a filename. The
generated name in that folder still uses the format
extension.

A filename extension overrides the format token.
`docify:txt=test.md` and `docify:html:path:test.md` are
markdown. A filename with no extension is text and keeps
no extension (`path=scratch/test` → file `test`).

Do not require `python-docx` or the npm `docx`
package. Use the Word skill only when a later write
needs Word-specific features beyond pandoc.

---

## Paths

`~` and `~/` expand. An absolute path is used as
given. A relative path is under the workspace root.
One candidate. Do not glob. Do not search. A piece
containing `://` is **Error:** URL not allowed.

Create parent directories for a file path. Create
`agent/` on first use of the default folder.

| Typed | Result |
|-------|--------|
| `docify my_doc.md` | That filename. Folder = stored `path`, else `pytch-docs/agent/`. |
| `docify scratch/test.md` | `<workspace>/scratch/test.md` |
| `docify /home/ami/scratch` when that path is a directory | **Error:** folder needs a filename. Use `docpathify` or `path=`. No file. |
| `docify path=/home/ami/scratch` or `path:` when the value is a directory or ends with a slash | Generated name in that folder. |
| `docpathify /home/ami/scratch` | Same, generated name. |
| `docpathify /home/ami/scratch/Foo.md` | That file. |

Default file:
`/home/ami/src/pytch/pytch-docs/agent/<NAME>.md`.
Leave `corpus.manifest.json` alone. `agent/` is
outside helpdesk RAG. If that checkout is missing:
**Error:** pytch-docs not found. Do not invent
another repo. Do not commit generated docs.

---

## Scratch override

`docify:scratch`, `docify:html:scratch`, and the same
shape with other pieces force the local folder from
`./scripts/cli.sh scratch show` (or `cli.ps1`) and
ignore every path on that line. Remote scratch:
**Error:** scratch source is remote. Docify writes
local files only.

Scratch image attach stays image extensions only. A
markdown file written there is not an `Nimages`
attachment.

---

## HTML

Write the HTML shell when the resolved name ends in
`.html`, including a name this rule generated. No
filename and format `html` (on this line, or a stored
`format`) produces that generated `.html` name.
`docify:html` with no filename writes `CAPS.html`.
`docify:html:path:test.md` writes markdown because the
filename extension overrides. Do not print a fallback
banner. A filename override writes that format
directly.

Escape the deliverable inside a `srcdoc` body with
`&amp;`, `&lt;`, `&gt;`, and `&quot;`. Escape `"` in
the attribute. Fetch paths are the sibling basename,
never a hardcoded `scratch/test.docx`.

Pinned scripts:

- marked `18.0.14`:
  `https://cdn.jsdelivr.net/npm/marked@18.0.14/lib/marked.umd.js`
- jszip `3.10.2`:
  `https://unpkg.com/jszip@3.10.2/dist/jszip.min.js`
- docx-preview `0.4.1`:
  `https://unpkg.com/docx-preview@0.4.1/dist/docx-preview.min.js`

| Directive | Files |
|-----------|-------|
| `html`, `html:doc`, `html:full`, `html:iframe` | One fragment. srcdoc iframe. Deliverable escaped in `<pre>` inside the body. |
| `html:embed` | Fragment `<embed src="COMPANION">`. |
| `html:object` | Fragment `<object data="COMPANION">`. |
| `html:md` | Sibling `.md`, then a fragment that fetches that basename and runs `marked.parse`. |
| `html:txt` | Sibling `.txt`, then an iframe fragment whose `src` is that basename. |
| `html:docx` | Sibling `.docx` via pandoc, then a fragment that fetches that basename and calls `docx.renderAsync`. Load jszip, then docx-preview. |
| `html:page`, `html:md:page`, `html:txt:page`, `html:docx:page` | Full `<!DOCTYPE html>` page of that kind. Also accept `docx\|page`, `md\|page`, `txt\|page`, and `word\|page`. |

`COMPANION` is the sibling basename. `embed` and
`object` write a markdown sibling when the directive
does not also name `md`, `txt`, or `docx`.

After any `:page` file is written, open that HTML
file (`xdg-open` on Linux, `Start-Process` on
Windows). Do not open a fragment that is not a page.

srcdoc fragment:

```html
<iframe srcdoc="&lt;html&gt;&lt;body&gt;&lt;pre&gt;ESCAPED&lt;/pre&gt;&lt;/body&gt;&lt;/html&gt;" width="100%" height="400px" style="border: 1px solid #ccc;"></iframe>
```

Markdown fragment (sibling `NAME.md`):

```html
<div id="md-viewer">Loading...</div>
<script src="https://cdn.jsdelivr.net/npm/marked@18.0.14/lib/marked.umd.js"></script>
<script>
  fetch('NAME.md').then(res => res.text()).then(text => {
    document.getElementById('md-viewer').innerHTML = marked.parse(text);
  });
</script>
```

Docx fragment (sibling `NAME.docx`):

```html
<div id="docx-viewer" style="height:500px; overflow-y:auto; border:1px solid #ccc;">Loading...</div>
<script src="https://unpkg.com/jszip@3.10.2/dist/jszip.min.js"></script>
<script src="https://unpkg.com/docx-preview@0.4.1/dist/docx-preview.min.js"></script>
<script>
  fetch('NAME.docx').then(res => res.blob()).then(blob => {
    const container = document.getElementById('docx-viewer');
    container.innerHTML = '';
    docx.renderAsync(blob, container);
  });
</script>
```

A `:page` file wraps the matching fragment in
`<!DOCTYPE html><html><body>…</body></html>`, except
`html:page` itself, which is a full page whose body
is the srcdoc iframe.

---

## Errors

Print **Error:** and do not claim a path.

| Condition | Error |
|-----------|-------|
| `pytch-docs` checkout missing | pytch-docs not found |
| Piece contains `://` | URL not allowed |
| Bare `docify` token is an existing directory | folder needs a filename |
| Scratch kind is remote | scratch source is remote |
| Unknown store key, `docif`, `scrach` | rejected; store unchanged |

---

## Out of scope

- A `/docpathify` skill.
- Scanning file bodies, globs, quoted paths with
  spaces, remote scratch uploads.
- A code parser or unit-test harness. Walk the
  checklist below by hand.
- Editing `corpus.manifest.json`, committing
  generated docs, or changing `.grok/image`.
- Treating `docif` or `scrach` as syntax.

### Checklist

Use a temp directory as an explicit `path=` so the
walk does not write into pytch-docs.

- `phasify image` parses as `1image`.
- Bare `docify <dir>` errors.
- `docpathify <dir>` writes a `CAPS` markdown file.
- `docify:txt=test.md` writes markdown.
- `docify:scratch path=/tmp/ignored` writes only
  under the scratch folder.
- `docify:set:prefix=AMI_` then `docify:txt:NOPREFIX`
  skips the prefix once.
- `docify:html` and no filename writes a generated
  `.html` file.
- `/docify:html` with no prompt after a resume writes
  that reprint. It does not print short usage. It
  does not dispatch askify.
- `docify:html:path:test.md` writes markdown.
- `docify:html:page=out.html` writes a page, opens
  it, and the script tags are the pinned URLs above.
- `docify:html:docx=out.html` writes a pandoc docx
  sibling and a viewer fragment.

---

## Cite

A few lines in the verb's `SKILL.md`. Do not paste
this file. Put the same cite in `.grok/<verb>/`,
`.cursor/skills/<verb>/`, `.copilot/skills/<verb>/`,
and `.claude/skills/<verb>/`.

Ship a byte copy of this file at
`<docify-skill>/references/docify_contract.md`
(`.claude/skills/docify/references/docify_contract.md`,
and the same path under `.cursor/skills/docify/`,
`.grok/docify/`, and `.copilot/skills/docify/`).
Agents read that copy. It is this file. Edit this
file, then copy it again. Do not edit the copy in
place.

Workspace `docs/docify_contract.md` is this file
only when the workspace is sva-skills. In any other
project that path is absent. Do not treat that
absence as a new output folder. Do not write to the
project root.

```markdown
Cite the docify skill's `references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.
```
