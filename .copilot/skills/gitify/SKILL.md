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
  dry-run prints that action list and writes nothing. forcemain
  merges the checked-out branch into main and leaves the repo on
  main. all walks every git repo under the open folder and pushes
  origin main. status, push, log, diff, commit, and git are stop words,
  not repo names. Any other unmatched token stops with no git
  write. /gitify help or /gitify --help (also /?) prints the full
  reference. /gitify tldr prints the short page. /gitify pass and
  pass help print the Pass (Npass) subsection. After a successful
  commit, runs `git push origin <current-branch>`. Detached HEAD
  aborts before `git add`. Does not amend, skip hooks, or change
  git config. Does not push tags. Does not pull. Does not use
  `--force`. No smart mode. Recognizes nimages / Nimages / N
  images / N-images and npass / Npass / N-pass / N pass per
  promptify Flag parse order (stripped before the directives;
  gitify does not run its own pass loop).
argument-hint: "[repo|tag|msg|link|dry-run|forcemain|all|help|tldr|pass]"
user-invocable: true
disable-model-invocation: true
---

# Gitify (= add and commit)

You are running **Gitify** (`/gitify`) — a **thin commit verb**
in the Promptify family. For each dirty repo in the bunch you
`git add -A`, then make one commit, then
`git push origin <current-branch>`. Before any `git add`, read
the branch with `git rev-parse --abbrev-ref HEAD`. Name `main`
pushes `git push origin main`. Any other branch name, including
`master`, pushes `git push origin <that-name>`. Detached `HEAD`
is **Error** before `git add`. No add, no commit, no push, in
this repo or any later repo in the bunch. You may annotated-tag
that commit before the push. `forcemain` is the only merge. On
`main` it adds nothing. On any other branch it pushes that
branch, merges it into `main`, pushes `main`, deletes the branch,
and finishes on `main`. `all` walks every git repo under the
open folder. Without `forcemain`, the branch must be `main` and
the push is `git push origin main`. You do not amend, skip hooks, or change
git config. You do not push tags. You do not use `--force`. You
do not pull.
You do not plan, execute, debug, or answer. There is no `smart`
mode. Empty `/gitify` commits every dirty repo under the open
folder, not short usage.

1. Strip `Nimages` / `Npass` on the typed line (Flag parse order).
2. Help, tldr, and pass print only, then stop. They do not touch git.
3. Splice `from=` / `from:` files. Strip a typed-line `docify`.
4. Parse `tag`, `msg`, `link`, `dry-run`, `forcemain`, and `all`. One optional selector
   names one repo. A stop word or any other unmatched token stops
   with no git write.
5. Resolve the open folder and the bunch. Classify archived, clean,
   and dirty. Path sort is fixed.
6. Preflight every dirty repo. Read the branch before the first
   `git add`. Detached `HEAD` aborts before `git add`. Build one
   action list before that add. `dry-run` prints that list and
   writes nothing.
   A live run executes that same list. Tag only after that commit
   succeeds.
7. Set the window title when a live bunch commits, including empty
   `/gitify`.

`gitify` with no slash is the same command. Canonical slash is
`/gitify`. No alias folder.

Follow `~/.copilot/skills/promptify/SKILL.md` (repo:
`.copilot/skills/promptify/SKILL.md`) for **Flag parse order**
only. Do not run a second pass loop. Do not run Scratch images.

---

## Help (`help` / `--help` / `/?` / `tldr`)

Strip `Nimages` / `Npass` first (Flag parse order). Then take the
first whole token, case-insensitive. Reserved first tokens are
modes, not directives: `help`, `tldr`, `pass`, `--help`, `/?`.
`pass help` is pass. These do not add, commit, tag, push, merge,
or retitle.

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
/gitify forcemain       — push this branch, merge it into main, finish on main
/gitify all             — every git repo under the open folder; commit; push origin main
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
`forcemain`, `all`, `from=`, `docify`, or a selector.

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
| `forcemain` | Bare token. Case-insensitive. On `main`, adds nothing. On any other branch, push it, merge it into `main`, and finish on `main`. |
| `all` | Bare token. Case-insensitive. Walk every git repo under the open folder. An ancestor-ignored nested repo is skipped before preflight. Without `forcemain`, a repo that is not ignored must be on `main`, and the push is `git push origin main`. |

A `msg` value that starts with `+` and ends with `+` (`msg:+hello+`,
`msg:+`) is **Error**. An empty value (`msg`, `msg:`, `msg=`,
`tag:`, `tag=`, `link`, `link:`, `link=`) is **Error**. Two `msg`
tokens is **Error**. Two `tag` tokens is **Error**. Two `link`
tokens is **Error** before any write.

`link:TEXT` and `link=TEXT` are one token. The value has no spaces.
`link:hello world` is `link:hello` plus leftover `world`. `dry-run`
is a bare token. Two of them is **Error**. `dry-run:TEXT` and
`dry-run=TEXT` are **Error** before any write. `forcemain` is a
bare token, case-insensitive, same shape as `dry-run`. One token.
Two of them is **Error** before any write. `forcemain:TEXT` and
`forcemain=TEXT` are **Error**. It is not a selector and not a
stop word. Typed `push` stays a stop word. That word is not this
directive. It applies to every dirty repo in the bunch, the same
way `tag` and `msg` do. A clean repo is still skipped.

`all` is a bare token, case-insensitive, same shape as `dry-run`.
One token. Two of them is **Error** before any write. `all:TEXT`
and `all=TEXT` are **Error**. It is not a selector and not a stop
word. A selector token together with `all` is **Error** before any
write. The walk is the bunch.

A token that is not a directive is a selector, unless it is a stop
word. One selector is optional. Two selector tokens is **Error**
before any write.

`status`, `push`, `log`, `diff`, `commit`, and `git` are stop
words. They are not repo names and not selectors. A stop word, or
any other unmatched token, stops the turn with no write. Print
that a typed `push` is not a repo and not a request. That word
is not the `forcemain` directive. After a successful commit,
gitify runs `git push origin <current-branch>`. It is not a git
engine. Do not add, commit, tag, or push when a stop word aborted
the turn.

---

## Open folder

The scan root is the folder the running host has open. Not a
historical project list, and not every repo under `/home/ami/src`.

Copilot: the open folder.

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
With `all`, empty means no directory under the open folder contains
`.git`. That is the same **Error:**.

## All

`all` replaces the one-level candidate list. The scan root is still
the open folder. Do not walk up to `src`. Do not include siblings
of the open folder.

Walk every directory under the open folder. A directory that
contains `.git` is a repo. Keep walking its children so a nested
repo is found. Do not walk into a directory named `.git` or
`node_modules`. Count each repo path once. Sort by full path.

Before preflight, classify a nested repo **ignored** when any
ancestor git repo ignores that path. Do not hardcode a directory
name. From that ancestor, `git check-ignore` exit 0 means ignored.
A path no ancestor ignores stays in the walk. An ignored repo is
skipped like an archived repo. Print it in the run notes, in path
order. Do not add, commit, tag, push, checkout, merge, or reset
it. Do not require `main`. Exclude it before detached `HEAD`,
non-`main`, a dirty tree, a missing upstream, and secret-like
checks. Those facts do not abort this repo or any other repo.
`forcemain` does not commit it. `dry-run` lists the skip and
writes nothing.

Without `forcemain`, every dirty repo in that walk that is not
ignored must be on `main` before `git add`. Any other branch name, including
`master`, is **Error** before `git add`. No add, no commit, no
push, in that repo or any later repo. After the commit, the push
is `git push origin main`.

With `forcemain`, `all` only changes the bunch. `forcemain` still
owns the merge and the push sequence.

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
Zero matches, or two matches that are neither archived nor
ignored, is **Error** before any write. Two selector tokens is
**Error**. One match that is neither archived nor ignored is the
bunch. Archived and ignored name-twins are not a second match.
If the only matches are archived or ignored, note each and do not
add, commit, tag, or push.

## Archived and dirty

Before a checkin, classify each repo in the bunch. With no
selector the bunch is the open-folder candidates. With a selector
the bunch is the one resolved repo, or the archived or ignored
matches when those are the only matches. Sort by full path so the order does
not change between dry-run and live.

- **Ignored.** A nested repo whose path any ancestor git repo
  ignores. Test from that ancestor with `git check-ignore`. Exit 0
  means ignored. Do not hardcode a directory name. Note it in the
  printed run notes, in path order. Do not add, commit, tag, push,
  checkout, merge, or reset it. Do not require `main`. This class
  is decided before preflight. Detached `HEAD`, a non-`main`
  branch, a dirty tree, a missing upstream, or a secret-like path
  inside it does not abort this repo or any other repo.
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
repo path, `git add -A`, the full commit message, the tag name
when one was requested, and `git push origin <branch>`. It does
not stage, commit, tag, push, checkout, merge, delete, or edit
git config. It does not write a notes file. It does not pull.
With `forcemain` on `main`, that push line is
`git push origin main` and nothing more. With `forcemain` on any
other branch, it prints these commands in this order and does not
run them: `git push origin <branch>`, `git checkout main`,
`git merge <branch>`, `git push origin main`,
`git branch -d <branch>`, `git push origin --delete <branch>`.
With `all` and no `forcemain`, that push line is
`git push origin main` and nothing more. An ancestor-ignored
nested repo is a skip in the run notes, not an action.

Live run (no `dry-run`) executes that same list in that same order,
with those same messages and tag names. Build the list before the
first `git add`. A secret-like path aborts the whole bunch unless
`git check-attr filter` from that repo is `git-crypt`. An existing
tag still aborts the bunch. Dry-run prints that error and also
writes nothing. A commit hook that rejects a live
commit prints the hook output, does not tag that commit, and does
not continue to later repos. Dry-run cannot simulate hooks.

Dry-run does not retitle. A live bunch that commits does. Cite
`docs/window_title.md`. Prefix `GIT:`. One repo keeps today's
summary. Several repos use three to six words, the link token when
that token is already that short.

---

## Preflight

Do this before any write. Reads are fine. `git add`, `git commit`,
and `git tag` are not. A secret-like path whose git-crypt filter
is not `git-crypt`, or an existing tag, in any dirty repo aborts
the whole bunch with no write. Dry-run prints that error and also
writes nothing.

- **Ignored** repos are already excluded. Do not run the checks
  below on them.
- Detached `HEAD`: **Error** before `git add`. In every dirty
  repo that is not ignored, read the branch with `git rev-parse --abbrev-ref HEAD`.
  When that name is `HEAD`, no add, no commit, no push, in this
  repo or any later repo in the bunch.
- `all` without `forcemain`: the branch must be `main`. Any other
  name, including `master`, is **Error** before `git add`. No add,
  no commit, no push, in this repo or any later repo.
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
  Git-crypt ciphertext is not that error. From that repo, run
  `git check-attr filter -- <path>`. When the value is `git-crypt`,
  the clean filter will store ciphertext, so that path does not
  abort the bunch. Do not unlock, decrypt, or read plaintext to
  decide. A secret-like path whose filter is unset, or any other
  value, is still **Error** and aborts the whole bunch before
  `git add`. Note a ciphertext path in the run notes. Dry-run
  lists it and writes nothing.
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

For each dirty repo, from that repository root, in path order.

Before any `git add`, read the branch with
`git rev-parse --abbrev-ref HEAD`.

- Name `main`: after a successful commit, `git push origin main`.
- Any other branch name, including `master`: `git push origin <that-name>`.
- Detached `HEAD`: **Error** before `git add`. No add, no commit,
  no push, in this repo or any later repo in the bunch.

```text
git add -A
```

Then one commit in that repo. The message is extensive. Do not
amend. Do not pass `--no-verify`. Do not change git config. Do
not run `git commit -a` in place of `git add -A`. After that
commit succeeds, and after an optional annotated tag, push the
checked-out branch as specified below. Do not use `--force`. Do
not push tags. Do not pull.

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
- When `all` is set, the generated message is as complete as the
  internal tracking documentation allows. Read the tracking docs
  in that repo that the diff touches, or that name the changed
  behavior: `docs/` markdown, the README command rows for the
  changed verb, and any `SKILL.md`, `HELP.md`, or `TLDR.md` in
  the diff. Write the subject and body from those docs and from
  the working tree. If they do not describe the change, say so
  and describe the diff. Do not stop at a diff stat. A `msg`
  replace still replaces this generated message.

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
not tag that commit. Do not push. Do not continue to later repos.
Do not retry with `--no-verify`. Do not amend. Leave the index as
the hook left it. Dry-run cannot simulate hooks.

When the commit succeeds and a tag was requested, annotated-tag
that commit before the push. `git tag -a <name> -m "<subject>"`.
Do not use `-f`. Do not create a lightweight tag. Do not move an
existing tag. Do not push the tag. The same requested `tag:NAME`
is used in every repo. A bare `tag` is derived per repo, before
the first `git add`.

Then push from that repository root. Do not use `--force`. Do
not push tags. Do not pull. A clean repo still has no commit and
no push. A rejected commit still does not push.

No `forcemain` and no `all`: run `git push origin <branch>` and
stay on that branch. There is no merge and no branch to close. On
`main` that command is `git push origin main`.

`all` without `forcemain`: the branch is already `main`. After the
commit, run `git push origin main` and stay on `main`.

When `forcemain` is set and the checked-out branch is `main`,
`forcemain` adds nothing: commit, then `git push origin main`,
and stay on `main`. There is no merge and no branch to close.

When `forcemain` is set and the checked-out branch is not `main`,
after the commit and the optional local tag:

1. `git push origin <branch>`
2. `git checkout main`
3. `git merge <branch>`
4. `git push origin main`
5. `git branch -d <branch>`
6. `git push origin --delete <branch>`

When that sequence finishes, `HEAD` is `main`. The feature branch
is gone locally and on `origin`. The tag is still not pushed.

There is no other merge. Nothing merges into a branch other than
`main`. No merge directive besides `forcemain`.

If the push fails, print the output. Do not continue to later
repos. Do not amend. Failure stops the bunch. Do not use
`--force` or `git branch -D`.

- Branch push fails: stay on that branch. Do not merge. Do not
  delete.
- `git checkout main` fails: stay on that branch. Do not delete.
- Merge fails: `git merge --abort`, then `git checkout <branch>`.
  Do not delete. Do not push `main`.
- `git push origin main` fails: stay on `main`. Do not delete the
  branch.
- `git branch -d` fails: do not delete the remote branch.
- Remote delete fails: print the output. The repo is already on
  `main`. Still do not continue to later repos.

`dry-run` prints `git push origin <branch>`, and when `forcemain`
applies off `main` it prints those six commands in that order. It
does not checkout, merge, delete, or push. Help, tldr, pass, and
dry-run do not push or merge.

A live run prints the run notes, then for each commit the hash,
the subject, the tag name when one was made, and that
`git push origin <branch>` ran. When the `forcemain` sequence
finishes, also say `HEAD` is `main`. `dry-run` prints the run
notes and the action list, including that push command, and it
does not print a hash and does not push.

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
exists, secret, not a repo, detached `HEAD`, hook rejection) does
not retitle.
`GIT` is not a phasify ancestor prefix.

## Hard rules

- Thin commit verb. For each dirty repo, `git add -A`, then one
  commit, then `git push origin <current-branch>`. Before any
  `git add`, read the branch with
  `git rev-parse --abbrev-ref HEAD`. Name `main`:
  `git push origin main`. Any other branch name, including
  `master`: `git push origin <that-name>`. Detached `HEAD` is
  **Error** before `git add`. No add, no commit, no push, in this
  repo or any later repo in the bunch. Optional annotated tag
  before that push. Do not push tags. Do not pull. Do not amend.
  Do not skip hooks. Do not change git config. Do not use
  `--force`. Do not add a `scripts/cli.sh` subcommand. A clean
  repo still has no commit and no push. A rejected commit still
  does not push. If the push fails, print the output, do not
  continue to later repos, do not amend.
- Empty `/gitify` commits every dirty repo under the open folder.
  It sets `GIT:` when a commit happens. It is not short usage.
- One optional selector. A basename, or a component (basename
  with a leading `<parent>-` removed). Named lookup is the
  open-folder candidates, then git repos one or two levels under
  the nearest ancestor named `src`. Exact basename wins. Zero
  matches, or two non-archived matches, is **Error** before any
  write. Two selector tokens is **Error**. No selector does not
  walk every repo under `src`. `all` walks the open folder at any
  depth and still does not walk up to `src`.
- Archived: a path segment `archive` (case-insensitive), or
  `gh repo view --json isArchived` true. Note it. Do not add,
  commit, or tag. A failed `gh` call is not archived. Clean:
  note it. No empty commit. Dirty: one landed gitify commit.
  Path sort is fixed.
- One `tag` token. One `msg` token. One `link` token. One
  `forcemain` token. One `all` token. `:` and `=` are the same. Keys are
  case-insensitive. A value has no spaces. `+` on both sides, an
  empty value, or two of either `tag` or `msg` is **Error** before
  `git add`. Two `link` tokens, or an empty `link` value, is
  **Error** before any write. `link:hello world` is `link:hello`
  plus leftover `world`.
- Every commit message in the bunch ends with
  `[multirepo-link=TEXT]` after `msg` replace, prepend, or postfix.
  The brackets are part of the line. No `link` token means no line.
- `dry-run` is one bare token. Two of them is **Error**. It prints
  the run notes and, for each dirty repo, the repo path,
  `git add -A`, the full commit message, the tag name when one
  was requested, and `git push origin <branch>`. With `forcemain`
  on a branch other than `main`, it prints `git push origin <branch>`,
  `git checkout main`, `git merge <branch>`, `git push origin main`,
  `git branch -d <branch>`, and `git push origin --delete <branch>`,
  in that order. It does not stage, commit, tag, push, checkout,
  merge, delete, edit git config, or write a notes file. A live
  run executes that same list in that same order, with those same
  messages and tag names, then pushes. Build the list before the
  first `git add`. Help, tldr, pass, and dry-run do not push or
  merge.
- `status`, `push`, `log`, `diff`, `commit`, and `git` are stop
  words, not repo names. Any other unmatched token stops with no
  git write. A typed `push` is a stop word, not the post-commit
  push, and not `forcemain`. After a successful commit, gitify
  runs `git push origin <current-branch>`. It is not a git engine.
- A secret-like path aborts the whole bunch unless
  `git check-attr filter` from that repo is `git-crypt`. An
  existing tag still aborts the bunch with no write. Dry-run
  prints that error and also writes nothing.
- Help, tldr, and pass print their page and stop. Exact `tldr`
  is the short page. They do not touch git and do not retitle.
- Preflight before any write. Nothing to commit: say so. No empty
  commit. No tag. An existing tag is **Error** before `git add`.
  Do not move it. A secret-like path is **Error** before `git add`,
  unless `git check-attr filter` from that repo is `git-crypt`.
  No upstream: say so, and build the message from the working tree
  and commits since the last tag, or the working tree only.
- `all` is one bare token, case-insensitive, same shape as
  `dry-run`. Two tokens is **Error** before any write.
  `all:TEXT` and `all=TEXT` are **Error**. It is not a selector
  and not a stop word. A selector token together with `all` is
  **Error** before any write. The bunch is every git repo under
  the open folder, at any depth. A directory that contains `.git`
  is a repo. Keep walking its children so a nested repo is found.
  Do not walk into `.git` or `node_modules`. Count each path once.
  Do not walk up to `src`. Do not include siblings of the open
  folder. Before preflight, a nested repo any ancestor ignores
  (`git check-ignore` exit 0 from that ancestor) is skipped like
  an archived repo. Note it. Do not add, commit, tag, push,
  checkout, merge, or reset it. Do not require `main`. Those
  checks do not abort the bunch. Empty `/gitify` stays one level
  deep. A selector that resolves only to an ignored repo notes it
  and does not commit it. Without `forcemain`, the branch must be `main` and the
  push is `git push origin main`. With `forcemain`, `forcemain`
  still owns the merge. The generated message is as complete as
  that repo's tracking docs allow (`docs/` markdown, README
  command rows, and `SKILL.md` / `HELP.md` / `TLDR.md` in the
  diff). A `msg` replace still replaces it.
- `forcemain` is one bare token, case-insensitive, same shape as
  `dry-run`. Two tokens is **Error** before any write.
  `forcemain:TEXT` and `forcemain=TEXT` are **Error**. It is not a
  selector and not a stop word. It applies to every dirty repo in
  the bunch, the same way `tag` and `msg` do. A clean repo is
  still skipped. On `main` it adds nothing: commit, then
  `git push origin main`, and stay on `main`. There is no merge
  and no branch to close. On any other branch, after the commit
  and the optional local tag: `git push origin <branch>`,
  `git checkout main`, `git merge <branch>`, `git push origin main`,
  `git branch -d <branch>`, `git push origin --delete <branch>`.
  Finish on `main`. The feature branch is gone locally and on
  `origin`. The tag is still not pushed. There is no other merge.
  Nothing merges into a branch other than `main`. No merge
  directive besides `forcemain`. Failure stops the bunch. Do not
  continue to later repos. Do not use `--force` or `git branch -D`.
  Branch push fails: stay on that branch. Do not merge. Do not
  delete. `git checkout main` fails: stay on that branch. Do not
  delete. Merge fails: `git merge --abort`, then
  `git checkout <branch>`. Do not delete. Do not push `main`.
  `git push origin main` fails: stay on `main`. Do not delete the
  branch. `git branch -d` fails: do not delete the remote branch.
  Remote delete fails: print the output. The repo is already on
  `main`. Still do not continue to later repos. `dry-run` prints
  those commands in that order and does not checkout, merge,
  delete, or push.
- Hook rejection: print the hook output. Do not tag that commit.
  Do not push. Do not continue to later repos. Dry-run cannot
  simulate hooks.
- Dry-run does not retitle. A live bunch that commits does. One
  repo keeps today's summary. Several repos use three to six words,
  the link token when that token is already that short.
- Cite `docs/from_contract.md`, the docify skill's
  `references/docify_contract.md`, and `docs/window_title.md`.
  Prefix `GIT:`.
