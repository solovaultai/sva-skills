# Buildify — user reference

Print this file as the response when the user runs `/buildify help`,
`/buildify --help`, or `/buildify /?`. Also when the first token
after the help-recognition strip is `help`, `--help`, or `/?`
(`help me …` included). Do not create a repo. `/buildify tldr`
prints the short page (`references/TLDR.md`), not this file. Exact
`tldr` stays that short page. `tldr help` is not Help.

If the first token after that strip is `pass`, including `pass help`,
print only the **Pass (`Npass`)** section below and stop. There is
no `/pass` skill.

Empty `/buildify` is short usage, not this page.

---

## What it does

Prepares one private GitHub repo with git-crypt, a README, and the
gitify secret attributes. If the repo already exists, makes it
reachable and git-crypt enabled, and encrypts secret-like files.
`clone <from> <to>` duplicates an existing repo into a new one.
Words after the repo are a runnify prompt. Image, pass, and `img`
tokens in that tail are passed to runnify. They are not buildify
directives.

`buildify test-repo make a repo that tests our other repos 1image 3pass`
is buildify on `test-repo`, then runnify with
`make a repo that tests our other repos 1image 3pass`.

No language, CI, or Docker scaffold. No alias. No smart mode.

`from=` / `from:` splices local files into the prompt (see
`docs/from_contract.md`). Help, tldr, pass, and empty do not read
files.

A typed-line `docify` / `docpathify` writes this verb's deliverable
(see the docify skill's `references/docify_contract.md`). The
deliverable is the build report, and the runnify Results when a
tail ran. Help, tldr, pass, empty, and dry-run do not write that
file.

Window title prefix is `BUILD:` (see `docs/window_title.md`).
Help, tldr, pass, empty usage, and dry-run do not retitle. A live
create, ensure, or clone does, when `TMUX` is set. `BUILD` is not
a phasify ancestor prefix. When the tail runs, runnify retitles
to `RUN:`.

```text
/buildify <name> [instructions…]
/buildify clone <from> <to> [instructions…]
/buildify dry-run <name> [instructions…]
/buildify help            — this reference (also --help, /?)
/buildify tldr            — short form (stop)
/buildify pass help       — Pass (Npass) subsection (also `pass`)
```

---

## Grammar

Typed line only. File bodies are not scanned.

1. Flag parse recognizes help, `--help`, `/?`, tldr, pass, and
   `pass help` only. `buildify 1image help` is help. Those modes
   stop. They do not create a repo and do not retitle.
2. A bare token `dry-run` is buildify's. It is removed so runnify
   never sees it. Two bare `dry-run` tokens is **Error** before
   any write.
3. After that, first token `clone` takes the next two tokens as
   `<from>` and `<to>`. Anything left is the runnify tail, image
   and pass tokens included.
4. Otherwise the first token is the repo name. Anything left is
   the runnify tail, unchanged.
5. A flag-shaped token (`1image`, `3pass`, `img=…`) is never a
   repo name. Empty `/buildify`, or a line whose only tokens were
   flags, is short usage.

`clone` is reserved only as that first task token.
`buildify test-repo clone the fixtures` builds `test-repo` and
hands `clone the fixtures` to runnify.

The name is one token and must pass `git check-ref-format --branch`.
Lookup is the exact basename. `fluent` is a repo named `fluent`,
not the gitify component of `pytch-fluent`.

---

## Placement

Search every directory under the nearest ancestor named `src`.
Do not walk above `src`. Do not enter `.git` or `node_modules`.
A directory with `.git` whose basename equals the name is a
checkout. Two such checkouts is **Error** before any write.
One checkout: that checkout.

No checkout, and `/home/ami/src/<prefix>` exists, is not a git
repo, and the name starts with `<prefix>-`:
`/home/ami/src/<prefix>/<name>`. Longest prefix wins.
`sva-new` lands in `/home/ami/src/sva/`. No such prefix:
`/home/ami/src/<name>`. `test-repo` lands at
`/home/ami/src/test-repo`.

Create only the new repo directory. Do not create a family
parent. Do not nest a new repo inside a directory that is
itself a git repo. If the destination exists and is not the
checkout being repaired, stop before any write.

---

## Create

The name is neither a local checkout nor GitHub repo
`solovaultai/<name>`. The steps are gitify put's create steps.
The attribute block is that skill's block:

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

1. `git init -b main`
2. `git-crypt init`. New key. Do not copy a key. Do not run
   `git-crypt add-gpg-user`. Do not export a key.
   `/home/ami/src/git-crypt-instructions.txt` is a personal note,
   not the contract.
3. Write that `.gitattributes` block.
4. Write `README.md` when absent: a heading with the repo name,
   and one sentence that the repository is private and secret-like
   files are git-crypt encrypted.
5. `git check-attr filter` must print `git-crypt` for the gitify
   check paths (`.env`, `.env.example`, `credentials.json`,
   `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`, a `*.pem` path,
   and a `*.key` path) before the commit. If it does not, stop.
   No commit and no push.
6. One initial commit. The message says the repo was created with
   git-crypt and names those attribute rules.
7. Private GitHub repo. Owner comes from a live sibling origin.
   Origins already checked use `solovaultai` and
   `git@github-adworkinitp`. Set origin to
   `git@github-adworkinitp:<owner>/<name>.git`. Do not leave the
   `github.com` URL `gh` prints. `git push -u origin main`. If
   sibling origins disagree on host or owner, stop before
   `gh repo create`.

---

## Ensure

The name already exists locally or as `solovaultai/<name>`.

- GitHub repo, no checkout, `isArchived` false: `git clone` into
  the placement path. SSH URL, not `github.com`.
- GitHub `isArchived` true: `gh repo unarchive <owner>/<name> --yes`.
- Checkout under a path segment `archive`: move it the way gitify
  unarchive moves `/home/ami/src/archive/pytch/pytch-iam`. If the
  destination exists, or its parent does not, stop before the move.
- `git ls-remote origin` must succeed. A `github.com` origin is
  rewritten to `git@github-adworkinitp:<owner>/<name>.git` before
  the push.
- The branch must be `main` before any `git add`. Any other
  branch, including `master`, or a detached `HEAD`, stops the
  turn. Do not checkout `main`.
- No `.git-crypt` yet: `git-crypt init` with a new key. Same key
  rules as create.
- `.gitattributes` missing the gitify lines: add the missing
  lines. Leave project-specific lines. Leave a
  `.gitattributes !filter !diff` line if the file already has one.
- Secret-like is the gitify basename rule: `.env`, a name starting
  with `.env.`, `credentials.json`, `id_rsa`, `id_dsa`,
  `id_ecdsa`, `id_ed25519`, a name ending in `.pem` or `.key`,
  and not a name ending in `.pub`. Do not read file contents.
  Do not gitignore `.env`.
- `git check-attr filter` must print `git-crypt` for each of those
  paths that exist, and for the gitify check paths. Stage
  `.gitattributes`, `README.md` if it was added, and those
  secret-like paths. Do not stage unrelated files.
- Missing `README.md`: the same minimal README as create.
- One commit, then `git push origin main`. The message says
  git-crypt was ensured and names the attribute rules. A clean
  tree that already matches is noted. No empty commit.
- Prior commits can still hold plaintext. Report that. Do not
  rewrite history.

---

## Clone

`buildify clone <from> <to>`.

`<from>` is an exact basename under `src`, or GitHub
`solovaultai/<from>`. Zero matches: the source is missing. Ask
whether to create a new repo named `<to>`. Yes runs create for
`<to>`. No stops. Do not create `<from>`. Do not guess.

`<to>` already a checkout or a GitHub repo: stop before any copy.
Do not overwrite.

Source work tree locked (ciphertext, unlock not available): stop
before any copy.

Create the `<to>` directory with the placement rule.
`git init -b main`. `git-crypt init` with a new key. Copy the
source work tree except `.git` and `.git-crypt`. Keep the source
README. Keep source attribute lines, and add any missing gitify
secret lines. Same check-attr, commit, private GitHub, and push
as create. Do not modify the source repo.

---

## Dry-run

Prints the placement, the git and gh commands, the attribute
lines, and the runnify tail that would have run. Writes nothing.
Asks nothing. Does not retitle. Does not start runnify.

---

## Runnify

A non-empty tail runs only after the build succeeds. The tail is
the prompt, including `1image`, `3pass`, and `img=` tokens.
Buildify does not print the scratch or Npass acknowledgements
and does not read scratch. Runnify does. The work root is the
repo just built.

A failed build, a declined create, or dry-run does not start
runnify. An empty tail stops after a short build report: path,
created or ensured or cloned, and that the git-crypt check passed.

---

## Tokens

| Token | Effect |
|-------|--------|
| `<name> [instructions…]` | Create or ensure that repo. The rest is the runnify tail. |
| `clone <from> <to> [instructions…]` | Duplicate `<from>` into `<to>`. The rest is the runnify tail. |
| `dry-run` | Bare token. Print the action. Write nothing. Two is **Error**. |
| `1image` / `3pass` / `img=` | Never a repo name. In the tail, passed to runnify. |
| `help` / `--help` / `/?` | Print this reference and stop. |
| `tldr` | Print the short page and stop. |
| `pass` / `pass help` | Print the Pass section and stop. |

---

## Pass (`Npass`)

There is **no** `/pass` skill. After the help-recognition strip,
first token `pass` (including `pass help`) prints **this section**
and stops. Full reference: `/promptify pass help`.

**Tokens:** `Npass` / `N-pass` / `N pass`. First numbered instance
left to right, typed line only. Default **1**.

**Meaning:** buildify does not loop. A pass token in the
instruction tail is runnify's. Buildify does not print the Npass
acknowledgement.

```text
/buildify pass
/buildify pass help
/buildify test-repo 2pass
/promptify pass help
```

---

## Window title

Prefix `BUILD:` (`docs/window_title.md`). Summary is three to six
words (`create test-repo`, `clone foo to bar`). Whole name at
most 48 characters. A live create, ensure, or clone sets it when
`TMUX` is set. Help, tldr, pass, empty usage, and dry-run do not
retitle. `BUILD` is not a phasify ancestor prefix. The tail's
runnify retitles to `RUN:`.
