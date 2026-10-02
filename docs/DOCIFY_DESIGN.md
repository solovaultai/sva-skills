# Docify design

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

**Note 2e3b.** If the file name is not `.html` or no name is specified (like just a folder or no name at all), then the HTML render fails. Render as markdown with a line at the top showing the command that was used and a note that this was modified due to type inconsistencies (explain the issue).

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
