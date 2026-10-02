# Family from-file contract

Shared contract. Lives in `docs/` like `docs/window_title.md`
and `docs/smart_contract.md`.
Every ify verb **cites this file**. Do not fork a second slot
syntax, path rule, splice shape, or fromify dispatch.

`from=` and `from:` splice local files into the typed prompt.
`/fromify` is the front end that defaults to plannify.

---

## Slot

`from=` and `from:` are the **same slot**. The key is
case-insensitive (`FROM=`, `From:`). No space before `=`
or `:`. The slot is one whitespace-delimited token that
**starts** with that key. The value runs to the next
whitespace. Several slots may appear in one line.

The value is a comma-separated list of paths. Split on
commas and trim space and tab around each piece. A piece
that is empty after trim is an error. That includes
`from=`, `from:`, `from=a,,b`, `from=a,`, and `from=,a`.

These are not slots:

- The English word `from`
- `from =` or `from :` (space before the mark)
- `fromhere` (a plannify mode, not a path key)
- A token that does not start with the key (`notfrom=a`)

The value has no spaces. Quotation marks are not syntax.
A piece that contains `://` is a URL and an error. Do not
fetch it. A file body is never scanned for another slot.

---

## Parse order

Apply this to the **typed invocation only**. The typed
line is the text after the invoking verb. File bodies are
literal. Do not scan them for `from=`, flags, or verb names.

1. **Flags.** Use promptify **Flag parse order**. Image
   family and pass family are independent. Keep only the
   first **numbered** instance of each (`2pass`, `1image`,
   `2 images`, `1-image`, and the other forms promptify
   already counts). Strip those tokens. They are not body
   text. Hand the N and the family to the verb that will
   run. A from-slot is one token and is not a flag, even
   when the path looks like `2pass`. Cite promptify. Do
   not restate a second flag dialect.
2. **fromify verb pick**, fromify only. Other verbs skip
   this step. See **fromify**.
3. **Slots** on the remaining typed text. See **Slot**.
4. **fromify bare files**, fromify only. Other verbs do
   not treat a bare path as a slot. See **fromify**.
5. **Reserved modes**, on the typed line after flag strip
   (and after fromify verb removal). A from-slot is one
   opaque token. A line whose first token is a slot is a
   normal task. `help`, `tldr`, and `pass` match as whole
   tokens, case-insensitive, including `--help` and `/?`.
   When the first token is one of those, or the line is
   empty, short-circuit and **do not read files**, even
   if a later token is a slot or a path. `fromhere`,
   `add`, `smart`, and the rest of that verb's modes stay
   that verb's modes. On those modes, still splice any
   from-slots, then let the verb see the spliced line.
   Exact `fromhere` with no slot is unchanged.
6. **Read, then splice.** Resolve and read every path in
   every slot. Any error stops the turn. Then splice.
   Then follow the verb on the spliced body.

---

## Paths

Expand a leading `~` or `~/` to the current user's home.
`~other` is not home-shorthand. After expansion, a path
that starts with `/` is absolute: use it as given. One
candidate. No workspace, cwd, or scratch search.

A relative path that contains `/` or `\` has two
candidates when cwd differs from the workspace root, and
one candidate when they are the same directory: the path
under the workspace root, then the path under cwd. Treat
`\` as a separator, the same as `/`.

A bare name (no `/` or `\`) has these candidates, in
order:

1. Workspace root
2. cwd, when it differs from the workspace root
3. The local scratch directory, when
   `./scripts/cli.sh scratch show` (run from the
   sva-skills repo) reports a local folder
4. Workspace `scratch/`, when that directory exists

Skip candidate 3 when scratch is unset, the show command
fails, or the source is remote. Do not create `scratch/`.
Do not fetch remote files. Remote and image attachments
stay on `Nimages`.

Look up the exact name only. No globs. No subdirectory
search. A candidate matches only when it is a regular
file. A directory does not match. Two candidates that are
the same absolute path are one match.

Zero file matches: stop, **Error:**, and the path as
written. More than one different file: stop, **Error:**,
and the match list. Do not prefer an earlier root when
two files exist. Do not invent file text. Do not splice
the other files.

---

## Splice

Replace each slot token in place with file text. Text
before, between, and after slots stays where the user
wrote it, including whitespace around the token. Typos in
that user text stay. Do not trim file text. Do not strip
a trailing newline to pull the user's next words onto the
file's last line.

One file in a slot: that file's exact text. No banner.
No added blank line.

Several files in one slot: concatenate in listed order.
A repeated path is included again. Between two files, put
a blank line and one source line. The source line names
the file that **follows** (the first file has no banner):

```text
<exact text of the first file>

--- <absolute path of the next file> ---
<exact text of the next file>
```

The path in the source line is the absolute candidate
that matched, with `~` expanded. Do not add any other
text. If the previous file does not end in a newline,
still start the blank line and the source line on their
own lines. The last file's bytes stay exact.

User whitespace stays outside that block. An empty file
is text and splices as empty. Do not scan the spliced
text for slots, flags, or verbs. `from=` inside a file
is ordinary characters.

---

## Errors

Fail closed. Print **Error:** and stop before the verb
pipeline. No partial splice. No guessed file text. The
first error wins, in slot order, then path order inside
the slot.

| Case | What to print |
|------|----------------|
| Empty piece | **Error:** empty path in `<token>` |
| URL (`://` in the piece) | **Error:** URL not allowed: `<piece>` |
| No file match | **Error:** not found: `<path as written>` |
| Two or more different files | **Error:** ambiguous: `<path as written>`, then one absolute path per line |
| Directory, image, or other non-text | **Error:** not text: `<path>` |
| Exists but cannot be read | **Error:** unreadable: `<path>` |

A file is non-text when its extension is a scratch image
extension (`png`, `jpg`, `jpeg`, `webp`, `gif`, `bmp`,
any case) or its bytes contain a NUL. Do not splice those
bytes. An image in a from-slot is not an `Nimages`
attachment.

---

## fromify

`/fromify` is in the Ify set. It selects a verb, splices
under this contract, then reads and follows that verb's
`SKILL.md` on the spliced body. It does not reimplement
that verb. `Npass` and `Nimages` stripped in step 1 are
handed through, including the scratch source promptify
already uses. fromify does not resolve images and does
not run the extra passes itself.

**Verb pick** (step 2). Scan tokens left to right. A
token selects a verb when one optional leading `/` leaves
exactly a name in the table, compared case-insensitively.
`./runnify` is a path. The first match is the verb.
Remove that token only. Words before it stay. A later
verb word stays in the body.

Never select `fromify`. Leave a `fromify` or `/fromify`
token in the body as prose. If no token matches, the
verb is **plannify**, but only when the line is a task.
Empty `/fromify` is fromify's own empty usage, not an
empty plannify run.

| Token | Selects |
|-------|---------|
| `promptify` | promptify |
| `runnify`, `promptify-run` | runnify |
| `askify`, `promptify-ask` | askify |
| `plannify`, `planify`, `promptify-plan` | plannify |
| `phasify` | phasify |
| `debugify`, `promptify-debug` | debugify |
| `addify` | addify |
| `ify` | ify |
| `docify` | docify |

`which` and `delete` are mode aliases, not verbs. They
stay prose. These are not verbs either: `image`,
`imagine`, `help`, `check-work`, `code-review`,
`create-skill`, `debug-kickoff`.

**Bare files** (step 4), after explicit slots are taken.
A remaining token is a file slot when any comma-piece
contains `/` or `\`, starts with `~` or `.`, or has a
dot-extension (a `.` and at least one character after it
in that piece). If one piece is path-like, every piece
of that token is a path. An empty piece is an error. A
token with no path-like piece is prose, comma included.
Other verbs do not do this step. `fromify a.txt,b.txt`
is the same slot as `plannify from=a.txt,b.txt`.

**Short-circuit.** After flag strip:

- No tokens left: fromify empty usage. Stop. No read.
- First token `help`, `tldr`, or `pass`: fromify's own
  mode. Stop. No verb pick, no plannify default, no read.
- Otherwise pick a verb (default plannify only if this
  remaining line is a task). If nothing remains, or the
  first remaining token is `help`, `tldr`, or `pass`,
  short-circuit **that** verb and do not read files.

`fromify 2pass help` is still help. The flag does not
open a file. `fromify 2pass runnify test.txt` is runnify
of the file, with `2pass` handed through.
`fromify please runnify test.txt` selects runnify,
leaves `please`, and splices `test.txt`.

---

## Examples

**1. Guidance file.**

```text
plannify from:scratch/test_guidance.md Ignore the optional guidance section
```

plannify's body is the guidance file's exact text, then
the user's space, then `Ignore the optional guidance section`.
One file, so no source line.

**2. Two slots. Typos stay.**

```text
plannify get the list of recipients from from=/home/ami/phonelist.csv and do nopt include ... from=dnd_list.csv do not include ...
```

The body, in order:

1. `get the list of recipients from `
2. Exact text of `/home/ami/phonelist.csv` (absolute, as given)
3. ` and do nopt include ... `
4. Exact text of the one `dnd_list.csv` match
5. ` do not include ...`

The word `from` stays. `nopt` stays. Each slot is one
file, so there is no source line.

**3. fromify, two files, defaults to plannify.**

`/fromify file1[,file2,...]` is `plannify from=file1,file2,...`
when those names are file slots. A name with no slash, no
leading `~` or `.`, and no dot-extension is prose, so the
concrete line is:

```text
fromify file1.txt,file2.txt
```

which is `plannify from=file1.txt,file2.txt`. One slot,
two files:

```text
<exact text of file1.txt>

--- <absolute path of file2.txt> ---
<exact text of file2.txt>
```

**4. fromify picks a verb.**

```text
fromify runnify test.txt
```

is runnify plus the exact text of `test.txt`. The token
`runnify` is removed. No extra words. No source line.

---

## Scope

Ify set only: promptify, runnify, askify, plannify,
phasify, debugify, addify, ify, fromify, docify.

Not Grok utilities: `image`, `imagine`, `help`,
`check-work`, `code-review`, `create-skill`,
`debug-kickoff`.

Out of scope: a code parser, quoted paths with spaces,
remote files, recursive includes, flag or verb detection
inside file bodies, and globs.

fromify may select `docify`. Docify never selects itself.
Cite `docs/docify_contract.md` for the write. Do not invent
a second `from=` dialect.

---

## Cite

A few lines in the verb's `SKILL.md`. Do not paste this
file. Put the same cite in `.grok/<verb>/`,
`.cursor/skills/<verb>/`, and `.copilot/skills/<verb>/`.

```markdown
## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.
```

fromify's `SKILL.md` cites this file, then follows the
selected verb's `SKILL.md`. Promptify keeps the flag
dialect: from-slots are not flags; after flag strip,
follow this contract.

---

## Adding a verb

1. Add it to **Scope** and the fromify pick table.
2. Thin cite in that verb's `SKILL.md` in all three trees.
3. Do not invent a second from= dialect.
