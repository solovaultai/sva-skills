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
`all` walks every git repo under the open folder. Without
`forcemain`, the branch must be `main` and the push is
`git push origin main`. The commit message is as complete as
that repo's tracking docs allow.
After a successful commit it runs
`git push origin <current-branch>`. Before any `git add` it reads
the branch with `git rev-parse --abbrev-ref HEAD`. Name `main`
pushes `git push origin main`. Any other branch name, including
`master`, pushes `git push origin <that-name>`. Detached `HEAD`
is **Error** before `git add`. No add, no commit, no push, in
this repo or any later repo in the bunch. It does not amend, skip
hooks, or change git config. It does not push tags, does not
pull except `get`, and does not use `--force`. It is not a git
engine. There is no `smart` mode. `get` pulls or clones a literal
basename prefix and skips archived and ignored repos. `put` checks
existing repos in to `origin main`, or creates a missing repo with
git-crypt. `unarchive` restores one archived repo, or notes that a
request on a repo that is not archived was meaningless.
`unarachive` is not an alias.

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
does, including empty `/gitify`. Live `get`, live `put`, and live
`unarchive` set `GIT:` when `TMUX` is set. A meaningless unarchive
does not retitle.

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
/gitify all             — every git repo under the open folder; commit; push origin main
/gitify get pytch-       — pull or clone basenames starting with pytch-
/gitify get:pytch-fluent — that one repo (get=pytch-fluent is the same)
/gitify put pytch-       — check in that prefix, or create a missing repo
/gitify put:pytch-fluent — check in that repo (put=pytch-fluent is the same)
/gitify unarchive pytch-iam — restore that archived repo
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

`all` is the exception. It walks every directory under the open
folder. A directory that contains `.git` is a repo, and its
children are still walked so a nested repo is found. Do not walk
into `.git` or `node_modules`. Do not walk up to `src`. Before
preflight, if any ancestor git repo ignores that path, skip it.
Test from that ancestor with `git check-ignore`. Exit 0 means
ignored. Do not hardcode a directory name. Note it in path order.
Do not add, commit, tag, push, checkout, merge, or reset it. Do
not require `main`. Detached `HEAD`, a non-`main` branch, a dirty
tree, a missing upstream, or a secret-like path inside it does
not abort this repo or any other repo. Empty `/gitify` stays one
level deep.

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
| `all` | Bare token. Case-insensitive. Every git repo under the open folder. An ancestor-ignored nested repo is skipped before preflight (`git check-ignore` exit 0 from that ancestor). Without `forcemain`, a repo that is not ignored must be on `main`, then `git push origin main`. A selector with `all` is **Error**. A selector that resolves only to an ignored repo is noted and not committed. |
| `get` / `get:PLUG` / `get=PLUG` | One plug. Literal basename prefix. Pull or clone. No plug, and the open folder is a git repo, acts on that repo only. Case-insensitive key. Does not run the commit bunch. `dry-run` is allowed. |
| `put` / `put:PLUG` / `put=PLUG` | One plug or repo name. Check in to `origin main`, or create with git-crypt. No plug, and the open folder is a git repo, acts on that repo only. `msg` is not accepted. |
| `unarchive` / `unarchive:NAME` / `unarchive=NAME` | One repo token, basename or component. Restore one archived repo. No name, and the open folder is a git repo, acts on that repo only. `unarachive` is not an alias. |
| one other token | Commit selector, only when `get`, `put`, and `unarchive` are absent. Basename, or component (leading `<parent>-` removed). |

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

`get`, `put`, and `unarchive` are directives. Match them before a
leftover token becomes a commit selector. The key is case-insensitive.
`:` and `=` still split one token, so `get:pytch-` and `get pytch-`
are the same, and so are `put:pytch-fluent` and `put pytch-fluent`,
and so are `unarchive:pytch-iam` and `unarchive pytch-iam`. The value
is the plug or the repo token. `unarachive` is not an alias. That
spelling is an unmatched token. The directive spelling is `unarchive`.

`get` needs one plug, unless the open folder is a git repo. With no
plug, that open folder is the one repo. Do not expand its basename
into a prefix family. Do not ask. Two plugs, or `get` plus `tag`,
`msg`, `link`, `forcemain`, `all`, `put`, `unarchive`, or a commit
selector is **Error** before any write. No plug, and the open folder
is not a git repo, is **Error** before any write. `dry-run` is allowed.

`put` needs one plug or repo name, unless the open folder is a git
repo. With no plug, that open folder is the one repo. Do not expand
its basename into a prefix family. Do not ask. Two plugs, or `put`
plus `tag`, `msg`, `link`, `forcemain`, `all`, `get`, `unarchive`, or
a commit selector is **Error** before any write. No plug, and the
open folder is not a git repo, is **Error** before any write.
`dry-run` is allowed. The commit message comes from the tracking
docs, so `msg` is not accepted here.

`unarchive` needs one repo token, resolved with the existing
basename-or-component rule, unless the open folder is a git repo.
With no name, that open folder is the repo. Two names, or
`unarchive` plus `get`, `put`, `tag`, `msg`, `link`, `forcemain`, or
`all` is **Error** before any write. No name, and the open folder is
not a git repo, is **Error** before any write. `dry-run` is allowed.

`get` and `unarchive` do not run the commit bunch. `put` does, for
repos that already exist. `forcemain` does not run on these modes.
You do not pull, except `get`.

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

- **Ignored.** Before preflight. Any ancestor git repo ignores
  the path (`git check-ignore` exit 0 from that ancestor). Note it
  in path order. Do not add, commit, tag, push, checkout, merge,
  or reset it. Do not require `main`. `forcemain` does not commit
  it. `dry-run` lists the skip and writes nothing.
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
`git add`. A secret-like path aborts the whole bunch unless
`git check-attr filter` from that repo is `git-crypt`. An existing
tag still aborts the bunch with no write. Dry-run prints that error
and also writes nothing. A commit hook that rejects a live commit prints
the hook output, does not tag that commit, and does not continue to
later repos. Dry-run cannot simulate hooks.

Dry-run does not retitle. One repo keeps today's summary. Several
repos use three to six words, the link token when that token is
already that short.

---

## Commit

Before any write: not a repo, a selector error, an existing tag, or
a secret-like path (`.env`, `credentials.json`, a private key) is
**Error** or a stop, unless `git check-attr filter` from that repo
is `git-crypt` (ciphertext, not plaintext). A secret that is not
git-crypt, or an existing tag, in any dirty repo aborts the whole
bunch. No empty commit. No tag on a stop. No
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

## get

`get` pulls or clones. It does not run the commit bunch. `forcemain`
does not run. `dry-run` is allowed and does not retitle. Do not apply
`tag`, `msg`, `link`, `forcemain`, or `all`.

The plug is a literal basename prefix, case-sensitive. `pytch-`
matches `pytch-fluent` and does not match a component named `fluent`.
It is not compiled as a regular expression.

Search every directory under the nearest ancestor named `src`. Do not
walk above `src`, and do not enter `.git` or `node_modules`. A
directory with `.git` is a repo. This is deeper than the commit
selector's one-or-two-level lookup, because
`/home/ami/src/archive/pytch/pytch-iam` is three levels under `src`.
No `src` ancestor is **Error**.

Remote names come from
`gh repo list <owner> -L 1000 --json name,isArchived`. Owner and SSH
host come from a local `origin` of a repo with that prefix. Rewrite
the sibling URL's repo name. Live remotes are
`git@github-adworkinitp:solovaultai/<name>.git`, so do not clone the
`github.com` URL that `gh` prints. If those origins disagree on host
or owner, **Error** before any clone. If no local origin exists,
**Error**. If the plug matches nothing locally and nothing remotely,
**Error**.

After the src walk and the remote name list, and before any pull or
clone, classify the plug. A name counts if it is a local checkout
basename or a GitHub repo name, including an archived one.

- **Current repo.** No plug, and the open folder is a git repo. That
  checkout only. Do not expand its basename into a prefix family.
  Do not ask. No plug, and the open folder is not a git repo, is
  **Error** before any pull or clone.
- **One repo.** Some repo name equals the plug, and no other name
  starts with it. Clone or pull that repo only. `get pytch-fluent`
  is this case: update `/home/ami/src/pytch/pytch-fluent`, skip the
  archive twin, and do not touch `pytch-api`. No question.
- **Prefix family.** No repo name equals the plug. Keep the family
  behavior. `get pytch-` is this case. No basename is `pytch-`.
  `/home/ami/src/pytch/pytch` is a directory, not a git repo, so it
  is not a repo named `pytch`.
- **Ask.** A repo name equals the plug, and at least one other name
  starts with it. Stop before any pull, clone, or dry-run action
  list. Ask which was intended: every repo starting with the plug,
  or only the repo named exactly the plug. Wait for the answer. Do
  not guess. A missing question tool means print those two choices
  and wait. The answer selects the set. Archive and ignore skips
  still apply inside that set. Choosing the single repo when that
  repo is archived notes the skip and does not clone a second copy.

Skip a match when either archive rule already in the skill is true:
a path segment `archive` (case-insensitive), or
`gh repo view --json isArchived` true. A failed `gh` call does not
count as archived. Also skip a path any ancestor git repo ignores
(`git check-ignore` exit 0). Do not hardcode `.upstream`.

An archived or ignored name is not cloned and not pulled, even when
the basename starts with the plug. `pytch-iam` stays under `archive/`
during `get pytch-`. Print skips in the run notes, in path order.

- Live, not archived, not ignored: `git pull --ff-only` on the
  current branch. Do not checkout. Do not require `main`. Dirty or
  detached: note and skip that repo. A failed pull stops the rest of
  the bunch.
- No checkout anywhere under `src`, and GitHub `isArchived` is false:
  `git clone` into the parent of the live matches. For `pytch-` that
  parent is `/home/ami/src/pytch`. Several live parents is **Error**
  before any clone. Do not create a new parent.
- `dry-run` prints the skips, pull lines, and clone lines, and writes
  nothing. It does not retitle.

Live `get` sets `GIT:` per `docs/window_title.md` when `TMUX` is set.

## put

Same selection as `get`: the current repo, one repo, the prefix
family, or ask before any action. No plug, and the open folder is a
git repo, selects that folder only. The ask offers every repo
starting with the plug, or only the repo named exactly the plug. Archive and ignore skips are the
same. `put pytch-` does not check in
`/home/ami/src/archive/pytch/pytch-iam` and does not create a second
copy of it.

`put` runs the commit bunch for repos that already exist. `get` and
`unarchive` do not. `forcemain` does not run. `tag`, `msg`, `link`,
and `all` do not apply. `dry-run` is allowed and does not retitle.

"Eternal tracking notes" means the internal tracking docs already
used when `all` is set. Read `docs/` markdown, the README command
rows for the changed verb, and any `SKILL.md`, `HELP.md`, or
`TLDR.md` in the diff. Write the subject and body from those docs
and from the working tree. If they do not describe the change, say
so and describe the diff.

For each selected name that already has a live checkout:

- The branch must be `main` before `git add`. Any other branch,
  including `master`, and a detached `HEAD`, is **Error** before
  `git add`. No add, no commit, no push, in that repo or any later
  repo. Do not checkout `main`.
- Dirty: `git add -A`, one commit with that message, then
  `git push origin main`. Do not amend, skip hooks, push tags, or
  use `--force`.
- Clean: note it. No empty commit. If commits are already ahead of
  `origin/main`, push those. Do not invent a message for an empty
  commit.
- A secret-like path whose `git check-attr filter` is not `git-crypt`
  still aborts the whole put before `git add`. Do not install
  git-crypt into an existing repo as part of put.

For each selected name with no local checkout and no GitHub repo:
create it. A GitHub repo with no local checkout is not a create.
Note it and skip. Do not run `gh repo create` against a name that
already exists.

Create, in the same parent `get` would clone into. For a `pytch-`
name that parent is `/home/ami/src/pytch`. Several live parents, or
no parent, is **Error** before any create. Do not create the parent
directory. Do `mkdir` the new repo directory inside that parent.

1. `git init -b main` in the new directory.
2. `git-crypt init`. Do not copy another repo's key. Do not invent a
   GPG user. No `git-crypt add-gpg-user` in this step.
3. Write `.gitattributes` before `git add` of any secret. Every
   basename `.env`, and every basename that starts with `.env.`,
   gets `filter=git-crypt diff=git-crypt`, including `.env.example`
   and a file that contains no secrets. Do not read the file to
   decide. Do not copy the plaintext `!filter` lines from
   `/home/ami/src/pytch/pytch-fluent/.gitattributes`. Also mark the
   skill's other secret-like names (`credentials.json`, `id_rsa`,
   `id_dsa`, `id_ecdsa`, `id_ed25519`, `*.pem`, `*.key`, not
   `*.pub`). Do not gitignore `.env`. The attribute lines are:

```text
.env filter=git-crypt diff=git-crypt
.env.* filter=git-crypt diff=git-crypt
credentials.json filter=git-crypt diff=git-crypt
id_rsa filter=git-crypt diff=git-crypt
id_dsa filter=git-crypt diff=git-crypt
id_ecdsa filter=git-crypt diff=git-crypt
id_ed25519 filter=git-crypt diff=git-crypt
*.pem filter=git-crypt diff=git-crypt
*.key filter=git-crypt diff=git-crypt
```

4. `git check-attr filter -- <path>` must print `git-crypt` for each
   of those paths before the commit. Check `.env`, `.env.example`,
   `credentials.json`, `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`,
   a `*.pem` path, and a `*.key` path, plus any real secret-like path
   already in the new directory. If it does not, **Error**. No commit
   and no push.
5. One initial commit. The message says the repo was created with
   git-crypt and names the attribute rules.
6. Create a private GitHub repo under the sibling owner. Set `origin`
   to `git@github-adworkinitp:<owner>/<name>.git`, the same host live
   remotes already use. Do not leave the `github.com` URL `gh`
   prints. Then `git push origin main`.

`dry-run` prints the skips, the checkin commands, and the create
steps, and writes nothing. It does not retitle. A failed commit or
push stops the rest of the bunch.

Live `put` sets `GIT:` per `docs/window_title.md` when `TMUX` is set.

## unarchive

`unarchive` does not run the commit bunch. `forcemain` does not run.
`dry-run` is allowed and does not retitle. The spelling `unarachive`
is not an alias.

Resolve the name under the same `src` walk, including archive paths.
The token uses the existing basename-or-component rule, not the `get`
prefix family. `fluent` is the component of `pytch-fluent`. Archived
and ignored name-twins are not a second match. Zero matches is
**Error** before any move. Two archived-only matches is **Error**
before any move. No name, and the open folder is a git repo, selects
that folder. Do not search for a basename. No name, and the open
folder is not a git repo, is **Error** before any move.

Not archived by either rule: do not move, do not call `gh`, do not
commit. Print that the request was meaningless. This is a notice, not
the red **Error** used for a bad token. `pytch-fluent` is this case:
a live checkout already exists, and GitHub `isArchived` is false. A
meaningless unarchive does not retitle.

Otherwise undo each reason that applies:

- Path segment `archive`, and that segment is not the repo's own
  basename: move the checkout to the same path with that segment
  removed. `/home/ami/src/archive/pytch/pytch-iam` goes to
  `/home/ami/src/pytch/pytch-iam`. If the destination exists, or its
  parent directory does not, **Error** before the move. Do not create
  the parent. Do not overwrite.
- GitHub `isArchived` true: `gh repo unarchive <owner>/<name> --yes`,
  owner and name from that repo's `origin`. This covers
  `pytch-account`, `pytch-outreach`, `pytch-gpt`, and `pytch-admin`.
  A failed `gh repo view` does not count as archived.

A repo that is both path-archived and GitHub-archived gets the move
and the `gh` call. `dry-run` prints both and writes nothing.

Live `unarchive` sets `GIT:` per `docs/window_title.md` when `TMUX`
is set. A meaningless unarchive and `dry-run` do not retitle.

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
commits, including empty `/gitify`. Live `get`, live `put`, and
live `unarchive` set `GIT:` when `TMUX` is set. A meaningless
unarchive does not retitle. One repo keeps today's summary.
Several repos use three to six words, the link token when that
token is already that short. Help, tldr, pass, `--help`, `/?`, and
`dry-run` do not retitle.
