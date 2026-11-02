---
name: buildify
description: >-
  Buildify — prepare one private git-crypt GitHub repo, then hand any
  instruction tail to runnify. Use when the user runs /buildify or
  says "buildify". /buildify <name> creates or ensures that repo.
  /buildify clone <from> <to> duplicates an existing repo into a new
  one. /buildify destroy deletes the current repo. /buildify destroy
  <name> deletes that repo. Words after a create, ensure, or clone
  repo are the runnify prompt, and image, pass, and img tokens in
  that tail are passed to runnify. A destroy line has no runnify
  tail. /buildify help
  or /buildify --help (also /?) prints the full reference. /buildify
  tldr prints the short page. /buildify pass and pass help print the
  Pass (Npass) subsection.
---

# Buildify (= project setup)

You are running **Buildify** (`/buildify`) — a **thin project-setup
verb** in the Promptify family. You prepare one repo. If the user
typed anything after that repo, read and follow runnify on that
remainder. The follow-on work root is the repo just built.

You do not add a language, CI, or Docker scaffold. You do not plan,
debug, or answer the tail yourself. There is no `smart` mode. There
is no alias and no shell script. Empty `/buildify` is short usage.

1. Recognize help, tldr, and pass (Flag parse order, only for that
   recognition). Those modes stop. They do not create a repo and do
   not retitle.
2. Splice `from=` / `from:` before the grammar below. Strip a
   typed-line `docify`.
3. A bare `dry-run` token is buildify's. Remove it. Two is **Error**
   before any write.
4. First token `destroy` selects destroy. It is not a repo name
   and it is not `clone`. A destroy line does not hand a tail to
   runnify.
5. First token `clone` takes the next two tokens as `<from>` and
   `<to>`. Anything left is the runnify tail.
6. Otherwise the first token is the repo name. Anything left is the
   runnify tail, unchanged.
7. A flag-shaped token is never a repo name. Empty, or only flags,
   is short usage.
8. Create, ensure, or clone. Then run the tail only after a
   successful build. Destroy does not run a tail.

`buildify` with no slash is the same command. Canonical slash is
`/buildify`. No alias folder.

Follow `~/.claude/skills/promptify/SKILL.md` (repo:
`.claude/skills/promptify/SKILL.md`) for **Flag parse order**
only, and only to recognize help, tldr, and pass. Do not run a
pass loop. Do not open scratch. Do not print the scratch or Npass
acknowledgements.

The attribute lines below are the block in
`.claude/skills/gitify/SKILL.md` (put). Read that section. Do not
invent a second list. Do not copy
`/home/ami/src/pytch/pytch-fluent/.gitattributes`.

---

## Help (`help` / `--help` / `/?` / `tldr`)

On the typed line only. Case-insensitive whole tokens.

Use Flag parse order only as a view. Strip numbered image
directives, the first numbered pass token, and `img=` / `img:`
tokens on that view. Then take the first remaining token.
`buildify 1image help` is help. The real tail is unchanged when
the line is not one of these modes.

- First token `help`, `--help`, or `/?`: **read and print**
  `references/HELP.md` (this skill folder) and **stop**. Further
  words (`help me …`) stay on Help. They do not create a repo.
- First token `tldr`: **read and print** `references/TLDR.md` and
  **stop**. Exact `tldr` is that short page. There is no `tldr help`
  alias. Further words stay on tldr.
- First token `pass`, including body `pass help`: print the
  **Pass (`Npass`)** section of `references/HELP.md` and **stop**.
  There is no `/pass` skill.

These do not create a repo, do not read scratch, and do not retitle.

`password` and `helpful` are not the whole tokens `pass` and
`help`.

Empty `/buildify`, or a line whose only tokens are flags, is short
usage. Print the block below and stop. Do not retitle. Do not write.

```text
/buildify <name> [instructions…]
/buildify clone <from> <to> [instructions…]
/buildify destroy [repo|folder|both]
/buildify destroy <name> [repo|folder|both]
/buildify dry-run <name> [instructions…]
/buildify dry-run destroy [name]
/buildify help
/buildify tldr
/buildify pass help
```

---

## Flag parse order (`Nimages` / `Npass`)

On the **typed line only**. File bodies are not scanned.

Image directives, pass directives, and `img=` / `img:` tokens are
flag-shaped. Shapes are promptify **Flag parse order** (`1image`,
`3pass`, `img=…`, and the other forms that file already counts).
Buildify does not take that family. It does not print the scratch
or Npass acknowledgements and does not read scratch.

Use the strip only to recognize help, tldr, and pass. When the
line is not those modes, the tokens stay. They belong to the
runnify tail.

A line that is only flags is short usage.

## Named images (`img`)

Do not treat `img` as a buildify directive. `img=<file>`,
`img:<file>`, `img=[a,b]`, and `img:[a,b]` are flag-shaped. They
are never a repo name, `<from>`, `<to>`, or a destroy name. In
the tail of a create, ensure, or clone they are runnify's.
`buildify destroy 1image` is **Error**, not a runnify tail.
Cite promptify **Named images**. Do not fork that
grammar.

---

## Parse

The typed line is the text after the verb. File bodies are
literal. Do not scan them for `dry-run`, `clone`, `destroy`,
`from=`, `docify`, or a repo name.

1. **Help, tldr, pass.** Above. Stop. Do not read files.
2. **From files.** Cite `docs/from_contract.md`. Splice, then
   continue. Any from-error stops the turn. No `git init`.
3. **Docify.** Strip typed-line `docify` / `docpathify` per the
   docify skill's `references/docify_contract.md`. Those tokens
   are not a repo name. The write happens after a successful
   build. `dry-run` does not write that file.
4. **`dry-run`.** A bare token, case-insensitive. Remove every
   such token from the line so runnify never sees it. Two bare
   `dry-run` tokens is **Error** before any write or delete. A
   token that is not bare (`dry-run:TEXT`) stays on the line.
5. **`destroy`.** After that removal, case-insensitive first
   token `destroy` selects this mode. It is not a repo name and
   it is not `clone`. The next token, when it is present and is
   not a selector, is the exact basename. Selector tokens are
   the whole words `repo`, `folder`, and `both`, case-insensitive.
   They may follow the name. `repo` is GitHub only. `folder` is
   directories only. `both` is the default. A selector with no
   name is the current folder. A token after a selector, a
   second selector, or any other leftover token is **Error**
   before any delete. A destroy line does not hand a tail to
   runnify. A flag-shaped token here is **Error**.
   `buildify destroy 1image` is that error.
6. **`clone` or a name.** Otherwise, case-insensitive first
   token `clone` takes the next two tokens as `<from>` and
   `<to>`. Anything left is the runnify tail, image and pass
   tokens included. Otherwise the first token is the repo name.
   Anything left is the runnify tail, unchanged. `clone` is
   reserved only as that first task token. `buildify test-repo
   clone the fixtures` builds `test-repo` and hands `clone the
   fixtures` to runnify. `destroy` is reserved only as that
   first task token. `buildify test-repo destroy the fixtures`
   builds `test-repo` and hands `destroy the fixtures` to
   runnify.

A flag-shaped token is never a repo name, `<from>`, `<to>`, or
a destroy name. Empty, or only flag-shaped tokens, is short
usage. A flag-shaped first token with a later name token is
**Error** before any write. `clone` with fewer than two name
tokens is **Error** before any write.

The name, `<from>`, `<to>`, and a destroy basename are one token
each and must pass `git check-ref-format --branch`. A failure is
**Error** before any write or delete. Lookup is the exact
basename. `fluent` is a repo named `fluent`, not the gitify
component of `pytch-fluent`. `repo`, `folder`, and `both` on a
destroy line are selectors, not that basename.

---

## Placement

Search every directory under the nearest ancestor named `src`.
Do not walk above `src`. Do not enter `.git` or `node_modules`.
No `src` ancestor is **Error** before any write.

A directory with `.git` whose basename equals the name is a
checkout. Two such checkouts is **Error** before any write.
One checkout: that checkout.

No checkout, and `/home/ami/src/<prefix>` exists, is not a git
repo, and the name starts with `<prefix>-`: the path is
`/home/ami/src/<prefix>/<name>`. Longest prefix wins.
`sva-new` lands in `/home/ami/src/sva/` because that directory
exists and is not a repo.

No checkout and no such prefix: `/home/ami/src/<name>`.
`test-repo` lands at `/home/ami/src/test-repo`.

Create only the new repo directory. Do not create a family
parent. Do not nest a new repo inside a directory that is
itself a git repo. If the destination exists and is not the
checkout being repaired, **Error** before any write.

GitHub lookup is the exact repo `solovaultai/<name>`
(`gh repo view solovaultai/<name> --json name,isArchived`).
Not found means it does not exist. A failed `gh` call that is
not a not-found stops the turn. A failed view does not count
as archived.

---

## Create

Create when the name is neither a local checkout nor GitHub
repo `solovaultai/<name>`. Follow the create steps in the
gitify skill's put section. Same key rules. Same attribute
block.

1. `mkdir` the new repo directory. `git init -b main`.
2. `git-crypt init`. New key. Do not copy a key. Do not run
   `git-crypt add-gpg-user`. Do not export a key to the
   Desktop. `/home/ami/src/git-crypt-instructions.txt` is a
   personal note, not the contract.
3. Write `.gitattributes` before `git add` of any secret.
   The lines are the gitify put block:

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

4. Write `README.md` when absent. A heading with the repo
   name, and one sentence that the repository is private and
   secret-like files are git-crypt encrypted:

```markdown
# <name>

This repository is private and secret-like files are git-crypt encrypted.
```

5. `git check-attr filter -- <path>` must print `git-crypt`
   for the gitify check paths before the commit. Check
   `.env`, `.env.example`, `credentials.json`, `id_rsa`,
   `id_dsa`, `id_ecdsa`, `id_ed25519`, a `*.pem` path, and
   a `*.key` path. If it does not, **Error**. No commit and
   no push.
6. One initial commit. The message says the repo was created
   with git-crypt and names those attribute rules. Stage
   `.gitattributes`, `README.md`, and any secret-like path
   already in the new directory.
7. Private GitHub repo under the owner taken from a live
   sibling `origin`. Origins already checked use owner
   `solovaultai` and host `git@github-adworkinitp`. If the
   sibling origins disagree on host or owner, **Error**
   before `gh repo create`. If no live sibling origin
   exists, **Error** before `gh repo create`. Do not guess.
   `gh repo create <owner>/<name> --private`. Set `origin`
   to `git@github-adworkinitp:<owner>/<name>.git`. Do not
   leave the `github.com` URL `gh` prints. Then
   `git push -u origin main`.

---

## Ensure

Ensure when the name is already a local checkout or GitHub
repo `solovaultai/<name>`.

- GitHub `isArchived` true: `gh repo unarchive <owner>/<name> --yes`
  (gitify unarchive). Owner and name from that repo. A failed
  `gh repo view` does not count as archived.
- No checkout, and `isArchived` is false (or the unarchive
  just succeeded): `git clone` into the placement path. Use
  `git@github-adworkinitp:<owner>/<name>.git`. Do not clone
  the `github.com` URL `gh` prints.
- Checkout under a path segment `archive`, and that segment
  is not the repo's own basename: move it the way gitify
  unarchive moves `/home/ami/src/archive/pytch/pytch-iam` to
  `/home/ami/src/pytch/pytch-iam`. If the destination exists,
  or its parent does not, **Error** before the move. Do not
  create the parent. Do not overwrite.
- `git ls-remote origin` must succeed. If it does not,
  **Error** before `git add`. If `origin` is a `github.com`
  URL, rewrite it to
  `git@github-adworkinitp:<owner>/<name>.git` before the push.
- The branch must be `main` before any `git add`. Read it
  with `git rev-parse --abbrev-ref HEAD`. Any other branch,
  including `master`, or a detached `HEAD`, stops the turn.
  Do not checkout `main`. No add, no commit, no push.
- No `.git-crypt` yet: `git-crypt init` with a new key.
  Same key rules as create. Do not copy a key.
- `.gitattributes` missing the gitify lines: add the missing
  lines. Leave project-specific lines already there. Leave
  a `.gitattributes !filter !diff` line if the file already
  has one. Do not add that `!filter` line when it is absent.
- Secret-like is the gitify basename rule. Do not read file
  contents to decide. The basename is `.env`, a name starting
  with `.env.`, `credentials.json`, `id_rsa`, `id_dsa`,
  `id_ecdsa`, `id_ed25519`, or a name ending in `.pem` or
  `.key`, and not a name ending in `.pub`. Do not gitignore
  `.env`.
- `git check-attr filter` must print `git-crypt` for each of
  those paths that exist, and for the gitify check paths. If
  it does not, **Error**. No commit and no push.
- Missing `README.md`: write the same minimal README as create.
- Stage `.gitattributes`, `README.md` if it was added, and
  those secret-like paths so the clean filter stores
  ciphertext. Do not stage unrelated dirty or untracked
  files. Do not `git add -A`.
- One commit, then `git push origin main`. The message says
  git-crypt was ensured and names the attribute rules. A
  clean tree that already matches is noted. No empty commit.
  Do not push when there is no commit.
- Prior commits can still hold plaintext. Report that. Do
  not rewrite history.

---

## Clone

`buildify clone <from> <to>`.

Resolve `<from>` as an exact basename under `src`, or GitHub
`solovaultai/<from>`. The same two-checkout rule applies.
Zero matches: tell the user the source is missing and ask
with the AskQuestion tool whether to create a new repo named
`<to>`. Yes runs create for `<to>`. No stops. Do not create
`<from>`. Do not guess. If AskQuestion is unavailable, print
the two choices and wait.

`<to>` already a checkout or a GitHub repo: **Error** before
any copy. Do not overwrite. Check this before the question.

Source work tree locked (ciphertext, unlock not available):
**Error** before any copy. Do not export a key. Do not copy
the source key.

Create the `<to>` directory with the placement rule.
`git init -b main`. `git-crypt init` with a new key. Copy
the source work tree except `.git` and `.git-crypt`. Keep
the source README. When the source has no README, write the
same minimal README as create. Keep source attribute lines,
and add any missing gitify secret lines. Leave a
`.gitattributes !filter !diff` line if the source has one.
Same check-attr, commit, private GitHub, and push as create.
The copied files are that commit. Secret-like paths go
through the clean filter. Do not modify the source repo.

---

## Destroy

`buildify destroy` with no name destroys the current repo.
`buildify destroy <name>` destroys the named repo. Nothing is
deleted on the proposing turn.

### Current folder

No name: the open folder. That folder is the only directory
target. Do not scan
the disk for other folders with the same basename.

If that folder is already gone, stop. There is no current
folder.

When `origin` exists, the GitHub repo is the one that URL
names. When the open folder is not a git repo and has no
`origin`, this is folder deletion only. Say that.

### Named repo

The basename is exact.

1. Walk parents of the open folder up through the user's home
   directory. Record a parent only when that parent's own
   basename equals the name.
2. Search under the user's home for directories with that
   exact basename. Do not walk above home. Do not enter
   `.git`, `node_modules`, or `.cache`. Do not follow a
   symlink that leaves home.

Also resolve GitHub the way create does. Owner comes from a
live sibling `origin`. Origins already checked use owner
`solovaultai` and host `git@github-adworkinitp`. If those
origins disagree, **Error** before any delete when a GitHub
delete was requested. `gh repo view <owner>/<name>` decides
whether that repo exists. A failed `gh` call is **Error**
when a GitHub delete was requested. It is not proof that the
repo is absent.

- Folders found and the GitHub repo exists: offer both.
- The GitHub repo does not exist: folder deletion only. Say
  that.
- No folder anywhere and the GitHub repo exists: GitHub
  deletion only. Say that.
- Neither: **Error** before any delete. Name the basename,
  the home search, and `<owner>/<name>`.

Several matching folders: list every absolute path. The user
chooses `all` or a subset of those paths. A path that was not
listed is **Error**. The later basename confirmation covers
only that set. Do not delete a path that was not listed.

### repo, folder, or both

Default is `both`, limited to targets that exist.
`repo` deletes the GitHub repo and leaves every folder.
`folder` deletes the chosen folders and leaves the GitHub
repo. If the requested side does not exist, **Error** before
any delete. Do not silently delete the other side.

### Verification

The proposing turn prints the plan and stops. The plan lists
each folder path, whether the GitHub repo exists
(`owner/name`), the commit count when a local git repo is in
the set, and which side will be deleted. No delete.

When more than one folder would be deleted, the next turn
chooses `all` or the subset of listed paths. That turn does
not delete. A path that was not listed is **Error**. The
basename confirmation comes after that choice and covers
only the chosen set.

The confirmation turn must be the exact basename and nothing
else. For the current folder, that basename is the open
folder's basename. A mismatch, an empty answer, or anything
else stops. No delete.

Second verification, only when a git repo being destroyed has
more than 3 commits (4 or more). Count with
`git rev-list --count HEAD` from that repo. No `HEAD` is 0.
Any other failure to count is **Error** before any delete.
If several repos qualify, use the largest count. The user
must type `delete <N> commits` with that exact N, on its own
turn, after the basename matched. Typing the name again does
not satisfy it. A mismatch stops. No delete.

The second check applies when that repo's folder is being
deleted or its GitHub repo is being deleted. A folder that is
not a git repo does not add a second check.

Only after the required typed checks succeed:

- GitHub: `gh repo delete <owner>/<name> --yes`
- Folder: remove that directory. Do not remove a path outside
  the listed set. Do not remove `/` or the user's home. If
  the open folder is the one being removed, operate from the
  parent. State that parent as the new context. The skill
  cannot permanently `cd` the user's shell. Do not delete
  the parent.

Do not rewrite history. Do not force-push. Do not delete the
git-crypt key file from anywhere else.

`destroy` sets `BUILD:` on the turn that actually deletes,
when `TMUX` is set. Summary is three to six words
(`destroy test-repo`). The proposing turn, a mismatch, and
`dry-run` do not retitle.

### Dry-run

On a destroy line, `dry-run` prints the resolution and the
commands. It writes nothing, asks nothing, deletes nothing,
and does not retitle.

---

## Dry-run

`dry-run` prints the placement, the git and gh commands, the
attribute lines, and the runnify tail that would have run.
On destroy it prints the resolution and the commands instead.
It writes nothing, asks nothing, and does not retitle. A
missing clone source is printed as the question that would
have been asked. It does not call AskQuestion. It does not
start runnify. It does not delete.

---

## Runnify

A non-empty tail runs only after the build succeeds. Read
and follow `~/.claude/skills/runnify/SKILL.md` (repo:
`.claude/skills/runnify/SKILL.md`). The tail is the prompt,
including `1image`, `3pass`, and `img=` tokens. Buildify
does not print the scratch or Npass acknowledgements and
does not read scratch. Runnify does, under its own rules.

The work root is the repo just built, not the sva-skills
checkout and not the folder that was open when buildify
started. When the tail runs, runnify's own contract
retitles to `RUN:`.

A failed build, a declined create, `dry-run`, or a destroy
line does not start runnify. An empty tail stops after a
short build report: path, created or ensured or cloned, and
that the git-crypt check passed.

`buildify test-repo make a repo that tests our other repos 1image 3pass`
is `buildify test-repo`, then runnify with
`make a repo that tests our other repos 1image 3pass`.

---

## From files

Cite `docs/from_contract.md`.
`from=` and `from:` splice local files into this prompt.
Help, tldr, pass, and empty do not read files.

## Docify

Cite the docify skill's `references/docify_contract.md`. A typed-line `docify` / `docpathify` writes this verb's deliverable. Help, tldr, pass, and empty do not write. Read-only modes may create or overwrite only that resolved file.

The deliverable is the build report, and the runnify
Results when a tail ran. On destroy it is the plan, or the
delete report after the typed checks. `dry-run` does not
write that file. A proposing turn does not delete.

## Optify

Cite the optify skill's `references/optify_contract.md`. On: short router, and only the mode just parsed. Off: the full reference set. Clear and compact follow that contract. Help, tldr, pass, and empty usage do not retitle.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `BUILD:`.
Summary is three to six words (`create test-repo`,
`clone foo to bar`, `ensure test-repo`). Whole name at most
48 characters. Set the tmux window name per that contract
on a live create, ensure, or clone, only when `TMUX` is set.
A live destroy sets it on the turn that deletes. Summary
`destroy <name>`, three to six words. The proposing turn
does not retitle.

Help, tldr, pass, `--help`, `/?`, empty usage, and
`dry-run` do not retitle. A stop (bad name, two checkouts,
missing sibling origin, check-attr failure, branch not
`main`, destroy mismatch) does not retitle. `BUILD` is not a
phasify ancestor prefix. When the tail runs, runnify
retitles to `RUN:`.

---

## Hard rules

- Thin project-setup verb. One repo, then the runnify tail.
  No language, CI, or Docker scaffold. No alias. No
  `scripts/cli.sh` subcommand. No shell script in this skill.
- Help, tldr, and pass print their page and stop. They do
  not create a repo and do not retitle. Empty `/buildify`
  is short usage.
- Image, pass, and `img=` tokens stay in the tail of a
  create, ensure, or clone. On a destroy line they are
  **Error**. Buildify does not read scratch and does not
  print those acknowledgements.
- One bare `dry-run`. Two is **Error** before any write or
  delete. Dry-run writes nothing, deletes nothing, asks
  nothing, and does not retitle.
- The name is one token and must pass
  `git check-ref-format --branch`. Exact basename. Two
  checkouts is **Error** before any write.
- Create: `git init -b main`, `git-crypt init` with a new
  key, the gitify attribute block, the minimal README,
  check-attr, one commit, private GitHub, SSH origin
  `git@github-adworkinitp:<owner>/<name>.git`,
  `git push -u origin main`. Sibling origins that disagree
  stop before `gh repo create`.
- Do not copy a key. Do not run `git-crypt add-gpg-user`.
  Do not export a key. Do not treat
  `/home/ami/src/git-crypt-instructions.txt` as the contract.
- Ensure repairs reachability and git-crypt. Do not
  `git add -A`. Do not empty-commit. Do not rewrite history.
  Report that prior commits can still hold plaintext.
  Branch not `main` stops the turn. Do not checkout `main`.
- Clone copies the work tree except `.git` and `.git-crypt`,
  with a new key. Do not modify the source. A missing source
  asks before creating `<to>`. Do not create `<from>`.
- A non-empty tail runs runnify only after the build
  succeeds. The work root is that repo. A destroy line has
  no tail.
- `destroy` prints the plan and waits. The next turn is the
  exact basename. Four or more commits then require
  `delete <N> commits` with the largest count. Only then
  `gh repo delete <owner>/<name> --yes` and remove the
  listed directories. Do not remove `/` or the home
  directory. Do not rewrite history, force-push, or delete
  a git-crypt key from anywhere else. The proposing turn,
  a mismatch, and `dry-run` do not delete and do not
  retitle. The turn that deletes sets `BUILD:` when `TMUX`
  is set.
- Cite `docs/from_contract.md`, the docify skill's
  `references/docify_contract.md`, the optify skill's
  `references/optify_contract.md`, and `docs/window_title.md`.
  Prefix `BUILD:`.
