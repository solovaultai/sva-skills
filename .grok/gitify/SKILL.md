---
name: gitify
description: >-
  Gitify — add each dirty worktree and make one commit. Use when
  the user runs /gitify or says "gitify". Empty /gitify commits
  every dirty repo under the host's open folder, not short usage.
  A repo basename (pytch-fluent) or a component name (fluent)
  selects one repo. tag or tag:NAME annotated-tags that commit.
  msg replaces, prepends, or postfixes the message. link:TEXT
  stamps [multirepo-link=TEXT] on every commit in the bunch.
  dry-run prints that action list and writes nothing. status,
  push, log, diff, commit, and git are stop words, not repo names.
  Any other unmatched token stops with no git write. /gitify help or
  /gitify --help (also /?) prints the full reference. /gitify tldr
  prints the short page. /gitify pass and pass help print the Pass
  (Npass) subsection. Does not push, amend, skip hooks, or change
  git config. No smart mode. Recognizes nimages / Nimages / N
  images / N-images and npass / Npass / N-pass / N pass per
  promptify Flag parse order (stripped before the directives;
  gitify does not run its own pass loop).
metadata:
  short-description: "Add each dirty worktree and make one commit"
---

# Gitify (= add and commit)

You are running **Gitify** (`/gitify`) — a **thin commit verb**
in the Promptify family. For each dirty repo in the bunch you
`git add -A`, then make one commit. You may annotated-tag that
commit. You do not push, amend, skip hooks, or change git config.
You do not plan, execute, debug, or answer. There is no `smart`
mode. Empty `/gitify` commits every dirty repo under the open
folder, not short usage.

1. Strip `Nimages` / `Npass` on the typed line (Flag parse order).
2. Help, tldr, and pass print only, then stop. They do not touch git.
3. Splice `from=` / `from:` files. Strip a typed-line `docify`.
4. Parse `tag`, `msg`, `link`, and `dry-run`. One optional selector
   names one repo. A stop word or any other unmatched token stops
   with no git write.
5. Resolve the open folder and the bunch. Classify archived, clean,
   and dirty. Path sort is fixed.
6. Preflight every dirty repo. Build one action list before the
   first `git add`. `dry-run` prints that list and writes nothing.
   A live run executes that same list. Tag only after that commit
   succeeds.
7. Set the window title when a live bunch commits, including empty
   `/gitify`.

`gitify` with no slash is the same command. Canonical slash is
`/gitify`. No alias folder.

Follow `~/.grok/skills/promptify/SKILL.md` (repo:
`.grok/promptify/SKILL.md`) for **Flag parse order**
only. Do not run a second pass loop. Do not run Scratch images.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then take the
first whole token, case-insensitive. Reserved first tokens are
modes, not directives: `help`, `tldr`, `pass`, `--help`, `/?`.
`pass help` is pass. These do not add, commit, tag, or retitle.

- First token `help`, `--help`, or `/?`: **read and print**
  `references/HELP.md` (this skill folder) and **stop**. Further
  words on that line (`help me …`) stay on Help. They do not commit.
- First token `tldr`: **read and print** `references/TLDR.md` and
  **stop**. Exact `tldr` is that short page. There is no `tldr help`
  alias. Further words stay on tldr.
- First token `pass`, including body `pass help`: print the
  **Pass (`Npass`)** section of `references/HELP.md` and **stop**.
  There is no `/pass` skill. Further words stay on pass.

`password` and `helpful` are not the whole tokens `pass` and
`help`. They are leftover tokens on a commit line.

Empty `/gitify` is a real commit, not Help and not short usage.
Same exception shape as empty `/saveify` (a real save) and empty
`/phasify` (Next).

```text
/gitify                 — every dirty repo under the open folder
/gitify pytch-fluent    — that repo (basename)
/gitify fluent          — that component (leading <parent>- removed)
/gitify tag             — annotated tag, derived name
/gitify tag:NAME        — annotated tag NAME (tag=NAME is the same)
/gitify msg:TEXT        — TEXT replaces the generated message
/gitify msg:+TEXT       — labeled custom block before the message
/gitify msg:TEXT+       — labeled custom block after the message
/gitify link:TEXT       — [multirepo-link=TEXT] on every commit
/gitify dry-run         — print the action list; write nothing
/gitify help            — full reference (also --help, /?)
/gitify tldr            — short form (stop)
/gitify pass help       — Pass (Npass) subsection (also `pass`)
```

---

## Flag parse order (`Nimages` / `Npass`)

On the **typed line only**, follow promptify **Flag parse order**
(first numbered `Nimages` / `Npass` only). Strip them before help,
tldr, pass, or the directives. They are not body text and not
directives. Do not fork that parse.

Gitify does not loop, does not open scratch for `Nimages`, and
does not print the scratch or Npass acknowledgements. One commit
per dirty repo. A line that is only flags is an empty `/gitify`
commit of every dirty repo under the open folder.

## Named images (`img`)

Do not treat `img` as a gitify directive. An `img=` / `img:` token
is a leftover. Stop with no git write.

---

## Parse

The typed line is the text after the verb. File bodies are
literal. Do not scan them for `tag`, `msg`, `link`, `dry-run`,
`from=`, `docify`, or a selector.

1. **Flags.** Already stripped.
2. **Help, tldr, pass.** First token, above. Stop. Do not read
   files.
3. **From files.** Cite `docs/from_contract.md`. Splice, then
   continue. Any from-error stops the turn. No `git add`.
4. **Docify.** Strip typed-line `docify` / `docpathify` per the
   docify skill's `references/docify_contract.md`. Those tokens
   are not leftovers. The write happens after a successful commit.
5. **Directives and one selector.** Every remaining token is one
   directive or the optional selector.

`:` and `=` are the same. The first one in the token splits key
and value. The key is case-insensitive. The value is the rest of
that token, unchanged. A value has no spaces. Quotation marks are
not syntax. `msg:hello world` is `msg:hello` plus leftover `world`.

| Token | Meaning |
|-------|---------|
| `tag` | Bare. Derive a short name. |
| `tag:NAME` / `tag=NAME` | Use NAME as written. |
| `msg:TEXT` / `msg=TEXT` | Replace the generated message with TEXT. |
| `msg:+TEXT` / `msg+=TEXT` | Labeled custom block before the generated message. |
| `msg:TEXT+` / `msg=TEXT+` | Labeled custom block after the generated message. |
| `link:TEXT` / `link=TEXT` | End every commit message with `[multirepo-link=TEXT]`. |
| `dry-run` | Bare token. Print the action list. Do not write. |

A `msg` value that starts with `+` and ends with `+` (`msg:+hello+`,
`msg:+`) is **Error**. An empty value (`msg`, `msg:`, `msg=`,
`tag:`, `tag=`, `link`, `link:`, `link=`) is **Error**. Two `msg`
tokens is **Error**. Two `tag` tokens is **Error**. Two `link`
tokens is **Error** before any write.

`link:TEXT` and `link=TEXT` are one token. The value has no spaces.
`link:hello world` is `link:hello` plus leftover `world`. `dry-run`
is a bare token. Two of them is **Error**. `dry-run:TEXT` and
`dry-run=TEXT` are **Error** before any write.

A token that is not a directive is a selector, unless it is a stop
word. One selector is optional. Two selector tokens is **Error**
before any write.

`status`, `push`, `log`, `diff`, `commit`, and `git` are stop
words. They are not repo names and not selectors. A stop word, or
any other unmatched token, stops the turn with no write. Print
that gitify only adds, commits, and optionally tags. It is not a
git engine. Do not add, commit, or tag.

---

## Open folder

The scan root is the folder the running host has open. Not a
historical project list, and not every repo under `/home/ami/src`.

Grok: the cwd of the grok process that is running this command.
`~/.grok/active_sessions.json` records cwd, but only the running
session counts.

Candidates, one level only:

- The open folder, if it is a git repo.
- Each immediate child directory that has `.git`.

Example: open folder `/home/fastpytch/src/pytch` (or
`/home/ami/src/pytch`) includes `pytch-fluent`, `pytch-api`, and
the other child git repos. It does not include sibling products
and it does not walk into a repo's subfolders.

No selector uses only these candidates. Do not walk up to every
repo under `src` when the user did not name one.

An empty candidate set (the open folder is not a git repo and no
immediate child has `.git`) is **Error:** not a git repo. No write.

## Selector

One optional token that is not a directive and not a stop word.
`pytch-fluent` is the repo basename. `fluent` is the component:
the basename with a leading `<parent>-` removed, so parent
`pytch` and basename `pytch-fluent` yield `fluent`. `<parent>` is
the parent directory's basename. A basename that does not start
with `<parent>-` has no component name.

Named lookup searches the open-folder candidates, then git repos
one or two levels under the nearest ancestor named `src`. That is
how `fluent` resolves from `/home/ami/src/sva/sva-skills`. Count
each repo path once. Exact basename wins over a component match:
if any exact basename match exists, drop component-only matches.
Zero matches, or two non-archived matches, is **Error** before
any write. Two selector tokens is **Error**. One non-archived
match is the bunch. Archived name-twins are not a second match.
If the only matches are archived, note each and do not add,
commit, or tag.

## Archived and dirty

Before a checkin, classify each repo in the bunch. With no
selector the bunch is the open-folder candidates. With a selector
the bunch is the one resolved repo, or the archived matches when
those are the only matches. Sort by full path so the order does
not change between dry-run and live.

- **Archived.** A path segment `archive` (case-insensitive), or a
  GitHub `origin` whose `gh repo view --json isArchived` is true.
  Note it in the printed run notes. Do not add, commit, or tag.
  If `gh` cannot answer, the path rule still applies and a failed
  `gh` call does not count as archived.
- **Clean.** Skip. Mention it in the notes. No empty commit.
- **Dirty.** One gitify commit, using the rules already landed
  (`git add -A`, one commit, optional annotated tag, `msg`
  replace, prepend, or postfix).

Print the run notes. Do not write a notes file.

## Link and dry-run

`link:TEXT` and `link=TEXT` are one token. The value has no spaces.
`link:hello world` is `link:hello` plus leftover `world`. Two
`link` tokens, or an empty value, is **Error** before any write.

Every commit message in the bunch ends with this line, after `msg`
replace, prepend, or postfix:

```text
[multirepo-link=TEXT]
```

The brackets are part of the line. No `link` token means no line.

`dry-run` is a bare token. Two of them is **Error**. It prints the
run notes and, for each dirty repo, the action that would run:
repo path, `git add -A`, the full commit message, and the tag name
when one was requested. It does not stage, commit, tag, or edit
git config. It does not write a notes file.

Live run (no `dry-run`) executes that same list in that same order,
with those same messages and tag names. Build the list before the
first `git add`. A secret-like path or an existing tag in any dirty
repo aborts the whole bunch with no write; dry-run prints that
error and also writes nothing. A commit hook that rejects a live
commit prints the hook output, does not tag that commit, and does
not continue to later repos. Dry-run cannot simulate hooks.

Dry-run does not retitle. A live bunch that commits does. Cite
`docs/window_title.md`. Prefix `GIT:`. One repo keeps today's
summary. Several repos use three to six words, the link token when
that token is already that short.

---

## Preflight

Do this before any write. Reads are fine. `git add`, `git commit`,
and `git tag` are not. A secret-like path or an existing tag in
any dirty repo aborts the whole bunch with no write. Dry-run prints
that error and also writes nothing.

- Not a git repo, or an empty open-folder candidate set on a bare
  run: **Error:** not a git repo.
- Selector: zero matches, or two non-archived matches, is
  **Error** before any write.
- Nothing to commit (no staged, unstaged, or untracked change that
  `git add -A` would take): clean. Say so in the notes. Do not
  create an empty commit. Do not tag.
- A path that would be staged looks like a secret: **Error.** No
  add, no commit, in this repo or any other repo in the bunch.
  Secret-like means the basename is `.env` or starts with `.env.`,
  or the basename is `credentials.json`, or it is a private key
  (`id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`, or a basename
  ending in `.pem` or `.key`, and not a name ending in `.pub`).
- Requested tag already exists, or the derived name already
  exists: **Error:** tag exists: `<name>`. No add, no commit, in
  this repo or any other repo in the bunch. Do not move an
  existing tag. Do not pick a different name.
- `git check-ref-format refs/tags/<name>` fails: **Error** before
  `git add`. No add, no commit.
- No upstream: say so. This is not a stop. Build the message from
  the working tree and commits since the last tag. No tag either:
  working tree only.

Derive a bare `tag` name before `git add`, from the commit message
you are about to use and from what changed since the last tag.
Short, lowercase, hyphenated, no spaces, a legal tag name. If that
tag exists, stop the bunch. Do not append `-2`.

---

## Commit

For each dirty repo, from that repository root, in path order:

```text
git add -A
```

Then one commit in that repo. The message is extensive. Do not
push. Do not amend. Do not pass `--no-verify`. Do not change git
config. Do not run `git commit -a` in place of `git add -A`.

**Generated message.** Subject plus a body, from this iteration,
for that repo:

- The working tree (what `git add -A` will commit).
- When an upstream exists: commits not on that upstream.
- When no upstream, and a tag exists: commits since that tag, and
  say there is no upstream.
- When no upstream and no tag: the working tree only, and say
  there is no upstream.
- Plans, docs, and other artifacts those changes touch. Read them.
  Do not stop at a diff stat.

**Custom block.** Label it so the custom part is obvious. Replace
uses the value as the message, with no generated body and no label.
The same `msg` value is applied in every repo in the bunch. When a
`link` token is present, this line is still appended after replace,
prepend, or postfix. The brackets are part of the line. No `link`
token means no line.

```text
[multirepo-link=TEXT]
```

Prepend (`msg:+TEXT`):

```text
--- custom ---
TEXT
--- end custom ---

<generated message>
```

Postfix (`msg:TEXT+`):

```text
<generated message>

--- custom ---
TEXT
--- end custom ---
```

If the commit hook rejects the commit, print the hook output. Do
not tag that commit. Do not continue to later repos. Do not retry
with `--no-verify`. Do not amend. Leave the index as the hook left
it. Dry-run cannot simulate hooks.

When the commit succeeds and a tag was requested, annotated-tag
that commit. `git tag -a <name> -m "<subject>"`. Do not use `-f`.
Do not create a lightweight tag. Do not move an existing tag. Do
not push the tag. The same requested `tag:NAME` is used in every
repo. A bare `tag` is derived per repo, before the first `git add`.

A live run prints the run notes, then for each commit the hash,
the subject, and the tag name when one was made. `dry-run` prints
the run notes and the action list, and it does not print a hash.

---

## From files

Cite `docs/from_contract.md`. Do not restate it.
Help, tldr, and pass do not read files.

## Docify

Cite the docify skill's `references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and dry-run do not write that file. Empty `/gitify` still commits.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `GIT:`.
Dry-run does not retitle. A live bunch that commits does, including
empty `/gitify`. One repo keeps today's summary: three to six words
of the change. Several repos use three to six words, the link token
when that token is already that short. Whole name at most 48
characters. Do not invent a second prefix.

Help, tldr, pass, `--help`, `/?`, and `dry-run` do not retitle. A
stop (leftover token, selector error, nothing to commit, tag
exists, secret, not a repo, hook rejection) does not retitle.
`GIT` is not a phasify ancestor prefix.

## Hard rules

- Thin commit verb. For each dirty repo, `git add -A`, then one
  commit. Optional annotated tag. Do not push. Do not amend. Do
  not skip hooks. Do not change git config. Do not add a
  `scripts/cli.sh` subcommand.
- Empty `/gitify` commits every dirty repo under the open folder.
  It sets `GIT:` when a commit happens. It is not short usage.
- One optional selector. A basename, or a component (basename
  with a leading `<parent>-` removed). Named lookup is the
  open-folder candidates, then git repos one or two levels under
  the nearest ancestor named `src`. Exact basename wins. Zero
  matches, or two non-archived matches, is **Error** before any
  write. Two selector tokens is **Error**. No selector does not
  walk every repo under `src`.
- Archived: a path segment `archive` (case-insensitive), or
  `gh repo view --json isArchived` true. Note it. Do not add,
  commit, or tag. A failed `gh` call is not archived. Clean:
  note it. No empty commit. Dirty: one landed gitify commit.
  Path sort is fixed.
- One `tag` token. One `msg` token. One `link` token. `:` and
  `=` are the same. Keys are case-insensitive. A value has no
  spaces. `+` on both sides, an empty value, or two of either
  `tag` or `msg` is **Error** before `git add`. Two `link` tokens,
  or an empty `link` value, is **Error** before any write.
  `link:hello world` is `link:hello` plus leftover `world`.
- Every commit message in the bunch ends with
  `[multirepo-link=TEXT]` after `msg` replace, prepend, or postfix.
  The brackets are part of the line. No `link` token means no line.
- `dry-run` is one bare token. Two of them is **Error**. It prints
  the run notes and, for each dirty repo, the repo path,
  `git add -A`, the full commit message, and the tag name when one
  was requested. It does not stage, commit, tag, edit git config,
  or write a notes file. A live run executes that same list in
  that same order, with those same messages and tag names. Build
  the list before the first `git add`.
- `status`, `push`, `log`, `diff`, `commit`, and `git` are stop
  words, not repo names. Any other unmatched token stops with no
  git write. Gitify only adds, commits, and optionally tags. It
  is not a git engine.
- A secret-like path or an existing tag in any dirty repo aborts
  the whole bunch with no write. Dry-run prints that error and
  also writes nothing.
- Help, tldr, and pass print their page and stop. Exact `tldr`
  is the short page. They do not touch git and do not retitle.
- Preflight before any write. Nothing to commit: say so. No empty
  commit. No tag. An existing tag is **Error** before `git add`.
  Do not move it. A secret-like path is **Error** before `git add`.
  No upstream: say so, and build the message from the working tree
  and commits since the last tag, or the working tree only.
- Hook rejection: print the hook output. Do not tag that commit.
  Do not continue to later repos. Dry-run cannot simulate hooks.
- Dry-run does not retitle. A live bunch that commits does. One
  repo keeps today's summary. Several repos use three to six words,
  the link token when that token is already that short.
- Cite `docs/from_contract.md`, the docify skill's
  `references/docify_contract.md`, and `docs/window_title.md`.
  Prefix `GIT:`.
