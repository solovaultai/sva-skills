# /buildify

Prepare one private git-crypt GitHub repo and a README. If it
already exists, make it reachable and encrypt secret-like files.
`clone <from> <to>` duplicates an existing repo. Words after the
repo are runnify's prompt. `1image`, `3pass`, and `img=` in that
tail go to runnify. `dry-run` prints the action and writes nothing.
`from=` splices local files (`docs/from_contract.md`). `docify`
writes the deliverable (the docify skill's `references/docify_contract.md`):
the build report, and the runnify Results when a tail ran.
Window prefix `BUILD:` (`docs/window_title.md`). No smart mode.
No alias. Empty `/buildify` is short usage.

```text
/buildify <name> [instructions…]       — create or ensure that repo
/buildify clone <from> <to> [instructions…] — duplicate <from> into <to>
/buildify dry-run <name> [instructions…]    — print the action; write nothing
/buildify help                         — full reference (also --help / /?)
/buildify tldr                         — short form (stop)
/buildify pass                         — Pass (Npass) subsection only (also pass help)
```

`buildify test-repo make a repo that tests our other repos 1image 3pass`
is buildify on `test-repo`, then runnify with that sentence plus
`1image 3pass`.

| Argument | What it does | Why |
|----------|--------------|-----|
| *(empty)* | Short usage | Not a commit. Flags only is the same |
| `<name>` | Create or ensure that one repo | One token. Must pass `git check-ref-format --branch`. Exact basename |
| `clone <from> <to>` | New repo `<to>` copied from `<from>`, new git-crypt key | `<from>` missing: ask, then create `<to>` or stop. Do not create `<from>` |
| instructions | Runnify on that tail after the build | Work root is the repo just built. Image and pass tokens stay in the tail |
| `dry-run` | Print placement, git and gh commands, attribute lines, and the tail | Writes nothing. Asks nothing. Does not retitle. Does not start runnify |
| `help` / `tldr` / `pass` | Print that page and stop | `buildify 1image help` is help. No repo. No retitle |

## Create

Neither a local checkout nor GitHub `solovaultai/<name>`.
`git init -b main`. `git-crypt init` with a new key. No copied
key, no `git-crypt add-gpg-user`, no key export. Write the gitify
put `.gitattributes` block (`.env`, `.env.*`, `credentials.json`,
`id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`, `*.pem`, `*.key`).
README when absent: the repo name as a heading, and one sentence
that the repository is private and secret-like files are git-crypt
encrypted. `git check-attr filter` must print `git-crypt` before
the commit. One commit that says the repo was created with
git-crypt and names those rules. Private GitHub repo. Origin
`git@github-adworkinitp:<owner>/<name>.git` from a live sibling
origin (checked origins use `solovaultai`). Disagreeing siblings
stop before `gh repo create`. `git push -u origin main`.

Placement: one checkout under `src` with that basename is the
repo. Two is **Error**. None, and `/home/ami/src/<prefix>` exists
and is not a repo, and the name starts with `<prefix>-`:
`/home/ami/src/<prefix>/<name>` (longest prefix). Else
`/home/ami/src/<name>`. Do not create a family parent.

## Ensure

Already a checkout or `solovaultai/<name>`. Clone when GitHub
exists and there is no checkout (SSH URL). `gh repo unarchive`
when `isArchived` is true. Move an `archive` path segment the way
gitify moves `/home/ami/src/archive/pytch/pytch-iam`. `git
ls-remote origin` must succeed. Rewrite a `github.com` origin
before the push. Branch must be `main` before any `git add`. Do
not checkout `main`. `git-crypt init` only when `.git-crypt` is
missing. Add missing gitify attribute lines. Leave a
`.gitattributes !filter !diff` line that is already there.
Secret-like basenames (do not read contents): `.env`, `.env.*`,
`credentials.json`, `id_rsa`, `id_dsa`, `id_ecdsa`, `id_ed25519`,
`*.pem`, `*.key`, not `*.pub`. Do not gitignore `.env`. Stage
`.gitattributes`, a README that was added, and those secret-like
paths. One commit that says git-crypt was ensured, then
`git push origin main`. A clean match is noted. No empty commit.
Prior commits can still hold plaintext. Do not rewrite history.

## Clone

`<to>` must not already be a checkout or a GitHub repo. A locked
source (ciphertext, unlock not available) stops before any copy.
Copy the work tree except `.git` and `.git-crypt`. Keep the source
README and its attribute lines. Add any missing gitify secret
lines. New key. Same check-attr, commit, private GitHub, and push
as create. Do not modify the source.

## Runnify

Non-empty tail only after a successful build. Empty tail: report
the path, created or ensured or cloned, and that the git-crypt
check passed. Failed build, declined create, and dry-run do not
start runnify.
