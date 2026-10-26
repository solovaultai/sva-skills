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
  origin main. get <plug> pulls or clones repos whose basename
  starts with that literal prefix and skips archived and ignored
  repos. With no plug or name, and the open folder is a git repo,
  get, put, and unarchive act on that repo only. put <plug> checks existing repos in to origin main, or
  creates a missing repo with git-crypt. unarchive <repo> restores
  one archived repo, or notes that a request on a repo that is not
  archived was meaningless. The spelling unarachive is not an alias.
  status, push, log, diff, commit, and git are stop words,
  not repo names. Any other unmatched token stops with no git
  write. /gitify help or /gitify --help (also /?) prints the full
  reference. /gitify tldr prints the short page. /gitify pass and
  pass help print the Pass (Npass) subsection. After a successful
  commit, runs `git push origin <current-branch>`. Detached HEAD
  aborts before `git add`. Does not amend, skip hooks, or change
  git config. Does not push tags. Does not pull, except get. Does not use
  `--force`. No smart mode. Strips every numbered image directive
  before the directives, including negatives, multiples, and zero.
  Does not open scratch and does not print the imagify zero error.
  Npass stays the first numbered instance (gitify does not run its
  own pass loop).
metadata:
  short-description: "Add each dirty worktree and make one commit"
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
do not pull, except `get`.
`get`, `put`, and `unarchive` are modes. `get` and `unarchive` do
not run the commit bunch. `put` does, for repos that already exist.
`forcemain` does not run on these modes. `unarachive` is not an
alias. The directive spelling is `unarchive`.
You do not plan, execute, debug, or answer. There is no `smart`
mode. Empty `/gitify` commits every dirty repo under the open
folder, not short usage.

1. Strip `Nimages` / `Npass` on the typed line (Flag parse order).
2. Help, tldr, and pass print only, then stop. They do not touch git.
3. Splice `from=` / `from:` files. Strip a typed-line `docify`.
4. Parse `tag`, `msg`, `link`, `dry-run`, `forcemain`, `all`, `get`,
   `put`, and `unarchive`. Match `get`, `put`, and `unarchive` before
   a leftover token becomes a commit selector. On a commit line, one
   optional selector names one repo. A stop word or any other unmatched
   token stops with no git write.
5. When `get`, `put`, or `unarchive` is set, follow that section and
   stop. Do not continue into the commit preflight. `forcemain` does
   not run. `put` checks in existing repos from that section, not
   from the open-folder bunch. Otherwise resolve the open folder and
   the bunch. Classify archived, clean, and dirty. Path sort is fixed.
6. Preflight every dirty repo. Read the branch before the first
   `git add`. Detached `HEAD` aborts before `git add`. Build one
   action list before that add. `dry-run` prints that list and
   writes nothing.
   A live run executes that same list. Tag only after that commit
   succeeds.
7. Set the window title when a live bunch commits, including empty
   `/gitify`. Live `get`, live `put`, and live `unarchive` also set
   `GIT:` when `TMUX` is set. A meaningless unarchive and `dry-run`
   do not retitle.

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
/gitify get              — pull the open folder when it is a git repo
/gitify get pytch-       — pull or clone basenames starting with pytch-
/gitify get:pytch-fluent — that one repo (get=pytch-fluent is the same)
/gitify put              — check in the open folder when it is a git repo
/gitify put pytch-       — check in that prefix, or create a missing repo
/gitify put:pytch-fluent — check in that repo (put=pytch-fluent is the same)
/gitify unarchive        — unarchive the open folder when it is a git repo
/gitify unarchive pytch-iam — restore that archived repo
/gitify help            — full reference (also --help, /?)
/gitify tldr            — short form (stop)
/gitify pass help       — Pass (Npass) subsection (also `pass`)
```

---

## Flag parse order (`Nimages` / `Npass`)

On the **typed line only**.

**Image family.** Strip every numbered image directive on the
typed line. `1image -3image` strips both. A negative count is
one directive.

Accepted shapes (case-insensitive). N is digits, including 0:

- `Nimage`, `Nimages`, `N-image`, `N-images`, `N image`, `N images`
- `imageN`, `imagesN`
- `-Nimage`, `-Nimages`, `-N-image`, `-N-images`, `-N image`, `-N images`
- `image-N`, `images-N`

`0image`, `image0`, and `-0image` are in that list, and so is every
other accepted shape whose digits are 0. Strip them. Do not print
`Error: image count starts at 1`.

`image -3` is not a negative directive. When that `image` is the
first token, it is `1image` and the `-3` stays on the line. Use
`-3image` or `image-3` for a negative. `image -3image` is two
directives when `image` is the first token (`1image` and `-3image`).
Both are stripped. Unnumbered `image` / `images` are not directives
except that leading `image`. `images` and a non-leading `image` stay
unnumbered.

**Pass family.** The first numbered `Npass`, `N-pass`, or `N pass`
is the pass flag. A later numbered pass token stays on the line.
Do not take the largest N. Unnumbered `pass` / `passes` are not
pass flags.

Strip every image directive and that first numbered pass before
help, tldr, pass, or the directives. They are not body text and not
directives. Gitify does not loop, does not open scratch, and does
not print the scratch or Npass acknowledgements. One commit per
dirty repo. A line that is only flags is an empty `/gitify` commit
of every dirty repo under the open folder.

## Named images (`img`)

Do not treat `img` as a gitify directive. An `img=` / `img:` token
is a leftover. Stop with no git write.

---

## Parse

The typed line is the text after the verb. File bodies are
literal. Do not scan them for `tag`, `msg`, `link`, `dry-run`,
`forcemain`, `all`, `get`, `put`, `unarchive`, `from=`, `docify`,
or a selector.

1. **Flags.** Already stripped.
2. **Help, tldr, pass.** First token, above. Stop. Do not read
   files.
3. **From files.** Cite `docs/from_contract.md`. Splice, then
   continue. Any from-error stops the turn. No `git add`.
4. **Docify.** Strip typed-line `docify` / `docpathify` per the
   docify skill's `references/docify_contract.md`. Those tokens
   are not leftovers. The write happens after a successful commit.
   On `get` and `unarchive`, that write happens after the mode
   succeeds. On `put`, it happens after the checkin or the create
   push. `dry-run` still does not write that file.
5. **Directives and one selector.** Match `get`, `put`, and
   `unarchive` before a leftover token becomes a commit selector.
   Every remaining token is one directive, the one plug or repo
   token those three require, or the optional commit selector.

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
| `get` / `get:PLUG` / `get=PLUG` | One plug. Literal basename prefix. Pull or clone. No plug, and the open folder is a git repo, acts on that repo only. Case-insensitive key. Does not run the commit bunch. `dry-run` is allowed. |
| `put` / `put:PLUG` / `put=PLUG` | One plug or repo name. Check in to `origin main`, or create with git-crypt. No plug, and the open folder is a git repo, acts on that repo only. `msg` is not accepted. |
| `unarchive` / `unarchive:NAME` / `unarchive=NAME` | One repo token, basename or component. Restore one archived repo. No name, and the open folder is a git repo, acts on that repo only. `unarachive` is not an alias. |

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

A token that is not a directive, and not the one plug or repo
token `get`, `put`, or `unarchive` requires, is a commit selector,
unless it is a stop word. One selector is optional. Two selector
tokens is **Error** before any write.

`status`, `push`, `log`, `diff`, `commit`, and `git` are stop
words. They are not repo names and not selectors. A stop word, or
any other unmatched token, stops the turn with no write. Print
that a typed `push` is not a repo and not a request. That word
is not the `forcemain` directive. After a successful commit,
gitify runs `git push origin <current-branch>`. It is not a git
engine. Do not add, commit, tag, or push when a stop word aborted
the turn.

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
empty `/gitify`. Live `get`, live `put`, and live `unarchive` set
`GIT:` when `TMUX` is set. A meaningless unarchive does not retitle.
One repo keeps today's summary: three to six words
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
  before that push. Do not push tags. Do not pull, except `get`.
  Do not amend.
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
- `get` is one plug, a literal case-sensitive basename prefix, not
  a regular expression and not a component name. No plug, and the
  open folder is a git repo, selects that folder only. Do not expand
  its basename into a prefix family. Do not ask. No plug, and the
  open folder is not a git repo, two plugs, or `get` plus `tag`,
  `msg`, `link`, `forcemain`, `all`, `put`, `unarchive`, or a commit
  selector is **Error** before any write. `dry-run` is allowed. `get:pytch-` and `get pytch-` are
  the same. Walk every directory under the nearest ancestor named
  `src`. Do not walk above `src`. Do not enter `.git` or
  `node_modules`. No `src` ancestor is **Error**. This walk is
  deeper than the one-or-two-level commit selector. After that walk
  and `gh repo list <owner> -L 1000 --json name,isArchived`,
  classify before any pull or clone: current repo, one repo, prefix
  family, or ask. Ask stops before any pull, clone, or dry-run action list.
  Do not guess. Owner and SSH host come from a local `origin` of a
  repo with that prefix. Clone
  `git@github-adworkinitp:solovaultai/<name>.git`, not the
  `github.com` URL `gh` prints. Disagreeing origins, no local
  origin, or a plug that matches nothing locally and nothing
  remotely is **Error** before any clone. Skip path segment
  `archive`, GitHub `isArchived`, and `git check-ignore` exit 0.
  Do not hardcode `.upstream`. A failed `gh` call is not archived.
  Archived and ignored names are not cloned and not pulled.
  `pytch-iam` stays under `archive/` during `get pytch-`. Live:
  `git pull --ff-only` on the current branch. Do not checkout. Do
  not require `main`. Dirty or detached: note and skip. A failed
  pull stops the rest. No checkout under `src`, and GitHub
  `isArchived` false: `git clone` into the parent of the live
  matches. Several live parents is **Error** before any clone. Do
  not create a new parent. `get` does not run the commit bunch.
  `forcemain` does not run. `dry-run` prints skips, pull lines, and
  clone lines, writes nothing, and does not retitle.
- `put` uses the same selection as `get`, including the ask, and
  the same archive and ignore skips. `put pytch-` does not check
  in the archive `pytch-iam` and does not create a second copy.
  No plug, and the open folder is a git repo, selects that folder
  only. No plug, and the open folder is not a git repo, two plugs,
  or `put` plus `tag`, `msg`, `link`, `forcemain`, `all`, `get`,
  `unarchive`, or a commit selector is **Error** before any write. `msg` is not accepted. The message
  comes from the tracking docs used when `all` is set. An existing
  live checkout must be on `main` before `git add`. Any other
  branch, including `master`, and a detached `HEAD`, is **Error**
  before `git add`. Do not checkout `main`. Dirty: `git add -A`,
  one commit, `git push origin main`. Do not amend, skip hooks,
  push tags, or use `--force`. Clean: note it. No empty commit.
  If commits are already ahead of `origin/main`, push those. A
  secret-like path whose `git check-attr filter` is not `git-crypt`
  aborts the whole put before `git add`. Do not install git-crypt
  into an existing repo as part of put. No local checkout and no
  GitHub repo: create it in the parent `get` would clone into. Do
  not create that parent. A GitHub repo with no local checkout is
  not a create. Do not `gh repo create` a name that already exists.
  Several live parents, or no parent, is **Error** before any
  create. Create steps: `git init -b main`; `git-crypt init` with
  no copied key and no `git-crypt add-gpg-user`; write
  `.gitattributes` before `git add` of any secret so every `.env`
  basename and every basename starting with `.env.` gets
  `filter=git-crypt diff=git-crypt`, including `.env.example`, plus
  `credentials.json`, `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`,
  `*.pem`, and `*.key`, not `*.pub`; do not gitignore `.env`; do
  not copy plaintext `!filter` lines; `git check-attr filter` must
  print `git-crypt` for each of those paths before the commit, else
  **Error**, no commit, no push; one initial commit whose message
  says the repo was created with git-crypt and names the attribute
  rules; private GitHub repo under the sibling owner; `origin` is
  `git@github-adworkinitp:<owner>/<name>.git`; `git push origin
  main`. `dry-run` prints skips, checkin commands, and create steps,
  writes nothing, and does not retitle. A failed commit or push
  stops the rest of the bunch.
- `unarchive` needs one repo token, basename or component, under
  the same `src` walk, including archive paths. It is not a prefix
  family. No name, and the open folder is a git repo, selects that
  folder. No name, and the open folder is not a git repo, two names,
  or `unarchive` plus `get`, `put`, `tag`, `msg`, `link`,
  `forcemain`, or `all` is **Error** before any write. `unarachive` is not an alias. Zero matches, or
  two archived-only matches, is **Error** before any move.
  Archived and ignored name-twins are not a second match. Not
  archived by either rule: do not move, do not call `gh`, do not
  commit. Print that the request was meaningless. That notice is
  not the red **Error**. `pytch-fluent` is this case. A path
  segment `archive` that is not the repo's own basename: move the
  checkout to the same path with that segment removed.
  `/home/ami/src/archive/pytch/pytch-iam` goes to
  `/home/ami/src/pytch/pytch-iam`. If the destination exists, or
  its parent does not, **Error** before the move. Do not create the
  parent. Do not overwrite. GitHub `isArchived` true:
  `gh repo unarchive <owner>/<name> --yes`, owner and name from
  that repo's `origin`. Both reasons: move and the `gh` call.
  `dry-run` prints both and writes nothing. `unarchive` does not
  run the commit bunch.
- Dry-run does not retitle. A live bunch that commits does. Live
  `get`, live `put`, and live `unarchive` set `GIT:` when `TMUX`
  is set. A meaningless unarchive does not retitle. One repo keeps
  today's summary. Several repos use three to six words, the link
  token when that token is already that short.
- Cite `docs/from_contract.md`, the docify skill's
  `references/docify_contract.md`, and `docs/window_title.md`.
  Prefix `GIT:`.
