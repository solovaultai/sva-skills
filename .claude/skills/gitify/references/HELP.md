# Gitify — user reference

Print this file as the response when the user runs `/gitify help`,
`/gitify --help`, or `/gitify /?`. Also when the first token after
flag strip is `help`, `--help`, or `/?` (`help me …` included). Do
not add, commit, or tag. `/gitify tldr` prints the short page
(`references/TLDR.md`), not this file. Exact `tldr` stays that
short page. `tldr help` is not Help.

If the first token after flag strip is `pass`, including `pass help`,
print only the **Pass (`Npass`)** section below and stop. There is
no `/pass` skill.

Empty `/gitify` is a real commit, not this page and not short usage.
It commits every dirty repo under the open folder.

---

## What it does

Adds each dirty worktree (`git add -A`) and makes **one** commit
there. The message is extensive and comes from this iteration. It
can annotated-tag that commit, splice a custom message, or stamp a
link line on every commit in the bunch. `forcemain` merges the
checked-out branch into `main` and leaves the repo on `main`.
After a successful commit it runs
`git push origin <current-branch>`. Before any `git add` it reads
the branch with `git rev-parse --abbrev-ref HEAD`. Name `main`
pushes `git push origin main`. Any other branch name, including
`master`, pushes `git push origin <that-name>`. Detached `HEAD`
is **Error** before `git add`. No add, no commit, no push, in
this repo or any later repo in the bunch. It does not amend, skip
hooks, or change git config. It does not push tags, does not
pull, and does not use `--force`. It is not a git engine. There
is no `smart` mode.

No selector: every dirty repo under the host's open folder. One
repo basename (`pytch-fluent`) or component name (`fluent`) selects
that repo. `dry-run` prints the action list and writes nothing. A
live run executes that same list.

`from=` / `from:` splices local files into the prompt (see
`docs/from_contract.md`). Help, tldr, and pass do not read files.

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see the docify skill's `references/docify_contract.md`). Help,
tldr, pass, and dry-run do not write that file. Empty `/gitify`
still commits.

Window title prefix is `GIT:` (see `docs/window_title.md`). Help,
tldr, pass, and dry-run do not retitle. A live bunch that commits
does, including empty `/gitify`.

```text
/gitify                 — every dirty repo under the open folder
/gitify pytch-fluent    — that repo (basename)
/gitify fluent          — that component (leading <parent>- removed)
/gitify tag             — that commit, annotated tag, derived name
/gitify tag:NAME        — annotated tag NAME (tag=NAME is the same)
/gitify msg:TEXT        — commit message is TEXT (msg=TEXT is the same)
/gitify msg:+TEXT       — labeled custom block before the message
/gitify msg:TEXT+       — labeled custom block after the message
/gitify link:TEXT       — [multirepo-link=TEXT] on every commit
/gitify dry-run         — print the action list; write nothing
/gitify forcemain       — push this branch, merge it into main, finish on main
/gitify help            — this reference (also --help, /?)
/gitify tldr            — short form (stop)
/gitify pass            — Pass (Npass) section only (also pass help)
```

---

## Open folder

The scan root is the folder the running host has open. Not a
historical project list, and not every repo under `/home/ami/src`.

Claude Code: the session working directory.

Candidates, one level only: the open folder, if it is a git repo,
and each immediate child directory that has `.git`. An open folder
`/home/fastpytch/src/pytch` (or `/home/ami/src/pytch`) includes
`pytch-fluent`, `pytch-api`, and the other child git repos. It does
not include sibling products and it does not walk into a repo's
subfolders.

No selector uses only these candidates. Naming a repo also searches
git repos one or two levels under the nearest ancestor named `src`.

---

## Tokens

Each directive is one whitespace-delimited token. `:` and `=` are
the same. Keys are case-insensitive. A value has no spaces.
Quotation marks are not syntax. `msg:hello world` is `msg:hello`
plus a leftover `world`. `link:hello world` is `link:hello` plus
leftover `world`.

| Token | Effect |
|-------|--------|
| `tag` | After the commit, annotated-tag it. The name is derived before `git add`. |
| `tag:NAME` / `tag=NAME` | Annotated-tag with NAME, as written. |
| `msg:TEXT` / `msg=TEXT` | TEXT replaces the generated message. |
| `msg:+TEXT` / `msg+=TEXT` | Labeled custom block before the generated message. |
| `msg:TEXT+` / `msg=TEXT+` | Labeled custom block after the generated message. |
| `link:TEXT` / `link=TEXT` | End every commit message with `[multirepo-link=TEXT]`. |
| `dry-run` | Print the run notes and the action list, including `git push origin <branch>`. Do not write. |
| `forcemain` | Bare token. Case-insensitive. On `main`, adds nothing. On any other branch, push it, merge it into `main`, delete it, and finish on `main`. |
| one other token | Selector. Basename, or component (leading `<parent>-` removed). |

One `tag` token. One `msg` token. One `link` token. One `dry-run`
token. One `forcemain` token. Two of any of those is **Error**
before any write. An empty value is **Error**. `+` on both sides
(`msg:+hello+`) is **Error**. `dry-run` is a bare token.
`dry-run:TEXT` is **Error**. `forcemain` is a bare token,
case-insensitive, same shape as `dry-run`. One token. Two of them
is **Error**. `forcemain:TEXT` and `forcemain=TEXT` are **Error**.
It is not a selector and not a stop word. Two selector tokens is
**Error**.

`status`, `push`, `log`, `diff`, `commit`, and `git` are stop words.
They are not repo names. Any other unmatched token stops the turn.
An `img=` / `img:` token is a leftover, not a directive. Stop with no git write.
A typed `push` is a stop word, not the post-commit push, and not
`forcemain`. After a successful commit, gitify runs
`git push origin <current-branch>`. It is not a git engine.
Nothing is added, committed, tagged, or pushed when a stop word
aborted the turn.

---

## Selector, archived, clean

`pytch-fluent` is the repo basename. `fluent` is the component: the
basename with a leading `<parent>-` removed, so parent `pytch` and
basename `pytch-fluent` yield `fluent`. Named lookup searches the
open-folder candidates, then git repos one or two levels under the
nearest ancestor named `src`. Exact basename wins over a component
match. Zero matches, or two non-archived matches, is **Error**
before any write.

Before a checkin, classify each repo. Sort by full path so the order
does not change between dry-run and live.

- **Archived.** A path segment `archive` (case-insensitive), or a
  GitHub `origin` whose `gh repo view --json isArchived` is true.
  Note it. Do not add, commit, or tag. A failed `gh` call does not
  count as archived.
- **Clean.** Skip. Mention it in the notes. No empty commit.
- **Dirty.** One gitify commit.

Print the run notes. Do not write a notes file.

---

## Link and dry-run

Every commit message in the bunch ends with this line, after `msg`
replace, prepend, or postfix. The brackets are part of the line.
No `link` token means no line.

```text
[multirepo-link=TEXT]
```

`dry-run` prints the run notes and, for each dirty repo, the repo
path, `git add -A`, the full commit message, the tag name when
one was requested, and `git push origin <branch>`. With
`forcemain` on `main`, that push line is `git push origin main`.
With `forcemain` on any other branch, it also prints
`git checkout main`, `git merge <branch>`, `git push origin main`,
`git branch -d <branch>`, and `git push origin --delete <branch>`,
in that order. It does not stage, commit, tag, push, checkout,
merge, delete, or edit git config. It does not pull.

A live run executes that same list in that same order, with those
same messages and tag names. Build the list before the first
`git add`. A secret-like path or an existing tag in any dirty repo
aborts the whole bunch with no write. Dry-run prints that error and
also writes nothing. A commit hook that rejects a live commit prints
the hook output, does not tag that commit, and does not continue to
later repos. Dry-run cannot simulate hooks.

Dry-run does not retitle. One repo keeps today's summary. Several
repos use three to six words, the link token when that token is
already that short.

---

## Commit

Before any write: not a repo, a selector error, an existing tag, or
a secret-like path (`.env`, `credentials.json`, a private key) is
**Error** or a stop. A secret or an existing tag in any dirty repo
aborts the whole bunch. No empty commit. No tag on a stop. No
upstream is said in the reply. The message then uses the working
tree and commits since the last tag, or the working tree only when
there is no tag either.

Then, for each dirty repo in path order, `git add -A` and one
commit. Hooks run. A hook rejection is printed. That commit is not
tagged, and later repos are not committed.

The generated message covers the working tree, commits not on the
upstream, and the plans, docs, and other artifacts those changes
touch. A custom prepend or postfix is a labeled block so the custom
part is obvious. A replace is the message. The link line, when
present, is still appended after it.

A bare `tag` name is a short name from that commit and from what
changed since the last tag, derived per repo before the first
`git add`. If that name already exists, stop before `git add`. Do
not move an existing tag. The same `tag:NAME` is used in every repo.

Before any `git add`, read the branch with
`git rev-parse --abbrev-ref HEAD`. Detached `HEAD` is **Error**
before `git add`. No add, no commit, no push, in this repo or any
later repo in the bunch.

After a successful commit, and after an optional annotated tag,
push the checked-out branch. Name `main`: `git push origin main`.
Any other branch name, including `master`:
`git push origin <that-name>`. Do not use `--force`. Do not push
tags. Do not pull. A clean repo still has no commit and no push.
A rejected commit still does not push. If the push fails, print
the output. Do not continue to later repos. Do not amend.

`forcemain` applies to every dirty repo in the bunch, the same
way `tag` and `msg` do. A clean repo is still skipped. When the
checked-out branch is `main`, `forcemain` adds nothing: commit,
then `git push origin main`, and stay on `main`. There is no
merge and no branch to close.

When the checked-out branch is not `main`, after the commit and
the optional local tag:

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

Failure stops the bunch. Do not continue to later repos. Do not
use `--force` or `git branch -D`.

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

`dry-run` prints those commands in that order and does not
checkout, merge, delete, or push. Help, tldr, pass, and dry-run
do not push or merge.

---

## Pass (`Npass`)

There is **no** `/pass` skill. After flag strip, first token `pass`
(including `pass help`) prints **this section** and stops. Full
reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right, typed line only. Default **1**.

**Meaning:** the flag is stripped before the directives. Gitify
does not loop. One commit per dirty repo.

```text
/gitify pass
/gitify pass help
/gitify 2pass
/gitify 2pass tag
/promptify pass help
```

---

## Window title

Prefix `GIT:` (`docs/window_title.md`). Set when a live bunch
commits, including empty `/gitify`. One repo keeps today's summary.
Several repos use three to six words, the link token when that
token is already that short. Help, tldr, pass, `--help`, `/?`, and
`dry-run` do not retitle.
