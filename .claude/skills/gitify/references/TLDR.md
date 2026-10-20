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
Does not push tags. Does not pull, except `get`. Does not use `--force`.
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
/gitify get pytch-       — pull or clone basenames starting with pytch-
/gitify get:pytch-fluent — that one repo (get=pytch-fluent is the same)
/gitify put pytch-       — check in that prefix, or create a missing repo
/gitify put:pytch-fluent — check in that repo (put=pytch-fluent is the same)
/gitify unarchive pytch-iam — restore that archived repo
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
| `all` | Every git repo under the open folder. An ancestor-ignored nested repo is skipped before preflight (`git check-ignore` exit 0). Without `forcemain`: a repo that is not ignored must be on `main`, message from the tracking docs, then `git push origin main` | Bare token. One token. Two is **Error**. `all:TEXT` is **Error**. A selector with `all` is **Error**. A selector that finds only an ignored repo notes it and does not commit. With `forcemain`, `forcemain` still owns the merge and does not commit an ignored repo |
| `get` / `get:PLUG` | Pull or clone that literal basename prefix. One repo, prefix family, or ask. Skip archived and ignored. Live: `git pull --ff-only`. Missing and not archived: `git clone` into the live parent | One plug. Empty, two plugs, or combined with `tag`, `msg`, `link`, `forcemain`, `all`, `put`, `unarchive`, or a commit selector is **Error**. `dry-run` allowed. Does not run the commit bunch |
| `put` / `put:PLUG` | Same selection as `get`. Existing live repo on `main`: `git add -A`, one tracking-doc commit, `git push origin main`. Missing locally and on GitHub: create with git-crypt | `msg` is not accepted. Not on `main` is **Error** before `git add`. `git check-attr filter` must be `git-crypt` before add, and before the create commit. Do not install git-crypt into an existing repo |
| `unarchive` / `unarchive:NAME` | One archived repo. Move an `archive` path segment out. `gh repo unarchive <owner>/<name> --yes` when GitHub `isArchived` is true | Not a prefix. Not archived: meaningless notice, not red **Error**. `unarachive` is not an alias. Does not run the commit bunch |
| anything else | Stop. No add, no commit, no tag, no push | `status`, `push`, `log`, `diff`, `commit`, and `git` are stop words, not repo names. `unarachive` is this row |
| `help` / `--help` / `/?` | Print the full user reference and stop | Further words (`help me …`) stay on Help |
| `tldr` | Print this short page and stop | Exact `tldr` is this page. `tldr help` is not Help |
| `pass` / `pass help` | Print the Pass (`Npass`) subsection only and stop | There is no `/pass` skill |

`msg:hello world` is `msg:hello` plus leftover `world`, which stops
the turn. Archived (path segment `archive`, or
`gh repo view --json isArchived`) is noted and skipped. An
ancestor-ignored nested repo is noted and skipped before preflight.
A failed
`gh` call is not archived. Clean repos are noted. No empty commit.
A secret-like path (`.env`, `credentials.json`, a private key)
aborts the bunch before any write unless `git check-attr filter`
from that repo is `git-crypt`. An existing tag still aborts.
Dry-run prints that error and also writes nothing. Detached `HEAD`
is **Error** before `git add`. No upstream: say so. A rejected
hook is printed. Do not tag that commit. Do not push. Do not
continue to later repos. A failed push stops the bunch. Do not
use `--force`. Dry-run does not push or merge and does not
retitle.

## get, put, unarchive

Match `get`, `put`, and `unarchive` before a leftover token becomes a
commit selector. Case-insensitive. `:` and `=` split one token.
`get:pytch-` equals `get pytch-`. `put:pytch-fluent` equals
`put pytch-fluent`. `unarachive` is not an alias.

`get` needs one plug, unless the open folder is a git repo. With no
plug, that open folder is the one repo. Do not expand its basename
into a prefix family. Do not ask. Two plugs, or `get` plus `tag`,
`msg`, `link`, `forcemain`, `all`, `put`, `unarchive`, or a commit
selector is **Error** before any write. No plug, and the open folder
is not a git repo, is **Error** before any write. `dry-run` is allowed. The plug
is a literal case-sensitive basename prefix, not a regex and not a
component. `pytch-` matches `pytch-fluent`, not component `fluent`.

Walk every directory under the nearest ancestor named `src`. Do not
walk above `src`. Do not enter `.git` or `node_modules`. A directory
with `.git` is a repo. Deeper than the one-or-two-level selector,
because `/home/ami/src/archive/pytch/pytch-iam` is three levels under
`src`. No `src` ancestor is **Error**.

After the walk and `gh repo list <owner> -L 1000 --json name,isArchived`,
before any pull or clone: the current repo when no plug is given and the open folder is a git repo (that folder only; do not expand its basename; do not ask; no plug and the open folder is not a git repo is **Error**); one repo (a name equals the plug and no other
name starts with it; `get pytch-fluent` updates
`/home/ami/src/pytch/pytch-fluent`, skips the archive twin, does not
touch `pytch-api`); prefix family (no name equals the plug; `get pytch-`;
`/home/ami/src/pytch/pytch` is not a repo named `pytch`); or ask (a name
equals the plug and another name starts with it, including archived
local or GitHub names). Ask before any pull, clone, or dry-run action
list. Do not guess. Missing question tool: print the two choices and
wait. Choosing the single archived repo notes the skip and does not
clone a second copy.

Skip path segment `archive` (case-insensitive), or
`gh repo view --json isArchived` true. A failed `gh` call is not
archived. Also skip `git check-ignore` exit 0. Do not hardcode
`.upstream`. Archived or ignored names are not cloned and not pulled.
`pytch-iam` stays under `archive/` during `get pytch-`. Print skips in
path order. Owner and SSH host come from a local `origin` of a repo
with that prefix. Clone `git@github-adworkinitp:solovaultai/<name>.git`.
Do not clone the `github.com` URL `gh` prints. Disagreeing origins,
no local origin, or no local and no remote match is **Error** before
any clone. Live: `git pull --ff-only` on the current branch. Do not
checkout. Do not require `main`. Dirty or detached: note and skip. A
failed pull stops the rest. No checkout under `src` and not archived:
`git clone` into the parent of the live matches (`/home/ami/src/pytch`
for `pytch-`). Several live parents is **Error** before any clone. Do
not create a new parent. `get` does not run the commit bunch.
`forcemain` does not run. `dry-run` prints skips, pull lines, and clone
lines, writes nothing, and does not retitle.

`put` uses that same selection and the same skips. `put pytch-` does
not check in archive `pytch-iam` and does not create a second copy.
No plug, and the open folder is a git repo, selects that folder only. No plug, and the open folder is not a git repo, two plugs, or `put` plus `tag`, `msg`, `link`,
`forcemain`, `all`, `get`, `unarchive`, or a commit selector is
**Error**. `msg` is not accepted. The message comes from the tracking
docs used when `all` is set (`docs/` markdown, README command rows,
`SKILL.md` / `HELP.md` / `TLDR.md` in the diff). If they do not
describe the change, say so and describe the diff. Existing live
checkout: branch must be `main` before `git add`. Any other branch,
including `master`, and detached `HEAD`, is **Error** before `git add`.
Do not checkout `main`. Dirty: `git add -A`, one commit,
`git push origin main`. Do not amend, skip hooks, push tags, or use
`--force`. Clean: note it. No empty commit. If already ahead of
`origin/main`, push those. A secret-like path whose `git check-attr
filter` is not `git-crypt` aborts the whole put before `git add`. Do
not install git-crypt into an existing repo. No local checkout and no
GitHub repo: create it in the parent `get` would clone into. Do not
create that parent. Several live parents, or no parent, is **Error**
before any create. A GitHub repo with no local checkout is not a
create. Do not `gh repo create` a name that exists. Create:
`git init -b main`; `git-crypt init` (no copied key, no GPG user, no
`git-crypt add-gpg-user`); write `.gitattributes` before `git add` of
any secret so every `.env` and every `.env.*` basename, including
`.env.example` and files with no secrets, gets
`filter=git-crypt diff=git-crypt`, plus `credentials.json`, `id_rsa`,
`id_dsa`, `id_ecdsa`, `id_ed25519`, `*.pem`, `*.key`, not `*.pub`; do
not gitignore `.env`; do not copy plaintext `!filter` lines from
`/home/ami/src/pytch/pytch-fluent/.gitattributes`; `git check-attr
filter` must print `git-crypt` for each of those paths before the
commit, else **Error**, no commit, no push; one initial commit that
says the repo was created with git-crypt and names the attribute
rules; private GitHub repo; `origin` is
`git@github-adworkinitp:<owner>/<name>.git`; `git push origin main`.
`dry-run` prints skips, checkin commands, and create steps, writes
nothing, and does not retitle. A failed commit or push stops the rest.
`put` runs the commit bunch only for repos that already exist.

`unarchive` needs one repo token (basename or component) under that
same `src` walk, including archive paths. Not a prefix family. No name, and the open folder is a git repo, selects that folder. No name, and the open folder is not a git repo, two names, or `unarchive` plus `get`, `put`, or the other
directives is **Error** before any write. Zero matches, or two
archived-only matches, is **Error** before any move. Archived and
ignored name-twins are not a second match. Not archived by either
rule: do not move, do not call `gh`, do not commit. Print that the
request was meaningless. That is a notice, not the red **Error**.
`pytch-fluent` is this case. Path segment `archive` that is not the
repo's own basename: move to the same path with that segment removed.
`/home/ami/src/archive/pytch/pytch-iam` goes to
`/home/ami/src/pytch/pytch-iam`. Destination exists, or parent missing:
**Error** before the move. Do not create the parent. Do not overwrite.
GitHub `isArchived` true: `gh repo unarchive <owner>/<name> --yes`
from that repo's `origin` (`pytch-account`, `pytch-outreach`,
`pytch-gpt`, `pytch-admin`). Both: move and the `gh` call. `dry-run`
prints both and writes nothing. `unarchive` does not run the commit
bunch.

Live `get`, live `put`, and live `unarchive` set `GIT:` per
`docs/window_title.md` when `TMUX` is set. A meaningless unarchive and
`dry-run` do not retitle.
