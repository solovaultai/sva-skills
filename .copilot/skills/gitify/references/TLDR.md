# /gitify

Add each dirty repo under the open folder and make one commit. A
basename (`pytch-fluent`) or component (`fluent`) selects one repo.
Optional annotated tag, custom message, and link line. `dry-run`
prints the action list and writes nothing. `forcemain` merges the
checked-out branch into `main` and leaves the repo on `main`.
`all` walks every git repo under the open folder, writes the
commit from the tracking docs, and pushes `origin main`.
After a successful commit, a live run executes
`git push origin <current-branch>`. Detached `HEAD` aborts before
`git add`. Does not amend, skip hooks, or change git config.
Does not push tags. Does not pull. Does not use `--force`.
Not a git engine. `from=` splices
local files (`docs/from_contract.md`). `docify` writes the
deliverable (the docify skill's `references/docify_contract.md`).
Window prefix `GIT:` (`docs/window_title.md`). No smart mode. Empty
`/gitify` is a real commit, not short usage.

```text
/gitify                 — every dirty repo under the open folder
/gitify pytch-fluent    — that repo (basename)
/gitify fluent          — that component (leading <parent>- removed)
/gitify tag             — annotated tag; name derived before git add
/gitify tag:NAME        — annotated tag NAME (tag=NAME is the same)
/gitify msg:TEXT        — TEXT replaces the generated message
/gitify msg:+TEXT       — labeled custom block before the message
/gitify msg:TEXT+       — labeled custom block after the message
/gitify link:TEXT       — [multirepo-link=TEXT] on every commit
/gitify dry-run         — print the action list; write nothing
/gitify forcemain       — push this branch, merge it into main, finish on main
/gitify all             — every git repo under the open folder; commit; push origin main
/gitify help            — full reference (also --help / /?)
/gitify tldr            — short form (stop)
/gitify pass            — Pass (Npass) subsection only (also pass help)
```

Empty `/gitify` commits every dirty repo under the open folder.

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Every dirty repo: `git add -A`, then one commit | Same shape as empty `/saveify`: a real action, not short usage |
| `pytch-fluent` | That repo only (basename) | One selector. Two selector tokens is Error |
| `fluent` | That component (leading `<parent>-` removed) | Exact basename wins. Zero matches, or two non-archived matches, is Error |
| `tag` | Annotated-tag the new commit with a derived short name | Derived before `git add`. An existing name aborts the bunch. Do not move a tag |
| `tag:NAME` / `tag=NAME` | Annotated-tag with NAME, as written | One tag token. Empty NAME is Error. Same NAME in every repo |
| `msg:TEXT` / `msg=TEXT` | The commit message is TEXT | Replaces the generated message. One msg token. Empty is Error |
| `msg:+TEXT` / `msg+=TEXT` | Labeled custom block, then the generated message | `+` on both sides is Error |
| `msg:TEXT+` / `msg=TEXT+` | Generated message, then the labeled custom block | A value has no spaces |
| `link:TEXT` / `link=TEXT` | Append `[multirepo-link=TEXT]` after `msg` | Brackets are part of the line. No link token means no line. `link:hello world` leaves leftover `world` |
| `dry-run` | Print run notes and the action list, including `git push origin <branch>`. With `forcemain` off `main`, also the checkout, merge, push `main`, `git branch -d`, and `git push origin --delete` lines | Does not stage, commit, tag, push, checkout, merge, delete, edit git config, or write a notes file. Live run executes that same list |
| `forcemain` | On `main`: commit, then `git push origin main`, stay on `main`. On any other branch: `git push origin <branch>`, `git checkout main`, `git merge <branch>`, `git push origin main`, `git branch -d <branch>`, `git push origin --delete <branch>`, finish on `main` | Bare token. Case-insensitive. One token. Two is **Error**. `forcemain:TEXT` and `forcemain=TEXT` are **Error**. Not a selector. No other merge. Failure stops the bunch |
| `all` | Every git repo under the open folder. Without `forcemain`: branch must be `main`, message from the tracking docs, then `git push origin main` | Bare token. One token. Two is **Error**. `all:TEXT` is **Error**. A selector with `all` is **Error**. With `forcemain`, `forcemain` still owns the merge |
| anything else | Stop. No add, no commit, no tag, no push | `status`, `push`, `log`, `diff`, `commit`, and `git` are stop words, not repo names |
| `help` / `--help` / `/?` | Print the full user reference and stop | Further words (`help me …`) stay on Help |
| `tldr` | Print this short page and stop | Exact `tldr` is this page. `tldr help` is not Help |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |

`msg:hello world` is `msg:hello` plus leftover `world`, which stops
the turn. Archived (path segment `archive`, or
`gh repo view --json isArchived`) is noted and skipped. A failed
`gh` call is not archived. Clean repos are noted. No empty commit.
A secret-like path (`.env`, `credentials.json`, a private key) or
an existing tag in any dirty repo aborts the bunch before any write.
Dry-run prints that error and also writes nothing. Detached `HEAD`
is **Error** before `git add`. No upstream: say so. A rejected
hook is printed. Do not tag that commit. Do not push. Do not
continue to later repos. A failed push stops the bunch. Do not
use `--force`. Dry-run does not push or merge and does not
retitle.
