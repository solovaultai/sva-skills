---
name: buildify
description: >-
  Buildify — prepare one private git-crypt GitHub repo, then hand any
  instruction tail to runnify. Use when the user runs /buildify or
  says "buildify". /buildify <name> creates or ensures that repo.
  /buildify clone <from> <to> duplicates an existing repo into a new
  one. Words after the repo are the runnify prompt, and image, pass,
  and img tokens in that tail are passed to runnify. /buildify help
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
4. First token `clone` takes the next two tokens as `<from>` and
   `<to>`. Anything left is the runnify tail.
5. Otherwise the first token is the repo name. Anything left is the
   runnify tail, unchanged.
6. A flag-shaped token is never a repo name. Empty, or only flags,
   is short usage.
7. Create, ensure, or clone. Then run the tail only after a
   successful build.

`buildify` with no slash is the same command. Canonical slash is
`/buildify`. No alias folder.

Follow `~/.grok/skills/promptify/SKILL.md` (repo:
`.grok/promptify/SKILL.md`) for **Flag parse order**
only, and only to recognize help, tldr, and pass. Do not run a
pass loop. Do not open scratch. Do not print the scratch or Npass
acknowledgements.

The attribute lines below are the block in
`.grok/gitify/SKILL.md` (put). Read that section. Do not
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
/buildify dry-run <name> [instructions…]
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
are never a repo name, `<from>`, or `<to>`. In the tail they are
runnify's. Cite promptify **Named images**. Do not fork that
grammar.

---

## Parse

The typed line is the text after the verb. File bodies are
literal. Do not scan them for `dry-run`, `clone`, `from=`,
`docify`, or a repo name.

1. **Help, tldr, pass.** Above. Stop. Do not read files.
2. **From files.** Cite `docs/from_contract.md`. Splice, then
   continue. Any from-error stops the turn. No `git init`.
3. **Docify.** Strip typed-line `docify` / `docpathify` per the
   docify skill's `references/docify_contract.md`. Those tokens
   are not a repo name. The write happens after a successful
   build. `dry-run` does not write that file.
4. **`dry-run`.** A bare token, case-insensitive. Remove every
   such token from the line so runnify never sees it. Two bare
   `dry-run` tokens is **Error** before any write. A token that
   is not bare (`dry-run:TEXT`) stays on the line.
5. **`clone` or a name.** After that removal, case-insensitive
   first token `clone` takes the next two tokens as `<from>` and
   `<to>`. Anything left is the runnify tail, image and pass
   tokens included. Otherwise the first token is the repo name.
   Anything left is the runnify tail, unchanged. `clone` is
   reserved only as that first task token. `buildify test-repo
   clone the fixtures` builds `test-repo` and hands `clone the
   fixtures` to runnify.

A flag-shaped token is never a repo name, `<from>`, or `<to>`.
Empty, or only flag-shaped tokens, is short usage. A flag-shaped
first token with a later name token is **Error** before any
write. `clone` with fewer than two name tokens is **Error**
before any write.

The name, `<from>`, and `<to>` are one token each and must pass
`git check-ref-format --branch`. A failure is **Error** before
any write. Lookup is the exact basename. `fluent` is a repo
named `fluent`, not the gitify component of `pytch-fluent`.

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

## Dry-run

`dry-run` prints the placement, the git and gh commands, the
attribute lines, and the runnify tail that would have run.
It writes nothing, asks nothing, and does not retitle. A
missing clone source is printed as the question that would
have been asked. It does not call AskQuestion. It does not
start runnify.

---

## Runnify

A non-empty tail runs only after the build succeeds. Read
and follow `~/.grok/skills/runnify/SKILL.md` (repo:
`.grok/runnify/SKILL.md`). The tail is the prompt,
including `1image`, `3pass`, and `img=` tokens. Buildify
does not print the scratch or Npass acknowledgements and
does not read scratch. Runnify does, under its own rules.

The work root is the repo just built, not the sva-skills
checkout and not the folder that was open when buildify
started. When the tail runs, runnify's own contract
retitles to `RUN:`.

A failed build, a declined create, or `dry-run` does not
start runnify. An empty tail stops after a short build
report: path, created or ensured or cloned, and that the
git-crypt check passed.

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
Results when a tail ran. `dry-run` does not write that file.

## Optify

Cite the optify skill's `references/optify_contract.md`. On: short router, and only the mode just parsed. Off: the full reference set. Clear and compact follow that contract. Help, tldr, pass, and empty usage do not retitle.

## Window title

Cite `docs/window_title.md`. Prefix for this verb: `BUILD:`.
Summary is three to six words (`create test-repo`,
`clone foo to bar`, `ensure test-repo`). Whole name at most
48 characters. Set the tmux window name per that contract
on a live create, ensure, or clone, only when `TMUX` is set.

Help, tldr, pass, `--help`, `/?`, empty usage, and
`dry-run` do not retitle. A stop (bad name, two checkouts,
missing sibling origin, check-attr failure, branch not
`main`) does not retitle. `BUILD` is not a phasify ancestor
prefix. When the tail runs, runnify retitles to `RUN:`.

---

## Hard rules

- Thin project-setup verb. One repo, then the runnify tail.
  No language, CI, or Docker scaffold. No alias. No
  `scripts/cli.sh` subcommand. No shell script in this skill.
- Help, tldr, and pass print their page and stop. They do
  not create a repo and do not retitle. Empty `/buildify`
  is short usage.
- Image, pass, and `img=` tokens stay in the tail. Buildify
  does not read scratch and does not print those
  acknowledgements.
- One bare `dry-run`. Two is **Error** before any write.
  Dry-run writes nothing, asks nothing, and does not retitle.
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
  succeeds. The work root is that repo.
- Cite `docs/from_contract.md`, the docify skill's
  `references/docify_contract.md`, the optify skill's
  `references/optify_contract.md`, and `docs/window_title.md`.
  Prefix `BUILD:`.
